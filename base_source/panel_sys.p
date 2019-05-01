/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/panel_sys.p,v 1.3 1996/10/29 11:31:29 harrisj Exp $
*
*  $Log: panel_sys.p,v $
 * Revision 1.3  1996/10/29  11:31:29  harrisj
 * Added panel_menu_create and panel_menu_delete to pre-create a panel popup menu
 * and then to delete it.
 * Modified panel_menu to call panel_menu_create instead of addmenu,$build_entries.
 * panel_menu looks up the panel menu and if it does not find it, creates it.
 * panel_menu also modified to use popdownmenu instead of deletemenu.
 * panel_close modified to call panel_menu_delete to delete all associated panel
 * popup menus
 *
 * Revision 1.2  1996/10/08  11:12:11  harrisj
 * Modified $delete_panel to remove the state space structures
 * associated with lists when deleting a panel
 *
 * Revision 1.1  1995/09/22  11:25:45  harrisja
 * Initial version.
 *
*
*/
/*
 *   panel sys
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
% Support of opening and closing panels, and support for popup menus
/*

Panel id's have two forms:

    Template        % Template is a symbol identifying the panel_definition to be used
    Template:ID     % Template as above, ID is application supplied term used to
                    %   distinguish instances of the same definition.


panel_id(Panel,Template,Window)
-------------------------------
    given a valid 'Panel' name, 'Template' and 'Window' are unified with the name
of the panel_definition and the corresponding window name respectively.


panel_open(Panel)
panel_open(Panel,Init..)
panel_open(Panel,pos(X,Y))
panel_open(Panel,pos(X,Y),Init..)
---------------------------------

This call trys to activate an existing window, or open a window with an existing 
definition, or to create a panel with the given name by refering to panel_content
and panel_window clauses.  

This call is the standard procedure for an applications to use a panel window.

Open.. in the Panels menu lists panels with definitions found loaded (and shows
the context they are found in. Double clicking one does a panel_open.
 
No context load or unload is ever done -- applications must do this explicitly
themselves.


panel_create(Panel)
panel_create(Panel,pos(X,Y))
panel_create(Panel,Window,Content)
----------------------------------

Creates a panel given Window (a list of the form [Pos,Size,Options]) and 
Content (a list of objects). This allows Panels to be created dynamically,
i.e., no panel_definition clause required.


panel_save(Panel)
------------------

Saves the current panel definition in a text file. Prompts for file
as required. Fails if user aborts any dialog. Panels which are instances cannot 
be saved as definitions.


panel_close(Panel)
------------------

Closes Panel and prompts for save if definition modified. Fails if user aborts 
any dialog.

panel_menu(Panel,List,Choice)
----------------------------- 

Displays a pop-up menu in the panel at the location of the last mouse down, fails
if no menu item is chosen, else it unifies Choice with the menu entry chosen.

*/
% -- other local predicates used:
%   $savecontent in 'panel view'
%   $getitem     in 'panel view'
%   $grafpanel   in 'panel view'
%   $report      in 'panel works'

%  forms of panel id's
panel_id(Panel,Panel,Panel):-
    symbol(Panel),!.

panel_id(Name:ID,Name,Window):-
    symbol(Name),
    swrite(Window,Name,':',ID).

% mark window as modified
%$mark_window(Window):-
%    recall(Window(dirty),$local)->!;remember(Window(dirty),$local).

%
%  event handlers for 'FIle' menu save and close

menuselect(Window,'File','Close'):-    % 'Close' a panel
    ispanel(Panel,Window),
    panel_close(Panel);[].  % on user aborts we dont want the system close!

menuselect(Window,'File','Save'):-     % 'Save' a panel
    ispanel(Panel,Window),
    panel_attribute(Panel,dirty(on))->
    %recall(Window(dirty),$local)->
        [panel_save(Panel);true];  % on user aborts we dont want the system save!
        beep.

% termination code
$close_all_panels:-
    foreach(ispanel(Panel) do panel_close(Panel)),
    foreach(forget(open_text(Path,File),$local) do
        [close(File,0),closewindow(Path)]).

%
% -- panel_create is called from New or panel_open
% -- panel_create/3 is used to create dynamic panels 


