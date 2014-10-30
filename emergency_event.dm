diag_mod(emergency_event(Time, Sit, Position, Error, Status),
[
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [execute('scripts/inicia_reporte.sh'),apply(generate_time_limit_em(Time,LimitTime),LimitTime),set(limit_time,LimitTime),
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
               error : [get(limit_time,LimTime),apply(verify_ask_em(Stat,as(Prompt,LanguageModel),LimTime,RS,NS),[RS,NS])
                        say(RS)] => NS
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
	  id ==> fs(time_is_up),
	  type ==> neutral,
	  arcs ==> [
	       empty : say('my time is up asking you about your health') => error
	  ]
	],

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
  counter ==> 0,
  limit_time ==> 0
]
).
