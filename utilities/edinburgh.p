/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/edinburgh.p,v 1.1 1995/09/22 11:23:59 harrisja Exp $
*
*  $Log: edinburgh.p,v $
 * Revision 1.1  1995/09/22  11:23:59  harrisja
 * Initial version.
 *
*
*/

/*
 *   Edinburgh - compatibility definitions, predicates, operators
 *             - Definite Clause Grammars
 *
 *   BNR Prolog 
 *
 *   Copyright © Bell-Northern Research Ltd. 1988 
 */
 
/* This file contains some Edinburgh Prolog predicate and operator definitions
   that aim at compatiblity with the predicates by the same name described in
   Clocksin and Mellish "Programming in Prolog". See this volume for further 
   details on the semantics for these predicates. See also chapter 20 of the
   BNR Prolog User Guide for explanations of the incompatibilities. 
*/

/* some common edinburgh operator definitions */
op(1000, xfy, ','). % comma
op(900, fy, \+).    % not
op(700, xfx, =..).  % univ
op(900, fy, not).   % not

% (A , B) :- (A & B). % comma means "&"



%% for Quintus Compatibility -- added for 3.0
current_predicate(Pred,Pred(Args..)) :-  definition(Pred(Args..) :- Body,_Context).

%% NOT - negation by failure 

\+ Goal :- not Goal.


%% UNIV - converts terms to lists or visa versa
Symbol =.. [Symbol] :- symbol(Symbol),!.
F(Args..) =.. [F,Args..] :- 
         symbol(F),
         termlength([Args..],_,[Last..]),
         [Last..] @= [].

%% For semblance of Quintus Compatibility -- added for 3.0
[H|T] =.. ['.',H|T].
 
%% ATOM is a filter so vars or tailvars must fail

atom(Var) :-  var(Var), !, fail.
atom(Tvar..) :- tailvar(Tvar..),!,fail.
atom([]).                 		    % empty list is an atom
atom(P) :- symbol(P).			    % symbols are atoms
atom(P()) :- symbol(P).     % and functorials of arity 0


name(X,Y) :- var(X,Y),!,fail.
name([],X) :- name('[]',X), !.


%% CLAUSE/2 is defined in terms of CLAUSE/1 in base

clause(Head,Body) :- 
         symbol(Head),
	 clause(Head() :- Body).

clause(F(Args..),Body) :-
         clause((F(Args..) :- Body)).


/* FUNCTOR/3 decomposes\constructs terms
   One of the major differences between ApProlog and Edinburgh Prologs is
   with the notion of a list. A list in Edinburgh Prolog is simply another
  (useful) prolog term. In ApProlog, the list has no functorial form -- it
   is a basic data structure. Consequently the null list is not an atom
   and non-empty lists have no principle functor. This definition attempts
   to fake it for lists, but C&M behaviour is only skin deep.   
*/
functor(Struct,Functor,Arity) :-    
                             % underspecified
     (var(Struct,Arity) ; var(Struct,Functor)),
     !,
     fail.    	     	      % so fail

functor([],[],0) .                        

functor(List,'.',2) :-                
    	var(List) ,
	List = [Head,Tail..],
	!.
functor(List,'.',2) :-                
     	  list(List),
          List @\=[],
 	 !.
functor(F(_args..),F,N):- % the usual case -- decomposing structures
				 symbol(F),
				 termlength([_args..],N,_),
				 !.
functor(F(_args..),F,N):-  % the usual case -- decomposing structures
				 symbol(F),
				 once($length([_args..],N)).
$length([],0).
$length([H,T..],N) :- 		M is N - 1,
				$length([T..],M).
			
/* overload arg/3 to handle lists as Edinburgh might: same reasoning
   regarding lists as for functor/3



arg(N,[A..],'.') :- N @= 0, !.
arg(N,[A,B..],A):- N @= 1, !.
arg(N,[A,B..],[B..]):- N @= 2, !.

*/
call(Goal) :- [Goal].          % NOTE call(!) cuts call/1


%% CHARACTER I/O %%
get0(AsciiCode) :-
				get_char(Char),
				put_char(Char),	       % echo to the default output
			        char_int(Char,AsciiCode).


get(AsciiCode) :- 
	 repeat,              
                get0(AsciiCode),        % read the char
                $printable(AsciiCode),  % is it printable? 
                cut(get).


put(AsciiCode) :- 
		char_int(Char,AsciiCode),
                write(Char).

