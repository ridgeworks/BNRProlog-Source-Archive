/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/textbox.p,v 1.1 1995/09/22 11:28:59 harrisja Exp $
*
*  $Log: textbox.p,v $
 * Revision 1.1  1995/09/22  11:28:59  harrisja
 * Initial version.
 *
*
*/

$textbox(GC, L, T, R, B, Text, Start, TextOutProc, TextOutArgs) :-
	name(Text,TextList),
	inqtextfont_C(GC,Font),
	inqtextsize_C(GC,Size),
	inqtextface_C(GC,Face),
	$$fontinfo(Font,Size,Face,Ascent,Descent,Leading,MaxWidth,AvgWidth),
	LineWidth is R-L,
	Y1 is T+Ascent,
	YMax1 is B-Descent,
	LineHeight is Ascent+Descent,
	TabWidth is 8*AvgWidth,
	$word_wrap(TextList,0,Y1,0,LineWidth,LineHeight,L,YMax1,Start,TabWidth,GC,TextOutProc,TextOutArgs).

% $word_wrap(Text,Len,Y,CharPos,LineWidth,LineHeight,X,YMax,Start,TabWidth,GC,TextOutProc,TextOutArgs).
$word_wrap([],_,_,_,_,_,_,_,_,_,_,_,_) :- !.	% done
$word_wrap(_,_,Y,_,_,_,_,YMax,_,_,_,_,_):- 		% past bottom of box, done
	Y > YMax,
	!.
$word_wrap([NL,Text..],Len,Y,CharPos,LineWidth,LineHeight,X,YMax,Start,Etc..):-  % newline
	$nlcr(NL),
	!, 
	$next_line_pos(CharPos,Start,Y,Y1,LineHeight),
	successor(CharPos,CharPos1),
	$word_wrap(Text,0,Y1,CharPos1,LineWidth,LineHeight,X,YMax,Start,Etc..).
$word_wrap(Text,Len,Y,CharPos,LineWidth,LineHeight,X,YMax,Start,TabWidth,GC,TextOutProc,TextOutArgs) :-
	$next_word(Text,Word,Text1),
	$word_width(GC,Word,WL,TabWidth,Len),
	Len1 is Len+WL,
	!,
	$$word_wrap(Word,Text,Text1,Len,Len1,Y,CharPos,LineWidth,LineHeight,X,YMax,Start,TabWidth,GC,TextOutProc,TextOutArgs).

$$word_wrap(Word,Text,Text1,Len,Len1,Y,CharPos,LineWidth,LineHeight,X,YMax,Start,TabWidth,GC,TextOutProc,TextOutArgs) :-
	Len1 > LineWidth, % word won't fit on this line, start new line
	!,
	$next_line_pos(CharPos,Start,Y,Y1,LineHeight),
	$end_line(Len,Text,TextN,Word,Text1,CharPos,CharPos1,LineWidth,Start,X,Y,GC,TextOutProc,TextOutArgs),
	!,
	$word_wrap(TextN,0,Y1,CharPos1,LineWidth,LineHeight,X,YMax,Start,TabWidth,GC,TextOutProc,TextOutArgs).

$$word_wrap(Word,Text,Text1,Len,Len1,Y,CharPos,LineWidth,LineHeight,X,YMax,Start,TabWidth,GC,TextOutProc,TextOutArgs) :-
	% put word at end of current line
	Pos is X+Len,
	$text_at(CharPos,Start,CharPos1,Pos,Y,Word,TextOutProc,TextOutArgs),
	!,
	$word_wrap(Text1,Len1,Y,CharPos1,LineWidth,LineHeight,X,YMax,Start,TabWidth,GC,TextOutProc,TextOutArgs).

$end_line(0,Text,TextN,Word,Text1,CharPos,CharPos2,LineWidth,Start,X,Y,GC,TextOutProc,TextOutArgs) :-
	% line is empty -> current word won't fit by itself on a line so we must split it
	!,
	$fit_word(Word,Word1,Word2,0,LineWidth,GC),
	$text_at(CharPos,Start,CharPos1,X,Y,Word1,TextOutProc,TextOutArgs),
	$append(Word2,Text1,Text2),
	$trim_white_space(Text2,TextN,TrimLen),
	CharPos2 is CharPos1+TrimLen.
$end_line(Len,Text,TextN,Word,Text1,CharPos,CharPos1,_..) :-
	% line not empty
	$trim_white_space(Text,TextN,TrimLen), % trim white space from beginning of next line
	CharPos1 is CharPos+TrimLen.
	
$next_line_pos(CharPos,Start,Y,Y,_) :-
	CharPos < Start,
	!.
$next_line_pos(_,_,Y,Y1,LineHeight) :-
	Y1 is Y+LineHeight.

$next_word([],[],[]).
$next_word([N,Text..],[N],Text) :-
	$nlcr(N),
	!.
$next_word([D,Text..],[D],Text) :-
	$delim(D),
	!.
$next_word(Text,W,Text1) :-
	$$next_word(Text,W,Text1).

$$next_word([],[],[]).
$$next_word([D,Text..],[],[D,Text..]) :-
	$delim(D);$nlcr(D),
	!.
$$next_word([C,Cs..],[C,W..],Text) :-
	$$next_word(Cs,W,Text).

