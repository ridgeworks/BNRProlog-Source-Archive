/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/button_class.p,v 1.1 1995/09/22 11:22:56 harrisja Exp $
*
*  $Log: button_class.p,v $
 * Revision 1.1  1995/09/22  11:22:56  harrisja
 * Initial version.
 *
*
*/

/*
 *   button_class
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
/*
    Button Class

    Object Form:
        button(name(Name),      % a symbol identifying the button in a panel
               place(Place..),  % a list of 4 integers defining a rectangle
               style(Style),    % one of standard, designate, transparent, rectangle,
                                %   shadow, 'radio button', 'check box', motif,
                                %   'motif radio button', 'motif check box'  
               label(Label),    % a symbol, may be used to distinguish radio buttons
               state(State),    % 'on','off', 'nil' (used to disable hilighting),
                                %   or 'disable' (no hilighting, grayed appearance) 
               font(F,S,St..),  % font name, size and style specification
               icon(Id),        % icon Id, 0 indicates none
               menu(Ms..)       % menu associated with a button (not implemented)
              )                 % end of value specification
*/

 
% *** button ***   Animation...

panel_event(Panel,select(_..),button(N,P,Style,L,State,Etc..)):-
    $check(Style,State,Flip),!,
    panel_view(Panel,button(N,P,Style,L,_..):=Flip),
    dispatch_panel_event(Panel,update(L,State),button(N,P,Style,L,state(Flip),Etc..)).

panel_event(Panel,select,button(N,P,Style,L,state(on),Etc..)):-
            % select on radio buttons already on is noop
    $radio(Style),!.

panel_event(Panel,select(_..),button(N,P,Style,L,state(off),Etc..)):-
    $radio(Style),!,
    panel_view(Panel,button(N,_,Style,OL,state(on),_..):=off,  % turn old off
                     button(N,P,Style,L,state(off),Etc..):=on),% and new on
    dispatch_panel_event(Panel,update(OL,on),button(N,P,Style,L,state(on),Etc..)).

panel_event(Panel,select(_..),button(N,P,Style,L,state(off),Font,Icon,menu(M,Ms..),Etc..)):-
    panel_view(Panel,button(N,P,Style,L,_..):=on),
    $button_menu(Panel,button(N,P,Style,L,state(on),Font,Icon,menu(M,Ms..),Etc..)),
    panel_view(Panel,button(N,P,Style,L,_..):=off).
    
panel_event(Panel,select(_..),button(N,P,Style,L,state(nil),Font,Icon,menu(M,Ms..),Etc..)):-
    $button_menu(Panel,button(N,P,Style,L,state(nil),Font,Icon,menu(M,Ms..),Etc..)).
    
panel_event(Panel,select(_..),button(N,P,Style,L,state(off),Etc..)):-
    panel_view(Panel,button(N,P,Style,L,state(off),Etc..):=on).

panel_event(Panel,unselect(_..),button(_,_,Style,_..)):-
    $stickon(Style).

panel_event(Panel,unselect(_..),button(N,P,Style,L,state(on),Etc..)):-
    not($stickon(Style)),
    panel_view(Panel,button(N,P,Style,L,_..):=off).

% return/enter key is click on (first) designate button
panel_event(Panel,keystroke(Return,_),_):-
    once(Return='\0D';Return=enter),
    panel_view(Panel,button(N,P,style(designate),Etc..)),
    nonvar(N),  % need to test because panel_view never fails
    $clickon(Panel,button(N,P,style(designate),Etc..)).

% other non command/control/option keys apply to buttons if they are not 
%    'check box' or 'radio button' and the key corresponds to the first letter 
%    of the button label.
panel_event(Panel,keystroke(Char,[0,0,Capslock,Shift,0,1]),_):-
    panel_view(Panel,button(N,P,S,label(Label),Etc..)), % generate the buttons
    not($stickon(S)),
    substring(Label,1,1,L),
    lowercase(Char,C),
    lowercase(L,C),
    cut,
    $clickon(Panel,button(N,P,S,label(Label),Etc..)).

