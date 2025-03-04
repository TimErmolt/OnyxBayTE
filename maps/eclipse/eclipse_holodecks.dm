
/datum/map/eclipse

	holodeck_programs = list(
		"emptycourt"       = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_emptycourt, list('sound/music/THUNDERDOME.ogg')),
		"boxingcourt"      = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_boxingcourt, list('sound/music/THUNDERDOME.ogg')),
		"basketball"       = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_basketball, list('sound/music/THUNDERDOME.ogg')),
		"thunderdomecourt" = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_thunderdomecourt, list('sound/music/THUNDERDOME.ogg')),
		"beach"            = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_beach),
		"desert"           = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_desert,
														list(
															'sound/effects/wind/wind_2_1.ogg',
											 				'sound/effects/wind/wind_2_2.ogg',
											 				'sound/effects/wind/wind_3_1.ogg',
											 				'sound/effects/wind/wind_4_1.ogg',
											 				'sound/effects/wind/wind_4_2.ogg',
											 				'sound/effects/wind/wind_5_1.ogg'
												 			)
		 												),
		"snowfield"        = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_snowfield,
														list(
															'sound/effects/wind/wind_2_1.ogg',
											 				'sound/effects/wind/wind_2_2.ogg',
											 				'sound/effects/wind/wind_3_1.ogg',
											 				'sound/effects/wind/wind_4_1.ogg',
											 				'sound/effects/wind/wind_4_2.ogg',
											 				'sound/effects/wind/wind_5_1.ogg'
												 			)
		 												),
		"space"            = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_space,
														list(SFX_AMBIENT_SPACE)
														),
		"picnicarea"       = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_picnicarea, list('sound/music/classic/title2.ogg')),
		"theatre"          = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_theatre),
		"meetinghall"      = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_meetinghall),
		"courtroom"        = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_courtroom, list('sound/music/classic/traitor.ogg')),
		"wildlifecarp"     = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_wildlife, list()),
		"chess"            = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_chess, list()),
		"turnoff"          = new /datum/holodeck_program(/area/eclipse/civilian/dormitory/holodeck/source_plating, list())
	)

	holodeck_supported_programs = list(

		"EclipseMainPrograms" = list(
			"Empty Court"       = "emptycourt",
			"Basketball Court"  = "basketball",
			"Thunderdome Court" = "thunderdomecourt",
			"Boxing Ring"       = "boxingcourt",
			"Beach"             = "beach",
			"Desert"            = "desert",
			"Space"             = "space",
			"Picnic Area"       = "picnicarea",
			"Snow Field"        = "snowfield",
			"Theatre"           = "theatre",
			"Meeting Hall"      = "meetinghall",
			"Courtroom"         = "courtroom",
			"Chess Field"       = "chess"
		)

	)

	holodeck_restricted_programs = list(

		"EclipseMainPrograms" = list(
			"Wildlife Simulation" = "wildlifecarp"
		)

	)