$text_at(CharPos,Start,CharPos1,X,Y,Text,TextOutProc,TextOutArgs) :-
	termlength(Text,Len,_),
	CharPos1 is CharPos+Len,
	!,
	$$text_at(CharPos,Start,X,Y,Text,TextOutProc,TextOutArgs).

$$text_at(CharPos,Start,X,Y,Text,TextOutProc,TextOutArgs):-
	CharPos>=Start,
	!,
	name(Str,Text),
	TextOutProc(TextOutArgs,X,Y,Str).
$$text_at(_,_,_,_,_,_,_).

$trim_white_space([],[],0).
$trim_white_space([C,Cs..],Cs,1) :-
	$nlcr(C),
	!.
$trim_white_space([D,Cs..],Cs,1) :-
	$delim(D),
	!.
$trim_white_space(T,T,0).

$delim(0' ). % blank
$delim(0'	). % tab
$nlcr(NL):-name('\n',[NL]).
$nlcr(CR):-name('\r',[CR]).

$word_width(GC,[0'	],W,TabWidth,Width) :-
	W is TabWidth - (Width mod TabWidth).
$word_width(GC,W,WW,_,_) :-
	name(S,W),
	textwidth_C(GC,S,WW).

$fit_word([],[],[],_,_,_).
$fit_word([0'	],[0'	],[],_,_,_). % tab always fits
$fit_word([C,Cs..],Word1,Word2,W,LW,GC) :-
	$word_width(GC,[C],CW,0,0),
	W1L is W+CW,
	$$fit_word(W1L,[C,Cs..],Word1,Word2,LW,GC).
$$fit_word(W1L,[C,Cs..],[C,W1..],Word2,LW,GC) :-
	W1L < LW,
	!,
	$fit_word(Cs,W1,Word2,W1L,LW,GC).
$$fit_word(W1L,Word2,[],Word2,LW,GC).


$textlines(GC, [T1,T2,T3], Width, Lines) :-
	swrite(Text,T1,T2,T3),
	$textlines(GC,Text,Width,Lines).
$textlines(GC, '', Width , 0) :- !.
$textlines(GC, Text, Width, Lines) :-
	name(Text,TextList),
	inqtextfont_C(GC,Font),
	inqtextsize_C(GC,Size),
	inqtextface_C(GC,Face),
	$$fontinfo(Font,Size,Face,Ascent,Descent,Leading,MaxWidth,AvgWidth),
	TabWidth is 8*AvgWidth,
	$line_count(TextList,0,0,1,Lines,Width,TabWidth,GC).

% $line_count(Text,Len,CharPos,Lines,TotalLines,Width,TabWidth,GC).
$line_count([],_,_,Total,Total,_,_,_) :- !.	% done
$line_count([NL,Text..],Len,CharPos,Lines,TotalLines,Width,Etc..):-  % newline
	$nlcr(NL),
	!, 
	successor(CharPos,CharPos1),
	successor(Lines,Lines1),
	$line_count(Text,0,CharPos1,Lines1,TotalLines,Width,Etc..).
$line_count(Text,Len,CharPos,Lines,TotalLines,Width,TabWidth,GC) :-
	$next_word(Text,Word,Text1),
	$word_width(GC,Word,WL,TabWidth,Len),
	Len1 is Len+WL,
	!,
	$$line_count(Word,Text,Text1,Len,Len1,CharPos,Lines,TotalLines,Width,TabWidth,GC).

$$line_count(Word,Text,Text1,Len,Len1,CharPos,Lines,TotalLines,Width,TabWidth,GC) :-
	Len1 > Width, % word won't fit on this line, start new line
	!,
	$$end_line(Len,Text,TextN,Word,Text1,CharPos,CharPos1,Width,GC),
	$start_line(TextN,CharPos1,Lines,TotalLines,Width,TabWidth,GC).

$$line_count(Word,Text,Text1,Len,Len1,CharPos,Lines,TotalLines,Width,TabWidth,GC) :-
	% put word at end of current line
	!,
	termlength(Word,CharLen,_),
	CharPos1 is CharPos+CharLen,
	$line_count(Text1,Len1,CharPos1,Lines,TotalLines,Width,TabWidth,GC).

$$end_line(0,Text,TextN,Word,Text1,CharPos,CharPos2,Width,GC) :-
	% line is empty -> current word won't fit by itself on a line so we must split it
	!,
	$fit_word(Word,Word1,Word2,0,Width,GC),
	$append(Word2,Text1,Text2),
	$trim_white_space(Text2,TextN,TrimLen),
	termlength(Word1,Len,_),
	CharPos1 is CharPos+Len,
	CharPos2 is CharPos1+TrimLen.
$$end_line(Len,Text,TextN,Word,Text1,CharPos,CharPos1,_..) :-
	% line not empty
	$trim_white_space(Text,TextN,TrimLen), % trim white space from beginning of next line
	CharPos1 is CharPos+TrimLen.
	
$start_line([],_,TotalLines,TotalLines,_,_,_). % nothing left, don't start a new line
$start_line(TextN,CharPos,Lines,TotalLines,Width,TabWidth,GC) :- % start a new line
	successor(Lines,Lines1),
	$line_count(TextN,0,CharPos,Lines1,TotalLines,Width,TabWidth,GC).

