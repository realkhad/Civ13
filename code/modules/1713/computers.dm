
/////////////////////////////////////////
////////////////COMPUTERS////////////////
/////////////////////////////////////////

//BASE ELECTRONIC FOR COPY AND PASTING LMAO
/*/obj/structure/base_powered_object
	name = "Powered Object"
	desc = "This is meant to be copy-pasted to make more cool stuff with the power system."
	icon = 'icons/obj/modern_structures.dmi'
	icon_state = "off"
	flammable = FALSE
	not_movable = FALSE
	not_disassemblable = TRUE
	var/active = FALSE
	powerneeded = 1

/obj/structure/base_powered_object/attackby(var/obj/item/W as obj, var/mob/living/human/H as mob)
	if (istype(W, /obj/item/stack/cable_coil))
		if (!anchored)
			H << "<span class='notice'>Fix the [src] in place with a wrench first.</span>"
			return
		if (powersource)
			H << "There's already a cable connected here! Split it further from the [src]."
			return
		var/obj/item/stack/cable_coil/CC = W
		powersource = CC.place_turf(get_turf(src), H, turn(get_dir(H,src),180))
		powersource.connections += src

		var/opdir1 = 0
		var/opdir2 = 0
		if (powersource.tiledir == "horizontal")
			opdir1 = 4
			opdir2 = 8
		else if  (powersource.tiledir == "vertical")
			opdir1 = 1
			opdir2 = 2
		powersource.update_icon()

		if (opdir1 != 0 && opdir2 != 0)
			for(var/obj/structure/cable/NCOO in get_turf(get_step(powersource,opdir1)))
				if ((NCOO.tiledir == powersource.tiledir) && NCOO != powersource)
					if (!(powersource in NCOO.connections) && !list_cmp(powersource.connections, NCOO.connections))
						NCOO.connections += powersource
					if (!(NCOO in powersource.connections) && !list_cmp(powersource.connections, NCOO.connections))
						powersource.connections += NCOO
					H << "You connect the two cables."

			for(var/obj/structure/cable/NCOC in get_turf(get_step(powersource,opdir2)))
				if ((NCOC.tiledir == powersource.tiledir) && NCOC != powersource)
					if (!(powersource in NCOC.connections) && !list_cmp(powersource.connections, NCOC.connections))
						NCOC.connections += powersource
					if (!(NCOC in powersource.connections) && !list_cmp(powersource.connections, NCOC.connections))
						powersource.connections += NCOC
					H << "You connect the two cables."
		H << "You connect the cable to the [src]."

	else
		..()


/obj/structure/base_powered_object/attack_hand(var/mob/living/human/H)
	if (active)
		active = FALSE
		powered = FALSE
		powersource.update_power(powerneeded,1)
		powersource.currentflow -= powerneeded
		powersource.lastupdate2 = world.time
		H << "You power off the [src]."
		update_icon()
		return

	else if (!active && !powersource.powered)
		H << "<span class = 'notice'>There is not enough power to start the [src].</span>"
		update_icon()
		return
	else if (!active && powersource.powered && ((powersource.powerflow-powersource.currentflow) >= powerneeded))
		active = TRUE
		powered = TRUE
		powersource.update_power(powerneeded,1)
		powersource.currentflow += powerneeded
		powersource.lastupdate2 = world.time
		power_on()
		H << "You power the [src]."
		update_icon()
		return
	else
		H << "<span class = 'notice'>There is not enough power to start the [src].</span>"
		return

/obj/structure/base_powered_object/proc/power_on()
	if (powered && active)
		update_icon()
		//do something here.
	else
		update_icon()
		return

/obj/structure/base_powered_object/update_icon()
	if (active)
		icon_state = "on"
	else
		icon_state = "off"*/

