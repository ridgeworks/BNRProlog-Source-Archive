/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/button_editor.p,v 1.1 1997/03/14 17:09:25 harrisj Exp $
*
*  $Log: button_editor.p,v $
 * Revision 1.1  1997/03/14  17:09:25  harrisj
 * Moved files required by panels.a goal from panel_files to Panel_3.1.
 * Formally added Editing, Info, Interface to panel_files sub-project.
 * Added a makefile to panel_files subproject
 *
 * Revision 1.1  1995/09/22  11:23:00  harrisja
 * Initial version.
 *
*
*/

/*
 *   button_editor
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
/*
    Button Class as defined by 'button_class'

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
% -- other local predicates used:
%   $open_editor  in 'panel editor'
%   $close_editor in 'panel editor'
%   $selection_rename in 'panel editor'
%   $update_selected  in 'panel editor'
%   $update_font  in 'panel editor'
%   $update_font_size in 'panel editor'
%   $update_font_style in 'panel editor'
%   $openmenuitem in 'panel editor'
%   $replace      in 'panel editor'
%   $insert       in 'panel editor'
%%   $fieldval     in 'field_class'
%   $adjust       in 'list_class'
%   $member       in 'panel works'

% panel for editing button properties
panel_definition(edit_button,
    pos(30,49),
    size(459,299),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4)),
    field(name(size),place(160,112,212,132),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    button(name('Size:'),place(160,96,197,112),style(transparent),label('Size:'),state(nil),font(0,12),icon(0),menu()),
    field(name(font),place(15,112,140,132),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    field(name(label),place(59,65,203,85),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    field(name(name),place(215,7,330,27),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    button(name(ok),place(246,269,334,297),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    button(name(hilite),place(238,52,311,70),style('radio button'),label('No hilite'),state(off),font(0,12),icon(0),menu()),
    button(name(hilite),place(238,72,303,90),style('radio button'),label('Disable'),state(off),font(0,12),icon(0),menu()),
    button(name(hilite),place(238,32,324,50),style('radio button'),label('Auto hilite'),state(off),font(0,12),icon(0),menu()),
    list(name(menuitems),place(64,142,214,240),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    field(name(edititem),place(65,246,196,266),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    button(name('Add/Edit:'),place(1,248,67,264),style(transparent),label('Add/Edit:'),state(nil),font(0,12),icon(0),menu()),
    button(name(cancel),place(130,273,210,293),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name('Menu:'),place(15,142,61,158),style(transparent),label('Menu:'),state(nil),font(0,12),icon(0),menu()),
    button(name(icons),place(321,95,368,112),style('check box'),label('Icon'),state(off),font(0,12),icon(0),menu()),
    icon_list(name(icons),place(321,115,449,268),contents(2002,1000,1001,1002,1003,1004,1005,1006,1007,1008,1019,26884,18814,27056,15420,16560,6720,16692,3584,24317,29903,1014,1013,1012,29019,2730,30557,26865,9301,27009,2162,32488,2335,5472,766,902,26425,29114,4895,6724,21449,24830,17779,8419,7417,26020,15279,19381,22308,14953,6460,6179,3835,29484,9120,19162,1016,32650,1011,11045,20098,21700,20689,21847,1017,10610,30696,17481,3430,11645,4432,20965,17357,21209,8961,22855,4263,15972,20186,32670,26635,25002,32462,21060,2507,31685,1020,23078,19678,2478,14767,1018,1015,1009,8538,9761,7012),selection(0,0),top(1),style(rectangle)),
    button(name(condense),place(231,250,312,266),style('check box'),label('Condense'),state(off),font(0,12),icon(0),menu()),
    button(name(extend),place(231,228,294,244),style('check box'),label('Extend'),state(off),font(0,12),icon(0),menu()),
    button(name(shadow),place(231,206,300,222),style('check box'),label('Shadow'),state(off),font(0,12),icon(0),menu()),
    button(name(outline),place(231,184,295,200),style('check box'),label('Outline'),state(off),font(0,12),icon(0),menu()),
    button(name(underline),place(231,162,311,178),style('check box'),label('Underline'),state(off),font(0,12),icon(0),menu()),
    button(name(italic),place(231,140,284,156),style('check box'),label('Italic'),state(off),font(0,12),icon(0),menu()),
    button(name(bold),place(231,118,277,134),style('check box'),label('Bold'),state(off),font(0,12),icon(0),menu()),
    button(name('Font Style:'),place(229,95,305,111),style(transparent),label('Font Style:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Font:'),place(16,94,55,110),style(transparent),label('Font:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Label:'),place(12,68,57,84),style(transparent),label('Label:'),state(nil),font(0,12),icon(0),menu()),
    field(name(outline),place(102,36,202,56),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    button(name('Button Style:'),place(12,38,103,54),style(transparent),label('Button Style:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Button:'),place(161,9,215,25),style(transparent),label('Button:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Panel:'),place(13,9,59,25),style(transparent),label('Panel:'),state(nil),font(0,12),icon(0),menu()),
    field(name(panel),place(59,7,154,27),pre(''),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(rectangle),menu(),exitset(enter,'\t'))).

% open edit_button panel when selected button 'opened'

panel_event(Panel,edit,selected(SName,Sp,button(BPs..))):-
    findall(BS,[clause_head(panel_item_graf(button(_,_,style(BS),_..),_)),nonvar(BS)],Styles),
    $open_editor(edit_button,Panel,SName,button(BPs..),Styles).

% mapping button specific properties
$map_props([label(Label),Vs..],[field(label):=Label,Rest..]):-
    $map_props(Vs,Rest).

$map_props([icon(0),Vs..],[button(icons):=off,Rest..]):-      % icon property, none selected
    $map_props(Vs,Rest).

$map_props([icon(Id),Vs..],                                   % icon property, icon selected
           [button(icons):=on,icon_list(icons):=selection(_,Id),Rest..]):-
    Id\=0,
    $map_props(Vs,Rest).

$map_props([state(State),Vs..],                                 % state property to hilite
           [button(name(hilite),P,style('radio button'),label(Hilite),Etc..):=on,Rest..]):-
    $map_state(State,Hilite),
    $map_props(Vs,Rest).

$map_state(off,'Auto hilite').
$map_state(on,'Auto hilite').
$map_state(nil,'No hilite').
$map_state(disable,'Disable').

% edit dialog panel behaviour

panel_event(edit_button,update,field(name(name),_,Value..)):-
    $selection_rename(Value).

panel_event(edit_button,select,button(name(icons),_,_,_,state(off),_..)):-beep.
        % can't turn this check box on by clicking on it, must select an icon

panel_event(edit_button,update,button(name(icons),_,_,_,state(off),_..)):-
        % on turning it off, delete icon and remove selection
    $update_selected(icon(0)),       % label change
    panel_view(edit_button,icon_list(icons):=selection(0,0)).

panel_event(edit_button,update,icon_list(name(icons),P,C,selection(I,Id),Etc..)):-
    $update_selected(icon(Id)),
    panel_view(edit_button,button(icons):=on).   % turn check box on

panel_event(edit_button,update,field(name(label),_,Value..)):-
    $fieldvalue(Value,New),
    $update_selected(label(New)).

panel_event(edit_button,update,field(name(outline),_,Value..)):-
    $fieldvalue(Value,New),
    $update_selected(style(New)).

panel_event(edit_button,click,field(outline)).  % disable editing

panel_event(edit_button,update,button(name(hilite),_,_,label(Hilite),state(on),_..)):-
    $hilite(Hilite,Newstate),
    $update_selected(state(Newstate)).

panel_event(edit_button,update,field(name(font),_,Value..)):-
    $update_font(edit_button,Value).

panel_event(edit_button,click,field(font)).  % disable editing

panel_event(edit_button,update,field(name(size),_,Value..)):-
    $update_font_size(edit_button,Value).

panel_event(edit_button,update,button(name(Style),Ps..)):-
    $update_font_style(Style,Ps).

panel_event(edit_button,doubleclick,list(name(menuitems),Ps..)):-
    $member(selection(I,S),Ps),
    $openmenuitem(edit_button,selection(I,S)).

panel_event(edit_button,update,field(name(edititem),_,Value..)):-
    forget(edititem(S),$local),!,   % editing existing item
    $fieldvalue(Value,New),
    panel_view(edit_button,list(menuitems):contents(L..)),
    $replace(S,L,New,NewL),
    $update_selected(menu(NewL..)),
    panel_view(edit_button,list(menuitems):=[contents(NewL..),selection(S,_)],field(edititem):='').

panel_event(edit_button,update,field(name(edititem),_,Value..)):-
    $fieldvalue(Value,New),
    panel_view(edit_button,list(menuitems):[contents(L..),selection(I,_)]),   % insert in existing list
    New\=''->                   % ignore nil symbols
       [$insert(I,L,New,NewL),  % insert after current selection
        successor(I,NewI),      % bump selection to new item
        $update_selected(menu(NewL..)),   
        panel_view(edit_button,
                   list(menuitems):=[contents(NewL..),selection(NewI,_)],field(edititem):='')].

panel_event(edit_button,update,list(name(menuitems),P,contents(L..),Etc..)):-
    $update_selected(menu(L..)).    % update, e.g., dragging, track selected item to list

panel_event(edit_button,click,button(ok)):-
    panel_close(edit_button).    % quit editing button

panel_event(edit_button,click,button(cancel)):-
    recall(selected(Panel,name(Sn),Saved),$local),    % revert to original object
    panel_view(Panel,selected(Sn):=Saved),
    panel_close(edit_button).

panel_event(edit_button,close):-
    $close_editor(edit_button).
    
$hilite('Auto hilite',off).
$hilite('No hilite',nil).
$hilite('Disable',disable).


%  *** icon list class:  objects with a icon list pane and a scroll bar *****************
% this class for internal use by the button editor
% uses (heavily) general support for scrolling objects in list_class
% panel_item_class(icon_list). %-- this was in the file panel objects 
/* don't really need this until edit_button panel gets redesigned
    save space by commenting out.
panel_item_new(icon_list,
                 Name,
                 X, Y,
                 icon_list(name(Name),
                           place(X,Y,XL,YB),
                           contents(2002,1000,1001,1002,1003,1004,1005,1006,1007,1008,1019,26884,
                                18814,27056,15420,16560,6720,16692,3584,24317,29903,1014,1013,1012,
                                29019,2730,30557,26865,9301,27009,2162,32488,2335,5472,766,902,26425,
                                29114,4895,6724,21449,24830,17779,8419,7417,26020,15279,19381,22308,14953,
                                6460,6179,3835,29484,9120,19162,1016,32650,1011,11045,20098,21700,20689,
                                21847,1017,10610,30696,17481,3430,11645,4432,20965,17357,21209,8961,22855,4263,
                                15972,20186,32670,26635,25002,32462,21060,2507,31685,1020,23078,19678,2478,
                                14767,1018,1015,1009,8538,9761,7012)
                           selection(0,0),
                           top(1))  ) :-
    XL is X + 92,
    YB is Y + 112.
*/
% draw method
panel_item_graf(icon_list(Name,place(Place..),Contents,Selection,Top,Style,Etc..),
        [[backpat(white),backcolor(white),fillpat(hollow),rectabs(Place..),
          VSlider,
          fillpat(clear),rectabs(Clip..),
          Internals]]):-
    %$lcontainer(Style,Place,Cont,BP,BC),
    panel_scroll_item_info(icon_list(Name,place(Place..),Contents,Selection,Top,Style,Etc..),
            Clip,Span,Max),
    panel_scroll_vslider(Style,place(Place..),Top,Span,Max,nil,VSlider),
    $draw_iconlist(move,Clip,[Contents,Selection,Top,Style],Span,Internals).

