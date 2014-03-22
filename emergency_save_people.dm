diag_mod(emergency_save_people,
[

	
	%Aqui se define por UNICA vez la lista de puntos en la que se realizará la busqueda de personas	
	[
		id ==> is,
      		type ==> neutral,
      		arcs ==> [
        		empty : [execute('scripts/inicia_reporte.sh')] => ve_al_punto([p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p9,p8,p7,p6,p5,p4,p3,p2,p1])
      		]
    	],

	% Se mueve al siguiente punto de la lista (Punto_siguiente), la lista se pasa completa a la siguiente situacion
	% para mantener informacion sobre la posición actual

	%Caso base
	[  
      		id ==> ve_al_punto([]),
      		type ==> recursive,
      		embedded_dm ==> go(exit),
      		arcs ==> [
        			success(X) : [say('I finished. I will go to the exit')] => fs,
				error(Type,Info) : [say('I finished. I will go to the exit')] => fs
      			]
    	],


	%Caso inductivo
	[  
      		id ==> ve_al_punto([Punto_siguiente|Resto]),
      		type ==> recursive,
      		embedded_dm ==> go(Punto_siguiente),
      		arcs ==> [
        			success(X) : [say('I will search people in this point'), set(find_currpos,Punto_siguiente)] => rb([Punto_siguiente|Resto]),
				error(Type,Info) : [say('I will search people in this point')] => rb([Punto_siguiente|Resto])
      			]
    	],

	% Buscar una persona
	% L es la lista de puntos a buscar, y R son los puntos restantes en donde no se ha buscado
	% Recordar que md_find empieza a buscar en la Posicion_actual del robot y luego se va al primer punto de L,
	% por eso no es necesario suministrar la Posicion_actual a md_find.
	% Al pasar a la siguiente situacion de entrevista (re), se envía el resto de los puntos, y la posicion actual	
	[
      		id ==> rb([Posicion_actual|L]),
      		type ==> recursive,
      		embedded_dm ==> md_find(person, _, L, [left,right], [0,20], detect, _, R, Status),
      		arcs ==> [
        		fs_found : [take_photo(Result),say('I found a person'),tilth(0),tiltv(0)] => re(R,Posicion_actual),
			fs_error : say('I had an error and i will try again') => check([Posicion_actual|L],Status)
      			]
    	],
	
	% Manejo del posible error de find
	[
		id ==> check(_, not_detected),
      		type ==> neutral,
      		arcs ==> [
        		empty : empty => fs
      		]
    	],

	% Manejo del posible error de find
	[
		id ==> check([Posicion_actual|L], error(Ed,Er)),
      		type ==> neutral,
      		arcs ==> [
        		empty : empty => rb([Posicion_actual|L]) 
      		]
    	],

	% Entrevistar a la persona encontrada
	% La lista actual fluye hacia las siguientes situaciones, junto con la posicion actual y el status de la persona
	[
      		id ==> re(L,Posicion_actual),
      		type ==> recursive,
      		embedded_dm ==> emergency_interview,
      		arcs ==> [
        		inmovil_continuar_busqueda : say('I will search for more people') => decide_siguiente_accion(L,Posicion_actual,inmovil),
	                salio_continuar_busqueda : say('I will search for more people') => decide_siguiente_accion(L,Posicion_actual,salio),
			guiar_a_la_salida : say('Follow me please') => rg(L,Posicion_actual)
      			]
    	],
	
	% Guiar a la salida, al terminar se mueve al siguiente punto 
	[
      		id ==> rg(L,Posicion_actual),
      		type ==> recursive,
      		embedded_dm ==> emergency_guide,
      		arcs ==> [
        		fs : empty => decide_siguiente_accion(L,Posicion_actual,guiado)
      			]
    	],
	
	%Situacion intermedia en la que se decide a que situación pasar
	%Como expectativa espera a que se agregue al reporte los datos de la persona que vio
	%El reporte incluye la posición actual de la persona, el ángulo horizontal del cuello del robot, el status de la persona y el numero de persona
	%Se cuentan el numero de personas que se han visto 
	%y se toma una decisión: terminar la tarea o ir al siguiente punto de busqueda	
	%Si no se cumple la condición, C>numero_personas, se va al siguiente punto de busqueda,
	%Si se cumple la condición, termina
	[
		id ==> decide_siguiente_accion(L,Posicion_actual,Status_persona),
      		type ==> following,
		arcs ==> [
        		reporte_generado(get(find_currpos,CurrentPos),get(last_scan, Angulo_Cuello),Status_persona) : [execute('scripts/actualiza_reporte.sh'),inc(count,C)] => apply(when(If,TrueVal,FalseVal),[C>=6,fs,ve_al_punto(L)])
			]
    	],

	[
      		id ==> fs,
      		type ==> final
    	]


  ],
  % Second argument: list of local variables
  [
    	count ==> 0
  ]
).	
