/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/menus.p,v 1.5 1996/10/29 11:26:57 harrisj Exp $
*
*  $Log: menus.p,v $
 * Revision 1.5  1996/10/29  11:26:57  harrisj
 * - deletemenu modified to delete submenus.
 * - instantiate_popup_menu modified to correctly update state space info so that the popup can be deleted
 * - added popdownmenu predicate to hide a popup menu.
 *
 * Revision 1.4  1996/09/25  16:28:21  harrisj
 * modified mark back to mark().  Options for
 * mark() are: mark(on) or mark(off).  In terms
 * of the old method of specifying item attributes
 * this translates to '!E' and '!D' respectively
 *
 * Revision 1.3  1996/09/10  14:57:32  harrisj
 * Removed the $menu_attribute clause for mark(Char) and added
 * a clause for the "mark" symbol.
 *
 * Revision 1.2  1996/04/18  23:33:03  yanzhou
 * menuitem(Window, Menu, 0, Title, Attributes) now changes and
 * queries attributes of an entire menu.  Supported attributes
 * are: "enable" and "disable".  A disabled menu has a gray-ed out
 * button in menubar.
 *
 * Revision 1.1  1995/09/22  11:25:23  harrisja
 * Initial version.
 *
*
*/
/* for debugging
menu_statespace :-
	inventory(I,$local),
	recall(I(X..),$local),
	write(I(X..)),nl,
	fail.
menu_statespace.
dumpmenu(Menu) :-
	$console(Console),
	!,
	dumpmenu(Console,Menu).
dumpmenu(W,Menu) :-
	window_id(W,Wid),
	$menu_number(Wid,Menu,MenuPtr,MenuOp,Items),
	$dumpmenu(MenuPtr).
dumpwidget(W) :- $dumpwidget(W).
*/


addmenu(Menu, Title, -1) :- % hierarchical or popup menu - doesn't belong to a menu bar
	deletemenu(Menu)->true,
	!,
	new_obj(menu(Menu,nil,Title,_,-1,[]),MenuOp,$local),
	put_obj(MenuOp,menu(Menu,nil,Title,MenuOp,-1,[]),$local).

addmenu(W, Menu, Title, -1) :- % hierarchical or popup menu - doesn't belong to a menu bar
	!,
	addmenu(Menu, Title, -1).
addmenu(Menu, Title, Before_menu) :-
	$console(Console),
	!,
	addmenu(Console, Menu, Title, Before_menu).
addmenu(Window, Menu, Title, Before_menu) :-
	symbol(Title),
	$menu_id(Menu,MenuId),
	window_id(Window,WindowId),
	!,
	$delete_dummy_menu(Window),
	deletemenu(Window,Menu)->true,
	$fetch_mbar(WindowId,Mbar,Menus),
	$menu_position(Menus,Before_menu,MenuPos),
	$addmenu(WindowId,Title,MenuPos,MenuPtr),
	$addmenutombar(Mbar,MenuId,MenuPtr,Title,MenuPos).

$menu_id('File', 32129).
$menu_id('Edit', 32130).
$menu_id('Find', 32131).
$menu_id('Window', 32132).
$menu_id('Contexts', 32133).
$menu_id('Help', 32134).
$menu_id(' ',32135).
$menu_id(Id,Id) :- integer(Id).

%%%%%%%%%%%%%%%%% Dummy Menu Support %%%%%%%%%%%%%%%%%%%
% X/Motif does not display a full height menubar when
%there aren't any menu items.  Hence a "dummy" menu is
%created when we open a window.  This needs to be 
%deleted when we add real menu items.  It also needs to
%be re-created when we delete the last menu item.

$delete_dummy_menu(Window) :-
	$menu_number(Window," ",MenuId,MenuOp,Items),
	get_obj(MenuOp,menu(MenuNumber,MenuId,Title,MenuOp,Mbar,Items), $local),
	$$deletemenu(MenuId),
	dispose_obj(MenuOp,$local),
	!,
	$remove_menu_from_menubar(Mbar,Window,MenuOp).
$delete_dummy_menu(_) :- !.

$add_dummy_menu(Window) :-
	window_id(Window,WindowId),
	$menu_id(" ",MenuId),
	get_obj(Mbar,mbar(WindowId,[]),$local),
	!,
	$addmenu(WindowId," ",0,MenuPtr),
	$addmenutombar(Mbar,MenuId,MenuPtr," ",0).
$add_dummy_menu(Window) :- !.

