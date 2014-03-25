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
	  embedded_dm ==> find(gesture,X,Locations,[-20,0,20],[-30,0,30],3,[H|T],Remaining_Positions,yes,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in locating the person')] => up(H),
	       error : empty => verify_error(Status)
	  ]
	],

	[
	  id ==> verify_error(navigation_error),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('i succeeded in locating the person')] => get_curr_pos
	  ]
	],

	[
	  id ==> verify_error(Error),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('let me try to find the person again')] => fps
	  ]
	],

	% Guardar posicion actual
	[  
    	  id ==> get_curr_pos,
   	  type ==> positionxyz,
    	  arcs ==> [
      	       pos(X,Y,Z) : empty => down([X,Y,Z])
    	  ]
  	],

	%Final situations
	[
	  id ==> up(Person_posit),
	  type ==> final
	],

	[
	  id ==> down(Person_posit),
	  type ==> final
	]

],
% List of local variables
[
]
).
% End of dialogue
