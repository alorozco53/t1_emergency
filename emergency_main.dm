diag_mod(emergency_main,
[

	[
      		id ==> is,	
      		type ==> neutral,
      		arcs ==> [
        		empty : [set(entry,[nearexitrev]),initSpeech,say('I will wait until the door is open')] => detect_door
      			]
    	],


	 [  
      		id ==> detect_door,
      		type ==> recursive,
      		embedded_dm ==> detect_door(Status),
      		arcs ==> [
        			success : [say('The door is open')] => locate_pers,
        			error : [say('The door is still closed')] => detect_door
				
      			]
    	],

	[
	  id ==> locate_pers,
	  type ==> recursive,
	  embedded_dm ==> emergency_locate([nearexit,be1],[b3,be2],['hello see ooh dad dell carmen my name is golem and i will go to the rescue','let me find the person']),
	  arcs ==> [
	       up(Curr_posit, Last_posit) : empty => det_event(up,Curr_posit,Last_posit),
	       down(Curr_posit, Last_posit) : [tiltv(-30)] => det_event(down,Curr_posit, Last_posit)
	  ]
	],

	[
	  id ==> det_event(Sit, Curr_posit, Last_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_event(Sit,Last_posit),
	  arcs ==> [
	       success : [say('alright')] => request_needs(Curr_posit)
	  ]
	],

	[
	  id ==> request_needs(Pers_posit),
	  type ==> recursive,
	  embedded_dm ==> emergency_person(drink,[l3],Pers_posit),
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
%Third argument: list of parameters
[
  entry ==> []
]
).
