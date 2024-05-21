:- use_module(library(lists)).
/*hastype(G,E,T)*/
hastype(G,intT(N),intT):-!.
hastype(G,boolT(B),boolT):-!.
hastype(G,var(X),T):-member((var(X),T),G),!.
hastype(G, sum(E1,E2), T) :-hastype(G, E1, T1),hastype(G, E2, T2),T1 = intT, T2 = intT, !,T = intT.
hastype(G, sub(E1,E2), T) :-hastype(G, E1, T1),hastype(G, E2, T2),T1 = intT, T2 = intT, !,T = intT.
hastype(G, mul(E1,E2), T) :-hastype(G, E1, T1),hastype(G, E2, T2),T1 = intT, T2 = intT, !,T = intT.
hastype(G, and(E1,E2), T) :-hastype(G, E1, T1),hastype(G, E2, T2),T1 = boolT, T2 = boolT, !,T = boolT.
hastype(G, or(E1,E2), T) :-hastype(G, E1, T1),hastype(G, E2, T2),T1 = boolT, T2 = boolT, !,T = boolT.
hastype(G, not(E), T) :-hastype(G, E, T1),T1 = boolT, !, T = boolT.
hastype(G, checkEq(E1,E2), T) :-hastype(G, E1, T1),hastype(G, E2, T2),T1 = intT, T2 = intT, !,T = boolT.
hastype(G, checkGt(E1,E2), T) :-hastype(G, E1, T1),hastype(G, E2, T2),T1 = intT, T2 = intT, !,T = boolT.
hastype(_, _, illFormed):-fail.
%%hastype([(var(a), intT), (var(b), unitT), (var(c), boolT), (var(d), intT), (var(e), boolT), (var(f), unitT)], or(or(var(a), and(intT(8), var(b))), and(boolT(false), not(intT(3)))), W).--FAIL
%%hastype([(var(x), boolT), (var(y), intT), (var(z), unitT), (var(w), boolT), (var(v), intT), (var(u), unitT)], or(or(not(checkGt(intT(10), var(y))), and(var(x), boolT(true))), and(not(unitT), or(checkGt(var(u), intT(3)), and(var(v), var(w))))), W).--FAIL
%%hastype([(var(p), intT), (var(q), boolT), (var(r), unitT), (var(s), intT), (var(t), boolT), (var(u), unitT)], or(and(checkGt(intT(20), var(p)), not(boolT(false))), or(var(q), and(and(checkEq(unitT, var(r)), var(s)), var(t)))), W).--FAIL
%%hastype([(var(a),intT),(var(b),intT),(var(p),boolT)],and(checkEq(var(a)+var(b),intT(5)),var(p)),W).//W=boolT
%%hastype(G,and(checkGt(var(x),intT(5)),var(x)),T).//FAIL
%%hastype(G,or(and(checkGt(var(x),intT(5)),var(y)),boolT(T)),T),remove_anonymous(G,CACHE).
%%hastype([(var(x),intT),(var(y),intT),(var(z),intT)], checkGt(var(x), sub(var(y), var(z))), boolT).
remove_anonymous([], []):-!.
remove_anonymous([(_, Type) | T], [(Var, Type) | T1]) :-
    Var = _,
    remove_anonymous(T, T1).