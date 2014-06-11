diag_mod(emergency_locate(Places, Locations, Messages, Status),
[
%       Start of main sequence of this task defining situations
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
	       error : [arrived_posit(Locations,Rem_Posit,Cp)] => verify_error_fps(Status,Cp)
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
	  type ==> final,
          diag_mod ==> emergency_locate(_,_,_,ok)
	],

	[
	  id ==> down(Person_posit, Last_posit),
	  type ==> final,
          diag_mod ==> emergency_locate(_,_,_,ok)
	],

	[
          id ==> camera_error(Person_posit, Last_posit, UpDown),
	  type ==> final,
	  diag_mod => emergency_locate(_,_,_,error)
        ],
%        End of main sequence of situations
%        Start of recover/verify_error situations
	[
          id ==> verify_error_ms(navigation_error, Plac, Mess),
	  type ==> neutral,
	  arcs ==> [
               empty : [say('there is a problem with my map, please fix my current posittion')] => ms(Plac,Mess)
	  ]
        ],

	[
	  id ==> verify_error_fps(navigation_error, Curr_posit),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('an assistance gesture has been detected'),execute('scripts/killvisual.sh'),execute('scripts/personvisual.sh'),say('attempting to get close to the injured person')]
	       	       => get_curr_pos1(down,Curr_posit)
	  ]
	],

	[ 
           id ==> verify_error_fps(lost_user, Curr_posit),
	   type ==> neutral,
	   arcs ==> [
                empty : [say('could you please move closer and see my camera directly please')] => get_curr_pos1(up,Curr_posit)
	    ]
	],

	[
	  id ==> verify_error_fps(Error, Curr_posit),
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/killvisual.sh'),say('let me try to find the person again'),execute('scripts/upfollow.sh')] => fps(gesture,15)
	  ]
	]
%       End of recover/verify_error situations
],
% List of local variables
[
	rem_posit ==> [],
	pos ==> [],
	last_posit ==> '',
	found_posit ==> [],
	camera_error ==> false,
	num_attempts ==> 0
]
).
% End of dialogue
