diag_mod(emergency_person(LanguageToFetch, Obj_locations, Pers_position, Error, Status),
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
          embedded_dm ==> ask(Prompt, LanguageModel, false, [], Output, Stat),
          arcs ==> [
               success : [(LanguageModel = yesno -> Sit = as('so what would you like me to bring you',LanguageToFetch)
	       	       	  | otherwise -> Sit = fetch_carry(Output,Error))]
	       		 => Sit,
               error : [say('let me try again')] => as(Prompt,LanguageModel)
          ]
        ],

	[
	  id ==> fetch_carry(Thing,false),
	  type ==> recursive,
	  embedded_dm ==> emergency_fc(Thing,Obj_locations,Pers_position,Stat),
	  arcs ==> [
	       success : empty => success
	  ]
	],

	[
          id ==> fetch_carry(_,true),
	  type ==> neutral,
	  arcs ==> [
               empty : [say('i cannot fetch your request since my camera is fucked')] => success
	  ]
        ],

	% Final situation
	[
	  id ==> success,
	  type ==> final,
          diag_mod ==> emergency_person(_,_,_,ok)
	]
],

% Third argument
[
]
).