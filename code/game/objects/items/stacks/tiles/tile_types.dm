/* Diffrent misc types of tiles
 * Contains:
 *		Prototype
 *		Grass
 *		Wood
 *		Linoleum
 *		Carpet
 */

/obj/item/stack/tile
	name = "tile"
	singular_name = "tile"
	desc = "A non-descript floor tile."
	randpixel = 7
	w_class = ITEM_SIZE_NORMAL
	max_amount = 100
	icon = 'icons/obj/tiles.dmi'

	force = 1
	throwforce = 1
	throw_range = 20
	item_flags = 0
	obj_flags = 0
	var/image/stored_decals = null

	drop_sound = SFX_DROP_AXE
	pickup_sound = SFX_PICKUP_AXE

/*
 * Grass
 */
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses."
	icon_state = "tile_grass"
	origin_tech = list(TECH_BIO = 1)

	drop_sound = SFX_DROP_HERB
	pickup_sound = SFX_PICKUP_HERB

/*
 * Wood
 */
/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "An easy to fit wooden floor tile."
	icon_state = "tile-wood"

	drop_sound = SFX_DROP_WOODEN
	pickup_sound = SFX_PICKUP_WOODEN

/obj/item/stack/tile/wood/cyborg
	name = "wood floor tile synthesizer"
	desc = "A device that makes wood floor tiles."
	uses_charge = 1
	charge_costs = list(250)
	stacktype = /obj/item/stack/tile/wood
	build_type = /obj/item/stack/tile/wood

/obj/item/stack/tile/darkwood
	name = "darkwood floor tile"
	singular_name = "darkwood floor tile"
	desc = "An easy to fit darkwood floor tile."
	icon_state = "tile-darkwood"
	stacktype = /obj/item/stack/tile/darkwood
	build_type = /obj/item/stack/tile/darkwood

/obj/item/stack/tile/darkwood/fifty
	amount = 50

/obj/item/stack/tile/floor
	name = "steel floor tile"
	singular_name = "steel floor tile"
	desc = "Those could work as a pretty decent throwing weapon." //why?
	icon_state = "tile"
	force = 6.0
	matter = list(MATERIAL_STEEL = 937.5)
	throwforce = 10.5
	obj_flags = OBJ_FLAG_CONDUCTIBLE

/obj/item/stack/tile/floor/fifty
	amount = 50

/obj/item/stack/tile/floor_rough
	name = "steel rough floor tile"
	singular_name = "steel rough floor tile"
	icon_state = "tile_rough"

/obj/item/stack/tile/floor_rough/fifty
	amount = 50

/obj/item/stack/tile/floor_white
	name = "white floor tile"
	singular_name = "white floor tile"
	icon_state = "tile_white"
	matter = list(MATERIAL_PLASTIC = 937.5)

/obj/item/stack/tile/floor_white/fifty
	amount = 50

/obj/item/stack/tile/floor_white_rough
	name = "white rough floor tile"
	singular_name = "white rough floor tile"
	icon_state = "tile_white_rough"

/obj/item/stack/tile/floor_white_rough/fifty
	amount = 50

/obj/item/stack/tile/floor_dark
	name = "dark floor tile"
	singular_name = "dark floor tile"
	icon_state = "fr_tile"
	matter = list(MATERIAL_STEEL = 937.5)

/obj/item/stack/tile/floor_dark/fifty
	amount = 50

/obj/item/stack/tile/floor_dark_rough
	name = "dark rough floor tile"
	singular_name = "dark rough floor tile"
	icon_state = "fr_tile_rough"

/obj/item/stack/tile/floor_dark_rough/fifty
	amount = 50

/obj/item/stack/tile/floor_brown
	name = "brown floor tile"
	singular_name = "brown floor tile"
	icon_state = "tile_brown"
	matter = list(MATERIAL_PLASTIC = 937.5)

/obj/item/stack/tile/floor_brown/fifty
	amount = 50

/obj/item/stack/tile/floor_mono
	name = "steel mono tile"
	singular_name = "steel mono tile"
	icon_state = "tile_rough"
	matter = list(MATERIAL_STEEL = 937.5)

/obj/item/stack/tile/floor_mono/fifty
	amount = 50

/obj/item/stack/tile/floor_mono_dark
	name = "dark mono tile"
	singular_name = "dark mono tile"
	icon_state = "fr_tile_rough"
	matter = list(MATERIAL_STEEL = 937.5)

/obj/item/stack/tile/floor_mono_dark/fifty
	amount = 50

/obj/item/stack/tile/floor_mono_white
	name = "white mono tile"
	singular_name = "white mono tile"
	icon_state = "tile_white_rough"
	matter = list(MATERIAL_PLASTIC = 937.5)

/obj/item/stack/tile/floor_mono_white/fifty
	amount = 50