panel_create(Panel,_..):-
    recall(panel_window(Panel,_..),$local),!.  % has already been created...
    
panel_create(Panel):-
    panel_id(Panel,Name,Window),
    definition(panel_definition(Name,Pos,Size,Options,Items..):-[],Context),
    context(Context,Path),!,  % commit
    panel_create(Panel,[Pos,Size,Options],Items),
    remember(source(Panel,Path),$local).

panel_create(Panel,pos(X,Y)):-  % create a panel centred at X,Y
    panel_id(Panel,Name,Window),
    definition(panel_definition(Name,Pos,size(W,H),Options,Items..):-[],Context),
    $panel_place(X,Y,W,H,GX1,GY1),
    context(Context,Path),!,
    panel_create(Panel,[pos(GX1,GY1),size(W,H),Options],Items),
    remember(source(Panel,Path),$local).  % commit

panel_create(Panel,Windef,Content):-
    panel_id(Panel,Name,Window),
    once($window(Windef,Attrs)),
    remember(panel_window(Panel,Window,Attrs..),$local),
    $upgrade(Content,NewContent),
    $savecontent(Window,NewContent,Hitlist),
    voiditem(Void),!,  % commit
    remember(Window(Panel,down(Void,0,0,0),Hitlist),$local).

panel_create(Panel,_..):-
    $report('Confused: could not create ',Panel),
    fail.

% -- place panel so it fits on screen

$panel_place(GX,GY,W,H,GXL,GYT):-       % GX,GY is nominal middle of the panel, 
    scrndimensions(SW,SH,main),         % W,H are width and height
    mbarheight(MH),                     % compensate for menu bar height
    GXl is GX-W//2,GXr is GXl+W,        % GXl,GYt is adjusted upper left corner
    $fitpanel(GXl,GXr,0,SW,GXL),
    GYt is GY-H//2,GYb is GYt+H,
    $fitpanel(GYt,GYb,MH,SH,GYT).

$fitpanel(Low,Up,Min,Max,Low):-Low>=Min,Up=<Max.
$fitpanel(Low,Up,Min,Max,Nlow):-
    Up>Max,
    Nlow is Low-(Up-Max),
    Nlow>=Min.
$fitpanel(Low,Up,Min,Max,Min).

% convert old window format to new as required
$window([Pos,Size,options(St..)],WinStruc):-
    $map_styleList([St..],NSt..),
    $window([Pos,Size,options(style(NSt..),background(white,white),picture(),lock(off),dialog(off))],
            WinStruc).

$window([Pos,Size,options(Style,Background,Picture,Lock,Dialog)],WinStruc):-
    $window([Pos,Size,options(Style,Background,Picture,Lock,Dialog,grid(4,4))],WinStruc).

$window([Pos,Size,options(Style,Background,Picture,Lock,Dialog,Grid,_..)],
        [Pos,Size,Style,Background,Picture,Lock,Dialog,Grid,dirty(off)]).

% convert old objects to new as required
$upgrade([],[]).

$upgrade([background(Stuff..),Olds..],News):-   % can't map backgrounds, ignore them
    !,$upgrade(Olds,News).

$upgrade([Old,Olds..],[New,News..]):-
    once($upgradeobj(Old,New)),     % translation routines provided by new classes
    $upgrade(Olds,News).

% -- panel_open --

panel_open(Panel,_..):-
    panel_id(Panel,Name,Window),
    iswindow(Window,text,_),!,      % requested window is already a text window
    $report('Thwarted: ',Window,' is open as a text window.').

panel_open(Panel,pos(_,_),Init..):-
    panel_id(Panel,Name,Window),
    activewindow(Window,graf),!,    % already open (may have been hidden). 
    !,                              % commit to this panel_open clause
    panel_view(Panel,Init..).       % note, no additional open event if alraedy open

panel_open(Panel,pos(X,Y),Init..):-
    panel_create(Panel,pos(X,Y)),
    !,                              % commit to this panel_open clause
    $open_panel(Panel,Init..).

panel_open(Panel,Init..):-
    panel_id(Panel,Name,Window),
    activewindow(Window,graf),      % already open (may have been hidden). 
    !,                              % commit to this panel_open clause
    panel_view(Panel,Init..).       % note, no additional open event if alraedy open

