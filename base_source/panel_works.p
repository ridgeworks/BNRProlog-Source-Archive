/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/panel_works.p,v 1.1 1995/09/22 11:25:53 harrisja Exp $
*
*  $Log: panel_works.p,v $
 * Revision 1.1  1995/09/22  11:25:53  harrisja
 * Initial version.
 *
*
*/
/*
 *   panel works
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
% -- other local predicates used:
%   $getitem     in 'panel view'
%   $resizepanel in 'panel view'
%   $updatepanel in 'panel sys'
%   $switchable  in 'panel sys'

panelfont(systemfont,12).   % standard panel font


/*

    Every item has a standard form:

        Class(name(Name),place(Xl,Yt,Xr,Yb),Properties..) 

    where:  Class = the object class (eg field, button, icon, ...)
            Name = term used to label the object instance
            [Xl,Yt,Xr,Yb] = placement of the item, a rectangle  
            Properties = sequence of object properties

    Required methods for every object (often the standard default is fine):

    panel_item_class(Class) -- puts Class in new item menu list

    panel_item_new(Class,Name,X,Y,Item) -- to create a new instance

    panel_item_hit(Item,X,Y) -- mouse-down at X,Y hits item? (normally rely on default)

    panel_item_graf(Item,Graf) -- essential to define how to draw any class 

    panel_item_read(Item,Value) -- called from panel_view,  Item:Value 

    panel_item_write(Item,Value,Item,Graf) -- called from panel_view,  Item:=Value 

    panel_item_grow(Item,Xmin,Ymin) -- limit growth, 0 = don't allow re-size...


*/
% *** default object methods ***********************************************************

% -- new method --

panel_item_new(Class,Name,X1,Y1,Item):-
   $report('panel_item_new for ',Class,' undefined?').
        
% -- hit method --

panel_item_hit(_(_,place(X1,Y1,X2,Y2),_..),X,Y):- % inside Place...
    X >= X1, X =< X2, Y >= Y1, Y =< Y2.

% -- graf method --

panel_item_graf(Class(N,place(P..),V..),[[rectabs(P..)]]):-
    nl,write('panel_item_graf failed on:\n',Class(N,place(P..),V..));true.

% -- read methods --

panel_item_read(Class(V..),Prop(Pval..)):-    % handle property list case
    symbol(Prop),
    $member(Prop(Pval..),V),!.

panel_item_read(Item,[Props..]):-       % list, read each term 
    $getprops([Props..],Item).

$getprops([],_).
$getprops([Prop,Props..],Item):-
    panel_item_read(Item,Prop),
    $getprops(Props,Item).

panel_item_read(Item,Item).             % else just return Item

% -- write methods --

panel_item_write(Item,Value,Item,_):-   % special case, new value is a variable, 
    var(Value).                         % treat as a noop.

panel_item_write(Class(_,Ps..),name(New),Class(name(New),Ps..),_):-!.  % name replacement

panel_item_write(Item(N,P,Ps..),place(NP..),Item(N,place(NP..),Ps..),_):-!. 
        % new placement/size, panel_view handles graphics

panel_item_write(Class(Ps..),Prop(Pval..),Newitem,Graf):-  % property replacement
    $update_props([Prop(Pval..)],Ps,NPs),
    panel_item_write(Class(Ps..),Class(NPs..),Newitem,Graf).

panel_item_write(Class(Ps..),[Props..],Newitem,Graf):-     % list not swallowed, is it a property list
    $update_props([Props..],Ps,NPs),
    panel_item_write(Class(Ps..),Class(NPs..),Newitem,Graf).

$update_props([],V,V).              % end of property list

$update_props([Prop(Pval..),Props..],IV,V):-
    symbol(Prop),
    $replace(Prop(_..),IV,Prop(Pval..),NV),  % replace property and try again
    $update_props(Props,NV,V).
    
$replace(Old,[Old,Rest..],New,[New,Rest..]).
$replace(Old,[P,OL..],New,[P,NL..]):-$replace(Old,OL,New,NL).
       
panel_item_write(Class(_..),
                 Class(name(N),place(XL,YT,XR,YB),Ps..),
                 Class(name(N),place(XL,YT,XRR,YBB),Ps..),Graf):- 
    % new value, update and draw
    panel_item_grow(Class(name(N),place(XL,YT,XR,YB),Ps..),W,H),    % get min size
    XR-XL<W->XRR is XL+W-1;XRR=XR,  % enforce min size
    YB-YT<H->YBB is YT+H-1;YBB=YB,
    panel_item_graf(Class(name(N),place(XL,YT,XR,YBB),Ps..),Graf).
       
panel_item_write(Class(Ps..),_,Class(Ps..),_).    % no fit, leave it alone, no graf 
       
