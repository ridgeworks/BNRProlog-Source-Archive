/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/windows.p,v 1.2 1996/08/28 10:55:11 harrisj Exp $
*
*  $Log: windows.p,v $
 * Revision 1.2  1996/08/28  10:55:11  harrisj
 * Modified renamewindow to check if window is console then update console name as well.
 *
 * Revision 1.1  1995/09/22  11:29:13  harrisja
 * Initial version.
 *
*
*/

%
%   Window table stores 
%       window( Name, Type, Id, Visibility, Fname, Op, Reopenstream )
%   in state space.
%
%   Primitives operate on window ids.
%   All parameter type checking is done here.
%   Also window name uniqueness is checked here.
%
%   Required primitives:
%       $activewindow(?Id)
%       $closewindow(+Id)
%       $hidewindow(+Id)
%       $openwindow(+Name,+Type,-Id,?LeftEdge,?TopEdge,?Width,?Height,+Options)
%       $positionwindow(+Id,?LeftEdge,?TopEdge)
%       $showwindow(+Id),
%       $sizewindow(+Id,?Width,?Height)
%		$renamewindow(+Id,+NewName)
%
%	$changedtext(+Id)
%	$savetext(+Id)
%	$reloadtext(+Id)
%	$retargettext(+Id, +Name)
%     

activewindow(Name, Type) :- % set active window
    symbol(Name, Type),
    get_obj(Op,window(Name, Type, Id, Visibility, Etc..), $local),
    Visibility @= hidden
    -> [$showwindow(Id),
		$wait_for_update(Name,Type,visible,_,_),
        put_obj(Op,window(Name, Type, Id, visible, Etc..),$local)], 
    !,
    $activewindow(Id).

activewindow(Name, Type) :- % query active window
    $activewindow(Id),
    get_obj(Op,window(Name, Type, Id, _..), $local).

closewindow(Name) :- 
    symbol(Name),
    get_obj(Op,window(Name, Type, Id, _, FName, Op, Reopen), $local),
    dispose_obj(Op,$local),
    $reopenstream(Reopen,FName),
	$remove_window(Name,Type),
	$remove_menu_bar(Id),
	forget(undo(Name,_..),$local)->true,
    $closewindow(Id).

$reopenstream(true,Fname) :-
    % did this closed window have a stream open to it ??
    get_obj(Obj, stream$(Stream, FileP, Name, IMode, Fname), $local),
    % YES, so determine where we are
    $at(FileP, Pos),
    % get a new mode for the file
    $modifymode(IMode, NewMode),
    % reopen the file
    $openfile(NewMode,Fname,NewFileP,_),
    % seek back to where we last were
    $seek(NewFileP, Pos),
    % AND replace the stream pointer to new stream
    put_obj(Obj, stream$(Stream, NewFileP, Name, NewMode, Fname), $local),
    !.
$reopenstream(false,Fname) :-
    forget(stream$(Stream, FileP, Name, IMode, Fname), $local),
	!.
$reopenstream(_,_).

$modifymode(read_window, read_only) :- !.
$modifymode(read_write_window, read_write) :- !.
$modifymode(Mode, Mode).

hidewindow(Name) :-
    symbol(Name),
    get_obj(Op,window(Name, Type, Id, Visibility, Etc..), $local),
    Visibility @= visible
    -> [$hidewindow(Id),
        put_obj(Op,window(Name, Type, Id, hidden, Etc..),$local)].

iswindow(Name, Type, Visibility) :-
    recall(window(Name, Type, _, Visibility, _..),$local).

iswindow(Name, text, Visibility, Fname) :-
    recall(window(Name, text, _, Visibility, Fname, _..),$local).

iswindow(Name, graf, Visibility, nil) :-
    recall(window(Name, graf, _, Visibility, _..),$local).

$istextwindow(Name, Fname, Id) :-
    recall(window(Name, text, Id, _, Fname, _..), $local).

