diag_mod(emergency_event(Sit, Position, Status),
[

	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/inicia_reporte.sh'),
	                (Sit = up -> Qs = 'hello there can you walk on your own'  | otherwise -> Qs = 'hello there can you move your legs')]
	       => as(Qs,yesno)
	  ]
	],

        [
          id ==> as(Prompt,LanguageModel),
          type ==> recursive,
          embedded_dm ==> ask(Prompt, LanguageModel, false, [], Output, Status),
          arcs ==> [
               success : [(Output = no -> Resp = inmovil | otherwise -> Resp = salio)] => grs(Resp),
               error : [say('let me try again')] => as(Prompt,LanguageModel)
          ]
        ],

        [
          id ==> grs(Status_persona),
          type ==> following,
          arcs ==> [
               reporte_generado(p2,get(last_scan, Angulo_Cuello),Status_persona) : [execute('scripts/actualiza_reporte.sh')] => success
          ]
        ],

	[
	  id ==> success,
	  type ==> final
          diag_mod ==> emergency_event(_,_,ok)
	]
],
% Third argument
[
]
).
