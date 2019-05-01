/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/dragregion.p,v 1.1 1995/09/22 11:23:57 harrisja Exp $
*
*  $Log: dragregion.p,v $
 * Revision 1.1  1995/09/22  11:23:57  harrisja
 * Initial version.
 *
*
*/

/* DRAGREGION implementation. Dragregion is now a stand alone predicate. 
   It is no longer a dograf descriptor */

dragregion(Window,Region,MouseX,MouseY,
           DL,DT,DR,DB,
           ML,MT,MR,MB,Constraint,
           DeltaX,DeltaY) :-
    DL1 is min(DL,DR),   % Ensure dragrect components are ordered correctly
    DR1 is max(DL,DR),
    DT1 is min(DT,DB),
    DB1 is max(DT,DB),
    ML1 is min(ML,MR),   % Ensure mouserect components are ordered correctly
    MR1 is max(ML,MR),
    MT1 is min(MT,MB),
    MB1 is max(MT,MB),
    DL1 >= ML1,          % Ensure mouserect encloses drag rect
    DR1 =< MR1,
    DT1 >= MT1,
    DB1 =< MB1,
    $constraint(Constraint),
    !,
    % adjust dragrect to constrain entire region 
    bounding_rect(Window,Region,Rl,Rt,Rr,Rb), 
    DL2 is DL1 + (MouseX-Rl),
    DR2 is DR1 - (Rr-MouseX),
    DT2 is DT1 + (MouseY-Rt),
    DB2 is DB1 - (Rb-MouseY),
	GrafRegion = [crectabs(0,0,Width,Height),penmode(xor),fillpat(hollow),penpat(gray),Region..],
    L = [GrafRegion,MouseX,MouseY,ML1,MT1,MR1,MB1,DL2,DT2,DR2,DB2,
         Constraint],
    new_obj(drag(MouseX,MouseY,visible),Op,$local),
	sizewindow(Window,Width,Height),
    dograf(Window,[GrafRegion]),
    repeat,
       userevent(Event,Window,D1,D2,noblock), 
       $acton(Event,Window,D1,D2,Op,L),
       !,
    $stop_dragging(Window,D1,D2,Op,L,DeltaX,DeltaY).
 
$acton(usermouseup,Window,X,Y,Op,L).    % done dragging

$acton(usermousedown,Window,X,Y,Op,L) :- 
    !,
    $acton(userdownidle,Window,X,Y,Op,L).

$acton(userdownidle,Window,X,Y,Op,L) :-
    get_obj(Op,drag(PrevX,PrevY,State),$local),
    !,
    $drag(X,Y,Window,L,PrevX,PrevY,State,NewX,NewY,NewState),
    put_obj(Op,drag(NewX,NewY,NewState),$local),
    !,
    fail.

$acton(Event,Window,D1,D2,Op,L) :- 
    Event(Window,D1,D2),
    !,
    fail.

$drag(X,Y,Window,[GrafRegion,MouseX,MouseY,ML,MT,MR,MB,Etc..],
          PrevX,PrevY,State,NewX,NewY,NewState) :-
    X >= ML,         
    X =< MR,
    Y >= MT,
    Y =< MB,
    !,                           % inside mouse rect
    % check drag rect
    $drag_rect(X,Y,Window,[GrafRegion,MouseX,MouseY,Etc..],
               PrevX,PrevY,State,NewX,NewY,NewState).
      
$drag(X,Y,Window,[GrafRegion,MouseX,MouseY,Etc..],
      PrevX,PrevY,State,PrevX,PrevY,erased) :-
    % outside mouse rect
    $erase_outline(State,Window,GrafRegion,PrevX-MouseX,PrevY-MouseY).    

$erase_outline(visible,Window,GrafRegion,OffsetX,OffsetY) :- 
    dograf(Window,[[offset(OffsetX,OffsetY),GrafRegion..]]).

$erase_outline(erased,Window,GrafRegion,OffsetX,OffsetY).