/obj/structure/computer/
	name = "Parent Computer"
	desc = "A simplistic computer. This is the parent object."
	icon = 'icons/obj/computers.dmi'
	icon_state = "1980_computer_off"
	var/peripherals = list()
	var/internals = list()
	var/operatingsystem = "ungaOS"
	var/memory = list()
	var/display = "UngaOS V 0.0.1<br>"
	flammable = FALSE
	not_movable = FALSE
	not_disassemblable = TRUE
	var/active = FALSE
	powered = FALSE
	powerneeded = 1

/obj/structure/computer/nopower
	name = "Desktop Computer"
	desc = "A desktop computer running the latest version of UngaOS."
	powered = TRUE
	powerneeded = FALSE
	anchored = TRUE

/obj/structure/computer/attackby(var/obj/item/W as obj, var/mob/living/human/H as mob)
	if (istype(W, /obj/item/stack/cable_coil))
		if (!anchored)
			H << "<span class='notice'>Fix the [src] in place with a wrench first.</span>"
			return
		if (powersource)
			H << "There's already a cable connected here! Split it further from the [src]."
			return
		var/obj/item/stack/cable_coil/CC = W
		powersource = CC.place_turf(get_turf(src), H, turn(get_dir(H,src),180))
		powersource.connections += src

		var/opdir1 = 0
		var/opdir2 = 0
		if (powersource.tiledir == "horizontal")
			opdir1 = 4
			opdir2 = 8
		else if  (powersource.tiledir == "vertical")
			opdir1 = 1
			opdir2 = 2
		powersource.update_icon()

		if (opdir1 != 0 && opdir2 != 0)
			for(var/obj/structure/cable/NCOO in get_turf(get_step(powersource,opdir1)))
				if ((NCOO.tiledir == powersource.tiledir) && NCOO != powersource)
					if (!(powersource in NCOO.connections) && !list_cmp(powersource.connections, NCOO.connections))
						NCOO.connections += powersource
					if (!(NCOO in powersource.connections) && !list_cmp(powersource.connections, NCOO.connections))
						powersource.connections += NCOO
					H << "You connect the two cables."

			for(var/obj/structure/cable/NCOC in get_turf(get_step(powersource,opdir2)))
				if ((NCOC.tiledir == powersource.tiledir) && NCOC != powersource)
					if (!(powersource in NCOC.connections) && !list_cmp(powersource.connections, NCOC.connections))
						NCOC.connections += powersource
					if (!(NCOC in powersource.connections) && !list_cmp(powersource.connections, NCOC.connections))
						powersource.connections += NCOC
					H << "You connect the two cables."
		H << "You connect the cable to the [src]."

	else
		..()
/obj/structure/computer/verb/toggle_power(var/mob/living/human/H)
	set category = null
	set name = "Turn On"
	set src in range(1, usr)
	if(src.active)
		name = "Turn Off"
	if(!powersource)
		H << "<span class = 'notice'>You need to plug in the [src].</span>"
		return
	if (active)
		active = FALSE
		powered = FALSE
		powersource.update_power(powerneeded,1)
		powersource.currentflow -= powerneeded
		powersource.lastupdate2 = world.time
		H << "You power off the [src]."
		update_icon()
		return
	else if (!active && !powersource.powered)
		H << "<span class = 'notice'>There is not enough power to start the [src].</span>"
		update_icon()
		return
	else if (!active && powersource.powered && ((powersource.powerflow-powersource.currentflow) >= powerneeded))
		active = TRUE
		powered = TRUE
		powersource.update_power(powerneeded,1)
		powersource.currentflow += powerneeded
		powersource.lastupdate2 = world.time
		power_on()
		H << "You power the [src]."
		update_icon()
		return
	else
		H << "<span class = 'notice'>There is not enough power to start the [src].</span>"
		return
/obj/structure/computer/attack_hand(var/mob/living/human/H)
	if(!src.active)
		load_os()
	else
		H << "<span class = 'notice'>You need to turn the [src] on first!</span>"
/obj/structure/computer/proc/power_on()
	if (powered && active)
		update_icon()
		//do somethin
	else
		update_icon()
		return