% write methods
panel_item_write(icon_list(_..),icon_list(N,P,Contents,selection(I,S),Top,Etc..),
            icon_list(N,P,Contents,AdjSel,AdjTop,Etc..),Graf):-
    panel_scroll_item_adjust(icon_list(N,P,Contents,selection(I,S),Top,Etc..),AdjTop,AdjSel),
    panel_item_graf(icon_list(N,P,Contents,AdjSel,AdjTop,Etc..),Graf).

panel_item_write(icon_list(Name,Place,Contents,selection(I0,S0),top(Top),Style,Etc..),
                 selection(I,S),
                 icon_list(Name,Place,Contents,selection(I,S),top(Top),Style,Etc..),
                 [G1,G2]):-   % special case situation where only selection has changed
    panel_scroll_item_info(icon_list(Name,Place,Contents,selection(I0,S0),top(Top),Style,Etc..),Clip,Span,Max),
    $icon_list_spec(Clip,Top,Width,IconTop),
    $inverticon(Clip,IconTop,Width,I0,S0,Contents,G1),% turn off the old
    $inverticon(Clip,IconTop,Width,I,S,Contents,G2).  % turn on the new

panel_item_write(icon_list(Name,Place,Contents,Selection,Top,Style..),scroll(SType,Delta),
        icon_list(Name,Place,Contents,Selection,NewTop,Style..),
        [[VSlider,                      % scroll
          Internals]]):-
    panel_scroll_item(SType,icon_list(Name,Place,Contents,Selection,Top,Style..),Delta,
            NewTop,Clip,Span,VSlider),
    $draw_iconlist(SType,Clip,[Contents,Selection,NewTop,Style..],Span,Internals).

