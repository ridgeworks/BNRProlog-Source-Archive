/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/field_editor.p,v 1.1 1997/03/14 17:09:27 harrisj Exp $
*
*  $Log: field_editor.p,v $
 * Revision 1.1  1997/03/14  17:09:27  harrisj
 * Moved files required by panels.a goal from panel_files to Panel_3.1.
 * Formally added Editing, Info, Interface to panel_files sub-project.
 * Added a makefile to panel_files subproject
 *
 * Revision 1.1  1995/09/22  11:24:18  harrisja
 * Initial version.
 *
*
*/

/*
 *   field_editor
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
/*
    Field Class as defined in 'field_class'

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
%   $fieldvalue   in 'panel_editor'
%%   $fcontainer   in 'field_class'
%   $member       in 'panel works'

% panel for editing field properties
panel_definition(edit_field,
    pos(276,47),
    size(349,347),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(off),grid(4,4)),
    button(name(lines),place(216,84,314,102),style('check box'),label('Show Lines'),state(off),font(0,12),icon(0),menu()),
    button(name(lock),place(216,68,303,86),style('check box'),label('Lock Text'),state(off),font(0,12),icon(0),menu()),
    button(name('Tab'),place(92,96,132,116),style('check box'),label('Tab'),state(off),font(0,12),icon(0),menu()),
    button(name('Esc'),place(92,112,132,132),style('check box'),label('Esc'),state(off),font(0,12),icon(0),menu()),
    button(name('Return'),place(92,80,156,100),style('check box'),label('Return'),state(off),font(0,12),icon(0),menu()),
    button(name('Enter'),place(92,64,148,84),style('check box'),label('Enter'),state(off),font(0,12),icon(0),menu()),
    button(name(label),place(16,64,88,84),style(transparent),label('Exit Chars:'),state(nil),font(0,12),icon(0),menu()),
    button(name(condense),place(252,268,333,286),style('check box'),label('Condense'),state(off),font(0,12),icon(0),menu()),
    button(name(extend),place(252,248,315,266),style('check box'),label('Extend'),state(off),font(0,12),icon(0),menu()),
    button(name(shadow),place(252,228,321,246),style('check box'),label('Shadow'),state(off),font(0,12),icon(0),menu()),
    button(name(outline),place(252,208,316,226),style('check box'),label('Outline'),state(off),font(0,12),icon(0),menu()),
    button(name(bold),place(252,148,298,166),style('check box'),label('Bold'),state(off),font(0,12),icon(0),menu()),
    button(name(underline),place(252,188,332,206),style('check box'),label('Underline'),state(off),font(0,12),icon(0),menu()),
    button(name(italic),place(252,168,305,186),style('check box'),label('Italic'),state(off),font(0,12),icon(0),menu()),
    field(name(outline),place(89,38,211,58),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    button(name('OK'),place(180,312,268,340),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    button(name('Add/Edit:'),place(0,288,66,304),style(transparent),label('Add/Edit:'),state(nil),font(0,12),icon(0),menu()),
    field(name(edititem),place(68,288,208,308),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    list(name(menuitems),place(68,180,224,278),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    button(name(cancel),place(76,316,156,336),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name('Menu:'),place(16,180,62,196),style(transparent),label('Menu:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Font Style:'),place(248,128,324,144),style(transparent),label('Font Style:'),state(nil),font(0,12),icon(0),menu()),
    field(name(size),place(168,148,223,168),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu('12'),exitset(enter,'\t','\r','\1B')),
    button(name('Size:'),place(176,128,213,144),style(transparent),label('Size:'),state(nil),font(0,12),icon(0),menu()),
    field(name(font),place(16,148,139,168),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu('New York','Venice','Athens','Cairo','London','Los Angeles','Mobile','San Francisco','Symbol','Avant Garde','Bookman','N Helvetica Narrow','New Century Schlbk','Palatino','Zapf Chancery','Zapf Dingbats','Chicago','Geneva','Monaco','Courier','Helvetica','Times'),exitset(enter,'\t')),
    button(name('Font:'),place(16,128,55,144),style(transparent),label('Font:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Field Style:'),place(12,40,90,56),style(transparent),label('Field Style:'),state(nil),font(0,12),icon(0),menu()),
    field(name(panel),place(57,8,151,28),pre(''),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    button(name('Panel:'),place(12,10,58,26),style(transparent),label('Panel:'),state(nil),font(0,12),icon(0),menu()),
    field(name(name),place(204,8,322,28),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    button(name('Field:'),place(163,10,204,26),style(transparent),label('Field:'),state(nil),font(0,12),icon(0),menu())).

$field_styles([transparent, opaque, rectangle, shadow, motif]).

% open 'edit_field' panel when selected field 'opened'

panel_event(Panel,edit,selected(SName,Sp,field(FPs..))):-
    %findall(Style,clause_head($fcontainer(Style,_..)),Styles),
    $field_styles(Styles),
    $open_editor(edit_field,Panel,SName,field(FPs..),Styles).

% mapping field specific properties
$map_props([lock(V),Vs..],[button(lock):=V,Rest..]):-
    $map_props(Vs,Rest).

$map_props([lines(V),Vs..],[button(lines):=V,Rest..]):-
    $map_props(Vs,Rest).

$map_props([exitset(),Vs..],Rest):-
    !,$map_props(Vs,Rest).

$map_props([exitset(XCh,XChs..),Vs..],[button(Name):=on,Rest..]):-
    $mapxch(Name,XCh),
    $map_props([exitset(XChs..),Vs..],Rest).

/* -- edit_field behaviour */

