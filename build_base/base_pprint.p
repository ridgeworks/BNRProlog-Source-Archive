/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/base_pprint.p,v 1.4 1996/02/02 06:17:07 yanzhou Exp $
*
*  $Log: base_pprint.p,v $
 * Revision 1.4  1996/02/02  06:17:07  yanzhou
 * In $bind/2, an extra ',' is removed.
 *
 * Revision 1.3  1995/11/24  19:18:45  yanzhou
 * COLUMNS is getenv("COLUMNS") - 4.
 *
 * Revision 1.2  1995/11/24  18:53:37  yanzhou
 * $pplength() modified to use getenv("COLUMNS") instead of system("stty size").
 * Was causing background BNRProlog processes to be blocked on TTY I/O.
 *
 * Revision 1.1  1995/09/22  11:21:35  harrisja
 * Initial version.
 *
*
*/
/*
 *	 Ring 5+ of BASE
 */

%%%
%%% fancy printing stuff..
%%%
% Oct 1994 special handling of {_..} in portry

%%%% print(X..)
print(X..) :-                                     % Defaults to calling the user defined
    portray(1, X..).                              % portray, which if not defined uses our own

%%%% portray(Stream, X..) -- uses base pretty printer

portray(X..) :-
    tailvar(X..),
    !,
    swrite(1, X..).

portray(Stream, X..) :-
    tailvar(X..),
    !,
    swrite(Stream, X..).

portray(X) :-
    !,
    portray(1, X).

portray(Stream, Term) :-
    $pplength(Stream, MaxWidth, _),
    $pretty_print(Stream, Term, '', MaxWidth, 0).

portray_with_indent(Stream, Leader, Term, MaxTerms) :-
	swrite(Stream, Leader),
	$ppindent(Stream, '', Leader, NextLineIndent),
    $pplength(Stream, MaxWidth, _),
    $pretty_print(Stream, Term, NextLineIndent, MaxWidth, MaxTerms),
	!.

%%%
%%% $pretty_print(Stream, Term, Indent, MaxWidth, MaxTerms)   
%%%
% Pretty Print a term: break up expressions, lists, and structures if they won't fit on a line
% Special handling for constraints and cyclic structures.
% Indent is a symbol to be used on second and subsequent lines. 
%    Assumes already indented on first line
% MaxWidth is the number of characters per line we should try for.
% MaxTerms is the number of items in a list or functor that we print before ...
%    If 0, then the whole list is output.

$pretty_print(Stream, Term, Indent, MaxWidth, MaxTerms) :-
    not(not($pretty_print_aux(Stream, Term, Indent, MaxWidth, MaxTerms))),
    !.

$pretty_print_aux(Stream, Term, Indent, MaxWidth, MaxTerms) :- 
    acyclic(Term),                                      % no cycles in Term
    $bind_unconstrained_vars(Term, Constraints),        % bind what variables we can, return Constraints
    acyclic(Constraints),                               % no cycles in Constraints either
    !, 
    $remove_constraints((Term where Constraints), NewTerm),
    $pp(Stream, NewTerm, Indent, MaxWidth, MaxTerms, off, 1).

$pretty_print_aux(Stream, Term, Indent, MaxWidth, MaxTerms) :-  % term or constraints cyclic
    decompose(Term, Term1, Unifys),                         % remove loops and constraints in Term
    variables([Term1, Unifys], Vs, Tvs),                    % get variables and tail variables out
    Term = Term1,                                           % put back together, variables now have names
    $remove_nonvars(Vs, NewVs),                             % leave only variables, maybe constraints
    $remove_nontailvars(Tvs, NewTvs),                       % leave only tail variables, maybe constraints
    $bind_unconstrained_vars([NewVs, NewTvs], Constraints), % get list of constraints, bind rest variable names
    spanning_tree([Term, Constraints], [Term2, Cs], Unifys2),
	$build_where(Unifys2,Cs,Goal),
	$reduceterm(Term2,Term3,Unifys2),		% shorten long loops returned from spanning 
    $remove_constraints((Term3 where Goal), Term4),
    $pp(Stream, Term4, Indent, MaxWidth, MaxTerms, off, 1).

