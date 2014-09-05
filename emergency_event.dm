diag_mod(emergency_event(Sit, Position, Error, Status),
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/inicia_reporte.sh'),set(counter,0),
	                (Sit = up -> Qs = 'hello there can you walk on your own' | otherwise -> Qs = 'hello there can you move your legs')]
	       => as(Qs,yesno)
	  ]
	],

        [
          id ==> as(Prompt,LanguageModel),
          type ==> recursive,
          embedded_dm ==> ask(Prompt, LanguageModel, false, [], Output, Stat),
          arcs ==> [
               success : [(Output = no -> Resp = inmovil | otherwise -> Resp = salio)] => grs(Resp),
               error : [inc(counter,Counter),(Counter =< 4 -> [say('let me try again'),Sit = as(Prompt,LanguageModel)] | otherwise -> Sit = error)] => Sit
          ]
        ],

        [
          id ==> grs(Status_persona),
          type ==> following,
          arcs ==> [
               reporte_generado(p2,get(last_scan, Angulo_Cuello),Status_persona) : [execute('scripts/actualiza_reporte.sh')] => success
          ]
        ],

	% Final situations
	[
	  id ==> success,
	  type ==> final,
          diag_mod ==> emergency_event(_,_,ok)
	],

	[
          id ==> error,
	  type ==> final,
	  diag_mod ==> emergency_event(_,_,no_answer_detected)
        ]
],
% Third argument
[
  counter ==> 0
]
).