panel_event(edit_field,update,field(name(name),_,Value..)):-
    $selection_rename(Value).

panel_event(edit_field,update,field(name(outline),_,Value..)):-
    $fieldvalue(Value,New),
    $update_selected(style(New)).

panel_event(edit_field,click,field(outline)).  % disable editing

panel_event(edit_field,update,button(name(Style),Ps..)):-
    $update_font_style(Style,Ps).

panel_event(edit_field,update,button(name(lock),Ps..)):-
    $member(state(State),Ps),
    $update_selected(lock(State)).

panel_event(edit_field,update,button(name(lines),Ps..)):-
    $member(state(State),Ps),
    $update_selected(lines(State)).

panel_event(edit_field,update,field(name(font),_,Value..)):-
    $update_font(edit_field,Value).

panel_event(edit_field,click,field(font)).  % disable editing

panel_event(edit_field,update,field(name(size),_,Value..)):-
    $update_font_size(edit_field,Value).

panel_event(edit_field,doubleclick,list(name(menuitems),Ps..)):-
    $member(selection(I,S),Ps),
    $openmenuitem(edit_field,selection(I,S)).

panel_event(edit_field,update,field(name(edititem),_,Value..)):-
    forget(edititem(S),$local),!,   % editing existing item
    $fieldvalue(Value,New),
    panel_view(edit_field,list(menuitems):contents(L..)),
    $replace(S,L,New,NewL),
    $update_selected(menu(NewL..)),
    panel_view(edit_field,list(menuitems):=[contents(NewL..),selection(S,_)],field(edititem):='').

panel_event(edit_field,update,field(name(edititem),_,Value..)):-
    $fieldvalue(Value,New),
    panel_view(edit_field,list(menuitems):[contents(L..),selection(I,_)]),   % insert in existing list
    New\=''->                   % ignore nil symbols
       [$insert(I,L,New,NewL),  % insert after current selection
        successor(I,NewI),      % bump selection to new item
        $update_selected(menu(NewL..)),   
        panel_view(edit_field,
                   list(menuitems):=[contents(NewL..),selection(NewI,_)],field(edititem):='')].

panel_event(edit_field,update,list(name(menuitems),P,contents(L..),Etc..)):-
    $update_selected(menu(L..)).    % update, e.g., dragging, track selected item to list

panel_event(edit_field,update,button(XChar)):-
    $mapxch(XChar,Ch),
    panel_view(edit_field,button(XChar):state(S)),
    $get_dialog_item(Panel,field(IPs..)),
    $member(exitset(XChs..),IPs),
    $update_xset(XChs,Ch,S,NXChs),
    $put_dialog_item(field(IPs..),exitset(NXChs..)).

$update_xset([],Ch,on,[Ch]):-!.
$update_xset([],Ch,off,[]).
$update_xset([Ch,Etc..],Ch,off,[Etc..]):-!.
$update_xset([Ch,Etc..],Ch,on,[Ch,Etc..]):-$mapxch(Clab,Ch),!. % shouldn't happen
$update_xset([XCh,Etc..],Ch,S,[XCh,NEtc..]):-
    $update_xset(Etc,Ch,S,NEtc).

$mapxch('Enter',enter).    
$mapxch('Return','\r').    
$mapxch('Tab','\t').    
$mapxch('Esc','\1B').    

panel_event(edit_field,click,button('OK')):-
    panel_close(edit_field).

panel_event(edit_field,click,button(cancel)):-
    recall(selected(Panel,name(Sn),Saved),$local),    % revert to original object
    panel_view(Panel,selected(Sn):=Saved),
    panel_close(edit_field).

panel_event(edit_field,close):-
    $close_editor(edit_field).