panel_open(Panel,Init..):-
    panel_create(Panel),
    !,                         % commit to this panel_open clause
    $open_panel(Panel,Init..).
    
panel_open(Panel,_..):-
    $report('Baffled: ',Panel,' not loaded?').

panel_event(Panel,open,nil):- % postevent needed the extra argument
    panel_event(Panel,open).

% -- open a panel window
$open_panel(Panel,Init..):-
    recall(panel_window(Panel,Window,Pos,Size,style(St..),_..),$local),
    $map_styleList([Wstyle..],St..), % map panel styles to window details
    openwindow(graf,Window,Pos,Size,options(hidden,Wstyle..)),
    activewindow(Window,graf), % make panel visible
    panel_view(Panel,Init..),  % execute initial panel_view requests
    $waitfor(userupdate,Window,_,_),
    $updatepanel(Window),      % draw window
%    sizewindow(Window,W,H),
%    validrect(Window,0,0,W,H), % and set valid region to cancel update event
    postevent(dispatch_panel_event,Panel,open,nil),!.
%    dispatch_panel_event(Panel,open,nil),!.

% -- close and reopen an existing panel, used to change window styles
panel_reopen(Panel):-
    recall(panel_window(Panel,Window,Attrs..),$local),
    closewindow(Window),
    $reopen_panel(Window,Attrs).

$reopen_panel(Window,[Pos,size(W,H),style(St..),_..]):-
    $map_styleList([Wstyle..],St..), % map panel styles to window details
    mbarheight(Window,MH),
    NH is H - MH,
    openwindow(graf,Window,Pos,size(W,NH),options(Wstyle..)).

$map_styleList([WinStyle,menubar],St,menubar) :- 
	!,
	$map_styles(WinStyle,St).
	
$map_styleList([menubar,WinStyle],menubar,St) :-
	!,
	$map_styles(WinStyle,St).

$map_styleList([WinStyle],St) :-
	!,
	$map_styles(WinStyle,St).

$map_styles(documentproc,document):-$unix,!.    % update panel editor if style set changes
$map_styles(nogrowdocproc,document).
$map_styles(documentproc,document).
$map_styles(dboxproc,dialog).
$map_styles(namedboxproc,namedDialog).
$map_styles(plaindbox,rectangle).
$map_styles(altdboxproc,shadow).
$map_styles(rdocproc,rounded).
$map_styles(plaindbox,motif).


% -- panel_close --

panel_close(Panel):-  
    recall(panel_window(Panel,_..),$local)->       
       [panel_id(Panel,Name,Window),
        $save_option(Panel,Name,Window),% fails if user aborts
        panel_event(Panel,close),       % tell the user first
        $delete_panel(Panel,Window),    % delete internal data
	 foreach(panel_menu_create(Panel,MenuId,_) do panel_menu_delete(Panel,MenuId,_)),
        closewindow(Window);[],         % then close window
%        userdeactivate(Window,_,_);[], % removed in 3.1.9; not sure why it was there.
        cut].                           % cut choicepoints left by ';'

$save_option(Name:ID,Name,_):-!.    % instance form, no save on close 

$save_option(Panel,Name,Window):-
    panel_attribute(Panel,dirty(off)).
    %not(recall(Window(dirty),$local)). % nothing to save, cut dialog clause on backtrack

$save_option(Panel,Name,Window):-
    swrite(Msg,'Save ',Panel,' before closing it?\n',
                '*** Remember ***\n',
                'A saved definition will need re-loading.'),
    confirm(Msg,'YES','YES',Reply),  % YES succeeds and saves, NO succeeds, CANCEL fails
    Reply = 'YES' -> panel_save(Panel). 


$delete_panel(Panel,Window):-
    forget_all(Window(_..),$local),         % misc temp state info
    $removeShiftSelected(Panel,_),	% List class selection info
    forget_all(panel_window(Panel,_..),$local),   % window(panel,window_name,[pos,size,...])
    forget_all(source(Panel,_..),$local).   % source file

% -- save panel as a text description file ------------------------------------

