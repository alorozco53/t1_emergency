diag_mod(emergency_main,
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [initSpeech,execute('scripts/upfollow.sh')] => locate_pers
	  ]
	],

	[
	  id ==> locate_pers,
	  type ==> recursive,
	  embedded_dm ==> emergency_locate([p1,p2],[p2,p3],['hello i am golem and i will go to the rescue','let me find the person']),
	  arcs ==> [
	       up(Position) : [execute('scripts/killvisual.sh')] => accident(up,Position),
	       down(Position) : [execute('scripts/killvisual.sh')] => accident(down,Position)

	  ]
	],

	[
	  id ==> accident(Sit, Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_event(Sit,Pers_posit),
	  arcs ==> [
	       X : [execute('scripts/objectvisual.sh')] => person(X)
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