prologwindows(WindowList) :-
    findall(W,iswindow(W,_,_),WindowList).

listwindows(WindowList) :-
    findall(W,iswindow(W,_,_),WindowList).

openwindow(text, Name, Pos, Size, Options) :-
    $windowname(text,Name),
	!,
    Pos = pos(LeftEdge, TopEdge),
    Size = size(Width, Height),
    Options = options(OptionList..),
    $int_or_var(LeftEdge, TopEdge),
	$int_or_var(Width, Height),
    $open_options(OptionList..),
    !,
	fullfilename(Name,Fname),
    $openwindow(Name,text,Id,LeftEdge,TopEdge,Width,Height,OptionList,Fname,DummyMenuPtr),  % NEW 09/06/95 Now we also get the ID of the dummy menu
    !,
    $window_visibility(OptionList,Visibility), 
    new_obj(window(Name, text, Id, Visibility, Fname, _), Op, $local),
    $update_stream(Fname, Id, Reopen),
    put_obj(Op, window(Name, text, Id, Visibility, Fname, Op, Reopen), $local),
    	$initialize_dummy_menu(Name,DummyMenuPtr),	% NEW 09/06/95 Install the dummy menu in Prolog
	$wait_for_update(Name,text,Visibility,LeftEdge,TopEdge),
	$add_pde_menus(Name,OptionList),
	$add_new_window(Name,text).

$add_pde_menus(Name,OptionList) :-
	$member(nopdemenus,OptionList),!.
$add_pde_menus(Name, OptionList) :-
	$install_pde_menus(Name, OptionList).

$update_stream(Fname, Id, true) :-
    % does this new window already have a stream open to it ??
    get_obj(Obj, stream$(Stream, FileP, Name, IMode, Fname), $local),
    % YES, so close the stream
    $close(FileP, _),
    $window_io_proc(WinProc),
    % AND replace the stream pointer to our window procedure
    put_obj(Obj, stream$(Stream,[Id, WinProc], Name, IMode, Fname), $local),
    !.
$update_stream(_, _, false).

openwindow(graf, Name, Pos, Size, Options) :-
    $windowname(graf,Name),
	!,
    Pos = pos(LeftEdge, TopEdge),
    Size = size(Width, Height),
    Options = options(OptionList..),
    $int_or_var(LeftEdge, TopEdge),
	$int_or_var(Width, Height),
    $open_options(OptionList..),
    !,
    $openwindow(Name,graf,Id,LeftEdge,TopEdge,Width,Height,OptionList,Name, DummyMenuPtr),  % NEW 09/06/95 Now we also get the ID of the dummy menu
    $getgc(Id,GC),
    !,
    $window_visibility(OptionList,Visibility), 
    new_obj(window(Name, graf, Id, Visibility, [GC,-1,0,0,1,1,0,0,0], _), Op, $local),
    put_obj(Op, window(Name, graf, Id, Visibility, [GC,-1,0,0,1,1,0,0,0], Op, false), $local),
    	$initialize_dummy_menu(Name,DummyMenuPtr),	% NEW 09/06/95 Install the dummy menu in Prolog
	$add_new_window(Name,graf),
	$wait_for_update(Name,graf,Visibility,LeftEdge,TopEdge).

positionwindow(Name, LeftEdge, TopEdge) :-
    symbol(Name),
    get_obj(Op,window(Name, Type, Id, _..), $local),
    $int_or_var(LeftEdge, TopEdge),
    cut,
    $positionwindow(Id,LeftEdge,TopEdge).

%% New Sizewindow from Oz 16/05/95
sizewindow(Name, Width, Height) :-
    symbol(Name),
    get_obj(Op,window(Name, Type, Id, _..), $local),
    var(Width,Height),
    mbarheight(Name, MbHeight),
    cut,
    $sizewindow(Id,Width, RHeight),
    Height is RHeight - MbHeight,!.
    