/obj/structure/computer/update_icon()
	if (active)
		icon_state = "1980_computer_on"
	else
		icon_state = "1980_computer_off"
/obj/structure/computer/proc/load_os()
	if(operatingsystem == "ungaOS")
		var/os = {"
				<!DOCTYPE html>
				<html>
				<head>
				<title>Unga OS V 0.1</title>
				<style>
				body {
					background-color: #161610
				}
				.vertical-center {
				  margin: 0;
				  position: absolute;
				  top: 40%;
				  -ms-transform: translateY(-50%);
				  transform: translateY(-50%);
				  padding-left: 5%
				}
				</style>
				<script type="text/javascript">
					typeFunction() {
						if (e.keyCode == 13) {
							byond://?src=\ref[src]&action=textenter&value=document.getElementById('input').value
					    }
						byond://?src=\ref[src]&action=textrecieved&value=document.getElementById('input').value
					}
				</head>
				<div class="vertical-center">
				<textarea id="display" name="display" rows="25" cols="60" readonly="true" style="resize: none; background-color: black; color: lime; border-style: inset inset inset inset; border-color: #161610; overflow: hidden;">
				"}
		os+=display
		os+={"</textarea>
				<input type="text" id="input" name="input" style="resize: none; background-color: black; color: lime; border-style: none inset inset inset; border-color: #161610; overflow: hidden;" onkeypress="typeFunction()"></input>
				</div>
				</html>
				"}
		usr << browse(os,"window=ungaos;border=1;can_close=1;can_resize=0;can_minimize=0;titlebar=1;size=500x500")

/obj/structure/computer/Topic(href, list/href_list)
	var/action = href_list["action"]
	if(action == "textrecieved")
		var/typenoise = pick('sound/machines/computer/key_1.ogg',
							 'sound/machines/computer/key_2.ogg',
							 'sound/machines/computer/key_3.ogg',
							 'sound/machines/computer/key_4.ogg',
							 'sound/machines/computer/key_5.ogg',
							 'sound/machines/computer/key_6.ogg',
							 'sound/machines/computer/key_7.ogg',
							 'sound/machines/computer/key_8.ogg')
		playsound(loc, typenoise, 10, TRUE)
	if(action == "textenter")
		playsound(loc, 'sound/machines/computer/key_enter.ogg', 10, TRUE)
		display+=href_list["value"]

//////////////////////////////////////////////////////////////

/obj/structure/computer/nopower/aotd
	name = "Desktop Computer"
	desc = "A desktop computer running the latest version of UngaOS. Has a floppy drive."
	powered = TRUE
	powerneeded = FALSE
	anchored = TRUE
/obj/structure/computer/nopower/aotd/attackby(var/obj/item/weapon/disk/D, var/mob/living/human/H)
	if (istype(D, /obj/item/weapon/disk))
		if (D.faction == H.civilization)
			H << "<span class='notice'>You can't read a disk belonging to your company.</span>"
			return
		else if (H.civilization == "Police")
			H << "<span class='notice'>You do not know how to decrypt this... Should put it in the evidence room instead.</span>"
			return
		else if (D.used)
			H << "<span class='notice'>This disk has already been decrypted and wiped.</span>"
			return
		else
			playsound(get_turf(src), 'sound/machines/computer/floppydisk.ogg', 100, TRUE)
			switch(D.exchange_state)
				if (-1)
					if (D.fake)
						WWalert(H,"This is a fake inactive disk! You lose 100 points.", "Fake Disk")
						map.scores[H.civilization] -= 100
						D.used = TRUE
						qdel(D)
					else
						WWalert(H,"This is a real inactive disk! You gain 100 dollars and 100 points.", "Real Disk")
						map.scores[H.civilization] += 100
						var/obj/item/stack/money/dollar/DLR = new/obj/item/stack/money/dollar(loc)
						DLR.amount = 40
						D.used = TRUE
						qdel(D)
				if (0)
					if (D.fake)
						WWalert(H,"This is a fake disk! Since you exchanged it with a fake disk too, both factions lose 400 points.", "Fake Disk")
						map.scores[H.civilization] -= 400
						D.used = TRUE
						qdel(D)

				if (1)
					if (D.fake)
						WWalert(H,"This is a fake disk! Since you exchanged it with a real disk, you gain nothing and the other faction gains 200 dollars and 200 points.", "Fake Disk")
						D.used = TRUE
						qdel(D)
					else
						WWalert(H,"This is a real disk! Since you exchanged it with a fake disk, you gain 200 dollars, 200 points and the other faction gains nothing.", "Real Disk")
						map.scores[H.civilization] += 200
						var/obj/item/stack/money/dollar/DLR = new/obj/item/stack/money/dollar(loc)
						DLR.amount = 40
						D.used = TRUE
						qdel(D)
				if (2)
					if (!D.fake)
						WWalert(H,"This is a real disk! Since you exchanged it with a real disk too, both factions gain 400 dollars and 400 points.", "Real Disk")
						map.scores[H.civilization] += 400
						var/obj/item/stack/money/dollar/DLR = new/obj/item/stack/money/dollar(loc)
						DLR.amount = 80
						D.used = TRUE
						qdel(D)
	else
		..()

/obj/structure/computer/nopower/carsales
	name = "CARTRADER Terminal"
	desc = "A computer terminal connected to the CARTRADER network."
	powered = TRUE
	powerneeded = FALSE
	anchored = TRUE
/obj/structure/computer/nopower/carsales/attackby(var/obj/item/D, var/mob/living/human/H)
	if (istype(D, /obj/item/stack/money))
		var/choice = WWinput(H, "Which model do you want to purchase?","Car Purchase","Cancel",list("Cancel","Yamasaki M125 motorcycle (160)","ASNO Quattroporte (500)","Ubermacht Erstenklasse (900)"))
		if (choice == "Cancel")
			return
		else
			var/obj/effects/premadevehicles/PV
			if (choice == "Yamasaki M125 motorcycle (160)")
				if (D.value*D.amount >= 160*4)
					D.amount-=32
				else
					H << "<span class='warning'>Not enough money!</span>"
					return
				new /obj/structure/vehicle/motorcycle/m125/full(locate(x+4,y-1,z))
				return
			else if (choice == "ASNO Quattroporte (500)")
				var/chosencolor = WWinput(H,"Which color do you want?","Car Purchase","Black",list("Black","Red","Blue","Green","Yellow","Dark Grey","Light Grey","White"))
				switch(chosencolor)
					if ("Black")
						chosencolor = "#181717"
					if ("Light Grey")
						chosencolor = "#919191"
					if ("Dark Grey")
						chosencolor = "#616161"
					if ("White")
						chosencolor = "#FFFFFF"
					if ("Green")
						chosencolor = "#007F00"
					if ("Red")
						chosencolor = "#7F0000"
					if ("Yellow")
						chosencolor = "#b8b537"
					if ("Blue")
						chosencolor = "#00007F"
				if (D.value*D.amount >= 500*4)
					D.amount-=100
				else
					H << "<span class='warning'>Not enough money!</span>"
					return
				PV = new /obj/effects/premadevehicles/asno/quattroporte(locate(x+3,y-3,z))
				PV.custom_color = chosencolor
				PV.doorcode = rand(1000,9999)
				var/obj/item/weapon/key/civ/C = new /obj/item/weapon/key/civ(loc)
				C.name = "car key"
				C.code = PV.doorcode
				var/obj/item/weapon/key/civ/C2 = new /obj/item/weapon/key/civ(loc)
				C2.name = "car key"
				C2.code = PV.doorcode
			else if (choice == "Ubermacht Erstenklasse (900)")
				var/chosencolor = WWinput(H,"Which color do you want?","Car Purchase","Black",list("Black","Red","Blue","Green","Yellow","Dark Grey","Light Grey","White"))
				switch(chosencolor)
					if ("Black")
						chosencolor = "#181717"
					if ("Light Grey")
						chosencolor = "#919191"
					if ("Dark Grey")
						chosencolor = "#616161"
					if ("White")
						chosencolor = "#FFFFFF"
					if ("Green")
						chosencolor = "#007F00"
					if ("Red")
						chosencolor = "#7F0000"
					if ("Yellow")
						chosencolor = "#b8b537"
					if ("Blue")
						chosencolor = "#00007F"
				if (D.value*D.amount >= 900*4)
					D.amount-=180
				else
					H << "<span class='warning'>Not enough money!</span>"
					return
				PV = new /obj/effects/premadevehicles/ubermacht/erstenklasse(locate(x+3,y-3,z))
				PV.custom_color = chosencolor
				PV.doorcode = rand(1000,9999)
				var/obj/item/weapon/key/civ/C = new /obj/item/weapon/key/civ(loc)
				C.name = "car key"
				C.code = PV.doorcode
				var/obj/item/weapon/key/civ/C2 = new /obj/item/weapon/key/civ(loc)
				C2.name = "car key"
				C2.code = PV.doorcode
	else
		..()


/obj/structure/computer/nopower/police
	name = "Police Processing Terminal"
	desc = "A terminal that processes and registers warrants."
	icon_state = "research_on"
	powered = TRUE
	powerneeded = FALSE
	anchored = TRUE
	var/list/pending_warrants = list()

/obj/structure/computer/nopower/police/attack_hand(var/mob/living/human/H)
	if (!ishuman(H))
		return
	var/what = WWinput(H, "Welcome to the Police Processing Terminal. Whar do you want to do?", "P.P.T.", "Quit",list("Quit","Check Warrants", "Print Warrant", "Register Suspect"))
	switch(what)
		if ("Quit")
			return
		if ("Check Warrants")
			var/list/tlist = list()
			for(var/obj/item/weapon/paper/police/warrant/SW in pending_warrants)
				tlist += "[SW.arn]: [SW.tgt], working for [SW.tgtcmp]"
			tlist += "Quit"
			var/choice = WWinput(H, "Current Warrants:","P.P.T.","Quit",tlist)
			if (choice)
				return
		if ("Print Warrant")
			var/list/tlist = list()
			for(var/obj/item/weapon/paper/police/warrant/SW in pending_warrants)
				tlist += "[SW.arn]: [SW.tgt], working for [SW.tgtcmp]"
			tlist += "Quit"
			var/choice = WWinput(H, "Choose a Warrant to print:","P.P.T.","Quit",tlist)
			if (choice == "Quit")
				return
			else
				choice = splittext(choice,":")[1]
				for(var/obj/item/weapon/paper/police/warrant/SW in pending_warrants)
					if (SW.arn == choice)
						var/obj/item/weapon/paper/police/warrant/NW = new/obj/item/weapon/paper/police/warrant(loc)
						NW.tgt_mob = SW.tgt_mob
						NW.tgt = SW.tgt
						NW.tgtcmp = SW.tgtcmp
						NW.arn = SW.arn
						return
		if ("Register Suspect")
			var/done = FALSE
			var/found = FALSE
			for (var/mob/living/human/S in range(2,src))
				found = TRUE
				for(var/obj/item/weapon/paper/police/warrant/SW in pending_warrants)
					if (SW.tgt_mob == S)
						map.scores["Police"] += 300
						done = TRUE
						pending_warrants -= SW
						visible_message("<big><font color='green'>Processed warrant no. [SW.arn] for [SW.tgt].</font></big>")
						pending_warrants -= SW
						SW.forceMove(null)
						qdel(SW)
			if (!done && found)
				visible_message("<big><font color='yellow'>There are no outstanding warrants for any of the suspects.</font></big>")
			else if (!done && !found)
				visible_message("<big><font color='yellow'>There are no suspects present.</font></big>")
			else if (done && found)
				visible_message("<big><font color='green'><b>All suspects in the bench have been sucessfully registed into the system and can be released now.</b></font></big>")
