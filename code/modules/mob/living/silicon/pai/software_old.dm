/mob/living/silicon/pai/var/list/available_software = list(
															//Nightvision
															//T-Ray
															//radiation eyes
															//chem goggs
															//mesons
															//"crew manifest" = 5,
															"digital messenger" = 5,
															//"atmosphere sensor" = 5,
															"photography module" = 5,
															"camera zoom" = 10,
															"printer module" = 10,
															//"remote signaler" = 10,
															"medical records" = 10,
															"security records" = 10,
															"host scan" = 10,
															//"medical HUD" = 20,
															//"security HUD" = 20,
															//"loudness booster" = 20,
															//"newscaster" = 20,
															"door jack" = 25,
															//"encryption keys" = 25,
															//"internal gps" = 35,
															//"universal translator" = 35
															)
/// Bool that determines if the pAI can refresh medical/security records.
/mob/living/silicon/pai/var/refresh_spam = FALSE
/// Cached list for medical records to send as static data
/mob/living/silicon/pai/var/list/medical_records = list()
/// Cached list for security records to send as static data
/mob/living/silicon/pai/var/list/security_records = list()

/mob/living/silicon/pai/ui_status(mob/user, state)
	return UI_INTERACTIVE

/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/mob/living/silicon/pai/ui_static_data(mob/user)
	var/list/data = list()
	var/mob/living/silicon/pai/pai = user
	data["available"] = available_software
	data["records"] = list()
	if("medical records" in pai.software)
		data["records"]["medical"] = medical_records
	if("security records" in pai.software)
		data["records"]["security"] = security_records
	return data

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["directives"] = laws.supplied
	data["door_jack"] = hacking_cable || null
	data["emagged"] = emagged
	data["image"] = card.emotion_icon
	data["installed"] = software
	data["languages"] = languages_granted
	data["master"] = list()
	data["pda"] = list()
	data["ram"] = ram
	data["refresh_spam"] = refresh_spam
	if(aiPDA)
		data["pda"]["power"] = !aiPDA.toff
		data["pda"]["silent"] = aiPDA.silent
	if(master)
		data["master"]["name"] = master
		data["master"]["dna"] = master_dna
	return data

/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy")
			if(available_software.Find(params["selection"]) && !software.Find(params["selection"]))
				/// Cost of the software to purchase
				var/cost = available_software[params["selection"]]
				if(ram >= cost)
					software.Add(params["selection"])
					ram -= cost
					var/datum/hud/pai/pAIhud = hud_used
					pAIhud?.update_software_buttons()
				else
					to_chat(usr, "<span class='notice'>Insufficient RAM available.</span>")
			else
				to_chat(usr, "<span class='notice'>Software not found.</span>")
		if("camera_zoom")
			aicamera.adjust_zoom(usr)
		if("change_image")
			var/newImage = input(usr, "Select your new display image.", "Display Image", sortList(list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What", "Sunglasses")))
			switch(newImage)
				if(null)
					card.emotion_icon = "null"
				if("Extremely Happy")
					card.emotion_icon = "extremely-happy"
				else
					card.emotion_icon = "[lowertext(newImage)]"
			card.update_icon() // have to do it like this until update_appearance() port
		if("check_dna")
			if(!master_dna)
				to_chat(src, "<span class='warning'>You do not have a master DNA to compare to!</span>")
				return FALSE
			if(iscarbon(card.loc))
				CheckDNA(card.loc, src) //you should only be able to check when directly in hand, muh immersions?
			else
				to_chat(src, "<span class='warning'>You are not being carried by anyone!</span>")
				return FALSE
		if("door_jack")
			if(params["jack"] == "jack")
				if(hacking_cable?.machine)
					hackdoor = hacking_cable.machine
					hackloop()
			if(params["jack"]  == "cancel")
				hackdoor = null
				QDEL_NULL(hacking_cable)
			if(params["jack"]  == "cable")
				extendcable()
		if("host_scan")
			if(!hostscan)
				hostscan = new(src)
			if(params["scan"] == "scan")
				hostscan()
			if(params["scan"] == "wounds")
				hostscan.attack_self(usr)
			if(params["scan"] == "limbs")
				hostscan.attack_self()
		if("pda")
			if(isnull(aiPDA))
				return FALSE
			if(params["pda"] == "power")
				aiPDA.toff = !aiPDA.toff
			if(params["pda"] == "silent")
				aiPDA.silent = !aiPDA.silent
			if(params["pda"] == "message")
				cmd_send_pdamesg(usr)
		if("photography_module")
			aicamera.toggle_camera_mode(usr)
		if("printer_module")
			aicamera.paiprint(usr)
		if("radio")
			radio.attack_self(src)
		if("refresh")
			if(refresh_spam)
				return FALSE
			refresh_spam = TRUE
			if(params["list"] == "medical")
				medical_records = GLOB.data_core.get_general_records()
			if(params["list"] == "security")
				security_records = GLOB.data_core.get_security_records()
			ui.send_full_update()
			addtimer(CALLBACK(src, .proc/refresh_again), 3 SECONDS)
	return

/mob/living/silicon/pai/proc/hostscan()
	var/mob/living/silicon/pai/pAI = usr
	var/mob/living/carbon/holder = get(pAI.card.loc, /mob/living/carbon)
	if(holder)
		pAI.hostscan.attack(holder, pAI)
	else
		to_chat(usr, "<span class='warning'>You are not being carried by anyone!</span>")
		return FALSE


/mob/living/silicon/pai/proc/hackloop()
	var/turf/turf = get_turf(src)
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
	to_chat(usr, "<span class='boldnotice'>You begin overriding the airlock security protocols.</span>")
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(turf.loc)
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force security override in progress in [turf.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force security override in progress. Unable to pinpoint location.</b></font>")
	hacking = TRUE
	if(!hackbar)
		hackbar = new(src, 100, hacking_cable.machine)
/**
 * Proc that switches whether a pAI can refresh
 * the records window again.
 */
/mob/living/silicon/pai/proc/refresh_again()
	refresh_spam = FALSE
