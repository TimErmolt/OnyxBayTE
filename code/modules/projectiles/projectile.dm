//Amount of time in deciseconds to wait before deleting all drawn segments of a projectile.
#define SEGMENT_DELETION_DELAY 5
#define MUZZLE_EFFECT_PIXEL_INCREMENT 16

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	pass_flags = PASS_FLAG_TABLE
	mouse_opacity = 0

	check_armour = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid

	var/bumped = FALSE		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/silenced = 0	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/shot_from = "" // name of the object which shot us
	var/atom/original = null // the target clicked (not necessarily where the projectile is headed). Should probably be renamed to 'target' or something.
	var/turf/previous = null // the projectile's previous turf updated on each move
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/list/segments = list() //For hitscan projectiles with tracers.

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/accuracy = 0
	var/dispersion = 0.0
	var/blockable = TRUE

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE, PAIN are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/projectile_type = /obj/item/projectile
	var/penetrating = 0 //If greater than zero, the projectile will pass through dense objects as specified by on_penetrate()
	var/kill_count = 50 //This will de-increment every process(). When 0, it will delete the projectile.
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/embed = 0 // whether or not the projectile can embed itself in the mob
	var/penetration_modifier = 0.2 //How much internal damage this projectile can deal, as a multiplier.
	var/tasing = 0 //Whether or not it will stun the target once they reach the pain limit
	var/poisedamage = 0 //Kinda self-decriptive


	// effect types to be used
	var/muzzle_type
	var/tracer_type
	var/impact_type

	var/ricochet_id = 0
	var/can_ricochet = TRUE

	var/fire_sound

	var/vacuum_traversal = 1 //Determines if the projectile can exist in vacuum, if false, the projectile will be deleted if it enters vacuum.
	var/impact_on_original = FALSE // Allow player to shot at floor and do on_impact stuff
	//Movement parameters
	var/speed = 0.4		//Amount of deciseconds it takes for projectile to travel
	var/pixel_speed = 33	//pixels per move - DO NOT FUCK WITH THIS UNLESS YOU ABSOLUTELY KNOW WHAT YOU ARE DOING OR UNEXPECTED THINGS /WILL/ HAPPEN!
	var/Angle = 0
	var/original_Angle = 0		//Angle at firing
	var/nondirectional_sprite = FALSE //Set TRUE to prevent projectiles from having their sprites rotated based on firing Angle
	var/forcedodge = FALSE		//to pass through everything
	var/ignore_source_check = FALSE

	//Fired processing vars
	var/fired = FALSE	//Have we been fired yet
	var/paused = FALSE	//for suspending the projectile midair
	var/last_projectile_move = 0
	var/last_process = 0
	var/time_offset = 0
	var/datum/point/vector/trajectory
	var/trajectory_ignore_forcemove = FALSE	//instructs forceMove to NOT reset our trajectory to the new location!
	var/range = 50 //This will de-increment every step. When 0, it will deletze the projectile.

	//Hitscan
	var/hitscan = FALSE		//Whether this is hitscan. If it is, speed is basically ignored.
	var/list/beam_segments	//assoc list of datum/point or datum/point/vector, start = end. Used for hitscan effect generation.
	var/datum/point/beam_index
	var/turf/hitscan_last	//last turf touched during hitscanning.

	var/projectile_light = FALSE        // whether the projectile should emit light at all
	var/projectile_max_bright    = 1.0 // brightness of light, must be no greater than 1.
	var/projectile_inner_range   = 0.3 // inner range of light, can be negative
	var/projectile_outer_range   = 1.5 // outer range of light, can be negative
	var/projectile_falloff_curve = 6.0
	var/projectile_brightness_color = "#fff3b2"

