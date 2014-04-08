diag_mod(emergency_main,
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [set(entry,[p1])] => locate_pers
	  ]
	],

	[
	  id ==> locate_pers,
	  type ==> recursive,
	  embedded_dm ==> emergency_locate([p1,p2],[p2,turn=>(-90),turn=>(180),tv_counter,turn=>(-90),turn=>(180)],
	                                   ['hello i am golem and i will go to the rescue','let me find the person']),
	  arcs ==> [
	       up(Curr_posit, Last_posit) : [sleep(3)] => det_event(up,Curr_posit,Last_posit),
	       down(Curr_posit, Last_posit) : [sleep(3)] => det_event(down,Curr_posit, Last_posit)
	  ]
	],

	[
	  id ==> det_event(Sit, Curr_posit, Last_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_event(Sit,Last_posit),
	  arcs ==> [
	       success : [say('a report of the current situation has been saved in the u s b plugged into my laptop')] => request_needs(Curr_posit)
	  ]
	],

	[
	  id ==> request_needs(Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_person(drink,[sideboard,bed,pantry],Pers_posit),
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
