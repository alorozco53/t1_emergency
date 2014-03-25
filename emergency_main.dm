diag_mod(emergency_main,
 [
	[
	  id ==> is,
	  type ==> neutral,
	  arcs ==> [
	       empty : [initSpeech,execute('scripts/upfollow.sh')] => locate_pers
	  ]
	],

	[
	  id ==> locate_pers,
	  type ==> recursive,
	  embedded_dm ==> emergency_locate([p1,p2],[p2,p3],['hello i am golem and i will go to the rescue','let me find the person'],Status),
	  arcs ==> [
	       up(Position) : [sleep(15),say('tell me what the hell happens to you'),execute('scripts/killvisual.sh')] => fs,
	       down(Position) : [sleep(15),say('tell me what the hell happens to you'),execute('scripts/killvisual.sh')] => fs

	  ]
	],

	[
	  id ==> fs,
	  type ==> final
	]
],
%Second argument: list of parameters
[
]
).