/obj/item/projectile/Initialize()
	damtype = damage_type //TODO unify these vars properly
	if(hitscan)
		animate_movement = NO_STEPS // Some fucking clown's put this under the if below and we enjoyed twitching projectiles for good 3 years
	else
		animate_movement = SLIDE_STEPS

	if(config.misc.projectile_basketball)
		anchored = 0
		mouse_opacity = 1
	. = ..()

/obj/item/projectile/CanPass()
	return TRUE

/obj/item/projectile/Destroy()
	if(hitscan)
		if(loc && trajectory)
			var/datum/point/pcache = trajectory.copy_to()
			beam_segments[beam_index] = pcache
		generate_hitscan_tracers()
	firer = null
	current = null
	original = null
	previous = null
	starting = null
	if(trajectory)
		QDEL_NULL(trajectory)
	STOP_PROCESSING(SSprojectiles, src)
	return ..()

//TODO: make it so this is called more reliably, instead of sometimes by bullet_act() and sometimes not
/obj/item/projectile/proc/on_hit(atom/target, blocked = 0, def_zone = null)
	if(blocked >= 100)
		return 0 //Full block
	if(!isliving(target))
		return 0
	if(isanimal(target))
		return 0

	var/mob/living/L = target

	L.apply_effects(0, weaken, paralyze, 0, stutter, eyeblur, drowsy, 0, blocked)
	if(ishuman(L) && tasing)
		var/mob/living/carbon/human/H = L
		spawn()
			H.handle_tasing(agony, tasing, def_zone, src)
	else
		L.stun_effect_act(stun, agony, def_zone, src)
	return 1

//called when the projectile stops flying because it collided with something
/obj/item/projectile/proc/on_impact(atom/A, use_impact = TRUE)
	if(damage && damage_type == BURN)
		var/turf/T = get_turf(A)
		if(T)
			T.hotspot_expose(700, 5)

//Checks if the projectile is eligible for embedding. Not that it necessarily will.
/obj/item/projectile/proc/can_embed()
	//embed must be enabled and damage type must be brute
	if(!embed || damage_type != BRUTE)
		return 0
	return 1

/obj/item/projectile/proc/get_structure_damage()
	if(damage_type == BRUTE || damage_type == BURN)
		return damage
	return 0

//return 1 if the projectile should be allowed to pass through after all, 0 if not.
/obj/item/projectile/proc/check_penetrate(atom/A)
	return 1

/obj/item/projectile/proc/launch(atom/target, target_zone, mob/user, params, obj/item/gun/launcher, Angle_override, forced_spread = 0)
	original = target
	previous = get_turf(loc)
	def_zone = check_zone(target_zone)
	firer = user
	var/direct_target
	if(get_turf(target) == get_turf(src))
		direct_target = target
	preparePixelProjectile(target, user? user : get_turf(src), params, forced_spread)
	return fire(Angle_override, direct_target)

//sets the click point of the projectile using mouse input params
/obj/item/projectile/proc/set_clickpoint(params)
	var/list/mouse_control = params2list(params)
	if(mouse_control["icon-x"])
		p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		p_y = text2num(mouse_control["icon-y"])

	//randomize clickpoint a bit based on dispersion
	if(dispersion)
		var/radius = round((dispersion*0.443)*world.icon_size*0.8) //0.443 = sqrt(pi)/4 = 2a, where a is the side length of a square that shares the same area as a circle with diameter = dispersion
		p_x = between(0, p_x + rand(-radius, radius), world.icon_size)
		p_y = between(0, p_y + rand(-radius, radius), world.icon_size)

//Used to change the direction of the projectile in flight.
/obj/item/projectile/proc/redirect(new_x, new_y, atom/starting_loc, mob/new_firer=null, is_ricochet = FALSE)
	var/turf/starting_turf = get_turf(src)
	var/turf/new_target = locate(new_x, new_y, src.z)

	original = new_target
	if(new_firer)
		firer = new_firer
	var/new_Angle = Atan2(starting_turf, new_target)
	if(is_ricochet) // Add some dispersion.
		new_Angle += (rand(-5,5) * 5)
	setAngle(new_Angle)