$initialize_dummy_menu(_,0) :- !.	
$initialize_dummy_menu(Window,MenuPtr) :-
	window_id(Window,WindowId),
	$menu_id(" ",MenuId),
	!,
	$fetch_mbar(WindowId,Mbar,Menus),
	$menu_position(Menus,0,MenuPos),
	$addmenutombar(Mbar,MenuId,MenuPtr," ",MenuPos).

$menu_bar(Window,Mbar,Menus) :-	
	window_id(Window,WindowId),
        $fetch_mbar(WindowId,Mbar,Menus).

$fetch_mbar(WindowId,Mbar,Menus):-
	get_obj(Mbar,mbar(WindowId,Menus),$local),
	!.
$fetch_mbar(WindowId,Mbar,[]) :-
	new_obj(mbar(WindowId,[]),Mbar,$local).	

$menu_position(Menus, -2, -2) :- !.
$menu_position(Menus, 0, MenuPos) :-
	termlength(Menus,MenuPos,_),
	!.

$menu_position(Menus, Menu, MenuPos) :-
	$menu_position(Menus, Menu, MenuPos, 0),
	!.	% NEW 06/95 Removes a choicepoint

$menu_position([M,Menus..], Menu, MenuPos, MenuPos) :-
	get_obj(M,menu(Menu,_..),$local),
	!.
$menu_position([M,Menus..], Menu, MenuPos, N) :-
	successor(N,N1),
	$menu_position(Menus, Menu, MenuPos, N1).


$addmenutombar(Mbar,MenuId,MenuPtr,Title,MenuPos) :-
	get_obj(Mbar,mbar(WindowId,Menus),$local),
	new_obj(menu(MenuId,MenuPtr,Title,_,Mbar,[]),MenuOp,$local),
	put_obj(MenuOp,menu(MenuId,MenuPtr,Title,MenuOp,Mbar,[]),$local),
	$insert_at(MenuPos,Menus,MenuOp,NewMenus),
	put_obj(Mbar,mbar(WindowId,NewMenus),$local).

$insert_at(-2,Items,Item,[Item,Items..]) :- !.
$insert_at(0,Items,Item,[Item,Items..]) :- !.
$insert_at(N,[X,Items..],Item,[X,Items1..]) :-
	successor(N1,N),
	$insert_at(N1,Items,Item,Items1).

additem(Item, Attributes, Menu, After_itemid, ItemPos) :-
	$console(Console),
	!,
	additem(Console,Item, Attributes, Menu, After_itemid, ItemPos).
additem(W,Item, Attributes, Menu, After_itemid, ItemPos) :-
	symbol(Item),
	$menu_number(W,Menu,MenuPtr,MenuOp,Items),
	$item_attributes(Attributes,Attr,MenuPtr),
	$check_command_key_uniqueness(Attr,Attr1,W),
	$item_position(Items,After_itemid,ItemPos), 
	$$additem(MenuPtr,Item,Attr1,ItemPos,ItemId),
	$additemtomenu(MenuOp,item(Item,ItemId,Attr1),ItemPos).

$$additem(nil,Item,Attr,ItemPos,nil) :- !.
$$additem(MenuPtr,Item,Attr,ItemPos,ItemId) :-
	$additem(MenuPtr,Item,Attr,ItemPos,ItemId).

$check_command_key_uniqueness(Attr,Attr1,W):-
 	$menu_bar(W,Mbar,Menus),!,  % only check uniqueness if menu bar exists
	$$check_command_key_uniqueness(Attr,Attr1,Menus).
$check_command_key_uniqueness(Attr,Attr,W).

% removes command key from attribute list if it already exists on menu bar
$$check_command_key_uniqueness([],[],_).
$$check_command_key_uniqueness([command(Key),Attrs..],Attrs1,Menus) :-
	$member(MenuOp,Menus),
	get_obj(MenuOp,menu(_,_,_,_,_,Items),$local),
	$member(item(_,_,ItemAttr),Items),
	$member(command(Key),ItemAttr),
	!,
	$$check_command_key_uniqueness(Attrs,Attrs1,W).
$$check_command_key_uniqueness([Attr,Attrs..],[Attr,Attrs1..],W):-
	!,
	$$check_command_key_uniqueness(Attrs,Attrs1,W).

$item_attributes(Attr1,Attr2,_..) :- var(Attr1),var(Attr2),!. 
$item_attributes(Attr,AttrList,MenuId) :- 
	symbol(Attr),		% old style of attributes
	!,
	$menu_attributes(AttrList0,Attr),
	$fix_sub_menu_ids(AttrList0,AttrList,MenuId).

$item_attributes(AttrList0,AttrList,MenuId) :- 
	list(AttrList0),
	$menu_attributes(AttrList0,_),
	$fix_sub_menu_ids(AttrList0,AttrList,MenuId).

