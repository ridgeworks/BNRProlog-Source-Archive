/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/filemenu.p,v 1.1 1995/09/22 11:24:20 harrisja Exp $
*
*  $Log: filemenu.p,v $
 * Revision 1.1  1995/09/22  11:24:20  harrisja
 * Initial version.
 *
*
*/
/*
 *   FileMenu
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1989, 1990, 1991
 */

installmenu(W,'File',Opts) :-
	addmenu(W, 'File', 'File', 0),
	additem(W,'Open...', [command('O')], 'File', end_of_menu, _),
	additem(W,'New...', [command('N')], 'File', end_of_menu, _),
	$file_closeable(Opts,Closeable),
	additem(W,'Close', [command('W'),Closeable], 'File', end_of_menu, _),
	$file_writeable(Opts,Writeable),
	additem(W,'Save', [command('S'),Writeable], 'File', end_of_menu, _),
	additem(W,'Save as...', [Closeable], 'File', end_of_menu, _),
	additem(W,'Save a Copy as...', [], 'File', end_of_menu, _),
	additem(W,'Revert to Saved', [], 'File', end_of_menu, _),
	additem(W,'Print Window', [command('P')], 'File', end_of_menu, _),
	additem(W,'Rename...', [], 'File', end_of_menu, _),
	additem(W,'Delete...', [], 'File', end_of_menu, _),
	additem(W,'Quit', [command('Q')], 'File', end_of_menu, _).

$file_closeable(Opts,disable) :-
	$member(noclosebox,Opts),
	!.
$file_closeable(_,enable).

$file_writeable(Opts,disable) :-
	$member(read_only,Opts),
	!.
$file_writeable(_,enable).

menuselect(_, 'File', 'New...') :- 
    stringlistresource(newfile, [Do, What, Name]),
    integer_range(Index, 1, 100), 
    swrite(DefaultName, Name, Index), 
    not(isfile(DefaultName, _, _)),
    !,                                          % commit to this defaultname we've generated
    nameafile(Do, What, DefaultName, Fn),
	$deleteifexists(Fn),
    open(_,Fn,read_write_window,_). 

menuselect(_, 'File', 'Open...') :- 
    stringlistresource(openfile, [Do]),
    selectafile('TEXT', Do, Name),                                 
    fullfilename(Name,FileName),
    open(_,FileName,read_write_window,_). 

menuselect(Window, 'File', 'Close')  :-  
    postevent(userclose,Window,_,_).

menuselect(Window, 'File', 'Save') :-      
    iswindow(Window, text, _), 
    $tryto(savetext(Window), cannotsave, Window).             

menuselect(Window, 'File', 'Save as...') :- 
    iswindow(Window, text, _), 
    stringlistresource(savefileas, [Do, What]),
    nameafile(Do, What, Window, Fn),
	$deleteifexists(Fn),
    $tryto(createfile(Fn, 'TEXT'), cannotcreate, Fn),
    retargettext(Window, Fn),
    $tryto(savetext(Fn), cannotsave, Fn).             

menuselect(Window, 'File', 'Save a Copy as...') :- 
    iswindow(Window, text, _), 
    inqtext(Window,selectcabs(SelectStart,SelectEnd)),
    stringlistresource(savefilecopy, [Do, What]),
    nameafile(Do, What, Window, Fn),
    $tryto(copyfile(Window, Fn), cannotcopy, Window, Fn),
    dotext(Window,selectcabs(SelectStart,SelectEnd)).

menuselect(Window, 'File', 'Revert to Saved') :- 
    iswindow(Window, text, _), 
    changedtext(Window),                                   
    stringlistresource(reverttofile, [Msg1, Msg2..]),
    swrite(Prompt, Msg1, Window, Msg2..),    
    confirm(Prompt, 'YES', 'YES', 'YES'),                     
    reloadtext(Window).                                

menuselect(Window, 'File', 'Print Window') :- 
    iswindow(Window, text, _),
	$printwindow(Window).

$printwindow(Window) :-
	changedtext(Window),
	!,
	stringlistresource(printfile,[Msg1,Msg2..]),
	swrite(Prompt, Msg1, Window, Msg2..),
	confirm(Prompt, 'YES', 'YES', Resp),
	$printchangedwindow(Resp,Window).
$printwindow(Window) :-
	iswindow(Window,text,_,FName),
	printfile(FName).