//Called when the projectile intercepts a mob. Returns 1 if the projectile hit the mob, 0 if it missed and should keep flying.
/obj/item/projectile/proc/attack_mob(mob/living/target_mob, distance, miss_modifier=0)
	if(!istype(target_mob))
		return

	//roll to-hit
	miss_modifier = max(15*(distance-2) - round(15*accuracy) + miss_modifier + target_mob.get_evasion(), 0)
	var/hit_zone = get_zone_with_miss_chance(def_zone, target_mob, miss_modifier, ranged_attack=(distance > 1 || original != target_mob)) //if the projectile hits a target we weren't originally aiming at then retain the chance to miss

	var/result = PROJECTILE_FORCE_MISS
	if(hit_zone)
		def_zone = hit_zone //set def_zone, so if the projectile ends up hitting someone else later (to be implemented), it is more likely to hit the same part
		if(!target_mob.aura_check(AURA_TYPE_BULLET, src,def_zone))
			return 1
		result = target_mob.bullet_act(src, def_zone)

	if(result == PROJECTILE_FORCE_MISS)
		if(!silenced)
			target_mob.visible_message("<span class='notice'>\The [src] misses [target_mob] narrowly!</span>")
		return 0

	//sometimes bullet_act() will want the projectile to continue flying
	if(result == PROJECTILE_CONTINUE)
		return 0

	if(result == PROJECTILE_FORCE_BLOCK)
		if(!no_attack_log)
			if(istype(firer, /mob))
				var/attacker_message = "shot with \a [src.type] (blocked)"
				var/victim_message = "shot with \a [src.type] (blocked)"
				var/admin_message = "shot (\a [src.type], blocked)"
				admin_attack_log(firer, target_mob, attacker_message, victim_message, admin_message)
			else
				admin_victim_log(target_mob, "was shot by an <b>UNKNOWN SUBJECT (No longer exists)</b> using \a [src] (blocked)")
		return 1

	var/impacted_organ = parse_zone(def_zone)
	if(istype(target_mob, /mob/living/simple_animal))
		var/mob/living/simple_animal/SM = target_mob
		var/decl/simple_animal_bodyparts/body_plan = SM.bodyparts
		if(body_plan != decls_repository.get_decl(/decl/simple_animal_bodyparts/humanoid)) // No need to override
			if(length(body_plan.hit_zones))
				impacted_organ = pick(body_plan.hit_zones)
			else
				impacted_organ = null

	//hit messages
	if(silenced)
		if(impacted_organ)
			to_chat(target_mob, SPAN("danger", "You've been hit in the [impacted_organ] by \the [src]!"))
		else
			to_chat(target_mob, SPAN("danger", "You've been hit by \the [src]!"))
	else
		if(impacted_organ)
			target_mob.visible_message(SPAN("danger", "\The [target_mob] is hit by \the [src] in the [impacted_organ]!"))//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
		else
			target_mob.visible_message(SPAN("danger", "\The [target_mob] is hit by \the [src]!"))

		new /obj/effect/effect/hitmarker(target_mob.loc)
		for(var/mob/O in hearers(7, get_turf(target_mob)))
			if(O.client)
				if(O.get_preference_value(/datum/client_preference/play_hitmarker) == GLOB.PREF_YES)
					O.playsound_local(target_mob, 'sound/effects/weapons/misc/hitmarker.ogg', 50, 1)

	//admin logs
	if(!no_attack_log)
		if(istype(firer, /mob))

			var/attacker_message = "shot with \a [src.type]"
			var/victim_message = "shot with \a [src.type]"
			var/admin_message = "shot (\a [src.type])"

			admin_attack_log(firer, target_mob, attacker_message, victim_message, admin_message)
		else
			admin_victim_log(target_mob, "was shot by an <b>UNKNOWN SUBJECT (No longer exists)</b> using \a [src]")

	return 1

