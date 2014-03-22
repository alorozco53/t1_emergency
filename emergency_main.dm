diag_mod(emergency_main,
[
	[
	   id ==> is,
	   type ==> neutral,
	   arcs ==> [
	   	empty : [initSpeech,execute('scripts/follow_nav.sh'), set(room_entrance,p1)]
		      	 => ms([door,room_entrance],['hello i am golem and i will go to the rescue','ok i just arrived to the room'],1)
	   ]
	],

	[
	  id ==> ms([Place],[Message],Stage),
	  type ==> recursive,
	  embedded_dm ==> move(Place,Status),
	  arcs ==> [
	       success : [say(Message)] => arrived_to(Stage),
	       error : empty => verify_error([Place],[Message],Status,Stage)	
	  ]
	],

	[
	  id ==> ms([H|T],[HM|TM],Stage),
	  type ==> recursive,
	  embedded_dm ==> move(H,Status),
	  arcs ==> [
	       success : [say(HM)] => ms(T,TM,Stage),
	       error : empty => verify_error([H|T],[HM|TM],Status,Stage)
	  ]
	],
	
	[
	  id ==> verify_error([H|T],[HM|TM],Error,1),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('let me try to reach the desired position again')] => ms([H|T],[HM|TM],Stage)
	  ]
	],
	
	[
	  id ==> arrived_to(1),
   	  type ==> positionxyz,
    	  arcs ==> [
      	       pos(X,Y,Z) : [set(room_entrance,[X,Y,Z]), sleep(15), say('ooooeee ooooeeee ooooeee ooooeeee oooooeeee')]
	       => fs(gesture,W,get(lista,Lista),[-20,0,20],[-30,0,30],3,Found_Objects,Remaining_Positions,yes,false,false,Status,'hello there nice to meet you',2)
	  ]
	],

	[
	  id ==> fs(Kind,Entity,Places,Orientations,Tilts,Mode,Found_Objects,Remaining_Positions,Scan_First,Tilt_First,See_First,Status,Message,Stage),
	  type ==> recursive,
	  embedded_dm ==> find(Kind,Entity,Places,Orientations,Tilts,Mode,Found_Objects,Remaining_Positions,Scan_First,Tilt_First,See_First,Status),
	  arcs ==> [
	      success : [say(Message)] => arrived_to(Stage),
	      error : empty => verify_error(Status,Message,Stage)
	  ]
	],

	[
	  id ==> verify_error(Error,Message,3),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('I will try to reach the request as soon as possible')] 
	       => fs(object, Thing, [p1],[-20,0,20],[-30,0,30],food,Found_object ,Remaining_Positions,false,false,false,Status,'i found it',3)
	  ]
	],

	[
	  id ==> verify_error(navigation_error,Message,Stage),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say(Message)] => arrived_to(Stage)
	  ]
	],

	[
	  id ==> verify_error(Error,Message,Stage),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('I will try to reach the request as soon as possible')] 
	       => fs(gesture,X,get(lista,Lista),[-20,0,20],[-30,0,30],3,Found_Objects,Remaining_Positions,yes,false,false,Status,'hello there nice to meet you',2)
	  ]
	],

	[
	  id ==> arrived_to(2),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('how are you what happened'), sleep(7)] => get_curr_pos
	  ]
	],

	% Guardar posicion actual
	[  
    	  id ==> get_curr_pos,
   	  type ==> positionxyz,
    	  arcs ==> [
      	       pos(X,Y,Z) : [set(pers_posit,[X,Y,Z])] => as('would you like me to call a friend of yours',yesno)
    	  ]
  	],
	
	[
	  id ==> as(Prompt,LanguageModel),
	  type ==> recursive,
	  embedded_dm ==> ask(Prompt, LanguageModel, false, [], Output, Status),
	  arcs ==> [
	       ok : empty => rs(Output),
	       error : [say('let me try again ')] => as(Prompt,LanguageModel)
	  ]
	],

	[
	  id ==> rs('yes'),
	  type ==> neutral,
	  arcs ==> [
	       empty : [set(friend,'yes'), say('ok let me register your status'), execute('scripts/inicia_reporte.sh')] => grs(L,pers_posit,lesionada)
	  ]
	],

	[
	  id ==> rs('no'),
	  type ==> neutral,
	  arcs ==> [
	       empty : [set(friend,'no'), say('ok let me register your status'), execute('scripts/inicia_reporte.sh')] => grs(L,pers_posit,lesionada)
	  ]
	],

        %Situacion intermedia en la que se decide a que situaci<C3><B3>n pasar
        %Como expectativa espera a que se agregue al reporte los datos de la persona que vio
        %El reporte incluye la posici<C3><B3>n actual de la persona, el <C3><A1>ngulo horizontal del cuello del robot, el status de la persona y el numero de persona
        %Se cuentan el numero de personas que se han visto 
        %y se toma una decisi<C3><B3>n: terminar la tarea o ir al siguiente punto de busqueda   
        %Si no se cumple la condici<C3><B3>n, C>numero_personas, se va al siguiente punto de busqueda,
        %Si se cumple la condici<C3><B3>n, termina
        [
          id ==> grs(L,Posicion_actual,Status_persona),
          type ==> following,
          arcs ==> [
               reporte_generado(get(find_currpos,CurrentPos),get(last_scan, Angulo_Cuello),Status_persona) : [execute('scripts/actualiza_reporte.sh'),inc(count,C)] 
	       => apply(when(If,TrueVal,FalseVal),[C>=6,fs,ve_al_punto(L)])
          ]
        ],

	[ 
	  id ==> ds,
	  type ==> neutral,
	  arcs ==> [
	       success : [say('im done registering your status')] => as('so, what would you like me to bring you', food)
	  ]
	],

	[
	  id ==> rs(Thing),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say(['ok i will bring you', Thing]), set(obj,Thing),execute('scripts/killvisual.sh'),execute('scripts/objectvisual.sh')] => find_obj(Thing)
	  ]
	], 

	[
	  id ==> find_obj(Thing),
	  type ==> recursive,
	  embedded_dm ==> find(object, Thing, [p1],[-20,0,20],[-30,0,30],food,[H|T],Remaining_Positions,false,false,false,Status),
	  arcs ==> [
	       ok : [say('i found it let me grab it')] => ts(H,left),
	       error : [say('let me take another look')] => find_obj(Thing)
	  ]
	],
	
	[
          id ==> ts(Object,Arm),
	  type ==> recursive,
	  embedded_dm ==> take(Object,Arm,X,Status),
	  arcs ==> [
	       ok : [say('i have it with me'),execute('scripts/killvisual.sh')] => ms(pers_posit,'here you have',4),
	       error : [say('let me try again')] => ts(Object,right)
	  ]
	],
	  
	[
	  id ==> arrived_to(4),
	  type ==> recursive,
	  embedded_dm ==> deliver(obj,pers_posit,handle,Status),
	  arcs ==> [
	       ok : [say('ok now i will go to the entrance')] => ms(room_entrance,'hello there follow me please',5),
	       error : [say('grab this shyte please')] => arrived_to(4)
	  ]
	],
	
	[
	  id ==> arrived_to(5),
	  type ==> neutral,
	  arcs ==> [
	       empty : empty => ms(pers_posit,'there is your bloody injured',6)
	  ]
	],

	[
	  id ==> arrived_to(6),
	  type ==> neutral,
	  arcs ==> [
	       empty : [say('good bye motherfuckers')] => final_sit
	  ]
	],
	
	[
	  id ==> final_sit,
	  type ==> final
	] 
],
% List of local variables
[
    pers_posit ==> [],
    room_entrance ==> [],
    friend ==> 'no',
    lista ==> [p2,p3],
    obj ==> ''
]
).
% End of dialogue