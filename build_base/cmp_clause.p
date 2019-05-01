/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/cmp_clause.p,v 1.4 1996/02/13 04:18:28 yanzhou Exp $
*
*  $Log: cmp_clause.p,v $
 * Revision 1.4  1996/02/13  04:18:28  yanzhou
 * The version numbers of the compiler and the code generator are increased:
 *     compiler from version 25 to version 26,
 *     code generator from time stamp Oct/31/1991 to Feb/15/1996.
 *
 * Revision 1.3  1996/02/05  06:55:10  yanzhou
 * Permanent variables are now initialized on the heap as well.
 *
 * BNRProlog V4 inherited from the WAM practice of initializing new
 * permanent variables as self-referential pointers on the environment
 * stack.  It was a BAD IDEA, because every place one chases a var
 * chain has to deal with it, hence the unsafe op-codes like unif_unsaf,
 * push_unsaf and putunsaf are needed.  Life is much simpler without it.
 *
 * Changes made to stop allocating permanent variables on the env stack
 * are:
 *
 *   1) in core.c, put_varp is changed from:
 *         put_varp(P,A) :- temp[A] <- ce[P] <- (var | address(ce[P]))
 *      to:
 *         put_varp(P,A) :- temp[A] <- ce[P] <- (var | hp <= hp)
 *
 *   2) in cmp_clause.p, when a new $var structure is constructed by
 *      $var_constructor, it now has "very_safe" as its default safety
 *      value, which  stops compile_clause/3 from generating any
 *      unsafe op-codes (eg., push_unsafp, putunsaf, etc.)
 *
 * Revision 1.2  1996/02/02  07:43:25  yanzhou
 * Typo fixed.
 *   In $flatten, an extra ',' is removed.
 *
 * Revision 1.1  1995/09/22  11:23:07  harrisja
 * Initial version.
 *
*
*/
%
%
%       modified WAM clause compiler
%
%  register allocation (scoreboarding) for temp and permanent vars
%
cwamversion('version 26').
%  June 1994 - compiler trace removed  wjo
%                           utilities
%tr :- fail.				%% should succeed if tracing required
$nonmember([TV..],_):-tailvar(TV..),!.
$nonmember([],_).
$nonmember([X,Xs..],Y):-freeze(X,freeze(Y, X=\=Y)),$nonmember(Xs,Y).

/*  old version :  $nonmember([X,Xs..],Y):-{X=\=Y},$nonmember(Xs,Y).
    replaced march 94 to avoid interaction with {}-CLP */

$get_end( [TV..],[TV..]):- tailvar(TV..),!.
$get_end( [_,Xs..],End):- $get_end(Xs,End).

$call_arity(F(A..),N):- $$c_arity([A..],0,N).
$$c_arity( [TV..],N,M):-tailvar(TV..),!, M is - (N + 1),!. %  count tvar
$$c_arity( [],N, N).
$$c_arity( [TV],N,M):-nonvar(TV),TV=$tvar(_..), M is - (N + 1),!. %  count tvar
$$c_arity( [_,Xs..],N,M):- N1 is N + 1,$$c_arity(Xs,N1,M).


% arity - counts princ. functor but not tailvars - used in structure headers
$arity( F(A..),N):- !, $$c_arity([A..],1,N),!. %include princ functor
$arity( [L..], N):-    $$c_arity(L,0,N),!. 

% $copy(X,X):- code_only,!.           %??? no need to copy when no comments
$copy(X,Y) :- decompose(X,Y,L), L.  % needed when generating comments

%     $trace( Msg, Data):-tr,nl, write(Msg,':',Data).
$trace(_,_).
%   labels have form:functor(arity, hash):-
$label_clause( F(A..), F(Ar,H)) :- $$h_arity( A,0,Ar), $hashkey(A,H),!.
$$h_arity( [TV..],N,M):-tailvar(TV..),!, M is - (N + 1),!. %  count tvar
$$h_arity( [],N, N).
$$h_arity( [_,Xs..],N,M):- N1 is N + 1,$$h_arity(Xs,N1,M).

$hashkey( [V..], _):- tailvar(V..),!.       % ???
$hashkey( [F,_..],F):-nonvar(F),!.
$hashkey(  _,_).

%
%       varmap utilities
%
%   $var/$tvar[ name,[first,last mention], perm/temp,nonvoid,bound, safe]
$var_constructor(Index,Void,  $var(Name,[First,Last],Perm, Void, Bound,very_safe)):-
    $dif_block(Index,Last,Perm).
$tvar_constructor(Index,Void,[$tvar(Name,[First,Last],Perm,Void, Bound,very_safe)]):-
    $dif_block(Index,Last,Perm).
% active constraints used to set first mention
$first_occurred( _(Nam,[First,_],_..),First):-!. 
$first_occurred([ _(Nam,[First,_],_..)],First):-!. 
$dif_block(I,I,Temp):-!. % same block-leave as var
$dif_block(_,_,p).       % different- mark as permanent


%    for adding temporary variables used to decompose structures
$addtemp(V,Indx, Varmap):- var(V),
    V=$var(Link,[Indx,Indx],t,nonvoid,Bound, link).

%   numbering variables

$gen_name(N,Nm,N   ):- Nm is N + 1.         % constraints fire here!
$gen_name(N,Nm,Name):- N1 is N + 1, $gen_name(N1,Nm,Name).