/obj/item/projectile/Bump(atom/A, forced = FALSE)
	if(A == src)
		return FALSE //no

	if(A == firer)
		loc = A.loc
		return FALSE //cannot shoot yourself

	if((bumped && !forced) || (A in permutated))
		return FALSE

	if(istype(A, /obj/effect/portal))
		var/obj/effect/portal/P = A
		if(P.on_projectile_impact(src, FALSE))
			bumped = FALSE // reset bumped variable!
			permutated.Add(P)
			return

	var/passthrough = FALSE //if the projectile should continue flying
	var/distance = get_dist(starting,loc)

	bumped = TRUE
	if(ismob(A))
		var/mob/M = A
		if(istype(A, /mob/living))
			//if they have a neck grab on someone, that person gets hit instead
			var/obj/item/grab/G = locate() in M
			if(G && G.shield_assailant())
				visible_message("<span class='danger'>\The [M] uses [G.affecting] as a shield!</span>")
				if(Bump(G.affecting, forced=1))
					return //If Bump() returns 0 (keep going) then we continue on to attack M.

			passthrough = !attack_mob(M, distance)
		else
			passthrough = TRUE //so ghosts don't stop bullets
	else
		passthrough = (A.bullet_act(src, def_zone) == PROJECTILE_CONTINUE) //backwards compatibility
		if(isturf(A))
			for(var/obj/O in A)
				O.bullet_act(src)
			for(var/mob/living/M in A)
				attack_mob(M, distance)

	//penetrating projectiles can pass through things that otherwise would not let them
	if(!passthrough && penetrating > 0)
		if(check_penetrate(A))
			passthrough = TRUE
		penetrating--

	//the bullet passes through a dense object!
	if(passthrough)
		//move ourselves onto A so we can continue on our way.
		if(A)
			if(istype(A, /turf))
				loc = A
			else
				loc = A.loc
			permutated.Add(A)
		bumped = FALSE //reset bumped variable!
		return FALSE

	//stop flying
	on_impact(A)

	set_density(0)
	set_invisibility(101)

	qdel(src)
	return 1

/obj/item/projectile/ex_act()
	return //explosions probably shouldn't delete projectiles

/obj/item/projectile/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/obj/item/projectile/proc/before_move()
	previous = loc
	return

/obj/item/projectile/proc/after_move()
	if(hitscan && tracer_type && !(locate(/obj/effect/projectile) in loc))
		var/obj/effect/projectile/invislight/light = new
		light.forceMove(loc)
		light.copy_from(tracer_type)
		QDEL_IN(light, 3)


//Helper proc to check if you can hit them or not.
/proc/check_trajectory(atom/target as mob|obj, atom/firer as mob|obj, pass_flags=PASS_FLAG_TABLE|PASS_FLAG_GLASS|PASS_FLAG_GRILLE)
	if(!istype(target) || !istype(firer))
		return 0

	var/obj/item/projectile/test/trace = new /obj/item/projectile/test(get_turf(firer)) //Making the test....

	//Set the flags and pass flags to that of the real projectile...
	trace.pass_flags = pass_flags

	return trace.launch(target) //Test it!

//"Tracing" projectile
/obj/item/projectile/test //Used to see if you can hit them.
	invisibility = 101
	hitscan = TRUE
	nodamage = TRUE
	damage = 0
	var/list/hit = list()

/obj/item/projectile/test/process_hitscan()
	. = ..()
	if(!QDELING(src))
		qdel(src)
	return hit

/obj/item/projectile/test/Bump(atom/A, forced = FALSE)
	if(A != src)
		hit |= A
	return ..()

/obj/item/projectile/test/attack_mob()
	return

/obj/item/projectile/proc/old_style_target(atom/target, atom/source)
	if(!source)
		source = get_turf(src)
	setAngle(get_projectile_angle(source, target))

