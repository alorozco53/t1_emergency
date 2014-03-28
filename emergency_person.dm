diag_mod(emergency_person(LanguageToFetch, Obj_Locations, Pers_position),
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
	       		 => fetch_carry(Output),
               error : [say('let me try again ')] => as(Prompt,LanguageModel)
          ]
        ],

	[
	  id ==> fetch_carry(Thing),
	  type ==> recursive,
	  embedded_dm ==> emergency_fc(Thing,Obj_locations,Pers_position),
	  arcs ==> [
	       X : empty => success
	  ]
	],

	% Final situation
	[
	  id ==> success,
	  type ==> final
	]
],

% Second argument
[
]
).
