#define ARTYDEBUG
/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////
/obj/effect/effect/smoke/chem
	icon = 'icons/effects/chemsmoke.dmi'
	opacity = FALSE
	layer = 6
	time_to_live = 300
	pass_flags = PASSTABLE | PASSGRILLE | PASSGLASS //PASSGLASS is fine here, it's just so the visual effect can "flow" around glass
	var/splash_amount = 10 //atoms moving through a smoke cloud get splashed with up to 10 units of reagent
	var/turf/destination
	var/reagent_id = null
	var/last_duration = -1
	var/random_destination = FALSE
	var/maxspread = 10
	var/passes_walls = FALSE
	var/dontmove = FALSE

/obj/effect/effect/smoke/chem/New(var/newloc, smoke_duration, turf/dest_turf = null, icon/cached_icon = null, var/spread = 7)

	maxspread = spread

	time_to_live = smoke_duration

	if (last_duration != -1)

		time_to_live = last_duration

	..()

	create_reagents(500)

	if (reagent_id)
		reagents.add_reagent(reagent_id, 500)

	if (cached_icon)
		icon = cached_icon

	set_dir(pick(cardinal))
	pixel_x = -32 + rand(-8, 8)
	pixel_y = -32 + rand(-8, 8)

	//switching opacity on after the smoke has spawned, and then turning it off before it is deleted results in cleaner
	//lighting and view range updates (Is this still true with the new lighting system?)

	opacity = TRUE

	//float over to our destination, if we have one
	destination = dest_turf

	var/possible_tiles = FALSE

	for (var/v in 1 to maxspread)
		possible_tiles += (8 * v)

	if (maxspread == 1)
		possible_tiles = 8

	if (!destination && random_destination)
		for (var/turf/t in orange(maxspread,src))
			var/abs_dist = abs(t.x - x) + abs(t.y - y)
			var/_prob = ceil(100/possible_tiles)
			if (abs_dist > 75)
				_prob = ceil(100/possible_tiles) * 2
			if (prob(_prob))
				destination = t

	spawn (1)

		if (destination && !dontmove)

			walk_to(src,destination,0,rand(2,3))
/*	spawn(30)
		do_wind()*/
/*
/obj/effect/effect/smoke/chem/proc/do_wind()
	if (!src)
		return
	var/area/A = get_area(src)
	if (src && A && A.location == AREA_OUTSIDE)
		var/turf/dest = null
		switch(map.winddirection)
			if("East")
				dest = get_turf(locate(x-1,y,z))
			if("West")
				dest = get_turf(locate(x+1,y,z))
			if("North")
				dest = get_turf(locate(x,y-1,z))
			if("South")
				dest = get_turf(locate(x,y+1,z))
		if(dest)
			walk_towards(src,dest,0,rand(2,3))
	spawn(40/map.windspeedvar)
		if(src)
			do_wind()
*/
/obj/effect/effect/smoke/chem/Destroy()
	opacity = FALSE
	walk(src, 0)
	fadeOut()
	..()

/obj/effect/effect/smoke/chem/Move()
	var/list/oldlocs = view(1, src)
	. = ..()
	if (.)
		// before we gas people, make sure we didn't pass a wall
		if (!passes_walls && istype(loc, /turf/wall))
			qdel(src)

		for (var/turf/T in view(1, src) - oldlocs)
			for (var/atom/movable/AM in T)
				if (!istype(AM, /obj/effect/effect/smoke/chem) || !istype(AM, /obj/item/weapon/reagent_containers))
					reagents.splash(AM, splash_amount, copy = TRUE)
		if (loc == destination)
			bound_width = 96
			bound_height = 96

/obj/effect/effect/smoke/chem/Crossed(atom/movable/AM)
	..()
	if (!istype(AM, /obj/effect/effect/smoke/chem) || !istype(AM, /obj/item/weapon/reagent_containers))
		reagents.splash(AM, splash_amount, copy = TRUE)

