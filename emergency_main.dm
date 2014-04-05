diag_mod(emergency_main,
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [set(entry,[nearexit])] => locate_pers
	  ]
	],

	[
	  id ==> locate_pers,
	  type ==> recursive,
	  embedded_dm ==> emergency_locate([nearexit,livingroom],[livingroom,couch_table,tv_counter],
	                                   ['hello i am golem and i will go to the rescue','let me find the person']),
	  arcs ==> [
	       up(Position) : [sleep(3),execute('scripts/actualiza_reporte.sh')] => det_event(up,Position),
	       down(Position) : [sleep(3),execute('scripts/actualiza_reporte.sh')] => det_event(down,Position)
	  ]
	],

	[
	  id ==> det_event(Sit, Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_event(Sit,Pers_posit),
	  arcs ==> [
	       success : [say('a report of the current situation has been saved in the u s b plugged into my laptop')] => request_needs(Pers_posit)
	  ]
	],

	[
	  id ==> request_needs(Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_person(drink,[bed,bedside_table,dresser],Pers_posit),
	  arcs ==> [
	       success : [say('ok now i will go to the houses entrance'),get(entry,Entry)] => rescue_sit(Entry,Pers_posit)
	  ]
	],

	[
	  id ==> rescue_sit(Entry_posit, Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_rescue(Entry_posit,Pers_posit),
	  arcs ==> [
	       success : [say('this is the end of my services so long and thanks for all the fish')] => fs
	  ]
	],

	[
	  id ==> fs,
	  type ==> final
	]
],
%Third} argument: list of parameters
[
  entry ==> []
]
).