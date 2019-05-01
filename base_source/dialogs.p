/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/dialogs.p,v 1.2 1996/07/12 09:57:41 yanzhou Exp $
*
*  $Log: dialogs.p,v $
 * Revision 1.2  1996/07/12  09:57:41  yanzhou
 * For a message box, the width of its viewable text area is now reduced from
 * 393 to 391 so that a text string of 65 characters can be displayed correctly
 * (with 1 line-break).  (See ProStar SR60011261 for more info.)
 *
 * Revision 1.1  1995/09/22  11:23:52  harrisja
 * Initial version.
 *
*
*/

/*
    Standard BNR Prolog dialogs implemented as panels

    Definition: dialogs are modal panels in the sense that they are perceived
        as a single predicate call by the programmer, and usually return an
        answer (perhaps as simple as succeed/fail). Only one dialog can be in
        progress at a time; otherwise $diaglogloop control flow gets confused.
        Whether a modal dialog can actually be enforced depends on the window
        manager policy: Yes for the Mac, Maybe for Motif.  
*/

%  General purpose event loop for all dialogs, external control via D1,D2
$dialogloop(Dialog,D1,D2,Init..):-
	activewindow(W,T)->true,
	remember($dialog_active_window(W,T),$local),
	panel_open(Dialog,Init..),
    capsule($evloop(Dialog,D1,D2),$handler(Dialog)),
	panel_close(Dialog),
	forget($dialog_active_window(W1,T1),$local),
	activewindow(W1,T1)->true.

$evloop(Dialog,D1,D2):-
    repeat, % minor event loop
        userevent(Ev,Win,D1,D2,noblock),
        $dialogevent(Ev,Win,D1,D2,Dialog),
        true.   % to prevent L.C.O.

$dialogevent(menuselect,Win,D1,D2,Dialog):-
    beep,!,fail.                % disable menu selections
$dialogevent(Dialog,Win,D1,D2,Dialog):-
	$dialogexit(Dialog).	           % successful exit, cut repeat
$dialogevent(Ev,Win,D1,D2,Dialog) :-
	not(iswindow(Dialog,graf,visible)),	% dialog window closed - fail out
    postevent(Dialog,Dialog,_,fail),
	!,fail.
$dialogevent(useractivate,Win,D1,D2,Dialog) :- % set the active window if it's not already set
	Win \= Dialog,
	get_obj(Op,$dialog_active_window(W,T),$local),
	var(W,T),
	activewindow(W,T),
	put_obj(Op,$dialog_active_window(W,T),$local),
	cut,fail.	% ripple into next clause
$dialogevent(useractivate,Win,D1,D2,Dialog) :-
	Win \= Dialog,			% don't allow another window to become active
	beep,
	activewindow(Dialog,graf),
	!,fail.
$dialogevent(Ev,Win,D1,D2,Dialog):-
    once(Ev(Win,D1,D2)),fail.   % otherwise dispatch event and fail
 
$dialogexit(Dialog) :-
	$dialogfree(Dialog),
	cut($evloop).

$handler(Panel):-	% exception handler for dialog loop
    panel_close(Panel),% close the panel
    $dialogfree(Panel), % free semaphore
    get_error_code(E),  % and resend error
    error(E).

/* flag to prevent re-entrant dialogs */
$dialogok(Dialog):-     % dialog flag off, proceed
    get_obj(Op,dialog(off),$local),
    put_obj(Op,dialog(on,Dialog),$local),!.
$dialogok(Dialog):-     % dialog flag on, fail
    get_obj(_,dialog(on,_),$local),
    failexit($dialogok).
$dialogok(Dialog):-     % no dialog flag yet, make one and set to on
    new_obj(dialog(on,Dialog),_,$local).

$dialogfree(Dialog):-   % reset dialog flag
    get_obj(Op,dialog(on,Dialog),$local),
	!,
    put_obj(Op,dialog(off),$local).
$dialogfree(Dialog):-get_obj(Op,dialog(X..),$local),write('failed to free dialog flag for ',Dialog,' was ',X),nl.

$cleanup :- 
	get_obj(Op,dialog(on,Dialog),$local),
	write('dialog not freed in $cleanup: ',Dialog),nl,
	$dialogfree(Dialog), % if we ever get back to listener, free dialog flag
    postevent(Dialog,Dialog,_,fail), % and exit dialog loop
	cut,fail.		% allow other cleanup to proceed

/* Utilities for changing list selections */

$keylist(Panel,List,down,Displayed):-
    panel_view(Panel,list(List):[top(Top),selection(Ix,_),contents(Entries..)]),
    $picknext(Ix,1,Entries,Panel,NIx),
    $$setselection(Panel,List,NIx,Top,Displayed).

$keylist(Panel,List,up,Displayed):-
    panel_view(Panel,list(List):[top(Top),selection(Ix,_),contents(Entries..)]),
    $picknext(Ix,-1,Entries,Panel,NIx),
    $$setselection(Panel,List,NIx,Top,Displayed).

$keylist(Panel,List,Key,Displayed):-
    Key@>' ',
    panel_view(Panel,list(List):[top(Top),contents(Entries..)]),
    name(Key, [Keyval]),		% uppercase(Key,UKey),name(UKey,[Keyval]),
    $pickentry(Entries,Keyval,1,Ix,Panel),
    $$setselection(Panel,List,Ix,Top,Displayed).