$number_temps( [], T, N):- !,$number_temps2(T,N).
$number_temps( [J,Xs..],T, N):- integer(J),!, $number_temps(Xs,T,N).
$number_temps( [N,Xs..],T, N):- N1 is N + 1,$number_temps(Xs,T,N1).     
$number_temps2([],N ):-!, $ncheck(N).
$number_temps2([_(X,_..),Xs..],N):- var(X),!, 
    $gen_name(N,N1,X),!, N1=<255,     
    $number_temps2(Xs,N1).
$number_temps2([_(X,_..),Xs..],N):- % skip since already numbered 
    $number_temps2(Xs,N).

$ncheck( N ):- N =< 255,!.
$ncheck( N) :- nl, write( 'Too many temporary variables required ',N), nl,failexit(compile_clause).


%
%           phase 1- classify vars  (makes lists of perm and temp vars)
%
$first_occurs( [], Indx ).
$first_occurs( [V,Vs..],Indx):- variables(V,_,_,Cns),
                                Cns@=[]->freeze(V,$first_occurred(V,Indx)),
                                $first_occurs(Vs,Indx).


$addvars( [],       _,     End,  End).
$addvars( [V,Vs..], Index, List, End) :- nonvar(V),!, 
    $var_constructor(Index,nonvoid,V),              % mark as permanent if used in dif blocks
    $addvars(Vs,    Index, List , End).
$addvars( [V,Vs..], Index, [V,List..], End) :- var(V),!, % last (rightmost) occurrence
    $var_constructor(Index,Void,V),              
    $addvars(Vs,    Index, List , End).


$addtvars( [],       _,     End,  End).
$addtvars( [V,Vs..], Index, List, End) :-
    $addtvar(V,List,List1),
    $tvar_constructor(Index,nonvoid,V),  % mark as permanent if used in dif blocks
    $addtvars(Vs,    Index, List1 , End). % treat as nonvoid since variables does not track occurrences
$addtvar( [V..], L,L) :- not(tailvar(V..)),!. % first (rightmost) occurrence
$addtvar( [V],[V,L..],L).

$form( (H :- [B1, Bs..]),  [(H:-B1),Bs..] ).
$form( (H :- []), [H]).

%    varmap splitting
$split( [], [],[_..],W,W):-!.    % Note: 2nd (temps) output indefinite
$split( [X,Xs..],[Ys..],[X,Zs..],Ws,W):- $temp(X),!,
    $split(Xs,Ys,Zs,Ws,W).
$split( [X,Xs..],[X,Ys..],[Zs..], [X,Ws..],W):- $perm(X),
    $split(Xs,Ys,Zs,Ws,W).
$temp(_(_,_,t,_..)).
$perm(_(_,_,p,_..)).

%  amalgamate before numbering
$number_perms([],N,N):- N =< 256. % N is first unused number
$number_perms([X, Xs..],N,M):-
	$assign(X,N,N1),
%   $amalgamate( Xs ,X, Ys), $number_perms(Ys,N1,M).
    $number_perms(Xs,N1,M).
% $assign(_(M,_..),N,N):- integer(M),!.
$assign(_(N1,_..),N,N1):- N1 is N + 1.

/****
$amalgamate( [], _, []).
$amalgamate( [_(V,[F,L],_..), Xs..], _(V,[F0,L0],_..), Ys):- L<F0,!,
        $amalgamate( Xs, _(V,[F,L0],_..), Ys).
$amalgamate( [X,Xs..],Y, [X,Ys..]):-$amalgamate(Xs,Y,Ys).

$compress( [] ).
$compress( [X,Xs..]) :- $amalgamate( Xs,X,Ys),!, $compress(Ys).
*****/

$split_map( [],P, [], 0).    % :- $compress(P).               
$split_map( [ [Indx,List], Rest..],PE, [[Indx,Nstart,T], R..],Nfinish):-
    $split( List, Perms, T , P, PE),
    $split_map( Rest, P, R, Nstart ),     $trace( envsize,Indx:Nstart),
    $number_perms(Perms,Nstart,Nfinish).


$classify_vars( F,Varmap, NeedsEnv):-
    $form( F, H),!,
    $collect_vars( H, VM ,1, Meta),             % mark head and first goal as 0    
    $split_map(   VM,_, Varmap, Tot_perms),       $trace( '#perms', Tot_perms),
    $env_decision( H, Meta,Tot_perms, NeedsEnv),!.
        % need s environment if
        %  any permanent vars or meta calls or more than one call on rhs


%  $collect_vars( Termlist, Varmap, Index_start, Meta)
$collect_vars( [],  [],     N,      _).
$collect_vars( [T,Ts..],[[N,Vs], NVs..],N, Meta):- symbol(T),!, N1 is N + 1,
    $collect_vars(Ts,NVs,N1,Meta).
$collect_vars( [T,Ts..],[[N,Vs], NVs..],N,Meta):- structure(T),  $meta(T,Meta),
    N1 is N + 1,
    variables(T,VList,TVlist,_),       %  might have  constraints 
    $first_occurs(VList,N), $first_occurs(TVlist,N),
    $collect_vars(Ts,NVs,N1,Meta),  % collect ir reverse call order
    $addvars(VList,  N, Vs, VL1),
    $addtvars(TVlist,N, VL1,[] ).

$meta( $comp_block(_..), meta):-!.   % if any meta calls, then must have enviornment
$meta(_,_).
$notmeta( H :- $comp_block(_..)):- !,fail.  % for first meta call on right
$notmeta(_).
$env_decision([X],no_meta,N, no_env):-N<1, $notmeta(X).   % if any perm vars, needs environment
$env_decision(_, _, _,    needs_env).