% $pp(Stream, Term, Indent, MaxWidth, MaxTerms, Brackets, splitWhere)   
% Pretty Print a term: break up expressions, lists, and structures if they won't fit on a line
% Indent is a symbol to be used on second and subsequent lines.
%    Assumes already indented on first line
% MaxWidth is the number of characters per line we should try for.
% MaxTerms is the number of items in a list or functor that we print before ...
%    If 0, then the whole list is output.
% Brackets=on enables printing of brackets around term,
%        usually off initially to suppress outer brackets around expressions
% splitWhere = 1  then try to print the 'where' stuff nicer
	
$pp(Stream, Term, Indent, MaxWidth, MaxTerms, Brackets, _) :-
    $pptry(Term, MaxTerms, Brackets, Ts, []),            % decompose Term into list of symbols Ts
	namelength(Indent, IL),                              % see how much room we have on this line
	Width is MaxWidth - IL,
    $fwrite(Symbol, 0, Width, Ts, 0, _),                 % write into symbol with maxlength condition
	!,                                                   % IF successful
    swrite(Stream, Symbol).                              % THEN dump symbol straight to stream, we're done

$pp(Stream, (P where Q), Indent, MaxWidth, MaxTerms, Brackets, 1) :-
	$pp(Stream, P, Indent, MaxWidth, MaxTerms, on, 0),
	swrite(Stream, '\n', Indent, 'where '),
	$ppindent(Stream, Indent, 'where ', NIndent),
	$pp(Stream, Q, NIndent, MaxWidth, MaxTerms, on, 0).

$pp(Stream, Term, Indent, MaxWidth, MaxTerms, Brackets, _) :-
    $ppform(Stream, Term, Indent, MaxWidth, MaxTerms, Brackets).   % too long, try splitting it


% $pptry, decompose term to a list of symbols, use difference lists to avoid concats
%   this should be quivalent to writeq, except for enforcement of MaxTerms

$pptry(Term,MaxTerms,Brackets,['[',Ss..],[Rest..]):-
    list(Term),
    MaxTerms > 0,
    Term = [X, Xs..],!,
    termlength(Term, ListLen, _),
	$pp_closer(ListLen,MaxTerms,']',Close),
    $pptry(X,MaxTerms,off,Ss,Rest1),
    $pptry_list(Xs,MaxTerms,MaxTerms,Rest1,[Close,Rest..]).

$pptry(Op(A,B),MaxTerms,Brackets,[Open,Ss..],[Rest..]) :-
    $op(_,Type,Op),
    $infix(Type),!,
	$pp_brackets(Brackets,Open,Close),
    $fwrite(SOp,0,0,[' ',Op,' '],0,_),
    $pptry(A,MaxTerms,on,Ss,[SOp,Rest1..]),
    $pptry(B,MaxTerms,on,Rest1,[Close,Rest..]).

$pptry(Op(A),MaxTerms,Brackets,[Open,SOp,Ss..],[Rest..]) :-
    $op(_,Type,Op),
    $prefix(Type),!,
	$pp_brackets(Brackets,Open,Close),
    $fwrite(SOp,0,0,[Op,' '],0,_),
    $pptry(A,MaxTerms,on,Ss,[Close,Rest..]).

$pptry(Op(A),MaxTerms,Brackets,[Open,Ss..],[Rest..]) :-
    $op(_,Type,Op),
    $postfix(Type),!,
	$pp_brackets(Brackets,Open,Close),
    $pptry(A,MaxTerms,on,Ss,[' ',Op,Close,Rest..]).

$pptry(Term,MaxTerms,_,[SP,'(',Ss..],[Rest..]) :-
    structure(Term),
    MaxTerms > 0,
    Term = P(X, Args..),!,
    termlength(Term, ListLen, _),
	$pp_closer(ListLen,MaxTerms,')',Close),
    $fwrite(SP,26,0,[P],0,_),
    $pptry(X,MaxTerms,off,Ss,Rest1),
    $pptry_list(Args,MaxTerms,MaxTerms,Rest1,[Close,Rest..]).