$drag_rect(X,Y,Window,[GrafRegion,MouseX,MouseY,DL,DT,DR,DB,Constraint],
               PrevX,PrevY,State,NewX,NewY,visible) :-
    X >= DL,         
    X =< DR,
    Y >= DT,
    Y =< DB,
    !,                           % inside drag rect and mouse rect
    $constrainXY(Constraint,X,Y,PrevX,PrevY,NewX,NewY), % apply axis constraint
    $redraw_req(State,PrevX,PrevY,NewX,NewY),
    $erase_outline(State,Window,GrafRegion,PrevX-MouseX,PrevY-MouseY),
    dograf(Window,[[offset(NewX-MouseX,NewY-MouseY),GrafRegion..]]).

$drag_rect(X,Y,Window,[GrafRegion,MouseX,MouseY,DL,DT,DR,DB,Constraint],
               PrevX,PrevY,State,NewX,NewY,visible) :-
    % outside drag rect, inside mouse rect
    $constrainXY(Constraint,X,Y,PrevX,PrevY,ConstrainX,ConstrainY),% apply axis constraint
    $pin_offset(ConstrainX,DL,DR,NewX),
    $pin_offset(ConstrainY,DT,DB,NewY),
    $redraw_req(State,PrevX,PrevY,NewX,NewY),
    $erase_outline(State,Window,GrafRegion,PrevX-MouseX,PrevY-MouseY),    
    dograf(Window,[[offset(NewX-MouseX,NewY-MouseY),GrafRegion..]]).

$redraw_req(visible,PrevX,PrevY,NewX,NewY) :-
    PrevX = NewX, 
    PrevY = NewY,    % don't redraw in place
    !,
    fail.
    
$redraw_req(State,PrevX,PrevY,NewX,NewY).
   
$pin_offset(Offset,LowBound,HighBound,HighBound) :-
    Offset > HighBound ,!.
$pin_offset(Offset,LowBound,HighBound,LowBound) :-
    Offset < LowBound,!.
$pin_offset(Offset,LowBound,HighBound,Offset).

$constrainXY(any,X,Y,PrevX,PrevY,X,Y).
$constrainXY(vert,X,Y,PrevX,PrevY,PrevX,Y).
$constrainXY(horz,X,Y,PrevX,PrevY,X,PrevY).

$stop_dragging(Window,X,Y,Op,[GrafRegion,MouseX,MouseY,Etc..],DeltaX,DeltaY) :-
    get_obj(Op,drag(PrevX,PrevY,State), $local),
    !,
    $erase_outline(State,Window,GrafRegion,PrevX-MouseX,PrevY-MouseY),
    $get_deltas(MouseX,MouseY,X,Y,PrevX,PrevY,[Etc..],DeltaX,DeltaY),
    dispose_obj(Op,$local).

$get_deltas(StartX,StartY,X,Y,PrevX,PrevY,[ML,MT,MR,MB,Etc..],
            DeltaX,DeltaY) :-
    X >= ML,          
    X =< MR,
    Y >= MT,
    Y =< MB,
    !,                   % inside mouse rectangle
    $get_deltas1(StartX,StartY,X,Y,PrevX,PrevY,[Etc..],DeltaX,DeltaY).

$get_deltas(StartX,StartY,X,Y,PrevX,PrevY,[ML,MT,MR,MB,Etc..],
            -32768,-32768).
    % outside mouse rectangle

$get_deltas1(StartX,StartY,X,Y,PrevX,PrevY,[DL,DT,DR,DB,Constraint],DeltaX,DeltaY) :-
    X >= DL,          
    X =< DR,
    Y >= DT,
    Y =< DB,
    !,                   % inside drag and mouse rectangles
    $constrainXY(Constraint,X,Y,PrevX,PrevY,ConstrainX,ConstrainY),% apply axis constraint
    DeltaX is ConstrainX-StartX,
    DeltaY is ConstrainY-StartY.

$get_deltas1(StartX,StartY,X,Y,PrevX,PrevY,[DL,DT,DR,DB,Constraint],DeltaX,DeltaY) :-
    % outside drag rectangle, inside mouse rectangle
    $constrainXY(Constraint,X,Y,PrevX,PrevY,ConstrainX,ConstrainY),% apply axis constraint
    $pin_offset(ConstrainX,DL,DR,NewX),
    $pin_offset(ConstrainY,DT,DB,NewY),
    DeltaX is NewX-StartX,
    DeltaY is NewY-StartY.

$constraint(horz).
$constraint(vert).
$constraint(any).

