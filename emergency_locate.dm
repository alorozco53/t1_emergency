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
	  id ==> ms([], X),
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/upfollow.sh')] => fps(gesture,15)
	  ]
	],

	[
	  id ==> ms([H|T], [HM|TM]),
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
	  embedded_dm ==> find(Mode,X,Locations,[-10,10],[0,-15],Category,Found,Rem_Posit,yes,false,false,Status),
	  arcs ==> [
	       success : [arrived_posit(Locations,Rem_Posit,Cp),
	       	       	 say('i succeeded in locating the injured person'),execute('scripts/killvisual.sh')]
	                 => get_curr_pos2(up,Cp),
	       error : [arrived_posit(Locations,Rem_Posit,Cp)] => verify_error(Status,Cp)
	  ]
	],

	[
	  id ==> verify_error(navigation_error, Curr_posit),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('an assistance gesture has been detected'),execute('scripts/killvisual.sh'),execute('scripts/personvisual.sh'),say('attempting to get close to the injured person')]
	       	       => get_curr_pos1(down,Curr_posit)
	  ]
	],

	[
	  id ==> verify_error(Error, Curr_posit),
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/killvisual.sh'),say('let me try to find the person again'),execute('scripts/upfollow.sh')] => fps(gesture,15)
	  ]
	],

	[
	  id ==> approach_sit(Pos,[X,Y,Z]),
	  type ==> recursive,
	  embedded_dm ==> find(person,W,[turn=>(10),turn=>(-10)],[-10,10],[0,-15],detect_with_approach,Found,Rem_Posit,true,true,true,Status),
	  arcs ==> [
	       success : [execute('scripts/killvisual.sh')] => get_curr_pos2(Pos,[X,Y,Z]),
	       error : [say('could you move closer to me please')] => approach_sit(Pos,[X,Y,Z])
	  ]
	],

	% Guardar posicion actual
	[  
    	  id ==> get_curr_pos1(Pos, Last_posit),
   	  type ==> positionxyz,
    	  arcs ==> [
      	       pos(X,Y,Z) : empty => approach_sit(Pos,[X,Y,Z])
	  ]
  	],

	[  
    	  id ==> get_curr_pos2(Pos, Last_posit),
   	  type ==> positionxyz,
    	  arcs ==> [
      	       pos(X,Y,Z) : [(Pos = up -> Sit = up([X,Y,Z],Last_posit) | otherwise -> Sit = down([X,Y,Z],Last_posit))] => Sit
	  ]
  	],

	% Final situations
	[
	  id ==> up(Person_posit, Last_posit),
	  type ==> final
	],

	[
	  id ==> down(Person_posit, Last_posit),
	  type ==> final
	]

],
% List of local variables
[
	rem_posit ==> [],
	pos ==> [],
	last_posit ==> '',
	found_posit ==> []
]
).
% End of dialogue