sizewindow(Name, Width, Height) :-
    symbol(Name),
    get_obj(Op,window(Name, Type, Id, _..), $local),
    integer(Width,Height),
    mbarheight(Name, MbHeight),
    RHeight is Height + MbHeight,
    cut,
    $sizewindow(Id,Width, RHeight).
/*
sizewindow(Name, Width, Height) :-
    symbol(Name),
    get_obj(Op,window(Name, Type, Id, _..), $local),
    $int_or_var(Width, Height),
    cut,
    $sizewindow(Id,Width, Height).
*/
renamewindow(Name, NewName) :-
	symbol(Name,NewName),
	get_obj(Op,window(Name, Type, Id, Etc..), $local), 
	cut,
	$renamewindow(Id,NewName),
	put_obj(Op,window(NewName, Type, Id, Etc..), $local),
	$updateConsoleName(Name, NewName),
	postevent(userrename,NewName,Name,Type).

$updateConsoleName(Name, NewName) :-
         $console(Name),
         $newConsoleName(NewName), !.
$updateConsoleName(_, _).

changedtext(Name) :-
    symbol(Name),
    get_obj(Op,window(Name, text, Id, _..), $local),
    $changedtext(Id).

savetext(Name) :-
    symbol(Name),
    get_obj(Op,window(Name, text, Id, _..), $local),
    $savetext(Id).

reloadtext(Name) :-
    symbol(Name),
    get_obj(Op,window(Name, text, Id, _..), $local),
    $reloadtext(Id).

retargettext(Window,FName) :-
    symbol(Window),
	fullfilename(FName, FileName),
    get_obj(Op,window(Window, text, Id, V, F, Etc..), $local),
    $retargettext(Id,FileName),
	put_obj(Op,window(Window, text, Id, V, FileName, Etc..), $local),
	renamewindow(Window,FName).

$windowname(graf,Name) :-
    symbol(Name),
    !,
    not(get_obj(Op,window(Name, _..), $local)).
$windowname(graf,Name) :-
    var(Name),
    integer_range(X,1,99),
    swrite(Name, 'Untitled', X),
    not(get_obj(Op,window(Name, _..), $local)),
    cut.

$windowname(text,Name) :-
    symbol(Name),
    !,
    not(get_obj(Op,window(Name, _..), $local)),
    isfile(Name,_,_)
    ; $create(Name),
    cut.
$windowname(text,Name) :-
    var(Name),
    integer_range(X,1,99),
    swrite(Name, 'Untitled', X),
    not(get_obj(Op,window(Name, _..), $local)),
    not(isfile(Name,_,_)),
    cut,
    $create(Name).

$window_visibility(OptionList,hidden) :-
    $member(hidden,OptionList),!.
$window_visibility(_,visible).

$wait_for_update(Window,graf,visible,PX,PY) :-
	repeat,
		userevent(Ev,W,X,Y,noblock),
		$$wait_for_event(userupdate,Ev,W,X,Y,Window),
	!,
	positionwindow(Window,PX,PY).
$wait_for_update(Window,text,visible,PX,PY) :-
	repeat,
		userevent(Ev,W,X,Y,noblock),
		$$wait_for_event(useractivate,Ev,W,X,Y,Window),
	!,
	positionwindow(Window,PX,PY).
$wait_for_update(_,_,_,_,_).

$$wait_for_event(Ev,Ev,W,X,Y,W) :-
	nextevent(Ev,W,X,Y),!.
$$wait_for_event(Ev,NotEv,W,X,Y,_) :-
	NotEv(W,X,Y),
	failexit.

$create(Name) :-
    open(S,Name,read_write,0),
    close(S,0).

$int_or_var().
$int_or_var(X,Xs..) :-
    integer(X),
    !,
	integer(Xs..).
$int_or_var(Xs..) :-
    var(Xs..). 

$open_options().
$open_options(Opt,Opts..) :-
    $open_option(Opt),
    $open_options(Opts..).

