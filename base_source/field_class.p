/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/field_class.p,v 1.3 1996/03/14 03:18:09 yanzhou Exp $
*
*  $Log: field_class.p,v $
 * Revision 1.3  1996/03/14  03:18:09  yanzhou
 * Bug fix:
 * In xBNRProlog, an update panel event is dispatched whenever a field has been
 * modified.  The event should be, but was not, dispatched like this:
 *     panel_event(Panel, update(Old..), field(name(Name), New..))
 * where Old.. are old values and New.. are new values.
 *
 * Now fixed.
 *
 * Revision 1.2  1996/01/02  16:44:21  yanzhou
 * "Cut and paste" now works for text fields (edit boxes).
 *
 * Revision 1.1  1995/09/22  11:24:16  harrisja
 * Initial version.
 *
*
*/
/*
 *   field_class
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
/*
    Field Class

    Object Form:
        field(name(Name),       % a term identifying the button in a panel
              place(Place..),   % a list of 4 integers defining a rectangle
              pre(Pre_Sel),     % symbol prior to selection in field
              selection(Sel),   % symbol representing selection in field
              post(Post_Sel),   % symbol after selection in field
              top(Top),         % top line visible in field (integer) 
              font(F,S,St..),   % font name, size and style specification
              lock(OnOff),      % flag indicating whether the field is editable
              lines(OnOff),     % flag indicating whether lines are to be visible
              style(Style),     % one of transparent, opaque, rectangle, shadow, motif
              menu(Sel..),      % menu associated with a field
              exitset(exitchs..)% set of edit exit chars, default is <tab>,<enter>
              )                 % end of value specification
*/

% -- other local predicates used:
%   $fontheight  in 'panel works'

% *** field ***   Animation...

panel_event(Panel,select(X,Y),field(name(Name),place(Xl,Yt,_,_),
                Pre,Sel,Post,Top,Font,lock(off),Lines,Style,menu(M,Ms..),_..)):-
    successor(Xl,PX),successor(Yt,PY),
    $fieldval([Pre,Sel,Post],Current),
    $member(Current,[M,Ms..])->S=Current;S=M,
    cut,    % commit
    panel_menu(Panel,[M,Ms..],S,PX,PY,New),
    panel_view(Panel,field(Name):=[pre(''),selection(New),post(''),top(0)],
                     field(name(Name),Etc..)),  % unify with new object
    dispatch_panel_event(Panel,update(Pre,Sel,Post,Top),field(name(Name),Etc..)).

