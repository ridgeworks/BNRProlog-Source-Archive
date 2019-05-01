/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/acton.p,v 1.1 1995/09/22 11:21:04 harrisja Exp $
*
*  $Log: acton.p,v $
 * Revision 1.1  1995/09/22  11:21:04  harrisja
 * Initial version.
 *
*
*/

$do_acton(W, X, Y, [Cntrl, Opt, Caps, Shift, Cmd, Btn], When) :-
	$get_acton_data(Op, LastPos, LastTime, LastClick),
	$charat(W,X,Y,Pos), 
	$getchar(W,Pos,Char),
	doubletime(Delta),
	$text_click(W, When, LastTime, Char, Shift, Pos, LastPos, Delta, LastClick, NewClick),
	put_obj(Op,acton_data(Pos, When, NewClick),$local).

/* double-click */
$text_click(W, When, LastTime, Char, Shift, Pos, Pos, Delta, single, double) :-
	When =< LastTime + Delta,
	!,
	$text_double_click(W, Char, Pos).

/* triple-click */
$text_click(W, When, LastTime, Char, Shift, Pos, Pos, Delta, double, triple) :-
	When =< LastTime + Delta,
	!,
	$setcursorposition(W,Pos),
	$setselectlrel(W,0,1). % select line

/* quad-click */
$text_click(W, When, LastTime, Char, Shift, Pos, Pos, Delta, triple, quad) :-
	When =< LastTime + Delta,
	!,
	End is maxint,
	$setselectcabs(W, 0, End). % select all
	
/* single click */
$text_click(W, When, _, _, 0, Pos, _, _, _, single) :-
	$setcursorposition(W,Pos),
	repeat,
	userevent(Ev,Win,D1,D2,noblock),
	$acton_single_event(Ev,Win,D1,D2,W,Pos),
	cut.

$acton_single_event(usermouseup,Win,X,Y,W,Pos):-!.
$acton_single_event(userupidle,Win,X,Y,W,Pos):-!.
$acton_single_event(userdownidle,Win,X,Y,W,Pos):-
	$charat(W,X,Y,NewPos),
	$order(Pos,NewPos,S,E),
	$setselectcabs(W,S,E),
	!, fail. % loop
$acton_single_event(Ev,Win,X,Y,_,_) :-
	Ev(Win,X,Y),
	!, fail. % loop
	
	
/* shift single click */
$text_click(W, When, _, _, 1, Pos, _, _, _, single) :-
	$getselectcabs(W,From,To),
	$extend_selection(W,From,To,Pos).
	
$extend_selection(W, From, To, Pos) :-
	Pos =< From,
	!,
	$setselectcabs(W,Pos,To).
$extend_selection(W, From, To, Pos) :-
	$setselectcabs(W,From,Pos).
		

$text_double_click(W, Char, Pos) :-
	$bracket(Char, Match, Pos, Start, Dir),
	!,
%	$setselectcabs(W, Pos, Pos),
	$match_brackets(W, Char, Match, Dir, 1, Pos, End),
	$order(Pos,End,S,E),
	successor(S,S1),
	$setselectcabs(W,S1,E).

$text_double_click(W, Char, Pos) :-
	$notbreakchar(Char),
	!,
	$find_word_start(W, Char, Pos, Start),
	$find_word_end(W, Char, Pos, End),
	$setselectcabs(W,Start,End).

$text_double_click(W, Char, Pos) :-
	End is Pos+1,
	$setselectcabs(W,Pos,End).

$order(S,E,S,E) :- S =< E,!.
$order(E,S,S,E) :- S =< E,!.

$match_brackets(W, Nest, UnNest, Dir, 0, End, End)	:- !.
$match_brackets(W, Nest, UnNest, backward, Level, 0, 0) :- !.
$match_brackets(W, Nest, UnNest, forward, Level, Pos, Pos):-
	$getcsize(W, Size),
	Pos >= Size,
	!.
$match_brackets(W, Nest, UnNest, Dir, Level, Pos, End) :-
	$nextchar(Dir, W, Pos, NewPos, Char),
	$check_match(Char, Nest, UnNest, Level, NewLevel),
	$match_brackets(W, Nest, UnNest, Dir, NewLevel, NewPos, End).

$check_match(UnNest, _, UnNest, Level, Level1) :-
	!,
	successor(Level1,Level).
$check_match(Nest, Nest, _, Level, Level1) :-
	!,
	successor(Level,Level1).
$check_match(_, _, _, Level, Level).
	
$nextchar(backward, W, Pos, Pos1, C):-
	Pos1 is Pos-1,
	$getchar(W,Pos1,C).

$nextchar(forward, W, Pos, Pos1, C):-
	Pos1 is Pos+1,
	$getchar(W,Pos1,C).

$find_word_start(W, Char, 0, 0).
$find_word_start(W, Char, Pos, Start) :-
	not($notbreakchar(Char)),
	!,
	Start is Pos + 1.
$find_word_start(W, Char, Pos, Start) :-
	$nextchar(backward, W, Pos, NewPos, NewChar),
	$find_word_start(W, NewChar, NewPos, Start).

$find_word_end(W, Char, Size, Size) :-
	$getcsize(W, Size).
$find_word_end(W, Char, End, End) :-
	not($notbreakchar(Char)),
	!.
$find_word_end(W, Char, Pos, End) :-
	$nextchar(forward, W, Pos, NewPos, NewChar),
	$find_word_end(W, NewChar, NewPos, End).

$bracket(Open, Close, Pos, Start, forward) :-
	$brackets(Open, Close),
	successor(Pos, Start).
$bracket(Close, Open, Pos, Start, backward) :-
	$brackets(Open, Close),
	successor(Start, Pos).

$brackets('(',')').
$brackets('{','}').
$brackets('[',']').
$brackets('"','"').
$brackets("'","'").

$notbreakchar('$').
$notbreakchar('_').
$notbreakchar(C) :- char_int(C , Int), $$notbreak(Int).

$$notbreak(Int) :- Int >= 0'0, Int =< 0'9.
$$notbreak(Int) :- Int >= 0'a, Int =< 0'z.
$$notbreak(Int) :- Int >= 0'A, Int =< 0'Z.

$get_acton_data(Op,Pos,Time,Click) :-
	get_obj(Op,acton_data(Pos,Time,Click),$local),
	!.
$get_acton_data(Op,0,0,nil) :-
	new_obj(acton_data(0,0,nil),Op,$local).
