diag_mod(emergency_fc(Thing, Obj_locations, Pers_position),
[
        [
          id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [say(['now i will go and bring you ', Thing]),execute('scripts/objectvisual.sh')] => fos(Obj_locations)
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
	  embedded_dm ==> find(object,[Thing],[H|T],[-20,0,20],[0,30],Mode,[FH|FT],Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in finding the object i will grab it now')] => ts(FH,left),
	       error : [say('it is not here')] => fos(T)
	  ]
	],

	[
	  id ==> fos(Obj_locs),
	  type ==> recursive,
	  embedded_dm ==> find(object,[Thing],Obj_locs,[-20,0,20],[0,30],Mode,[H|T],Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in finding the object i will grab it now')] => ts(H,left),
	       error : [say('i did not found the object let me try again')] => fos(Obj_locations)
	  ]
	],

	[
	  id ==> ts(Obj_list, Arm),
	  type ==> recursive,
          embedded_dm ==> take(Obj_list,Arm,X,Status),
          arcs ==> [
               success : [say('ooooooeeeeee ooooooooeeeee oooooeeee oooeee oe oe oe oooooeeee oooeeee oe oooooooeee')] => ms,
               error : [say('let me try again'),(Arm = right -> Other = left | otherwise -> Other = right)] => ts(Obj_list,Other)
          ]
        ],

	[
	  id ==> ms,
	  type ==> recursive,
	  embedded_dm ==> move(Pers_position,Status),
	  arcs ==> [
	       success : [say('here you have your request')] => dos,
	       error : [say('i will try to reach the person as soon as possible')] => ms
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
]
).