panel_event(Panel,click(X,Y),field(name(Name),place(Place..),
                                   pre(Pre_Sel),selection(Sel),post(Post_Sel),top(Top),
                                   font(F,S,St..),lock(off),Lines,style(Style),
                                   Menu,exitset(XChs..),Etc..)):-
    panel_id(Panel,_,Window),
    $fcontainer(Style,Place,_,[Xl,Yt,Xr,Yb],_,_,BP,BC,12),  % get edit area (12 is dont care integer
    %new_obj(edfield(Pre_Sel,Sel,Post_Sel,Top),Op,$local),
    new_obj(edfield([Pre_Sel,Sel,Post_Sel,Top]),Op,$local),
    repeat,         % failure driven loop to conserve stack
        %get_obj(Op,edfield(Value..),$local),
        get_obj(Op,edfield(Value),$local),
/*        nl,writeq(dograf(Window,[[BP,BC,
                       textfont(F),textsize(S),textface(St..),
                       editbabs(Xl,Yt,Xr,Yb,Value,New)]])),*/
/*
        dograf(Window,[[BP,BC,
                       textfont(F),textsize(S),textface(St..),editexitset(XChs..),
                       editbabs(Xl,Yt,Xr,Yb,Value,New)]]) ->
*/
        dograf(Window,[BP,BC,textfont(F),textsize(S),textface(St..)]),
        $editfield(Window,Xl,Yt,Xr,Yb,Value,New,XChs) ->    
           [%% WAS: nextevent(Ev,W,D1,D2),               % get terminating event
            %% 02/01/96: changed by yanzhou@bnr.ca to:
            userevent(Ev,W,D1,D2),				% get terminating event
            $facton(Ev,W,D1,D2,XChs,Panel,New,Nxt)-> % was it a continuation event
               [% it was, consume it,and backtrack
                %put_obj(Op,edfield(Nxt..),$local),  % save for failure driven loop
                put_obj(Op,edfield(Nxt),$local),% save for failure driven loop
                fail];
               [[N1,N2,N3,T]=New,
                panel_view(Panel,field(Name):=[pre(N1),selection(N2),post(N3),top(T)],
                                 field(name(Name),Ps..)),   % get new value
                dispatch_panel_event(Panel,
                                 update(pre(Pre_Sel),selection(Sel),post(Post_Sel),top(Top)),
                                 field(name(Name),Ps..))]],
        dispose_obj(Op,$local),!.   % exit, delete state info and cut repeat.

$editfield(Args..):-
    predicate(editbabs),!,
    editbabs(Args..).    
$editfield(Window,Xl,Yt,Xr,Yb,Value,New,XChs):-
    dograf(Window,[editexitset(XChs..),editbabs(Xl,Yt,Xr,Yb,Value,New)]).    

% edit continuation events
$facton(menuselect,W,'Edit','Copy',_,Panel,[N1,N2,N3,T],[N1,N2,N3,T]):-
	panel_id(Panel,_,W),
	!,
    N2=''->beep;texttoscrap(N2).

$facton(menuselect,W,'Edit','Cut',_,Panel,[N1,N2,N3,T],[N1,'',N3,T]):-
	panel_id(Panel,_,W),
	!,
    N2=''->beep;texttoscrap(N2).

$facton(menuselect,W,'Edit','Paste',_,Panel,[N1,N2,N3,T],[N4,'',N3,T]):-
	panel_id(Panel,_,W),
    scraptotext(N5),      % put scrap at end of prefix and remove selection
	!,
	concat(N1,N5,N4).

$facton(menuselect,W,'Edit','Paste',_,Panel,Contents,Contents):-
	panel_id(Panel,_,W),
	!,
    beep.                 % no text in scrap, beep and return

$facton(menuselect,W,'Edit','Select All',_,Panel,[N1,N2,N3,T],['',N4,'',T]):-
	panel_id(Panel,_,W),
	!,
    swrite(N4,N1,N2,N3).

$facton(E,W,D1,D2,_,Panel,C,C):-				% fall through
	nextevent(E,W,D1,D2),						% put the event back to the queue
	panel_id(Panel,_,PW),
	PW \= W,
	userdeactivate(PW,_,_)->true,
	useractivate(W,_,_)->true,
	fail.

% *** field ***  Graphics...

panel_item_class(field).

panel_item_new(field,Name,X1,Y1,
               field(name(Name),place(X1,Y1,X2,Y2),
                     pre(''),selection(''),post(''),top(0),
                     font(0,12),lock(off),lines(off),style(rectangle),
                     menu(),exitset(enter,'\09'))):-
    $fontheight(font(0,12),H),
    X2 is X1+100,
    Y2 is Y1+H+4.   

panel_item_graf(field(Name,place(Place..),
                      pre(Pre_Sel),selection(Sel),post(Post_Sel),top(Top),
                      font(F,S,St..),Lock,lines(OnOff),style(Style),Menu..),
                [[BP,BC,textfont(F),textsize(S),textface(St..),Cont,
                  textbabs(X3,Y3,X4,Y4,[Pre_Sel,Sel,Post_Sel,Top]),Back]]):-
    $fontheight(font(F,S,St..),H,D,Offs),
    $fcontainer(Style,Place,Cont,[X3,Y3,X4,Y4],_,_,BP,BC,H),
    $fbackgrnd(Style,[X3,Y3,X4,Y4],OnOff,H,Offs,Back).

$fcontainer(transparent,[Place..], textbabs(X3,Y3,X4,Y4,Newlines),
        [X3,Y3,X4,Y4],6,4,_,_,H):-
    panel_expand_rect(Place,-3,-2,[X3,Y3,X4,Y4]),
    Y is Y3+H,    % clear by writing blank lines for height of box,
    $newlines(Y,Y4,H,[13],Newlines).    %  preserves underlying patterns.colours but not pictures
$fbackgrnd(transparent,EPlace,OnOff,H,Offs,[penmode(or),penpat(gray),Lines..]):-
    $flines(OnOff,EPlace,H,Offs,Lines).

$fcontainer(opaque,[Place..],[fillpat(clear),rectabs(Place..)],
        EPlace,6,4,backpat(white),backcolor(white),_):-
    panel_expand_rect(Place,-3,-2,EPlace).
$fbackgrnd(opaque,EPlace,OnOff,H,Offs,[penmode(or),penpat(gray),Lines..]):-
    $flines(OnOff,EPlace,H,Offs,Lines).

$fcontainer(rectangle,[Place..],
        [fillpat(clear),rectabs(Place..),fillpat(hollow), rectabs(Place..)],
        EPlace,6,4,backpat(white),backcolor(white),_):-
    panel_expand_rect(Place,-3,-2,EPlace).
$fbackgrnd(rectangle,EPlace,OnOff,H,Offs,[penmode(or),penpat(gray),Lines..]):-
    $flines(OnOff,EPlace,H,Offs,Lines).

$fcontainer(shadow,[Xl,Yt,Xr,Yb],
       [fillpat(clear), rectabs(Xl,Yt,XFr,YFb),
        fillpat(hollow),rectabs(Xl,Yt,XFr,YFb),
        moveabs(XSl,YFb),penmode(or),pensize(2,2),lineabs(XFr,YFb,XFr,YSt)],
       EPlace,8,6,backpat(white),backcolor(white),_):-
    XFr is Xr-2,YFb is Yb-2,    % field boundaries
    XSl is Xl+3,YSt is Yt+3,    % shadow boundaries
    panel_expand_rect([Xl,Yt,XFr,YFb],-3,-2,EPlace).
$fbackgrnd(shadow,EPlace,OnOff,H,Offs,[penmode(or),penpat(gray),Lines..]):-
    $flines(OnOff,EPlace,H,Offs,Lines).

$fcontainer(motif,[Xl,Yt,Xr,Yb],
       [fillpat(clear),rectabs(XFl,YFt,XFr,YFb),
        fillpat(pentype),backcolor(white),
        penpat(black),moveabs(Xl,Yt),
        polygon(lineabs(Xr,Yt,XFr,YFt,XFl,YFt,XFl,YFb,Xl,Yb,Xl,Yt)),
        penpat(white),moveabs(Xr,Yb),
        polygon(lineabs(Xl,Yb,XFl,YFb,XFr,YFb,XFr,YFt,Xr,Yt,Xr,Yb)),
        penpat(black),fillpat(hollow),rectabs(Xl,Yt,Xr,Yb)],
       EPlace,10,8,backpat(white),backcolor(BC),_):-
    $motif_colour(BC),
    panel_expand_rect([Xl,Yt,Xr,Yb],-3,-3,[XFl,YFt,XFr,YFb]),    % field boundaries
    panel_expand_rect([XFl,YFt,XFr,YFb],-2,-1,EPlace).
$fbackgrnd(motif,[EPlace..],OnOff,H,Offs,
        [penmode(or),
         %fillpat(pentype),penpat(lightgray),rectabs(EPlace..),
         penpat(gray),Lines..]):-
    $flines(OnOff,EPlace,H,Offs,Lines).

$flines(off,_,_,_,[]).
$flines(on,[Xl,Yt,Xr,Yb],H,Offs,Lines):-
    Xl1 is Xl-2,Xr1 is Xr+1,
    Yt1 is Yt-2+Offs,Yb1 is Yb+2,
    $genflines([Xl1,Yt1,Xr1,Yb1],H,Offs,Lines).

$genflines([Xl,Yt,Xr,Yb],H,Offs,[]):-
    Yt>=Yb,!.
$genflines([Xl,Y,Xr,Yb],H,Offs,[moveabs(Xl,Y),lineabs(Xr,Y),Lines..]):-
    NY is Y+H,
    $genflines([Xl,NY,Xr,Yb],H,Offs,Lines).

$newlines(Y,Yb,H,NLs,Newlines):-
    Y>=Yb,!,
    name(Newlines,NLs).
$newlines(Y,Yb,H,NLs,Newlines):-
    Y<Yb,
    Yn is Y+H,
    $newlines(Yn,Yb,H,[13,NLs..],Newlines).
        

panel_item_grow(field(_,place(Place..),Ps..),W,H):-
    $member(font(F,S,St..),Ps),
    $member(style(Style),Ps),
    $fontheight(font(F,S,St..),FH),
    $fcontainer(Style,Place,_,_,Xb,Yb,_,_,FH),
    $fieldminsize(S,Xb,W),
    $fieldminsize(FH,Yb,H),cut.     % make deterministic

panel_item_read(field(Name,Place,Ps..),Contents):-
    % read just returns the concatenated text
    $fieldval(Ps,Contents).

panel_item_write(field(Name,Place,Pre,Sel,Post,Top,Font,Lock,Lines,Style,menu(_..),Etc..),
                 menu(Ms..),
                 field(Name,Place,Pre,Sel,Post,Top,Font,Lock,Lines,Style,menu(Ms..),Etc..),
                 []).  % changing menu only, no difference in appearance

panel_item_write(field(Name,Place,Pre,Sel,Post,Top,Font,Lock,Etc..),
                 lock(OnOff),
                 field(Name,Place,Pre,Sel,Post,Top,Font,lock(OnOff),Etc..),
                 []).     % changing lock only, no difference in appearance

panel_item_write(field(Name,Place,Pre,Sel,Post,Top,Font,Lock,Lines,Style,Menu,exitset(_..),Etc..),
                 exitset(XChs..),
                 field(Name,Place,Pre,Sel,Post,Top,Font,Lock,Lines,Style,Menu,exitset(XChs..),Etc..),
                 []).     % changing exit characters only, no difference in appearance

/*  Relax restriction of exact line alignment for grid purposes
panel_item_write(field(_..),
        field(name(N),place(XL,YT,XR,YB),Ps..),
        field(name(N),place(XL,YT,XR,YBB),Ps..),
        Graf):-
    % make sure region holds integral number of lines
    Ps=[pre(N1),selection(N2),post(N3),Top,Font,Lock,Lines,style(Style),Menu..],
    symbol(N1,N2,N3),
    $fontheight(Font,H),                 % changing font, placement, etc..
    $fcontainer(Style,[XL,YT,XR,YB],_,[XFl,YFt,XFr,YFb],_,Ybord,_,_,H),
    Line is round((YFb-YFt)/H),
    Line<1-> Height is H;Height is Line*H,
    YBB is YT+Height+Ybord,
    panel_item_graf(field(name(N),place(XL,YT,XR,YBB),Ps..),Graf).
*/

panel_item_write(field(N,P,_,_,_,_,Ps..),V,
        field(N,P,pre(''),selection(V),post(''),top(0),Ps..),Graf):-
    symbol(V),  % new symbol value -> selected V, top is 0
    panel_item_graf(field(N,P,pre(''),selection(V),post(''),top(0),Ps..),Graf).


$fieldminsize(D,B,12):-D=<12-B.           % min size is 12 for grow box
$fieldminsize(D,B,ND):-D>12-B,ND is D+B.

$fieldval([pre(N1),selection(N2),post(N3),_..],Val):-swrite(Val,N1,N2,N3).

% -- conversion routines for previous object classes

% old field objects
$upgradeobj(field(Name,Place,V),New):-
    var(V),
    $upgradeobj(field(Name,Place,''),New).
$upgradeobj(field(Name,Place,input(V)),New):-
    $upgradeobj(field(Name,Place,V),New).
$upgradeobj(field(Name,Place,V),
        field(name(Name),place(Place..),pre(''),selection(V),post(''),top(0),
              font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\09'))):-
    symbol(V).
$upgradeobj(field(Name,Place,[[Pre,Selection,Post,Top],Font,Lock,Lines,Style,Menu]),
            field(name(Name),place(Place..),pre(Pre),selection(Selection),post(Post),top(Top),
                  Font,Lock,Lines,Style,Menu,exitset(enter,'\09'))).

$upgradeobj(field(name(Name),place(Place..),pre(Pre),selection(Selection),post(Post),top(Top),
                  Font,Lock,Lines,Style,Menu),
            field(name(Name),place(Place..),pre(Pre),selection(Selection),post(Post),top(Top),
                  Font,Lock,Lines,Style,Menu,exitset(enter,'\09'))).