$picknext(Ix,Dir,Entries,Panel,NIx):-
    NIx is Ix+Dir,
    arg(NIx,Entries,Pick)->
        $legal_selection(Panel,Pick);
        failexit($picknext),    % arg failed, hit a limit, really fail
	true.			% defeat LCO so failexit will work
$picknext(Ix,Dir,Entries,Panel,NIx):-
    Nxt is Ix+Dir,              % not a legal selection, keep going
    $picknext(Nxt,Dir,Entries,Panel,NIx).
    
$pickentry([Entry,Entries..],Keyval,Ix,Ix,Panel):-
    name(Entry, [First, _..]),		% uppercase(Entry,UEntry), name(UEntry,[First,_..]),
    Keyval=<First,
    $legal_selection(Panel,Entry),!.
$pickentry([Entry,Entries..],Keyval,Ix,SIx,Panel):-
    NIx is Ix+1,
    $pickentry(Entries,Keyval,NIx,SIx,Panel).

$$setselection(Panel,List,Ix,Top,Displayed):-
    [(Ix>(Top+Displayed-1));(Ix<Top)]->    
        panel_view(Panel,list(List):=[top(Ix),selection(Ix,_)]);
        panel_view(Panel,list(List):=selection(Ix,_)).



/*  test for unix/mac */ 
$unix:-isvolume('/').

/*  predicate to define separator character in path names */ 
$pathseparator('/'):-$unix,!.
$pathseparator(':').

/*  predicate to define highest level 'directory' */ 
$rootdir([]):-$unix,!.
$rootdir(['Desktop']).

/* relative directory name */    
$dirname(Dir,Dir):-     % if unix, leave it alone
    $unix,!.
$dirname(Dir,DDir):-    % if Mac, prepend ':'
    concat(':',Dir,DDir).            

/*-----------------------------------------------------------------------------------------
    selectafile

    Main problems: 
        1. listfiles and listdirectories take a long time due to internal implementation,
           to be fixed for next system
        2. creating an ordered list of directories and files takes a lot of global
           stack space, not so critical when garbage collection is available
        3. Extend the font to display folders/documents/volumes.. or drop menu symbol
*/        

panel_definition(selectafile,
    pos(104,103),
    size(296,194),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4)),
    button(name(cancel),place(208,164,288,184),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name(select),place(208,124,288,152),style(designate),label(''),state(off),font(0,12),icon(0),menu()),
    list(name(filelist),place(4,36,196,184),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    button(name(volume),place(196,52,296,72),style(opaque),label(''),state(nil),font(0,12),icon(0),menu()),
    button(name(dir),place(28,8,172,28),style(shadow),label(''),state(nil),font(0,12),icon(0),menu())).


selectafile(Filetypes,Doit,Selection):-
    nonvar(Filetypes),  % for compatability
    symbol(Doit),
    $dialogok(selectafile),  % claim dialog flag
    defaultdir(Save),
    once($ftlist(Filetypes,FTList)),
    new_obj(filetype(FTList..),FObj,$local),
    $dialogloop(selectafile,Result,Goal,button(select):=label(Doit)),
    dispose_obj(FObj,$local),
    defaultdir(Save),
    !,        % commit
    Selection=Result,
    Goal.


$ftlist('',[_]).
$ftlist([],[_]).
$ftlist(Type,[Type]):-symbol(Type).
$ftlist(Types,Types):-list(Types).

panel_event(selectafile,open):-
    $openfiledialog(selectafile,1),
	!.
panel_event(selectafile,open):-
    postevent(selectafile,selectafile,_,fail).

panel_event(selectafile,click,button(cancel)):-
    postevent(selectafile,selectafile,_,fail).

panel_event(selectafile,click,button(select)):-
    panel_view(selectafile,list(filelist):selection(_,Name)),
    $selectopen(selectafile,Name,1).

