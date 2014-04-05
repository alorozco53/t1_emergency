sublist( [], _ ).
sublist( [X|XS], [X|XSS] ) :- sublist( XS, XSS ).
sublist( [X|XS], [_|XSS] ) :- sublist( [X|XS], XSS ).

occurr(X,[],0).
occurr(X,[X|T],N) :- occurr(X,T,M), N is M+1, !.
occurr(X,[H|T],N) :- occurr(X,T,M), N is M, !.

long([],0).
long([H|T],N) :- long(T,M), N is M+1.

% remove(X,L,K) :- K is the list L without X 
remove(X,[],[]).
remove(X,L,K) :- elem(X,K), \+ elem(X,L).   

% elem(X,L) :- X is element of list L
elem(X,[X|T]).
elem(X,[H|T]) :- elem(X,T).

% sublist(L,R) :- R is sublist of L
%sublist(L,[]).
%sublist(L,[H|T]) :-
%	long(L,P), long([H|T],Q), Q =< P, !,
%	elem(H,L), 
%	occurr(H,L,N), occurr(H,[H|T],M), 
%	M =< N, sublist(L,T).

cat([], R, R).
cat([LH|LT], [RH|RT], K) :- K is [LH|T], reversa(T,[RH|LT]),  

quicksort([],[]).
quicksort([H|T],K) :- 
	sublist(K,[H|T]), elem(H,K),
	elem(X,K), elem(X,[H|T]), X =< H, 
	elem(Y,K), elem(Y,[H|T]), Y > H,
	