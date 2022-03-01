/datum/pai_software/
	var/name = ""
	var/cost = 0 // Cost in RAM for this software
	var/mob/living/silicon/pai/pai // Reference to the pAI we belong to

/datum/pai_software/proc/install()
	return

/datum/pai_software/proc/activate()
	return

/datum/pai_software/simple/
	var/obj/simple_item
	var/ui_mode = FALSE // Whether we should access ui_interact or just attack_hand

/datum/pai_software/simple/install()
	simple_item = new(pai)

/datum/pai_software/simple/activate()
	if(ui_mode)
		simple_item.ui_interact(pai)
	else
		simple_item.attack_hand(pai)

/datum/pai_software/simple/Destroy()
	QDEL_NULL(simple_item)
	return ..()

/datum/pai_software/simple/internal_gps/
	name = "Internal GPS"
	cost = 35
	simple_item = /obj/item/gps/pai

/datum/pai_software/simple/newscaster/
	name = "Newscaster"
	cost = 20
	simple_item = /obj/machinery/newscaster
	ui_mode = TRUE

/datum/pai_software/simple/instrument/
	name = "Loudness Booster"
	cost = 20
	simple_item = /obj/item/instrument/piano_synth

/datum/pai_software/simple/signaler/
	name = "Remote Signaler"
	cost = 20
	simple_item = /obj/item/assembly/signaler/internal
	ui_mode = TRUE

/datum/pai_software/simple/analyzer/
	name = "Atmosphere Analyzer"
	cost = 5
	simple_item = /obj/item/analyzer

/obj/item/assembly/signaler/interanl/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
