/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/resources.p,v 1.1 1995/09/22 11:27:39 harrisja Exp $
*
*  $Log: resources.p,v $
 * Revision 1.1  1995/09/22  11:27:39  harrisja
 * Initial version.
 *
*
*/


%
%	resource management
%	resource files are composed of prolog facts:
%		resource(Type, Id, Name, Value).
%
%	Examples:
%		resource('STR ', 1, username, 'Larry Brunet').
%		resource('STR#', 2, menus, ['File','Edit','Find','Help']).
%		resource('ICON', 3, xlogo, '/usr/include/X11/bitmaps/xlogo32').
%
%	data structures:
%
%		openresfile$(FileName)	-	table of open resource files
%		search_order$(Order..)	-	list of pointers to openresfile$ objects, search order for resource files
%		resource(FP, Type, Id, Name, Value)	-	the resources (FP points to openresfile$ object)
%
openresfile(FileName) :-
	get_obj(Op,openresfile$(FileName),$local),
	!,
	get_obj(SOp, search_order$(Order..),$local),
	$select(Order,X,OrderX),
	put_obj(SOp, search_order$(X,OrderX..),$local).

openresfile(FileName) :-
	new_obj(openresfile$(FileName),Op,$local),
	readfile(FileName,F(P..)),
	remember(F(Op,P..),$local),
	fail.
openresfile(FileName) :-
	get_obj(Op,openresfile$(FileName),$local),
	get_obj(SOp,search_order$(Order..),$local)
	-> put_obj(SOp,search_order$(Op,Order..),$local)
	; new_obj(search_order$(Op),SOp,$local).

closeresfile(FileName) :-
	get_obj(Op,openresfile$(FileName),$local),
	dispose_obj(Op,$local),
	get_obj(SOp, search_order$(Order..),$local),
	$select(Order,X,OrderX),
	put_obj(SOp, search_order$(OrderX..),$local),
	forget_all(resource(Op,_..),$local).

deleteresource(Type) :-
	% delete all resources of the given type in the topmost resource file
	get_obj(_,search_order$(Top,_..),$local),
	forget_all(resource(Top,Type,_..),$local),
	% make change permanent
	$saveresfile(Top).

deleteresource(Type, Ident) :-
	% delete only the identified resource
	get_obj(_,search_order$(Top,_..),$local),
	$resid(Ident,Name,Id),
	forget(resource(Top,Type,Id,Name,_..),$local),
	% make change permanent
	$saveresfile(Top).

readresource(Type, Ident, Value) :-
	$resid(Ident,Name,Id),
	get_obj(_,search_order$(Order..),$local),
	!,
	$member(F,Order),
	get_obj(Op,resource(F,Type,Id,Name,Value),$local).

writeresource(Type, Ident, Value) :-
	$resid(Ident,Name,Id),
	% write new resource value
	get_obj(_,search_order$(Order..),$local),
	$member(F,Order),
	get_obj(Op,resource(F,Type,Id,Name,_),$local)
	-> put_obj(Op,resource(F,Type,Id,Name,Value),$local)
	;  new_obj(resource(F,Type,Id,Name,Value),_,$local),
	% make change permanent
	$saveresfile(F).

stringresource(Str, Value) :-
	var(Value),
	!,
	readresource('STR ',Str,Value).
stringresource(Str, Value) :-
	symbol(Value),
	writeresource('STR ', Str, Value).

stringlistresource(Str, Value) :-
	var(Value),
	!,
	readresource('STR#', Str, Value).
stringlistresource(Str, Value) :-
	symbol(Value..),
	writeresource('STR#', Str, Value).
stringlistresource(Str, Index, Value) :-
	var(Value),
	!,
	readresource('STR#', Str, Values),
	cut,
	arg(Index,Values,Value).
	
stringlistresource(Str, Index, Value) :-
	symbol(Value),
	readresource('STR#', Str, Values),
	$strlist(Values,Index,Value,NewValues),
	writeresource('STR#', Str, NewValues).

addresitems(Type, Menu, After) :- 
	$console(Console),
	addresitems(Console, Type, Menu, After).
addresitems(Window, Type, Menu, After) :-
	foreach(readresource(Type, _, Value) do
		additem(Window, Value, [], Menu, After, _)).

$saveresfile(Op) :-
	get_obj(Op,openresfile$(F),$local),
	open(Strm,F,read_write,0),
	[recall(resource(Op,P..),$local),
	 put_term(Strm,resource(P..),0),nl(Strm),
	 fail]
	; close(Strm,0).

$resid(Ident,Ident,_) :-
	symbol(Ident), !.
$resid(Ident,_,Ident) :-
	integer(Ident), !.
