/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/constraint_network.p,v 1.1 1995/09/22 11:23:34 harrisja Exp $
*
*  $Log: constraint_network.p,v $
 * Revision 1.1  1995/09/22  11:23:34  harrisja
 * Initial version.
 *
*
*/
% Author: W.J. Older
% Date:  Oct 1992
% Copyright 1992  Bell-Northern Research
%
%   -Dec 08 1992- change "enumerateff' to "firstfail" in presolve
%   -Jan 03 1994- modifications to work with crias4 & crias5
%   -Mar 22 1994- modifications to handle wrap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%
%    constraint_network( X ,  Nodes where State )
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%
%  This is a program to extract interval networks
%  solely for purposes of display, debugging,and  analysis.
% 
%  where X is an interval
%  returns a representation of the entire constraint network 
%  containing X as 
%       Nodes: an (indefinite) list of primitive arithmetic operations
%  and  State: an (indefinite) list of the current bounds
%  (All interval variables will have been replaced by symbols in
%   this representation. )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%
%    	presolve( X )  - where X is an interval
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%   This routine can be used either as an alternative to solve
%   or together with solve (i.e. ".. presolve(X), solve(X) ..")
%   to solve more complicated problems.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%
%    degrees_of_freedom( X, Neqs, Nvars, Nineqs,Ndiscrete)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%   This (relatively expensive) routine returns some idea of the 
%   number of degrees of freedom in the network associated with X.
%   If N_of_Eqs = N_of_vars then expect point solutions
%   or no solutions. An inequation is some (unkown) fraction of
%   an equation; discretes are either integer or boolean type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

constraint_network( X, Nodes where Vars):- 
		domain( X, _),
		$tree_insert( X, Vtree, 1 ,V),
		$network( [X,Vs..]/Vs, Vtree, Ntree ),
		$tree_to_list(Ntree, Nodes / [], $cod_and_trans),
		$tree_to_list(Vtree, Vars / [],  $domain_of),
		$label_list( Vars, x, 1), !.

%  binary trees : Item is key, Value is dependent attributes
%     Note that Value can be a variable, and this will
%     result in a 1-1 map from keys to variables 
$tree_insert( Item, Tree, 1 ,Value):- var(Tree),!,
		Tree=$tree( [Item,Value],_,_).
$tree_insert( Item, Tree, New, Value):- $compare( Item, Tree, Cmp ),
		$ti( Cmp, Item,Tree, New, Value).
		
$compare( X, $tree([Y,_],_..), C):- term_compare(X,Y,C).

$ti( @=, Item, $tree([_,Val],_,_), 0, Val).
$ti( @>, Item, $tree(_,_,R), New, Val):- $tree_insert( Item,R,New,Val).
$ti( @<, Item, $tree(_,L,_), New, Val):- $tree_insert( Item,L,New,Val).


% tree_to_list( Tree, Diflist, Extractor) where Extractor(Item,Diflist)
$tree_to_list(  T  , Q/Q , _):- var(T),!.
$tree_to_list(  $tree(Item, L, R ), Q0/QF, Extract):-
		$tree_to_list( L, Q0/Q1, Extract ),
		Extract( Item,  Q1/Q2),
		$tree_to_list( R, Q2/QF, Extract ).

%extractors:
$dom( [L,_], [L,Ls..]/Ls).
$cod( [_,R], [R,Ls..]/Ls).
$domain_of( [X,V] , [V:D,Ls..]/Ls):- domain(X,D).
$cod_and_trans( [_,R], [TR,Ls..]/Ls):- $translate(R,TR), !.
$cod_and_trans( _, Q/Q).

$label_list([],_,_).
$label_list([V:D,Xs..], Name, N):- 
	swrite(V, Name, N),
	N1 is N+1,
	$label_list(Xs, Name, N1).

% get nodes attached to an interval
$nodelist( X ,List):- 
		$domain( X, Type(_,List,_..)),!.
		% note that this list is indefinite --
		% do not make it definite as it will disable future constraints on this var

%  $network( Front of Q/End of Q, Vars seen, Nodes seen)		
$network( FQ/EQ,  Vtree, Ntree):- FQ@=EQ,!.
$network([V,Vs..]/Q ,  Vtree, Ntree):-
		$nodelist( V, Ns ) ->
			$add_nodes( Ns,      Vtree, Ntree, Q/NewQ ),
		$network( Vs/NewQ,  Vtree, Ntree).
	
$add_nodes( [TV..], _, _, Q/Q ):- tailvar(TV..),!.
$add_nodes( [N,Ns..], Vtree,Ntree, Q0/Q ):-
		$add_node( N,  Vtree,Ntree, Q0/Q1),
		$add_nodes(Ns, Vtree,Ntree, Q1/Q ).

