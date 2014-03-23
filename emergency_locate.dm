diag_mod(emergency_locate(Places, Locations, Messages, Position),
[
	[
	   id ==> is,
	   type ==> neutral,
	   arcs ==> [
	   	empty : empty => ms(Places,Messages)
	   ]
	],

	[
	  id ==> ms([],X),
	  type ==> neutral,
	  arcs ==> [
	       empty : empty => fps
	  ]
	],

	[
	  id ==> ms([H|T],[HM|TM]),
	  type ==> recursive,
	  embedded_dm ==> move(H,Status),
	  arcs ==> [
	       success : [say(HM)] => ms(T,TM),
	       error : [say('i will try to reach all the desired positions as soon as possible')] => ms([H|T],[HM|TM])
	  ]
	],

	[
	  id ==> fps,
	  type ==> recursive,
	  embedded_dm ==> find(gesture,X,Locations,[-20,0,20],[-30,0,30],3,Found_Objects,Remaining_Positions,yes,false,false,Status),
	  diag_mod ==> emergency_locate(_,_,_,up),
	  arcs ==> [
	       success : [say('i succeeded in locating the person')] => success,
	       error : empty => verify_error(Status)
	  ]
	],

	[
	  id ==> verify_error(navigation_error),
	  type ==> neutral,
	  diag_mod ==> emergency_locate(_,_,_,down),
	  arcs ==> [
	       empty : [say('i succeeded in locating the person')] => success
	  ]
	],

	[
	  id ==> verify_error(Error),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('let me try to find the person again')] => fps
	  ]
	],

	%Final situations
	[
	  id ==> success,
	  type ==> final
	]
],
% List of local variables
[
]
).
% End of dialogue