$printchangedwindow('YES',Window) :-
    $tryto(savetext(Window), cannotsave, Window),             
	iswindow(Window,text,_,FName),
	printfile(FName).
$printchangedwindow('NO',Window) :-
	inqtext(Window,[selectcabs(S,E),do(selectcabs(0,end_of_file)),selection(Text),do(selectcabs(S,E))]),
	T is cputime,
	swrite(Name,'/tmp/pw',T),
	open(Strm,Name,read_write,0),
	swrite(Strm,Text),
	close(Strm,0),
	printfile(Name),
	deletefile(Name).

menuselect(Window, 'File', 'Print Window') :- 
    iswindow(Window, graf, _),
    sizewindow(Window, W,H),
    beginpicture(Window, frame(0,0,W,H), ID),
    userupdate(Window, _,_),
    endpicture(ID),
    printpicture(frame(0,0,W,H),ID),
    deletepicture(ID).

menuselect(_, 'File', 'Rename...') :- 
    stringlistresource(renamefile, [Do, Prompt1, Prompt2..]),
    selectafile('', Do, Name),
    swrite(Prompt, Prompt1, Name, Prompt2..),    
    query(Prompt, Name, NewName),
    $tryto(renamefile(Name, NewName), cannotrename, Name, NewName).

menuselect(_, 'File', 'Delete...') :- 
    stringlistresource(deletefile, [Do]),
    selectafile('', Do, Name),          
    $confirmifopen(Name),
    isfile(Name, _, _),
    $tryto(deletefile(Name), cannotdelete, Name).

$confirmifopen(Name) :- 
    iswindow(Name, _, _), !, beep,             % commit to this clause if open window
    $$confirm(Name, alsowindow),
    closewindow(Name).
$confirmifopen(Name) :- 
    stream(Stream, Name, _), !, beep,             % commit to this clause if open stream
    $$confirm(Name, alsostream),
    close(Stream, 0).
$confirmifopen(Name).

$$confirm(Name, MsgResource) :-
    stringresource(MsgResource, Msg),
    swrite(Prompt, Name, Msg),
    confirm(Prompt, 'YES', 'YES', 'YES').

menuselect(_, 'File', 'Quit') :- quit.

$tryto(Goal, _..) :-
	Goal,
	!.

$tryto(Goal, ErrMsg..) :-
	$error_msg(ErrMsg..),
	!,
	fail.

$error_msg(FailResource) :-
	stringlistresource(FailResource,[M1..]),
	$error_msg_aux(M1..),
	true.		% avoid L.C.O. for named 'cut' below
$error_msg(FailResource,I1) :-
	stringlistresource(FailResource,[M1,M2..]),
	$error_msg_aux(M1,I1,M2..),
	true.		% avoid L.C.O. for named 'cut' below
$error_msg(FailResource,I1,I2) :-
	stringlistresource(FailResource,[M1,M2,M3..]),
	$error_msg_aux(M1,I1,M2,I2,M3..),
	true.		% avoid L.C.O. for named 'cut' below
$error_msg(Msg..) :-
	$error_msg_aux('Cannot perform function to ',Msg..),
	true.		% avoid L.C.O. for named 'cut' below

$error_msg_aux(Msg..) :-
	swrite(S, Msg..),
	beep,
	message(S),
	cut($error_msg).

renamefile(Name,NewName) :-
	swrite(Cmd, 'mv \"',Name,'\" \"',NewName,'\"'),
	system(Cmd).

copyfile(Window,Dest) :-
	iswindow(Window, text, _), 
    !,
	$deleteifexists(Dest),
	$tryto(createfile(Dest, 'TEXT'), cannotcreate, Dest),
	fullfilename(Dest,FileName),
	retargettext(Window, FileName),
	$tryto(savetext(FileName), cannotsave, FileName),
	retargettext(FileName,Window).

copyfile(Src,Dest) :-
	swrite(Cmd, 'cp \"',Src,'\" \"',Dest,'\"'),
	system(Cmd).

$deleteifexists(F) :-
	isfile(F, _, _),
	!, 
	$tryto(deletefile(F), cannotreplace, F).
$deleteifexists(_).

createfile(Name, _) :-
	open(Strm,Name,read_write,0),
	close(Strm,_).

printfile(Name) :-
	swrite(Cmd,'lp -s \"',Name,'\"'),
	system(Cmd).