%
%   normalform( Structure,Tvarmap, FlatStructure, List, Index, Direction)
%     where list is of form  [V1=S1,V2=S2...]
%     (where Direction = bottomup or topdown, left to right order, with Sn also flat)
%     ( flatstructure means nesting to one level only)

$normalform( F(A..), TempV, F(B..), List,End, Indx, Dir):-!,
    $flatten( [A..], TempV, [B..], List,End, Indx, Dir),!.
$normalform( [A..], TempV, [B..], List,End, Indx, Dir):-
    $flatten( [A..], TempV, [B..], List,End, Indx,Dir),!.

$cons( [X..], T, Y,      [X..], T=Y     ).
$cons( F(X..),T, [Y..],  [X..], T=F(Y..)).

$simple( X, _) :- not( compound(X)).
$simple( $var(_..),_).
$simple( $tvar(_..),_).
$simple( [] ,_).
$simple( [$tvar(A1,A2,A3,A4,B,S)], bottomup) :- 
    B@=1,	% removed 92/07/23 to handle p :- q([X..], [X..]), doesn't work
    S@=very_safe.

$$append_sub( bottomup,  R, Xs, [R,Xs..], Ys,Ys).
$$append_sub( topdown,   R, Xs, Xs, Ys, [R,Ys..]).

%       $flatten(In, TempVarmap,Out, Diflist,Index)
$flatten( [], _, [], End,End,_ , D):-!.
$flatten( [X,Xs..], TV, [X,Ys..], List,End,Indx,D):- $simple(X,D),!,    % constants, vars,tvars,[]
    $flatten(Xs,TV,Ys,List,End,Indx,D).
$flatten( [X,Xs..],TV, [T,Ys..], List1,End,    Indx , Dir):- compound(X),
    $cons(X,T,Y,X1, Res),!, $addtemp( T,Indx,TV), 
    $$append_sub(Dir,Res, Rest, Rest1, List, List1),!,
    $flatten( X1,  TV, Y,  List, Rest1,Indx, Dir),
    $flatten( Xs,  TV, Ys, Rest, End,  Indx, Dir).    
%
%
%                instruction building utilities   
%
%           call instructions
%  $gen_call(Op,tail, Env, Sizeofenv, Code):-
$gen_call(true(),   tail,     _       ,     _  ,  proceed     ).
$gen_call(true(),   not_tail, _       ,     _  ,  []          ).
$gen_call('!'(),    not_tail,needs_env,   Size ,  ecut(Size)  ).
$gen_call('!'(),    tail,    _        ,     _  ,  cutreturn   ).
$gen_call('!'(),    not_tail, no_env,       _  ,  dcut        ).
$gen_call(fail(),   tail   , _        ,     _  ,  fail        ). 
$gen_call(fail(),   not_tail,_        ,     _  ,  _           ):- nl, write( 'fail not at end'),
        failexit(compile_clause).
$gen_call(cut(),    not_tail, needs_env, Size  ,  ccut(Size)  ).
$gen_call(cut(),    tail    , needs_env,    _  ,  cdcutreturn ).
$gen_call(cut(),    not_tail, no_env,       _  ,  cdcut       ).
$gen_call(failexit(),tail,    _ ,           _  ,  cdcutfail   ).
$gen_call(failexit(),not_tail,_        ,    _  ,  _           ):-nl, write( 'failexit not at end'),
        failexit(compile_clause).
  %  $gen_call(failexit(),not_tail,needs_env,    _  ,  ccutfail).
  %  $gen_call(failexit(),not_tail,no_env,       _  ,  cdcutfail).
$gen_call(F(A..),   not_tail, needs_env,   Size,  call(F/N,Size) ):- $call_arity(F(A..),N).
$gen_call(F(A..),   tail       ,_,          _ ,   exec(F/N)   ):-$call_arity(F(A..),N).
$gen_call(F(A..),   cuttail    ,_,          _ ,cutexec(F/N)   ):-$call_arity(F(A..),N).
 
%           allocation/deallocation  of environment
$allocation( needs_env, finalcut, [gcalloc,X..], X):-!. %garbage collection enabled
$allocation( needs_env,  _, [alloc,X..], X):-!.
$allocation( _  ,_            ,    X,  X).    

$deallocation(tail,needs_env,  [dealloc,X..],X):-!.
$deallocation(cuttail,needs_env,  [dealloc,X..],X):-!.
$deallocation(_ ,_       ,              X,   X).
%

%  utilities for building var instructions 
%
%      first vs later occurrences in put/get instructions
$occurrence(B,'_var', S, Dir) :- var(B),!,B=1, $safety(Dir,S),!.
$occurrence(1,'_val', _, _  ) :- !.
$occurrence(2,'_val', link, put).

$safety(_    , very_safe).  % arith, get of tailvar
$safety(_    , link).

%     occurrences in unif/push instructions
$sub_occurrence(B,'_var',  very_safe):-var(B),!,B=1.
$sub_occurrence(B,'_var',  link     ):-var(B),!,B=1.
$sub_occurrence(1,'_val',  _  ).

$sub_safety( very_safe).        % set to very safe (if possible)
$sub_safety( _ ).

%   symbol concatenation database
$vsuffix( '_var', t, '_vart').
$vsuffix( '_var', p, '_varp').
$vsuffix( '_val', t, '_valt').
$vsuffix( '_val', p, '_valp').

$getsuffix( '_vart', get_vart).
$getsuffix( '_varp', get_varp).
$getsuffix( '_valt', get_valt).
$getsuffix( '_valp', get_valp).

