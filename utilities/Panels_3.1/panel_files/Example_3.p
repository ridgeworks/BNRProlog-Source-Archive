/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/panel_files/RCS/Example_3.p,v 1.1 1995/09/22 11:24:09 harrisja Exp $
*
*  $Log: Example_3.p,v $
 * Revision 1.1  1995/09/22  11:24:09  harrisja
 * Initial version.
 *
*
*/

/*
 *   Example 3
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/


% -- Object class for balls --------------------------------

panel_item_class(ball). % show in editors popup menu

panel_item_new(ball,Name,X1,Y1,ball(name(Name),place(X1,Y1,X2,Y2),diam(20),velocity(0))):-
    X2 is X1+20, Y2 is Y1+20.

panel_item_graf(ball(_,place(Place..),_..),[fillpat(hollow),ovalabs(Place..)]).

panel_item_grow(ball(_..),4,4). 



% -- Event handlers for balls -------------------------------

panel_event('Example 3',click,button('RESET')):-
    panel_definition('Example 3',_,_,_,Items..),
    reset_balls(Items,'Example 3').

panel_event('Example 3',upidle,_):-
    panel_view('Example 3',[]:Items),
    sizewindow('Example 3',_,Bottom),
    drop('Example 3',Items,Bottom,Fallen),
    panel_view('Example 3',Fallen..).

panel_event('Example 3',close):-
    context('Example_3',Path),
    concat(Window,'.a',Path)->true;Window=Path,
    closewindow(Window)->true,
    exit_context('Example_3').

% -- animate the balls --------------------------------------

drop(Panel,[ball(name(N),place(X1,Y1,X2,Y2),diam(H),velocity(V1)),Items..],Bottom,
    [ball(N):=[place(X1,Y3,X2,Y4),velocity(V2)],Fallen..]):-
    bounce(Bottom,Y1,Y2,H,V1,V2,D1,D2), 
    Y3 is Y1+D1, Y4 is Y2+D2,
    drop(Panel,Items,Bottom,Fallen).

drop(Panel,[_,Items..],Bottom,Fallen):-
    drop(Panel,Items,Bottom,Fallen).

drop(_,[],_,[]).

bounce(Bottom,Y1,Y2,H,V1,V2,V1,D2):- 
    (Y2+V1) < Bottom,
    D2 is V1 - (Y2-Y1-H)//2,
    V2 is V1+1. 

bounce(Bottom,Y1,Y2,H,V1,V2,D1,D2):- % hits bottom
    (Y1+V1) < Bottom-> D1 is V1;D1 is Bottom-Y1,
    D2 is Bottom-Y2,
    V2 is -integer(0.95*V1). % coefficient of elasticity  

clear_balls(_,[]). 

clear_balls(Panel,[ball(_,place(X1,Y1,X2,Y2),_..),Items..]):-
    !,
    dograf(Panel,[[fillpat(clear),rectabs(X1,Y1,X2,Y2)]]),
    clear_balls(Panel,Items).

reset_balls([],_).
reset_balls([ball(name(Name),Place..),Rest..],Panel):-
    panel_view(Panel,ball(Name):=Place),
    reset_balls(Rest,Panel).
reset_balls([Item(_..),Rest..],Panel):-
    Item\=ball,
    reset_balls(Rest,Panel).

% -- panel maker's layout description --------------------

panel_definition('Example 3' , 
    pos(300,123) ,
    size(300, 200) ,
    options(nogrowdocproc), 
    ball(name(ball2),place(164,72,196,104),diam(32),velocity(0)),
    ball(name(ball1),place(108,88,128,108),diam(20),velocity(0)),
    button('RESET', [8, 8, 88, 28], _3) ).

$initialization:-panel_open('Example 3').