$fix_sub_menu_ids(AttrList,AttrList,nil) :- !.
$fix_sub_menu_ids(AttrList0,AttrList,ParentMenuId) :-
	$replace_1_item(menu(Menu),AttrList0,menu(SubMenuId),AttrList),
	!,
	$instantiate_sub_menu(Menu,ParentMenuId,SubMenuId).
$fix_sub_menu_ids(AttrList,AttrList,_) :- !.

$menu_number(_,Menu,MenuId,MenuOp,Items) :-	% heirachical menu
	integer(Menu),
	get_obj(MenuOp,menu(Menu,MenuId,Title,MenuOp,-1,Items), $local),!.

$menu_number(W,Title,MenuId,MenuOp,Items) :-
	symbol(Title),
	!,
	$menu_bar(W,Mbar,Menus),
	get_obj(MenuOp,menu(Menu,MenuId,Title,MenuOp,Mbar,Items), $local),
	!.
	
$menu_number(W,Menu,MenuPtr,MenuOp,Items) :-
	integer(Menu),
	$menu_bar(W,Mbar,Menus),
	get_obj(MenuOp,menu(Menu,MenuPtr,Title,MenuOp,Mbar,Items), $local),
	!.

$item_position(Items,end_of_menu,ItemPos) :-
	termlength(Items,NumItems,_),
	successor(NumItems,ItemPos),!.
$item_position(Items,AfterItem,ItemPos) :-
	termlength(Items,NumItems,_),
	AfterItem >= 0, AfterItem =< NumItems,
	successor(AfterItem,ItemPos).

$additemtomenu(MenuOp, Item, ItemPos) :-
	get_obj(MenuOp,menu(Menu,MenuId,Title,MenuOp,Mbar,Items),$local),
	successor(ItemPos1,ItemPos),
	$insert_at(ItemPos1, Items, Item, NewItems),
	put_obj(MenuOp,menu(Menu,MenuId,Title,MenuOp,Mbar,NewItems),$local).

%
% Patch 18/04/96 to enable/disable menus, by yanzhou@bnr.ca
%   $menuattr/2 is a new primitive to query/modify menu attributes.
%   Supported menu attributes are: "enable" and "disable".
%
menuattr(Menu, Title, Attributes) :-
	$console(Console),
	!,
	menuattr(Console, Menu, Title, Attributes).
menuattr(W, Menu, Title, Attributes) :-
	$menu_number(W,Menu,MenuId,MenuOp,Items),
	get_obj(MenuOp,menu(MenuNumber,MenuId,Title,_..),$local),
	!,
	$$menuattr(MenuId, Attributes).

$$menuattr(MenuId, Attributes) :-
	var(Attributes),
	!,
	$menuattr(MenuId, Attributes).
$$menuattr(MenuId, Attributes) :-
	$enablemenu(Attributes),
	!,
	$menuattr(MenuId, [enable]).
$$menuattr(MenuId, Attributes) :-
	$disablemenu(Attributes),
	!,
	$menuattr(MenuId, [disable]).

$enablemenu(')').
$enablemenu([enable]).
$disablemenu('(').
$disablemenu([disable]).

%
% End patch
%

menuitem(Menu, ItemPos, Item, Attributes) :-
	$console(Console),
	!,
	menuitem(Console, Menu, ItemPos, Item, Attributes).
menuitem(W, Menu, 0, Title, Attrs) :-
    % Modified by yanzhou@bnr.ca 18/04/96 to enable/disable menus
	!,
	menuattr(W, Menu, Title, Attrs).
menuitem(W, Menu, ItemPos, Item, Attributes) :-
	$menu_number(W,Menu,MenuId,MenuOp,Items),
	arg(ItemPos,Items,item(OldItem,ItemId,OldAttributes)),
	$item_attributes(Attributes,Attr,MenuId),
	$menuitem(ItemId, Item, Attr),
	% added 93/04/06 JR - change submenu PTR to an ID
	$fixSubMenu(Attr, Attr1),
	$return_item_attributes(Attr1,Attributes,MenuId),
	$replace_1_item(item(OldItem,ItemId,OldAttributes),Items,item(Item,ItemId,Attr),NewItems),
	get_obj(MenuOp,menu(MenuNumber,MenuId,Title,MenuOp,Mbar,Items),$local),
	put_obj(MenuOp,menu(MenuNumber,MenuId,Title,MenuOp,Mbar,NewItems),$local).

