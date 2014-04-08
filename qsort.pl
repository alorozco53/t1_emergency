sublist( [], _ ).
sublist( [X|XS], [X|XSS] ) :- sublist( XS, XSS ).
sublist( [X|XS], [_|XSS] ) :- sublist( [X|XS], XSS ).

long([],0).
long([H|T],N) :- long(T,M), N is M+1.

% remove(X,L,K) :- K is the list L without X 
remove(X,[],[]).
remove(X,L,K) :- elem(X,K), \+ elem(X,L).   

% elem(X,L) :- X is element of list L
elem(X,[X|T]).
elem(X,[H|T]) :- elem(X,T).

append([],L,L).
append([X|L1],L2,[X|L3]) :- 
  append(L1,L2,L3), !.

reverse([],[]).
reverse([H|T],L) :- 
  reverse(T,Z), append(Z,[H],L), !.

:- op(800, xfx, '=>').

remove_turn(L,R):-
    remove_turn(L,[],R).

remove_turn([],Res,Res).
remove_turn([turn=>A|Rest],Acc,Res):-
    remove_turn(Rest,Acc,Res).
remove_turn([H|Rest],Acc,Res):-
    remove_turn(Rest,[H|Acc],Res).

arrived_posit([P], _, P).
arrived_posit(Posit, Rem, Cp) :- 
	remove_turn(Posit, Posit1),
	reverse(Rem, Rem1),
	diff(Posit1, Rem1, Cp).

diff([X|XS], [Y|YS], Out) :-
	diff(XS,YS,Out).
diff([X|XS], [], X).