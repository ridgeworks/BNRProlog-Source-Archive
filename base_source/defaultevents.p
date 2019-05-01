/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/defaultevents.p,v 1.2 1995/11/24 15:31:33 yanzhou Exp $
*
*  $Log: defaultevents.p,v $
 * Revision 1.2  1995/11/24  15:31:33  yanzhou
 * Typo at userdownidle fixed.
 *
 * Revision 1.1  1995/09/22  11:23:50  harrisja
 * Initial version.
 *
*
*/

userupidle(_,_,_) :- idlenaptime. % sleep for 0.1 sec when inactive 
% userupidle(_,_,_) :- delay(0.1). % changed due to problems with enable_timer not interupting when it should.

idlenaptime :- sleep(0.1).

userdownidle(_,_,_).
useractivate(_,_,_).
userdeactivate(_,_,_).
usergrow(_,_,_).
userdrag(_,_,_).
userupdate(_,_,_).
usermouseup(_,_,_).
usermousedown(W,X,Y) :-
	lasteventdata(_,_,_,When,Modifiers),
	dotext(W,acton(X,Y,Modifiers,When)).
usermousedown(_,_,_).
userreposition(_,_,_).
userresize(_,_,_).


userswitch(To, _, _) :-
	iswindow(To, Type, Visible),
	activewindow(To, Type).

userclose(W,_,_) :-
	$saveifchanged(W),
	closewindow(W), % close if no changes or not a text window or ok to close
	$console(W) % Closing the console quits the application
	-> postevent(menuselect,W,'File','Quit')
	;  $leaveonewindowvisible.

$saveifchanged(W) :-
	changedtext(W),
	!,
	stringlistresource(closefile, [Msg1, Msg2..]),
	swrite(Prompt, Msg1, W, Msg2..),
	$save_default(W,Default),
	confirm(Prompt, 'YES', Default, R),
	R = 'YES'
	-> $tryto(savetext(W), cannotsave, W).
$saveifchanged(_).

$save_default(W,'NO') :- $console(W),!.
$save_default(W,'YES').

userkey(W, '\7F', Options) :- % delete
    userkey(W, '\b', Options).

userkey(W, enter, Options) :-
    userkey(W, '\n', Options).

userkey(W, '\r', Options) :-
    userkey(W, '\n', Options).