$putsuffix( '_vart', put_vart).
$putsuffix( '_varp', put_varp).
$putsuffix( '_valt', put_valt).
$putsuffix( '_valp', put_valp).

$unifsuffix( '_vart', unif_vart).
$unifsuffix( '_varp', unif_varp).
$unifsuffix( '_valt', unif_valt).
$unifsuffix( '_valp', unif_valp).

$pushsuffix( '_vart', push_vart).
$pushsuffix( '_varp', push_varp).
$pushsuffix( '_valt', push_valt).
$pushsuffix( '_valp', push_valp).

%     X_var_instruction(Void, Permanent, Bound, Safe, Ins)
$get_var_instruction(void, t, 1, very_safe, get_void):-!.
$get_var_instruction(Vd,   P, B, S,   Ins):-  
    $occurrence(B, Occ, S,get), 
    $vsuffix(Occ,P, Suf),
    $getsuffix(Suf,Ins),!.
$put_var_instruction(void,  t, 1, very_safe, put_void):-!.
$put_var_instruction(Vd,    P, B, S,   Ins):-  
    $occurrence(B, Occ, S, put), 
    $vsuffix(Occ,P, Suf),
    $putsuffix(Suf,Ins),!.


$unif_var_instruction(void, t, 1, very_safe, unif_void):-!.
$unif_var_instruction(Vd,   P, B, S,   Ins):-  
    $sub_occurrence(B, Occ, S), 
    $vsuffix(Occ,P, Suf),
    $unifsuffix(Suf,Ins),!.

$push_var_instruction(void,  t, 1, very_safe, push_void):-!.
$push_var_instruction(Vd,    P, B, S,   Ins):-  
    $sub_occurrence(B, Occ, S), 
    $vsuffix(Occ,P, Suf),
    $pushsuffix(Suf,Ins),!.


$get_var_ins(V,Src,Vd,P,B,S,Code):-  % get_var
    $get_var_instruction(Vd,P,B,S,UC),
    $reg_optimiz_get( UC(V,Src),Code),!.
$put_var_ins(V,Src,Vd,P,B,S,Code,Hd):-  % put_var
    $put_var_instruction(Vd,P,B,S,UC),
    $reg_optimiz_put( UC(V,Src),Code,S,Hd),!.

%
$reg_optimiz_get( get_void(V,V),  []).  % noop for unused var in args
$reg_optimiz_get( X,X).

$reg_optimiz_put( put_valt(V,V), [],S,Hd):-
    S@=link ; $nonmember(Hd,V). 
$reg_optimiz_put( put_void(V,V), put_void(V),_,_).
$reg_optimiz_put( X,X,_,_).

$unif_var_ins(V,Vd,P,B,S,Code):-
    $unif_var_instruction(Vd,P,B,S,UC),
    $reg_optimiz_unif( UC(V),Code),!.

$push_var_ins(V,Vd,P,B,S,Code):-
    $push_var_instruction(Vd,P,B,S,UC),
    $reg_optimiz_push( UC(V),Code),!.

%  eliminate var references from void instructions
$reg_optimiz_unif( unif_void(V),   unif_void).
$reg_optimiz_unif( tunif_void(V),  tunif_void).
$reg_optimiz_unif( X,X).

$reg_optimiz_push( push_void(V),   push_void).
$reg_optimiz_push( tpush_void(V),  tpush_void).
$reg_optimiz_push( X,X).
%
%                 mapping terms
%
%   $unify and $push( Term, code)  handles substructures (Vars,Tvars,Cons)
$comp_unify( $var(V,_,P,Vd,B,S),  Code) :-!,$unif_var_ins(V,Vd,P,B,S,Code).
$comp_unify([$tvar(V,_,P,Vd,B,S)],Code) :-!,$unif_var_ins(V,Vd,P,B,S,Code). 
$comp_unify(  Cons,   unif_cons(Cons)).          

$push( $var(V,_,P,Vd,B,S),  Code) :-!,$push_var_ins(V,Vd,P,B,S,Code).
$push([$tvar(V,_,P,Vd,B,S)],Code) :-
    B@=1,!,$push_var_ins(V,Vd,P,B,S,Code).   % not first occurrence
$push(  Cons,    push_cons(Cons)).           

% subsequences:  unif/push instructions
$map_sub_unify([],                    [end_seq],L,L).
$map_sub_unify([$tvar(V,_,P,Vd,B,S)], [Code], L,L):-!,            % tunif_
    $unif_var_instruction(Vd,P,B,S, UC1), swrite(UC,'t',UC1),
    $reg_optimiz_unif( UC(V), Code).
$map_sub_unify([$var(V,_,P,Vd,B,S),Xs..],[Code,Ys..], [V,LI..], LO):- S@=link,!,    %busy        
            $unif_var_ins(V,Vd,P,B,link,Code),!, 
            $map_sub_unify(Xs,Ys,LI,LO).
$map_sub_unify([X,Xs..],[Y,Ys..],LI,LO):- $comp_unify(X,Y),!, $map_sub_unify(Xs,Ys,LI,LO).

$map_sub_push([],                    [push_end],L,L).
$map_sub_push([$tvar(V,_,P,Vd,B,S)], [Code], L,L):-!, 
    $push_var_instruction(Vd,P,B,S, UC1), swrite(UC,'t',UC1),
    $reg_optimiz_push( UC(V), Code).