$clickon(Panel,button(N,Place,S,L,State,Etc..)):-
    State=state(off)->
       [panel_view(Panel,button(N,Place,_..):=on),    % for the visuals
        panel_view(Panel,button(N,Place,_..):=off)],
    Place=place(Xl,Yt,_..),
    dispatch_panel_event(Panel,click(Xl,Yt),button(N,Place,S,L,State,Etc..)).  % generate a click
 
% button menus..
$button_menu(Panel,Button):-
    Button=button(N,place(Xl,Yt,Xr,Yb),Style,L,S,Font,Icon,menu(Ms..),Etc..),
    successor(Xl,PX),
    panel_menu(Panel,[Ms..],1,PX,Yb,New)->dispatch_panel_event(Panel,menu(New),Button).

% these are the styles that stick on
$stickon(Style):-$check(Style,_..),!.   % green cut                                                                            
$stickon(Style):-$radio(Style).                                                                             

% checkbox styles
$check(style('check box'),Old,New):-$toggle(Old,New).
$check(style('motif check box'),Old,New):-$toggle(Old,New).

% radio button styles
$radio(style('radio button')).                                                                             
$radio(style('motif radio button')). 

% toggle states
$toggle(state(on),off).
$toggle(state(off),on).

                                                                            
% *** button ***  Graphics...

panel_item_class(button).

panel_item_new(button,Name,X1,Y1,
               button(name(Name),place(X1,Y1,X2,Y2),style(standard),label(Name),
                      state(off),font(0,12),icon(0),menu())):-
    $buttontext_size(Name,font(0,12),Length,Height,_),
    Length < 80 -> X2 is X1+80; X2 is X1+Length+10,
    Y2 is Y1+Height+4.

% --- standard
panel_item_graf(button(name(Name),place(X1,Y1,X2,Y2),style(standard),Label,State,Font,Icon,_..),
        [[backpat(white),backcolor(white),Logo,Pat, 
          fillpat(hollow), rrectabs(X1,Y1,X2,Y2,9,9)]]):-
    $center_text(Label,Font,Icon,rrectabs(X1,Y1,X2,Y2,9,9),Logo),
    $button_pat(State,rrectabs(X1,Y1,X2,Y2,9,9),Pat).

panel_item_write(button(Name,place(Place..),style(standard),Label,Old,Etc..),New,
                 button(Name,place(Place..),style(standard),Label,state(New),Etc..),
                 [[fillpat(invert), rrectabs(X1,Y1,X2,Y2,9,9)]]):-
    $toggle(Old,New),
    panel_expand_rect(Place,-2,-2,[X1,Y1,X2,Y2]).

% --- designate
panel_item_graf(button(Name,place(X1,Y1,X2,Y2),style(designate),Label,State,Font,Icon,_..),
        [[backpat(white),backcolor(white),
          Logo,
          [fillpat(hollow),pensize(3,3),rrectabs(X1,Y1,X2,Y2,16,16)],
          Pat,
          fillpat(hollow),rrectabs(X3,Y3,X4,Y4,9,9)]]):-
    $center_text(Label,Font,Icon,rrectabs(X1,Y1,X2,Y2,16,16),Logo),
    $coresize(designate,[X1,Y1,X2,Y2],[X3,Y3,X4,Y4]),
    $button_pat(State,rrectabs(X1,Y1,X2,Y2,16,16),Pat).

panel_item_write(button(Name,place(Place..),style(designate),Label,Old,Etc..),New,
                 button(Name,place(Place..),style(designate),Label,state(New),Etc..),
                [[fillpat(invert), rrectabs(X1,Y1,X2,Y2,9,9)]]):-
    $toggle(Old,New),
    $coresize(designate,Place,Core),
    panel_expand_rect(Core,-1,-1,[X1,Y1,X2,Y2]).

$min_size(designate,Label,Font,Icon,W,H):-
    $min_size(Label,Font,Icon,W1,H1),
    W is W1+8, H is H1+8.

$coresize(designate,Place,Core):-
    panel_expand_rect(Place,-4,-4,Core).