$fixSubMenu(Attr, Attr1) :- 
	$replace_1_item(menu(MenuPtr),Attr,menu(MenuId),Attr1),
	recall(menu(MenuId, MenuPtr, _..), $local),
	!.
$fixSubMenu(Attr, Attr). 

$replace_1_item(X,[X,Xs..],Y,[Y,Xs..]) :- !.
$replace_1_item(X,[Z,Xs..],Y,[Z,Ys..]) :- $replace_1_item(X,Xs,Y,Ys).

$return_item_attributes(Attr,Attr,Etc..) :- !.
$return_item_attributes(AttrList,Attr,Etc..) :- % pass back old format on backtracking
	$item_attributes(Attr,AttrList,Etc..).
	

lastmenudata(M, ItemPos) :-
	$lastmenudata(MenuId, ItemId),
	get_obj(_,menu(Menu,MenuId,Title,MenuOp,Mbar,Items),$local),
	M = Menu;M = Title,
	cut,
	arg(ItemPos,Items,item(Item,ItemId,Attributes)).

deleteitem(Menu, Item) :-
	$console(Console),
	!,
	deleteitem(Console, Menu, Item).
deleteitem(W, Menu, ItemPos) :-
	$menu_number(W,Menu,MenuId,MenuOp,Items),
	get_obj(MenuOp,menu(MenuNumber,MenuId,Title,MenuOp,Mbar,Items),$local),
	arg(ItemPos,Items,item(Item,ItemId,Attributes)),
	$selectone(item(_,ItemId,_),Items,NewItems),
	$$deleteitem(MenuId,ItemId),
	put_obj(MenuOp,menu(MenuNumber,MenuId,Title,MenuOp,Mbar,NewItems),$local).

$$deleteitem(nil,_).
$$deleteitem(_,nil).
$$deleteitem(Menu,Item) :- $deleteitem(Menu,Item).

deletemenu(Menu) :-
	$console(Console),
	!,
	deletemenu(Console,Menu).
deletemenu(W, Menu) :-
	$menu_number(W,Menu,MenuId,MenuOp,Items),
	get_obj(MenuOp,menu(MenuNumber,MenuId,Title,MenuOp,Mbar,Items), $local),
	$deletesubmenus(Items),
	$$deletemenu(MenuId),
	dispose_obj(MenuOp,$local),
	$remove_menu_from_menubar(Mbar,W,MenuOp),
	!,
	$add_dummy_menu(W).

$remove_menu_from_menubar(-1,_,_) :- !.
$remove_menu_from_menubar(Mbar,W,MenuOp) :-
	window_id(W,Wid),
	get_obj(Mbar,mbar(Wid,Menus),$local),
	$selectone(MenuOp,Menus,NewMenus),
	put_obj(Mbar,mbar(Wid,NewMenus),$local).
	
$$deletemenu(nil).
$$deletemenu(Menu) :- $deletemenu(Menu).

$deletesubmenus([]).
$deletesubmenus([item(_,_,Attributes),RestItems..]) :-
   $getSubMenu(Attributes,MenuId) ->
      [get_obj(MenuOp,menu(MenuNumber,MenuId,Title,MenuOp,Mbar,Items), $local),
      deletemenu(MenuNumber)],
   $deletesubmenus(RestItems).

$getSubMenu([],_) :- !,fail.
$getSubMenu([menu(MenuId),Rest..],MenuId).
$getSubMenu([Attr,Rest..],MenuId) :-
      $getSubMenu(Rest,MenuId).

$remove_menu_bar(Wid) :-
	forget(mbar(Wid,Menus),$local),
	foreach($member(Menu,Menus) do
		[get_obj(Menu,menu(_,MenuId,Rest..),$local),
		$$deletemenu(MenuId),
		dispose_obj(Menu,$local)]),!.

$remove_menu_bar(Wid).  % in case mbar didn't exist for this window
	
$selectone(X,[X,Xs..],[Xs..]) :- !.
$selectone(X,[Y,Xs..],[Y,Ys..]) :- $selectone(X,[Xs..],[Ys..]).

popupmenu(Menu,ItemPos,Top,Left) :-
 	$menu_number(W,Menu,MenuId,MenuOp,_),
	$instantiate_popup_menu(MenuOp,MenuId,MenuId1),
	get_obj(MenuOp, menu(MenuNumber, MenuId1, Title, MenuOp, -1, Items), $local),
	arg(ItemPos,Items,item(Item,ItemId,Attributes)),
	$popupmenu(MenuId1,ItemId,Top,Left).

