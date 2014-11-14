diag_mod(emergency_fc(Time, Thing, Obj_locations, Pers_position, Status),
[
        [
          id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [apply(generate_time_limit_em(Time,LimitTime),LimitTime),set(limit_time,LimitTime),
		        set(locations,Locations),say(['now i will go and bring you ',Thing]),
			execute('scripts/objectvisual.sh')] => fos(Obj_locations)
	  ]
	],

	[
	  id ==> fos([]),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('i did not found the object let me try to find it again'),get(limit_time,LT),
	                apply(verify_time_em(LT),[TrueFalse]),(TrueFalse = True -> Sit = fos(Obj_locations) |
		                                               otherwise -> Sit = fs(time_is_up))] => Sit
	  ]
	],

	[
	  id ==> fos([H|T]),
	  type ==> recursive,
	  embedded_dm ==> find(object,[Thing],[H|T],[-20,0,20],[-30,0],Mode,[FH|FT],Remaining_Positions,false,false,false,Stat),
	  arcs ==> [
	       success : [get(limit_time,LimTime),apply(verify_find_em(Stat,ts(FH,right),LimTime,RS,NS),[RS,NS]),
			  say([RS,'i succeeded in finding the object i will grab it now']),set(not_taken,0)] => NS,
	       error : [get(limit_time,LimTime),apply(verify_find_em(Stat,fos([H|T]),LimTime,RS,NS),[RS,NS]),
			say([RS,'i did not found the object let me try again'])] => NS
	  ]
	],

	[
	  id ==> fos(Obj_locs),
	  type ==> recursive,
	  embedded_dm ==> find(object,[Thing],Obj_locs,[-20,0,20],[-30,0],Mode,[H|T],Remaining_Positions,false,false,false,Stat),
	  arcs ==> [
	       success : [get(limit_time,LimTime),apply(verify_find_em(Stat,ts(FH,right),LimTime,RS,NS),[RS,NS]),
			  say([RS,'i succeeded in finding the object i will grab it now']),set(not_taken,0)] => NS,
	       error : [get(limit_time,LimTime),apply(verify_find_em(Stat,fos(Obj_locs),LimTime,RS,NS),[RS,NS]),
			say([RS,'i did not found the object let me try again']),] => NS
	  ]
	],

	[
	  id ==> ts(Obj_list, Arm),
	  type ==> recursive,
          embedded_dm ==> take(Obj_list,Arm,X,Stat),
          arcs ==> [
               success : [say('yoooooooooooooooooooooooopeeeeeeeeeeeeeeeeee i have the object with me')] => ms,
               error : [get(limit_time,LimTime),apply(verify_take_em(Stat,Obj_list,Arm,LimTime,RS,NS),[RS,NS]),
			say(RS)] => NS
          ]
        ],
	
	[
          id ==> ms(false),
	  type ==> recursive,
	  embedded_dm ==> move(Pers_position,Stat),
	  arcs ==> [
               success : [say('im sorry i didnt found or couldnt grab the object'),execute('scripts/killvisual.sh')] => success,
	       error : [say('i will try to reach the person as soon as possible')] => ms(false)
	  ]
	],

	[
	  id ==> ms(true),
	  type ==> recursive,
 	  embedded_dm ==> move(Pers_position,Stat),
	  arcs ==> [
	       success : [say('here you have your request')] => dos,
	       error : [say('i will try to reach the person as soon as possible')] => ms(true)
	  ]
	],

	[
	  id ==> dos,
	  type ==> recursive,
          embedded_dm ==> deliver(Thing,Pers_position,handle,Stat),
          arcs ==> [
               success : [execute('scripts/killvisual.sh')] => success,
               error : [say('please do take your request')] => dos
          ]
        ],

	% Final situation
	[
          id ==> success,
	  type ==> final,
	  diag_mod ==> emergency_fc(_,_,_,ok)
	]
],

% Third argument
[
  not_taken ==> 0,
  limit_time ==> 0
]
).