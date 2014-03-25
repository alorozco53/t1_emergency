diag_mod(emergency_event(Sit, Position),
[

	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [(Sit = up -> Qs = 'hello there can you walk on your own'  | otherwise -> Qs = 'hello there can you move your legs' )] => as(Qs,yesno)
	  ]
	],

        [
          id ==> as(Prompt,LanguageModel),
          type ==> recursive,
          embedded_dm ==> ask(Prompt, LanguageModel, false, [], Output, Status),
          arcs ==> [
               ok : empty => success(Output),
               error : [say('let me try again ')] => as(Prompt,LanguageModel)
          ]
        ],

	[
	  id ==> success(Output),
	  type ==> final
	]
],
% Second argument
[
]
).