$pptry(Term,MaxTerms,_,[ST,Rest..],[Rest..]) :-
    $fwrite(ST,30,0,[Term],0,_).

$pptry_list([X, Xs..], ListLen, MaxTerms,[', ',Ss..],[Rest..]) :-
    ListLen > 1,
    $pptry(X,MaxTerms,off,Ss,Rest1),
    I is ListLen-1,I>=0,!,
    $pptry_list(Xs,I,MaxTerms,Rest1,Rest).      % L.C.O.

$pptry_list(_,ListLen,MaxTerms,Rest,Rest).     % end of list or MaxTerms exceeded

$pp_brackets(on,'(',')').
$pp_brackets(off,'','').

$pp_closer(ListLen,MaxTerms,Closing,Close):-
	ListLen>MaxTerms,!,
	$concat(',_..',Closing,Close).
$pp_closer(ListLen,MaxTerms,Close,Close).	% ListLen=<MaxTerms
	

% $ppform : formatted output for terms that are too long
$ppform(Stream, [X, Xs..], Indent, MaxWidth, MaxTerms, _) :-        % list
	!,
    swrite(Stream, '['),
    $concat(Indent, ' ', Indent1),
    $pp(Stream, X, Indent1, MaxWidth, MaxTerms, off, 0),
    $pplist(Stream, Xs, Indent1, MaxWidth, 1, MaxTerms),
    swrite(Stream, ']').

$ppform(Stream, {X, Xs..}, Indent, MaxWidth, MaxTerms, _) :- % curly /Oct 94/wjo
	!,
    swrite(Stream, '{'),
    $concat(Indent, ' ', Indent1),
    $pp(Stream, X, Indent1, MaxWidth, MaxTerms, off, 0),
    $pplist(Stream, Xs, Indent1, MaxWidth, 1, MaxTerms),
    swrite(Stream, '}').


$ppform(Stream, Op(A,B), Indent, MaxWidth, MaxTerms, Brackets) :-   % infix operator structure
    $op(_, Type, Op),
    $infix(Type),
	!,
	$ppform_infix(Stream, Op(A,B), Indent, MaxWidth, MaxTerms, Brackets).

$infix(xfx).
$infix(xfy).
$infix(yfx).     
     
$ppform_infix(Stream, Op(A,B), Indent, MaxWidth, MaxTerms, off) :-
    $pp(Stream, A, Indent, MaxWidth, MaxTerms, on, 0),
    swrite(Stream, ' ', Op, '\n', Indent),
    $pp(Stream, B, Indent, MaxWidth, MaxTerms, on, 0),
	!.
$ppform_infix(Stream, Op(A,B), Indent, MaxWidth, MaxTerms, _) :-
    swrite(Stream, '('),
    $concat(Indent, ' ', Indent1),
    $pp(Stream, A, Indent1, MaxWidth, MaxTerms, on, 0),
    swrite(Stream, ' ', Op, '\n', Indent1),
    $pp(Stream, B, Indent1, MaxWidth, MaxTerms, on, 0),
    swrite(Stream, ')').


$ppform(Stream, Op(A), Indent, MaxWidth, MaxTerms, Brackets) :-     % prefix operator structure
    $op(_, Type, Op),
    $prefix(Type),
	!,
	$ppform_prefix(Stream, Op(A), Indent, MaxWidth, MaxTerms, Brackets).
	
$prefix(fx).
$prefix(fy).
     
$ppform_prefix(Stream, Op(A), Indent, MaxWidth, MaxTerms, off) :-
	swrite(First, Op, ' '),
	swrite(Stream, First),
    $ppindent(Stream, Indent, First, Indent1),
    $pp(Stream, A, Indent1, MaxWidth, MaxTerms, on, 0),
	!.
