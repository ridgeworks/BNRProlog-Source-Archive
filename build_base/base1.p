/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/base1.p,v 1.8 1997/09/04 11:56:53 harrisj Exp $
 *
 * $Log: base1.p,v $
 * Revision 1.8  1997/09/04  11:56:53  harrisj
 * Added memory_status\2 which doesn't calculate high water marks nor returns state space and context space used.
 *
 * Revision 1.7  1997/03/21  10:28:37  harrisj
 * combining tailvar freeze constraints wasn't working properly.
 * joinvar primitive modified to support tailvars and the
 * combinevar predicate also modified to support tailvars.
 *
 * Revision 1.6  1996/04/18  23:35:11  yanzhou
 * A cut added to substring to remove unwanted choice point.
 *
 * Revision 1.5  1996/03/04  03:53:41  yanzhou
 * Improved substring() implementation for better performance.
 * Improved integer_range() implementation (cut before tail recursion).
 *
 * Revision 1.4  1996/02/12  08:07:19  yanzhou
 * Added new predicate statespace_status(Total,Used,SSpace).
 *
 * Revision 1.3  1996/02/02  06:16:07  yanzhou
 * In $rm_dup/2, an extra ',' is removed.
 *
 * Revision 1.2  1996/01/24  09:33:43  yanzhou
 * successor/2 now only works for integers.
 *
 * Revision 1.1  1995/09/22  11:21:16  harrisja
 * Initial version.
 *
 *
 */

/*
 * Ring 1 of BASE
 */

$base(1).

%%%
%%%   Constraints
%%%
%     data flow replaced by CLP(BNR) march 1994

{ } :-!.

{C, Cs..} :- 
    $braces(C), {Cs..}.

/*  data flow arithmetic removed march 1994 and replaced with CLP(BNR)
$braces(N is Exp) :-   !, $freeze_simple(Exp, (N is Exp)).
*/

$braces( F(X,Y) ):- 
		$arithmetic_relation(F),!,		 % commit to interval arithmetic
		$braced_arithmetic( F(X,Y)),!.   % setup must be deterministic 
						% see Crias / march 1994


% regular (and usual) case 
$braces(nonvar(P, Ps..) -> Q) :-   
    breadth_first_compare(Ps,[],@=), % add Ps.. to nonvar(P)
    !,                               % in case called with nonvar(X..)
    freeze(P, Q).

% more than 1 variable in nonvar, bind to first one
$braces(nonvar(P, Ps..) -> Q) :-
    !,
    freeze(P, $braces(nonvar(Ps..) -> Q)).

$braces(P -> Q) :- 
    !,
    $freeze_simple2(P, Q).

$braces(C) :-  
    $freeze_simple(C, C).


$freeze_simple(Vars, Goal) :-               % if a variable exists in Vars then bind to it
    $first_var(Vars, V), 
    !, 
    freeze(V, $freeze_simple(Vars, Goal)).

$freeze_simple(_, Goal) :-                  % no variables so execute it immediately
    Goal.                                   % Don't do a cut as we want to be able to re-establish 
                                            % (backtrack to) constrainted goals once injected 
                                            % into the goal clause.

$freeze_simple2(P, Q) :-
    P,                                      % try to execute P
    !,                                      % if it succeeds, then outcome solely based on Q
    Q.
      
$freeze_simple2(P, Q) :-                    % know P failed, if vars remaining then wait to try again
    $first_var(P, V),!, 
    freeze(V, $freeze_simple2(P, Q)).

$freeze_simple2(P, Q).


%%%% freeze
% freeze[V, Goal] has traditional semantics: If V is a var, the evaluation of Goal is 
% delayed until V is bound to a nonvar. If V is a nonvar, Goal is evaluated immediately.
% Now implemented as a primitive.