% -- grow methods --

panel_item_grow(Item,0,0). % default = no size change


% -- catchall for object conversion --

$upgradeobj(Item,Item). % no internal conversion necessary, may be user class

% -------- User event handlersÊ---------------------
userupdate(Window,_,_):-
    ispanel(Panel,Window),
    $updatepanel(Window),
    fail.   % allow other update handlers to execute (unlikely requirement)

userswitch(Window,Old,_):-
    $switchable(Old)->                              % can deactivate old window
       [ispanel(Panel,Window),                      % is new window a panel,
        activewindow(Window,graf),                  % make it active
        lasteventdata(userswitch,Window,[X,Y],_..), % convert to usermousedown/usermouseup
        localglobal(Window,Xl,Yl,X,Y),
        postevent(usermousedown,Window,Xl,Yl),      % doesn't work because posted events
        postevent(usermouseup,Window,Xl,Yl)];       % don't have proper lasteventdata
       beep.

userdrag(Target,X,Y):-
    activewindow(Active,_),                         % get current active window
    Active=Target,!,                                % if Target is active window
    dragwindow(Target,X,Y,[0,0,0,0]).               % drag it

userdrag(Target,X,Y):-                              % target not the active window
    activewindow(Active,_),                         % get current active window
    $switchable(Active)->                           % is active window switchable
       [iswindow(Target,Type),
        activewindow(Target,Type),                  % activate target
        postevent(userdrag,Target,X,Y)];            % and post drag event
       beep.

userresize(Window,W,H):-        % window resized (Motif event)
    ispanel(Panel,Window),
    $resizepanel(Window).

userclose(Window,_,_):-  
    ispanel(Panel,Window),
    panel_close(Panel);[].  % on user aborts we dont want the system close!

userkey(Window,Key,Mods):-   % resissue key strokes on panels
    ispanel(Panel,Window),
    voiditem(Void),
    dispatch_panel_event(Panel,keystroke(Key,Mods),Void).    

%  --  Standard basic event generation  -------------------------------
%      Note that mouse coordinates are picked up from lasteventdata, not arguments;
%      this produces current mouse coordinates for events generated via nextevent.

usermousedown(Window,EX,EY):-
    get_obj(HOp,Window(Panel,down(Prev(PName,PPlace),T1,_..),Items),$local),
    $modifiers(Window,EX,EY,X,Y,T2,Mod..),
    $target_item(Items,Window,X,Y,Class(name(Name),place(Place..),Etc..)),
    put_obj(HOp,Window(Panel,down(Class(Name,Place),T2,X,Y),Items),$local),
    [Prev(PName,PPlace)=Class(Name,Place), doubletime(Delta), T2 < T1 + Delta]
        -> Event = doubleclick; Event = select,
    dispatch_panel_event(Panel,Event(X,Y,Mod..),Class(name(Name),place(Place..),Etc..)).

userdownidle(Window,EX,EY):-
    $useridle(Window,EX,EY,downidle).

userupidle(Window,EX,EY):-
    $useridle(Window,EX,EY,upidle).

usermouseup(Window,EX,EY):-
    get_obj(HOp,Window(Panel,down(Prev(PName,PPlace),_..),Items1),$local),
    $modifiers(Window,EX,EY,X,Y,_,Mod..),
    Prev=void ->
       [voiditem(Void), 
        dispatch_panel_event(Panel,unselect(X,Y),Void)];
       [$getitem(_,Window(Prev(name(PName),place(PPlace..),PEtc..))),
        dispatch_panel_event(Panel,unselect(X,Y,Mod..),Prev(name(PName),place(PPlace..),PEtc..))],
    get_obj(HOp,Window(Panel,Down,Items),$local),  % refetch list in case event changed it
    $target_item(Items,Window,X,Y,Class(name(Name),place(Place..),Etc..)),
    (Class(Name,Place)=Prev(PName,PPlace))->
        dispatch_panel_event(Panel,click(X,Y,Mod..),Class(name(Name),place(Place..),Etc..)).

$useridle(Window,EX,EY,Idle):-
    get_obj(_,Window(Panel,Down,Items),$local),
    $modifiers(Window,EX,EY,X,Y,_,Mod..),
    $target_item(Items,Window,X,Y,Item),
    dispatch_panel_event(Panel,Idle(X,Y,Mod..),Item),
    fail.   % pass on idles

$modifiers(Window,EX,EY,X,Y,T,Mod..):-
    lasteventdata(_,_,[GX,GY],T,[Ctrl,Opt,_,Shft,Cmnd,_]),
    var(GX,GY)->
        [X,Y]=[EX,EY];  % if GX,GY vars, e.g., after postevent, bind X,Y to event data
        localglobal(Window,X,Y,GX,GY),
    [Ctrl,Opt,Shft,Cmnd]=[0,0,0,0]->Mod=[];Mod=[Ctrl,Opt,Shft,Cmnd].