$map_sub_push([$var(V,_,t,Vd,B,S),Xs..],[Code,Ys..],LI,LO):- S@=link,nonvar(B),!,
            B@=1 -> L2=[V,LI..] ; L2=LI,    % free up unless used in tailvar optimization
            $push_var_ins(V,Vd,t,1,link,Code),!, 
            $map_sub_push(Xs,Ys,L2,LO). 
$map_sub_push([X,Xs..],[Y,Ys..],LI,LO):- $push(X,Y),!, $map_sub_push(Xs,Ys,LI,LO).

%  $getsub - get subsequences
$getsub( [],     Src, [get_nil(Src)], LV,LV):-!. 
$getsub( [$tvar(V,_,P,Vd,B,S)],Src, Code,LV,LV):-B@=1, nonvar(S),!, % if not first occurrence
       $get_var_ins(V,Src,Vd,P,B,S, Code).    %  and not unsafe then do tailvar optimization
$getsub( [L..],  Src, [get_list(Src),C..] ,LI,LO):- !, $map_sub_unify( L,  C,LI,LO).
$getsub( F(L..), Src, [get_struc(N,Src),C..],LI,LO):-
            $arity(F(L..),N), $map_sub_unify([F,L..],C,LI,LO).

%  $putsub - put subsequences
$putsub( [],     Src, [put_nil(Src)]     ,   L,L,_ ):-!. 
$putsub( [$tvar(V,_,P,Vd,B,S)],Src, Code ,   L,L,Hd):- B@=1,nonvar(S),!,  % if not first occurrence
        $put_var_ins(V,Src,Vd,P,B,S, Code,Hd).     %  and not unsafe then do tailvar optimization
$putsub( [L..],  Src, [put_list(Src),C..],   LI,LO,_):- !, $map_sub_push( L,  C,LI,LO).
$putsub( F(L..), Src, [put_struc(N,Src),C..],LI,LO,_):- $arity(F(L..),N), 
        $map_sub_push( [F,L..],  C,LI,LO).

%   xform( Term,  Src, Code,Indx, Direction)
%   (put/get instructions)
 
$xform_get($var(V,_,P,Vd,B,S),Src, Code, _ ,LI,LI):-!, $get_var_ins(V,Src,Vd,P,B,S, Code).
$xform_get($tvar(V,_,P,Vd,B,S),Src, Code, _,LI,LI):-!, %tvar in head 
                    $get_var_ins(V,Src,Vd,P,B,S, Code).
$xform_get( Sub,   Src,   Code,       _ ,LI,LO):-compound(Sub),!, 
                    $getsub( Sub, Src, Code,LI,LO).
$xform_get( Cons,  Src,  get_cons(Cons,Src),_ ,L,L):- not(compound(Cons)).

$xform_put($var(V,_,P,Vd,B,S), Src, Code,_, L,L,Hd):-!, $put_var_ins(V,Src,Vd,P,B,S, Code,Hd).
$xform_put($tvar(V,_,P,Vd,B,S),Src, Code,_, LI,LO,Hd):-!, %tvar in call
          %  and not unsafe then do tailvar optimization
       $putsub( [$tvar(V,L,P,Vd,B,S)],Src,Code,LI,LO,Hd).
$xform_put( Cons,  Src,  put_cons(Cons,Src),_,L,L,_):- not(compound(Cons)),!.
$xform_put( Sub,   Src,   Code,_,  LI,LO,Hd):-compound(Sub),    % not needed?
       $putsub( Sub, Src, Code,LI,LO,Hd). 

%  for handling decomposition sequences
$map_gets( [], [X..], X, L,L).
$map_gets( [$var(R,_,t,_,1,link)=S, Xs..],[Code,Cs..],  End, LI,LO):- 
        $getsub(S,R,Code,[R,LI..],L2),!, %free R
        $map_gets( Xs,Cs, End, L2,LO). %free up reg

$map_puts( [], [X..], X, L,L).
$map_puts( [$var(R,_,t,_,2,link)=[$tvar(V,_,t,Vd,B,S)], Xs..],[Code,Cs..], End,L,LO):- 
        B@=1, nonvar(S),!, %  dont  busy R as will not be used- '2'=Bound inhibits freeing later
        $put_var_ins(V,R,Vd,t,B,S, Code,[]),      %   do tailvar optimization
        $map_puts( Xs,Cs, End,L,LO).
$map_puts( [$var(R,_,t,_,1,link)=S, Xs..],[Code,Cs..], End,[R, L..],LO):- 
        $putsub(S,R,Code,L,L2 ,[]),!,                     % ^  busy R
        $map_puts( Xs,Cs, End,L2,LO).
%
$merge_$xform( [],[],Rest, Indx,Rest,L,L,_).
$merge_$xform( [X,Xs..],[Y,Ys..], [Z,Zs..], Indx, Rest,LI,LO,Hd):-
        $xform_put( X,Y,Z, Indx, LI,L2,Hd),!,
        $merge_$xform(Xs,Ys,Zs,Indx,Rest,L2,LO,Hd).
$merge_$xform_c( [],[],Rest, Rest).
$merge_$xform_c( [X,Xs..],[Y,Ys..], [put_cons(X,Y),Zs..], Rest):- not(compound(X)),
        $merge_$xform_c(Xs,Ys,Zs,Rest).
%
%   protect( list, list_of_disallowed_registers)
%    :- prevent temp variables/tailvariables on list 1 from being assigned to regs on list 2 
$protect( _,[]):-!.
$protect( F(A..), RL):-!, $protect( [F,A..], RL).
$protect( [],_).
$protect( [X,L..], Rlist):- $exclude(X,Rlist),!,$protect(L,Rlist).

