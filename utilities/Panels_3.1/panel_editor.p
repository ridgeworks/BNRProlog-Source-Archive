/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/panel_editor.p,v 1.1 1997/03/14 17:09:34 harrisj Exp $
*
*  $Log: panel_editor.p,v $
 * Revision 1.1  1997/03/14  17:09:34  harrisj
 * Moved files required by panels.a goal from panel_files to Panel_3.1.
 * Formally added Editing, Info, Interface to panel_files sub-project.
 * Added a makefile to panel_files subproject
 *
 * Revision 1.2  1995/11/01  14:42:48  yanzhou
 * Bug fix to display the name of the current panel style correctly.
 *
 * Revision 1.1  1995/09/22  11:25:38  harrisja
 * Initial version.
 *
*
*/

/*
 *   panel editor
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/

%---------------------------------------------------------------------------------

%       --  Selection and editing of objects  --

% --------------------------------------------------------------------------------

% -- other local predicates used:
%%   $getitem      in 'panel view'
%%   $rename       in 'panel sys'
%%   $reopen_panel in 'panel sys'
%%   $fieldvalue    in 'field_class'	
%%   $grid         in 'panel sys'
%%   $unlocked     in 'panel sys'
%%   $member       in 'panel_edit'
%

% -- Dragnet: item selection or new_item creation ---------------------------

panel_event(Panel,select(X,Y),void(void)):-
    Y>16,                       % not in drag region
    panel_id(Panel,_,Window),
    sizewindow(Window,W,H),
    not([X>(W-16),Y>(H-16)]),   % not in grow region
    %$unlocked(Panel),           % panel must be editable
    panel_attribute(Panel,lock(off)),
    panel_view(Panel,[]:Objs),
    $selection(Window,Objs,Selection,Newitems),       % unselect existing selection
    Selection@\=[]->panel_view(Panel,Selection<=Newitems),
    new_obj(dragnet(X,Y,X,Y,W,H),Op,$local),    % initiate new selection..
    $net(Window,W,H,rectabs(X,Y,X,Y)).

userdownidle(Window,NXr,NYb):-                  % idle event for dragnet
    get_obj(Op,dragnet(Xl,Yt,Xr,Yb,W,H),$local),
    NXr<>Xr;NYb<>Yb,
    $net(Window,W,H,rectabs(Xl,Yt,Xr,Yb),rectabs(Xl,Yt,NXr,NYb)),
    put_obj(Op,dragnet(Xl,Yt,NXr,NYb,W,H),$local).
    
panel_event(Panel,unselect(NXr,NYb),_):-        % end of dragnet
    get_obj(Op,dragnet(DXl,DYt,DXr,DYb,W,H),$local),
    dispose_obj(Op,$local),
    panel_id(Panel,_,Window),
    $net(Window,W,H,rectabs(DXl,DYt,DXr,DYb)),
    $checknet([DXl,DYt,NXr,NYb],Place),  % normalize rectangle, make sure it has area
    %$overlap(Window,Place,Items,Selection),
    panel_view(Panel,[]:Objs),
    once($overlaps(Window,Objs,Place,1,Items,Selection)),
    panel_attribute(Panel,dirty(_):=dirty(on)),
				Items = [] 
        -> [% create a button the same size as empty dragnet
            Place=[XL,YT,XR,YB],    
            panel_item_new(button,'New...',XL,YT,
                    button(Name,Ps..)),   % get a template
            $place_field(Panel,Window,place(Place..),NPlace), % fit it in the window
            findall(Class,panel_item_class(Class),Classes),  % generate menu list 
            % insert new object with different name (more unique), style, and menu 
            panel_item_write(button(Name,Ps..),
                   [name(newpanelobject),NPlace,style(shadow),menu(Classes..)],
                    Newitem,_),     % modify item using write method
            panel_view(Panel,insert(Newitem))];
           panel_view(Panel,Items<=Selection). % show selection 			

% -- select on newitem  button -------------------------------------------------
%   popup class menu under mouse (so don't have to wander too far)
%   if class selected create object same size as original dragnet
panel_event(Panel,select(X,Y),button(name(newpanelobject),Place,S,L,St,F,I,menu(Ms..))):-
    MX is X-8,MY is Y-8,
    panel_menu(Panel,[Ms..],1,MX,MY,Class)->
       [panel_view(Panel,delete(button(name(newpanelobject),Place,S,L,St,F,I,menu(Ms..)))),
        panel_id(Panel,_,Window),
        $next_item(Panel,Class,1,Name),
        panel_item_new(Class,Name,X,Y,Class(NName,_,NPs..)),
        $place_field(Panel,Window,Place,NPlace),  % fit it in the window
        $sel_item(Window,Class(NName,NPlace,NPs..),Select,1),
        panel_view(Panel,insert(Select))].
        
$checknet([Xl,Yt,Xr,Yb],[Xl,Yt,Xr,Yb]):-
    Xl<Xr-1,Yt<Yb-1.

$checknet([Xl,Yt,Xr,Yb],[Xr,Yt,Xl,Yb]):-
    Xl>Xr+1,Yt<Yb-1.

$checknet([Xl,Yt,Xr,Yb],[Xl,Yb,Xr,Yt]):-
    Xl<Xr-1,Yt>Yb+1.

$checknet([Xl,Yt,Xr,Yb],[Xr,Yb,Xl,Yt]):-
    Xl>Xr+1,Yt>Yb+1.

% build selection from Area, return list of items selected as well as selection
/*
$overlap(Window,Area,Items,Selection):-
    recall(Window(Panel,Down,Objs),$local),
    $overlaps(Window,Objs,Area,1,Items,Selection),
    !.  % commit and remove choicepoints

$overlaps(_,[],_,_,[],[]).
$overlaps(Window,[[Op,_],Objs..],[XL,YT,XR,YB],N,
            [Class(Name,place(Xl,Yt,Xr,Yb),Ps..),Items..],[Select,Sel..]):-
    $getitem(Op,Window(Class(Name,place(Xl,Yt,Xr,Yb),Ps..))),
    Xl=<XR,Xr>=XL,Yt=<YB,Yb>=YT,
    $sel_item(Window,Class(Name,place(Xl,Yt,Xr,Yb),Ps..),Select,N),
    successor(N,NN),
    $overlaps(Window,Objs,[XL,YT,XR,YB],NN,Items,Sel).
$overlaps(Window,[_,Objs..],Region,N,Items,Sel):-
    $overlaps(Window,Objs,Region,N,Items,Sel).
*/
$overlaps(_,[],_,_,[],[]).
$overlaps(Window,[Class(Name,place(Xl,Yt,Xr,Yb),Ps..),Objs..],[XL,YT,XR,YB],N,
            [Class(Name,place(Xl,Yt,Xr,Yb),Ps..),Items..],[Select,Sel..]):-
    Xl=<XR,Xr>=XL,Yt=<YB,Yb>=YT,
    $sel_item(Window,Class(Name,place(Xl,Yt,Xr,Yb),Ps..),Select,N),
    successor(N,NN),
    $overlaps(Window,Objs,[XL,YT,XR,YB],NN,Items,Sel).