$bordersize(designate,Core,Place):-
    panel_expand_rect(Core,4,4,Place).

% --- rectangle
panel_item_graf(button(Name,place(Place..),style(rectangle),Label,State,Font,Icon,_..),
        [[backpat(white),backcolor(white),Logo,Pat,
          fillpat(hollow), rectabs(Place..)]]):-
    $center_text(Label,Font,Icon,rectabs(Place..),Logo),
    $button_pat(State,rectabs(Place..),Pat).

% --- opaque
panel_item_graf(button(Name,place(Place..),style(opaque),Label,State,Font,Icon,_..),
        [[backpat(white),backcolor(white),Logo,Pat]]):-
    $center_text(Label,Font,Icon,rectabs(Place..),Logo),
    $button_pat(State,rectabs(Place..),Pat).

% --- transparent
panel_item_graf(button(Name,place(Place..),style(transparent),Label,State,Font,Icon,_..),
        [[Logo,Pat]]):-
    $center_text(Label,Font,Icon,none(Place..),Logo),
    $button_pat(State,rectabs(Place..),Pat).

% --- shadow
panel_item_graf(button(Name,place(X1,Y1,X2,Y2),style(shadow),Label,State,Font,Icon,_..),
        [[backpat(white),backcolor(white),Logo,Pat,
          fillpat(hollow),rectabs(X1,Y1,X3,Y3),
          angle(0),moveabs(X6,Y3),line(Xd),angle(270),line(Yd)]]):-
    X3 is X2-1, Y3 is Y2-1, 
    $center_text(Label,Font,Icon,rectabs(X1,Y1,X3,Y3),Logo),
    $button_pat(State,rectabs(X1,Y1,X3,Y3),Pat),
    X6 is X1+3,
    Xd is X2-X1-4, Yd is Y2-Y1-3.

panel_item_write(button(Name,place(Place..),style(shadow),Label,Old,Etc..),New,
                 button(Name,place(Place..),style(shadow),Label,state(New),Etc..),
                 [[fillpat(invert),rectabs(Xl,Yt,Xr,Yb)]]):-
    $toggle(Old,New),
    panel_expand_rect(Place,-2,-2,[Xl,Yt,R,B]),
    successor(Xr,R),successor(Yb,B).

$min_size(shadow,Label,Font,Icon,W,H):-
    $min_size(Label,Font,Icon,W1,H1),
    W is W1+1, H is H1+1.

$coresize(shadow,[Xl,Yt,Xr,Yb],[Xl,Yt,XCr,YCb]):-
    successor(XCr,Xr),successor(YCb,Yb).

$bordersize(shadow,[Xl,Yt,XCr,YCb],[Xl,Yt,Xr,Yb]):-
    successor(XCr,Xr),successor(YCb,Yb).

% --- radio 
panel_item_graf(button(Name,place(Place..),style('radio button'),Label,state(State),Font,Icon,_..),
            [[Logo,Pat,Dot]]):-
    $center_left(Place,16,Right,X1,Y0),
    $center_text(Label,Font,Icon,none(Right..),Logo),
    $button_pat(State,rectabs(Right..),Pat),
    $circle_dot(State,Place,Dot..).

panel_item_write(button(Name,place(Place..),style('radio button'),Label,Old,Etc..),New,
                 button(Name,place(Place..),style('radio button'),Label,state(New),Etc..),[Graf]):-
    $toggle(Old,New),
    $circle_dot(New,Place,Graf..).

$circle_dot(on,[X1,Y1,X2,Y2],
       backpat(white),backcolor(white),fillpat(clear),
       circleabs(XC,YC,6),fillpat(hollow),circleabs(XC,YC,6),
       fillpat(pentype),circleabs(XC,YC,3)):-
    !,XC is X1+6, YC is (Y1+Y2)//2.

$circle_dot(_,[X1,Y1,X2,Y2],
       backpat(white),backcolor(white),fillpat(clear),
       circleabs(XC,YC,6),fillpat(hollow),circleabs(XC,YC,6)):-
    XC is X1+6, YC is (Y1+Y2)//2.

