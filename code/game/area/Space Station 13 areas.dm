/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/



/area
	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1
	var/party = null
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	plane = DEFAULT_PLANE
	layer = BASE_AREA_LAYER
	luminosity = 0
	mouse_opacity = 0
	var/lightswitch = 1
	var/lighting_mode = ""
	var/list/enabled_lighting_modes = list()
	var/eject = null

	var/debug = 0
	var/requires_power = 1
	var/always_unpowered = 0	//this gets overriden to 1 for space in area/New()

	var/power_equip = 1 // Status
	var/power_light = 1
	var/power_environ = 1
	var/oneoff_equip   = 0 //Used once and cleared each tick.
	var/oneoff_light   = 0
	var/oneoff_environ = 0

	var/has_gravity = TRUE
	var/gravity_state = AREA_GRAVITY_NORMAL
	var/obj/machinery/power/apc/apc = null
	var/no_air = null
//	var/list/lights				// list of all lights on this area
	var/list/all_doors = null		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = 0
	/// Plays when an area has power.
	var/list/ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL)
	/// Plays when an area has no power.
	var/list/ambience_off = list(SFX_AMBIENT_OFF_GLOBAL)
	var/list/forced_ambience = null
	var/sound_env = STANDARD_STATION
	var/turf/base_turf //The base turf type of the area, which can be used to override the z-level's base turf
	var/holy = FALSE

/*-----------------------------------------------------------------------------*/

/////////
//SPACE//
/////////

/area/space
	name = "\improper Space"
	icon_state = "space"
	requires_power = 1
	always_unpowered = 1
	dynamic_lighting = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	has_gravity = 0
	area_flags = AREA_FLAG_EXTERNAL
	ambient_music_tags = list(MUSIC_TAG_SPACE)
	ambience_off = list(SFX_AMBIENT_SPACE)
	ambience_powered = list(SFX_AMBIENT_SPACE)

/area/space/on_update_icon()
	return

/area/space/atmosalert()
	return

/area/space/fire_alert()
	return

/area/space/fire_reset()
	return

/area/space/readyalert()
	return

/area/space/partyalert()
	return

//////////////////////
//AREAS USED BY CODE//
//////////////////////
/area/centcom
	name = "\improper Centcom"
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = 0

/area/centcom/holding
	name = "\improper Holding Facility"

/area/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	holy = TRUE

/area/centcom/specops
	name = "\improper Centcom Special Ops"

/area/hallway
	name = "hallway"

/area/hallway/Initialize()
	. = ..()
	GLOB.hallway += src

/area/medical
	ambience_powered = list(SFX_AMBIENT_SCIENCE)

/area/medical/virology
	name = "\improper Virology"
	icon_state = "virology"

/area/medical/virologyaccess
	name = "\improper Virology Access"
	icon_state = "virology"

/area/security/brig
	name = "\improper Security - Brig"
	icon_state = "brig"

/area/security/prison
	name = "\improper Security - Prison Wing"
	icon_state = "sec_prison"

/area/maintenance
	area_flags = AREA_FLAG_RAD_SHIELDED
	sound_env = TUNNEL_ENCLOSED
	turf_initializer = /decl/turf_initializer/maintenance
	ambience_off = list(SFX_AMBIENT_OFF_GLOBAL, SFX_AMBIENT_OFF_MAINTENANCE)
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_POWERED_MAINTENANCE)
	ambient_music_tags = list(MUSIC_TAG_MYSTIC)

/area/rnd
	ambience_powered = list(SFX_AMBIENT_POWERED_GLOBAL, SFX_AMBIENT_SCIENCE)

/area/rnd/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xeno_lab"

/area/rnd/xenobiology/dorm
	name = "\improper Xenobiology Lab Dormitories"
	icon_state = "xeno_lab_dorm"


/area/rnd/xenobiology/xenoflora
	name = "\improper Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/rnd/xenobiology/xenoflora_storage
	name = "\improper Xenoflora Storage"
	icon_state = "xeno_f_store"

/area/shuttle/escape/centcom
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/specops/centcom
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/mothership
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	icon_state = "shuttlered2"

/area/skipjack_station/start
	name = "\improper Skipjack"
	icon_state = "yellow"

/area/supply
	name = "Supply Shuttle"
	icon_state = "shuttle3"

/area/syndicate_mothership/elite_squad
	name = "\improper Syndicate Elite Squad"
	icon_state = "syndie-elite"
	area_flags = AREA_FLAG_NO_STATION

////////////
//SHUTTLES//
////////////
//shuttles only need starting area, movement is handled by landmarks
//All shuttles should now be under shuttle since we have smooth-wall code.

/area/shuttle
	requires_power = 0
	sound_env = SMALL_ENCLOSED
	area_flags = AREA_FLAG_NO_STATION

/*
* Special Areas
*/
/area/wizard_station
	name = "\improper Wizard's Den"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 0
	area_flags = AREA_FLAG_NO_STATION

/area/beach
	name = "Keelin's private beach"
	icon_state = "null"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0
	area_flags = AREA_FLAG_NO_STATION
	var/sound/mysound = null

/area/beach/New()
	..()
	var/sound/S = new /sound()
	mysound = S
	S.file = 'sound/ambient/shore.ogg'
	S.repeat = 1
	S.wait = 0
	S.channel = 123
	S.volume = 100
	S.priority = 255
	S.status = SOUND_UPDATE
	process()

/area/beach/Entered(atom/movable/Obj,atom/OldLoc)
	if(ismob(Obj))
		var/mob/M = Obj
		if(M.client)
			mysound.status = SOUND_UPDATE
			sound_to(M, mysound)

/area/beach/Exited(atom/movable/Obj)
	. = ..()
	if(ismob(Obj))
		var/mob/M = Obj
		if(M.client)
			mysound.status = SOUND_PAUSED | SOUND_UPDATE
			sound_to(M, mysound)

/area/beach/proc/process()
	set background = 1

	var/sound/S = null
	var/sound_delay = 0
	if(prob(25))
		S = sound(file=pick('sound/ambient/seag1.ogg','sound/ambient/seag2.ogg','sound/ambient/seag3.ogg'), volume=100)
		sound_delay = rand(0, 50)

	for(var/mob/living/carbon/human/H in src)
		if(H.client)
			mysound.status = SOUND_UPDATE
			if(S)
				spawn(sound_delay)
					sound_to(H, S)

	spawn(60) .()

/area/thunderfield
	name = "Thunderfield"
	icon_state = "yellow"
	luminosity = 1
	dynamic_lighting = 0
	requires_power = 0
	area_flags = AREA_FLAG_NO_STATION

//Abductors
/area/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = FALSE
	requires_power = 0
	dynamic_lighting = 0
	luminosity = 1
	area_flags = AREA_FLAG_NO_STATION
