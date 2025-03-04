/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "bed"
	anchored = 1
	can_buckle = 1
	buckle_dir = SOUTH
	buckle_lying = 1
	buckle_pixel_shift = "x=0;y=3"
	appearance_flags = DEFAULT_APPEARANCE_FLAGS | LONG_GLIDE
	var/material/material
	var/material/padding_material
	var/base_icon = "bed"
	var/material_alteration = MATERIAL_ALTERATION_ALL

/obj/structure/bed/New(newloc, new_material, new_padding_material)
	..(newloc)
	color = null
	if(!new_material)
		new_material = MATERIAL_STEEL
	material = get_material_by_name(new_material)
	if(!istype(material))
		qdel(src)
		return
	if(new_padding_material)
		padding_material = get_material_by_name(new_padding_material)
	update_icon()

/obj/structure/bed/get_material()
	return material

// Reuse the cache/code from stools, todo maybe unify.
/obj/structure/bed/on_update_icon()
	// Prep icon.
	icon_state = ""
	ClearOverlays()
	// Base icon.
	var/cache_key = "[base_icon]-[material.name]"
	if(isnull(stool_cache[cache_key]))
		var/image/I = image('icons/obj/furniture.dmi', base_icon)
		if(material_alteration & MATERIAL_ALTERATION_COLOR)
			I.color = material.icon_colour
		stool_cache[cache_key] = I
	AddOverlays(stool_cache[cache_key])
	// Padding overlay.
	if(padding_material)
		var/padding_cache_key = "[base_icon]-padding-[padding_material.name]"
		if(isnull(stool_cache[padding_cache_key]))
			var/image/I =  image(icon, "[base_icon]_padding")
			if(material_alteration & MATERIAL_ALTERATION_COLOR)
				I.color = padding_material.icon_colour
			stool_cache[padding_cache_key] = I
		AddOverlays(stool_cache[padding_cache_key])

	// Strings.
	if(material_alteration & MATERIAL_ALTERATION_NAME)
		SetName(padding_material ? "[padding_material.adjective_name] [initial(name)]" : "[material.adjective_name] [initial(name)]") //this is not perfect but it will do for now.

	if(material_alteration & MATERIAL_ALTERATION_DESC)
		desc = initial(desc)
		desc += padding_material ? " It's made of [material.use_name] and covered with [padding_material.use_name]." : " It's made of [material.use_name]."

/obj/structure/bed/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_TABLE)
		return TRUE
	return ..()

/obj/structure/bed/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return

/obj/structure/bed/bullet_act(obj/item/projectile/Proj)
	var/damage = Proj.get_structure_damage()
	if(!damage)
		return
	..()
	if(prob(50))
		return
	if(material)
		if(prob(20))
			material.place_sheet(loc)
		else
			material.place_shard(loc)
	qdel(src)
	return

/obj/structure/bed/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		dismantle()
		qdel(src)
	else if(istype(W,/obj/item/stack))
		if(padding_material)
			to_chat(user, "\The [src] is already padded.")
			return
		var/obj/item/stack/C = W
		if(C.get_amount() < 1) // How??
			qdel(C)
			return
		var/padding_type //This is awful but it needs to be like this until tiles are given a material var.
		if(istype(W,/obj/item/stack/tile/carpet))
			padding_type = MATERIAL_CARPET
		else if(istype(W,/obj/item/stack/material))
			var/obj/item/stack/material/M = W
			if(M.material && (M.material.flags & MATERIAL_PADDING))
				padding_type = "[M.material.name]"
		if(!padding_type)
			to_chat(user, "You cannot pad \the [src] with that.")
			return
		C.use(1)
		if(!isturf(loc))
			user.drop(src, get_turf(src))
		to_chat(user, "You add padding to \the [src].")
		add_padding(padding_type)
		return

	else if(isWirecutter(W))
		if(!padding_material)
			to_chat(user, "\The [src] has no padding to remove.")
			return
		to_chat(user, "You remove the padding from \the [src].")
		playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
		remove_padding()

	else if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		var/mob/living/affecting = G.affecting
		user.visible_message("<span class='notice'>[user] attempts to buckle [affecting] into \the [src]!</span>")
		if(do_after(user, 20, src))
			if(user_buckle_mob(affecting, user))
				qdel(W)
	else
		if(W.mod_weight >= 0.75)
			shake_animation(stime = 4)
		..()
/obj/structure/bed/attack_robot(mob/user)
	if(Adjacent(user)) // Robots can open/close it, but not the AI.
		attack_hand(user)