$min_size(Style,Label,Font,Icon,W,H):-  % for all radio buttons and check boxes
    $stickon(style(Style)), 
    $min_size(Label,Font,Icon,W1,H1), 
    W is W1+16,H is H1+2.

% --- check_box
panel_item_graf(button(Name,place(Place..),style('check box'),Label,State,Font,Icon,_..),
                [[Logo,Pat,
                  fillpat(hollow), rectabs(X1,Y1,X2,Y2),
                  Check..]]):-
    $center_left(Place,16,Right,X1,Y0),
    $center_text(Label,Font,Icon,none(Right..),Logo),
    $button_pat(State,rectabs(Right..),Pat),
    X2 is X1+12, Y1 is Y0-6, Y2 is Y0+6,
    $cross_check(State,[X1,Y1,X2,Y2],Check..).

panel_item_write(button(Name,place(Place..),style('check box'),Label,Old,Etc..),New,
                 button(Name,place(Place..),style('check box'),Label,state(New),Etc..),[Check]):-
    $toggle(Old,New),
    $center_left(Place,16,Right,X1,Y0),
    X2 is X1+12, Y1 is Y0-6, Y2 is Y0+6,
    $cross_check(state(New),[X1,Y1,X2,Y2],Check..).

$cross_check(state(on),[X1,Y1,X2,Y2],
        backpat(white),backcolor(white),fillpat(clear),rectabs(XL,YT,XR,YB),fillpat(pentype),
        moveabs(XL,YT),lineabs(XR2,YB2),moveabs(XR2,YT),lineabs(XL,YB2)):-
    !,successor(X1,XL),successor(Y1,YT),
    successor(XR,X2),successor(YB,Y2),
    successor(XR2,XR),successor(YB2,YB).

$cross_check(_,[X1,Y1,X2,Y2],
        backpat(white),backcolor(white),fillpat(clear),rectabs(XL,YT,XR,YB)):-
    successor(X1,XL),successor(Y1,YT),
    successor(XR,X2),successor(YB,Y2).

% --- motif
panel_item_graf(button(Name,place(Place..),style(motif),Label,State,Font,Icon,_..),
        [[backpat(white),backcolor(BC),Logo,Pat,Graf]]):-
    $motif_fill(State,UL,LR,_,BC),
    $motif_button(Place,white,black,Graf),
    $coresize(motif,Place,[XFl,YFt,XFr,YFb]),
    $center_text(Label,Font,Icon,rectabs(XFl,YFt,XFr,YFb),Logo),
    $button_pat(State,rectabs(XFl,YFt,XFr,YFb),Pat).
    
panel_item_write(button(Name,place(Place..),style(motif),Label,Old,Etc..),New,
                 button(Name,place(Place..),style(motif),Label,state(New),Etc..),
                 [Graf]):-
    $toggle(Old,New),
    $motif_fill(state(New),UL,LR,_..),
    $motif_button(Place,UL,LR,Graf).

$min_size(motif,Label,Font,Icon,W,H):-
    $min_size(Label,Font,Icon,W1,H1),
    W is W1+4, H is H1+4.

$motif_fill(state(on),black,white,dimgray,BC):-!,$motif_colour(BC).
$motif_fill(_,white,black,lightgray,BC):-$motif_colour(BC).

$motif_button([Xl,Yt,Xr,Yb],ULcol,LRcol,
        [fillpat(pentype),backcolor(white),
         penpat(ULcol),moveabs(Xl,Yt),
         polygon(lineabs(Xr,Yt,XFr,YFt,XFl,YFt,XFl,YFb,Xl,Yb,Xl,Yt)),
         penpat(LRcol),moveabs(Xr,Yb),
         polygon(lineabs(Xl,Yb,XFl,YFb,XFr,YFb,XFr,YFt,Xr,Yt,Xr,Yb)),
         penpat(black),fillpat(hollow),rectabs(Xl,Yt,Xr,Yb)]):-
    $coresize(motif,[Xl,Yt,Xr,Yb],[XFl,YFt,XFr,YFb]).

$coresize(motif,Place,Core):-
    panel_expand_rect(Place,-3,-3,Core).

