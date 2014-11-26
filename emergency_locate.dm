diag_mod(emergency_locate(Time, Places, Locations, Messages, Status),
[
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start of main sequence of defining situations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % INITIAL SITUATION
       [
	   id ==> is,
	   type ==> neutral,
	   arcs ==> [
	   	empty : [apply(generate_limit_time_em(T,L),[Time,LimitTime]),set(limit_time,LimitTime),
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
	  embedded_dm ==> move(H,Stat),
	  arcs ==> [
	       success : [get(limit_time,LimTime),apply(verify_move_em(A,B,C,D,E),[Stat,ms(T,TM,NextSit),LimTime,RS,NS]),
			  say(RS)] => NS,
	       error : [get(limit_time,LimTime),apply(verify_move_em(A,B,C,D,E),[Stat,ms([H|T],[HM|TM],NextSit),LimTime,RS,NS]),
			  say([RS,'i will try to reach the desired position as soon as possible'])] => NS
	  ]
	],

	% DETECT ACCIDENT SITUATION
	[
          id ==> das,
	  type ==> recursive,
	  embedded_dm ==> scan(person,X,[-10,10],[5,15],detect,Found,false,false,Stat),
	  arcs ==> [
               success : [get(limit_time,LimTime),apply(verify_scan_em(A,B,C,D,E),[Stat,das,LimTime,RS,NS]),
			  say([RS,'i think everything is still going ok'])] => NS,
	       error : [get(limit_time,LimTime),apply(verify_scan_em(A,B,C,D,E),[Stat,fps(gesture,15,Locations),LimTime,RS,NS]),
			  say(RS)] => NS
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
               success : [get(limit_time,LimTime),apply(verify_move_em(A,B,C,D,E),[Stat,scs(Kind,Mode,FirstLocation,RemLocations),LimTime,RS,NS]),
			  say([RS,'looking for any sort of signal from the injured person'])] => NS,
	       error : [get(limit_time,LimTime),apply(verify_move_em(A,B,C,D,E),[Stat,get_curr_pos1(down,FirstLocation),LimTime,RS,NS]),
			say([RS,'my robotic intution tells me the injured person is just in front of me'])] => NS
	  ]
        ],
	
	[
          id ==> scs(Kind, Mode, CurrLocation, RemLocations),
	  type ==> recursive,
	  embedded_dm ==> scan(Kind,X,[-10,10],[0,-15],Mode,Found,false,false,Stat),
	  arcs ==> [
	       success : [get(limit_time,LimTime),apply(verify_scan_em(A,B,C,D,E),[Stat,get_curr_pos2(up,CurrLocation),LimTime,RS,NS]),
			  say([RS,'i succeeded in locating the injured person']),execute('scripts/killvisual.sh')] => NS,
	       error : [get(limit_time,LimTime),apply(verify_scan_em(A,B,C,D,E),[Stat,scs(Kind,Mode,CurrLocation,RemLocations),LimTime,RS,NS]),
			say([RS,'i succeeded in locating the injured person'])] => NS
	  ]
	],

	% APPROACH TO THE INJURED PERSON SITUATION
	[
	  id ==> approach_sit(Pos,[X,Y,Z]),
	  type ==> recursive,
	  embedded_dm ==> find(person,W,[turn=>(10),turn=>(-10)],[-10,10],[0,-15],detect_with_approach,Found,Rem_Posit,true,true,true,Stat),
	  arcs ==> [
	       success : [get(limit_time,LimTime),apply(verify_find_em(A,B,C,D,E),[Stat,get_curr_pos2(Pos,[X,Y,Z]),LimTime,RS,NS]),
			  say(RS),execute('scripts/killvisual.sh')] => NS,
	       error : [get(limit_time,LimTime),apply(verify_find_em(A,B,C,D,E),[Stat,get_curr_pos2(Pos,[X,Y,Z]),LimTime,RS,NS]),
			say([RS,'could you move closer to me please'])] => NS
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
      	       pos(X,Y,Z) : [(Pos = up -> Sit = up([X,Y,Z],Last_posit) | otherwise -> Sit = down([X,Y,Z],Last_posit))] => Sit
	  ]
  	],

	% Final situations
	[
	  id ==> fs(camera_error),
	  type ==> positionxyz,
	  arcs ==> [
	       pos(X,Y,Z) : say('since my camera is no longer working please keep close to my microphone') => error([X,Y,Z],[X,Y,Z],up)
	  ]
	],

	[
	  id ==> fs(time_is_up),
	  type ==> positionxyz,
	  arcs ==> [
	       pos(X,Y,Z) : say('my time is up please stand in front of me') => up([X,Y,Z],[X,Y,Z])
	  ]
	],

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
        ]
],
% List of local variables
[
	camera_error ==> false,
	num_attempts ==> 0,
	counter1 ==> 0,
	counter2 ==> 0,
	locations ==> [],
	limit_time ==> 0
] 
).
% End of dialogue
