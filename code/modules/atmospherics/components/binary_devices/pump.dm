/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/binary/pump
	icon = 'icons/atmos/pump.dmi'
	icon_state = "map_off"
	level = 1

	name = "gas pump"
	desc = "A pump."

	var/target_pressure = ONE_ATMOSPHERE

	//var/max_volume_transfer = 10000

	use_power = POWER_USE_OFF
	idle_power_usage = 150 WATTS		//internal circuitry, friction losses and stuff
	power_rating = 7.500 KILO WATTS		//7500 W ~ 10 HP

	var/max_pressure_setting = MAX_PUMP_PRESSURE

	var/frequency = 0
	var/id = null
	var/datum/frequency/radio_connection

/obj/machinery/atmospherics/binary/pump/Initialize()
	. = ..()
	air1.volume = ATMOS_DEFAULT_VOLUME_PUMP
	air2.volume = ATMOS_DEFAULT_VOLUME_PUMP

/obj/machinery/atmospherics/binary/pump/Initialize()
	if(frequency)
		set_frequency(frequency)
	return ..()

/obj/machinery/atmospherics/binary/pump/AltClick(mob/user)
	if(user.is_ic_dead() || user.restrained())
		return

	if(!Adjacent(user, src) && !issilicon(user))
		return

	if(!allowed(user))
		return

	show_splash_text(user, "toggled [use_power ? "off" : "on"]")
	update_use_power(!use_power)
	update_icon()

/obj/machinery/atmospherics/binary/pump/AltRightClick(mob/user)
	if(user.is_ic_dead() || user.restrained())
		return

	if(!Adjacent(user, src) && !issilicon(user))
		return

	if(!allowed(user))
		return

	target_pressure = max_pressure_setting
	show_splash_text(user, "target pressure set to [target_pressure] kPa")

/obj/machinery/atmospherics/binary/pump/on
	icon_state = "map_on"
	use_power = POWER_USE_IDLE


/obj/machinery/atmospherics/binary/pump/on_update_icon()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[use_power ? "on" : "off"]"

/obj/machinery/atmospherics/binary/pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/pump/hide(i)
	update_underlays()

/obj/machinery/atmospherics/binary/pump/Process()
	last_power_draw = 0
	last_flow_rate = 0

	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return

	var/power_draw = -1
	var/pressure_delta = target_pressure - air2.return_pressure()

	if(pressure_delta > 0.01 && air1.temperature > 0)
		//Figure out how much gas to transfer to meet the target pressure.
		var/transfer_moles = calculate_transfer_moles(air1, air2, pressure_delta, (network2)? network2.volume : 0)
		power_draw = pump_gas(src, air1, air2, transfer_moles, power_rating)

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power_oneoff(power_draw)

		if(network1)
			network1.update = 1

		if(network2)
			network2.update = 1

	return 1

//Radio remote control

/obj/machinery/atmospherics/binary/pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/list/data = list(
		"tag" = id,
		"device" = "AGP",
		"power" = use_power,
		"target_output" = target_pressure,
		"sigtype" = "status"
	)

	var/datum/signal/signal = new(data)
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/binary/pump/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(stat & (BROKEN|NOPOWER))
		return

	// this is the data which will be sent to the ui
	var/data[0]

	data = list(
		"on" = use_power,
		"pressure_set" = round(target_pressure*100),	//Nano UI can't handle rounded non-integers, apparently.
		"max_pressure" = max_pressure_setting,
		"last_flow_rate" = round(last_flow_rate*10),
		"last_power_draw" = round(last_power_draw),
		"max_power_draw" = power_rating,
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "gas_pump.tmpl", name, 470, 290)
		ui.set_initial_data(data)	// when the ui is first opened this is the data it will use
		ui.open()					// open the new ui window
		ui.set_auto_update(1)		// auto update every Master Controller tick

/obj/machinery/atmospherics/binary/pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return 0

	if(signal.data["power"])
		if(text2num(signal.data["power"]))
			update_use_power(POWER_USE_IDLE)
		else
			update_use_power(POWER_USE_OFF)

	if("power_toggle" in signal.data)
		update_use_power(!use_power)

	if(signal.data["set_output_pressure"])
		target_pressure = between(
			0,
			text2num(signal.data["set_output_pressure"]),
			ONE_ATMOSPHERE*50
		)

	if(signal.data["status"])
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/binary/pump/attack_hand(mob/user)
	if(..())
		return
	src.add_fingerprint(user)
	if(!src.allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		return
	user.set_machine(src)
	ui_interact(user)
	return

/obj/machinery/atmospherics/binary/pump/Topic(href, href_list)
	if((. = ..())) return

	if(href_list["power"])
		update_use_power(!use_power)
		. = 1

	switch(href_list["set_press"])
		if ("min")
			target_pressure = 0
			. = 1
		if ("max")
			target_pressure = max_pressure_setting
			. = 1
		if ("set")
			var/new_pressure = input(usr,"Enter new output pressure (0-[max_pressure_setting]kPa)","Pressure control",src.target_pressure) as num
			src.target_pressure = between(0, new_pressure, max_pressure_setting)
			. = 1

	if(.)
		src.update_icon()

/obj/machinery/atmospherics/binary/pump/attackby(obj/item/W, mob/user)
	if(!isWrench(W))
		return ..()
	if (!(stat & NOPOWER) && use_power)
		to_chat(user, SPAN_WARNING("You cannot unwrench this [src], turn it off first."))
		return 1
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		to_chat(user, SPAN_WARNING("You cannot unwrench this [src], it too exerted due to internal pressure."))
		add_fingerprint(user)
		return 1
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	to_chat(user, SPAN_NOTICE("You begin to unfasten \the [src]..."))
	if (do_after(user, 40, src))
		user.visible_message( \
			SPAN_NOTICE("\The [user] unfastens \the [src]."), \
			SPAN_NOTICE("You have unfastened \the [src]."), \
			"You hear ratchet.")
		new /obj/item/pipe(loc, make_from=src)
		qdel(src)
