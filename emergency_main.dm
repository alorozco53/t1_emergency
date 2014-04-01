diag_mod(emergency_main,
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [set(entry,lobby)] => request_needs([1,2,3]) 
	  ]
	],

	[
	  id ==> locate_pers,
	  type ==> recursive,
	  embedded_dm ==> emergency_locate([p1,livingroom],[livingroom,bedroom,p3],['hello i am golem and i will go to the rescue','let me find the person']),
	  arcs ==> [
	       up(Position) : [sleep(3)] => det_event(up,Position),
	       down(Position) : [sleep(3)] => det_event(down,Position)
	  ]
	],

	[
	  id ==> det_event(Sit, Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_event(Sit,Pers_posit),
	  arcs ==> [
	       success : [say('a report of the current situation has been saved in the usb plugged into my laptop')] => request_needs(Pers_posit)
	  ]
	],

	[
	  id ==> request_needs(Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_person(drink,[kitchen,diningroom],Pers_posit),
	  arcs ==> [
	       success : [say('ok now i will go to the houses entrance'),get(entry,Entry)] => rescue_sit(Entry,Pers_posit)
	  ]
	],

	[
	  id ==> rescue_sit(Entry_posit, Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_rescue(Entry,posit,Pers_posit),
	  arcs ==> [
	       success : [say('this is the end of my services so long and thanks for all the fish')] => fs
	  ]
	],

	[
	  id ==> fs,
	  type ==> final
	]
],
%Second argument: list of parameters
[
  entry ==> ''
]
).