panel_save(Name:ID):-       % Note, instances can't be saved as definitions
    !,
    panel_id(Name:ID,Name,Window),
    $report('Panel instance, ',Window,', can\'t be saved as definition.').

panel_save(Panel):-
    panel_id(Panel,Panel,Panel),    % consistency check (symbol form of panel/window)
    $panel_file(Panel,Path),        % Get a path   
    $write_pipe(Panel,Pipe),        % save panel definition in a pipe
    $text_window(Path),
    $write_window(Path,Panel,Pipe), % update panel definition facts
    savetext(Path),
    iswindow(Path,text,hidden) -> closewindow(Path),
    panel_attribute(Panel,dirty(_):=dirty(off)).
    %forget(Panel(dirty),$local) -> true.

$text_window(Path):-  % window open with path name
    iswindow(Path,text,_).

$text_window(Path):-  % window open with file name
    openwindow(text,Path,pos(_,_),size(_,_),options(hidden)).

% replace existing (old) panel_defintion with the current (new) panel_definition

$write_window(Window,Name,Pipe):-
    swriteq(Text,Name), % note this is needed, but it adds a trailing space (gotcha)
    swrite(Panel_definition,'\npanel_definition(',Text), % a space is written by write_pipe!!
    dotext(Window,
       [selectcabs(-1,-1),
        scandirection(forward),
        selection(Panel_definition),inq(selectcabs(Start,_)),
        selection('.\n'),inq(selectcabs(_,End)),
        selectcabs(Start,End),
        edit(clear),insert(Pipe)]),  % avoid replace in case any control chars
    close(Pipe,0).

% no prior panel definition in this window -- write it at the end

$write_window(Window,_,Pipe):- 
    dotext(Window,
       [selectcabs(end_of_file,end_of_file),
        insert('\n'),insert(Pipe),insert('\n')]),
    close(Pipe,0).

$write_window(_,_,Pipe):-
    message('Failed to update file... '),
    close(Pipe,0).

$write_pipe(_panel,_pipe):-
    open(_pipe,panel_pipe,read_write_pipe,0),
    recall(panel_window(_,_panel,_,_,Options..),$local),
    positionwindow(_panel,X,Y),
    sizewindow(_panel,W,H),
    swrite(_pipe,'\npanel_definition('),
    swriteq(_pipe,_panel),
    $write_item(_pipe,pos(X,Y)), 
    $write_item(_pipe,size(W,H)), 
    $write_item(_pipe,options(Options..)),
    recall(_panel(_panel,_,Items),$local),
    foreach($member([Op,_],Items) do
       [$getitem(Op,_panel(Item)),
        bind_vars(Item),
        $write_item(_pipe,Item)]),
    swrite(_pipe,').\n').

$write_item(_pipe,Item):-
    swrite(_pipe,',\n    '),
    swriteq(_pipe,Item).
    
% -- Text file with panel definition ----------------------------------------

$panel_file(Panel,Path):-   % not a panel instance
    recall(source(Panel,Path),$local),  % and can find panels source file..
    !.                                  % commit

$panel_file(Panel,Path):-
    nameafile('Save in...','Enter a file name:',Panel,Path),  % fails if user aborts
    remember(source(Panel,Path),$local).

panel_rename(Panel,Panel):-!.  % commit if same term

panel_rename(Panel,NewPanel):-   % rename a panel
	ispanel(Panel,Window),
	panel_id(NewPanel,_,NewWin),
	renamewindow(Window,NewWin).

userrename(NewWin,Window,graf):-   % rename a panel
    panel_id(Panel,Name,Window),
    panel_id(NewPanel,_,NewWin),
    panel_view(Panel,[]:Content),
    forget(Window(Panel,Down,_),$local),
    foreach($getitem(Op,Window(Item)) do dispose_obj(Op)),
    $savecontent(NewWin,Content,Hitlist),
    voiditem(Void),
    remember(NewWin(NewPanel,down(Void,0,0,0),Hitlist),$local),
    once(update(panel_window(Panel,Window,Windef..),panel_window(NewPanel,NewWin,Windef..),$local)),
    forget(source(Panel,Path),$local)->     % change source if it exists
        remember(source(NewPanel,Path),$local),
    panel_attribute(NewPanel,dirty(_):=dirty(on)).
    %forget(Window(_),$local)->true,         % remove dirty flag
    %$mark_window(NewWin),                   % set new flag

