/obj/machinery/shield_diffuser
	name = "shield diffuser"
	desc = "A small underfloor device specifically designed to disrupt energy barriers."
	description_info = "This device disrupts shields on directly adjacent tiles (in a + shaped pattern). They are commonly installed around exterior airlocks to prevent shields from blocking EVA access."
	icon = 'icons/obj/machines/shielding.dmi'
	icon_state = "fdiffuser_on"
	use_power = POWER_USE_ACTIVE
	idle_power_usage = 100 WATTS
	active_power_usage = 2 KILO WATTS
	anchored = 1
	density = 0
	level = 1
	var/alarm = 0
	var/enabled = 1

/obj/machinery/shield_diffuser/Process()
	if(alarm)
		alarm--
		if(!alarm)
			update_icon()
		return

	if(!enabled)
		return
	for(var/direction in GLOB.cardinal)
		var/turf/simulated/shielded_tile = get_step(get_turf(src), direction)
		for(var/obj/effect/shield/S in shielded_tile)
			qdel(S)

/obj/machinery/shield_diffuser/attackby(obj/item/O as obj, mob/user as mob)
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

/obj/machinery/shield_diffuser/on_update_icon()
	if(alarm)
		icon_state = "fdiffuser_emergency"
		return
	if((stat & (NOPOWER | BROKEN)) || !enabled)
		icon_state = "fdiffuser_off"
	else
		icon_state = "fdiffuser_on"

/obj/machinery/shield_diffuser/attack_hand()
	if(alarm)
		to_chat(usr, "You press an override button on \the [src], re-enabling it.")
		alarm = 0
		update_icon()
		return
	enabled = !enabled
	update_use_power(enabled + 1)
	update_icon()
	to_chat(usr, "You turn \the [src] [enabled ? "on" : "off"].")

/obj/machinery/shield_diffuser/proc/meteor_alarm(duration)
	if(!duration)
		return
	alarm = round(max(alarm, duration))
	update_icon()

/obj/machinery/shield_diffuser/_examine_text(mob/user)
	. = ..()
	. += "\nIt is [enabled ? "enabled" : "disabled"]."
	if(alarm)
		. += "\nA red LED labeled \"Proximity Alarm\" is blinking on the control panel."
