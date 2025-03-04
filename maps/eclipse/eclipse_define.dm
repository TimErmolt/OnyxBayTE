
/datum/map/eclipse
	name = "Eclipse"
	full_name = "NSS Eclipse"
	path = "eclipse"

	station_name  = "NSS Eclipse"
	station_short = "Eclipse"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "Nanotrasen"
	company_short = "NT"
	system_name   = "Pegasus"

	lobby_icon = 'maps/exodus/exodus_lobby.dmi'

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod1,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod2,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod3,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod5,
		/datum/shuttle/autodock/ferry/supply/drone,
		/datum/shuttle/autodock/ferry/research,
		/datum/shuttle/autodock/ferry/engie,
		/datum/shuttle/autodock/ferry/mining,
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/ferry/administration,
		/datum/shuttle/autodock/ferry/transport,
		/datum/shuttle/autodock/ferry/deathsquad,
		/datum/shuttle/autodock/multi/antag/rescue,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/multi/antag/merchant,
		/datum/shuttle/autodock/multi/antag/skipjack,
	)

	load_legacy_saves = TRUE

	map_levels = list(
		new /datum/space_level/eclipse_1,
		new /datum/space_level/eclipse_3,
		new /datum/space_level/eclipse_6,
		new /datum/space_level/null_space,
		new /datum/space_level/telecomms,
		new /datum/space_level/construction_site,
		new /datum/space_level/snow_asteroid,
		new /datum/space_level/derelict,
		new /datum/space_level/bearcat_1,
		new /datum/space_level/bearcat_2,
		new /datum/space_level/jungle_level,
		new /datum/space_level/old_restaurant,
		new /datum/space_level/sensor_array,
		new /datum/space_level/science_ship_1,
		new /datum/space_level/science_ship_2
	)

	evac_controller_type = /datum/evacuation_controller/shuttle

	station_networks = list(
		NETWORK_CIVILIAN_EAST,
		NETWORK_CIVILIAN_WEST,
		NETWORK_COMMAND,
		NETWORK_ENGINE,
		NETWORK_ENGINEERING,
		NETWORK_ENGINEERING_OUTPOST,
		NETWORK_EXODUS,
		NETWORK_MAINTENANCE,
		NETWORK_MEDICAL,
		NETWORK_MINE,
		NETWORK_RESEARCH,
		NETWORK_RESEARCH_OUTPOST,
		NETWORK_ROBOTS,
		NETWORK_PRISON,
		NETWORK_SECURITY,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		NETWORK_THUNDER,
		NETWORK_TELECOM,
		NETWORK_MASTER
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1,
		/area/shuttle/escape_pod2,
		/area/shuttle/escape_pod3,
		/area/shuttle/escape_pod5,
		/area/shuttle/transport/centcom,
		/area/shuttle/administration/,
		/area/shuttle/specops/centcom,
	)
