diag_mod(emergency_person(LanguageToFetch, Obj_locations, Pers_position, Status),
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : empty => as('is a friend of yours going to come to help you',yesno)
	  ]
	],

        [
          id ==> as(Prompt,LanguageModel),
          type ==> recursive,
          embedded_dm ==> ask(Prompt, LanguageModel, false, [], Output, Status),
          arcs ==> [
               success : [(LanguageModel = yesno -> Sit = as('so what would you like me to bring you',LanguageToFetch)
	       	       	  | otherwise -> Sit = fetch_carry(Output))]
	       		 => Sit,
               error : [say('let me try again ')] => as(Prompt,LanguageModel)
          ]
        ],

	[
	  id ==> fetch_carry(Thing),
	  type ==> recursive,
	  embedded_dm ==> emergency_fc(Thing,Obj_locations,Pers_position,Status),
	  arcs ==> [
	       success : empty => success
	  ]
	],

	% Final situation
	[
	  id ==> success,
	  type ==> final
          diag_mod ==> emergency_person(_,_,_,ok)
	]
],

% Third argument
[
]
).