skip(AsciiCode) :- 
        integer(AsciiCode),       % must be bound going in
         repeat,              
               get_char(Char),     % read the char
               char_int(Char,AsciiCode), % does it match ?
	!.


tab(N) :-
    integer(N),
     $write_space(N).    

%%  abolish/2 does a retractall in the current context %%

abolish(Pred,Arity) :-
    symbol(Pred),
     integer(Arity),
     functor(Struct,Pred,Arity),    % build a structure of the right arity
     retractall(Struct).            % and retract all clauses whose heads match
    

%% abolish/1 is used in ARITY prolog 

abolish( (Pred / Arity ) ) :-  abolish( Pred, Arity) .
/* overload assert to assertZ semantics */
assert(Cl):-
	!,
        assertz(Cl).

%% utility predicates for the above 
$printable(AsciiCode) :-          % according to standard ASCII conventions
     AsciiCode > 32 ,
     AsciiCode =< 126.

$write_space(0) :- cut($write_space).
$write_space(N) :- 
     write(" "),
      M is N - 1,
      $write_space(M).

/************* S E T O F   and   B A G O F  **************/

/*
   declare operator for specifying existential variables
*/
op(200,xfy,^).

/* 
   setof/3: _set is an sorted set of patterns, _pat, with duplicates removed, 
            generated by solving _goal. 
*/
setof(_pat,_goal,_set):-
   once($setup(_pat,_goal,_newgoal,_goallist)),%process existentials
    $member(_newgoal,_goallist),
    findset(_pat,_newgoal,_set),
    _set @\= [].                                   %pass if set is non-null
   

/* 
   bagof/3: _set is an unsorted set of patterns, _pat, generated by
            solving _goal. 
*/
bagof(_pat,_goal,_bag):- 
    once($setup(_pat,_goal,_newgoal,_goallist)),%process existentails
    $member(_newgoal,_goallist),
    findall(_pat,_newgoal,_bag),
    _bag @\= [].                                   %pass if set is non-null


/* 
    setof and bagof setup, takes a pattern and a goal
    and returns a goal list to qulify non-existentails
    and a generator goal.
*/
$setup(_pat,_goal,_newgoal,_goallist):-
     variables(_pat,_vs,_tvs,_),      %initialize list of existentail vars
     $app(_vs,_tvs,_l),
     once($qualify(_goal,_l,_newgoal,_qgoal)),  %generate a qualifying goal with
                                                %existential vars removed, and a 
                                                %new generator 
     findset(_newgoal,_qgoal,_goallist).
    

/*
    $qualify/4 processes goals gathering existentail variables, and
    generating a qualifying goal, which will replace non-existentails
    with a different variable. Non-existentails get different values
    when 'setof' or 'bagof' are backtracked across. There are no
    internal cuts so '$qualify' should be used 'once'. 
*/
 
$qualify(_x,_l,_x,_a):-      %replace non-existentials
    var(_x),
     $memb(_x,_l).    

$qualify(_x,_l,_x,_x):- var(_x).  %keep existentials

$qualify(_x,_l,_x,[_a..]):-       %replace non-existential tailvars
    tailvar(_x..),
     $memb(_x,_l).


$qualify(_x,_l,_x,_x):- tailvar(_x..).  %keep existential tailvars

$qualify(_v^_goal,_l,_newgoal,_qgoal):-  %add existential
    $qualify(_goal,[_v,_l..],_newgoal,_qgoal).    

$qualify(bagof(_p,_g,_s),_l,bagof(_p,_g,_s),true).  %bagof special case
    
$qualify(setof(_p,_g,_s),_,setof(_p,_g,_s),true).   %setof special case
    
$qualify(_f(_args..),_l,_f(_args..),_f(_qargs..)):-   %structures
    $qualify(_args,_l,_args,_qargs).

$qualify([_a,_args..],_l,[_a,_args..],[_qa,_qargs..]):- %lists
   $qualify(_a,_l,_a,_qa),
   $qualify(_args,_l,_args,_qargs).
   

$qualify(_x,_l,_x,_x).  %catch everything else (constants)


/*
    Standard append.
*/
$app([], _L, _L).

$app([_H, _T1..], _L, [_H, _T2..]) :-  $app([_T1..], _L, [_T2..]).

/*
    Membership using identity test
*/
$memb(_X, [_Y, _Ys..]):- _X@=_Y,!.

$memb(_X, [_, _Ys..]) :- $memb(_X, [_Ys..]).

/*
    Standard Member
*/
$member(_x,[_x,_r..]).

$member(_x,[_y,_r..]):-$member(_x,_r).
