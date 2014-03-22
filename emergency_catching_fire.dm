diag_mod(emergency_catching_fire,
[
	[
		id ==> is,
      		type ==> neutral,
      		arcs ==> [
        	empty : [say('I will go to the kitchen')] => go_kitchen    
			]  		
    	],

	% Ir a la cocina
	[  
      		id ==> go_kitchen,
      		type ==> recursive,
      		embedded_dm ==> go(stove),
      		arcs ==> [
        			success(X) : [say('I am in the kitchen'),sleep(60),say('I hear the alarm of fire')] => fs,
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