$bordersize(motif,Core,Place):-
    panel_expand_rect(Core,3,3,Place).

% --- motif radio 
panel_item_graf(button(Name,place(Place..),style('motif radio button'),Label,State,Font,Icon,_..),
        [[Logo,Pat,Dot]]):-
    $center_left(Place,16,Right,X1,Y0),
    $center_text(Label,Font,Icon,none(Right..),Logo),
    $button_pat(State,rectabs(Right..),Pat),
    $motif_fill(State,UL,LR,HL,MC),
    $motif_diamond(Place,UL,LR,HL,MC,Dot).

panel_item_write(button(Name,place(Place..),style('motif radio button'),Label,Old,Etc..),New,
                 button(Name,place(Place..),style('motif radio button'),Label,state(New),Etc..),[Graf]):-
    $toggle(Old,New),
    $motif_fill(state(New),UL,LR,HL,MC),
    $motif_diamond(Place,UL,LR,HL,MC,Graf).

$motif_diamond([Xl,YT,_,YB],UL,BR,HL,MC,
        [backpat(white),backcolor(MC),fillpat(clear),
        moveabs(Xr,YM),polygon(lineabs(XM,Yt,Xl,YM,XM,Yb,Xr,YM)),
	fillpat(hollow),
        polygon(lineabs(XM,Yt,Xl,YM,XM,Yb,Xr,YM)),
        fillpat(pentype),
        forecolor(HL),
        moveabs(Xil,YM),polygon(lineabs(XM,Yit,Xir,YM,XM,Yib)),
        forecolor(UL),
        moveabs(XM1,Yt),polygon(lineabs(XM1,Yit,Xil,YM1,Xl,YM1)),
        forecolor(BR),
        moveabs(XM,Yb),polygon(lineabs(XM,Yib,Xir,YM,Xr,YM))]):-
    Xr is Xl+16,
    XM is (Xl+Xr)//2,XM1 is XM+1, %%%successor(XM,XM1),
    YM is (YT+YB)//2,YM1 is YM+1, %%%successor(YM,YM1),
    Yt is YM-8,Yt1 is Yt+1,
    Yb is YM+8,
    panel_expand_rect([Xl,Yt1,Xr,Yb],-3,-3,[Xil,Yit,Xir,Yib]).

% --- motif check_box
panel_item_graf(button(Name,place(Place..),style('motif check box'),Label,State,Font,Icon,_..),
        [[Logo,Pat,backpat(white),backcolor(HL),fillpat(clear),rectabs(X1,Y1,X2,Y2),Check..]]):-
    $center_left(Place,16,Right,X1,Y0),
    $center_text(Label,Font,Icon,none(Right..),Logo),
    $button_pat(State,rectabs(Right..),Pat),
    X2 is X1+12, Y1 is Y0-6, Y2 is Y0+6,
    $motif_fill(State,UL,LR,HL,MC),
    $motif_button([X1,Y1,X2,Y2],UL,LR,Check..).

panel_item_write(button(Name,place(Place..),style('motif check box'),Label,Old,Etc..),New,
                 button(Name,place(Place..),style('motif check box'),Label,state(New),Etc..),
                [[backpat(white),backcolor(HL),fillpat(clear),rectabs(X1,Y1,X2,Y2),Check..]]):-
    $toggle(Old,New),
    $center_left(Place,16,Right,X1,Y0),
    X2 is X1+12, Y1 is Y0-6, Y2 is Y0+6,
    $motif_fill(state(New),UL,LR,HL,MC),
    $motif_button([X1,Y1,X2,Y2],UL,LR,Check..).


% *** Standard Defaults...

panel_item_read(button(N,P,_,_,state(State),_..),State).     % read request is state

panel_item_write(button(Etc..),state(State),Newitem,Graf):-  % state property is special case
    panel_item_write(button(Etc..),State,Newitem,Graf).

panel_item_write(button(Name,place(Place..),Style,Label,Old,Etc..),New,
                 button(Name,place(Place..),Style,Label,state(New),Etc..),
                 [[fillpat(invert),rectabs(Box..)]]):-
    $toggle(Old,New),
    panel_expand_rect(Place,-2,-2,Box).

