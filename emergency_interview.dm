diag_mod(emergency_interview,
[
	[
		id ==> is,
      		type ==> neutral,
      		arcs ==> [
        	empty : empty => ask1('There is fire in the kitchen. Can you move by yourself')
      		]
    	],

	[
      		id ==> ask1(Message),	
      		type ==> recursive,
     		embedded_dm ==> ask(Message,okno,Result),
      		arcs ==> [
        		success(understood_ok) : empty => ask2('Do you know the way to the exit'),
        		success(understood_no) : [say('I have registered your position. Wait here. I will look for help')] => inmovil_continuar_busqueda
      			]
    	],

	[
      		id ==> ask2(Message),	
      		type ==> recursive,
     		embedded_dm ==> ask(Message,okno,Result),
      		arcs ==> [
        		success(understood_ok) : [say('Leave the house quickly. Be careful')] => salio_continuar_busqueda,
        		success(understood_no) : [say('I will take you to the exit')] => guiar_a_la_salida
      			]
    	],

	[
     		id ==> inmovil_continuar_busqueda,
      		type ==> final
    	],

	[
     		id ==> salio_continuar_busqueda,
      		type ==> final
    	],

	[
     		id ==> guiar_a_la_salida,
      		type ==> final
    	]


  ],
  % Second argument: list of local variables
  [
    
  ]
).	