/obj/structure/bed/Move()
	. = ..()
	if(buckled_mob)
		buckled_mob.forceMove(loc, unbuckle_mob = FALSE)

/obj/structure/bed/forceMove()
	. = ..()
	if(isturf(src.loc))
		if(buckled_mob)
			buckled_mob.forceMove(loc, unbuckle_mob = FALSE)
		else
			unbuckle_mob()

/obj/structure/bed/proc/remove_padding()
	if(padding_material)
		padding_material.place_sheet(get_turf(src))
		padding_material = null
	update_icon()

/obj/structure/bed/proc/add_padding(padding_type)
	padding_material = get_material_by_name(padding_type)
	update_icon()

/obj/structure/bed/proc/dismantle()
	material.place_sheet(get_turf(src))
	if(padding_material)
		padding_material.place_sheet(get_turf(src))

/obj/structure/bed/psych
	name = "psychiatrist's couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	base_icon = "psychbed"
	buckle_pixel_shift = "x=0;y=1"

/obj/structure/bed/psych/New(newloc)
	..(newloc, MATERIAL_WOOD, MATERIAL_LEATHER)

/obj/structure/bed/padded/New(newloc)
	..(newloc, MATERIAL_PLASTIC, MATERIAL_COTTON)

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"

/obj/structure/bed/alien/New(newloc)
	..(newloc, MATERIAL_RESIN)

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	desc = "A portable bed-on-wheels made for transporting medical patients."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "rollerbed"
	anchored = 0
	buckle_pixel_shift = "x=0;y=6"
	pull_slowdown = PULL_SLOWDOWN_TINY
	var/bedtype = /obj/structure/bed/roller
	var/rollertype = /obj/item/roller
	var/obj/structure/closet/body_bag/buckled_bodybag
	var/accepts_bodybag = TRUE
	var/buckling_y = 3

/obj/structure/bed/roller/adv
	name = "advanced roller bed"
	desc = "An advanced bed-on-wheels made for transporting medical patients with maximum speed."
	icon_state = "rollerbedadv"
	bedtype = /obj/structure/bed/roller/adv
	rollertype = /obj/item/roller/adv
	pull_slowdown = PULL_SLOWDOWN_NONE

/obj/structure/bed/roller/on_update_icon()
	if(buckled_mob || buckled_bodybag)
		set_density(1)
		icon_state = "[initial(icon_state)]_up"
	else
		set_density(0)
		icon_state = "[initial(icon_state)]"

/obj/structure/bed/roller/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W) || istype(W, /obj/item/stack) || isWirecutter(W))
		return
	else if(istype(W, /obj/item/roller_holder))
		if(buckled_mob)
			user_unbuckle_mob(user)
		if(buckled_bodybag)
			manual_unbuckle(user)
		else if(rollertype)
			visible_message("[user] collapses \the [src.name].")
			new rollertype(get_turf(src))
			rollertype = null
			qdel(src)
		return
	..()

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "rollerbed_folded"
	item_state = "rbed"
	slot_flags = SLOT_BACK
	w_class = ITEM_SIZE_GARGANTUAN // Not sure if it's actually necessary, I can barely imagine this thing being bigger than a mecha part;
	var/rollertype = /obj/item/roller
	var/bedtype = /obj/structure/bed/roller
	drop_sound = SFX_DROP_AXE
	pickup_sound = SFX_PICKUP_AXE

/obj/item/roller/adv
	name = "advanced roller bed"
	desc = "A high-tech, compact version of the regular roller bed."
	icon_state = "rollerbedadv_folded"
	w_class = ITEM_SIZE_NORMAL
	rollertype = /obj/item/roller/adv
	bedtype = /obj/structure/bed/roller/adv

/obj/item/roller/attack_self(mob/user)
	if(!bedtype)
		return
	var/obj/structure/bed/roller/R = new bedtype(user.loc)
	R.add_fingerprint(user)
	bedtype = null
	qdel(src)

/obj/item/roller/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/roller_holder))
		var/obj/item/roller_holder/RH = W
		if(!RH.held)
			to_chat(user, "<span class='notice'>You collect the roller bed.</span>")
			forceMove(RH)
			RH.held = src
			return
	..()

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "rollerbed_folded"
	var/obj/item/roller/held

