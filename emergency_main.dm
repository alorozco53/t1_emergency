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
	       up(Position) : [sleep(5)] => accident(up,Position),
	       down(Position) : [sleep(5)] => accident(down,Position)
	  ]
	],

	[
	  id ==> accident(Sit, Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_event(Sit,Pers_posit),
	  arcs ==> [
	       success(Output) : [say(Output)] => fs
	  ]
	],










	[
	  id ==> fs,
	  type ==> final
	]
],
%Second argument: list of parameters
[
]
).