/obj/item/projectile/proc/fire(angle, atom/direct_target)
	//If no Angle needs to resolve it from xo/yo!
	if(direct_target)
		direct_target.bullet_act(src, def_zone)
		on_impact(direct_target)
		qdel(src)
		return
	if(isnum(Angle))
		setAngle(Angle)
	// trajectory dispersion
	var/turf/starting = get_turf(src)
	if(!starting)
		return
	if(isnull(Angle))	//Try to resolve through offsets if there's no Angle set.
		if(isnull(xo) || isnull(yo))
			util_crash_with("WARNING: Projectile [type] deleted due to being unable to resolve a target after Angle was null!")
			qdel(src)
			return
		var/turf/target = locate(Clamp(starting + xo, 1, world.maxx), Clamp(starting + yo, 1, world.maxy), starting.z)
		setAngle(get_projectile_angle(src, target))
	if(dispersion)
		var/DeviationAngle = (dispersion * 15)
		setAngle(Angle + rand(-DeviationAngle, DeviationAngle))
	original_Angle = Angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	trajectory = new(starting.x, starting.y, starting.z, 0, 0, Angle, pixel_speed)
	last_projectile_move = world.time
	fired = TRUE
	if(hitscan)
		return process_hitscan()

	if(muzzle_type)
		var/atom/movable/thing = new muzzle_type
		update_effect(thing)
		thing.forceMove(starting)
		thing.pixel_x = trajectory.return_px() + (trajectory.mpx * 0.5)
		thing.pixel_y = trajectory.return_py() + (trajectory.mpy * 0.5)
		var/matrix/M = new
		M.Turn(Angle)
		thing.transform = M
		QDEL_IN(thing, 3)

	if(!is_processing)
		START_PROCESSING(SSprojectiles, src)
	pixel_move(1)	//move it now!

/obj/item/projectile/proc/preparePixelProjectile(atom/target, atom/source, params, Angle_offset = 0)
	var/turf/curloc = get_turf(source)
	var/turf/targloc = get_turf(target)
	forceMove(curloc)
	starting = curloc
	original = target

	var/list/calculated = list(null,null,null)
	if(isliving(source) && params)
		calculated = calculate_projectile_Angle_and_pixel_offsets(source, target, params2list(params))
		p_x = calculated[2]
		p_y = calculated[3]
		setAngle(calculated[1])

	else if(targloc && curloc)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		setAngle(get_projectile_angle(src, targloc))
	else
		util_crash_with("WARNING: Projectile [type] fired without either mouse parameters, or a target atom to aim at!")
		qdel(src)
	if(Angle_offset)
		setAngle(Angle + Angle_offset)

/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	..()
	if(isliving(AM) && (AM.density || AM == original) && !(pass_flags & PASS_FLAG_MOB))
		Bump(AM)