panel_item_write(icon_list(Name,Place,Contents,Selection,Top,Style,Etc..),
                 scroll(Type,up(X,Y)),
                 icon_list(Name,Place,Contents,Selection,Top,Style,Etc..),
                 [[VSlider]]):-   % $scroll_it failed, but mouse up so clear arrows if up or down
    once(Type=up;Type=down),
    panel_scroll_item_info(icon_list(Name,Place,Contents,Selection,Top,Style,Etc..),
            Clip,Span,Max),
    panel_scroll_vslider(Style,Place,Top,Span,Max,nil,VSlider).
    
panel_item_write(icon_list(Etc..),scroll(_,_),icon_list(Etc..),[]).  % can't scroll -> no change

% grow method
panel_item_grow(icon_list(_..),56,49). % slider width=16,slider height=top box+2+bottom box

% icon_list characteristics
panel_scroll_item_info(icon_list(Name,place(Xl,Yt,Xr,Yb),Contents,_,top(Top),Style,Etc..),
                [CXl,CYt,CXr,CYb],Span,Max):-
    %$cliprect(Style,place(Xl,Yt,Xr,Yb),Clip),
    CXr is Xr-16,successor(CYb,Yb),
    successor(Xl,CXl),successor(Yt,CYt),
    $icon_list_spec([CXl,CYt,CXr,CYb],Top,Width,IconTop),
    termlength(Contents,Length,_),
    Max is (Length + Width - 1) // Width,
    Span is (Yb-Yt-4)//36.