% exclude( term, reglist)  - temp vars must not use 'in use' registers
$exclude( _,[]):-!.
$exclude( $var(V,_,P,_..)  ,Rlist):-!,P@=t->freeze(V, $nonmember(Rlist,V)).
$exclude( $tvar(V,_,P,_..) ,Rlist):-!,P@=t->freeze(V, $nonmember(Rlist,V)).
$exclude( X,L):-compound(X) ->$protect(X,L).

$bodyend( tail, needs_env, [dealloc, proceed] ).
$bodyend( tail, no_env, [ proceed] ).
$bodyend( not_tail,_,  []).


%
%                               Filters
% 
$comp_filter( var ).
$comp_filter( tailvar).
$comp_filter( nonvar ).
$comp_filter( integer).
$comp_filter( symbol).
$comp_filter( float).
$comp_filter( numeric).
$comp_filter( number).
$comp_filter( structure).
$comp_filter( list).
$comp_filter( compound ).

$comp_filter( noninteger).
$comp_filter( nonsymbol).
$comp_filter( nonfloat).
$comp_filter( nonnumeric).
$comp_filter( nonnumber).
$comp_filter( nonstructure).
$comp_filter( nonlist).
$comp_filter( noncompound ).

%  $mk_filter( Filter, Arg, Code)
%            note:filters (except var) cannot be used on new or void vars
$mk_filter(var, $var(V,_,P,Vd,B,_..),  Fcode(V)):-  $has_a_value( Vd,B),!,  
        swrite(Fcode,var,P). 
$mk_filter(var, $var(V,_,P,Vd,B,_..),   noop)   :- !, 
        nl, write( 'Warning: var of null or new variable coerced to noop ').
$mk_filter(F,   $var(V,_,P,Vd,B,_..),  Fcode(V,F)):- $has_a_value( Vd,B),!,  
        swrite(Fcode,test,P).
$mk_filter(F,   $var(V,_,P,Vd,B,_..), fail):- $diagnostic(Vd,B,F),
        failexit($generate_call_sequence).   % omit or retarget this fail if wish to allow this 
$mk_filter(F,   $tvar(_..),           fail):- !,fail.  % tvars not allowed 
$mk_filter(F,   Any,  Val):- $checkfilter(F,Any,Val),!,
        nl, write('Unneccessary ', Val,' filter ',F ),
        failexit($generate_call_sequence).

$has_a_value( Vd,B):- nonvar(B), not( Vd@=void).

$checkfilter(F,A,true):- F(A),!.
$checkfilter(F,A,false):-not(F(A)).
$diagnostic(Vd,B,Filter):- Vd @= void,
        nl, write( 'Filter ',Filter,' of void variable').
$diagnostic(Vd,B,Filter):- var(B), 
        nl, write( 'Filter ',Filter,'  of new (or unused) variable').

$$compile_filter( [], F, End, End). 
$$compile_filter( [A,As..], F , [C, Cs..], End) :-
        $mk_filter( F,A, C),!,
        $$compile_filter( As, F, Cs, End).

$compile_filter( tailvar,[$tvar(V,_,P,Vd,B,S)],  [Fcode(V), End..], End):-
        $has_a_value( Vd,B),!,
        swrite(Fcode, tvar, P).     
$compile_filter( tailvar, [$tvar(_..)],  [noop, End..], End):-!,
        nl, write('Warning: tvar of new or unused tailvar coerced to noop').
$compile_filter( tailvar,_,_,_ ) :-!, 
        nl, write('Error: tailvar syntax '), failexit($generate_call_sequence).
$compile_filter( F, Args, Code, Rest):- $$compile_filter( Args,F,Code,Rest).
%
%                               Head
%
$rearrange( [],    _        ,[],   [],        [],  []).
$rearrange( [A,As..],R  ,[A,EA..], [R,ER..],  FA,FR):- compound(A),!, %incl. vars
    R1 is R + 1,
    $rearrange(As,R1, EA,ER, FA,FR).
$rearrange( [A,As..],R,  PA,    PR, [A,FA..],[R,FR..]):- R1 is R + 1, % constants
    $rearrange(As,R1,PA,PR,FA,FR).

$use_regs([],_).
$use_regs(_,[]):-!.
$use_regs([R,Rs..],[R,Xs..]):-$use_regs(Rs,Xs).
$mrg([],X,X).
$mrg(X,[],X):-!.
$mrg([R,Rs..],[R,Xs..],[R,Ys..]):-$mrg(Rs,Xs,Ys).
$merge_regs( L1,L2, Res):- variables(L1,VL1,_,_), variables(L2,VL2,_,_),$mrg(VL1,VL2,Res).

$decompose_head_s( [],[],  End,End, L,L).
$decompose_head_s( [A,As..],[R,Rs..],  [Ins,More..],End, [Ls..],LV):- $simple(A,topdown),!,
    $xform_get( A, R, Ins,0, [R,Ls..],LO),!,
    $decompose_head_s(As, Rs,More,End, LO,LV).   

$decompose_head_c( [],[], End,End,_, Linkvars,Linkvars).
$decompose_head_c( [A,As..],[R,Rs..],  [Ins,More..],End,VM,[Ls..],LV):- $simple(A,topdown),!,
    $exclude(A,Rs),
    $xform_get( A, R, Ins,0, [R,Ls..],LO),!,
    $decompose_head_c(As, Rs,More,End,VM, LO,LV).   
