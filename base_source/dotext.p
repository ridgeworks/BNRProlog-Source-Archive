/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/dotext.p,v 1.1 1995/09/22 11:23:56 harrisja Exp $
*
*  $Log: dotext.p,v $
 * Revision 1.1  1995/09/22  11:23:56  harrisja
 * Initial version.
 *
*
*/

dotext(WindowName, TextStructure) :-
    iswindow(WindowName,text,_),
	!,
    window_id(WindowName,W),
    not(not($traversetextlist(TextStructure,W,$dotext))).

dotext(Stream, TextStructure) :-
	stream(Stream,FName,Mode,FFName),
	!,
    iswindow(WindowName,text,_,FFName),
    window_id(WindowName,W),
    not(not($traversetextlist(TextStructure,W,$dotext))).

inqtext(WindowName, TextStructure) :-
    iswindow(WindowName,text,_),
	!,
    window_id(WindowName,W),
    $traversetextlist(TextStructure,W,$inqtext).

inqtext(Stream, TextStructure) :-
	stream(Stream,FName,Mode,FFName),
	!,
    iswindow(WindowName,text,_,FFName),
    window_id(WindowName,W),
    $traversetextlist(TextStructure,W,$inqtext).

$traversetextlist([],W,Do) :- !.
$traversetextlist([T,Ts..],W,Do) :-
    structure(T),
    !,
    Do(W,T),
    $traversetextlist([Ts..],W,Do).
$traversetextlist([T,Ts..],W,Do) :-
    list(T),
    !,
    not(not($traversetextlist(T,W,Do))),
    $traversetextlist([Ts..],W,Do).
$traversetextlist(T,W,Do) :-
    structure(T),
    !,
    Do(W,T).

$dotext(W,T) :-
	var(T),!.
$dotext(W,T(P..)) :-
	$text_output_desc(T,DoT),
	!,
	DoT(W,P..).
$dotext(W,inq(S)) :-
    !,
    $traversetextlist(S,W,$inqtext).
$dotext(W,F) :- F,cut.   % execute unknown functor 

$inqtext(W,T) :-
	var(T),!.
$inqtext(W,T(P..)) :-
	$text_attr_desc(T,InqT),
	!,
	InqT(W,P..),
	cut.
$inqtext(W,do(S)) :-
    !,
    $traversetextlist(S,W,$dotext).
$inqtext(W,F) :- F,cut. % execute unknown functor

$do_selectcabs(W,Start,End) :-
    $sel_range(Start,End,S,E),
    $setselectcabs(W,S,E).

$do_selectcrel(W,Start,End) :-
    $sel_end(End,E),
    $setselectcrel(W,Start,E).

$do_selectlabs(W,Start,End) :-
    $sel_range(Start,End,S,E),
    $setselectlabs(W,S,E).

$do_selectlrel(W,Start,End) :-
   $sel_end(End,E),
   $setselectlrel(W,Start,E).

$do_insert(W,S) :-
	$validstream(S,FileP),
	!,
    $doinsert(W,FileP).

$do_insert(W,S) :-
    $doinsert(W,S).

$do_replace(W,S) :-
	$validstream(S,FileP),
	!,
    $doreplace(W,FileP).

$do_replace(W,S) :-
    $doreplace(W,S).

$do_textfont(W,Font) :-
	$font(Font,F),
	$settextfont(W,F).
	
$inq_selection(W,S) :-
	var(S),!,
    $getselection(W,S).

$inq_selection(W,S) :-
	$validstream(S, FileP),
    $getselection(W,FileP).

$inq_selectcrel(W,0,0).

$inq_selectlrel(W,0,0).

$inq_textfont(W,Font) :-
	$gettextfont(W,F),
	$font(Font,F).

listsizes(Font,Sizes) :-
	nonvar(Font),
	$font(Font,F),
	cut,
	$listsizes(F,Sizes).

listfonts(List) :-
	findset(Font,isfont(Font,Name,_,_),List).

isfont(Font, Size, Name, SizeList) :-
	isfont(Font, Size, Name, SizeList, face()).
