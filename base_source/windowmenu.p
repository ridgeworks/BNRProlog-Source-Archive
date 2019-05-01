/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/windowmenu.p,v 1.1 1995/09/22 11:29:11 harrisja Exp $
*
*  $Log: windowmenu.p,v $
 * Revision 1.1  1995/09/22  11:29:11  harrisja
 * Initial version.
 *
*
*/

/*
 *   WindowMenu
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1989, 1990, 1991
 */

installmenu(W,'Window') :-
	addmenu(W, 'Window', 'Window', 0),
	additem(W, 'Tile Text Windows', [command('J')], 'Window', end_of_menu, _),
	additem(W, 'Stack Text Windows', [], 'Window', end_of_menu, _),
	additem(W, 'Hide Window', [], 'Window', end_of_menu, _),
	$enable_load(W,EnableLoad),
	additem(W, 'Load Window', [command('L'),EnableLoad], 'Window', end_of_menu, _),
	additem(W, '-', [disable], 'Window', end_of_menu, _),
	cut,
	$get_window_list(Windows),
	$add_window_items(Windows,W),
	fail.
installmenu(W,'Window').

$enable_load(W,disable) :-
	$console(W),
	!.
$enable_load(_,enable).

$get_window_list(Windows) :-
	recall(window_list(Windows),$local),
	!.
$get_window_list([]) :-
	remember(window_list([]),$local).

$add_window_items([],W).
$add_window_items([[Type,Name],Windows..],W) :-
	$add_window_item(Type,Name,W),
	!,
	$add_window_items(Windows,W).
$add_window_item(WType, WName, W) :-
	$console(WName),
	!,
	additem(W,WName,[command('K')],'Window',end_of_menu,ItemId).
$add_window_item(WType, WName, W) :-
	additem(W,WName,[],'Window',end_of_menu,ItemId).

menuselect(_, 'Window', 'Tile Text Windows') :- tilewindows(text, visible).
menuselect(_, 'Window', 'Stack Text Windows') :- stackwindows(text, visible).
menuselect(W, 'Window', 'Hide Window') :- 
	iswindow(W2,text,visible),
	W2 \= W,
	!,
	hidewindow(W).
menuselect(W, 'Window', 'Hide Window') :- beep.	% don't allow last window to be hidden
menuselect(_, 'Window', WindowName) :- 
	iswindow(WindowName, WindowType, _),
	activewindow(WindowName, WindowType).

menuselect(W, 'Window', 'Load Window') :-
	iswindow(W, text, _),
	fullfilename(Cx, W),
	$menuload_fn_as_cx(W, Cx).

$add_new_window(WName,WType) :-
	get_obj(Op,window_list(Windows),$local),
	$append(Windows,[[WType,WName]],NewWindows),
	put_obj(Op,window_list(NewWindows),$local),
	cut,
	iswindow(W,T,_),
	$add_window_item(WType,WName,W),
	fail.
$add_new_window(_,_).

$remove_window(WName, WType) :-
	get_obj(Op,window_list(Windows),$local),
	$selectone([WType,WName],Windows,NewWindows),
	put_obj(Op,window_list(NewWindows),$local),
	$window_itemid(WType,WName,Windows,ItemId),
	cut,
	iswindow(W,T,_),
	deleteitem(W,'Window',ItemId),
	fail.
$remove_window(_,_).

userrename(NewName,OldName,WType) :-
	get_obj(Op,window_list(Windows),$local),
	$replace_1_item([WType,OldName],Windows,[WType,NewName],NewWindows),
	put_obj(Op,window_list(NewWindows),$local),
	$window_itemid(WType,OldName,Windows,ItemId),
	cut,
	iswindow(W,T,_),
	menuitem(W, 'Window', ItemId, NewName, []),
	fail.

$window_itemid(WType,WName,Windows,ItemId) :-
	arg(Pos,Windows,[WType,WName]),
	ItemId is Pos+5.
