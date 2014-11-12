:- use_module(library(lists)).
:- use_module(library(system)).
% Mostly, in this context, each time will be a UNIX timestamp unified by the predicate now(Time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% current_time_em(Current_time).
% Computes the current time
current_time_em(Current_time) :-
	now(Current_time).

% generate_limit_time_em(Time_list, Time_timestamp).
% Generates limit time timestamp by adding the total expected elapsed time (in seconds) to the current time
generate_limit_time_em(Expected_time, Limit_time_timestamp) :-
	current_time_em(Current_time),
	Limit_time_timestamp is Expected_time+Current_time.

% verify_time_em(Current_time, Initial_time, Limit_time).
% Checks whether the current time is less than limit time
verify_time_em(Limit_time) :-
	current_time_em(Current_time),
	Current_time =< Limit_time.

% verify_move_em(Error, Next_situation, Limit_time, Robot_speech, NextSit)
% Checks a 'move' error and decides the next situation in an emergency DM, also considering time limit
verify_move_em(navigation_error, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'my map says someone or something is blocking my way',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_move_em(_, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i successfully arrived to the desired position',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

% verify_scan_em(Error, Next_situation, Limit_time, Robot_speech, NextSit)
% Checks a 'scan' error and decides the next situation in an emergency DM, also considering time limit
verify_scan_em(lost_user, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'could you please move closer to my camera please',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_scan_em(camera_error, _, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'there is an error with my camera',
	    NextSit = fs(camera_error)
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_scan_em(not_detected, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i dont see anyone now',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_scan_em(_, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i see someone in front of me',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

% verify_find_em(Error, Next_situation, Limit_time, Robot_speech, NextSit)
% Checks a 'find' error and decides the next situation in an emergency DM, also considering time limit
verify_find_em(navigation_error, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'my map says someone or something is blocking my way',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_find_em(lost_user, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'could you please move closer and see my camera please',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_find_em(camera_error, _, Limit_time, Robot_speech, _) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'there is an error with my camera',
	    NextSit = fs(camera_error)
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_find_em(not_detected, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i couldnt detect anyone',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_find_em(not_found, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i cant see anything or anyone here',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_find_em(empty_scene, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'im in front of nothing',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_find_em(_, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i successfully completed this task',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

% verify_ask_em(Error, Next_situation, Limit_time, Robot_speech, NextSit)
% Checks an 'ask' error and decides the next situation in an emergency DM, also considering time limit
verify_ask_em(error, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'let me try to listen to you again',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_ask_em(_, NextSit, _, 'alright', NextSit).

% verify_take_em(Error, Locations_list, Current_used_arm, Limit_time, Robot_speech, NextSit)
% Checks a 'take' error and decides the next situation in an emergency DM, also considering time limit
verify_take_em(not_grasped, Obj_list, CurrArm, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i didnt take the object',
	    (CurrArm = right -> NextSit = ts(Obj_list,left) | otherwise -> NextSit = ts(Obj_list,right))
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).
verify_take_em(_, Obj_locs, _, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i cannot see the object let me try to fix my position',
	    NextSit = fos(Obj_locs)
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

% verify_deliver_em(Error, Next_situation, Limit_time, Robot_speech, NextSit)
% Checks a 'deliver' error and decides the next situation in an emergency DM, also considering time limit
verify_deliver_em(_, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'please stand in front of me and grab the object im trying to give you',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

% verify_approach_person__ckp(Error, Next_situation, Limit_time, Robot_speech, NextSit)
% Checks an 'approach_person' error and decides the next situation in a cocktail party DM, also considering time limit
verify_approach_person_ckp(_, Next_situation, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'could you please stand in front of me and see my camera please',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

% verify_see_person__ckp(Error, Next_situation, Limit_time, Counter, Robot_speech, NextSit)
% Checks an 'see_person' error and decides the next situation in a cocktail party DM, also considering time limit
verify_see_person_ckp(ok, Next_situation, Limit_time, _, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i successfully see you',
	    NextSit = Next_situation
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

verify_see_person_ckp(_, Next_situation, Limit_time, Counter, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'see my cameraaaaaaaa please',
	    NextSit = Next_situation
	| 5 =< Counter ->
	    Robot_speech = 'i couldnt memorize your face',
	    NextSit = ask_order
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = fs(time_is_up)
	).

% verify_psearch_ckp(Error, Next_situation, Counter, Robot_speech, Action, NextSit)
% Checks a 'party_psearch' error and decides the next situation in a cocktail party DM
verify_psearch_ckp(time_is_up, ClientList, DrinkList, PositList, Counter, Robot_speech, Action, NextSit) :-
	(Counter =< 3 ->
	    Robot_speech = 'next person please stand in front of me',
	    NextSit = busca_persona_para_pedido(ClientList,DrinkList,PositList)
	| otherwise ->
	    Robot_speech = 'my robotic intuition says im done with all the people',
	    NextSit = busca_por_objetos(ClientList,DrinkList,PositList)
	),
	Action = say('alright').

verify_psearch_ckp(camera_error, Next_situation, Counter, Robot_speech, Action, NextSit) :-
	(Counter =< 3 ->
	    Robot_speech = 'next person please stand in front of me',
	    NextSit = busca_persona_para_pedido(ClientList,DrinkList,PositList)
	| otherwise ->
	    Robot_speech = 'my robotic intuition says im done with all the people',
	    NextSit = busca_por_objetos(ClientList,DrinkList,PositList)
	),
	Action = set(camera_error,true).

% verify_take_ckp(Error, Object, Current_used_arm, Limit_time, Robot_speech, NextSit)
% Checks a 'take' error and decides the next situation in an emergency DM, also considering time limit
verify_take_ckp(not_grasped, Object, CurrArm, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i didnt take the object',
	    (CurrArm = right -> NextSit = ts(Object,left) | otherwise -> NextSit = ts(Object,right))
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = error
	).
verify_take_ckp(_, Object, _, Limit_time, Robot_speech, NextSit) :-
	(verify_time_em(Limit_time) ->
	    Robot_speech = 'i cannot see the object let me try to fix my position',
	    NextSit = success
	| otherwise ->
	    Robot_speech = 'my robotic intuition says my time is over doing this',
	    NextSit = success
	).
