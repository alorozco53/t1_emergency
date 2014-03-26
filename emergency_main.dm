diag_mod(emergency_main,
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : empty => locate_pers
	  ]
	],

	[
	  id ==> locate_pers,
	  type ==> recursive,
	  embedded_dm ==> emergency_locate([p1,p2],[p2,p3],['hello i am golem and i will go to the rescue','let me find the person']),
	  arcs ==> [
	       up(Position) : [set(pers_posit,Position), sleep(3)] => det_event(up,Position),
	       down(Position) : [set(pers_posit,Position), sleep(3)] => det_event(down,Position)
	  ]
	],

	[
	  id ==> det_event(Sit, Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_event(Sit,Pers_posit),
	  arcs ==> [
	       success : [say('a report of the current situation has been saved in the usb plugged into my laptop')] => request_needs
	  ]
	],

	[
	  id ==> request_needs,
	  type ==> recursive,
	  embedded_dm ==> emergency_person,
	  arcs ==> [
	       success : empty => rescue_sit
	  ]
	]






	[
	  id ==> fs,
	  type ==> final
	]
],
%Second argument: list of parameters
[
  pers_posit ==> ''
]
).