% generate variations on events

dispatch_panel_event(Panel,Event(E..),Class(name(Name),_..)):-  % try short forms first
    panel_event(Panel,Event,Class(Name)),!.
 
dispatch_panel_event(Panel,Event,Class(name(Name),_..)):-
    panel_event(Panel,Event,Class(Name)),!.
 
dispatch_panel_event(Panel,Event(E..),Item):- 
    panel_event(Panel,Event,Item),!.
 
dispatch_panel_event(Panel,Event,Item):-
    panel_event(Panel,Event,Item).

% default panel behaviour

panel_event(Panel,select(X,Y),void(void)):-  % can grow by bottom right corner
    ispanel(Panel,Window),
    sizewindow(Window,W,H),
    X>(W-16),Y>(H-16),
    $unlocked(Panel),                       % can't grow locked panels
    localglobal(Window,X,Y,GX,GY),
    growwindow(Window,GX,GY,[0,0,0,0]),
    $resizepanel(Window).

panel_event(Panel,select(X,Y),void(void)):-  % can drag by top
    Y<16,
    ispanel(Panel,Window),
    localglobal(Window,X,Y,GX,GY),
    dragwindow(Window,GX,GY,[0,0,0,0]).

panel_event(Panel,open).                % the end of the line for open

panel_event(Panel,close).               % the end of the line for close
    
panel_event(Panel,doubleclick(E..),Class(N,P,Ps..)):-
                % doubleclick not handled, turn it into a select
    dispatch_panel_event(Panel,select(E..),Class(N,P,Ps..)),!.
 
panel_event(Panel,Event(_..),Class(N,P,Ps..)).  % the end of the line, just ignore it.

% ----------------------- Support routines -------------------------------------------

%$member(Item,[Item,_..]).

%$member(Item,[_,Items..]):- $member(Item,Items).

$report(Msgs..):-
    swrite(Msg,Msgs..),
    message(Msg).

% given a list of objects and a coordinate pair, find which object inludes the coordinates
% first the local variety
$target_item([],_,X,Y,Void):-
    voiditem(Void).

$target_item([[Op,[XL,YT,XR,YB]],Items..],Panel,X,Y,Item):-
    X >= XL, X =< XR, Y >= YT, Y =< YB,
    $getitem(Op,Window(Item)),
    panel_item_hit(Item,X,Y).

$target_item([_,Items..],Panel,X,Y,Item):-
    $target_item(Items,Panel,X,Y,Item).

% global variety
panel_target_item([],X,Y,Void):-voiditem(Void).

panel_target_item([Item,_..],X,Y,Item):-
    panel_item_hit(Item,X,Y).

panel_target_item([_,Items..],X,Y,Item):-
    panel_target_item(Items,X,Y,Item).

panel_target_item(Panel,X,Y,Item):-
    get_obj(_,Window(Panel,Down,Items),$local),
    $target(Items,Window,X,Y,Item).

% Utility to expand object size
panel_expand_rect([X1,Y1,X2,Y2],X,Y,[X3,Y3,X4,Y4]):-
    X3 is X1-X, Y3 is Y1-Y, X4 is X2+X, Y4 is Y2+Y.

% Utility to determine text size in standard panel font, and arbitrary font

panel_text_size(Text,Font,Length,Height,Descent):-
    iswindow(W,graf,_), % W is any graf window
    $textwidth(W,Text,Font,Width),
    Length is Width+2,
    $fontheight(Font,Height,Descent,Offs),
    !.

panel_text_size(Text,Length,Height):-
    text_size(Text,Length,Height,_),!.

panel_text_size(Text,Length,Height,Descent):-
    panelfont(Font,Size),
    panel_text_size(Text,font(Font,Size),Length,Height,Descent). 

$textwidth(W,Text,font(Font,Size,St..),Width):-
    dograf(W,[textfont(Font),textsize(Size),textface(St..)]),   % set text attributes
    inqgraf(W,textwidth(Text,Width)),!.     % try inqgraf first
$textwidth(W,Text,font(Font,Size,St..),Width):-
    dograf(W,textwidth(Text,Width)).        % inqgraf failed, try dograf

$fontheight(font(F,S,St..),Height,Descent,Offs):-
    isfont(F,S,_,[Ascent,Descent,Leading,_],face(St..)),!,
    Offs is Ascent+3,
    Height is Ascent+Descent+Leading.  % minimum height is font height

$fontheight(Font,Height):-
    $fontheight(Font,Height,_,_).

% void item
voiditem(void(name(void),place(0,0,0,0))).
    
% default motif colour
$motif_colour(lightgray).
