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
	       success : [arrived_posit(Locations,Rem_Posit,Cp),execute('scripts/killvisual'),execute('scripts/personvisual')]
	                 => get_curr_pos(up,Cp),
	       error : [arrived_posit(Locations,Rem_Posit,Cp)] => verify_error(Status,Cp)
	  ]
	],

	[
	  id ==> verify_error(navigation_error, Curr_posit),
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/killvisual'),execute('scripts/personvisual')] => get_curr_pos(down,Curr_posit)
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
	  embedded_dm ==> find(person,W,[turn=>(10),turn=>(-10)],[-10,10],[0,-15],detect_with_approach,Found,Rem_Posit,yes,yes,yes,Status),
	  arcs ==> [
	       success : [(Pos = up -> Sit = up([X,Y,Z],Last_posit) | otherwise -> Sit = down([X,Y,Z],Last_posit))] => Sit,
	       error : [say('could you move closer to me please')] => approach_sit(Pos,[X,Y,Z])
	  ]
	],

	% Guardar posicion actual
	[  
    	  id ==> get_curr_pos(Pos, Last_posit),
   	  type ==> positionxyz,
    	  arcs ==> [
      	       pos(X,Y,Z) : empty => approach_sit(Pos,[X,Y,Z])
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
