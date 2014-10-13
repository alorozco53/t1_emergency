diag_mod(emergency_locate(Places, Locations, Messages, Status),
[
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start of main sequence of defining situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % INITIAL SITUATION
       [
	   id ==> is,
	   type ==> neutral,
	   arcs ==> [
	   	empty : [%apply(register_max_time(0,3,15),
		         set(locations,Locations),execute('scripts/personvisual.sh')] => ms(Places,Messages,das)
	   ]
	],

	% MOVE TO THE DESIRED ROOM SITUATIONS
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
	       success : [say(HM)] => ms(T,TM,NextSit),
	       error : [say('i will try to reach all the desired positions as soon as possible')] => ms([H|T],[HM|TM],NextSit)
	  ]
	],

	% DETECT ACCIDENT SITUATION
	[
          id ==> das,
	  type ==> recursive,
	  embedded_dm ==> scan(person,X,[-10,10],[5,15],detect,Found,false,false,Stat),
	  arcs ==> [
               success : [say('i think everything is still going ok')] => check_time_das(Stat),
	       error : empty => verify_error_das(Stat,fps(gesture,15,Locations))
	  ]
	],

	% FIND INJURED PERSON SITUATIONS
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
	  embedded_dm ==> move([FirstLocation],Stat),
	  arcs ==> [
               success : [say('looking for any sort of signal from the injured person')] => scs(Kind,Mode,FirstLocation,RemLocations),
	       error : empty => verify_error_fps(Stat,Kind,Mode,FirstLocation,RemLocations)
	  ]
        ],
	
	[
          id ==> scs(Kind, Mode, CurrLocation, RemLocations),
	  type ==> recursive,
	  embedded_dm ==> scan(Kind,X,[-10,10],[0,-15],Mode,Found,false,false,Stat),
	  arcs ==> [
	       success : [say('i succeeded in locating the injured person'),execute('scripts/killvisual.sh')] => get_curr_pos2(up,CurrLocation),
	       error : [get(counter2,Counter),(Counter < 3 -> Sit = verify_error_fps(Stat,Kind,Mode,CurrLocation,RemLocations) |
	                otherwise -> [say('i could not find anyone if you hear me please approach me'),Sit = get_curr_pos1(up,CurrLocation)]),
			inc(counter2,Counter)] => Sit
	  ]
	],

	% APPROACH TO THE INJURED PERSON SITUATION
	[
	  id ==> approach_sit(Pos,[X,Y,Z]),
	  type ==> recursive,
	  embedded_dm ==> find(person,W,[turn=>(10),turn=>(-10)],[-10,10],[0,-15],detect_with_approach,Found,Rem_Posit,true,true,true,Stat),
	  arcs ==> [
	       success : [execute('scripts/killvisual.sh')] => get_curr_pos2(Pos,[X,Y,Z]),
	       error : [say('could you move closer to me please')] => verify_error_appsit(Stat,Pos,[X,Y,Z])
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
      	       pos(X,Y,Z) : [(camera_error = true -> Sit = error([X,Y,Z],Last_posit,Pos) | otherwise ->
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
        % MS RECOVERY SITUATION
	[
          id ==> verify_error_ms(navigation_error, Plac, Mess),
	  type ==> neutral,
	  arcs ==> [
               empty : [say('there is a problem with my map, please fix my current position')] => ms(Plac,Mess)
	  ]
        ],

	% DAS RECOVERY SITUATIONS
	[ 
           id ==> verify_error_das(lost_user, _),
	   type ==> neutral,
	   arcs ==> [
                empty : empty => das
	    ]
	],

	[
           id ==> verify_error_das(camera_error, _),
	   type ==> neutral,
	   arcs ==> [
                empty : [say('there is a problem with my camera i wil continue without using it'),
		         execute('scripts/killvisual.sh'),set(camera_error,true)] => get_curr_pos2(up,[])
	   ]
       ],

        [
	   id ==> verify_error_das(Error, NextSit),
	   type ==> neutral,
	   arcs ==> [
	       empty : [say('alright an accident has just occurred'),execute('scripts/killvisual.sh'),execute('scripts/upfollow.sh')] => NextSit
	   ]
        ],

	% FPS RECOVERY SITUATIONS
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
                empty : [say('there is a problem with my camera i wil continue without using it'),set(camera_error,true)] => get_curr_pos2(down,[])
	   ]
       ],

       [
	  id ==> verify_error_fps(Error, Kind, Mode, Curr_posit, RemLocations),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('let me try to find the person again'),filter(Curr_posit,RemLocations,NewLocs),set(locations,NewLocs)] => fps(Kind,Mode,NewLocs)
	  ]
       ],

       % APPROACH_SIT RECOVERY SITUATIONS
       [
          id ==> verify_error_appsit(camera_error, Pos, [X,Y,Z]),
	  type ==> neutral,
	  arcs ==> [
               empty : [say('there is a problem with my camera i wil continue without using it'),
	                set(camera_error,true),execute('scripts/killvisual.sh')] => get_curr_pos2(Pos,[X,Y,Z])
	  ]
       ],

       [
         id ==> verify_error_appsit(navigation_error, Pos, [X,Y,Z]),
	 type ==> neutral,
	 arcs ==> [
	      empty : [say('alright'),execute('scripts/killvisual.sh')] => get_curr_pos2(Pos,[X,Y,Z])
	 ]
       ],

       [ 
          id ==> verify_error_appsit(lost_user, Pos, [X,Y,Z]),
	  type ==> neutral,
	  arcs ==> [
               empty : [say('could you please move closer and see my camera directly please'),execute('scripts/killvisual.sh')] => get_curr_pos2(Pos,[X,Y,Z])
	  ]
       ],

       [
	  id ==> verify_error_appsit(Error, Pos, [X,Y,Z]),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('trying to get closer to the injured person again if you hear me please stare at my camera')] => appsit(Pos,[X,Y,Z])
	  ]
       ],
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of recovery/verify_error situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Time constraint situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       [
          id ==> check_time_das(Stat),
	  type ==> neutral,
	  arcs ==> [
               %empty : [(apply(fetch_time_over(_,_)) -> Sit = das | otherwise -> Sit = fps(gesture,15,Locations))] => Sit
                empty : [get(counter1,Counter),(Counter < 5 -> Sit = das | otherwise ->
		         [Sit = verify_error_das(Stat,fps(gesture,15,Locations)),say('maybe an accident has occured')]),
			 inc(counter1,Counter)] => Sit
	  ]
       ]
],
% List of local variables
[
	camera_error ==> false,
	num_attempts ==> 0,
	counter1 ==> 0,
	counter2 ==> 0,
	locations ==> []
] 
).
% End of dialogue