/obj/item/stack/tile/techfloor
	name = "tech floor tile"
	singular_name = "tech floor tile"
	icon_state = "tile_techfloor"
	matter = list(MATERIAL_PLASTEEL = 937.5)

/obj/item/stack/tile/techfloor/fifty
	amount = 50

/obj/item/stack/tile/techfloor/maint
	name = "tech maint tile"
	singular_name = "tech maint tile"
	icon_state = "tile_techmaint"

/obj/item/stack/tile/techfloor/maint/fifty
	amount = 50

/obj/item/stack/tile/techfloor/grid
	name = "tech grid tile"
	singular_name = "tech grid tile"
	icon_state = "tile_techgrid"

/obj/item/stack/tile/techfloor/grid/fifty
	amount = 50

/obj/item/stack/tile/techfloor/ridge
	name = "tech ridge tile"
	singular_name = "tech ridge tile"
	icon_state = "tile_techridge"

/obj/item/stack/tile/techfloor/ridge/fifty
	amount = 50

/obj/item/stack/tile/floor_freezer
	name = "freezer floor tile"
	singular_name = "freezer floor tile"
	icon_state = "tile_freezer"
	matter = list(MATERIAL_PLASTIC = 937.5)

/obj/item/stack/tile/floor_freezer/fifty
	amount = 50

/obj/item/stack/tile/floor/cyborg
	name = "floor tile synthesizer"
	desc = "A device that makes floor tiles."
	gender = NEUTER
	matter = null
	uses_charge = 1
	charge_costs = list(250)
	stacktype = /obj/item/stack/tile/floor
	build_type = /obj/item/stack/tile/floor

/obj/item/stack/tile/floor_rough/cyborg
	name = "rough floor tile synthesizer"
	desc = "A device that makes rough floor tiles."
	gender = NEUTER
	matter = null
	uses_charge = 1
	charge_costs = list(250)
	stacktype = /obj/item/stack/tile/floor_rough
	build_type = /obj/item/stack/tile/floor_rough

/obj/item/stack/tile/linoleum
	name = "linoleum"
	singular_name = "linoleum"
	desc = "A piece of linoleum. It is the same size as a normal floor tile!"
	icon_state = "tile-linoleum"

/obj/item/stack/tile/linoleum/fifty
	amount = 50

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "brown carpet"
	singular_name = "brown carpet"
	desc = "A piece of brown carpet."
	icon_state = "tile_carpetbrown"

/obj/item/stack/tile/carpet/fifty
	amount = 50

/obj/item/stack/tile/carpetblue
	name = "blue carpet"
	desc = "A piece of blue and gold carpet."
	singular_name = "blue carpet"
	icon_state = "tile_carpetblue"

/obj/item/stack/tile/carpetoldred
	name = "red carpet"
	desc = "A piece of red and gold carpet."
	singular_name = "red carpet"
	icon_state = "tile_brown"

/obj/item/stack/tile/carpetoldred/fifty
	amount = 50

/obj/item/stack/tile/carpetblue/fifty
	amount = 50

/obj/item/stack/tile/carpetblue2
	name = "pale blue carpet"
	desc = "A piece of blue and silver carpet."
	singular_name = "pale blue carpet"
	icon_state = "tile_carpetblue2"

/obj/item/stack/tile/carpetblue2/fifty
	amount = 50

/obj/item/stack/tile/carpetarcade
	name = "pale arcade carpet"
	desc = "A piece of blue and silver carpet."
	singular_name = "pale arcade carpet"
	icon_state = "tile_carpetblue2"

/obj/item/stack/tile/carpetarcade/fifty
	amount = 50

/obj/item/stack/tile/carpetpurple
	name = "purple carpet"
	desc = "A piece of purple carpet."
	singular_name = "purple carpet"
	icon_state = "tile_carpetpurple"

/obj/item/stack/tile/carpetpurple/fifty
	amount = 50

/obj/item/stack/tile/carpetgpurple
	name = "purple carpet"
	desc = "A piece of purple carpet."
	singular_name = "purple carpet"
	icon_state = "tile_carpetpurple"

/obj/item/stack/tile/carpetorange
	name = "orange carpet"
	desc = "A piece of orange carpet."
	singular_name = "orange carpet"
	icon_state = "tile_carpetorange"

/obj/item/stack/tile/carpetorange/fifty
	amount = 50

/obj/item/stack/tile/carpetgreen
	name = "green carpet"
	desc = "A piece of green carpet."
	singular_name = "green carpet"
	icon_state = "tile_carpetgreen"

/obj/item/stack/tile/carpetgreen/fifty
	amount = 50

/obj/item/stack/tile/carpetred
	name = "red carpet"
	desc = "A piece of red carpet."
	singular_name = "red carpet"
	icon_state = "tile_carpetred"

/obj/item/stack/tile/carpetred/fifty
	amount = 50
