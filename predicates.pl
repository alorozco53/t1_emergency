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
	current_time(Current_time),
	Limit_time_timestamp is Expected_time+Current_time.

% verify_time_em(Current_time, Initial_time, Limit_time).
% Checks whether the current time is less than limit time
verify_time_em(Limit_time) :-
	current_time(Current_time),
	Current_time =< Limit_time.