/obj/item/projectile/proc/pixel_move(moves, trajectory_multiplier = 1, hitscanning = FALSE)
	if(!loc || !trajectory)
		if(!QDELETED(src))
			if(loc)
				on_impact(loc)
			qdel(src)
		return

	if (QDELETED(src))
		return

	last_projectile_move = world.time
	if(!nondirectional_sprite && !hitscanning)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	trajectory.increment(trajectory_multiplier)
	var/datum/point/vector/_trajectory = trajectory
	var/turf/T = trajectory.return_turf()

	if (!T) // Nowhere to go. Just die.
		qdel(src)
		return

	if(T.z != loc.z)
		before_move()
		before_z_change(loc, T)
		trajectory_ignore_forcemove = TRUE
		forceMove(T)
		trajectory_ignore_forcemove = FALSE
		after_move()
		if(!hitscanning)
			pixel_x = _trajectory.return_px()
			pixel_y = _trajectory.return_py()
	else
		if(T != loc)
			before_move()
			Move(T)
			after_move()
		if(!hitscanning)
			pixel_x = _trajectory.return_px() - _trajectory.mpx * trajectory_multiplier
			pixel_y = _trajectory.return_py() - _trajectory.mpy * trajectory_multiplier
	if(!hitscanning)
		animate(src, pixel_x = _trajectory.return_px(), pixel_y = _trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	if(isturf(loc))
		hitscan_last = loc
	if(can_hit_target(original, permutated))
		Bump(original, TRUE)
	check_distance_left()

//Returns true if the target atom is on our current turf and above the right layer
/obj/item/projectile/proc/can_hit_target(atom/target, list/passthrough)
	return (target && ((target.layer >= TURF_LAYER + 0.3) || ismob(target)) && (loc == get_turf(target)) && (!(target in passthrough)))

/proc/calculate_projectile_Angle_and_pixel_offsets(atom/source, atom/target, modifiers)
	var/angle = 0
	var/p_x = modifiers["icon-x"] ? text2num(modifiers["icon-x"]) : world.icon_size / 2 // ICON_(X|Y) are measured from the bottom left corner of the icon.
	var/p_y = modifiers["icon-y"] ? text2num(modifiers["icon-y"]) : world.icon_size / 2 // This centers the target if modifiers aren't passed.

	if(target)
		var/turf/source_loc = get_turf(source)
		var/turf/target_loc = get_turf(target)
		var/dx = ((target_loc.x - source_loc.x) * world.icon_size) + (target.pixel_x - source.pixel_x) + (p_x - (world.icon_size / 2))
		var/dy = ((target_loc.y - source_loc.y) * world.icon_size) + (target.pixel_y - source.pixel_y) + (p_y - (world.icon_size / 2))

		angle = Atan2(dy, dx)
		return list(angle, p_x, p_y)

	if(!ismob(source) || !modifiers["screen-loc"])
		CRASH("Can't make trajectory calculations without a target or click modifiers and a client.")

	var/mob/user = source
	if(!user.client)
		CRASH("Can't make trajectory calculations without a target or click modifiers and a client.")

	//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
	var/list/screen_loc_params = splittext(modifiers["screen-loc"], ",")
	//Split X+Pixel_X up into list(X, Pixel_X)
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	//Split Y+Pixel_Y up into list(Y, Pixel_Y)
	var/list/screen_loc_Y = splittext(screen_loc_params[2],":")

	var/tx = (text2num(screen_loc_X[1]) - 1) * world.icon_size + text2num(screen_loc_X[2])
	var/ty = (text2num(screen_loc_Y[1]) - 1) * world.icon_size + text2num(screen_loc_Y[2])

	//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
	if(!user.client.view)
		return list(0, 0)
	var/list/screenview = getviewsize(user.client.view)
	screenview[1] *= world.icon_size
	screenview[2] *= world.icon_size

	var/ox = round(screenview[1] / 2) - user.client.pixel_x //"origin" x
	var/oy = round(screenview[2] / 2) - user.client.pixel_y //"origin" y
	angle = Atan2(tx - oy, ty - ox)
	return list(angle, p_x, p_y)

/obj/item/projectile/proc/check_distance_left()
	range--
	if(range <= 0 && loc)
		end_distance()

/obj/item/projectile/proc/end_distance() //if we want there to be effects when they reach the end of their range
	on_impact(loc)
	qdel(src)

/obj/item/projectile/proc/store_hitscan_collision(datum/point/pcache)
	beam_segments[beam_index] = pcache
	beam_index = pcache
	beam_segments[beam_index] = null

/obj/item/projectile/proc/return_predicted_turf_after_moves(moves, forced_Angle)		//I say predicted because there's no telling that the projectile won't change direction/location in flight.
	if(!trajectory && isnull(forced_Angle) && isnull(Angle))
		return FALSE
	var/datum/point/vector/current = trajectory
	if(!current)
		var/turf/T = get_turf(src)
		current = new(T.x, T.y, T.z, pixel_x, pixel_y, isnull(forced_Angle)? Angle : forced_Angle, pixel_speed)
	var/datum/point/vector/v = current.return_vector_after_increments(moves)
	return v.return_turf()

/obj/item/projectile/proc/return_pathing_turfs_in_moves(moves, forced_Angle)
	var/turf/current = get_turf(src)
	var/turf/ending = return_predicted_turf_after_moves(moves, forced_Angle)
	return getline(current, ending)

/obj/item/projectile/proc/process_hitscan()
	set waitfor = FALSE
	var/safety = range * 3
	var/return_vector = RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1)
	record_hitscan_start(return_vector)
	while(loc && !QDELETED(src))
		if(paused)
			stoplag(1)
			continue
		safety--
		if(safety <= 0)
			qdel(src)
			util_crash_with("WARNING: [type] projectile encountered infinite recursion during hitscanning!")
			return	//Kill!
		pixel_move(1, 1, TRUE)