/obj/item/roller_holder/New()
	..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/attack_self(mob/user)
	if(!held)
		to_chat(user, "<span class='notice'>The rack is empty.</span>")
		return

	to_chat(user, "<span class='notice'>You deploy the roller bed.</span>")
	var/obj/structure/bed/roller/R = new held.bedtype(user.loc)
	R.add_fingerprint(user)
	QDEL_NULL(held)

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	if(M == buckled_mob || buckled_bodybag)
		set_density(1)
		icon_state = "[initial(icon_state)]_up"
	else
		set_density(0)
		icon_state = "[initial(icon_state)]"

	return ..()

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!rollertype)
			return
		if(!ishuman(usr))
			return
		if(buckled_mob)
			return 0
		visible_message("[usr] collapses \the [src.name].")
		new rollertype(get_turf(src))
		rollertype = null
		qdel(src)
		return


/obj/structure/bed/roller/MouseDrop_T(atom/movable/dropping, mob/user)
	if(accepts_bodybag && !buckled_bodybag && !buckled_mob && istype(dropping,/obj/structure/closet/body_bag) && ishuman(user))
		var/obj/structure/closet/body_bag/B = dropping
		if(!B.roller_buckled)
			do_buckle_bodybag(B, user)
			return TRUE
	else
		. = ..()

/obj/structure/bed/roller/Destroy()
	if(buckled_bodybag)
		unbuckle()
	. = ..()

/obj/structure/bed/roller/forceMove()
	. = ..()
	if(isturf(src.loc))
		if(buckled_bodybag)
			buckled_bodybag.set_glide_size(glide_size)
			buckled_bodybag.forceMove(loc)
	else
		unbuckle()


/obj/structure/bed/roller/Move()
	. = ..()
	if(buckled_bodybag)
		buckled_bodybag.set_glide_size(glide_size)
		buckled_bodybag.forceMove(loc)


/obj/structure/bed/roller/proc/do_buckle_bodybag(obj/structure/closet/body_bag/B, mob/user)
	if(isanimal(user))
		return FALSE
	if(!user.Adjacent(B) || user.incapacitated(INCAPACITATION_ALL) || istype(user, /mob/living/silicon/pai))
		return FALSE
	B.visible_message(SPAN_NOTICE("[user] buckles [B] to [src]!"))
	B.roller_buckled = src
	B.forceMove(loc)
	B.set_dir(dir)
	buckled_bodybag = B
	density = TRUE
	update_icon()
	if(buckling_y)
		buckled_bodybag.pixel_y = buckled_bodybag.buckle_offset + buckling_y
	add_fingerprint(user)
	register_signal(B, SIGNAL_MOVED, nameof(.proc/on_move))

/obj/structure/bed/roller/proc/on_move()
	if(buckled_bodybag)
		var/turf/body_bag_turf = get_turf(buckled_bodybag)
		var/turf/roller_turf = get_turf(src)
		if(body_bag_turf != roller_turf)
			if(body_bag_turf.z != roller_turf.z)
				src.forceMove(body_bag_turf)
				return
			step_glide(src, get_dir(roller_turf, body_bag_turf), glide_size)

/obj/structure/bed/roller/proc/unbuckle()
	if(buckled_bodybag)
		unregister_signal(buckled_bodybag, SIGNAL_MOVED)
		buckled_bodybag.glide_size = initial(buckled_bodybag.glide_size)
		buckled_bodybag.pixel_y = initial(buckled_bodybag.pixel_y)
		buckled_bodybag.roller_buckled = null
		buckled_bodybag = null
		density = FALSE
		update_icon()

/obj/structure/bed/roller/proc/manual_unbuckle(mob/user)
	if(isanimal(user) || istype(user, /mob/living/silicon/pai))
		return FALSE
	if(user.incapacitated(INCAPACITATION_ALL))
		return FALSE
	if(buckled_bodybag && !user.Adjacent(buckled_bodybag))
		return FALSE
	unbuckle()
	add_fingerprint(user)
	return TRUE

/obj/structure/bed/roller/buckle_mob(mob/living/M)
	if(buckled_bodybag)
		return 0
	. = ..()

/obj/structure/bed/roller/attack_hand(mob/user)
	manual_unbuckle(user)
	. = ..()
///
/// BETTER rolling bed huh
///

/obj/structure/bed/wheel
	name = "roller bed"
	desc = "Truly a racing bed."
	anchored = 0
	icon_state = "wheelbed"
	base_icon = "wheelbed"
	buckle_pixel_shift = "x=0;y=3"
	pull_slowdown = PULL_SLOWDOWN_LIGHT

/obj/structure/bed/wheel/padded/New(newloc)
	..(newloc, MATERIAL_PLASTIC, MATERIAL_COTTON)

/obj/structure/bed/wheel/luxury/New(newloc)
	..(newloc, MATERIAL_GOLD, MATERIAL_CARPET)
