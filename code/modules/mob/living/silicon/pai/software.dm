#define SIMPLEMODE_HAND 0
#define SIMPLEMODE_UI 1
#define SIMPLEMODE_SELF 2

/mob/living/silicon/pai
	var/list/available_software = list(
		/datum/pai_software/crew_manifest,
		/datum/pai_software/encryption_keys,
		/datum/pai_software/security_hud,
		/datum/pai_software/medical_hud,
		/datum/pai_software/translator,
		/datum/pai_software/newscaster,
		/datum/pai_software/simple/instrument,
		/datum/pai_software/simple/internal_gps,
		/datum/pai_software/simple/signaler,
		/datum/pai_software/simple/analyzer
	)

/datum/pai_software
	var/name = ""
	var/cost = 0 // Cost in RAM for this software
	var/mob/living/silicon/pai/pai // Reference to the pAI we belong to

/datum/pai_software/proc/install()
	return

/datum/pai_software/proc/activate()
	return

/datum/pai_software/crew_manifest
	name = "Crew Manifest"
	cost = 5

/datum/pai_software/crew_manifest/activate()
	pai.ai_roster()

/datum/pai_software/encryption_keys
	name = "Radio Encryption Keys"
	cost = 25

/datum/pai_software/encryption_keys/install()
	activate()

/datum/pai_software/encryption_keys/activate()
	to_chat(pai, "<span class='notice'>You have [!pai.radio.subspace_transmission ? "enabled" : "disabled"] encrypted radio frequencies.</span>")
	pai.radio.subspace_transmission = !pai.radio.subspace_transmission

/datum/pai_software/security_hud
	name = "Security HUD"
	cost = 20
	var/secHUD = FALSE

/datum/pai_software/security_hud/install()
	activate()

/datum/pai_software/security_hud/activate()
	secHUD = !secHUD
	if(secHUD)
		var/datum/atom_hud/sec = GLOB.huds[pai.sec_hud]
		sec.add_hud_to(pai)
	else
		var/datum/atom_hud/sec = GLOB.huds[pai.sec_hud]
		sec.remove_hud_from(pai)

/datum/pai_software/medical_hud
	name = "Medical HUD"
	cost = 20
	var/medHUD = FALSE

/datum/pai_software/medical_hud/install()
	activate()

/datum/pai_software/medical_hud/activate()
	medHUD = !medHUD
	if(medHUD)
		var/datum/atom_hud/med = GLOB.huds[pai.med_hud]
		med.add_hud_to(pai)
	else
		var/datum/atom_hud/med = GLOB.huds[pai.med_hud]
		med.remove_hud_from(pai)

/datum/pai_software/translator
	name = "Universal Translator"
	cost = 35

/datum/pai_software/translator/install()
	pai.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)

/datum/pai_software/translator/activate()
	pai.open_language_menu() // Translator isn't a "thing", let's just open the language menu for them

/datum/pai_software/newscaster
	name = "Newscaster"
	cost = 20
	var/obj/machinery/newscaster/machine
	var/machine_type = /obj/machinery/newscaster

/datum/pai_software/newscaster/install()
	machine = new machine_type(pai)

/datum/pai_software/newscaster/activate()
	machine.attack_hand(pai);

/datum/pai_software/simple// Tons of software literally embed an item into the pAI
	var/obj/item/simple_item
	var/simple_item_type
	var/mode = SIMPLEMODE_HAND // Whether we should access ui_interact, attack_hand or attack_self

/datum/pai_software/simple/install()
	simple_item = new simple_item_type(pai)

/datum/pai_software/simple/activate()
	switch(mode)
		if(SIMPLEMODE_HAND)
			simple_item.attack_hand(pai)
		if(SIMPLEMODE_UI)
			simple_item.ui_interact(pai)
		if(SIMPLEMODE_SELF)
			simple_item.attack_self(pai)

/datum/pai_software/simple/Destroy()
	QDEL_NULL(simple_item)
	return ..()

/datum/pai_software/simple/internal_gps
	name = "Internal GPS"
	cost = 35
	simple_item_type = /obj/item/gps/pai

/datum/pai_software/simple/instrument
	name = "Loudness Booster"
	cost = 20
	simple_item_type = /obj/item/instrument/piano_synth
	mode = SIMPLEMODE_UI

/datum/pai_software/simple/signaler
	name = "Remote Signaler"
	cost = 20
	simple_item_type = /obj/item/assembly/signaler/internal
	mode = SIMPLEMODE_UI

/datum/pai_software/simple/analyzer
	name = "Atmosphere Analyzer"
	cost = 5
	simple_item_type = /obj/item/analyzer
	mode = SIMPLEMODE_SELF

/datum/pai_software/complex
	var/ui_data

#undef SIMPLEMODE_HAND
#undef SIMPLEMODE_UI
#undef SIMPLEMODE_SELF
