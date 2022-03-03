/mob/living/silicon/pai/proc/check_DNA(mob/living/silicon/pai/pai)
	var/mob/living/holder = get_holder()
	if(!istype(holder))
		return
	to_chat(pai, "<span class='notice'>Requesting a DNA sample.</span>")
	var/confirm = alert(holder, "[pai] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "Checking DNA", list("Yes", "No"))
	if(confirm == "Yes")
		holder.visible_message("<span class='notice'>[holder] presses [holder.p_their()] thumb against [pai].</span>",\
						"<span class='notice'>You press your thumb against [pai].</span>",\
						"<span class='notice'>[pai] makes a sharp clicking sound as it extracts DNA material from [holder].</span>")
		if(!holder.has_dna())
			to_chat(pai, "<b>No DNA detected.</b>")
			return
		to_chat(pai, "<font color = red><h3>[holder]'s UE string : [holder.dna.unique_enzymes]</h3></font>")
		if(holder.dna.unique_enzymes == pai.master_dna)
			to_chat(pai, "<b>DNA is a match to stored holder DNA.</b>")
		else
			to_chat(pai, "<b>DNA does not match stored holder DNA.</b>")
	else
		to_chat(pai, "<span class='warning'>[holder] does not seem like [holder.p_theyre()] going to provide a DNA sample willingly.</span>")

/mob/living/silicon/pai/proc/extend_cable()
	QDEL_NULL(hacking_cable) //clear any old cables
	hacking_cable = new
	var/transfered_to_mob
	var/mob/living/holder = get_holder()
	if(isliving())
		if(holder.put_in_hands(hacking_cable))
			transfered_to_mob = TRUE
			holder.visible_message("<span class='warning'>A port on [src] opens to reveal \a [hacking_cable], which you quickly grab hold of.", "<span class='hear'>You hear the soft click of something light and manage to catch hold of [hacking_cable].</span></span>")
		if(!transfered_to_mob)
			hacking_cable.forceMove(drop_location())
			hacking_cable.visible_message("<span class='warning'>A port on [src] opens to reveal \a [hacking_cable], which promptly falls to the floor.", "<span class='hear'>You hear the soft click of something light and hard falling to the ground.</span></span>")

/mob/living/silicon/pai/proc/get_holder()
	return get(card, /mob/living)// Walk up the loc stack to find who holds us, even if we're in a PDA.
