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
	  embedded_dm ==> find(object,Thing,[H|T],[-20,0,20],[-30,0,30],Mode,Found_obj,Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in finding the object i will grab it now')] => ts(right),
	       error : [say('it is not here')] => fos(T)
	  ]
	],

	[
	  id ==> fos(Obj_locs),
	  type ==> recursive,
	  embedded_dm ==> find(object,Thing,Obj_locs,[-20,0,20],[-30,0,30],Mode,Found_obj,Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       success : [say('i succeeded in finding the object i will grab it now')] => ts(right),
	       error : [say('i did not found the object let me try again')] => fos(Obj_locations)
	  ]
	],

	[
	  id ==> ts(Arm),
	  type ==> recursive,
          embedded_dm ==> take(Thing,Arm,X,Status),
          arcs ==> [
               success : [say('yes i have it with me')] => ms,
               error : [say('let me try again'),(Arm = right -> Other = left | otherwise -> Other = right)] => ts(Other)
          ]
        ],

	[
	  id ==> ms,
	  type ==> recursive,
	  embedded_dm ==> move(Pers_posit,Status),
	  arcs ==> [
	       success : [say('here you have your request')] => dos,
	       error : [say('i will try to reach the person as soon as possible')] => ms
	  ]
	],

	[
	  id ==> dos,
	  type ==> recursive,
          embedded_dm ==> deliver(Thing,Pers_posit,handle,Status),
          arcs ==> [
               success : [execute('scripts/killvisual.sh')] => success,
               error : [say('please try to take your request once more')] => dos
          ]
        ],

	% Final situation
	[
	  id ==> success,
	  type ==> empty
	]
],

% Second argument
[
]
).