$overlaps(Window,[_,Objs..],Region,N,Items,Sel):-
    $overlaps(Window,Objs,Region,N,Items,Sel).


% build list of selected items and list of items selected (see code for more precise def.)
$selection(_,[],[],[]).
$selection(Window,[selected(N,P,Item),Objs..],[selected(N,P,Item),Sel..],[Item,Newitems..]):-
    $selection(Window,Objs,Sel,Newitems).
$selection(Window,[_,Objs..],Sel,Newitems):-
    $selection(Window,Objs,Sel,Newitems).

% -- place item so as to fit inside the window aligned on grid....

$place_field(Panel,Window,place(Xl,Yt,Xr,Yb),place(XL,YT,XR,YB)):-
    %$grid(Panel,GX,GY),
    panel_attribute(Panel,grid(GX,GY)),
    sizewindow(Window,Xmax,Ymax),            % item cover is Xl,Yt,Xr,Yb, Xl>=0,Yt>=0
    $placefit(Xl,Xr,Xmax,GX,XL,XR),
    $placefit(Yt,Yb,Ymax,GY,YT,YB).

$placefit(Lo,Hi,Max,G,NLo,NHi):-    % 'Min' assumed to be 0
    Lo1 is Lo//G*G,                 % round Lo down to a grid point
    Hi1 is (Hi+Lo1-Lo+G-1)//G*G,    % adjust Hi and round up to grid point
    Hi1>Max->                       % if Hi now greater than Max
        [Hi2 is Max//G*G,Lo2 is Lo1+Hi2-Hi1];   % move to grid point just inside window
        [Hi2=Hi1,Lo2=Lo1],
    Lo2<0->                         % if Lo now less than zero
        [NLo=0,NHi is Hi2-Lo2];     % move to grid point just inside window, takes precedence
        [NLo=Lo2,NHi=Hi2].


% -- Mouse down with a selection ---------------------------------------------

% -- control select : add to or delete from a selection
panel_event(Panel,select(X,Y,1,0,0,0),Item):-
    Item\=void(_..),
    panel_attribute(Panel,lock(off)),
    Item=selected(name(Name),_,SItem)->
        panel_view(Panel,selected(Name)<=SItem);        % unselect item
        [panel_id(Panel,_,Window),
         $sel_item(Window,Item,Selitem,1),
         panel_view(Panel,Item<=Selitem),               % select item
         panel_attribute(Panel,dirty(_):=dirty(on))].   % mark window as modified

% -- Growing a selected object ------------------------------------------------

panel_event(Panel,select(X0,Y0),selected(name(S),P,Item)):-     % down on a selected item...
    once(panel_item_grow(Item,Xmin,Ymin)),
    Xmin\=0; Ymin\=0,
    $ingrow(Item,X0,Y0,Place),
    panel_id(Panel,_,Window),
    sizewindow(Window,W,H),
    new_obj(grownet(S,Place,Place,Xmin,Ymin,X0,Y0,W,H),Op,$local),  % start grow..
    $net(Window,W,H,rectabs(Place..)).

userdownidle(Window,XM,YM):-                                    % ..growing..
    get_obj(Op,grownet(S,[XL,YT,XR,YB],[XL,YT,XR0,YB0],Xmin,Ymin,X0,Y0,W,H),$local),
    %sizewindow(Window,W,H),             % limit growth to window 
    $limit_size(XM,X0,XL,XR,W,Xmin,XR1),
    $limit_size(YM,Y0,YT,YB,H,Ymin,YB1),
    [XR1,YB1]\=[XR0,YB0]->
       [$net(Window,W,H,rectabs(XL,YT,XR0,YB0),rectabs(XL,YT,XR1,YB1)),
        put_obj(Op,grownet(S,[XL,YT,XR,YB],[XL,YT,XR1,YB1],Xmin,Ymin,X0,Y0,W,H),$local)].

$limit_size(M,O,        % current and original mouse coordinate (X or Y)
            Top,Bot,    % left&right/top&bottom of original object
            Max,MinD,   % window max and object min
            NBot):-     % new left/bottom
    New0 is Bot+(M-O),
    New0>=Max      -> successor(New,Max);New=New0,
    (New-Top)>MinD -> NBot=New          ;NBot is Top+MinD.

panel_event(Panel,unselect(XM,YM),_):-                          % ..end grow 
    get_obj(Op,grownet(S,_,[Xl,Yt,Xr,Yb],_,_,_,_,W,H),$local),dispose_obj(Op,$local),
    panel_id(Panel,_,Window),
    $net(Window,W,H,rectabs(Xl,Yt,Xr,Yb)),
    %$grid(Panel,GX,GY),
    panel_attribute(Panel,grid(GX,GY)),
    XR is (Xr+GX-1)//GX*GX,
    YB is (Yb+GY-1)//GY*GY,
    panel_view(Panel,selected(name(S),P,Class(N,_,Ps..)):=Class(N,place(Xl,Yt,XR,YB),Ps..)).   % update to new,

% draw for drag and grow nets
$net(Window,W,H,Desc..):-
    %sizewindow(Window,W,H),		
    dograf(Window,[[crectabs(0,0,W,H),penmode(xor),penpat(gray),fillpat(hollow),Desc..]]).


% -- Dragging selected objects ------------------------------------------------
    
panel_event(Panel,select(X,Y),selected(S,P,I)):-  % down on a selected item, but not in grow box
    panel_id(Panel,_,Window),
    panel_view(Panel,[]:Objs),
    $selection(Window,Objs,Sel,Items),        % build drag region from all selected items
    $dragregion(Items,Drag),
    sizewindow(Window,W,H),
    $dragit(Window,Drag,X,Y,
                   0,0,W,H,    % drag limit
                   0,0,W,H,    % mouse limit
                   any,
                   DX,DY),
    [DX=0,DY=0]->nextevent(usermouseup,Window,X,Y);  % no movement, generate mouseup
       [NewX is X+DX,NewY is Y+DY,                   % else get final mouse position
        [NewX>0,NewX<W,NewY>0,NewY<H]->     % if still in window,   
           [%$grid(Panel,GX,GY),             % align top left of items to grid
            panel_attribute(Panel,grid(GX,GY)),
            $moveall(Sel,NewS,DX,DY,GX,GY), % items moved 
            panel_view(Panel,Sel<=NewS)];
           panel_view(Panel,delete(Sel))].  % else items trashed    

$dragregion([],[]).
$dragregion([Class(N,place(Cover..),Ps..),Items..],[rectabs(Cover..),Covers..]):-
    $dragregion(Items,Covers).

$dragit(Args..):-dragregion(Args..),!.  % done differently in new system
$dragit(Window,Args..):-dograf(Window,dragregion(Args..)).
 
$moveall([],[],_,_,_,_).
$moveall([selected(S,_,Class(N,place(Xl,Yt,Xr,Yb),Ps..)),Items..],
         [selected(S,place(NSP..),Class(N,place(XlD,YtD,XrD,YbD),Ps..)),New..],
         DX,DY,GX,GY):-
    XlD is round((Xl+DX)/GX)*GX,    % top left corners to current grid
    YtD is round((Yt+DY)/GY)*GY,
    XrD is Xr+XlD-Xl,               % bottom right corners to keep size
    YbD is Yb+YtD-Yt,
    panel_expand_rect([XlD,YtD,XrD,YbD],1,1,NSP),    
    $moveall(Items,New,DX,DY,GX,GY).

% -- Doubleclick on a selected item: edit --------------------------------------------

panel_event(Panel,doubleclick(X,Y),selected(Ps..)):-
    dispatch_panel_event(Panel,edit(X,Y),selected(Ps..)).

% -- Doubleclick on void: edit panel definition
panel_event(Panel,doubleclick(X,Y),void(Etc..)):-
    dispatch_panel_event(Panel,edit(X,Y),void(Etc..)).

% -- Cut, Copy, Paste and Delete selection --------------------------------------------

menuselect(Window,'Edit','Copy'):-
    $putscrap(Panel,Window,_).                  % put current Panel selection in scrap

menuselect(Window,'Edit','Cut'):-
    $putscrap(Panel,Window,Selection),          % put current Panel selection in scrap
    panel_view(Panel,delete(Selection)).        % delete selection in panel

menuselect(Window,'Edit','Paste'):-
    ispanel(Panel,Window),                      % applies only if current window is a panel
    $getscrap(Scrap),                           % get contents of scrap
    $disambiguate(Scrap,Insertion,Window),      % disambiguate names in selection
    panel_view(Panel,[]:Objs),
    $selection(Window,Objs,Selection,_),             % get current selection
    panel_view(Panel,delete(Selection),insert(Insertion)).   % replace current selection with scrap

$disambiguate([],[],_).

$disambiguate([selected(N,P,Class(name(Name),Etc..)),Os..],
              [selected(N,P,Class(name(Name),Etc..)),Us..],Window):-
    $unique_object(Window,Class,Name),!,
    $disambiguate(Os,Us,Window).

$disambiguate([selected(N,P,Class(name(Name),Etc..)),Os..],
              [selected(N,P,Class(name(UName),Etc..)),Us..],Window):-
    $create_unique(Window,Class,Name,1,UName),
    $disambiguate(Os,Us,Window).

$create_unique(Window,Class,Name,N,UName):-
    swrite(UName,Name,N),
    $unique_object(Window,Class,UName),!.

$create_unique(Window,Class,Name,N,UName):-
    N1 is N+1,
    $create_unique(Window,Class,Name,N1,UName).

panel_event(Panel,keystroke('\08',_),_):-       % delete key
    panel_id(Panel,_,Window),                   % applies only if current window is a panel
    panel_view(Panel,[]:Objs),
    $selection(Window,Objs,Selection,_),             % get current selection
    panel_view(Panel,delete(Selection)).        % and delete it    

$putscrap(Panel,Window,Selection):-
    ispanel(Panel,Window),                      % applies only if current window is a panel
    panel_view(Panel,[]:Objs),
    $selection(Window,Objs,Selection,_),        % get current selection
    forget(panel_scrap(_),$local)->[],          % forget current panel scrap
    remember(panel_scrap(Selection),$local).    % and remember new one

$getscrap(Selection):-
    recall(panel_scrap(Selection),$local).      % recall scrap
    
% -- Special class used for editing items ---------------------------------

% *** selected ****  The main editor object class....

panel_item_hit(selected(Name,Place,Item),X,Y):-
    panel_item_hit(Item,X,Y).

panel_item_graf(selected(Name,place(Place..),Item),Graf):-
    panel_item_graf(Item,Draw),
    $panel_item_select(Item,Place,Draw,Graf).

panel_item_write(selected(Name,_,Class(name(N0),Ps..)),Class(name(N1),CPs..),
                        selected(Name,place(SP..),Class(name(N2),place(P..),NPs..)),Graf):-
    panel_item_write(Class(name(N0),Ps..),Class(name(N1),CPs..),Class(name(N2),place(P..),NPs..),Draw),
    panel_expand_rect(P,1,1,SP),    
    $panel_item_select(Class(name(N2),place(P..),NPs..),SP,Draw,Graf).

% -- Highlight (invert) items normal graf to show it as selected ------------

$panel_item_select(Class(Name,place(XL,YT,XR,YB),Ps..),Box,Draw,
                    [[fillpat(clear),rectabs(Box..)],Draw,
                     [fillpat(invert),rectabs(Box..)],Growbox]):-
    panel_item_grow(Class(Name,place(XL,YT,XR,YB),Ps..),W,H),
    [W,H]=[0,0]->
       true;                            % can't grow, leave Growbox as var
       Growbox=[moveabs(XR,YB),backcolor(white),
                penpat(white),fillpat(hollow),rectrel(-12,-12,-3,-3),
                penpat(black),fillpat(pentype),rectrel(-11,-11,-4,-4)].


$ingrow(Class(N,place(XL,YT,XR,YB),Ps..),X,Y,[XL,YT,XR,YB]):-
    X > XR-12, Y > YB-12.

$sel_item(Panel,
          Class(Name,place(P..),Ps..),
          selected(name(S),place(SP..),Class(Name,place(P..),Ps..)),
          N):-
    $next_item(Panel,selected,N,S),
    panel_expand_rect(P,1,1,SP).    


% ----------------------- Support routines -------------------------------------------

% -- test for unique object within Window and Class ----
$unique_object(Panel,Class,Name):-
    not(panel_view(Panel,Class(name(Name),_..))),
    not(panel_view(Panel,selected(_,_,Class(name(Name),_..)))).
/*  not($getitem(_,Window(Class(name(Name),_..)))),
    not($getitem(_,Window(selected(_,_,Class(name(Name),_..))))).  */

% -- find a fresh name for a new item ----
$next_item(Panel,Class,N,Name):-
    swrite(Name,Class,N),
    $unique_object(Panel,Class,Name).

$next_item(Panel,Class,N,Name):-
    successor(N,N1),
    $next_item(Panel,Class,N1,Name).  

% -- replace an item in a list ----

$replacement([],_,Newitem,[Newitem]).  % if item doesn't exist, add it at the end

$replacement([Item,Items..],Item,Newitem,[Newitem,Items..]):-!.

$replacement([Other,Items..],Item,Newitem,[Other,Newitems..]):-
    $replacement(Items,Item,Newitem,Newitems).

/* -----------------------------------------------------------------------------------

    Support for editing panel properties 
    N.B. The following code is tightly coupled to 'panel sys'; it is put here
         so that all panel editing code can be easily omitted from applications.

----------------------------------------------------------------------------------- */

% the edit_panel panel
panel_definition(edit_panel,
    pos(42,62),
    size(384,243),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4)),
    field(name(pictid),place(314,167,368,187),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    field(name(pictfile),place(55,167,249,187),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    field(name(ygrid),place(340,76,368,96),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    field(name(xgrid),place(340,52,368,72),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    field(name(panel),place(68,8,219,28),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    button(name(gridx),place(236,52,338,72),style(transparent),label('Grid Spacing  X:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Background'),place(20,84,100,104),style(transparent),label('Background'),state(nil),font(0,12),icon(0),menu()),
    field(name(colour),place(244,108,330,128),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(white,black,red,green,cyan,blue,magenta,yellow),exitset(enter,'/t')),
    button(name('Colour:'),place(192,108,240,128),style(transparent),label('Colour:'),state(nil),font(0,12),icon(0),menu()),
    field(name(pattern),place(80,108,167,128),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(white,lightgray,gray,darkgray,black),exitset(enter,'/t')),
    button(name('Pattern:'),place(20,108,76,127),style(transparent),label('Pattern:'),state(nil),font(0,12),icon(0),menu()),
    button(name(dialog),place(240,28,342,45),style('check box'),label('Modal Dialog'),state(off),font(0,12),icon(0),menu()),
    button(name(lock),place(240,8,328,24),style('check box'),label('Lock Panel'),state(off),font(0,12),icon(0),menu()),
    button(name(gridy),place(324,76,340,96),style(transparent),label('Y:'),state(nil),font(0,12),icon(0),menu()),
    button(name('OK'),place(207,204,295,232),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    button(name('Panel:'),place(21,9,63,27),style(transparent),label('Panel:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Panel Style:'),place(20,39,99,58),style(transparent),label('Panel Style:'),state(nil),font(0,12),icon(0),menu()),
    field(name(outline),place(102,38,219,58),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'/t')),
    button(name(cancel),place(106,208,186,228),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name('Picture'),place(20,138,73,158),style(transparent),label('Picture'),state(nil),font(0,12),icon(0),menu()),
    button(name('Res ID:'),place(264,167,311,187),style(transparent),label('Res ID:'),state(nil),font(0,12),icon(0),menu()),
    button(name('File:'),place(22,168,51,184),style(transparent),label('File:'),state(nil),font(0,12),icon(0),menu())).

$panel_styles([document,dialog,namedDialog,rectangle,shadow,rounded,motif]).

% open 'edit_panel' panel when selected button 'opened'

panel_event(Panel,edit,void(void)):-
    panel_id(Panel,_,Window),
    positionwindow(Window,Xl,Yt),
    sizewindow(Window,W,H),
    % update current position and size in case of style changes
    panel_attribute(Panel,[]:
        [Pos,Size,style(St..),background(Pat,Col),picture(Pict..),lock(Lock),dialog(Dial),grid(GX,GY),Etc..]),
    panel_attribute(Panel,[]:=
        [pos(Xl,Yt),size(W,H),style(St..),background(Pat,Col),picture(Pict..),lock(Lock),dialog(Dial),grid(GX,GY),Etc..]),
    % remember current size in case of 'cancel'
    remember(selected(window(pos(Xl,Yt),size(W,H),style(St..),background(Pat,Col),
                             picture(Pict..),lock(Lock),dialog(Dial),grid(GX,GY),Etc..)),$local),
    $pfields(Pict,PFile,PId),
    swrite(XG,GX),swrite(YG,GY),
    %findall(S,$map_styles(_,S),Ss),$dedup(Ss,Styles),
    $panel_styles(Styles),
    scrndimensions(SW,SH,main),mbarheight(MH),
    X is SW//2,Y is (SH-MH)//2+MH,
	$outline_name(St,OutLine),					% 01/11/95:yanzhou@bnr.ca: Extract the style name
    panel_open(edit_panel,pos(X,Y),
               panel:=Window,
               outline:=OutLine,				% 01/11/95:yanzhou@bnr.ca: The style name here!
			   outline:=menu(Styles..),
               pattern:=Pat,
               colour:=Col,
               pictfile:=PFile,
               pictid:=PId,
               lock:=Lock,
               dialog:=Dial,
               xgrid:=XG,
               ygrid:=YG).

$outline_name([menubar,Name,_..], Name) :- !.
$outline_name([Name,_..], Name) :- !, symbol(Name).

%$dedup([],[]).
%$dedup([X,Xs..],[Ys..]):-$member(X,Xs),!,$dedup(Xs,Ys).
%$dedup([X,Xs..],[X,Ys..]):-$dedup(Xs,Ys).

$pfields([],'','').
$pfields(['',Id],'',PId):-
    swrite(PId,Id). % convert integer ID to a symbol
$pfields([nil,Id],nil,PId):-
    swrite(PId,Id). % convert integer ID to a symbol
$pfields([Name,Id],PName,PId):-
    fullfilename(PN,Name),
    concat('É:',PN,PName),
    swrite(PId,Id). % convert integer ID to a symbol

% -- edit_panel behaviour ----------------------------------------------------------

panel_event(edit_panel,update(Old..),field(name(panel),_,Value..)):-
    $fieldvalue(Value,New),
    $panel_name(New,Panel),
    $fieldvalue(Old,OldName),
    ispanel(OldPanel,OldName),
    panel_rename(OldPanel,Panel),       % replaces old data structures and reopens new window
    panel_id(Panel,_,Window),
    panel_view(edit_panel,field(panel):=[pre(''),selection(Window),post(''),top(0)],  % restore selection
                          button(cancel):=disable),  % disable cancel, can't go back
    activewindow(edit_panel,graf).      % leave edit_panel front

$panel_name(Str,Name:ID):-
    substring(Str,N,1,':'),
    successor(NN,N),substring(Str,1,NN,Name),
    concat(Str,'. ',In),
    sread(In,_:TID),
    ground(TID)->ID=TID;
        [successor(N,NP),
         namelength(Str,LS),
         L is LS-N,
         substring(Str,NP,L,ID)],
    !.
    
$hasMenubar :-
	panel_view(edit_panel,panel:Window),
	panel_id(Panel,_,Window),
	panel_attribute(Panel,style(St..)),
	$containsMenubar(St..),!.
	
$containsMenubar(menubar,X).
$containsMenubar(X,menubar).

$panel_name(Str,Str).   % instance format failed, use string as full template name
    
panel_event(edit_panel,update,field(name(outline),_,Value..)):-
    $fieldvalue(Value,New),
    $hasMenubar ->
    	$updatepaneldef(Window,style(X..),style(menubar,New)) ;
    	$updatepaneldef(Window,style(_),style(New)),
    panel_id(Panel,_,Window),
    panel_reopen(Panel),
    activewindow(edit_panel,graf).  % leave edit_panel front

panel_event(edit_panel,click,field(outline)).  % disable editing

panel_event(edit_panel,update,field(name(pattern),_,Value..)):-
    $fieldvalue(Value,New),
    $updatepaneldef(Window,background(_,Col),background(New,Col)),
    userupdate(Window,_,_).  % effect update event

panel_event(edit_panel,click,field(pattern)).  % disable editing

panel_event(edit_panel,update,field(name(colour),_,Value..)):-
    $fieldvalue(Value,New),
    $updatepaneldef(Window,background(Pat,_),background(Pat,New)),
    userupdate(Window,_,_).  % effect update event

panel_event(edit_panel,click,field(colour)).  % disable editing

panel_event(edit_panel,select(X,Y),field(name(pictfile),Rest..)):-
    selectafile('','Select',Name)->
       [$updatepanelpict(Window,[Name,Id]),
        $pfields([Name,Id],PName,_),
        panel_view(edit_panel,field(pictfile):=PName),
        userupdate(Window,_,_)];  % effect update event
       postevent(dispatch_panel_event,edit_panel,click(X,Y),field(name(pictfile),Rest..)). % dialog failed-> edit

panel_event(edit_panel,update,field(name(pictfile),_,Value..)):-
    $fieldvalue(Value,Name),
    $updatepanelpict(Window,[Name,Id]),
    userupdate(Window,_,_).  % effect update event

panel_event(edit_panel,update(Old..),field(name(pictid),_,Value..)):-
    $integerfield(Value,Id)->
       [$updatepanelpict(Window,[Name,Id]),
        userupdate(Window,_,_)];  % effect update event
       [beep,panel_view(field(pictid):=Old)]. % invalid Id, beep and restore old value

panel_event(edit_panel,update,button(name(lock),_,_,_,state(State),_..)):-
    $updatepaneldef(Window,lock(_),lock(State)).

panel_event(edit_panel,update,button(name(dialog),_,_,_,state(State),_..)):-
    $updatepaneldef(Window,dialog(_),dialog(State)).

panel_event(edit_panel,update(Old..),field(name(xgrid),_,Value..)):-
    [$integerfield(Value,GX),GX>0]->
       $updatepaneldef(Window,grid(_,GY),grid(GX,GY));
       [beep,panel_view(edit_panel,field(xgrid):=Old)]. % invalid grid spacing, beep and restore old value

panel_event(edit_panel,update(Old..),field(name(ygrid),_,Value..)):-
    [$integerfield(Value,GY),GY>0]->
       $updatepaneldef(Window,grid(GX,_),grid(GX,GY));
       [beep,panel_view(edit_panel,field(ygrid):=Old)]. % invalid grid spacing, beep and restore old value

panel_event(edit_panel,click,button('OK')):-
    panel_close(edit_panel).

panel_event(edit_panel,click,button(name(cancel),Ps..)):-
    not($member(state(disable),Ps)),
    recall(selected(window(Attrs..)),$local),    % revert to original object
    panel_view(edit_panel,panel:Window),
    panel_id(Panel,_,Window),
    panel_attribute(Panel,[]:=Attrs),   % put back old attributes
    panel_reopen(Panel),
    panel_close(edit_panel).          % quit editing button

panel_event(edit_panel,close):-
    forget(selected(_),$local).

$updatepaneldef(Window,Old,New):-
    panel_view(edit_panel,panel:Window),  % get current size and position and saved options
    panel_id(Panel,_,Window),
    panel_attribute(Panel,Old:=New),
    panel_attribute(Panel,dirty(_):=dirty(on)).

$updatepanelpict(Window,[Name,Id]):-
    panel_view(edit_panel,panel:Window),  % get current size and position and saved options
    panel_id(Panel,_,Window),
    panel_attribute(Panel,picture(Pict..)),
    once($changepict(Pict,[Name,Id])),
    panel_attribute(Panel,picture(Pict..):=picture(Name,Id)),
    panel_attribute(Panel,dirty(_):=dirty(on)).

$changepict([],[Name,0]):-symbol(Name).
$changepict([],[nil,Id]):-integer(Id).
$changepict([_,OI],[Name,OI]):-symbol(Name).
$changepict([ON,_],[ON,Id]):-integer(Id).

$integerfield(Value,Int):-
    $fieldvalue(Value,Sym),
    concat(Sym,'. ',Term),
    sread(Term,Int),
    integer(Int).

$fieldvalue([pre(N1),selection(N2),post(N3),_..],Val):-swrite(Val,N1,N2,N3).

/* --------------------------------------------------------------------------------------

    Supporting utilities for editing buttons, fields, and lists

-------------------------------------------------------------------------------------- */

$mark_select(Panel,Sn):-new_obj(selobj(Panel,Sn),_,$local).
$unmark_select:-forget_all(selobj(_..),$local).
$selected(Panel,Sn):-get_obj(_,selobj(Panel,Sn),$local).

% open a class editor
$open_editor(Dialog,Panel,SName,Class(Ps..),Styles):-
    remember(selected(Panel,SName,Class(Ps..)),$local),
    $map_props(Ps,OPs),
    scrndimensions(SW,SH,main),mbarheight(MH),
    X is SW//2,Y is (SH-MH)//2+MH,
    panel_id(Panel,_,Window),
    findall(F,panelfontinfo(F,_,_),Fonts),
    panel_open(Dialog,pos(X,Y),panel:=Window,
                               field(outline):=menu(Styles..),
                               field(font):=menu(Fonts..),OPs..),
    $mark_select(Panel,SName).

$close_editor(Dialog):-
    forget_all(selected(_..),$local),
    $unmark_select.

% map common button, field, and list properties on to writes to editing panels

$map_props([],[]).

$map_props([name(Term),Vs..],[field(name):=Name,Rest..]):-      % name property
    swrite(Name,Term),
    $map_props(Vs,Rest).

$map_props([font(F,S,St..),Vs..],
            [field(font):=Fontname,field(size):=[selection(SS),menu(Sizes..)],Rest..]):-  % font property
    panelfontinfo(Fontname,F,Sizes),
    swrite(SS,S),
    $map_styles(St,[Rest..],[Cont..]),
    $map_props(Vs,Cont).

$map_props([style(V),Vs..],[field(outline):=V,Rest..]):-        % style property
    $map_props(Vs,Rest).

$map_props([menu(Menu..),Vs..],                                 % menu property
           [list(menuitems):=[contents(Menu..),selection(S,_),top(1)],Rest..]):-
    Menu=[]->S=0;S=1,
    $map_props(Vs,Rest).

$map_styles([],Cont,Cont).
$map_styles([Style,St..],[button(Style):=on,Rest..],Cont):-$map_styles(St,Rest,Cont).

% property mapping default for class editors
$map_props([_,Vs..],Rest):-     % unrecognizable property
    $map_props(Vs,Rest).

% update selected item with property 
$update_selected(NewProp):-
    $selected(Panel,Sn),                                % get selection
    panel_view(Panel,selected(Sn,SP,Item)),             % get item
    panel_item_write(Item,NewProp,NewItem,_),           % write property to item
    panel_view(Panel,selected(Sn,SP,Item):=NewItem).    % write item to selection
    
% get and put item based on info in dialog panel
$get_dialog_item(Panel,Item):-
    $selected(Panel,Sn),
    panel_view(Panel,selected(Sn,_,Item)).

$put_dialog_item(Class(Ps..),NewProp):- 
    panel_item_write(Class(Ps..),NewProp,NewItem,_),
    $selected(Panel,name(Sn)),
    panel_view(Panel,selected(Sn):=NewItem).

% convert symbol name to term name
$obj_name(Symbol,Term):-
    concat(Symbol,'. ',Read),
    sread(Read,Term),
    ground(Term),!.

$obj_name(Symbol,Symbol).

% rename selected object
$selection_rename(New):-
    $fieldvalue(New,Newvalue),
    $obj_name(Newvalue,NewName),
    $update_selected(name(NewName)).

% update font name
$update_font(Dialog,Value):-
    $fieldvalue(Value,New),
    panelfontinfo(New,FNum,Sizes),
    $get_dialog_item(Panel,Class(IPs..)),
    $member(font(_,Etc..),IPs),
    $put_dialog_item(Class(IPs..),font(FNum,Etc..)),
    panel_view(Dialog,field(size):=menu(Sizes..)).

% update font size
$update_font_size(Dialog,Value):-
    $fieldvalue(Value,New),
    [concat(New,'. ',Str),sread(Str,Size),integer(Size)]-> % new size must be integer
       [$get_dialog_item(Panel,Class(IPs..)),
        $member(font(F,_,St..),IPs),
        $put_dialog_item(Class(IPs..),font(F,Size,St..))];
       panel_view(Dialog,field(size):=Old).

% update a font style (turn it on or off)
$update_font_style(Style,Ps):-
    $member(Style,[bold,italic,underline,outline,shadow,extend,condense]),
    $member(state(State),Ps),
    $get_dialog_item(Panel,Class(IPs..)),
    $member(font(F,S,St..),IPs),
    $set_fstyle(State,Style,St,NSt),
    $put_dialog_item(Class(IPs..),font(F,S,NSt..)).

% build font style attribute list
$set_fstyle(on,Attr,[Rest..],[Attr,Rest..]).        % add attribute to list
$set_fstyle(off,Attr,[Attr,Rest..],[Rest..]):-!.    % remove attribute from list
$set_fstyle(off,Attr,[],[]):-!.                     % didn't find it, succeed anyway
$set_fstyle(off,Attr,[R,Rest..],[R,NRest..]):-
    Attr\=R,$set_fstyle(off,Attr,Rest,NRest).       % not this one, keep looking

% open a menu item for editing
$openmenuitem(Dialog,selection(I,S)):-
    panel_view(Dialog,field(edititem):=S,field(name(edititem),Ps..)),
    remember(edititem(I),$local),
    postevent(panel_event,Dialog,click(_,_),field(name(edititem),Ps..)).

% utilities to replace, insert and delete items in a menu list
$replace(N,L,'',NewL):-             % treat replacement by null as delete
    $delete(N,L,NewL),!.
$replace(1,[L,Ls..],New,NewLs):-    % found item to be replaced
    $prepend(New,Ls,NewLs),!.
$replace(N,[L,Ls..],New,[L,NewLs..]):-  % continue scan for replaced item
    successor(N1,N),
    $replace(N1,Ls,New,NewLs).

$insert(_,[],New,NewLs):-         % insert before end of list
    $prepend(New,[],NewLs),!.
$insert(0,Ls,New,NewLs):-           % found insertion point after current selection
    $prepend(New,Ls,NewLs),!.
$insert(N,[L,Ls..],New,[L,NewLs..]):-   % continue scan for insertion point
    successor(N1,N),
    $insert(N1,Ls,New,NewLs).

$delete(1,[L,Ls..],[Ls..]):-!.
$delete(N,[L,Ls..],[L,NewLs..]):-
    successor(N1,N),
    $delete(N1,Ls,NewLs).

$prepend('',Ls,Ls):-!.            % nil string gets tossed

$prepend(New,Ls,[Sub,NewLs..]):-
    substring(New,N,1,'\n'),!,    % if New contains a newline, then more than 1 item
    successor(N1,N),
    substring(New,1,N1,Sub),      % pick off head
    concat(Sub,RestP,New),        % rest plus newline
    concat('\n',Rest,RestP),      % rest
    $prepend(Rest,Ls,NewLs).

$prepend(New,Ls,[New,Ls..]).      % non-nil, no newline, just add item    