$add_node( F(X1,X2,X3), Vtree,Ntree, Q):-
		$tree_insert( F(X1,X2,X3), Ntree,New, F(Y1,Y2,Y3)),
		$add_vars(New, F(X1,X2,X3), F(Y1,Y2,Y3), Vtree, Q).
		
$add_vars(0,_,           _,           _,      Q/Q).
$add_vars(1,_(V1,V2,V3), _(U1,U2,U3), Vtree, Q0/Q3):-
		$add_var( V1, Vtree, U1, Q0/Q1),		
		$add_var( V2, Vtree, U2, Q1/Q2),
		$add_var( V3, Vtree, U3, Q2/Q3).
		
$add_var( V,  _,     V, Q/Q):- nonvar(V),!.
$add_var( V, Vtree, NV, Q  ):- 
		$tree_insert( V, Vtree, New, NV),
		$addtoq(New, V, Q ).
		
$addtoq( 0, _, Q/Q       ).
$addtoq( 1, V, [V,Q..]/Q ).


$translate( F, G):- $translat(F,G),!.		
%% $translate( F, F).   % default : transparent				

%% $translat( $diophantine(Z,nil,nil),  integer(Z)).
$translat( F(Z,X,Nil) , R(Z,X)   ):- Nil@=nil, $tmaprel(F,R). 
$translat( F(Z,X,Nil) , Z==G(X)  ):- Nil@=nil, $tmapfunc1(F,G). 
$translat( F(Z,X,Y)   , Z==G(X,Y)):- $tmapfunc2(F,G). 
$translat( $root(Z,X,Y) , Z==X**2). 
$translat( $k_equal(Z,X,Y), Y==( Z==X) ).
$translat( $j_less(Z,X,Y),  Y==( Z>=X) ).
$translat( $wrap(Z,X,M),  Z== wrap(X,M) ).

$tmaprel( $equal,     '==').
$tmaprel( $greatereq, '>=').
$tmaprel( $higher,    '<').
$tmaprel( $unequal,   '<>').
$tmaprel( $begin_tog, '|=').
$tmaprel( $finish_tog,'=|').
$tmaprel( $narrower,  '<=').

$tmapfunc1($cos,  cos).
$tmapfunc1($sin,  sin).
$tmapfunc1($tan,  tan).
$tmapfunc1($vabs, abs).
$tmapfunc1($xp,   exp).
$tmapfunc1($$falseimplied,   '~').

$tmapfunc2($add,  '+').
$tmapfunc2($mul,  '*').
$tmapfunc2($lub,  max).
$tmapfunc2($inf,  min).
$tmapfunc2($or,  ';').
$tmapfunc2($pow_odd,  '**').
$tmapfunc2($qpow_even,'+').
   % boolean dyadics Dec 94
$tmapfunc2($$conjunction,and).
$tmapfunc2($$anynot,   nand).
$tmapfunc2($$butnot,    nor).
$tmapfunc2($$disjunction,or).
$tmapfunc2($$exor,      xor).


%
%   degrees_of_freedom( X, N_of_eqs, N_of_vars, N_of_ineqs, N_discrete)
%

degrees_of_freedom( X, NE, NV, NI,ND):-
        domain(X,_),
		$tree_insert( X, Vtree, 1 ,V),
		$network( [X,Vs..]/Vs, Vtree, Ntree ),
		$tree_to_list(Ntree, Nodes/[], $dom),
		$tree_to_list(Vtree, Vars/[],  $dom),
		$countlist( Nodes, 0,$equation,  NE),
		$countlist( Nodes, 0,$inequation,NI),
		$countlist( Vars,  0,$discrete,  ND),
		$countlist( Vars,  0,$any,       TV),
		NV is TV - ND.
		
$countlist( [], N,_,  N ).
$countlist( [X,Xs..],N, P, M):- P(X),!,N1 is N+1, $countlist(Xs,N1,P,M).
$countlist( [_,Xs..],N, P, M):- $countlist(Xs,N,P,M).