% additional icon list info, i.e., top,left icon and # of icons/row
$icon_list_spec([CXl,CYt,CXr,CYb],Top,Width,IconTop):-
    Width is (CXr-CXl-2)//36,
    IconTop is (Top - 1) * Width + 1.

% icon_list graphics
% toggle selection
$inverticon([XL,YT,XR,YB],Top,Width,I,S,List,[fillpat(invert),rectabs(XSL,YST,XSR,YSB)]):-
    arg(I,List,S),                  % selection in range..
    YST is YT+3+((I-Top)//Width)*36,
    YSB is YST+32,
    YSB=<YB,YST>=YT,
    XSL is XL+3+((I-Top) mod Width)*36,
    XSR is XSL+32,
    XSL>=XL.
$inverticon(_,_,_,0,0,_,[]).

% update list after scroll
$draw_iconlist(Stype,[CXl,CYt,CXr,CYb],[NT,Select,List],Span,
        [scrollrect(CXl,CYt,CXr,SYb,0,Scroll),Icons]):-
    [Stype=up,  Scroll=36,  LYt = CYt,             IX = NT];
    [Stype=down,Scroll= -36,LYt is CYt+(Span-1)*36,IX is NT+Span-1],
    !,
    LYb is LYt+36,
    SYb is CYt+Span*36,
    $setup_iconlist([CXl,LYt,CXr,LYb],[IX,I,Contents],Icons).

% normal draw
$draw_iconlist(Stype,[CXl,CYt,CXr,CYb],[Contents,selection(I,_),top(Top),Style..],_,
        [fillpat(clear),rectabs(CXl,CYt,CXr,CYb),Icons..]) :-
    $setup_iconlist([CXl,CYt,CXr,CYb],[Top,I,Contents],Icons).

$setup_iconlist([CXl,CYt,CXr,CYb],[Top,Select,List],Icons):-
    XC is CXl + 3,
    YC is CYt + 3,
    $icon_list_spec([CXl,CYt,CXr,CYb],Top,Width,IconTop),
    $draw_icons([IconTop,Select,List],[XC,YC,CXr,CYb],[XC,YC],Icons).

% -- Drawing the Icons ---------------------------------
$draw_icons([Top,Select,List],[XL,YT,XR,YB],[XC,YC],[IGraf, Icons..]) :-
    XX is XC + 36,
    XX =< XR,
    !,
    once($icongraf([Top,Select,List],[XC,YC,XN,YN],IGraf)),
    XN is XC + 32,
    YN is YC + 32,
    successor(Top,Next),
    $draw_icons([Next,Select,List],[XL,YT,XR,YB],[XX,YC],Icons).

$draw_icons(V,[XL,YT,XR,YB],[XC,YC],Icons) :-         % down one line
    YY is YC + 36,
    YY < YB - 34,
    !,
    $draw_icons(V,[XL,YT,XR,YB],[XL,YY],Icons).

$draw_icons(_,[XL,YT,XR,YB],[XC,YC],[fillpat(clear),rectabs(XL,YY,XR,YBB)]):-
    YY is YC+33,    % no room, clear rest of space, and quit
    YBB is YB-2,    % line for hollow rectangle inside boundary
    YY=<YBB.

$draw_icons(_,_,_,[]).    % as above but no space left to clear

$icongraf([Select,Select,List],[XC,YC,XN,YN],
        [iconabs(XC,YC,XN,YN,Icon),fillpat(invert),rectabs(XC,YC,XN,YN)]):-
    arg(Select,List,Icon).               %selected entry=inverted icon

$icongraf([Index,_,List],[XC,YC,XN,YN],iconabs(XC,YC,XN,YN,Icon)):-
    arg(Index,List,Icon).                %unselected entry=icon

$icongraf(_,[XC,YC,XN,YN],[fillpat(clear),rectabs(XC,YC,XN,YN)]).   % else clear


%  ------ icon_list specific event handler  ----------------------------------

panel_event(Panel, select(X,Y), icon_list(Ps..)):-
    panel_scroll_item_info(icon_list(Ps..),[CXl,CYt,CXr,CYb],Span,Max),
    X < CXr,X>CXl,                % new item selection
    Ps=[Name,Place,Contents,selection(I,S),top(Top),Etc..],
    $icon_list_spec([CXl,CYt,CXr,CYb],Top,Width,IconTop),
    Dy is (Y-CYt-1)//36,Dy=<Span-1,
    Dx is (X-CXl-1)//36,Dx=<Width-1,
    NSel is (Top+Dy-1)*Width+Dx+1,
    termlength(Contents,MaxSel,_),
    [NSel=<MaxSel,NSel\=I]->
       [arg(NSel,Contents,Sel),
        panel_view(Panel,icon_list(Ps..):=selection(NSel,Sel)),
        dispatch_panel_event(Panel,update(selection(I,S)),
                             icon_list(Name,Place,Contents,selection(Nsel,Sel),top(Top),Etc..))].
 
/*
% -- conversion routine for previous icon_lists

$upgradeobj(icon_list(Name,Place,[T,S,[L..]]),Item):-
    $upgradeobj(icon_list(Name,Place,[[T,S,[L..]],style(rectangle)]),Item).

$upgradeobj(icon_list(Name,Place,[[T,S,[L..]],style(rectangle)]),
            icon_list(name(Name),place(Place..),contents(L..),selection(S,Sel),top(T),style(rectangle))):-
    once(arg(S,L,Sel);Sel='').
*/