$decompose_head_c( [A,As..],[R,Rs..],  [Code,More..],End, VM, [Links..],Linkvars):- compound( A),!,
    $protect( A, Rs),!,
    $normalform( A, VM, AN, Cons,[], 0, topdown),
    $xform_get( AN, R, Code, 0,[R,Links..],LO), 
    $map_gets( Cons, More, More2, LO, LO2),!,
    $decompose_head_c( As,Rs, More2,End,VM, LO2,Linkvars).

   
$generate_head_sequence( F(As..),[Headseq..],End,[[1,Size,T],_..], Needs_Env,FC,Linkvars,N):-
    symbol(F),  $trace(headin, F(As..)),
    termlength(F(As..),N,_),
    $rearrange( As,1, C,CR, S, SR ),!,
    $decompose_head_s( S,SR, Headseq, Hseq2,  [_..], Link1), 
    $allocation( Needs_Env,FC,Hseq2,Hseq3),!,
    $decompose_head_c( C,CR, Hseq3, End, T, Link1, Linkvars),!.
%
%                       Body
%
%  everything to generate a call:
%  $generate_call_sequence( F,_ , Code,tail,needs_env):- $failure(F,Code),!.
$generate_call_sequence( F,[_,Size,T], [Code],Tail,Needs_env,L,Ar):- symbol(F),!, 
    $gen_call(F(), Tail,Needs_env,Size,Call),
    $deallocation(Tail,Needs_env, Code,[Call]),
    $number_temps(L,T,Ar).
$generate_call_sequence( F(X,Y),[_,Size,T],[C,End..],Tail,Needs_env,L,Ar):- $rel_op(F), % arithmetic
    $arith( F(X,Y),Size, C),!,
    Start is max( Ar, 3),
    $number_temps(L,T,Start),
    $bodyend( Tail ,Needs_env,  End).
$generate_call_sequence( inline$(X..),[_,Size,T],[[X..],End..],Tail,Needs_env,L,Ar):-!, % inline WAM codes
    variables( [X..],[],[],[]), 
    $number_temps(L,T,Ar),       
    $bodyend( Tail ,no_env,  End).
$generate_call_sequence( call_i(tailvar(Args..)),[_,Size,T],Code,Tail,Needs_env,L,Ar):-!,  % filters
    $compile_filter(tailvar,[Args..],Code, End),!,
    $number_temps(L,T,Ar),                        
    $bodyend( Tail ,Needs_env,  End).               
$generate_call_sequence( F(Args..),[_,Size,T],Code,Tail,Needs_env,L,Ar):- 
    $comp_filter(F),                                
    $compile_filter(F,[Args..],Code, End),!,
    $number_temps(L,T,Ar),                         
    $bodyend( Tail ,Needs_env,  End).
$generate_call_sequence( $comp_block( failexit(_)),Map,[Code,End..],not_tail, Needs_env,L,Ar):-
    nl, write( 'failexit not at end'), failexit(compile_clause).  
$generate_call_sequence( $comp_block( Goal),Map,[Code,End..],Tail, Needs_env,L,Ar):-!, % block
    $generate_call_sequence( Goal, Map,Code,not_tail, needs_env,L,Ar),
    $bodyend( Tail, Needs_env, End).
$generate_call_sequence( F(As..),[Index,Size,T],[Code..],   Tail,Needs_env,HL,Ar):- symbol(F),
    termlength(F(As..),N,_), !, Nargs is abs(N),         $trace(call1, F(As..)/Nargs),
    $gen_call(F(As..),Tail,Needs_env, Size,  Call),!,
    $deallocation(Tail,Needs_env, Cs,[Call ]),!,    
    $normalform( F(As..), T, F(Bs..), List,[],Index, bottomup),   $trace(call,F(Bs..)/List),
    L0=[_..],       % indefinite list of yet unnamed temp regs to use for link vars
    $map_puts( List, Code, Callseq, L0,L1),!,        
    $rearrange( Bs,1, C,CR, S, SR ),!,  
    $merge_$xform( C,  CR, Callseq, Index, Callseq2,L1,L2, HL), %? L1=L2
    $use_regs(SR,L1),
    $merge_$xform_c( S,  SR, Callseq2, Cs),!,    
    $merge_regs(L2,HL,LV),   
    Nstart is max(Ar,Nargs + 1),
    $number_temps(LV,T,Nstart),!.
$generate_call_sequence( F(As..),Map,[Code,End..], Tail, Needs_env,L,Ar):- 
    $generate_call_sequence( call_i(F(As..)), Map,Code, not_tail, Needs_env,L,Ar),!,
    $bodyend( Tail, Needs_env,End).

$term( needs_env, [dealloc,proceed]).
$term( no_env, [proceed]).

$compile_body( [],[],Code,_, Needs_env,_, L,Ar):-!,  
    $term(Needs_env,Code),!.
$compile_body( [!,Lastcall],[_,N],[comment(Last),Code], [!,Last], needs_env,finalcut,L,Ar):- 
    $generate_call_sequence(Lastcall,N,Code,cuttail,needs_env,L,Ar),!.
$compile_body( [$comp_block(F)],[N],[ comment(Last), Code,Cs..], [Last], Needs_env,_,L,Ar):-!,
    $generate_call_sequence( F,N,Code,not_tail,Needs_env,L,Ar),!,
    $term( Needs_env,Cs),!.  
$compile_body( [Lastcall],[N],[comment(Last),Code], [Last], Needs_env,_,L,Ar):-!, 
    $generate_call_sequence(Lastcall,N,Code,tail,Needs_env,L,Ar).