$inequation( $k_equal(Z,X,B) ):- (var(B) ; B@=0),!.
$inequation( $j_less(Z,X,B)  ):-!.   % mar 94 correction (doesn't dep on B being var)
$inequation( $greatereq(Z,X,Y) ):-!.
$inequation( $higher(Z,X,Y)    ):-!.
$inequation( $unequal(Z,X,Y)   ):-!.
$inequation( $begin_tog(Z,X,Y) ):-!.
$inequation( $finish_tog(Z,X,Y)):-!.
$inequation( $narrower(Z,X,Y)  ):-!.

$equation( X ):- $inequation(X),!,fail.
$equation( _ ).

$discrete( V ):- domain(V,boolean),!. 
$discrete( V ):- domain(V,integer(_,_)),!. 

$any(_).
	
%
%   $locally_interval_convex( X ,Exceptions)
%
%   Given an interval, this procedure returns associated nodes
%   which may be non-interval convex. This is used in gsolve/1.

$locally_interval_convex( X , Exceptions) :- 
		domain( X, _),
		$tree_insert( X, Vtree, 1 ,V),
		$network( [X,Vs..]/Vs, Vtree, Ntree ),
		$tree_to_list(Ntree, Nodes/[], $dom),
		$tree_to_list(Vtree, Vars/[],  $dom),
		$all_real( Vars , Exceptions, More_exceptions),
		$loc_interval_convex( Nodes , More_exceptions).

$all_real( [] , Ex, Ex ).
$all_real( [V,Vs..], [V,E..], More):- $discrete(V),!, 
         $all_real( Vs, E, More).
$all_real( [V,Vs..],  E, More):- 
         $all_real( Vs, E, More).
		
$loc_interval_convex( [] ,[]).
$loc_interval_convex( [F(A,B,C),Ns..], Y):- $convex_node(F,A,B,C),!,
		$loc_interval_convex( Ns ,Y).
$loc_interval_convex( [N,Ns..], [N,Y..]):- 
		$loc_interval_convex( Ns ,Y).		

% revised march 94
$convex_node( $add,    Z,X,Y ).
$convex_node( $begin_tog,Z,X,Y ).
$convex_node( $cos,    Z,X,Y ):-!, $sign_definite(X).

$convex_node( $equal,  Z,X,Y ).
$convex_node( $greatereq,Z,X,Y ).
$convex_node( $higher, Z,X,Y ).
$convex_node( $inf,    Z,X,Y ).
$convex_node( $j_less, Z,X,B ):- !,integer(B).         % question???
$convex_node( $k_equal,Z,X,B ):- not(B@=1),!,fail. 
$convex_node( $lub,    Z,X,Y ).
$convex_node( $mul,    Z,X,Y ):- 
              $sign_definite(Z);$sign_definite(X);$sign_definite(Y), !. % Jan 94
$convex_node( $narrower,Z,X,Y).
$convex_node( $or,Z,X,Y ):- !, $disjoint(Z,X);$disjoint(Z,Y),!. % mar 94
$convex_node( $pow_odd, Z,X,Y).
$convex_node( $qpow_even,Z,X,Y):-!, $sign_definite(X).
$convex_node( $root,Z,X,Y ):-!, $sign_definite(X).
$convex_node( $sin,Z,X,Y):-!,range(X,[XL,XU]), P is pi/2, XL>= - P, XU=<P.
$convex_node( $tan,Z,X,Y).
$convex_node( $unequal,Z,X,Y ):-!,fail.                         % mar 94
$convex_node( $vabs,Z,X,Y ):-!, $sign_definite(X).
$convex_node( $wrap, Z,X,B ):- !,range(X,[XL,XU]), round(XL/(2*B))=round(XH/(2*B)). % mar 94
$convex_node( $xp   ,Z,X,Y ).

$sign_definite( X):- $sign_indefinite(X),!, fail.
$sign_definite( X).
$sign_indefinite( X ):- domain(X,T(L,U)), L<0, 0<U.

$disjoint(X,Y) :- range(X,[XL,XU]), range(Y,[YL,YU]), (XU<YL ; YU<XL).

%
%  presolve( Interval)  -  an alternative to solve
%

presolve( X ):- 
		domain( X, _),
		$locally_interval_convex(X, Exceptions),
		predicate( trace_gsolve) -> print(Exceptions),
		$convexify( Exceptions, Diophantines),
		firstfail( Diophantines).
% rewritten mar 94
$convexify([],[]).
$convexify( [Z,Ns..], [Z,Ys..]):- var(Z),!, $convexify( Ns, Ys).
$convexify([F(A,B,C),Ns..],Y):- $convexify_node(F,A,B,C), $convexify(Ns,Y).

$convexify_node( $cos,    Z,X,Y ):-!, $make_definite(X).
$convexify_node( $j_less, Z,X,B ):-!,boolean(B).         % question???
$convexify_node( $k_equal,Z,X,B ):-!, (B=1; Z=<X;Z>=X). 
$convexify_node( $mul,    Z,X,Y ):-!,$make_definite(X),$make_definite(Y).
$convexify_node( $or,     Z,X,Y ):-!, Z==X ; Z==Y.
$convexify_node($qpow_even,Z,X,Y):-!,$make_definite(X).
$convexify_node( $root,   Z,X,Y ):-!,$make_definite(X).
$convexify_node( $sin,    Z,X,Y ):-!, P is pi/2, (X =< - P; X>= - P) ,(X =< P ; X >= P).
$convexify_node( $unequal,Z,X,Y ):-!, Z<X;Z>X.                         
$convexify_node( $vabs,   Z,X,Y ):-!,$make_definite(X).
$convexify_node( $wrap,   Z,X,B ):-!, solve(X).
$convexify_node( _ ,_,_,_).

$make_definite( X ):- $sign_definite(X),!.
$make_definite( X ):- X=<0 ; X>=0.
		
		