/obj/item/projectile/proc/record_hitscan_start(datum/point/pcache)
	beam_segments = list()	//initialize segment list with the list for the first segment
	beam_index = pcache
	beam_segments[beam_index] = null	//record start.

/obj/item/projectile/proc/vol_by_damage()
	if(src.damage)
		return Clamp((src.damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then CLAMP the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume.

/obj/item/projectile/proc/before_z_change(turf/oldloc, turf/newloc)
	var/datum/point/pcache = trajectory.copy_to()
	if(hitscan)
		store_hitscan_collision(pcache)

/obj/item/projectile/Process()
	last_process = world.time
	if(!loc || !fired || !trajectory)
		fired = FALSE
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move += world.time - last_process		//Compensates for pausing, so it doesn't become a hitscan projectile when unpaused from charged up ticks.
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = 0
	if(speed > 0)
		required_moves = Floor(elapsed_time_deciseconds / speed, 1)
		if(required_moves > SSprojectiles.global_max_tick_moves)
			var/overrun = required_moves - SSprojectiles.global_max_tick_moves
			required_moves = SSprojectiles.global_max_tick_moves
			time_offset += overrun * speed
		time_offset += MODULUS_FLOAT(elapsed_time_deciseconds, speed)
	else
		required_moves = SSprojectiles.global_max_tick_moves
	if(!required_moves)
		return
	for(var/i in 1 to required_moves)
		pixel_move(required_moves)

/obj/item/projectile/proc/setAngle(new_Angle)	//wrapper for overrides.
	Angle = new_Angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(trajectory)
		trajectory.set_angle(new_Angle)
	return TRUE

/obj/item/projectile/forceMove(atom/target)
	. = ..()
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)

/obj/item/projectile/proc/generate_hitscan_tracers(cleanup = TRUE, duration = 3)
	if(!length(beam_segments))
		return
	if(duration <= 0)
		return
	if(tracer_type)
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(src, p, beam_segments[p], tracer_type, color, duration)
	if(muzzle_type && !silenced)
		var/datum/point/p = beam_segments[1]
		var/atom/movable/thing = new muzzle_type
		update_effect(thing)
		p.move_atom_to_src(thing)
		var/matrix/M = new
		M.Turn(original_Angle)
		thing.transform = M
		QDEL_IN(thing, duration)
	if(impact_type)
		var/datum/point/p = beam_segments[beam_segments[beam_segments.len]]
		var/atom/movable/thing = new impact_type
		update_effect(thing)
		p.move_atom_to_src(thing)
		var/matrix/M = new
		M.Turn(Angle)
		thing.transform = M
		QDEL_IN(thing, duration)
	if(cleanup)
		for(var/i in beam_segments)
			qdel(i)
		beam_segments = null
		QDEL_NULL(beam_index)

/obj/item/projectile/proc/update_effect(obj/effect/projectile/effect)
	return
