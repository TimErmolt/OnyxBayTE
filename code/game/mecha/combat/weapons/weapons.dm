/datum/mecha_weapon
	var/name = "mecha weapon"
	var/weapon_cooldown = 0
	var/weapon_ready = 1
	var/energy_drain = 0
	var/obj/mecha/combat/chassis = null


/datum/mecha_weapon/New(mecha)
	if(!istype(mecha, /obj/mecha/combat))
		return
	src.chassis = mecha
	chassis.log_append_to_last("[src.name] initialized.")
	return

/datum/mecha_weapon/proc/destroy()
	spawn
		del src
	return


/datum/mecha_weapon/proc/get_weapon_info()
	return src.name


/datum/mecha_weapon/proc/fire_checks(target) //general checks.
	if(!target)
		return 0
	if(!chassis)
		return 0
	if(energy_drain && chassis.cell.charge < energy_drain)
		return 0
	if(!weapon_ready)
		return 0
	return 1

/datum/mecha_weapon/proc/fire(target)
	return fire_checks(target)



/datum/mecha_weapon/missile_rack
	name = "SRM-8 Missile Rack"
	var/missiles = 8
	var/missile_speed = 2
	var/missile_range = 30
	var/missile_energy_cost = 1000
	weapon_cooldown = 60

	fire(target)
		if(!fire_checks(target) || missiles <=0) return
		var/obj/item/missile/M = new /obj/item/missile(chassis.loc)
		M.primed = 1
		M.throw_at(target, missile_range, missile_speed)
		weapon_ready = 0
		missiles--
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].",1)
		return

	proc/rearm()
		if(missiles < initial(missiles))
			var/missiles_to_add = initial(missiles) - missiles
			while(chassis.cell.charge >= missile_energy_cost && missiles_to_add)
				missiles++
				missiles_to_add--
				chassis.cell.charge -= missile_energy_cost
		chassis.log_message("Rearmed [src.name].")
		return

	get_weapon_info()
		return "[src.name]\[[src.missiles]\][(src.missiles < initial(src.missiles))?" - <a href='?src=\ref[src];rearm=1'>Rearm</a>":null]"

	Topic(href, href_list)
		if (href_list["rearm"])
			src.rearm()
		return



/obj/item/missile
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	var/primed = null
	throwforce = 15

	throw_impact(atom/hit_atom)
		if(primed)
			explosion(hit_atom, 0, 0, 2, 4)
			del(src)
		else
			..()
		return

/datum/mecha_weapon/missile_rack/flashbang
	name = "SGL-6 Grenade Launcher"
	missiles = 6
	missile_speed = 1.5
	missile_energy_cost = 800
	weapon_cooldown = 60
	var/det_time = 20

	fire(target)
		if(!fire_checks(target) || missiles <=0) return
		var/obj/item/weapon/flashbang/F = new /obj/item/weapon/flashbang(chassis.loc)
		F.throw_at(target, missile_range, missile_speed)
		weapon_ready = 0
		missiles--
		spawn(det_time)
			F.prime()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return

/datum/mecha_weapon/laser
	weapon_cooldown = 10
	name = "CH-PS \"Immolator\" Laser"
	energy_drain = 30

	fire(target)
		if(!fire_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'Laser.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		weapon_ready = 0
		chassis.cell.use(energy_drain)
		spawn()
			A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return


/datum/mecha_weapon/pulse
	weapon_cooldown = 50
	name = "eZ-13 mk2 Heavy pulse rifle"
	energy_drain = 60
	var/num_penetrations = 2

	fire(target)
		if(!fire_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'marauder.ogg', 50, 1)
		var/obj/beam/a_laser/A = new /obj/beam/a_laser/pulse_laser(curloc)
		A.life = num_penetrations
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		weapon_ready = 0
		chassis.cell.use(energy_drain)
		spawn()
			A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return


/datum/mecha_weapon/taser
	weapon_cooldown = 10
	name = "PBT \"Pacifier\" Mounted Taser"
	energy_drain = 20
	weapon_cooldown = 7

	fire(target)
		if(!fire_checks(target)) return

		var/turf/curloc = chassis.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if (targloc == curloc)
			return

		playsound(chassis, 'Laser.ogg', 50, 1)
		var/obj/bullet/electrode/A = new /obj/bullet/electrode(curloc)
		A.current = curloc
		A.yo = targloc.y - curloc.y
		A.xo = targloc.x - curloc.x
		weapon_ready = 0
		chassis.cell.use(energy_drain)
		spawn()
			A.process()
		spawn(weapon_cooldown)
			weapon_ready = 1
		chassis.log_message("Fired from [src.name], targeting [target].")
		return




/*
/datum/mecha_weapon/scattershot
	name = "Scuttershot"
	var/missiles = 8
	var/missile_speed = 2
	var/missile_range = 30
	var/missile_energy_cost = 1000
	weapon_cooldown = 60

	fire(target)
		if(!..() || missiles <=0) return
		var/obj/item/missile/M = new /obj/item/missile(chassis.loc)
		M.primed = 1
		M.throw_at(target, missile_range, missile_speed)
		weapon_ready = 0
		missiles--
		spawn(weapon_cooldown)
			weapon_ready = 1
		return

	proc/rearm()
		if(missiles < initial(missiles))
			var/missiles_to_add = initial(missiles) - missiles
			while(chassis.cell.charge >= missile_energy_cost && missiles_to_add)
				missiles++
				missiles_to_add--
				chassis.cell.charge -= missile_energy_cost
		return
*/