/obj/effect/effect/smoke/chem/proc/initial_splash()
	for (var/turf/T in view(1, src))
		for (var/atom/movable/AM in T)
			if (!istype(AM, /obj/effect/effect/smoke/chem) || !istype(AM, /obj/item/weapon/reagent_containers))
				reagents.splash(AM, splash_amount, copy = TRUE)

// Fades out the smoke smoothly using it's alpha variable.
/obj/effect/effect/smoke/chem/proc/fadeOut(var/frames = 16)
	if (!alpha) return //already transparent

	frames = max(frames, TRUE) //We will just assume that by FALSE frames, the coder meant "during one frame".
	var/alpha_step = round(alpha / frames)
	while (alpha > 0)
		alpha = max(0, alpha - alpha_step)
		sleep(world.tick_lag)

/////////////////////////////////////////////
// Chem Smoke Effect System
/////////////////////////////////////////////
/datum/effect/effect/system/smoke_spread/chem
	smoke_type = /obj/effect/effect/smoke/chem
	var/obj/chemholder
	var/range
	var/list/targetTurfs
	var/list/wallList
	var/density
	var/show_log = TRUE
/*8
/datum/effect/effect/system/smoke_spread/chem/spores
	show_log = FALSE
	var/datum/seed/seed

/datum/effect/effect/system/smoke_spread/chem/spores/New(seed_name)
	if (seed_name && plant_controller)
		seed = plant_controller.seeds[seed_name]
	if (!seed)
		qdel(src)
	..()
*/
/datum/effect/effect/system/smoke_spread/chem/New()
	..()
	chemholder = new/obj()
	chemholder.create_reagents(500)

