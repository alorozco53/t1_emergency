diag_mod(emergency_main,
[

 	[
      		id ==> is,	
      		type ==> neutral,
      		arcs ==> [
        		empty : [execute('scripts/personvisual.sh')] => busca_fuego
      			]
    	],    


	%Busca fuego en la cocina
	[
      		id ==> busca_fuego,
      		type ==> recursive,
      		embedded_dm ==> emergency_catching_fire,
      		arcs ==> [
        		fs : say('I must save all the people in the house') => busca_personas
      			]
    	],
	
	%Busca personas y las rescata
	[
      		id ==> busca_personas,
      		type ==> recursive,
      		embedded_dm ==> emergency_save_people,
      		arcs ==> [
        		fs : say('I finish') => exit
      			]
    	],

	% Salir de la arena
	[  
      		id ==> exit,
      		type ==> recursive,
      		embedded_dm ==> go(exit),
      		arcs ==> [
        			success(X) : [say('I am in the exit')] => fs,
				error(Type,Info) : [say('Error in navigation')] => fs
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