panel_item_write(button(Name,place(Place..),Style,Label,state(State),Etc..),State,
                 button(Name,place(Place..),Style,Label,state(State),Etc..),
                 []).    % writing the same state

panel_item_write(button(Name,Place,Style,Label,State,Font,Icon,menu(_..),Etc..),
                 menu(Ms..),
                 button(Name,Place,Style,Label,State,Font,Icon,menu(Ms..),Etc..),
                 []).    % changing menu only, no difference in appearance

panel_item_write(button(Name,Place,Style,Label,_,Etc..),State,
                 button(Name,Place,Style,Label,state(State),Etc..),
                 Graf):-
    $button_state(State),
    panel_item_graf(button(Name,Place,Style,Label,state(State),Etc..),Graf).

panel_item_write(button(Name,place(P..),style(S0),_..),
                 button(Name,place(Xl,Yt,Xr,Yb),style(S1),Ps..),
                 button(Name,place(Xl,Yt,NXr,NYb),style(S1),Ps..),
                 [Clear,Graf]):-
    Ps=[Label,State,Font,Icon,Menu..],
    S0\=S1->Clear=[fillpat(clear),rectabs(P..)],
    $min_size(S1,Label,Font,Icon,W,H),
    $check_size(Xl,Xr,W,NXr),
    $check_size(Yt,Yb,H,NYb),
    panel_item_graf(button(Name,place(Xl,Yt,NXr,NYb),style(S1),Ps..),Graf).

$check_size(L,U,Min,U):-(U-L)>=Min,!.
$check_size(L,U,Min,NU):-NU is L+Min.

$button_state(on).
$button_state(off).
$button_state(nil).
$button_state(disable).

$coresize(_,Place,Place).

$bordersize(_,Place,Place).

$min_size(Style,Label,Font,Icon,W,H):- 
    $min_size(Label,Font,Icon,W,H).

panel_item_grow(button(_,_,style(Style),Label,_,Font,Icon,_..),X,Y):-
    $min_size(Style,Label,Font,Icon,X,Y).


% *** Label text and/or icon...

$center_text(label(''),_,icon(0),Desc(X1,Y1,X2,Y2,Etc..),[fillpat(clear),Desc(X1,Y1,X2,Y2,Etc..)]).
    % no label or icon

$center_text(label(Label),font(Font,Size,St..),icon(0),Desc(X1,Y1,X2,Y2,Etc..),Graf):- % no icon
	   $buttontext_size(Label,font(Font,Size,St..),W,H,A),
	   $centre_place(X1,X2,W,X3,X4),   %X3 is (X1+X2-W)//2, X4 is X3+W,
	   $centre_place(Y1,Y2,H,Y3,Y4),   %Y3 is (Y1+Y2-H)//2, Y4 is Y3+H,
    Y5 is Y3+A,  
    Graf = [fillpat(clear),Desc(X1,Y1,X2,Y2,Etc..),
            textfont(Font),textsize(Size),textface(St..),
            textmode(or),textabs(X3,Y5,Label)].

$center_text(label(''),Font,icon(Icon),Desc(X1,Y1,X2,Y2,Etc..),Graf):-    % no label
    Icon\=0,
	   $centre_place(X1,X2,32,X3,X4),   %X3 is (X1+X2-32)//2, X4 is X3+32,
	   $centre_place(Y1,Y2,32,Y3,Y4),   %Y3 is (Y1+Y2-32)//2, Y4 is Y3+32,
    Graf = [fillpat(clear),Desc(X1,Y1,X2,Y2,Etc..),
            iconabs(X3,Y3,X4,Y4,Icon)].