//Sets up the chem smoke effect
// Calculates the max range smoke can travel, then gets all turfs in that view range.
// Culls the selected turfs to a (roughly) circle shape, then calls smokeFlow() to make
// sure the smoke can actually path to the turfs. This culls any turfs it can't reach.
/datum/effect/effect/system/smoke_spread/chem/set_up(var/datum/reagents/carry = null, n = 10, c = FALSE, loca, direct)
	range = n * 0.3
	cardinals = c
	carry.trans_to_obj(chemholder, carry.total_volume, copy = TRUE)

	if (istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if (!location)
		return

	targetTurfs = new()

	//build affected area list
	for (var/turf/T in view(range, location))
		//cull turfs to circle
		if (sqrt((T.x - location.x)**2 + (T.y - location.y)**2) <= range)
			targetTurfs += T

	wallList = new()

	smokeFlow() //pathing check

	//set the density of the cloud - for diluting reagents
	density = max(1, targetTurfs.len / 4) //clamp the cloud density minimum to TRUE so it cant multiply the reagents

	//Admin messaging
	var/contained = carry.get_reagents()
	var/area/A = get_area(location)

	var/where = "[A.name] | [location.x], [location.y]"
	var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

	if (show_log)
		if (carry.my_atom.fingerprintslast)
			var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
			var/more = ""
			if (M)
				more = "(<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</a>)"
			message_admins("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [carry.my_atom.fingerprintslast][more].")
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last associated key is [carry.my_atom.fingerprintslast].")
		else
			message_admins("A chemical smoke reaction has taken place in ([whereLink]). No associated key.")
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")

//Runs the chem smoke effect
// Spawns damage over time loop for each reagent held in the cloud.
// Applies reagents to walls that affect walls (only thermite and plant-b-gone at the moment).
// Also calculates target locations to spawn the visual smoke effect on, so the whole area
// is covered fairly evenly.
/datum/effect/effect/system/smoke_spread/chem/start()
	if (!location)
		return

	if (chemholder.reagents.reagent_list.len) //reagent application - only run if there are extra reagents in the smoke
		for (var/turf/T in wallList)
			chemholder.reagents.touch_turf(T)
		for (var/turf/T in targetTurfs)
			chemholder.reagents.touch_turf(T)
			for (var/atom/A in T.contents)
				if (istype(A, /obj/effect/effect/smoke/chem) || istype(A, /mob))
					continue
				else if (isobj(A) && !A.simulated)
					chemholder.reagents.touch_obj(A)

	var/color = chemholder.reagents.get_color() //build smoke icon
	var/icon/I
	if (color)
		I = icon('icons/effects/chemsmoke.dmi')
		I += color
	else
		I = icon('icons/effects/96x96.dmi', "smoke")

	//Calculate smoke duration
	var/smoke_duration = 150

	var/pressure = FALSE
	smoke_duration = between(5, smoke_duration*pressure/(ONE_ATMOSPHERE/3), smoke_duration)

	var/const/arcLength = 2.3559 //distance between each smoke cloud

	for (var/i = FALSE, i < range, i++) //calculate positions for smoke coverage - then spawn smoke
		var/radius = i * 1.5
		if (!radius)
			spawn(0)
				spawnSmoke(location, I, TRUE, TRUE)
			continue

		var/offset = FALSE
		var/points = round((radius * 2 * M_PI) / arcLength)
		var/angle = round(ToDegrees(arcLength / radius), TRUE)

		if (!IsInteger(radius))
			offset = 45		//degrees

		for (var/j = FALSE, j < points, j++)
			var/a = (angle * j) + offset
			var/x = round(radius * cos(a) + location.x, TRUE)
			var/y = round(radius * sin(a) + location.y, TRUE)
			var/turf/T = locate(x,y,location.z)
			if (!T)
				continue
			if (T in targetTurfs)
				spawn(0)
					spawnSmoke(T, I, range)

//------------------------------------------
// Randomizes and spawns the smoke effect.
// Also handles deleting the smoke once the effect is finished.
//------------------------------------------
/datum/effect/effect/system/smoke_spread/chem/proc/spawnSmoke(var/turf/T, var/icon/I, var/smoke_duration, var/dist = TRUE, var/splash_initial=0, var/obj/effect/effect/smoke/chem/passed_smoke)

	var/obj/effect/effect/smoke/chem/smoke
	if (passed_smoke)
		smoke = passed_smoke
	else
		smoke = PoolOrNew(/obj/effect/effect/smoke/chem, list(location, smoke_duration + rand(0, 20), T, I))

	if (chemholder.reagents.reagent_list.len)
		chemholder.reagents.trans_to_obj(smoke, chemholder.reagents.total_volume / dist, copy = TRUE) //copy reagents to the smoke so mob/breathe() can handle inhaling the reagents

	//Kinda ugly, but needed unless the system is reworked
	if (splash_initial)
		smoke.initial_splash()

/*
/datum/effect/effect/system/smoke_spread/chem/spores/spawnSmoke(var/turf/T, var/smoke_duration, var/icon/I, var/dist = TRUE)
	var/obj/effect/effect/smoke/chem/spores = PoolOrNew(/obj/effect/effect/smoke/chem, location)
	spores.name = "cloud of [seed.seed_name] [seed.seed_noun]"
	..(T, I, smoke_duration, dist, spores)
*/

/datum/effect/effect/system/smoke_spread/chem/proc/smokeFlow() // Smoke pathfinder. Uses a flood fill method based on zones to quickly check what turfs the smoke (airflow) can actually reach.

	var/list/pending = new()
	var/list/complete = new()

	pending += location

	while (pending.len)
		for (var/turf/current in pending)
			for (var/D in cardinal)
				var/turf/target = get_step(current, D)
				if (wallList)
					if (istype(target, /turf/wall))
						if (!(target in wallList))
							wallList += target
						continue

				if (target in pending)
					continue
				if (target in complete)
					continue
				if (!(target in targetTurfs))
					continue
			/*	if (current.c_airblock(target)) //this is needed to stop chemsmoke from passing through thin window walls
					continue
				if (target.c_airblock(current))
					continue*/
				pending += target

			pending -= current
			complete += current

	targetTurfs = complete

	return
