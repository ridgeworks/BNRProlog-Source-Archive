/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/panel_uif.p,v 1.1 1997/03/14 17:09:39 harrisj Exp $
*
*  $Log: panel_uif.p,v $
 * Revision 1.1  1997/03/14  17:09:39  harrisj
 * Moved files required by panels.a goal from panel_files to Panel_3.1.
 * Formally added Editing, Info, Interface to panel_files sub-project.
 * Added a makefile to panel_files subproject
 *
 * Revision 1.1  1995/09/22  11:25:50  harrisja
 * Initial version.
 *
*
*/

/*
 *   panel uif
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
% User interface for Panels - provides "Panels" menu and online Help facility.
% Developers will probably leave this out of applications they build. This file
% depends on a 'panels_version' predicate for locating support files. A call to
% installmenu must be made to define menu items.

/*
    Command key mappings for Panels 
    Required since Unix systems don't have universal application menubar,
       so each window type has to do their own.
    Normal menuselect handlers do the real work.
*/

/*   First, the Cut, Copy, and Paste from Edit menu */

panel_event(Panel,keystroke(x,[0,0,0,0,1,1]),Any):-
    menuselect(Panel,'Edit','Cut').

panel_event(Panel,keystroke(c,[0,0,0,0,1,1]),Any):-
    menuselect(Panel,'Edit','Copy').

panel_event(Panel,keystroke(v,[0,0,0,0,1,1]),Any):-
    menuselect(Panel,'Edit','Paste').

/* Next Save and Close from the file menu */
panel_event(Panel,keystroke(s,[0,0,0,0,1,1]),Any):-
    menuselect(Panel,'File','Save').

panel_event(Panel,keystroke(w,[0,0,0,0,1,1]),Any):-
    menuselect(Panel,'File','Close').

% -- Help panel -----------------------------------------

panel_event('Help',click,button('Try Me')):-
    panel_directory(Folder),
    defaultdir(Dd),
    defaultdir(Folder),
    load_context('Try_Me'),
    defaultdir(Dd).

panel_event('Help',click,button('Editing')):-
    $panel_text('Editing').

panel_event('Help',click,button('Interface')):-
    $panel_text('Interface').

panel_event('Help',click,button('Info')):-
    $panel_text('Info').

panel_event('Help',click,button(quit)):-
    panel_close('Help').

% -- $panel_text is useful for documentation --

$panel_text(Name):-
    recall(open_text(Name,_),$local),!,
%    panel_directory(Folder),
%    concat(Folder,Name,Path),
%    recall(open_text(Path,_),$local), % already open
    activewindow(Name).
    
$panel_text(Name):-
    panel_directory(Folder),
    defaultdir(DD),
    defaultdir(Folder),
    open(File,Name,read_window,0),
    remember(open_text(Name,FileID),$local),
    defaultdir(DD).

userclose(Name,_,_):-
    forget(open_text(Name,FileID),$local),
    close(FileID,0),
    closewindow(Name).

menuselect(Path,'File','Close'):-
    forget(open_text(Path,File),$local),
    close(File,0),
    closewindow(Path).

% -- panel layout ----

panel_definition('Help',
    pos(59,53),
    size(260,184),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(off)),
    button('Example panels.',[113,21,223,37],[transparent,'Example panels.',nil,font(0,12),icon(0),menu()]),
    button('Guide to editing.',[113,53,225,69],[transparent,'Guide to editing.',nil,font(0,12),icon(0),menu()]),
    button('List of panel calls.',[113,85,237,101],[transparent,'List of panel calls.',nil,font(0,12),icon(0),menu()]),
    button('Documentation.',[113,117,220,133],[transparent,'Documentation.',nil,font(0,12),icon(0),menu()]),
    button('Exit Help.',[114,150,177,166],[transparent,'Exit Help.',off,font(0,12),icon(0),menu()]),
    button('Try Me',[16,20,96,40],[standard,'Try Me',off,font(0,12),icon(0),menu()]),
    button('Info',[16,116,96,136],[standard,'Info',off,font(0,12),icon(0),menu()]),
    button('Interface',[16,84,96,104],[standard,'Interface',off,font(0,12),icon(0),menu()]),
    button('Editing',[16,52,96,72],[standard,'Editing',off,font(0,12),icon(0),menu()]),
    button(quit,[16,148,96,168],[standard,'Quit',off,font(0,12),icon(0),menu()])).

% -------------------------------------------------------------------------------

%                  --   Panels menu   -- 

% -------------------------------------------------------------------------------

%menuselect(_anywindow,'Panels', 'New'):- 
%    Window = [pos(100,100),size(300,200),
%                options(style(document),background(white,white),picture(),lock(off),dialog(off))],
%    once($untitled(1,Panel)),
%    panel_create(Panel,Window,[]),
%    panel_open(Panel).

menuselect(_anywindow,'New','menubar') :-
    Window = [pos(100,100),size(300,200),
                options(style(document,menubar),background(white,white),picture(),lock(off),dialog(off))],
    once($untitled(1,Panel)),
    panel_create(Panel,Window,[]),
    panel_open(Panel).
    
menuselect(_anywindow,'New', 'nomenubar'):- 
    Window = [pos(100,100),size(300,200),
                options(style(document),background(white,white),picture(),lock(off),dialog(off))],
    once($untitled(1,Panel)),
    panel_create(Panel,Window,[]),
    panel_open(Panel).


$untitled(N,Panel):-
    swrite(Panel,'Untitled',N),
    not(panel_definition(Panel,_..)),
    not(iswindow(Panel,_,_)).             % and not another window by the same name

$untitled(N,Panel):-
    N1 is N+1,
    $untitled(N1,Panel).

menuselect(Window,'Panels', 'Open...'):- 
	$panel_names(Panels),
    selectone('Currently loaded panel definitions:',Panels,Selection),
    concat(Preamble,Context,Selection),
    concat(Panel,', in ',Preamble),
    panel_open(Panel).

$panel_names(Panels) :-
	definition(panel_definition(P,_..):-_,C),
	swrite(N,P,', in ',C),
	new_obj(panel$(N),_,$local),
	fail.
$panel_names(Panels):-
	findset(N,forget(panel$(N),$local),Panels).

menuselect(Window,'Panels', 'Help'):-
    panel_open('Help').

menuselect(Window,'Panels', 'Quit'):-
    $quit_context.

installmenu('Panels'):- 
    addmenu(150, 'New',-1),
    additem('nomenubar','',150,0,1),
    additem('menubar','',150,1,2),
    addmenu(2224,'Panels',0),           % main menu ....
    additem('New', [menu(150)], 2224,0,1),
    additem('Open...', '', 2224,1,2),
    additem('-', '(', 2224,2,3),
    additem('Help','', 2224,3,4),
    additem('-', '(', 2224,4,5),
    additem('Quit','',2224,5,6).

