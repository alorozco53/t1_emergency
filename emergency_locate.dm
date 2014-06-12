diag_mod(emergency_locate(Places, Locations, Messages, Status),
[
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start of main sequence of defining situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       [
	   id ==> is,
	   type ==> neutral,
	   arcs ==> [
	   	empty : [set(locations,Locations),execute('scripts/upfollow.sh')] => ms(Places,Messages,fps(gesture,15,Locations))
	   ]
	],

	[
	  id ==> ms([], _, NextSit),
	  type ==> neutral,
	  arcs ==> [
	       empty : empty => NextSit
	  ]
	],

	[
	  id ==> ms([H|T], [HM|TM], NextSit),
	  type ==> recursive,
	  embedded_dm ==> move(H,Status),
	  arcs ==> [
	       success : [say(HM)] => ms(T,TM),
	       error : [say('i will try to reach all the desired positions as soon as possible')] => ms([H|T],[HM|TM],NextSit)
	  ]
	],

	[
          id ==> fps(_, _, []),
	  type ==> neutral,
	  arcs ==> [
               empty : [say('i couldnt find the injured person let me try again'),get(locations,Locs)] => fps(gesture,15,Locs)
	   ]
        ],

	[
	  id ==> fps(Kind, Mode, [FirstLocation|RemLocations]),
	  type ==> recursive,
	  embedded_dm ==> move([FirstLocation],Status),
	  arcs ==> [
               empty : [say('looking for the injured person')] => scs(Kind,Mode,FirstLocation,RemLocations),
	       error : empty => verify_error_fps(Status,Kind,Mode,FirstLocation,RemLocations)
	  ]
        ],
	
	[
          id ==> scs(Kind, Mode, CurrLocation, RemLocations)
	  type ==> recursive,
	  embedded_dm ==> scan(Kind,X,[-10,10],[0,-15],Mode,Found,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in locating the injured person'),execute('scripts/killvisual.sh')] => get_curr_pos2(up,CurrLocation),
	       error : empty => verify_error_fps(Status,Kind,Mode,CurrLocation,RemLocations)
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
	% Save current position
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
      	       pos(X,Y,Z) : [(camera_error = true -> Sit = error([X,Y,Z],Last_posit,Pos) |
	                     (Pos = up -> Sit = up([X,Y,Z],Last_posit) | otherwise -> Sit = down([X,Y,Z],Last_posit)))] => Sit
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
          id ==> error(Person_posit, Last_posit, UpDown),
	  type ==> final,
	  diag_mod => emergency_locate(_,_,_,camera_error)
        ],
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of main sequence of situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start of recovery/verify_error situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	[
          id ==> verify_error_ms(navigation_error, Plac, Mess),
	  type ==> neutral,
	  arcs ==> [
               empty : [say('there is a problem with my map, please fix my current position')] => ms(Plac,Mess)
	  ]
        ],

	[
	  id ==> verify_error_fps(navigation_error, _, _, Curr_posit, _),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('my robotic intuition tells me the injured person is blocking my way'),execute('scripts/killvisual.sh'),
	                execute('scripts/personvisual.sh'),say('attempting to get closer to the injured person')] => get_curr_pos1(down,Curr_posit)
	  ]
	],

	[ 
           id ==> verify_error_fps(lost_user, _, _, Curr_posit, _),
	   type ==> neutral,
	   arcs ==> [
                empty : [say('could you please move closer and see my camera directly please'),execute('scripts/killvisual.sh')] => get_curr_pos1(up,Curr_posit)
	    ]
	],

	[
           id ==> verify_error_fps(camera_error, _, _, Curr_posit, _),
	   type ==> neutral,
	   arcs ==> [
                empty : [say('there is a problem with my camera i wil continue without using it'),set(camera_error,true)] => get_curr_pos1(up,Curr_posit)
	   ]
       ],

       [
	  id ==> verify_error_fps(Error, Kind, Mode, Curr_posit, RemLocations),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('let me try to find the person again'),filter(Curr_posit,Locations,NewLocs),set(locations,NewLocs)] => fps(Kind,Mode,NewLocs)
	  ]
       ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of recovery/verify_error situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
],
% List of local variables
[
	camera_error ==> false,
	num_attempts ==> 0,
	locations ==> []
]
).
% End of dialogue
