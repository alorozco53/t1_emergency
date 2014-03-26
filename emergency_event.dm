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
               success : [(Output = yes -> Resp = inmovil | otherwise -> Resp = salio)] => grs(Resp),
               error : [say('let me try again ')] => as(Prompt,LanguageModel)
          ]
        ],

        [
          id ==> grs(Status_persona),
          type ==> following,
          arcs ==> [
               reporte_generado(Position,get(last_scan, Angulo_Cuello),Status_persona) : [execute('scripts/actualiza_reporte.sh')] => success
          ]
        ],

	[
	  id ==> success,
	  type ==> final
	]
],
% Second argument
[
]
).