% freeze(V, Goal) :-
%     list(V),                                % see if V contains a tail variable
%     V = [Vs..],                             % now bind to list containing TV
%     tailvar(Vs..),                          % and check (can't do in head because variable in V will bind)
%     compound(Goal),                         % Ensure form of Goal ok
%     !,                                      % remove choicepoint if it exists
%     $constrain([V1..], Goal),                 % Take two local vars, constrain V1 by V2
%     [V1..] = [Vs..].                        % Conjoin with existing constraints on V

% freeze(V, Goal) :-
%     compound(Goal),                         % Ensure form of Goal ok
%     !,                                      % remove choicepoint if it exists
%     $constrain(V1, Goal),                     % Take two local vars, constrain V1 by V2
%     V1 = V.                                 % Conjoin with existing constraints on V
%     % do not cut at the end here in case V was already bound and we need to backtrack

%%%
%%% Meta-Predicates arg(N, Term, A) and termlength(Term, Size, Last)
%%%

% arg(N,Term,A) succeeds if A is the Nth argument of Term
%   deterministic (open to change), succeeds at most once

arg(N,S,A):-                 % term is a structure (the common case)
    structure(S),!,          
    S=F(Args..),             % convert structure to list and 
    $arg(0,N,[F,Args..],A).  % start count at 0

arg(N,L,A):-                 % term is a list, should be last clause for arg
    list(L),        
    $arg(1,N,L,A).           % start count at 1

$arg(N,N,[A,_..],A):-!.      % cut to enforce determinism, note unification semantics
$arg(Ix,N,[_,As..],A):-      % extend indefinite list as required
    tailvar(As..),           % not required for deterministic case
    !,                       % altered clause to avoid meta-interpretation 
    fail.                    % of tailvar in  not(tailvar(As..)).
$arg(Ix,N,[_,As..],A):-      
    NIx is Ix+1,             
    $arg(NIx,N,As,A).

% termlength(Term, Size, Last) needs some documentation on how it handles
% cyclic structures

termlength(Term,Size,Last):-
	acyclic(Term),!,
	$acyclic_termlength(Term,Size,Last).	% standard walk for acyclic terms

termlength(Term,Size,Last):-
	spanning_tree(Term,Copy,Unifys),		% cyclic terms, break it down
	$cyclic_termlength(Copy,Unifys,Size,Last),
	Copy=Term.		% unify back to get Last on cyclic term
	
$acyclic_termlength(Term,Size,Last):-
    structure(Term), !,
    Term = P(Args..),
    $termlength([Args..],Size,Last,0).

$acyclic_termlength(Term,Size,Last):-
    list(Term),
    $termlength(Term,Size,Last,0).

$termlength([T..],S,Last,M):-
    tailvar(T..),!,			% reached unbound tailvar in original term
    $deflength(Last,0,LS),	% get length of Last
    S is M + LS,			% calculate total length
    Last = T.				% bind tail to Last
$termlength([],M,[],M).
$termlength([T,Ts..],Size,Last,M):-
    M1 is M + 1,
    $termlength(Ts,Size,Last,M1).

$deflength([T..],S,S):- tailvar(T..),!.		% abbreviated copy of $termlength
$deflength([],S,S).
$deflength([_,Rest..],C,S):-
    C1 is C + 1,
    $deflength(Rest,C1,S).

$cyclic_termlength(Copy,Unifys,infinite,[]):-
	list(Copy),						% special case for looped lists
	$gettail(Copy,Last),			% get tailvar from term copy
	$getunify(Last,Unifys,Loop),	% get unification from unifies list
	$gettail(Loop,LLast),			% get tailvar from loop definitaion
	breadth_first_compare(Last,LLast,@=),!.	% if the same then looped list

$cyclic_termlength(Copy,_,Size,Last):-
	$acyclic_termlength(Copy,Size,Last).	% not a looped list, return length of copy

%%%
%%%   literal comparisons, Sort and Term_Compare
%%%

X @= Y  :- term_compare(X,Y,'@=').
X @\= Y :- not(term_compare(X,Y,'@=')).
X \== Y :- not(term_compare(X,Y,'@=')).
X @< Y  :- term_compare(X,Y,'@<').
X @=< Y :- not(term_compare(X,Y,'@>')).
X @> Y  :- term_compare(X,Y,'@>').
X @>= Y :- not(term_compare(X,Y,'@<')).

% sort/2  sort uses term_compare 
% term_compare uses depth_first_compare then breadth_first compare

sort(_Given, _Result) :-                   % version by Bill Williams (modified). 
      list(_Given),                        % Require _Given to be bound to a list  
      $sort2_enlist(_Given, _ListList),    % if _Given extensible, it is capped
      $sort2_passes(_ListList, _Result1),  % Observe, _Result1 is a local var
      !,                                   % Commit
      _Result = _Result1,                  % In case _Result was bound
      !.

$sort2_enlist([],[]).          % 0 elements left   
$sort2_enlist([_O],[[_O]]).    % 1 element left    
$sort2_enlist([_X1,_X2,_Xs..],[_Pair,_Rest..]) :- % 2 or more elements left
      term_compare(_X1,_X2,_Rel),
      $sort_pair(_Rel,_X1,_X2,_Pair),
      $sort2_enlist(_Xs,_Rest).
$sort2_enlist([_X1,_Xs..],_Rest) :-                 % assume _X1 @= _X2, remove 1
      $sort2_enlist(_Xs,_Rest). 

$sort_pair('@<',_X1,_X2,[_X1,_X2]).    
$sort_pair('@>',_X1,_X2,[_X2,_X1]).    

$sort2_passes([], []).
$sort2_passes([_OneList], _OneList).
$sort2_passes(_ListList, _Sorted) :-
      $sort2_pairpass(_ListList, _Onepass),
      $sort2_passes(_Onepass, _Sorted).

$sort2_pairpass([_X1,_X2,_Xs..], [_Both,_Ys..]) :-
      $sort2_pairmerge(_X1,_X2,_Both),
      $sort2_pairpass(_Xs,_Ys).
$sort2_pairpass(_Lastone, _Lastone).

$sort2_pairmerge([], _Ys, _Ys).
$sort2_pairmerge(_Xs, [], _Xs).
$sort2_pairmerge([_X,_Xs..],[_Y,_Ys..],_Zs) :-
      term_compare(_X,_Y,_Rel),
      $pickmerge(_Rel,[_X,_Xs..],[_Y,_Ys..],_Zs).

$pickmerge('@<',[_X,_Xs..],_Ys,[_X,_Zs..]):-
      $sort2_pairmerge(_Xs,_Ys,_Zs).      
$pickmerge('@>',_Xs,[_Y,_Ys..],[_Y,_Zs..]):-
      $sort2_pairmerge(_Xs,_Ys,_Zs).      
$pickmerge('@=',[_X,_Xs..],[_X,_Ys..],[_X,_Zs..]):-
      $sort2_pairmerge(_Xs,_Ys,_Zs).      

%
% term_compare(X,Y,Rel) where X and Y are any terms and Rel is '@<', '@=', or '@>'
%

term_compare(X,Y,Rel):-
    $type(X,TX,Comp),
    $type(Y,TY,_),
    $type_compare(TX,TY,X,Y,Comp,Rel),!.

% term types in standard order, uses filters only so no unification
% also specifies comparison routine for equal types

$type(X,0,breadth_first_compare):-
    var(X).   % test first and prevent unification
% type 1 is tailvar, can't exist outside compound term, hence don't need it here
$type(X,2,breadth_first_compare):-
    number(X).
%$type(X,3,breadth_first_compare):-
%    interval(X).
$type(X,4,breadth_first_compare):-
    symbol(X).
$type(X,5,$list_compare):-
    list(X).
$type(X,6,$struc_compare):-
    structure(X).

% type comparisons, uses arithmetic compare    
$type_compare(TX,TX,X,Y,Comp,Rel):-  % types are equivalent, use comparison routine
    Comp(X,Y,Rel).

$type_compare(TX,TY,_,_,_,'@<'):-TX < TY.  % type of X is prior to type of Y

$type_compare(TX,TY,_,_,_,'@>'):-TX > TY.  % type of X is after to type of Y


% comparing lists depth first
% uses tailvar filter (in fact all funny tailvar cases done here)
$list_compare([Xs..],[Ys..],Rel):-  % compare two lists, catch tailvars here
    tailvar(Xs..),
    tailvar(Ys..),
    breadth_first_compare([Xs..],[Ys..],Rel).

$list_compare([],[Ys..],Rel):-      % end of Xs, Ys has a tailvar left
    tailvar(Ys..),!,
	Rel='@<'.

$list_compare([Xs..],[],Rel):-      % end of Ys, Xs has a tailvar left
    tailvar(Xs..),!,
	Rel='@>'.

$list_compare([],[],'@=').          % end of list, they're equal

$list_compare([],_,'@<').    		% end of Xs, Ys not exhausted

$list_compare(_,[],'@>').    		% end of Ys, Xs not exhausted

$list_compare([X,Xs..],[Y,Ys..],Rel):-  % each list has one or more terms left
    term_compare(X,Y,R),
	$list_chk(R,Xs,Ys,Rel).

$list_chk(@=,Xs,Ys,Rel):-$list_compare(Xs,Ys,Rel).
$list_chk(@<,_,_,@<).
$list_chk(@>,_,_,@>).

% fold functor of structure into arg list and compare lists
$struc_compare(X(Xs..),Y(Ys..),Rel):-
    $list_compare([X,Xs..],[Y,Ys..],Rel).

%%%
%%%   Basic Meta Primitives
%%%

%%%% T occurs in T1 if T1 is identical to T, or contains a subterm identical to T
%%% removes restriction in 3.0 that T cannot be a compound term

occurs_in(T,T1):-
	acyclic(T1),!,
	$occurs_in(T,T1).

occurs_in(T,T1):-	% T1 is a cyclic term
	decompose(T,C,_),
	decompose(T1,C1,Frags),	% decompose and check acyclic copy
	$$occurs_in(C,C1,Frags).

$$occurs_in(C,C1,Frags):- $occurs_in(C,C1),!.	% term is in acyclic C1
$$occurs_in(C,C1,Frags):- $frg_occurs_in(C,Frags). % term is in one of the acyclic fragments


$occurs_in(T,T1):-
	breadth_first_compare(T,T1,@=),!.		% terms are identical

$occurs_in(T,T1):-
	list(T1),!,
	$cmp_occurs_in(T,T1).

$occurs_in(T,T1):-
	structure(T1),
	T1=F(Args..),
	$cmp_occurs_in(T,[F,Args..]).

$cmp_occurs_in(T,[]):-!,fail.
$cmp_occurs_in(T,[S,Ss..]):-$occurs_in(T,S),!.
$cmp_occurs_in(T,[S,Ss..]):-$occurs_in(T,Ss).

$frg_occurs_in(T,[]):-!,fail.
$frg_occurs_in(T,[V=T1,Fs..]):-$occurs_in(T,T1),!.
$frg_occurs_in(T,[_,Fs..]):-$frg_occurs_in(T,Fs).

%%%% T subsumes T1 
% if, after unifing T with T1, the generality of T1 has not changed.
% Seems reasonable for _T = f[_X, _Y] to subsume _T1 = f[_Y, _X], consequently,
% construct a varient of T/ST.

subsumes(T, T1) :-                          % T subsumes T1
     not(not($subsumes(T, T1))).            % Use not not so any bindings are not exported.

$subsumes(T, T1) :-                         % no duplicates were introduced.
     spanning_tree([T1], [ST], Unifys),     % Create varient of T1 (1st arg must be a nonvar);
     Unifys,                                % T1, and thus ST, may be cyclic. Determine generality of
     $var_list(ST, Vs, TVs),                % ST by the vars and tailvars it contains.
     $rm_dup(Vs, Vs1),                      % Remove any duplicates in the var and 
     $rm_dup(TVs, TVs1),                    % tailvar list. And snip - $rm_dup is non-deterministic.
     !,                                     % Attempt to unify T and ST, observing that on success Vs1
     (T = ST),                              % and TVs1 reflect any bindings. Remove any duplicates in 
     $rm_dup(Vs1, Vs2),                     % the var and tailvar list, snip, and reason as follows:
     $rm_dup(TVs1, TVs2), !,                % After the unify, T subsumes ST, and thus T1, IF
     $filter(Vs1,var),                      % Vs1 is still contains only vars
     $list_of_tailvars(TVs1),               % TVs1 is still a list of tailvars, and 
     breadth_first_compare([Vs1, TVs1],[Vs2, TVs2],@=).  % unification hasn't changed var lists

$list_of_tailvars([]):-!.                   % All done, remove choicepoint
$list_of_tailvars([[TV..], TVs..]) :-       % Get a supposedly tailvar
    tailvar(TV..),                          % Confirm it is indeed a tailvar
    $list_of_tailvars(TVs).                 % Recur to check out remainder

%%%% variables(Term, Variables, TailVariables, Constraints)
% Removing duplicates not without conflict: how does one determine number 
% of variable occurrances. Maybe want something that dosen't return constraints
% but rather, the variables, IN THE ORDER IN WHICH THEY OCCUR, left-right; this
% breadth 1st odd, and certainly hard to minic and consequencely not natural for Prolog 

variables(T, Vs, TVs) :-
    !,
    $var_list(T, Vs, TVs).                  % Get vars and tailvars

variables(T, Vs, TVs, Cs) :- 
    $var_list(T, Vs, TVs),                  % Get vars and tailvars
    $var_constraints(TVs, C1, []),          % Go get the constraints from tail variables 
    $var_constraints(Vs, Cs, C1).           % Go get the constraints from variables   

$var_constraints([], [E..], [E..]).
$var_constraints([V, Vr..], [freeze(V, C), Cs..], E) :- 
    $get_constraint(V, C1),!,
    $constraint_convert(C1, C),
    $var_constraints(Vr, Cs, E).	% L.C.O.
$var_constraints([V, Vr..], Cs, E) :- 
    $var_constraints(Vr, Cs, E).            % assume not[$get_constraint[_V,_C]]

$constraint_convert($freeze_simple(_, C), {C}) :-!.
$constraint_convert($freeze_simple2(P, Q), {P -> Q}) :-!.
$constraint_convert([C1, C2, X..], [C3, C4]) :-
    breadth_first_compare(X,[],@=),         % make sure it's not extensible
    !,
    $constraint_convert(C1, C3),
    $constraint_convert(C2, C4).
$constraint_convert(C, C).

%%%
%%% bind_vars - bind variables to their names
%%%

bind_vars(Term):-
    variables(Term,Vs,TVs),
    $rm_dup(Vs,DVs),
    $bind_vars(DVs),
    $rm_dup(TVs,DTVs),
    $bind_tvars(DTVs).

$bind_vars([]).
$bind_vars([X,Xs..]):-
    swrite(X,X),
    $bind_vars(Xs).

$bind_tvars([]).
$bind_tvars([X,Xs..]):-
    swrite(LS,X),          % write as list
    namelength(LS,L),       % length of list symbol
    XL is L-2,              % -2
    substring(LS,2,XL,XS),  % remove '[' and ']'
    [XS]=[X..],             % and unify symbol with tailvar
    $bind_tvars(Xs).

%%%
%%% Integer Utilities: integer_range and successor
%%%

%%% integer_range(Number, UpperBound, LowerBound)

integer_range(N,LB,UB):-
    integer(N,LB,UB),!,
    LB =< N,
    UB >= N.

integer_range(LB,LB,UB):-
    integer(LB,UB),
    LB =< UB.

integer_range(N,LB,UB):-
    NLB is LB + 1, 
	NLB =< UB,
	!,									 % cutexec
    integer_range(N,NLB,UB).			 % L.C.O


%%% successor(N, N + 1)    

successor(P,Q) :- integer(P), P >= 0, Q is P + 1, !.
successor(P,Q) :- integer(Q), Q > 0, P is Q - 1, !.

%%%
%%%   Symbol_Manipul - Symbol Manipulation Primitives
%%%

%%%% name                                            
name(Symbol, List) :-                         % Defined in base so as to be overloadable
    $name(Symbol, List).                      % Simply call the primitive

%%%% concat
concat(Sym1, Sym2, Sym3) :-                   % CASE: Both Sym1 and Sym2 bound, and possibly Sym3.
    nonvar(Sym1, Sym2),                       % Confirm both are nonvars (assume bound to symbols).
    !,                                        % Commit, don't want to ripple into following clause.
    $concat(Sym1, Sym2, Sym3).                % Call the primitive to do the work.

concat(Sym1, Sym2, Sym3) :-                   % CASE: Sym3 bound, and possibly one, but not both
    $name(Sym3, L3),                          % of Sym1 and Sym2. Get Ascii codes of Sym3.
    $s_to_l(Sym1, L1),                        % Optimization: If either Sym1 or Sym2 is bound,
    $s_to_l(Sym2, L2),                        % assume bound to a symbol and get Ascii codes.
    $append(L1, L2, L3),                      % Choice point. 
    $l_to_s(Sym1, L1),                        % Optimization: No sense calling $name unless 
    $l_to_s(Sym2, L2).                        % Sym1 and/or Sym2 is unbound.

$s_to_l(S,L):-nonvar(S),!,$name(S,L).	      % added for efficiency vs. if-then
$s_to_l(S,L).

$l_to_s(S,L):-var(S),!,$name(S,L).	          % added for efficiency vs. if-then
$l_to_s(S,L).

%%%% char_int
char_int(Char,Int) :- $name(Char,[Int]).

%%%% substring
% case 1: SSym is bound
substring(Sym, Ix, Len, SSym) :-
	symbol(Sym, SSym),							% both are symbols
	namelength(SSym, Len),						% they have to match
	Len > 0,
	!,											% cut to remove unwanted CP
	$strstr(Sym, 1, SSym, First),
	$substring_recursively(Sym, SSym, First, Ix).

$substring_recursively(Sym,SSym,First,First).
$substring_recursively(Sym,SSym,First,Next) :-
	Start is First+1,
	$strstr(Sym,Start,SSym,Index),
	!,
	$substring_recursively(Sym,SSym,Index,Next).

% case 2: SSym is unbound
substring(Sym, Ix, Len, SSym) :-
	var(SSym),
    namelength(Sym, SL),				 % Confirmation Sym is a symbol, and obtain its length.
    integer_range(Len, 1, SL),			 % Confirmation/generation of Len.
    integer_range(Ix,1, SL),			 % Generate an index.
    $substring(Sym, Ix, Len, SSym).		 % Call the primitive to do the work.

%%%
%%% State Space
%%%

%%%% new_state
% -- uses primitive $name, $new_state

new_state(N) :-                                     % New global state space
    !, $new_state(N).                               % Remove extra cp

new_state(N, Sn) :-                                 % New local state space, name must be $local
    $name(Sn, [36, 108, 111, 99, 97, 108]),			% ASCII code for $local
    $new_state(N, Sn).


%%%% remember/remembera/rememberz
% -- uses primitives new_obj, $zstoreobj, $new_state

remember(Struc,Sn..):-                              % Remember a structure
   new_obj(Struc,_,Sn..),!.                         % Use asserta store semantics 

remember(Struc,Sn..):-
   $ss_alloc(Sn..),                                 % make sure ss allocated
   new_obj(Struc,_,Sn..).                           % and try again

remembera(Struc,Sn..):-                             % Remembera a structure
   remember(Struc,Sn..).                            % Use asserta store semantics 

rememberz(Struc, Sn..) :-                           % Rememberz a structure
   $zstoreobj(Struc,_,Sn..),!.                      % Use assertz store semantics 

rememberz(Struc, Sn..) :-                           % Rememberz a structure
   $ss_alloc(Sn..),                                 % make sure ss allocated
   $zstoreobj(Struc,_,Sn..).                        % Use assertz store semantics 

% The following clause will be called if the new_obj/$zstoreobj call fails.
% It can fail if (1) Struc not a structure, (2) Sn not a valid state space
% name, (3) Mac is out of memory (state space can't grow) or (4) state space
% is not defined.  We can only fix (4) so try to create a state space if the
% current size is 0.
$ss_alloc(Sn..):-                                   % Cannot remember Struc immediately, So:
   new_state(N, Sn..),                              % Query size of state space Sn.
   N=0,                                             % N must be 0 (i.e., Sn not allocated/defined).
   $new_state(4, Sn..).                             % Allocate a tiny weeny one; Assume Sn valid name.


%%%% recall 
% -- uses primitives $ss

recall(P(Args..), Sn..) :-                          % Recall a structure unifiable with Struc
    $ss(Ptr, P, Q, Sn..),                           % lookup P in state space, returning Q
    Q(Args..),                                      % get body of P as if it's a clause
	$getPtr(Ptr).                                   % dummy call to force Ptr into e(1)

$getPtr(Ptr).

%%%% recallz  --  no longer supported
%%%% recallz(_..) :- write('recallz no longer supported -- see release notes').
    
%%%% object support
% -- uses primitives $ss

get_obj(Ptr, P(Args..), Sn..) :-
    $ss(Ptr, P, Q, Sn..),                           % lookup P in state space, returning Q
    Q(Args..),                                      % get body of P as if it's a clause
	$getPtr(Ptr),                                   % dummy call to force Ptr into e(1)
    !.                                              % only get first match

%%%% forget, forget_all
% -- uses primitives $ss

forget(P(Args..),Sn..) :-                           % Forget P(Args..) in state space Sn. 
    $ss(Ptr, P, Q, Sn..),                           % lookup P in state space, returning Q
    Q(Args..),                                      % get body of P as if it's a clause
	dispose_obj(Ptr, Sn..).                         % delete Ptr

forget_all(P(Args..), Sn..) :-                      % Forget all things unifiable with P(Args..).
    $ss(Ptr, P, Q, Sn..),                           % lookup P in state space, returning Q
    Q(Args..),                                      % get body of P as if it's a clause
	dispose_obj(Ptr, Sn..),                         % delete Ptr
    fail.                                           % Force backtracking to find another.
forget_all(_..).                                    % Always succeeds.

%%%% update
% -- uses primitives get_obj, put_obj

update(F(A1..), F(A2..), Sn..) :-                   % Update a structure unifiable with F(A1..) with
   get_obj(Ptr, F(A1..), Sn..),                     % structure F(A2..). 
   $objreplace(Ptr, F(A2..), F(A1..), Sn..).

$objreplace(Ptr, S, _, Sn..) :-                     % Put new term onto object pointer
   put_obj(Ptr, S, Sn..).                           % leave cp until committed
$objreplace(Ptr, _, S, Sn..) :-                     % failure, put original back in
   put_obj(Ptr, S, Sn..),
   fail.
 
%%%% inventory
% -- uses primitives $hashlist

inventory(P, Sn..) :-                               % Case: P is bound
    symbol(P),
    !,                                              % Commit to remove CP                 
    $ss(_, P, _, Sn..).                             % lookup P in state space, fails if no clauses

inventory(P, Sn..) :-                               % Case: P is unbound
   var(P),                                          % Confirm that P is indeed unbound
   $hashentry(0, L, Sn..),                          % Generate list of valid atoms
   $member(P, L),                                   % Return the items one at a time
   inventory(P, Sn..).                              % Make sure a clause exists for P

$hashentry(Index, L, Sn..) :-
    $hashlist(Index, List, Sn..),                   % Get list at Index, may fail if no more
	$hashnext(Index, List, L, Sn..).                % decide what to do with List
	
$hashnext(_, List, List, _..).                      % first, return List
$hashnext(Index, _, L, Sn..) :-                     % second, try next chain
    Index1 is Index+1,
    $hashentry(Index1, L, Sn..).

%%%
%%% findset and findall
%%%   (with some inspiration from 'Craft of Prolog', R. O'Keefe, 1990)
%%%

% findset(X,Q,[Xs..]) : 
%   Xs is the ordered set of all X such that Q is true

findset(X,Q,Xs):-
	findall(X,Q,B),	% collect the bag
	sort(B,Xs).		% then sort it (removes duplicates) 

% findall(X,Q,[Xs..]) : 
%   Xs is the list of all X such that Q is true

findall(X,Q,Xs):- 
    $get_vars(X,V1,TV1),	% collect vars and tailvars from X
    $get_vars(Q,V2,TV2),	% collect vars and tailvars from Q
    $xorlist(V2,V1,Vs),     % append var lists and remove common elements
    $xorlist(TV2,TV1,TVs),  % append tailvar lists and remove common elements
	new_obj(findall$(marker),_,$local),	% mark beginning of solution
	capsule($findall(X,Q,Xs,Vs,TVs), $findall_cleanup),
	!.

$findall_cleanup :-
	get_error_code(E),              % get reason for failure
	forget(findall$(S),$local),		% backtrack to get all solutions
	S = marker,                     % have we found the marker ??
	!,                              % yes, so commit
	error(E).                       % and regenerate the error

$findall_cleanup :-                 % somehow forget failed to find marker
	get_error_code(E),              % get reason for failure
	error(E).                       % and regenerate the error

$findall(X,Q,Xs,Vs,TVs):-			% first clause generates solutions
    Q,                              % execute Q
    $putsolution(X,Vs,TVs),
    fail.                           % backtrack for alternate solutions

$findall(X,Q,Xs,Vs,TVs):-          	% second clause collects answers
	forget(findall$(S), $local),
	!,                              % remove choicepoint in forget if more clauses
    $bagcollect(S,[],Xs,Vs,TVs).


$putsolution(X,Vs,TVs):-
    ground(X),!,                    % If X ground, 
    new_obj(findall$({X}),_,$local).	% then don't bother with Vs and TVs
$putsolution(X,Vs,TVs):-
    new_obj(findall$({X,Vs,TVs}),_,$local). % full var treatment


$bagcollect(marker,Xs,Xs,_,_).      % reached marker, collection done

% No vars in solution, just copy it
$bagcollect({X},[XS..],Xs,Vs,TVs) :- 
    forget(findall$(NX), $local),	% retrieve next solution
	!,	                            % remove all choicepoints from forget
    $bagcollect(NX,[X,XS..],Xs,Vs,TVs). % L.C.O.

% vars in solution, rebind unique vars with originals
$bagcollect({X,XVs,XTVs},[XS..],Xs,Vs,TVs):-
    $mergevars(XVs,Vs),			    % unify original vars and tailvars with copies
    $mergetvars(XTVs,TVs),
    forget(findall$(NX), $local),   % retrieve next solution
	!,	                            % remove all choiceponts from merges and forget
    $bagcollect(NX,[X,XS..],Xs,Vs,TVs). % L.C.O.

$get_vars(T,Vs,TVs):-
    variables(T,V1,TV1),	% suck out vars and tailvars
    $rm_dup(V1,Vs),			% and dedup lists
    $rm_dup(TV1,TVs).

$xorlist([],Zs,Zs).
$xorlist([X,Xs..],Ys,Zs):-
    $xoritem(Ys,X,Y1s),
    $xorlist(Xs,Y1s,Zs).

$xoritem([],X,[X]).
$xoritem([Y,Ys..],X,Ys):-
    breadth_first_compare(X,Y,@=),!.
$xoritem([Y,Ys..],X,[Y,Zs..]):-
    % not(breadth_first_compare(X,Y,@=)),
    $xoritem(Ys,X,Zs).

% unify corresponding variables with variables in the respective lists
$mergevars([],[]).
$mergevars([X,Xs..],[V,Vs..]):-
	var(X,V),
	X=V,
	$mergevars(Xs,Vs).
$mergevars([X,Xs..],[V,Vs..]):-
	% not(var(X,V)),
	$mergevars(Xs,Vs).

% unify corresponding tailvariables with tailvariables in the respective lists
$mergetvars([],[]).
$mergetvars([X,Xs..],[V,Vs..]):-
	tailvar(X..),tailvar(V..),
	X=V,
	$mergetvars(Xs,Vs).
$mergetvars([X,Xs..],[V,Vs..]):-
	% not([tailvar(X..),tailvar(V..)]),
	$mergetvars(Xs,Vs).

% cleanup routine for findall and findset, called incase of aborts, etc.
$cleanup:-
	forget_all(findall$(_),$local),
	fail.	% fail to allow other $cleanup procedures to execute

%%%
%%% Counters, etc.
%%%

%%%% new_counter/counter_value
%%%% counter values are always a long int, use 'is' to make it useable
%%%% new_counter/$counter implemented as primitives

counter_value($counter($counter(X)), V) :-
    V is X.


%%% count the number of solutions of Goal

count(Goal, NumSoln) :- 
    new_counter(0, Cntr),
    $count1(Goal, Cntr),
    counter_value(Cntr, NumSoln).

$count1(Goal, Cntr) :- 
    Goal,
    Cntr,
    fail.
$count1(_, _).


%%% count the number of solutions of Goal, but stop at MaxSoln if necessary      

count(Goal, NumSoln, MaxSoln) :- 
    integer(MaxSoln), MaxSoln > 0,
    integer(NumSoln) -> [NumSoln >= 0, NumSoln =< MaxSoln],
    new_counter(0,Cntr),
    [Goal, Cntr, counter_value(Cntr,V), V=MaxSoln, NumSoln=MaxSoln] ;
	counter_value(Cntr,NumSoln),
	!.                                  % remove cp's


%%%% nth_solution     To get the Nth solution of a given goal

nth_solution(Goal, N) :-                % Get all solutions of Goal
    integer(N), N>0, !,                 % find particular solution
    new_counter(0,Cntr),                % Create a counter
    Goal,                               % Solve Goal
	Cntr,                               % Increment counter
	counter_value(Cntr, N),             % does counter correspond to N
	!.									% commit

nth_solution(Goal,N) :-                 % Get all solutions of Goal
    var(N),                  			% In case user passes in garbage
    new_counter(0,Cntr),                % Create a counter
    Goal,                               % Solve Goal 
	Cntr,                               % Increment counter
	counter_value(Cntr, N).             % get counter value


%%%
%%% Globals
%%%

%%%% new_global
% To get a $global(_V) where _V is a constant - not variable bound to a constant
% N.B. use same functor name as counters so single $cleanup routine is sufficient. 

new_global(InitVal, $global(X)) :- 
    new_obj(counter$(InitVal),X,$local);
	[dispose_obj(X,$local),fail].	% backtracking removes counter and fails

%%% global_value : read value of global
global_value($global(X), V) :-
    get_obj(X, counter$(V), $local).

%%% set_global : write value of global
set_global(Val,$global(X)) :-
    put_obj(X, counter$(Val), $local).


%%% cleanup routine for counters and globals, can be called when variable bound to 
%%%   global can no longer exist, e.g., in listener loop.

$cleanup:-		% cleanup routine for aborts and downstream cuts which remove
	forget_all(counter$(_),$local),		% 	';' choicepoint in new_counter
	fail.		% fail to other $cleanup routines.

memory_status([HT,HU],[ET,EU]) :-
      !,
      $memory_status(HT,HU,ET,EU).

memory_status([CT, CU, CM], [HT, HU, HM], [ET, EU, EM], [ST, SU, SU]) :-
	$memory_status(CT, CU, CM, HT, HU, HM, ET, EU, EM),
	$statestatus(ST, SU).

statespace_status(Total,Used,SS..) :- $statestatus(Total,Used,SS..).

delay(Seconds) :- $delay(Seconds, 1).

sleep(Seconds) :- $delay(Seconds, 0).

%%%
%%% Base Utilities for Ring 1 and up
%%%

% identity membership
$strict_member(X, [Y, _..]) :- breadth_first_compare(X,Y,@=).
$strict_member(X, [_, Ys..]) :- $strict_member(X, Ys). 

% unification membership
$member(X, [X, Xs..]).
$member(X, [_, Xs..]) :- $member(X, [Xs..]).         

% standard non-deterministic append
$append([],[Rest..],[Rest..]).
$append([X,Xs..],[Rest..],[X,Rest2..]):-
    $append(Xs,Rest,Rest2).

% remove duplicates in a list
$rm_dup([], []).                            % All done
$rm_dup([V, Vs..], RVs) :-                  % Assume V is a member of Vs, so toss V and
    $strict_member(V, Vs),                  % confirm it is a member of the remaining list.
    $rm_dup(Vs, RVs), !.                    % Recur
$rm_dup([V, Vs..], [V, RVs..]) :-           % Get a var in the list, and to conserve store,
    $rm_dup(Vs, RVs).                       % Recur

% isolate the tail variable at the end of an indefinite list (fails on definite lists)
$gettail([T..],[T..]):-tailvar(T..),!.
$gettail([_,T..],Last):-$gettail(T,Last).

% get the R.H.S. of the unification that matches Match in a unification list
%	from decompose or spanning tree
$getunify(Match,[V=Loop,Us..],Loop):-
	breadth_first_compare(Match,V,@=).
$getunify(Match,[U,Us..],Loop):-$getunify(Match,Us,Loop).


$tick :-                        %% called whenever a timeout occurs from enable_timer
	get_obj(Op,tick_masked(_),$local),  % ticks are masked
	!,
	put_obj(Op,tick_masked(1),$local).  % set tick pending flag
$tick :-
    tick,                     	        %% execute user code if it exists
	cut,						        %% remove all choicepoints from tick
    fail.            			        %% fail to recover space
$tick :-
    $reenable_timer.                    %% allow the timer interrupt to occur again

$mask_tick(Flag) :-                     % with variable, query current state of mask
	var(Flag),
	$check_mask_tick(Flag),
	!.
$mask_tick(0) :-                        % with 0, reenable tick
	forget(tick_masked(1),$local),      % tick pending
	!,                                  % so
	$tick.                              % execute tick now
$mask_tick(0) :-                        
	forget(tick_masked(_),$local).      % clear tick mask
$mask_tick(1) :-                        % with 1, mask ticks
	recall(tick_masked(_),$local),!.    % already masked
$mask_tick(1) :-
	remember(tick_masked(0),$local).    % set tick mask

$check_mask_tick(1) :- recall(tick_masked(_),$local).
$check_mask_tick(0).


%%% Added 93/05/21 JR to handle constrained variable to constrained variable binding
%%%                   Special handling of two interval constraints

$combinevar(V1, C1, V2, C2) :-
	var(V1, V2),			% might have changed by a subsequent binding
	!,
	$splitconstraint(C1, IntervalPart1, Rest1),
	$splitconstraint(C2, IntervalPart2, Rest2),
	$$combinevar(V1, V2, IntervalPart1, Rest1, IntervalPart2, Rest2),
	!.						% remove choicepoints in $$combinevar and $$$combine
$combinevar([V1..], C1, [V2..], C2) :-
	tailvar(V1..),			% might have changed by a subsequent binding
	tailvar(V2..),
	!,
	$splitconstraint(C1, IntervalPart1, Rest1),
	$splitconstraint(C2, IntervalPart2, Rest2),
	$$combinevar(V1, V2, IntervalPart1, Rest1, IntervalPart2, Rest2),
	!.						% remove choicepoints in $$combinevar and $$$combine
$combinevar(V, _, V, _).

$splitconstraint([Interval, Rest..], Interval, [Rest..]) :-
	$checkifinterval(Interval), !.
$splitconstraint([Rest..], [], [Rest..]) :-
	!.
$splitconstraint(Interval, Interval, []) :-
	$checkifinterval(Interval), !.
$splitconstraint(Rest, [], [Rest]) :-       % make a list out of the single item
	!.

%%% Added 93/07/20 JR since using F(Args..), F(Args..) in $splitconstraint
%%%                   sometimes forced the interval constraint to get broken
%%%                   up with a tailvar (i.e. hdr(arity -2), F, TV --> Args..)
$checkifinterval(F(Args..)) :- 
	$$interval_type(F, _).

$$combinevar(V1, V2, [], Rest1, [], Rest2) :-		% no interval constraints
	$$$combine(Rest1, Rest2, NewCons),				% combine remaining constraints
	$joinvar(V1, V2, NewCons).						% make a new var with the constraint, bind others to it
$$combinevar(V1, V2, Cons1, Rest1, [], Rest2) :-	% interval constraints only on V1
	$$$combine(Rest1, Rest2, [NewCons..]),
	$joinvar(V1, V2, [Cons1, NewCons..]).			% put interval constraint first
$$combinevar(V1, V2, [], Rest1, Cons2, Rest2) :-	% interval constraints only on V2
	$$$combine(Rest1, Rest2, [NewCons..]),
	$joinvar(V1, V2, [Cons2, NewCons..]).			% put interval constraint first
$$combinevar(V1, V2, Cons1, Rest1, Cons2, Rest2) :-	% interval constraints on both
	V1 == V2.			% when they become a point both will fire

% combine two sets together - note that both sets being [] should never occur
$$$combine([], Rest2, Rest2).						% one list is empty
$$$combine(Rest1, [], Rest1).
$$$combine([Rest1], [Rest2..], [Rest1, Rest2..]).   % first list contains only 1 thing
$$$combine([Rest1..], [Rest2], [Rest2, Rest1..]).   % second list contains only 1 thing
$$$combine(Rest1, [Rest2..], [Rest1, Rest2..]).		% both lists contain multiple items,
													% combine simply (could use append to make one big list)