isfont(Font, Size, Name, SizeList, face(Face..)) :-
	$font(Font,Name),
	cut,
	var(Font) -> [$listfonts(Names), $member(Name, Names), $font(Font,Name)],
	var(Size) -> [$listsizes(Name, Sizes), $member(Size, Sizes)],
	$$fontinfo(Name, Size, Face, Ascent, Descent, Leading, MaxWidth, AvgWidth),
	once(
	SizeList = [Ascent,Descent,Leading,MaxWidth]
	; SizeList = [Ascent,Descent,Leading,MaxWidth,AvgWidth]).

$$fontinfo(F, Size, Face, Ascent, Descent, Leading, MaxWidth, AvgWidth) :-
	recall($fontinfo(F, Size, Face, Ascent, Descent, Leading, MaxWidth, AvgWidth),$local),
	!.
$$fontinfo(F, Size, Face, Ascent, Descent, Leading, MaxWidth, AvgWidth) :-
	$fontinfo(F, Size, Face, Ascent, Descent, Leading, MaxWidth, AvgWidth),
	remember($fontinfo(F, Size, Face, Ascent, Descent, Leading, MaxWidth, AvgWidth),$local).

$sel_range(Start,End,S,E) :-
    $sel_end(End,E),
    $sel_start(Start,S),
    E >= 0 -> E >= S.

$sel_end(E,E) :- integer(E),!.
$sel_end(End,E) :- End@=end_of_file,E is maxint.
$sel_start(S,S) :- integer(S), S>=0, !.
$sel_start(S,0) :- integer(S),!.
$sel_start(End,S) :- End@=end_of_file,S is maxint.

$text_output_desc(edit,$doeditaction).
$text_output_desc(replace,$do_replace).
$text_output_desc(insert,$do_insert).
$text_output_desc(selection,$setselection).
$text_output_desc(selectcabs,$do_selectcabs).
$text_output_desc(selectcrel,$do_selectcrel).
$text_output_desc(selectlabs,$do_selectlabs).
$text_output_desc(selectlrel,$do_selectlrel).
$text_output_desc(casesense,$setcasesense).
$text_output_desc(scandirection,$setscandirection).
$text_output_desc(textfont,$do_textfont).
$text_output_desc(textsize,$settextsize).
$text_output_desc(textface,$settextface).
$text_output_desc(acton,$do_acton).

$text_attr_desc(selection,$inq_selection).
$text_attr_desc(selectcabs,$getselectcabs).
$text_attr_desc(selectcrel,$inq_selectcrel).
$text_attr_desc(selectlrel,$inq_selectlrel).
$text_attr_desc(selectlabs,$getselectlabs).
$text_attr_desc(casesense,$getcasesense).
$text_attr_desc(scandirection,$getscandirection).
$text_attr_desc(textfont,$inq_textfont).
$text_attr_desc(textsize,$gettextsize).
$text_attr_desc(textface,$gettextface).
$text_attr_desc(csize,$getcsize).
$text_attr_desc(lsize,$getlsize).
$text_attr_desc(textwidth,$gettextwidth).
$text_attr_desc(charat,$charat).
$text_attr_desc(charpos,$getchar).

$font(V1,V2) :- var(V1,V2), !.
$font(F,N) :- symbol(F),!,F=N.
$font(0,systemfont) :- !.
$font(1,applfont) :- !.
$font(20,times) :- !.
$font(21,helvetica) :- !.
$font(22,courier) :- !.
$font(23,symbol) :- !.
$font(N,applfont) :- integer(N).
$font(F,N) :- symbol(N),!,F=N.

findfileposition(File,Pos) :-
	symbol(File),							% make sure file specified
	isfile(File,_,_),						% and that it is a file
	integer(Pos),							% do we like the position given
	$findfile(File,Window),					% find proper window name for file
	!,										% one attempt is all we require
	activewindow(WIndow, text),				% make sure window frontmost
	dotext(Window, [selectcabs(Pos,Pos),	% select proper character in window
					selectlrel(0,1)]).		% and then select current line

$findfile(File,Window) :-
	iswindow(Window, _, _, File).			% is there a window on the file ??
$findfile(File, Window) :-
	openwindow(text, File, _, _, _).		% or else open new window to file
