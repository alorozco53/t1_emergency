diag_mod(emergency_rescue(Entry_posit, Pers_posit),
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/personvisual.sh')] => fps
	  ]
	],

	[
	  id ==> fps,
	  type ==> recursive,
	  embedded_dm ==> find(person,X,Entry_posit,[-20,0,20],[-30,0,30],detect,[H|T],Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       success : [say('hello i will guide you to the injured persons position')] => gps,
	       error : [say('let me try to find the human aid again')] => fps
	  ]
	],






        [
          id ==> success,
          type ==> final
        ]

],
% List of local variables
[
]
).
% End of dialogue