% -- Generator or tester for open panels

ispanel(Panel):-recall(panel_window(Panel,_..),$local).
ispanel(Panel,Window):-recall(panel_window(Panel,Window,_..),$local).

% -- test for editable panel
$unlocked(Panel):-
    get_obj(_,panel_window(Panel,_,Pos,Size,Style,Background,Picture,lock(off),Dialog..),$local).

% -- test for non-dialog panel, i.e., can deactivate 
$switchable(Panel):-
    get_obj(_,panel_window(Panel,_,Pos,Size,Style,Background,Picture,Lock,dialog(State),Grid..),
            $local)->
        State=off.

% -- panel grid for editing
$grid(Panel,X,Y):-
    get_obj(_,panel_window(Panel,_,Pos,Size,Style,Background,Picture,Lock,Dialog,grid(X,Y),_..),
            $local).

% -- general panel attribute access; for use in other contexts
panel_attribute(Panel,[]:Attrs):-
    !,get_obj(_,panel_window(Panel,_,Attrs..),$local).

panel_attribute(Panel,[]:=Attrs):-
    update(panel_window(Panel,Window,_..),panel_window(Panel,Window,Attrs..),$local),!.

panel_attribute(Panel,Old:=New):-
    get_obj(Op,panel_window(Panel,Window,Attrs..),$local),
    $opreplace(Attrs,Old,New,NAttrs),
    put_obj(Op,panel_window(Panel,Window,NAttrs..),$local),!.        

panel_attribute(Panel,Attr):-
    get_obj(_,panel_window(Panel,_,Attrs..),$local),
    $member(Attr,Attrs).

$opreplace([O(V..),Ops..],O(V..),New,[New,Ops..]):-!.
$opreplace([O,Ops..],Op,New,[O,News..]):-
    $opreplace([Ops..],Op,New,[News..]).

% -- General purpose poupup panel menu ---------------------------------------

panel_menu(Panel,Items,Choice):-
    panel_menu(Panel,Items,1,Choice).

panel_menu(Panel,_entries,_select,_choice):-
    panel_id(Panel,_,Window),
    recall(Window(Panel,down(_,_,_x,_y),_),$local),
    X1 is _x-20, Y1 is _y-8, 
    panel_menu(Window,_entries,_select,X1,Y1,_choice).

panel_menu(Panel,_entries,_select,_x,_y,_choice):-       % fails if no choice 
   panel_menu_create(Panel,MenuId,_entries),
    $menu_index(_entries,_select,_index),
    panel_id(Panel,_,Window),
    localglobal(Window,_x,_y,_left,_top),!,
    [popupmenu(MenuId,_index,_top,_left),$waitfor(menuselect,_panel,_menu,_sel)]-> 
       [_menu@=panelmenu->_choice=_sel;_choice=[_menu,_sel],
        popdownmenu(MenuId)]
      ;[% it'd be nice if we could get mouseup or current mouse coordinates here
        nextevent(usermouseup,Window,_x,_y),
        popdownmenu(MenuId), fail].

panel_menu_create(Panel,MenuId,_entries):-
    recall(panelMenu(Panel,MenuId,_entries),$local),!.
panel_menu_create(Panel,MenuId,_entries):-
    list(_entries),
    time(MenuId),		% Get a unique identifier
    addmenu(MenuId,panelmenu,-1),
    $build_entries(MenuId,_entries),
    remember(panelMenu(Panel,MenuId,_entries),$local).

panel_menu_delete(Panel,MenuId,_entries):-
   forget(panelMenu(Panel,MenuId,_entries),$local),
   deletemenu(MenuId).

$waitfor(E,W,D1,D2) :- 
    repeat, 
    userevent(NE,NW,ND1,ND2,noblock),
    $acton(E(W,D1,D2),NE(NW,ND1,ND2)),
    true.   % to circumvent L.C.O.