$instantiate_popup_menu(MenuOp, nil, MenuId) :-
	!,
	get_obj(MenuOp, menu(MenuNumber, nil, Title, MenuOp, -1, Items), $local),
	$addmenu(-1,Title,-1,MenuId), 
	$addallitems(Items,NewItems,MenuId,1),
	% MenuId and ItemId's are now bound
	put_obj(MenuOp, menu(MenuNumber, MenuId, Title, MenuOp, -1, NewItems), $local).
$instantiate_popup_menu(MenuOp, MenuId, MenuId).

popdownmenu(Menu) :-
      $menu_number(W,Menu,MenuId,MenuOp,_),
      $$popdownmenu(MenuId),!.
      
$$popdownmenu(nil).
$$popdownmenu(MenuId) :-
      $popdownmenu(MenuId).

$instantiate_sub_menu(MenuNumber, ParentMenuId, MenuId) :-
	get_obj(MenuOp, menu(MenuNumber, Etc..), $local),
	$$instantiate_sub_menu(menu(MenuNumber,Etc..),ParentMenuId,MenuId).
$$instantiate_sub_menu(menu(MenuNumber, nil, Title, MenuOp, -1, Items),ParentMenuId,MenuId) :-
	!,
	$addsubmenu(Title,ParentMenuId,MenuId), 
	$addallitems(Items,NewItems,MenuId,1),
	% MenuId and ItemId's are now bound
	put_obj(MenuOp, menu(MenuNumber, MenuId, Title, MenuOp, -1, NewItems), $local).
$$instantiate_sub_menu(menu(MenuNumber, MenuId, _..), ParentMenuId, MenuId).
	
$addallitems([],[],_,_):-!.
$addallitems([item(Item,_,AttrList0),Items..],[item(Item,ItemId,AttrList),NewItems..],MenuId,ItemPos) :-
	$fix_sub_menu_ids(AttrList0,AttrList,MenuId),
	$additem(MenuId, Item, AttrList, ItemPos, ItemId),
	successor(ItemPos,ItemPos1),
	$addallitems(Items,NewItems,MenuId,ItemPos1).

mbarheight(Height) :-
	$console(Console),
	!,
	mbarheight(Console, Height).
mbarheight(Window, Height) :-
	window_id(Window,Id),!,
	$mbarheight(Id,Height).
mbarheight(Window, 0).	% no window spec, use 0

$menu_attributes([],'') :- !.
$menu_attributes([Attr,Attrs..],String) :-
	concat(C,Cs,String),
	$menu_attribute(Attr,C),
	!,
	$menu_attributes(Attrs,Cs).
$menu_attributes([Attr,Attrs..],String) :-
	nonvar(Attr),
	$menu_attribute(Attr,C),
	!,
	$menu_attributes(Attrs,Cs),
	concat(C,Cs,String).

$menu_attribute(enable,')').
$menu_attribute(disable,'(').
$menu_attribute(icon(Id),Icon) :-
	char_int(C,Id),
	concat('^',C,Icon).
$menu_attribute(icon(Id),Icon) :-
	concat('/\1D^',C,Icon),
	char_int(C,Id0),
	Id is Id0 + 256.
$menu_attribute(icon(Id),Icon) :-
	Id0 is Id - 256,
	char_int(C,Id0),
	concat('/\1D^',C,Icon).
$menu_attribute(icon(Id),Icon) :-
	concat('^',C,Icon),
	char_int(C,Id).
%$menu_attribute(mark(Char),Mark) :-
%	concat('!',Char,Mark),
%	namelength(Char,1).
$menu_attribute(mark(M), Mark) :-
	$menu_item_mark(M, MChar),
	concat('!',MChar,Mark).
$menu_attribute(style(S),Style) :-
	$menu_item_style(S,SChar),
	concat('<',SChar,Style).
$menu_attribute(style(S),Style) :-
	concat('<',SChar,Style),
	$menu_item_style(S,SChar).
$menu_attribute(command(Key),Cmd) :-
	concat('/',Key,Cmd),
	namelength(Key,1).
$menu_attribute(menu(MenuNumber),Menu) :-
	$menu_number(W,MenuNumber,MenuId,MenuOp,_),
	char_int(C,MenuNumber),
	concat('/\1B!',C,Menu).
$menu_attribute(menu(MenuNumber),Menu) :-
	concat('/\1B!',C,Menu),
	char_int(C,MenuNumber),
	$menu_number(W,MenuNumber,MenuId,MenuOp,_).

$menu_item_style(plain,'P').
$menu_item_style(bold,'B').
$menu_item_style(italic,'I').
$menu_item_style(underline,'U').
$menu_item_style(shadow,'S').

$menu_item_mark(off, 'D').
$menu_item_mark(on, 'E').