$compile_body( [F,Fs..],[N,Ns..],[comment(OC),C,Cs..], [OC,OCs..], Needs_env,FC,L,Ar):- 
    $generate_call_sequence(F,N,C,not_tail,Needs_env,L,Ar),!,
    $compile_body(Fs,Ns,Cs,OCs, Needs_env,FC,[_..],0).

%  handle emission of neckcon vs. neck
$compbody( [$true,Body..],[ [1,Size,T],Js..],[neckcon(Size),Bcode..], [B, Bs..], Needs_env ,FC,L,N):-!,       
    $number_temps(L,T,N),
    $compile_body( Body,Js,Bcode,Bs,Needs_env,FC,L,0),!.
$compbody( Body,Map, [neck, Bcode..],  Bs, Needs_env,FC,L,N):- 
    $compile_body( Body,Map,Bcode, Bs, Needs_env,FC,L,N),!.
%
%         compile_clause
%
compile_clause( F ,Label, [ hcomment(H),Code..]):-               
    $stdform(F,(H:-[Bs..]),FC),!,   $trace('input:', H :- Bs),
    $label_clause(H,Label),!,
    $copy( H:-Bs, CH:-CB),                             $trace('copy:',(CH:-CB)),
    $classify_vars( (CH:-[CB..]),  Map, Needs_env),!,  $trace('classify:',Needs_env),
    $generate_head_sequence(CH, Code,Bcode,Map,Needs_env,FC,Linkvars,Arity),!, $trace('head:',Code),
    N1 is Arity + 1,
    $compbody(CB, Map, Bcode,   Bs, Needs_env,FC, Linkvars,N1),     $trace('body:',Bcode),
    !.                                                         
%
%       Input prep
%



%  transform clause to standard input form  (with all calls definite functors)
$funcb( H,          $comp_block(call_i(H))) :- var(H),!.
$funcb( [H..],      $comp_block(call_i([H..]))) :- !.
$funcb( F(A..),     call_i(F(A..))   ):- var(F), !.         %dec 21
$funcb( cut(N),     $comp_block( cut(N))  ):-!.
$funcb( failexit(N),$comp_block( failexit(N))):-!.
   %   $funcb( !,          !                ):-!.           % aug 9
$funcb( S,          S                ):-symbol(S),!.        % aug 9
$funcb( H,          H               ):- structure(H).       % aug 9


$funch( H,H  ):- structure(H),!.
$funch( H,H()):- symbol(H).

% first call on right - insert dummy call to $true if first call is to be compiled out
% this is to ensure that there are no temp vars in use at neck 
% and triggers emission of special neck opcode for handling constraints
$intrinsic(V):- var(V),!,fail.
$intrinsic(V(_..)):-var(V),!,fail.
$intrinsic(!).             % note: since constraints must fire before the cut
$intrinsic(cut).
$intrinsic(failexit).
$intrinsic(cut(_)).
$intrinsic(failexit(_)).
$intrinsic( F(_..)):- $comp_filter(F).  % since constraints must fire before the filter
            % special handling for first call on right
$mapbody1( [TV..],[call_i(TV)],nogc):- tailvar(TV..),!.
$mapbody1( [], [$true],nogc):-!.    % should remove $true here ???????
$mapbody1( [X,Xs..], [$true,Y,Ys..], End):-  $intrinsic(X),!,
    $funcb(X,Y), $mapbody(Xs,Ys,End).
$mapbody1( [F(A,B),Xs..],[$true,List..], End  ):-nonvar(F), $rel_op(F),  % arithmetic
    $expand_arithmetic( F(A,B), List, Ys), !, $mapbody(Xs,Ys, End).
$mapbody1( [Transparent(A,B)], [$comp_block(Transparent(A,B))], nogc) :-
	Transparent @= '->' ; Transparent @= ';', !.
$mapbody1( [X,Xs..], [Y,Ys..], End):- $funcb(X,Y), $mapbody(Xs,Ys,End).

$mapbody( [TV..],[call_i(TV)], nogc):- tailvar(TV..),!.
$mapbody( [C,TV..],[!,call_i(TV)], finalcut):- tailvar(TV..), C@='!', !.
$mapbody( [C,F],[!,F1], finalcut):- C@='!',$funch(F,F1),F1=Fnc(_..),symbol(Fnc),not(Fnc=fail),!. %enable gc
$mapbody( [], [], nogc):-!.
$mapbody( [C],[!],finalcut):-C@='!',!.  %enable gc
$mapbody( [F(A,B),Xs..], List, End  ):-nonvar(F), $rel_op(F),
    $expand_arithmetic( F(A,B), List, Ys), !,
    $mapbody(Xs,Ys, End).
$mapbody( [Transparent(A,B)], [$comp_block(Transparent(A,B))], nogc) :-
	Transparent @= '->' ; Transparent @= ';', !.
$mapbody( [X,Xs..], [Y,Ys..], End):- $funcb(X,Y), $mapbody(Xs,Ys,End).

% 3rd arg is returns var, or "finalcut" if clause ends as ..!,F. or !.
$stdform( (H :- V), (H1 :- B1) , nogc):- var(V),!, $stdform( H:-[V],H1:-B1,_). 
$stdform( ( H:-[B..]), H1:-[B1..],FC):- !, $funch(H,H1),!,$mapbody1(B,B1,FC).  
$stdform( (H:-B), H1:-[B1..],FC):-  not(list(B)),!,$funch(H,H1),!, $mapbody1([B],B1,FC).
$stdform( H ,(H1:-[$true]),nogc):- $funch(H,H1).  
