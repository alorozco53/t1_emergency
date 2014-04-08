diag_mod(emergency_fc(Thing, Obj_locations, Pers_position),
[
        [
          id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [set(not_taken,0),say(['now i will go and bring you ', Thing]),execute('scripts/objectvisual.sh')] => fos(Obj_locations)
	  ]
	],

	[
	  id ==> fos([]),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('i did not found the object let me try to find it again')] => fos(Obj_locations) 
	  ]
	],

	[
	  id ==> fos([H|T]),
	  type ==> recursive,
	  embedded_dm ==> find(object,[Thing],[H|T],[-20,0,20],[-30,0],Mode,[FH|FT],Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in finding the object i will grab it now'),set(not_taken,0)] => ts(FH,left),
	       error : [say('i did not found the object let me try again'),inc(not_taken,Not),
	       (Not > 3 -> Sit = ms(false) | otherwise -> Sit = fos(T))] => Sit
	  ]
	],

	[
	  id ==> fos(Obj_locs),
	  type ==> recursive,
	  embedded_dm ==> find(object,[Thing],Obj_locs,[-20,0,20],[-30,0],Mode,[H|T],Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in finding the object i will grab it now'),set(not_taken,0)] => ts(H,left),
	       error : [say('i did not found the object let me try again'),inc(not_taken,Not),
	       (Not > 3 -> Sit = ms(false) | otherwise -> Sit = fos(Obj_locs))] => Sit
	  ]
	],

	[
	  id ==> ts(Obj_list, Arm),
	  type ==> recursive,
          embedded_dm ==> take(Obj_list,Arm,X,Status),
          arcs ==> [
               success : [say('yoooooooooooooooooooooooopeeeeeeeeeeeeeeeeee i have the object with me')] => ms(true),
               error : [say('let me try again'),inc(not_taken,Not),
	       (Arm = right -> Other = left | otherwise -> Other = right),
	       (Not > 3 -> Sit = ms(false) | otherwise -> Sit = ts(Obj_list,Other))] => Sit
          ]
        ],
	
	[
          id ==> ms(false),
	  type ==> recursive,
	  embedded_dm ==> move(Pers_position,Status),
	  arcs ==> [
               success : [say('im sorry i didnt found or couldnt grab the object'),execute('scripts/killvisual.sh')] => success,
	       error : [say('i will try to reach the person as soon as possible')] => ms(false)
	  ]
	],

	[
	  id ==> ms(true),
	  type ==> recursive,
 	  embedded_dm ==> move(Pers_position,Status),
	  arcs ==> [
	       success : [say('here you have your request')] => dos,
	       error : [say('i will try to reach the person as soon as possible')] => ms(true)
	  ]
	],

	[
	  id ==> dos,
	  type ==> recursive,
          embedded_dm ==> deliver(Thing,Pers_position,handle,Status),
          arcs ==> [
               success : [execute('scripts/killvisual.sh')] => success,
               error : [say('please do take your request')] => dos
          ]
        ],

	% Final situation
	[
          id ==> success,
	  type ==> final
	]
],

% Third argument
[
  not_taken ==> 0
]
).
