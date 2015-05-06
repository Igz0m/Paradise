/datum/game_mode
	var/list/datum/mind/superheroes = list()
	var/list/datum/mind/supervillains = list()
	var/list/datum/mind/greyshirts = list()

/datum/superheroes
	var/name
	var/list/default_genes = list()
	var/list/default_spells = list()


/datum/superheroes/proc/equip(var/mob/living/carbon/human/H)
	H.fully_replace_character_name(H.real_name, name)
	for(var/obj/item/W in H)
		if(istype(W,/obj/item/organ)) continue
		H.unEquip(W)

/datum/superheroes/proc/assign_genes(var/mob/living/carbon/human/H)
	if(default_genes.len)
		for(var/gene in default_genes)
			H.mutations |= gene
		H.update_mutations()
	return

/datum/superheroes/proc/assign_spells(var/mob/living/carbon/human/H)
	if(default_spells.len)
		for(var/spell in default_spells)
			var/obj/effect/proc_holder/spell/wizard/S = spell
			if(!S) return
			H.spell_list += new S
			H.update_power_buttons()
	return


/datum/superheroes/owlman
	name = "Owlman"
	default_genes = list(REGEN, NO_BREATH)

/datum/superheroes/owlman/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/owl(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/owl_mask(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/bluespace/owlman(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(H), slot_glasses)

	var/obj/item/weapon/card/id/syndicate/W = new(H)
	W.name = "[H.real_name]'s ID Card (Superhero)"
	W.access = get_all_accesses()
	W.assignment = "Superhero"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	H.regenerate_icons()

	ticker.mode.superheroes += H.mind


/datum/superheroes/griffin
	name = "The Griffin"
	default_genes = list(LASER, RESIST_COLD, RESIST_HEAT, REGEN, NO_BREATH)
	default_spells = list(/obj/effect/proc_holder/spell/wizard/targeted/recruit)

/datum/superheroes/griffin/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/griffin(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/griffin(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings/griffinwings(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/griffin(H), slot_head)

	var/obj/item/weapon/card/id/syndicate/W = new(H)
	W.name = "[H.real_name]'s ID Card (Supervillain)"
	W.access = get_all_accesses()
	W.assignment = "Supervillain"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	H.regenerate_icons()

	ticker.mode.supervillains += H.mind


/datum/superheroes/lightnian
	name = "LightnIan"
	default_genes = list(REGEN, NO_BREATH)
	default_spells = list(/obj/effect/proc_holder/spell/wizard/targeted/lightning/lightnian)

/datum/superheroes/lightnian/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/brown(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/corgisuit(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/corgi(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(H), slot_gloves)

	var/obj/item/weapon/card/id/syndicate/W = new(H)
	W.name = "[H.real_name]'s ID Card (Superhero)"
	W.access = get_all_accesses()
	W.assignment = "Superhero"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	H.regenerate_icons()

	ticker.mode.superheroes += H.mind


//The Griffin's special recruit abilitiy
/obj/effect/proc_holder/spell/wizard/targeted/recruit
	name = "Recruit Greyshirt"
	desc = "Allows you to recruit a conscious, non-braindead, non-catatonic human to be part of the Greyshirts, your personal henchmen. This works on Civilians only and you can recruit a maximum of 3!."
	panel = "Shadowling Abilities"
	charge_max = 450
	clothes_req = 0
	range = 1 //Adjacent to user
	var/recruiting = 0

/obj/effect/proc_holder/spell/wizard/targeted/recruit/cast(list/targets)
	for(var/mob/living/carbon/human/target in targets)
		if(ticker.mode.greyshirts.len >= 3)
			usr << "<span class='warning'>You have already recruited the maximum number of henchmen.</span>"
		if(!in_range(usr, target))
			usr << "<span class='warning'>You need to be closer to enthrall [target].</span>"
			charge_counter = charge_max
			return
		if(!target.ckey)
			usr << "<span class='warning'>The target has no mind.</span>"
			charge_counter = charge_max
			return
		if(target.stat)
			usr << "<span class='warning'>The target must be conscious.</span>"
			charge_counter = charge_max
			return
		if(!ishuman(target))
			usr << "<span class='warning'>You can only recruit humans.</span>"
			charge_counter = charge_max
			return
		if(target.mind.assigned_role != "Civilian")
			usr << "<span class='warning'>You can only recruit Civilians.</span>"
		if(recruiting)
			usr << "<span class='danger'>You are already recruiting!</span>"
			charge_counter = charge_max
			return
		recruiting = 1
		usr << "<span class='danger'>This target is valid. You begin the recruiting process.</span>"
		target << "<span class='userdanger'>[usr] focuses in concentration. Your head begins to ache.</span>"

		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					usr << "<span class='notice'>You begin by introducing yourself and explaining what you're about.</span>"
					usr.visible_message("<span class='danger'>[usr]'s introduces himself and explains his plans.</span>")
				if(2)
					usr << "<span class='notice'>You begin the recruitment of [target].</span>"
					usr.visible_message("<span class='danger'>[usr] leans over towards [target], whispering excitedly as he gives a speech.</span>")
					target << "<span class='danger'>You feel yourself agreeing with [usr], and a surge of loyalty begins building.</span>"
					target.Weaken(12)
					sleep(20)
					if(isloyal(target))
						usr << "<span class='notice'>They are enslaved by Nanotrasen. You feel their interest in your cause wane and disappear.</span>"
						usr.visible_message("<span class='danger'>[usr] stops talking for a moment, then moves back away from [target].</span>")
						target << "<span class='danger'>Your loyalty implant activates and a sharp pain reminds you of your loyalties to Nanotrasen.</span>"
						return
				if(3)
					usr << "<span class='notice'>You begin filling out the application form with [target].</span>"
					usr.visible_message("<span class='danger'>[usr] pulls out a pen and paper and begins filling an application form with [target].</span>")
					target << "<span class='danger'>You are being convinced by [usr] to fill out an application form to become a henchman.</span>" //Ow the edge
			if(!do_mob(usr, target, 100)) //around 30 seconds total for enthralling, 45 for someone with a loyalty implant
				usr << "<span class='danger'>The enrollment process has been interrupted - you have lost the attention of [target].</span>"
				target << "<span class='warning'>You move away and are no longer under the charm of [usr]. The application form is null and void.</span>"
				recruiting = 0
				return

		recruiting = 0
		usr << "<span class='notice'>You have recruited <b>[target]</b> as your henchman!</span>"
		target << "<span class='deadsay'><b>You have decided to enroll as a henchman for [usr]. You are now part of the feared 'Greyshirts'.</b></span>"
		target << "<span class='deadsay'><b>You must follow the orders of [usr], and help him succeed in his dastardly schemes.</span>"
		target << "<span class='deadsay'>You may not harm other Greyshirt or [usr]. However, you do not need to obey other Greyshirts.</span>"
		target.adjustOxyLoss(-200) //In case the shadowling was choking them out
		ticker.mode.greyshirts += target.mind