$acton(E,E):-cut($waitfor).                     % match, $waitfor success cutting repeat choicepoint
$acton(_,userupidle(_..)):-failexit($waitfor).  % idle means end of event queue without match 
%$acton(_,userdownidle(_..)):-failexit($waitfor).% depends on system, Unix dispatches idles 
$acton(E,NE):-              % others, call event handler and try again.
    %E\=NE,
    once(NE),fail.

$build_entries(_,[]).

$build_entries(MenuId,[_entry,_entries..]):-
    symbol(_entry),
    additem(_entry, '', MenuId,end_of_menu,_),
    $build_entries(MenuId,_entries).

$build_entries(MenuId,[[_entry,_attr],_entries..]):-
    symbol(_entry), list(_attr),		% original one is "symbol(_entry,_attr),"  fix it according to Rick Workman's suggestion
    additem(_entry, _attr, MenuId,end_of_menu,_),
    $build_entries(MenuId,_entries).

$menu_index(List,Select,Select):- arg(Select,List,_),!.  % Select is integer in range

$menu_index([Select,_..],Select,1).                      % Select is a memebr in List

$menu_index([_,Entries..],Select,N1):-
    $menu_index(Entries,Select,N),
    successor(N,N1).

% -- all the utilities for drawing objects on panels

% -- repaint an area  (might be a list of areas), 
%    draw anything uncovered by erasing Covers -----

$paint_update([Xl,Yt,Xr,Yb],Items,Window):-
    integer(Xl,Yt,Xr,Yb),
    not(not([
        $coverage(Items,[Xl,Yt,Xr,Yb],[],CItems),
        $drawclip(Window,[Xl,Yt,Xr,Yb],CItems)])).

$paint_update([],_,_).

$paint_update([[Cover..],Covers..],Items,Window):-
    $paint_update(Cover,Items,Window),
    $paint_update(Covers,Items,Window).

$coverage([],Cover,Grafs,Grafs).

$coverage([Item,Items..],Cover,Grafs,Grafs2):-
    $checkcover(Item,Cover,Grafs,Grafs1),
    $coverage(Items,Cover,Grafs1,Grafs2).

$checkcover(Class(name(Name),place(X1,Y1,X2,Y2),Ps..),[Xl,Yt,Xr,Yb],Items,
            [Class(name(Name),place(X1,Y1,X2,Y2),Ps..),Items..]):-
    X1=<Xr,X2>=Xl,Y1=<Yb,Y2>=Yt.             % check for overlap, backtrack on fail

$checkcover(Item,Cover,Items,Items).
/*
$area([X1,Y1,X2,Y2],[X1,Y1,X2,Y2]):-    % leaf case
    integer(X1,Y1,X2,Y2),!.             % commit 
$area([[Areas..],_..],A):-              % node case
    $area(Areas,A).                     % chase a branch
$area([_,Areas..],Area):-               % node case, chase other branches
    $area(Areas,Area).
*/
% called from update events
$updatepanel(Window):-
    get_obj(Op,panel_window(Panel,Window,
            Pos,size(W,H),style(St..),background(Pat,Col),picture(Pict..),Etc..),
            $local),
    $grafstyle([St..],[0,0,W,H],StGraf,Clip),
    $grafpict(Pict,Clip,PtGraf),
    dograf(Window,[crectabs(0,0,W,H),backpat(Pat),backcolor(Col),StGraf,crectabs(Clip..),PtGraf]),
    $grafpanel(Window).

% update window size, called from grow events
$resizepanel(Window):-
    sizewindow(Window,W,H), % get new size
    get_obj(Op,panel_window(Panel,Window,Pos,size(OW,OH),Options..),$local),
    put_obj(Op,panel_window(Panel,Window,Pos,size(W,H),Options..),$local),
    dograf(Window,crectabs(0,0,W,H)),      % set clipping rect. to full window before update
    $invalidate(Window,OW,OH,W,H,Options..), % invalidate other areas depending on panel
    panel_attribute(Panel,dirty(_):=dirty(on)).
    %$mark_window(Window).                  % mark window as dirty

$invalidate(Window,OW,OH,W,H,S,B,picture(_,_),Etc..):- % picture, invlidate all
    !,
    invalidrect(Window,0,0,W,H).

