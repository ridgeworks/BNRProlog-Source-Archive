/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/list_editor.p,v 1.1 1997/03/14 17:09:29 harrisj Exp $
*
*  $Log: list_editor.p,v $
 * Revision 1.1  1997/03/14  17:09:29  harrisj
 * Moved files required by panels.a goal from panel_files to Panel_3.1.
 * Formally added Editing, Info, Interface to panel_files sub-project.
 * Added a makefile to panel_files subproject
 *
 * Revision 1.1  1995/09/22  11:25:02  harrisja
 * Initial version.
 *
*
*/
/*
 *   list_editor
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
/*
    List Class as defined in 'list_class'

    Object Form:
        list(name(Name),        % a symbol identifying the button in a panel
             place(Place..),    % a list of 4 integers defining a rectangle
             contents(L..),     % contents (terms) of the list
             selection(I,Sel),  % current selection index and selected term
             top(T),            % index into list of top displayed term 
             style(Style),      % one of rectangle, shadow, or motif
             font(F,S,St..)     % font name, size and style specification
            )                   % end of value specification
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
%   $fieldvalue   in 'panel editor'
%%   $lcontainer   in 'list_class'
%   $member       in 'panel works'

% panel for editing list properties
panel_definition(edit_list,
    pos(276,47),
    size(343,299),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4)),
    field(name(size),place(169,100,224,120),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    field(name(name),place(204,8,322,28),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r','\1B')),
    button(name('OK'),place(181,264,269,292),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    button(name('Contents:'),place(1,133,66,149),style(transparent),label('Contents:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Add/Edit:'),place(1,240,67,256),style(transparent),label('Add/Edit:'),state(nil),font(0,12),icon(0),menu()),
    field(name(edititem),place(68,238,208,258),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    list(name(menuitems),place(68,132,224,230),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    button(name(cancel),place(77,268,157,288),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    field(name(outline),place(89,38,211,58),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    button(name(condense),place(251,235,332,251),style('check box'),label('Condense'),state(off),font(0,12),icon(0),menu()),
    button(name(extend),place(251,213,314,229),style('check box'),label('Extend'),state(off),font(0,12),icon(0),menu()),
    button(name(shadow),place(251,191,320,207),style('check box'),label('Shadow'),state(off),font(0,12),icon(0),menu()),
    button(name(outline),place(251,169,315,185),style('check box'),label('Outline'),state(off),font(0,12),icon(0),menu()),
    button(name(underline),place(251,147,331,163),style('check box'),label('Underline'),state(off),font(0,12),icon(0),menu()),
    button(name(italic),place(251,125,304,141),style('check box'),label('Italic'),state(off),font(0,12),icon(0),menu()),
    button(name(bold),place(251,103,297,119),style('check box'),label('Bold'),state(off),font(0,12),icon(0),menu()),
    button(name('Font Style:'),place(249,80,325,96),style(transparent),label('Font Style:'),state(nil),font(0,12),icon(0),menu()),
    button(name('Size:'),place(176,80,213,96),style(transparent),label('Size:'),state(nil),font(0,12),icon(0),menu()),
    field(name(font),place(16,100,139,120),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    button(name('Font:'),place(16,80,55,96),style(transparent),label('Font:'),state(nil),font(0,12),icon(0),menu()),
    button(name('List Style:'),place(12,40,90,56),style(transparent),label('List Style:'),state(nil),font(0,12),icon(0),menu()),
    field(name(panel),place(57,8,151,28),pre(''),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(rectangle),menu(),exitset(enter,'\t')),
    button(name('Panel:'),place(12,10,58,26),style(transparent),label('Panel:'),state(nil),font(0,12),icon(0),menu()),
    button(name('List:'),place(163,10,204,26),style(transparent),label('List:'),state(nil),font(0,12),icon(0),menu())).

$list_styles([rectangle, shadow, motif]).

% open 'edit_field' panel when selected button 'opened'

panel_event(Panel,edit,selected(SName,Sp,list(LPs..))):-
    %findall(Style,clause_head($lcontainer(style(Style),_..)),Styles),
    $list_styles(Styles),
    $open_editor(edit_list,Panel,SName,list(LPs..),Styles).

% mapping list specific properties
$map_props([contents(L..),Vs..],[list(menuitems):=contents(L..),Rest..]):-
    $map_props(Vs,Rest).

/* -- edit_list behaviour */

panel_event(edit_list,update,field(name(name),_,Value..)):-
    $selection_rename(Value).

panel_event(edit_list,update,field(name(outline),_,Value..)):-
    $fieldvalue(Value,New),
    $update_selected(style(New)).

panel_event(edit_list,click,field(outline)).  % disable editing

panel_event(edit_list,update,button(name(Style),Ps..)):-
    $update_font_style(Style,Ps).

panel_event(edit_list,update,field(name(font),_,Value..)):-
    $update_font(edit_list,Value).

panel_event(edit_list,click,field(font)).  % disable editing

panel_event(edit_list,update,field(name(size),_,Value..)):-
    $update_font_size(edit_list,Value).

panel_event(edit_list,doubleclick,list(name(menuitems),Ps..)):-
    $member(selection(I,S),Ps),
    $openmenuitem(edit_list,selection(I,S)).

panel_event(edit_list,update,field(name(edititem),_,Value..)):-
    forget(edititem(S),$local),!,   % editing existing item
    $fieldvalue(Value,New),
    panel_view(edit_list,list(menuitems):contents(L..)),
    $replace(S,L,New,NewL),
    L\=NewL->$update_selected(contents(NewL..)),
    panel_view(edit_list,list(menuitems):=[contents(NewL..),selection(S,_)],field(edititem):='').

panel_event(edit_list,update,field(name(edititem),_,Value..)):-
    $fieldvalue(Value,New),       % not editing existing item, insert in list
    panel_view(edit_list,list(menuitems):[contents(L..),selection(I,_)]),
    New\=''->                   % ignore nil symbols
       [$insert(I,L,New,NewL),  % insert after current selection
        successor(I,NewI),      % bump selection to new item
        L\=NewL->$update_selected(contents(NewL..)),
        panel_view(edit_list,
                   list(menuitems):=[contents(NewL..),selection(NewI,_)],field(edititem):='')].

panel_event(edit_list,update(_,_),list(name(menuitems),P,Contents,Etc..)):-
    $update_selected(Contents).  % contents update, e.g., dragging, track selected item to list

panel_event(edit_list,click,button('OK')):-
    panel_close(edit_list).

panel_event(edit_list,click,button(cancel)):-
    recall(selected(Panel,name(Sn),Saved),$local),    % revert to original object
    panel_view(Panel,selected(Sn):=Saved),
    panel_close(edit_list).

panel_event(edit_list,close):-
    $close_editor(edit_list).

$updatelist(L):-
    $get_dialog_item(_,list(N,P,contents(Old..),Etc..)),
    L\=Old,
    $put_dialog_item(list(N,P,contents(Old..),Etc..),contents(L..)).
    