panel_event(selectafile,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(filelist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(selectafile,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(filelist),Place,Contents,selection(I0,S0),Ps..)):-
    % I1\=I0 - update selection
    panel_view(selectafile,list(filelist):=selection(I1,S1)),
    dispatch_panel_event(selectafile,update(selection(I0,S0)),
                   list(name(filelist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(selectafile,update(selection(OldI,OldS)),	  % only allow single selection
			list(name(filelist),Place,Contents,selection(NewI,NewS),_..)) :-
	list(NewI),
	!,
	panel_view(selectafile,list(filelist):=selection(OldI,OldS)).

panel_event(selectafile,doubleclick(_,_,selection(_,Name)),list(filelist)):-
    $selectopen(selectafile,Name,1).

panel_event(selectafile,menu(Item),button(dir)):-
    $dirmenu(selectafile,Item,1).

panel_event(selectafile,keystroke(Key,Mods),_):-    % other key
    $keylist(selectafile,filelist,Key,9).

$legal_selection(selectafile,Sel).

/*--------------------------------------------------------------------------
    nameafile
*/
panel_definition(nameafile,
    pos(163,123),
    size(316,201),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on)),
    field(name(label),place(16,140,208,160),pre(''),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset(enter,'\t')),
    field(name(response),place(16,164,208,184),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\t','\r')),
    list(name(filelist),place(16,36,212,136),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    button(name(cancel),place(224,164,304,184),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name(select),place(224,124,304,152),style(designate),label(''),state(off),font(0,12),icon(0),menu()),
    button(name(volume),place(208,52,308,72),style(opaque),label(''),state(nil),font(0,12),icon(0),menu()),
    button(name(dir),place(40,8,184,28),style(shadow),label(''),state(nil),font(0,12),icon(0),menu())).

nameafile(Doit,Label,Default,Selection):-
    symbol(Doit,Label,Default),
    $dialogok(nameafile),  % claim dialog flag
    defaultdir(Save),
    new_obj(filetype(_),FObj,$local),   % exclude files
    $dialogloop(nameafile,Result,Goal,button(select):=label(Doit),
                                   	field(label):=Label,
                                   	field(response):=selection(Default)),
    dispose_obj(FObj,$local),
    defaultdir(Save),
    !,        % commit
    Selection=Result,
    Goal.

panel_event(nameafile,open):-
    $openfiledialog(nameafile,0),
	!.
panel_event(nameafile,open):-
    postevent(nameafile,nameafile,_,fail).

panel_event(nameafile,click,button(cancel)):-
    postevent(nameafile,nameafile,_,fail).

panel_event(nameafile,click,button(select)):-
    panel_view(nameafile,list(filelist):selection(Ix,Name)),
    Ix>0,  % there is a selection, N.B., files can't be selected
    $selectopen(nameafile,Name,0).

panel_event(nameafile,click,button(select)):-   
    panel_view(nameafile,field(response):File,    % select on a file, get Name
                         button(dir):[label(DirComp),menu(Comps..)]),
	$nameafilepath(File,DirComp,Comps,Path),
    postevent(nameafile,nameafile,Path,true).

panel_event(nameafile,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(filelist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(nameafile,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(filelist),Place,Contents,selection(I0,S0),Ps..)):-
    % I1\=I0 - update selection
    panel_view(nameafile,list(filelist):=selection(I1,S1)),
    dispatch_panel_event(nameafile,update(selection(I0,S0)),
                   list(name(filelist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(nameafile,update(selection(OldI,OldS)),	  % only allow single selection
			list(name(filelist),Place,Contents,selection(NewI,NewS),_..)) :-
	list(NewI),
	!,
	panel_view(nameafile,list(filelist):=selection(OldI,OldS)).

panel_event(nameafile,doubleclick(_,_,selection(_,Name)),list(filelist)):-
    $selectopen(nameafile,Name,0).    % fails if selected item is a file

panel_event(nameafile,doubleclick(_,_,selection(_,Name)),list(filelist)).
    % tried to double click on a file

panel_event(nameafile,click,field(response)):-
    panel_view(nameafile,list(filelist):=selection(0,_)),   % deselect list element
    fail.       % fail back to normal editing

panel_event(nameafile,menu(Item),button(dir)):-
    $dirmenu(nameafile,Item,0).

panel_event(nameafile,keystroke(Key,Mods),_):-    % other key
    $keylist(nameafile,filelist,Key,6).

$nameafilepath(File,_,_,File) :-
	$abspathname(File),
	!.

$nameafilepath(File,DirComp,Comps,Path) :-
    $pathseparator(Sp),
    $buildpath(Comps,[DirComp,Sp,File],Path).

$abspathname(File) :-
	$unix,
	!,
	$pathseparator(Sp),
	concat(Sp,_,File).
$abspathname(File) :-
	$pathseparator(Sp),
	not(concat(Sp,_,File)).

$legal_selection(nameafile,Sel):-
        panel_view(nameafile,button(dir):[label(DirComp),menu(Comps..)]),
        $pathseparator(Sp),
        $buildpath(Comps,[DirComp,Sp,Sel],Path),
        not(isfile(Path,_,_)).

% common stuff for selectafile and nameafile

$openfiledialog(Dialog,Sel):-   
    not(not([$selectdir(Dir),
             defaultdir(Dir),    
             $rootdir(Root),
             $dirpath(Dir,Root,[DirComp,Comps..],Vol),
             $listentries(Entries),
             panel_view(Dialog,
                button(volume):=label(Vol),
                list(filelist):=[selection(Sel,_),top(1),contents(Entries..)],
                button(dir):=[label(DirComp),menu(Comps..)]),
             !])).

$dirmenu(Dialog,Item,Sel):-
    $rootdir([Item]),!,   % back to root directory (fails on unix)
    not(not([panel_view(selectafile,button(volume):label(Vol)),
             listvolumes(Vols),
             $pathseparator(S),
             $adddirs(Vols,S,Tree),
             $flatten_tree(Tree,Entries,[]),
             concat(Vol,S,Name),
             panel_view(Dialog,
                list(filelist):=[selection(_,Name),top(1),contents(Entries..)],
                button(dir):=[label(Item),menu()])
            ])).
    
$dirmenu(Dialog,Item,Sel):-
    not(not([panel_view(Dialog,button(dir):menu(Comps..)),
             $newcomps(Comps,Item,Newcomps),
             $pathseparator(Sp),
             $buildpath(Newcomps,[Item,Sp],Dirpath),
             defaultdir(Dirpath),    
             once($updateselectdir(Dirpath)),
             $listentries(Entries),
             panel_view(Dialog,
                list(filelist):=[selection(Sel,_),top(1),contents(Entries..)],
                button(dir):=[label(Item),menu(Newcomps..)])
            ])).

$selectopen(Dialog,Vol,Sel):-
    $pathseparator(Sp),      % possible volume
    concat(Name,Sp,Vol),
    isvolume(Name),!,
    defaultdir(Vol),
    $updateselectdir(Vol),
    !,                    % commit
    not(not([$rootdir([Root..]),
             $listentries(Entries),
             panel_view(Dialog,
                button(volume):=label('                   '),   % temp?? to clear label
                button(volume):=label(Name),
                list(filelist):=[selection(Sel,_),top(1),contents(Entries..)],
                button(dir):=[label(Name),menu(Root..)])
            ])).

$selectopen(Dialog,Dir,Sel):-
    $dirname(Dir,DDir),
    defaultdir(DDir),
    defaultdir(NDir),       % full path name ?    
    $updateselectdir(NDir),
    !,                    % commit
    not(not([$rootdir(Root),
             $dirpath(NDir,Root,[DirComp,Comps..],Vol),
             $listentries(Entries),
             panel_view(Dialog,
                list(filelist):=[selection(Sel,_),top(1),contents(Entries..)],
                button(dir):=[label(DirComp),menu(Comps..)])
            ])).

$selectopen(selectafile,File,_):-
    panel_view(selectafile,button(dir):[label(DirComp),menu(Comps..)]),
    $pathseparator(Sp),
    $buildpath(Comps,[DirComp,Sp,File],Path),
    postevent(selectafile,selectafile,Path,true).

$buildpath([Root],[Comps..],Path):- % when only root left, stop
    $rootdir([Root])->
        swrite(Path,Comps..);
        swrite(Path,Root,Comps..).
$buildpath([Comp,Comps..],[PathEl..],Path):-
    $pathseparator(Sp),
    $buildpath(Comps,[Comp,Sp,PathEl..],Path).

$newcomps([Item],Item,[Item]).
$newcomps([Item,Comps..],Item,Comps).
$newcomps([_,Comps..],Item,Newcomps):-$newcomps(Comps,Item,Newcomps).

$updateselectdir(_) :- 
    forget(selectdir(_),$local),
    fail.
$updateselectdir(Dir) :- 
    remember(selectdir(Dir),$local).

$selectdir(Dir) :-
	recall(selectdir(Dir),$local).
$selectdir(Dir) :-
	defaultdir(Dir).

$dirpath('',DL,DL,_):-!.    % nothing left
$dirpath(Dir,[Comps..],DL,Vol):-
    $pathseparator(Sp),
    substring(Dir,P,1,Sp),
    Clen is P-1,
    Clen=0->
        [Comp=Sp,Rest=Dir];   % leading separator, treat as Unix root directory
        [substring(Dir,1,Clen,Comp),
         concat(Comp,Rest,Dir)],      % remove component name
    Vol=Comp->true,     % unify volume with first component; subsequent unifications fail
    concat(Sp,SubDir,Rest),!,  % and the separator we found
    $dirpath(SubDir,[Comp,Comps..],DL,Vol).
$dirpath(Dir,[Comps..],[Dir,Comps..],Vol). % no separator, add rest as last component
$listentries(Entries):-
    get_obj(_,filetype(FTList..),$local),
    listfiles(Files),
    $addfiles(Files,FTList,Tree),
    listdirectories(Dirs),
    $pathseparator(S),
    $adddirs(Dirs,S,Tree),
    $flatten_tree(Tree,Entries,[]),    
    !.

$addfiles([],_,_).
$addfiles([File,Files..],FTList,Tree):-
    $filter_file(File,FTList),
    File = Key, 		% uppercase(File,Key),
    $fbtree(File,Key,Tree),
    $addfiles(Files,FTList,Tree).
$addfiles([File,Files..],FTList,Tree):-
    $addfiles(Files,FTList,Tree).
    
$adddirs([],_,_).
$adddirs([Dir,Dirs..],S,Tree):-
    concat(Dir,S,Name),
    Name = Key,			% uppercase(Name,Key),
    $fbtree(Name,Key,Tree),
    $adddirs(Dirs,S,Tree).

$filter_file(_,_):-$unix,!.
$filter_file(File,FTList):-
    isfile(File,_,FT),
    $symember(FT,FTList),
    !.
    
% insert Key,Name in binary tree based on key
$fbtree(Name,Key,Tree):-    % leaves initially vars
    var(Tree),!,
    Tree=tree(Left,Name,Key,Right).
$fbtree(Name,Key,tree(Left,TName,TKey,Right)):-
%    $globalstack(7),
    breadth_first_compare(Key,TKey,@<),!,
    $fbtree(Name,Key,Left).                     % left hand branch
$fbtree(Name,Key,tree(Left,TName,TKey,Right)):- % right hand branch,assumes no duplicates
    $fbtree(Name,Key,Right).

% flatten binary tree back into a list
$flatten_tree(0,L,L):-!.   % reached leaf if tree can be unified with 0
$flatten_tree(tree(Left,Name,Key,Right),L,DL):-
    $flatten_tree(Left,L,[Name,Rs..]),
    $flatten_tree(Right,Rs,DL).

$symember(X,[X,_..]):-  /* symbol(X), */!.
$symember(X,[_,Xs..]):-$symember(X,Xs).

/*-----------------------------------------------------------------------------
    selectone dialog
*/
panel_definition(selectone,
    pos(146,52),
    size(309,258),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on)),
    button(name(cancel),place(172,212,240,236),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name(ok),place(64,208,132,236),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    list(name(selectlist),place(28,32,276,196),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    field(name(message),place(28,8,276,28),pre(''),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset())).

selectone(Title,Choicelist,Selection,Initial..):-
    $dialogok(selectone),  % claim dialog flag
    $selection(selectone,Initial,Sel),
    $dialogloop(selectone,Result,Goal,field(message):=Title,
                list(selectlist):=[contents(Choicelist..),selection(Sel..)]),
    !,        % commit
    Selection=Result,
    Goal.

$selection(selectone,[],[1,_]).
$selection(selectone,[Item],[_,Item]).

panel_event(selectone,click,button(cancel)):-
    postevent(selectone,selectone,_,fail).

panel_event(selectone,click,button(ok)):-
    panel_view(selectone,list(selectlist):selection(_,Name)),
    $selectone(Name).

panel_event(selectone,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(selectlist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(selectone,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(selectlist),Place,Contents,selection(I0,S0),Ps..)):-
    % I1\=I0 - update selection
    panel_view(selectone,list(selectlist):=selection(I1,S1)),
    dispatch_panel_event(selectone,update(selection(I0,S0)),
                   list(name(selectlist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(selectone,update(selection(OldI,OldS)),	  % only allow single selection
			list(name(selectlist),Place,Contents,selection(NewI,NewS),_..)) :-
	list(NewI),
	!,
	panel_view(selectone,list(selectlist):=selection(OldI,OldS)).

panel_event(selectone,doubleclick(_,_,selection(_,Name)),list(selectlist)):-
    $selectone(Name).

panel_event(selectone,keystroke(Key,Mods),_):-    % other key
    $keylist(selectone,selectlist,Key,10).

$legal_selection(selectone,Sel).

$selectone(Name):-
    postevent(selectone,selectone,Name,true).

/*-----------------------------------------------------------------------------
    select dialog
*/
panel_definition(select,
    pos(146,52),
    size(309,258),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on)),
    button(name(cancel),place(172,212,240,236),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name(ok),place(64,208,132,236),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    list(name(selectlist),place(28,32,276,196),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    field(name(message),place(28,8,276,28),pre(''),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset())).

select(Title,Choicelist,Selection,Initial..):-
    $dialogok(select),  % claim dialog flag
    $selection(select,Initial,Sel),
    $dialogloop(select,Result,Goal,field(message):=Title,
                 list(selectlist):=[contents(Choicelist..),selection(Sel..)]),
    !,        % commit
    Selection=Result,
    Goal.

$selection(select,[],[1,_]).
$selection(select,[Item],[_,Item]).
$selection(select,[Items..],[_,Items]).

panel_event(select,click,button(cancel)):-
    postevent(select,select,_,fail).

panel_event(select,click,button(ok)):-
    panel_view(select,list(selectlist):selection(_,Name)),
    $select(Name).

panel_event(select,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(selectlist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(select,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(selectlist),Place,Contents,selection(I0,S0),Ps..)):-
    % I1\=I0 - update selection
    panel_view(select,list(selectlist):=selection(I1,S1)),
    dispatch_panel_event(select,update(selection(I0,S0)),
                   list(name(selectlist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(select,doubleclick(_,_,selection(_,Name)),list(selectlist)):-
    $select(Name).

panel_event(select,keystroke(Key,Mods),_):-    % other key
    $keylist(select,selectlist,Key,10).

$legal_selection(select,Sel).

$select(Name):-
    list(Name),
    !,
    postevent(select,select,Name,true).

$select(Name):-
    postevent(select,select,[Name],true).

/*-----------------------------------------------------------------------------
    message dialog
*/

$dialog_panel_contents(message, Text,
    [pos(71,75), size(492,WH),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on))],
    [field(name(message),place(12,12,408,FBottom),pre(Text),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset()),
    button(name(ok),place(416,8,484,32),style(designate),label('OK'),state(off),font(0,12),icon(0),menu())]) :-
	Width is 408-12-3-2,			% yanzhou@bnr.ca:12/07/96 modified
                                                % was 408-12-3
	$textlinesize(Text,0,12,Width,Lines),
	isfont(0,12,_,[A,D,L,_]),
	LineHeight is A+D+L,
	WH is Lines*LineHeight + D + 24,
	FBottom is WH - 2.
	

message(Text):-
    symbol(Text),
	$dialog_panel_contents(message,Text,Windef,Contents),
    $dialogok(message),  % claim dialog flag
	not(not(panel_create(message,Windef,Contents))),
    $dialogloop(message,_,_),
    !.        % commit

panel_event(message,click,button(ok)):-
    postevent(message,message,_,true).

/*------------------------------------------------------------------------------
    confirm dialog
*/

$dialog_panel_contents(confirm,Prompt,Cancel_enabled,Default,
    [pos(119,50), size(402,WH),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on))],
	[field(name(message),place(20,20,372,FBottom),pre(Prompt),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset()),
    button(name(cancel),place(292,BTop,372,BBottom),style(CancelStyle),label('CANCEL'),state(CancelState),font(0,12),icon(0),menu()),
    button(name(no),place(128,BTop,208,BBottom),style(NoStyle),label('NO'),state(off),font(0,12),icon(0),menu()),
    button(name(yes),place(20,BTop,100,BBottom),style(YesStyle),label('YES'),state(off),font(0,12),icon(0),menu())]) :-
	$enabled(Cancel_enabled,CancelState),
	$designate('YES',Default,YesStyle),
	$designate('NO',Default,NoStyle),
	$designate('CANCEL',Default,CancelStyle),
	!,
	[CancelState,CancelStyle]\=[disable,designate],
	Width is 372-20-3,
	$textlinesize(Prompt,0,12,Width,Lines),
	isfont(0,12,_,[A,D,L,_]),
	LineHeight is A+D+L,
	WH is Lines*LineHeight + D + 69,
	FBottom is WH - 47,   %%% RWW was 49
	BTop is FBottom + 12,
	BBottom is BTop + 20.

confirm(Prompt,Cancel_enabled,Default,Response):-
    symbol(Prompt),
	$dialog_panel_contents(confirm,Prompt,Cancel_enabled,Default,Windef,Contents),
    $dialogok(confirm),  % claim dialog flag
	not(not(panel_create(confirm,Windef,Contents))),
    $dialogloop(confirm,Result,Goal),
    !,          % message
    Response=Result,
    Goal.

$enabled('YES',off).
$enabled('NO',disable).
$designate(X,X,designate):-!.
$designate(X,Y,standard).

$textlinesize(Prompt,Font,Size,Width,Lines) :-
	openwindow(graf,$$temp,_,_,options(hidden)),
	dograf($$temp,[textfont(Font),textsize(Size)]),
	inqgraf($$temp,textlines(Prompt,Width,Lines)),
	closewindow($$temp).

panel_event(confirm,click,button(yes)):-
    postevent(confirm,confirm,'YES',true).
    
panel_event(confirm,click,button(no)):-
    postevent(confirm,confirm,'NO',true).
    
panel_event(confirm,click,button(name(cancel),Pl,St,L,state(S),_..)):-
    S\=disable,
    postevent(confirm,confirm,_,fail).

/*------------------------------------------------------------------------------
    query dialog
*/
    
$dialog_panel_contents(query, Prompt, Default,
    [pos(119,50), size(402,WH),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on))],
    [button(name(cancel),place(292,BTop,372,BBottom),style(standard),label('CANCEL'),state(off),font(0,12),icon(0),menu()),
    button(name(ok),place(20,OKBTop,100,OKBBottom),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    field(name(query),place(20,QTop,372,QBottom),pre(''),selection(Default),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\r')),
    field(name(message),place(20,12,372,MBottom),pre(Prompt),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset())]) :-
	Width is 372-20-3,
	$textlinesize(Prompt,0,12,Width,Lines),
	isfont(0,12,_,[A,D,L,_]),
	LineHeight is A+D+L,
	WH is Lines*LineHeight + D + 90,
	MBottom is WH - 76,     %%% RWWW was 78
	QTop is MBottom + 8,
	QBottom is QTop + 20,
	BTop is QBottom + 12,
	BBottom is BTop + 20,
	OKBTop is BTop - 4,
	OKBBottom is BBottom + 4.

query(Prompt,Default,Response):-
    symbol(Prompt,Default),
	$dialog_panel_contents(query, Prompt, Default, Windef, Contents),
    $dialogok(query),  % claim dialog flag
	not(not(panel_create(query,Windef,Contents))),
    $dialogloop(query,Result,Goal),
    !,          % commit
    Response=Result,
    Goal.

panel_event(query,open):-   % on open, put user in field(query) edit 
    once(panel_view(query,field(name(query),Rest..))),
    dispatch_panel_event(query,click(_,_),field(name(query),Rest..)).

panel_event(query,click,button(ok)):-
    panel_view(query,field(query):Response),
    postevent(query,query,Response,true).
    
panel_event(query,click,button(name(cancel),Pl,St,L,state(S),_..)):-
    postevent(query,query,_,fail).

/*-----------------------------------------------------------------------------
    queryfind dialog

*/
    
panel_definition(queryfind,
    pos(333,565),
    size(398,200),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on)),
    button(name(cancel),place(280,168,384,188),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name(find),place(20,164,120,188),style(designate),label('Find'),state(off),font(0,12),icon(0),menu()),
    button(name(dir),place(20,92,160,116),style('check box'),label('Search Backwards'),state(off),font(0,12),icon(0),menu()),
    button(name(case),place(20,124,144,140),style('check box'),label('Case Sensitive'),state(off),font(0,12),icon(0),menu()),
    field(name(findstring),place(20,44,368,72),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\r')),
    field(name(field1),place(20,16,104,36),pre('Find what?'),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset())).

queryfind([Find,Case,Dir],Response) :-
    symbol(Find),
	$case(Case,CaseState),
	$dir(Dir,DirState),
    $dialogok(queryfind),  % claim dialog flag
    $dialogloop(queryfind,Result,Goal,field(findstring):=Find,
			button(case):=CaseState,button(dir):=DirState),
    !,          % commit
    Response=Result,
    Goal.

panel_event(queryfind,open):-   % on open, put user in field(query) edit 
    once(panel_view(queryfind,field(name(findstring),Rest..))),
    dispatch_panel_event(queryfind,click(_,_),field(name(findstring),Rest..)).

panel_event(queryfind,click,button(find)):-
    panel_view(queryfind,field(findstring):Find,button(case):CaseState,button(dir):DirState),
	$case(Case,CaseState),
	$dir(Dir,DirState),
    postevent(queryfind,queryfind,[Find,Case,Dir],true).
    
panel_event(queryfind,click,button(name(cancel),Pl,St,L,state(S),_..)):-
    postevent(queryfind,queryfind,_,fail).

$case(yes, on).
$case(no,  off).

$dir(backward, on).
$dir(forward,  off).

/*-----------------------------------------------------------------------------------
    queryreplace dialog

*/
    
panel_definition(queryreplace,
    pos(171,518),
    size(399,232),
    options(style(dialog),background(white,white),picture(),lock(on),dialog(on),grid(4,4),dirty(on)),
    button(name(find),place(232,204,308,224),style(standard),label('Find'),state(off),font(0,12),icon(0),menu()),
    button(name(replaceall),place(108,204,192,224),style(standard),label('Replace All'),state(off),font(0,12),icon(0),menu()),
    button(name(replace),place(8,200,96,224),style(designate),label('Replace'),state(off),font(0,12),icon(0),menu()),
    button(name(cancel),place(320,204,388,224),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    button(name(case),place(24,172,148,188),style('check box'),label('Case Sensitive'),state(off),font(0,12),icon(0),menu()),
    button(name(dir),place(24,144,164,168),style('check box'),label('Search Backwards'),state(off),font(0,12),icon(0),menu()),
    field(name(replacestring),place(20,100,372,128),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\r')),
    field(name(field2),place(24,80,132,100),pre('Replace with?'),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset()),
    field(name('Find what?'),place(24,16,108,36),pre('Find what?'),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset()),
    field(name(findstring),place(20,36,372,64),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\r'))).

queryreplace([Find,Repl,Case,Dir],Response,Function) :-
    symbol(Find,Repl),
	$case(Case,CaseState),
	$dir(Dir,DirState),
    $dialogok(queryreplace),  % claim dialog flag
    $dialogloop(queryreplace,Result,Goal,field(findstring):=Find,
								field(replacestring):=Repl,
								button(case):=CaseState,
								button(dir):=DirState),
    !,          % commit
    [Response,Function]=Result,
    Goal.

panel_event(queryreplace,open):-   % on open, put user in field(findstring) edit 
    once(panel_view(queryreplace,field(name(findstring),Rest..))),
    dispatch_panel_event(queryreplace,click(_,_),field(name(findstring),Rest..)).

panel_event(queryreplace,click,button(replace)):-
    panel_view(queryreplace,field(findstring):Find,field(replacestring):Repl,button(case):CaseState,button(dir):DirState),
	$case(Case,CaseState),
	$dir(Dir,DirState),
    postevent(queryreplace,queryreplace,[[Find,Repl,Case,Dir],replace],true).
    
panel_event(queryreplace,click,button(replaceall)):-
    panel_view(queryreplace,field(findstring):Find,field(replacestring):Repl,button(case):CaseState,button(dir):DirState),
	$case(Case,CaseState),
	$dir(Dir,DirState),
    postevent(queryreplace,queryreplace,[[Find,Repl,Case,Dir],replaceall],true).
    
panel_event(queryreplace,click,button(find)):-
    panel_view(queryreplace,field(findstring):Find,field(replacestring):Repl,button(case):CaseState,button(dir):DirState),
	$case(Case,CaseState),
	$dir(Dir,DirState),
    postevent(queryreplace,queryreplace,[[Find,Repl,Case,Dir],find],true).
    
panel_event(queryreplace,click,button(name(cancel),Pl,St,L,state(S),_..)):-
    postevent(queryreplace,queryreplace,_,fail).

/*----------------------------------------------------------------------------
    queryformat dialog

*/
    
panel_definition(queryformat,
    pos(232,604),
    size(403,211),
    options(style(dialog),background(white,white),picture(),lock(off),dialog(on),grid(4,4),dirty(on)),
    field(name(tabs),place(296,60,340,80),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\r')),
    field(name(field3),place(248,60,296,80),pre('Tabs:'),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset(enter,'\r')),
    button(name(totabs),place(232,132,384,156),style(standard),label('Tabs << Spaces'),state(off),font(0,12),icon(0),menu()),
    button(name(tospaces),place(232,100,384,124),style(standard),label('Tabs >> Spaces'),state(off),font(0,12),icon(0),menu()),
    button(name(cancel),place(264,168,356,196),style(standard),label('Cancel'),state(off),font(0,12),icon(0),menu()),
    list(name(sizelist),place(176,68,216,156),contents(),selection(0,''),top(1),style(rectangle),font(0,12)),
    field(name(field2),place(176,16,224,33),pre('Size'),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset(enter,'\r')),
    field(name(field1),place(24,16,88,36),pre('Font'),selection(''),post(''),top(0),font(0,12),lock(on),lines(off),style(transparent),menu(),exitset(enter,'\r')),
    field(name(size),place(176,40,216,60),pre(''),selection(''),post(''),top(0),font(0,12),lock(off),lines(off),style(rectangle),menu(),exitset(enter,'\r')),
    button(name(ok),place(44,168,140,200),style(designate),label('OK'),state(off),font(0,12),icon(0),menu()),
    list(name(fontlist),place(24,40,164,156),contents(),selection(0,''),top(1),style(rectangle),font(0,12))).

queryformat(InSpec,OutSpec,Convert) :-
	InSpec = [Font,Size,Tabs],
	integer(Size,Tabs),
	isfont(Font,_,Name,_),
	listsizes(Font,Sizes),
	listfonts(Fonts),
	$fontnames(Fonts,FontNames),
	arg(SizeIx,Sizes,Size);SizeIx=0,
	arg(FontIx,FontNames,Name);FontIx=0,
	cut,
    $dialogok(queryformat),  % claim dialog flag
	swrite(TabsStr,Tabs),swrite(SizeStr,Size),
	$dialogloop(queryformat,Result,Goal,field(size):=SizeStr,
		field(tabs):=TabsStr,
		list(sizelist):=[top(SizeIx),selection(SizeIx,_),contents(Sizes..)],
		list(fontlist):=[top(FontIx),selection(FontIx,_),contents(FontNames..)]),
	!,
	[OutSpec,Convert]=Result,
	Goal.

$fontnames([],[]).
$fontnames([F,Fs..],[N,Ns..]) :-
	isfont(F,_,N,_);F=N,
	!,
	$fontnames(Fs,Ns).

panel_event(queryformat,open):-   % on open, put user in field(size) edit 
    once(panel_view(queryformat,field(name(size),Rest..))),
    dispatch_panel_event(queryformat,click(_,_),field(name(size),Rest..)).

panel_event(queryformat,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(fontlist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(queryformat,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(fontlist),Place,Contents,selection(I0,S0),Ps..)):-
    % I1\=I0 - update selection
    panel_view(queryformat,list(fontlist):=selection(I1,S1)),
    dispatch_panel_event(queryformat,update(selection(I0,S0)),
                   list(name(fontlist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(queryformat,update(selection(OldI,OldS)),	  % only allow single selection
			list(name(fontlist),Place,Contents,selection(NewI,NewS),_..)) :-
	list(NewI),
	!,
	not(not(panel_view(queryformat,list(fontlist):=selection(OldI,OldS)))).

panel_event(queryformat,update(selection(OldI,OldS)),	  % only allow single selection
			list(name(fontlist),Place,Contents,selection(NewI,Font),_..)) :-
	listsizes(Font,Sizes),
	panel_view(queryformat,field(size):SizeStr),
	$integersym(SizeStr,Size),
	!,
	not(not(panel_view(queryformat,list(sizelist):=[contents(Sizes..),selection(_,Size)]))).


panel_event(queryformat,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(sizelist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(queryformat,select(X,Y,selection(I1,S1)),   % override default to prevent drag
            list(name(sizelist),Place,Contents,selection(I0,S0),Ps..)):-
    % I1\=I0 - update selection
    panel_view(queryformat,list(sizelist):=selection(I1,S1)),
    dispatch_panel_event(queryformat,update(selection(I0,S0)),
                   list(name(sizelist),Place,Contents,selection(I1,S1),Ps..)).

panel_event(queryformat,update(selection(OldI,OldS)),	  % only allow single selection
			list(name(sizelist),Place,Contents,selection(NewI,NewS),_..)) :-
	list(NewI),
	!,
	not(not(panel_view(queryformat,list(sizelist):=selection(OldI,OldS)))).

panel_event(queryformat,update(selection(OldI,OldS)),	  % keep size list and field in sync
			list(name(sizelist),Place,Contents,selection(NewI,NewS),_..)) :-
	NewI\=0,
	swrite(NewSStr,NewS),
	not(not(panel_view(queryformat,field(size):=NewSStr))).

panel_event(queryformat,update(Prev..),field(name(size),P,Value..)) :-
	$integerfield(Value,New)
	-> not(not(panel_view(queryformat,list(sizelist):=selection(_,New))))
	; [beep,not(not(panel_view(queryformat,field(size):=Prev)))].

panel_event(queryformat,update(Prev..),field(name(tabs),P,Value..)) :-
	$integerfield(Value,New)
	-> [beep,panel_view(queryformat,field(tabs):=Prev)].

panel_event(queryformat,click,button(ok)):-
    panel_view(queryformat,field(tabs):TabsStr,field(size):SizeStr,list(fontlist):selection(_,Font)),
	$integersym(SizeStr,Size),
	$integersym(TabsStr,Tabs),
    postevent(queryformat,queryformat,[[Font,Size,Tabs],_],true).
    
panel_event(queryformat,click,button(tospaces)):-
    panel_view(queryformat,field(tabs):TabsStr,field(size):SizeStr,list(fontlist):selection(_,Font)),
	$integersym(SizeStr,Size),
	$integersym(TabsStr,Tabs),
    postevent(queryformat,queryformat,[[Font,Size,Tabs],tospaces],true).
    
panel_event(queryformat,click,button(totabs)):-
    panel_view(queryformat,field(tabs):TabsStr,field(size):SizeStr,list(fontlist):selection(_,Font)),
	$integersym(SizeStr,Size),
	$integersym(TabsStr,Tabs),
    postevent(queryformat,queryformat,[[Font,Size,Tabs],totabs],true).
    
panel_event(queryformat,click,button(name(cancel),Pl,St,L,state(S),_..)):-
    postevent(queryformat,queryformat,_,fail).

$integerfield(Value,Int) :-
	$fieldval(Value,Sym),		% in field_class
	$integersym(Sym,Int).

$integersym(Sym,Int) :-
	concat(Sym,'.',Term),
	sread(Term,Int),
	integer(Int).

