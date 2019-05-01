/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/bounding_rect.p,v 1.1 1995/09/22 11:22:33 harrisja Exp $
*
*  $Log: bounding_rect.p,v $
 * Revision 1.1  1995/09/22  11:22:33  harrisja
 * Initial version.
 *
*
*/

bounding_rect(Name,G,MinX,MinY,MaxX,MaxY) :-
	window_id(Name,W,[GC,_,Gc_Attrib..]),
	new_obj(bounding_rect_temp(G),Op,$local),
	get_obj(Op,bounding_rect_temp(G1),$local), % get temporary copy of G
	dispose_obj(Op,$local),
	$boundgraflist(G1,[32767,32767,-1,-1],[X1,Y1,X2,Y2],Gc_Attrib,_,GC),
	$bind_if_less(X1,32767,MinX), $bind_if_less(Y1,32767,MinY),
	$bind_if_greater(X2,-1,MaxX), $bind_if_greater(Y2,-1,MaxY),
	cut.

$bind_if_less(X,Max,X):- X<Max, !.
$bind_if_less(_,_,_).

$bind_if_greater(X,Min,X) :- X>Min, !.
$bind_if_greater(_,_,_).

$boundgraflist([],Bounds,Bounds,Gc_Attrib,Gc_Attrib,GC):-!. %%% vars caught here, bound to []

$boundgraflist([G,Gs..],Bounds0,Bounds,Gc_Attrib,New_Attrib,GC) :-  % starting a new list
    list(G),
    clone_GC_C(GC,NewGC),
    $boundgraflist(G,Bounds0,Bounds1,Gc_Attrib,_,NewGC)
	; $free_GC_fail(NewGC),					% free the GC upon backtracking
    free_GC_C(NewGC),
    !,  %%% required to remove cp, aids LCO and GC
    $boundgraflist(Gs,Bounds1,Bounds,Gc_Attrib,New_Attrib,GC).

$boundgraflist([G,Gs..],Bounds0,Bounds,Gc_Attrib,New_Attrib,GC) :-
    !,
    $boundgraf(G,Bounds0,Bounds1,Gc_Attrib,Attrib_Back,GC),!, % G not a list
    $boundgraflist([Gs..],Bounds1,Bounds,Attrib_Back,New_Attrib,GC).

$boundgraflist(GrafStruct,Bounds0,Bounds,Gc_Attrib,New_Attrib,GC) :-    % not a list
    $boundgraf(GrafStruct,Bounds0,Bounds,Gc_Attrib,New_Attrib,GC).

$boundgraf([],Bounds,Bounds,Gc_Attrib,Gc_Attrib,GC) :-  % Catch variable primitives.
	!.

$boundgraf($$$bind_to_variable(P..),Bounds,Bounds,Gc_Attrib,Gc_Attrib,GC) :-  % Catch variable functors.
	!.

$boundgraf(F(P..),Bounds,Bounds,GC_Attrib,New_Attrib,GC) :-
	graf_attr_desc(F,Cmd),
	!,
	F(GC_Attrib,New_Attrib,P,GC).

$boundgraf(F(P..),[MinX,MinY,MaxX,MaxY],[NMinX,NMinY,NMaxX,NMaxY],GC_Attrib,New_Attrib,GC) :-
	graf_output_desc(F),
	!,
	F(bounds(Lx,Ly,Hx,Hy),GC_Attrib,New_Attrib,P,GC),
	NMinX is min(MinX,Lx), NMinY is min(MinY,Ly),
	NMaxX is max(MaxX,Hx), NMaxY is max(MaxY,Hy).

$boundgraf(G,Bounds,Bounds,Gc_Attrib,Gc_Attrib,GC) :-   % try to execute
    G, /* ??? should we trap errors here (capsule) ??? */
    !. 

$boundgraf(F(ParmList..),Bounds,Bounds,Gc_Attrib,Gc_Attrib,GC) :-  % nothing worked => debug message
   $graf_debug('\nDOGRAF WARNING : ',bounds(F(ParmList..)),' failed.\n').

line(bounds(Lx,Ly,Hx,Hy),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [Dist],GC) :-             % turtle graphics
    A_rad is (A*pi/180),
    PxNew is Dist*cos(A_rad)*Sx +Px,
    PyNew is Dist*sin(A_rad)*Sy +Py,    % Clockwise rotation is considered positive.
    PxNew_int is round(PxNew),
    PyNew_int is round(PyNew),
    Px_int is round(Px),
    Py_int is round(Py),
	Lx is min(Px_int,PxNew_int), Ly is min(Py_int,PyNew_int),
	Hx is max(Px_int,PxNew_int), Hy is max(Py_int,PyNew_int).

move(bounds(32767,32767,0,0),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A],[Dist],GC) :-
    A_rad is (A*pi/180),
    PxNew is Dist*cos(A_rad)*Sx +Px,
    PyNew is Dist*sin(A_rad)*Sy +Py.    % Clockwise rotation is considered positive.

turn(bounds(32767,32767,0,0),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,ANew], [Delta],GC) :-
	ANew is round(A + Delta).

arcrel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
		    [L, T, R, B, StartAngle, DeltaAngle],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py).

arcabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
		    [L, T, R, B, StartAngle, DeltaAngle],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy).
    
circlerel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
		     [X, Y, Radius],GC) :-
    L is X-Radius, R is X+Radius,
    T is Y-Radius, B is Y+Radius,
    L1 is round(L*Sx +Px),
    R1 is round(R*Sx +Px),
    T1 is round(T*Sy +Py),
    B1 is round(B*Sy +Py).

circleabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],
		     [X, Y, Radius],GC) :-
    L is X-Radius, R is X+Radius,
    T is Y-Radius, B is Y+Radius,
    L1 is round(L*Sx +Ox),
    R1 is round(R*Sx +Ox),
    T1 is round(T*Sy +Oy),
    B1 is round(B*Sy +Oy).

iconrel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, Icon],GC) :-
    Icon_int is round(Icon),
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py).

iconabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, Icon],GC) :-
    Icon_int is round(Icon),
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy).

moverel(bounds(32767,32767,0,0),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
	PxNew is round(X*Sx + Px),
	PyNew is round(Y*Sy + Py).

moveabs(bounds(32767,32767,0,0),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
	PxNew is round(X*Sx + Ox),
	PyNew is round(Y*Sy + Oy).

ovalrel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L,T,R,B],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py).

ovalabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L,T,R,B],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy).

rectrel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py).

rectabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy).

crectrel(bounds(32767,32767,0,0),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC).

crectabs(bounds(32767,32767,0,0),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B],GC).

linerel(bounds(L,T,R,B),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNext,PyNext,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
    !,
    PxNext is round(X*Sx + Px),
    PyNext is round(Y*Sy + Py),		
    Px_int is round(Px),
    Py_int is round(Py),
	L is min(Px_int,PxNext), T is min(Py_int,PyNext),
	R is max(Px_int,PxNext), B is max(Py_int,PyNext).

linerel(bounds(L,T,R,B),[Px,Py,Rest..],[PxNew,PyNew,Rest..], [X, Y, Points..],GC) :-
    Px_int is round(Px),
    Py_int is round(Py),
    $check_segment_list_rel([X,Y,Ps..],[PointsAbs..],[Px,Py,Rest..],[PxNew,PyNew,Rest..]),
	$point_list_bounds([Px_int,Py_int,PointsAbs..],[32767,32767,0,0],[L,T,R,B]).

lineabs(bounds(L,T,R,B),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNext,PyNext,Sx,Sy,Ox,Oy,A], [X, Y],GC) :-
    !,
    PxNext is round(X*Sx + Ox),
    PyNext is round(Y*Sy + Oy),
    Px_int is round(Px),
    Py_int is round(Py),
	L is min(Px_int,PxNext), T is min(Py_int,PyNext),
	R is max(Px_int,PxNext), B is max(Py_int,PyNext).

lineabs(bounds(L,T,R,B),[Px,Py,Rest..],[PxNew,PyNew,Rest..],[X,Y,Points..],GC) :-
    Px_int is round(Px),
    Py_int is round(Py),
    $check_segment_list_abs([X,Y,Points..],[PointsNew..],[Px,Py,Rest..],[PxNew,PyNew,Rest..]),
	$point_list_bounds([Px_int,Py_int,PointsNew..],[32767,32767,0,0],[L,T,R,B]).

$point_list_bounds([],Bounds,Bounds).
$point_list_bounds([X,Y,Ps..],[L0,T0,R0,B0],Bounds) :-
	L1 is min(X,L0), T1 is min(Y,T0),
	R1 is max(X,R0), B1 is max(Y,B0),
	$point_list_bounds(Ps,[L1,T1,R1,B1],Bounds).

rrectrel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, OvalWidth, OvalHeight],GC) :-
    L1 is round(min(L,R)*Sx +Px), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py).

rrectabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A], [L, T, R, B, OvalWidth, OvalHeight],GC) :-
    L1 is round(min(L,R)*Sx +Ox), 	    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy).

textrel(bounds(X1,T,PxNew,Y1),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y, Text],GC) :-
    Xnext is X*Sx + Px,
    X1 is round(Xnext),
    PyNew is Y*Sx + Py,
    Y1 is round(PyNew),
	T is Y1-12, % approx font height
    textwidth_C(GC, Text, Wx),
    PxNew is Xnext + Wx.

textabs(bounds(X1,T,PxNew,Y1),[Px,Py,Sx,Sy,Ox,Oy,A],[PxNew,PyNew,Sx,Sy,Ox,Oy,A], [X, Y, Text],GC) :-
    Xnext is X*Sx + Ox,
    X1 is round(Xnext),
    PyNew is Y*Sx + Oy,
    Y1 is round(PyNew),
	T is Y1-12,
    textwidth_C(GC, Text, Wx),
    PxNew is Xnext + Wx.

textbrel(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Text],GC) :-
    L1 is round(min(L,R)*Sx +Px),   % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Px),
    T1 is round(min(T,B)*Sy +Py),
    B1 is round(max(T,B)*Sy +Py).

textbabs(bounds(L1,T1,R1,B1),[Px,Py,Sx,Sy,Ox,Oy,A],[Px,Py,Sx,Sy,Ox,Oy,A],[L, T, R, B, Text],GC) :-
    L1 is round(min(L,R)*Sx +Ox),    % Make sure the rect's components are ordered correctly
    R1 is round(max(L,R)*Sx +Ox),
    T1 is round(min(T,B)*Sy +Oy),
    B1 is round(max(T,B)*Sy +Oy).

polygon(bounds(L,T,R,B),GCAttr,GCAttr,PolySpec,GC) :-
	$polygon_points(PolySpec,Points,GCAttr),
	$point_list_bounds(Points,[32767,32767,0,0],[L,T,R,B]).