$invalidate(Window,OW,OH,W,H,style(Styles..),Etc..):-  % motif, invlidate borders
    $isMotif(Styles..),
    !,
    OFH is OH-2,invalidrect(Window,0,OFH,OW,OH),
    OFW is OW-2,invalidrect(Window,OFW,0,OW,OH),
    FH is H-2,invalidrect(Window,0,FH,W,H),
    FW is W-2,invalidrect(Window,FW,0,W,H).

$invalidate(Window,OW,OH,W,H,Options..).   % else no additional invalidation


% draw object
$drawobj(Window,V):-
    var(V),!.                          % var argument is a noop

$drawobj(Window,Desc(Args..)):-        % single descriptor case, turn into a list
    !,
    $drawobj(Window,[Desc(Args..)]).

$drawobj(Window,[Graf..]):-            % list case
    get_obj(Op,panel_window(Panel,Window,
            Pos,size(W,H),style(St..),background(Pat,Col),picture(Pict..),Etc..),
            $local),
    $grafstyle([St..],[0,0,W,H],StGraf,Clip),
    dograf(Window,[backpat(Pat),backcolor(Col),[crectabs(Clip..),Graf..]]).


/* draw graf list in a clipping rectangle */
$drawclip(Window,Crect,Items):-
    get_obj(Op,panel_window(Panel,Window,
            Pos,size(W,H),style(St..),background(Pat,Col),picture(Pict..),Etc..),
            $local),
    $grafstyle([St..],[0,0,W,H],StGraf,Clip),
    $grafpict(Pict,Clip,PtGraf),
    $mergeclip(Crect,Clip,MClip),
    dograf(Window,[backpat(Pat),backcolor(Col),[crectabs(MClip..),StGraf,PtGraf]]),
    $drawitems(Items,Window).

$mergeclip([Xl1,Yt1,Xr1,Yb1],[Xl2,Yt2,Xr2,Yb2],[Xl,Yt,Xr,Yb]):-
    $max(Xl1,Xl2,Xl),
    $max(Yt1,Yt2,Yt),
    $min(Xr1,Xr2,Xr),
    $min(Yb1,Yb2,Yb),!.

$min(X,Y,X):-X=<Y.
$min(X,Y,Y):-X>Y.
$max(X,Y,X):-X>=Y.
$max(X,Y,Y):-X<Y.

$isMotif(motif).
$isMotif(motif,Styles..).
$isMotif(Style,Styles..) :- $isMotif(Styles..).

$grafstyle([St..],[Xl,Yt,Xr,Yb],
        [fillpat(clear),rectabs(Xl,Yt,Xr,Yb),
         fillpat(pentype),penpat(black),
         forecolor(white),moveabs(Xl,Yt),
         polygon(lineabs(Xr,Yt,XFr,YFt,XFl,YFt,XFl,YFb,Xl,Yb,Xl,Yt)),
         forecolor(black),moveabs(Xr,Yb),
         polygon(lineabs(Xl,Yb,XFl,YFb,XFr,YFb,XFr,YFt,Xr,Yt,Xr,Yb))],
        [XFl,YFt,XFr,YFb]):-
    $isMotif(St..),
    panel_expand_rect([Xl,Yt,Xr,Yb],-2,-2,[XFl,YFt,XFr,YFb]),!.    % field boundaries

$grafstyle([St..],Place,[fillpat(clear),rectabs(Place..)],Place). % all other styles

$grafpict([],Place,_).

$grafpict([File,Id],[Xl,Yt,Xr,Yb],pictabs(Xl,Yt,Xr,Yb,PId)):-
    ispicture(PId,_,_,File,Id),!.       % picture already loaded

$grafpict([File,Id],[Xl,Yt,Xr,Yb],pictabs(Xl,Yt,Xr,Yb,PId)):-
    loadpicture(File,Id,PId,_),!.       % or it can be loaded

$grafpict([File,Id],[Xl,Yt,Xr,Yb],_).   % invalid picture, do nothing

$drawitems([],Window).

$drawitems([Item,Items..],Window):-
    not(not([panel_item_graf(Item,Graf),dograf(Window,Graf)])),
    $drawitems(Items,Window).


