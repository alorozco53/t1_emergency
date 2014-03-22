diag_mod(emergency_guide,
[
	[
		id ==> is,
      		type ==> neutral,
      		arcs ==> [
        		empty : empty  => go_exit
      		]
    	],

	% Ir a la salida
	[  
      		id ==> go_exit,
      		type ==> recursive,
      		embedded_dm ==> go(nearexit),
      		arcs ==> [
        			success(X) : [say('This is the exit. I will return to search more people')] => fs,
				error(Type,Info) : empty => fs
      			]
    	],

	[
     		id ==> fs,
      		type ==> final
    	]


  ],
  % Second argument: list of local variables
  [
    
  ]
).	