$center_text(label(Label),font(Font,Size,St..),icon(Icon),Desc(X1,Y1,X2,Y2,Etc..),Graf):-
	   $buttontext_size(Label,font(Font,Size,St..),W,H,A),
	   $centre_place(X1,X2,32,X3,X4),   %X3 is (X1+X2-32)//2, X4 is X3+32,
	   $centre_place(Y1,Y2-H,32,Y3,Y4), %Y3 is (Y1+Y2-32-H)//2, Y4 is Y3+32,
    $centre_place(X1,X2,W,X5,X6),    %X5 is (X1+X2-W)//2, X6 is X5+W,
    Y5 is Y4+A,  
    Graf = [fillpat(clear),Desc(X1,Y1,X2,Y2,Etc..),
            penmode(or),iconabs(X3,Y3,X4,Y4,Icon),
            textfont(Font),textsize(Size),textface(St..),
            textmode(or),textabs(X5,Y5,Label)].

% optimization; do it all at once
% Note, for some styles, text width returns lower value than drawn,
%   but this isn't the place to fix it. 
$buttontext_size(Text,font(Font,Size,St..),L,Height,Ascent):-
    iswindow(W,graf,_), % W is any graf window
    $textwidth(W,Text,font(Font,Size,St..),L),
    isfont(Font,Size,_,[Ascent,Descent,Leading,_],face(St..)),!,
    Height is Ascent+Descent.  % minimum height is font height


$center_left([X1,Y1,X2,Y2],W,[X3,Y1,X2,Y2],X1,Y3):-
    X3 is X1+W,
    Y3 is (Y2+Y1)//2.   

$centre_place(V1,V2,Span,V3,V4):-
    V3 is (V1+V2-Span)//2,
    V4 is V3+Span. 
    
% pattern for disabled buttons
$button_pat(state(disable),Desc,[penpat(gray),penmode(notclear),Desc]):-!.
$button_pat(_,_,_).


%  Utilities

$min_size(label(''),Font,icon(0),12,12).

$min_size(label(''),Font,icon(Icon),36,36):-Icon>0. % size of icon +4 for inversion pattern

$min_size(label(Label),Font,icon(0),W,H):-
    $buttontext_size(Label,Font,W1,H1,_),
    W1 > 12 -> W=W1; W=12,
    H1 > 12 -> H=H1; H=12.

$min_size(label(Label),Font,icon(Icon),W,H):-
    Icon>0,
	$buttontext_size(Label,Font,W1,H1,_),
    W1 > 36 -> W=W1; W=36,
    H is H1+36.

% -- conversion routines for previous object classes..

% text objects
$upgradeobj(text(Name,Place,V),New):-var(V),$upgradeobj(text(Name,Place,Name),New).
$upgradeobj(text(Name,Place,V),New):-
    $upgradeobj(button(Name,Place,[transparent,V,nil,font(0,12),icon(0),menu()]),New).

% old button objects
$upgradeobj(button(Name,Place,V),New):-
    var(V),
    $upgradeobj(button(Name,Place,[Name,off]),New).
$upgradeobj(button(Name,Place,V),New):-
    symbol(V),
    $upgradeobj(button(Name,Place,[V,off]),New).
$upgradeobj(button(Name,Place,[Label,State]),New):-
    var(Label)->Label=Name,
    $upgradeobj(button(Name,Place,[standard,Label,State,font(0,12),icon(0),menu()]),New).
$upgradeobj(button(Name,Place,[Style,Label,State,Font,Icon,Menu]),
            button(name(Name),place(Place..),style(Style),label(Label),state(State),Font,Icon,Menu)).


% popup objects
$upgradeobj(popup(Name,Place,[S,L]),New):-
    var(L)->L=[],
    $upgradeobj(button(Name,Place,[shadow,Name,nil,font(0,12),icon(0),menu(L..)]),New).

% check_box objects
$upgradeobj(check_box(Name,Place,State),New):-
    $upgradeobj(button(Name,Place,['check box',Name,State,font(0,12),icon(0),menu()]),New).

% icon objects
$upgradeobj(icon(Name,Place,Id),New):-
    integer(Id),
    $upgradeobj(icon(Name,Place,[Id,off]),New).
$upgradeobj(icon(Name,Place,[Id,State]),New):-
    $upgradeobj(button(Name,Place,[transparent,'',state(State),font(0,12),icon(Id),menu()]),New).
