/obj/structure/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	anchored = 0
	density = 0
	pull_slowdown = PULL_SLOWDOWN_TINY
	var/mob/living/carbon/human/attached
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/reagent_containers/beaker
	var/list/transfer_amounts = list(REM, 1, 2)
	var/transfer_amount = 1

/obj/structure/iv_drip/verb/set_APTFT()
	set name = "Set IV transfer amount"
	set category = "Object"
	set src in range(1)
	if(!istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return
	var/N = input("Amount per transfer from this:","[src]") as null|anything in transfer_amounts
	if(N)
		transfer_amount = N

/obj/structure/iv_drip/on_update_icon()
	if(attached)
		icon_state = "hooked"
	else
		icon_state = ""

	ClearOverlays()

	if(beaker)
		var/datum/reagents/reagents = beaker.reagents
		var/percent = round((reagents.total_volume / beaker.volume) * 100)
		if(reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			switch(percent)
				if(0 to 9)		filling.icon_state = "reagent0"
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"
			filling.icon += reagents.get_color()
			AddOverlays(filling)

		if(attached)
			var/image/light = image('icons/obj/iv_drip.dmi', "light_full")
			if(percent < 15)
				light.icon_state = "light_low"
			else if(percent < 60)
				light.icon_state = "light_mid"
			AddOverlays(light)

/obj/structure/iv_drip/MouseDrop(over_object, src_location, over_location)
	if(!CanMouseDrop(over_object))
		return

	if(attached)
		visible_message("\The [attached] is taken off \the [src]")
		attached = null
	else if(ishuman(over_object))
		visible_message("\The [usr] hooks \the [over_object] up to \the [src].")
		attached = over_object
		set_next_think(world.time)

	update_icon()

/obj/structure/iv_drip/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/reagent_containers))
		if(!QDELETED(src.beaker))
			to_chat(user, "There is already a reagent container loaded!")
			return
		if(!user.drop(W, src))
			return
		beaker = W
		to_chat(user, "You attach \the [W] to \the [src].")
		update_icon()
	else
		return ..()

/obj/structure/iv_drip/Destroy()
	attached = null
	qdel(beaker)
	beaker = null
	. = ..()

/obj/structure/iv_drip/think()
	if(attached)
		if(!Adjacent(attached))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			attached.apply_damage(1, BRUTE, pick(BP_R_ARM, BP_L_ARM))
			attached = null
			update_icon()
			return
	else
		return

	if(!beaker)
		set_next_think(world.time + 1 SECOND)
		return

	if(mode) // Give blood
		if(beaker.volume > 0)
			beaker.reagents.trans_to_mob(attached, transfer_amount, CHEM_BLOOD)
			update_icon()
	else // Take blood
		var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		amount = min(amount, 4)

		if(amount == 0) // If the beaker is full, ping
			if(prob(5)) visible_message("\The [src] pings.")
			set_next_think(world.time + 1 SECOND)
			return

		if(!attached.should_have_organ(BP_HEART))
			set_next_think(world.time + 1 SECOND)
			return

		// If the human is losing too much blood, beep.
		if(attached.get_blood_volume() < BLOOD_VOLUME_SAFE * 1.05)
			visible_message("\The [src] beeps loudly.")

		if(attached.take_blood(beaker,amount))
			update_icon()

	set_next_think(world.time + 1 SECOND)

/obj/structure/iv_drip/attack_hand(mob/user as mob)
	if(beaker)
		beaker.dropInto(loc)
		beaker = null
		update_icon()
	else
		return ..()

/obj/structure/iv_drip/attack_robot(mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle IV Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		to_chat(usr, "<span class='warning'>You can't do that.</span>")
		return

	if(usr.incapacitated())
		return

	mode = !mode
	to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")

/obj/structure/iv_drip/_examine_text(mob/user)
	. = ..()

	if (get_dist(src, user) > 2)
		return

	. += "\nThe IV drip is [mode ? "injecting" : "taking blood"]."
	. += "\nIt is set to transfer [transfer_amount]u of chemicals per cycle."

	if(beaker)
		if(beaker.reagents && beaker.reagents.total_volume)
			. += "\n<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>"
		else
			. += "\n<span class='notice'>Attached is an empty [beaker].</span>"
	else
		. += "\n<span class='notice'>No chemicals are attached.</span>"

	. += "\n<span class='notice'>[attached ? attached : "No one"] is hooked up to it.</span>"
