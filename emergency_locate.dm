diag_mod(emergency_locate(Places, Locations, Messages),
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
	       empty : [execute('scripts/personvisual.sh')] => fps(gesture,3)
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
	  id ==> fps(Mode,Category),
	  type ==> recursive,
	  embedded_dm ==> find(Mode,X,Locations,[-20,0,20],[-30,0,30],Category,[H|T],Remaining_Positions,yes,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in locating the person'),execute('scripts/killvisual.sh')] => get_curr_pos(up),
	       error : empty => verify_error(Status)
	  ]
	],

	[
	  id ==> verify_error(navigation_error),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('i succeeded in locating the person'),execute('scripts/killvisual.sh')] => get_curr_pos(down)
	  ]
	],

	[
	  id ==> verify_error(Error),
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/killvisual.sh'),say('let me try to find the person again'),execute('scripts/upfollow.sh')] => fps(gesture,3)
	  ]
	],

	% Guardar posicion actual
	[  
    	  id ==> get_curr_pos(Pos),
   	  type ==> positionxyz,
    	  arcs ==> [
      	       pos(X,Y,Z) : [(Pos = up -> Sit = up([X,Y,Z]) | otherwise -> Sit = down([X,Y,Z]))] => Sit
	  ]
  	],

	% Final situations
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