$ppform_prefix(Stream, Op(A), Indent, MaxWidth, MaxTerms, _) :-
	swrite(First, '(', Op, ' '),
	swrite(Stream, First),
    $ppindent(Stream, Indent, First, Indent1),
    $pp(Stream, A, Indent1, MaxWidth, MaxTerms, on, 0),
    swrite(Stream, ')').


$ppform(Stream, Op(A), Indent, MaxWidth, MaxTerms, Brackets) :-     % postfix operator structure
    $op(_, Type, Op),
    $postfix(Type),
	!,
	$ppform_postfix(Stream, Op(A), Indent, MaxWidth, MaxTerms, Brackets).

$postfix(xf).
$postfix(yf).
     
$ppform_postfix(Stream, Op(A), Indent, MaxWidth, MaxTerms, off) :-
    $pp(Stream, A, Indent, MaxWidth, MaxTerms, on, 0),
    swrite(Stream, ' ', Op),
	!.
$ppform_postfix(Stream, Op(A), Indent, MaxWidth, MaxTerms, _) :-
    swrite(Stream, '('),
    $concat(Indent, ' ', Indent1),
    $pp(Stream, A, Indent1, MaxWidth, MaxTerms, on, 0),
    swrite(Stream, ' ', Op, ')').


$ppform(Stream, F(X,Xs..), Indent, MaxWidth, MaxTerms, _) :-         % other structures
	!,
	$outstream(Stream, FileP),
    $fwrite(FileP,26,0,[F],0,L),
    $fwrite(FileP,0,0,['('],0,_),
    successor(L, L1),                   % include ( in length
    $pplead(Stream, Indent, L1, Indent1),
    $pp(Stream, X, Indent1, MaxWidth, MaxTerms, off, 0),
    $pplist(Stream, Xs, Indent1, MaxWidth, 1, MaxTerms),
    $fwrite(FileP,0,0,[')'],0,_).

$ppform(Stream, Term, _, _, MaxTerms, _) :-         % catch all, output overlength term anyway
	$outstream(Stream, FileP),
    $fwrite(FileP,26,0,[Term],0,_).


% $pplist outputs the rest of a list
$pplist(_, [], _, _, _, _).              
$pplist(Stream, _, _, _, X, X) :-
    swrite(Stream, ', _..').
$pplist(Stream, [X,Xs..], Indent, MaxWidth, NumItems, MaxTerms) :-
    swrite(Stream, ',\n', Indent),
    $pp(Stream, X, Indent, MaxWidth, MaxTerms, off, 0),
    successor(NumItems, Next),
    $pplist(Stream, Xs, Indent, MaxWidth, Next, MaxTerms).


% $pplead generates a Nleadin from Indent with Pad additional spaces
$pplead(Stream, Indent, Pad, NIndent) :-
    stream(Stream, _, _, FFname),                   % IF Stream is defined
    iswindow(Window, text, _, FFname),              %   AND it has a window attached
    inqtext(Window, [textwidth('0', W0),            %   AND we can get an average char size
	                 textwidth(' ', W)]),           %   AND we can get a space size
	W > 0, W0 > 0,									%   AND the sizes are valid
	!,                                              % THEN
	NumSpaces is Pad * W0 // W,                     %   compute number of spaces needed for same width as '0000'
    $makespaces(NumSpaces,[],X),                    %   make the spaces
    $concat(Indent,X,NIndent).                      %   combine with existing indent
$pplead(_, Indent, Pad, NIndent) :-                 % ELSE
    $makespaces(Pad,[],X),                          %   make number of spaces suggested
    $concat(Indent,X,NIndent).                      %   combine with existing indent

% similar to pplead, except that pad is a string to use as a pad 
% (make equivalent number spaces as pad)
$ppindent(Stream, Indent, Pad, NIndent) :-
    stream(Stream, _, _, FFname),                   % IF Stream is defined
    iswindow(Window, text, _, FFname),              %   AND it has a window attached
    inqtext(Window, [textwidth(Pad, W0),            %   AND we can get an average char size
	                 textwidth(' ', W)]),           %   AND we can get a space size
	W > 0, W0 > 0,									%   AND the sizes are valid
	!,                                              % THEN
	NumSpaces is W0 // W,                           %   compute number of spaces needed for same width as '0000'
    $makespaces(NumSpaces, [], X),                  %   make the spaces
    $concat(Indent, X, NIndent).                    %   combine with existing indent
$ppindent(_, Indent, Pad, NIndent) :-               % ELSE
    namelength(Pad, L),                             %   see how many characters are there
    $makespaces(L, [], X),                          %   make number of spaces suggested
    $concat(Indent, X, NIndent).                    %   combine with existing indent

% make a list of spaces and convert to symbol, assumes N>=0
$makespaces(0,List,Spaces):-name(Spaces,List),!.
$makespaces(1,[S..],Spaces):-name(Spaces,[32,S..]),!.
$makespaces(2,[S..],Spaces):-name(Spaces,[32,32,S..]),!.
$makespaces(3,[S..],Spaces):-name(Spaces,[32,32,32,S..]),!.
$makespaces(N,S,Spaces):-   % N>=4
    N1 is N-4,
    $makespaces(N1,[32,32,32,32,S..],Spaces).  % L.C.O.

% For a given window, we assume that 20 pixels are used for the scroll bars and
% that the average width of a character is 2/3 of the character's height 
% (true for default Monaco font).
% N.B. for now this initial clause never succeeds

$pplength(Stream, LineWidth, Spaces) :-
    stream(Stream, _, _, FFname),                   % IF Stream is defined
    iswindow(Window, text, _, FFname),              %   AND it has a window attached
    inqtext(Window, [textwidth('0', W0),            %   AND we can get an average char size
	                 textwidth(' ', W)]),           %   AND we can get the size of a space
	W > 0, W0 > 0,									%   AND the sizes are valid
    sizewindow(Window, Width, _),                   %   AND we can get window width
    mbarheight(Menu),                               %   AND we get an approx scroll bar width
	!,                                              % THEN
    LineWidth is ((Width - Menu) // W0) - 1,        %   determine average number of chars in line
	NumSpaces is 4 * W0 // W,                       %   compute number of spaces needed for same width as '0000'
    $makespaces(NumSpaces, [], Spaces).             %   make a run of spaces for tab
$pplength(_, LineWidth, '    ') :-
	$getCOLUMNS(LineWidth),
% yanzhou@bnr.ca:24/11/95:commented out
% reason: stty was causing background BNRProlog processes
%         to be blocked on TTY I/O.
%	system("exit `stty size 2>> /dev/null | awk '{print $2}'`", R),
%	system("test `uname` = SunOS", 0),				% only works on Suns
%   system("exit `stty size | awk '{print $2}'`", R),
%	LineWidth is R // 256,
	LineWidth > 20,
	!.
$pplength(_, 76, '    ').                           % ELSE line length is 76 with a tab of 4

$getCOLUMNS(COLUMNS) :-							    % getenv("COLUMNS")
	getenv("COLUMNS", ENVCOLUMNS),
    concat(ENVCOLUMNS, ". ", S),
	sread(S, COLUMNS),
	integer(COLUMNS),
	COLUMNS is COLUMNS - 4,
	COLUMNS > 0,
	!.
	
$bind_unconstrained_vars(Term, Constraints) :-
    variables(Term, Vs, TVs, CSs),                  % get variables, tail variables, and constraints (may be duplicates)
	$transform_intervals(CSs, Cs),                  % prettify interval constraints
    $rm_dup(Cs, Constraints),                  		% remove duplicate constraints
    $bind_named_vars(Vs, Constraints),              % bind unconstrained, named vars
    $bind_named_vars(TVs, Constraints).             % bind unconstrained, named tailvars

$transform_intervals([], []).
$transform_intervals([X, Xs..], [Y, Ys..]) :-
    $transform_interval(X, Y),
    !,
	$transform_intervals(Xs, Ys).

/* update for new interval arithmetic system  Crias 5 Feb 94 wjo */	

$transform_interval(freeze(V, $interval(V, _, L, U)), V : real(L, U)).
$transform_interval(freeze(V, $integral(V, _, L, U)), V : integer(L1, U1)) :- 
    L1 is round(L),
    U1 is round(U).
$transform_interval(freeze(V, $boolean(_, _)),  V : boolean).
$transform_interval(freeze(V, [$interval(V,_, L, U), R..]), [V : real(L, U), freeze(V, R)]).
$transform_interval(freeze(V, [$integral(V,_, L, U), R..]), [V : integer(L1, U1), freeze(V, R)]) :- 
    L1 is round(L),
    U1 is round(U).
$transform_interval(freeze(V, [$boolean(_,_), R..]),  [V : boolean, freeze(V, R)]).
$transform_interval(X, X).

/*  old code (for Crias3):	
$transform_interval(freeze(V, $interval(V, L, U, _)), V : real(L, U)).
$transform_interval(freeze(V, $integral(V, L, U, _)), V : integer(L1, U1)) :- 
    L1 is round(L),
    U1 is round(U).
$transform_interval(freeze(V, $boolean(V, L, U, _)),  V : boolean).
$transform_interval(freeze(V, [$interval(V, L, U, _), R..]), [V : real(L, U), freeze(V, R)]).
$transform_interval(freeze(V, [$integral(V, L, U, _), R..]), [V : integer(L1, U1), freeze(V, R)]) :- 
    L1 is round(L),
    U1 is round(U).
$transform_interval(freeze(V, [$boolean(V, L, U, _), R..]),  [V : boolean, freeze(V, R)]).
$transform_interval(X, X).
*/

% bind unconstrained variables to their names
$bind_named_vars([],_).
$bind_named_vars([V,Vs..],Cs):-
    not(ground(V)),         % just in case it was previously bound (variables doesn't dedup)
    $notconstrained(Cs,V),  % don't bind constrained variables
    bind_vars(V),
	!,
    $bind_named_vars(Vs,Cs).
$bind_named_vars([V,Vs..],Cs):-  % couldn't be bound to name
    $bind_named_vars(Vs,Cs).

$notconstrained([],_).
$notconstrained([freeze(CV,_),Cs..],V):-
	not(breadth_first_compare(V,CV,@=)),
    $notconstrained(Cs,V).

$remove_constraints(Term, NewTerm) :-
    $fix_copy(Term,Term1),
		%  Note: the rest of this clause has the sole effect of copying the term
		%  to a new set of variables which are unconstrained so that bind_vars can be used
		%  on it. The drawback is that the variables will have therefore appear to have "moved"
		%  each time they are printed. It appears that deleting the rest of this clause
		% fixes this problem.
	new_obj(copy(Term1),Op,$local),   % make a copy
	get_obj(Op,copy(NewTerm),$local),
	dispose_obj(Op,$local),
    bind_vars(NewTerm),!.            % and bind remaining unconstrained variables

$fix_copy(Term where [],Term):-!.
$fix_copy(Term,Term).

$build_where([],Cs,Cs).		% finished 'Unifys', add constraints
$build_where([U,Us..],Cs,U2s):-	% remove unifys due to common subexpressions
	U,					% 1. execute unification,
	acyclic(U),!,		% 2. if X still acyclic, it was a common subexpression
	$build_where(Us,Cs,U2s).
$build_where([U,Us..],Cs,[U,U2s..]):-	% unification built a cycle
	$rm_variant(Us,U,U1s), 				% remove variants in remainder
	$build_where(U1s,Cs,U2s).			% so add it to where list

$rm_variant([],_,[]).
$rm_variant([V,Us..],U,[U1s..]):-
	$variant(U,V),!,	% test and unifys if they're variants
	$rm_variant(Us,U,U1s).
$rm_variant([V,Us..],U,[V,U1s..]):-		
	$rm_variant(Us,U,U1s).

% U and V are variants if identical except for var renaming
$variant(U,V):-
	variables(U,Vs,TVs),
	$bind(Vs,TVs),	% bind vars to unique values
	U\=V,			% if they unify, fail to unbind and test opposite direction
	failexit($variant).	% they didn't unify, $variant fails
$variant(U,V):-
	variables(V,Vs,TVs),
	$bind(Vs,TVs),	% bind vars to unique values
	U\=V,			% if they unify, fail to unbind and then unify U and V
	failexit($variant).	% they didn't unify, $variant fails
$variant(U,U).		% they're variants, unify them

% bind vars and tailvars in lists to unique values, cheap version of bind_vars
$bind([],[]):-!.
$bind([N,Vs..],TVs):-
	!,
	gensym($$,N),
	$bind(Vs,TVs).
$bind([],[[N],TVs..]):-
	gensym($$,N),
	$bind([],TVs).
	
$remove_nonvars([], []).
$remove_nonvars([V, Vs..], [V, NewVs..]) :-
    var(V),
    $remove_nonvars(Vs, NewVs).
$remove_nonvars([_, Vs..], [NewVs..]) :-
    $remove_nonvars(Vs, NewVs).

$remove_nontailvars([], []).
$remove_nontailvars([[TV..], Vs..], [[TV..], NewVs..]) :-
    tailvar(TV..),
    $remove_nontailvars(Vs, NewVs).
$remove_nontailvars([_, Vs..], [NewVs..]) :-
    $remove_nontailvars(Vs, NewVs).

% reduce a term containing possible looped lists which are longer than necessary
$reduceterm(T,T,_):-var(T),!.
$reduceterm(T,T,_):-atomic(T),!.
$reduceterm(F(Args..),F(Args1..),Unifys):-
	symbol(F),!,
	$reducelist(Args,Args1,_,Unifys).	% N.B., can't have looped structures
$reduceterm(L,L2,Unifys):-
	%list(L),
	$reducelist(L,L1,Last,Unifys),
	[$getunify(Last,Unifys,Loop),
	 $gettail(Loop,Last1),
	 breadth_first_compare(Last,Last1,@=)]->
		$reduceloop(L1,Loop,L2);
		L2=L1,
	!.

$reducelist([T..],[T..],[T..],Unifys):-tailvar(T..).
$reducelist([],[],[],Unifys).
$reducelist([L,Ls..],[L1,L1s..],Last,Unifys):-
	$reduceterm(L,L1,Unifys),
	$reducelist(Ls,L1s,Last,Unifys).

$reduceloop(List,Loop,Loop):-   % must get here before the end of the list
    not(not(List=Loop)).        % if they unify, it's the best form
$reduceloop([X,Xs..],Loop,[X,Etc..]):-   % otherwise try it on sublist
    $reduceloop(Xs,Loop,Etc).

%% $op/3 defined in case user overloads op/3 with a variable as the name which
%% doesn't add an operator, just a definition which gives us problems printing
$op(Precedence, Type, Name) :-
	op(Precedence, Type, Name1),
	symbol(Name1,Type),
	integer(Precedence),
	Name=Name1.


%%%%
%%%% listing  - version 1.0  code reviewed
%%%%          - should run as a loadable context given, 
%%%%             $member(X, [X, Ys..]).
%%%%             $member(X, [Y, Ys..]) :- $member(X, Ys). 

%%%% listing/0  

listing() :-                                % List all clauses in topmost context.
    context(Cx),                            % Get name of topmost context; Commit to 
    !,                                      % remove "listing" choice points; no arity cks.
    $listing_aux(1, _, Cx).                 % List to stream 1

%%%% listing/1 

listing(P) :-                               % List all clauses defining P.
    !,                                      % Commit to remove "listing" choice points.
    $listing_aux(1, P, _).                  % List to stream 1
 
%%%% listing/2 

listing(P, Cx) :-                           % List all clauses defining P in Cx.
    !,                                      % Commit to remove "listing" choice points
    $listing_aux(1, P, Cx).                 % List to stream 1
 
%%%% listing/3

listing(Stream, P, Cx) :-
    integer(Stream),                        % Require Stream to be just that
    stream(Stream, _, _, _),                % Note, steam instantiates Stream if it is a var
    $listing_aux(Stream, P, Cx).

$listing_aux(Stream, P1, Cx) :-             % user specified complete functor
    structure(P1),
    P1 = P(Args..),
    $listing_validate(P, Cx),               % generate/test P in optional context
    $listing(Stream, P(Args..), Cx),        % show it to us
    fail.                                   % get other possible predicates to list
$listing_aux(Stream, P, Cx) :-
    not(structure(P)),
    $listing_validate(P, Cx),               % generate/test P
    $listing(Stream, P(_..), Cx),           % show it to us
    fail.                                   % get other possible predicates to list
$listing_aux(Stream, P, Cx):-               % so we always succeed
	nl(Stream).								% final newline

$listing_validate(P, Cx) :-                 % validate P in context specified
    nonvar(Cx),
    context(Cx, Fn),                        % Get file name associated with Cx
    contents(Cx, Fn, Ps),                   % Use contents for efficiency
    !,  
    $member(P, Ps).                         % Check or generate P
$listing_validate(P, Cx) :-                 % validate P if no context specified
    var(Cx),
    predicate(P).

%%%% $listing

$listing(Stream, P(Args..), Cx) :-          % Case where P is visible 
    visible(P),                             % Commit for efficiency, $listing called
    !,                                      % from within a forced backtrack
    foreach(definition((P(Args..) :- B), Cx) do [
        bind_vars((P(Args..) :- B)),        % Ground the clause making var names correct.
        nl(Stream),                         % Begin with a new line - fails if Stream unbound.
        $pp_clause(Stream, (P(Args..) :- B), Cx) ]).

$listing(Stream, P(Args..), Cx) :-          % Case where P is hidden
    $pplength(Stream, LineLength, Tab),     % Get length of text line for Stream.
    foreach(clause_head(P(Args..), Cx) do [  
        bind_vars(P(Args..)),               % Ground the head.
        nl(Stream),                         % Begin with a new line - fails if Stream unbound.
        $pp(Stream, P(Args..), '', LineLength, 0, off, 0), 
        swrite(Stream, ' :- [ ... ].', Tab, '% Context: \"', Cx, '\", Hidden Definition.\n')]).


%%%% $pp_clause(Stream, Clause, Context)
% NOTES:
% (1) $pp_clause assumes Clause to be ground. (i.e., that bindvars has been called prior).
% (2) $pp is used to pretty print clauses w.r.t. breaking up expressions, lists, and structures 
%     if they won't fit on a line. 
% (3) The line on which the last portion of the clause head is output will also contain the
%     appropriate punctuation (":-" or ".") and the context name comment.

$pp_clause(Stream, (Head :- []), Cx) :-                 % CASE: clause to be output is a fact.   
    !,                                                  % Commit (to remove choicepoint).
    $pplength(Stream, LineLength, Tab),                 % Get length of text line for Stream.
    $pphead(Stream, Head, Cx, '.', LineLength, Tab).    % And pretty print Head.

$pp_clause(Stream, (Head :- Body), Cx) :-               % CASE: clause with a body.
    $pplength(Stream, LineLength, Tab),                 % Get length of text line and tab for Stream.
    $pphead(Stream, Head, Cx, ' :-', LineLength, Tab),  % Pretty print the head.
    swrite(Stream, Tab),                                % Indent for body.
    $pp(Stream, Body, Tab, LineLength, 0, off, 0),      % Pretty print the body.
    swrite(Stream, '.\n').                              % Terminate with a period and a newline.

$pphead(Stream, Head, Cx, Punc, LineLength, Tab) :-     % Output head and context
    $pp(Stream, Head, '', LineLength, 0, off, 0),       % Output the Head (with a null Leadin).
    swrite(Stream, Punc, Tab, '% Context: \"',Cx,'\"\n'). % Together with context defined in.

