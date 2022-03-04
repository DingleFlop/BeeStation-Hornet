/obj/item/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	item_flags = NOBLUDGEON
	var/mob/living/silicon/pai/pai // Reference to the pAI we belong to

/obj/item/pai_cable/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(get_dist(user, target) > 1)
		return FALSE
	if(istype(target, /obj/machinery))
		var/obj/machinery/machine = target

		user.visible_message("[user] inserts [src] into a data port on [machine].",\
		"<span class='notice'>You insert [src] into a data port on [machine].</span>",\
		"<span class='italics'>You hear the satisfying click of a wire jack fastening into place.</span>")

		pai.target_machine = machine
		// TODO: Register atom move signal to check distance. Otherwise, we're still connected.