$open_option(menubar).
$open_option(nomenubar).
$open_option(closebox).
$open_option(vscroll).
$open_option(hscroll).
$open_option(msgbutton).
$open_option(noclosebox).
$open_option(novscroll).
$open_option(nohscroll).
$open_option(nomsgbutton).
$open_option(documentproc).
$open_option(dboxproc).
$open_option(namedboxproc).
$open_option(plaindbox).
$open_option(altdboxproc).
$open_option(nogrowdocproc).
$open_option(rdocproc).
$open_option(zoomdocproc).
$open_option(zoomnogrow).
$open_option(hidden).
$open_option(visible).
$open_option(read_only).
$open_option(read_write).
$open_option(front).
$open_option(back).
$open_option(pdemenus).
$open_option(nopdemenus).

localglobal(W,X,Y,Gx,Gy) :-
    symbol(W),
    get_obj(Op,window(W, graf, Id, _..), $local),
	$localglobal(Id,X,Y,Gx,Gy).

invalidrect(W,L,T,R,B) :-
    symbol(W),
    get_obj(Op,window(W, graf, Id, _..), $local),
	integer(L,T,R,B),
    L =< R,
    T =< B,
	$invalidrect(Id,L,T,R,B).

validrect(W,L,T,R,B) :-
    symbol(W),
    get_obj(Op,window(W, graf, Id, _..), $local),
	integer(L,T,R,B),
    L =< R,
	T =< B,
	$validrect(Id,L,T,R,B).

setcursor(Cursor) :-
	!,
	$activewindow(W),
	$setcursor(W,Cursor).
setcursor(Name, Cursor) :-
	symbol(Name),
	get_obj(_, window(Name, Type, W, _..), $local),
	$setcursor(W,Cursor).

window_id(Name, W) :-
	symbol(Name),
	recall(window(Name,Type,W,_..),$local),
	!.

window_id(Name, W, GC) :-
	symbol(Name),
	recall(window(Name,Type,W,_,GC,_..),$local).

$setgc(W,GC) :-
	get_obj(Op,window(Name,graf,W,V, _,Etc..),$local),
	put_obj(Op,window(Name,graf,W,V,GC,Etc..),$local).

scrndimensions(W,H) :-
	$scrndimensions(W,H).
scrndimensions(W,H,main) :-
	$scrndimensions(W,H).

quit :-
	iswindow(W,_,_),
	once(userclose(W,_,_)
	;$cancel_quit),
	fail.

$cancel_quit :-
	$console(Console),
	iswindow(W,text,visible)
	; activewindow(Console,text)
	; openwindow(text,Console,_,_,options()),
	failexit(quit).

$openfile(read_window, FileName, [FileP, FileProc], IOResult) :-
	$openfile_window(FileName,FileP,options(read_only),IOResult),
	$window_io_proc(FileProc).
$openfile(read_write_window, FileName, [FileP, FileProc], IOResult) :-
	$openfile_window(FileName,FileP,options(read_write),IOResult),
	$window_io_proc(FileProc).

$openfile_window(FileName, FileP, _, 0) :-
	fullfilename(FileName, FFileName),
	$istextwindow(_, FFileName, FileP),
	!.
$openfile_window(FileName, FileP, options(Opts..), 0) :-
	openwindow(text,FileName,_,_,options(Opts..)),
	!,
	$istextwindow(FileName, _, FileP).
$openfile_window(_, _, _, -210).

$leaveonewindowvisible :-
	iswindow(_,_,visible),
	!.
$leaveonewindowvisible :-
	confirm("There are now no visible windows for Prolog, so you will not be able to control Prolog any longer. Would you like to quit Prolog?", 'YES', 'YES', R),
	R = 'YES',
	$console(W), 
	postevent(menuselect, W, 'File', 'Quit'),
	!.
$leaveonewindowvisible :-			% in case the user selects no or cancel
	block(quit, $cancel_quit).		% in a block since cancel_quit does a failexit
