/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/base2.p,v 1.1 1995/09/22 11:21:19 harrisja Exp $
*
*  $Log: base2.p,v $
 * Revision 1.1  1995/09/22  11:21:19  harrisja
 * Initial version.
 *
*
*/

/*
 *  Ring 2 of BASE
 */

$base(2).

%%%
%%%  Support for reading and writing symbols (from streams in base 4)
%%%

sread(Stream, Term) :-                          % Read from a symbol (variadic not supported).
    symbol(Stream),                             % Confirm Stream is a symbol.
    !,                                          % Commit, 
    $fread(Stream, T, 0, 0),                    % Do it, ensuring IOResult = 0, no error messages
    $coerce_term(T, Term).                      % coerce result to whats expected
%% clause for reading from stream in R4


%%%% get_term(Stream,Term,IOResult)
get_term(Stream,Term,IOResult) :-             	% Observe, nothing special for sdtin.
	$instream(Stream,FileP),
    $fread(FileP,T,IOResult,0),             	% Do the read, no error message if error
    $coerce_term(T, Term).                      % coerce result to whats expected


%% stream output predicates
%% the second term of $fwrite is a flag
%% bit 0 - trailing period
%%     1 - print intervals
%%     2 - blanks between items
%%     3 - commas between items
%%     4 - quoting

%%%% put_term(?Stream, +Term, ?IOResult)
put_term(Stream, Term, IOResult) :-                        % Output to a stream/write to a symbol.
	$outstream(Stream,FileP),
    $fwrite(FileP,21,0,[Term],IOResult,_).


%%%% swrite(Stream, Xs..) 
swrite(Stream, Xs..) :-                                    % A write into stream, or to a symbol
	$outstream(Stream,FileP),
    $fwrite(FileP,0,0,[Xs..],0,_).      


%%%% swriteq(Stream, Xs..) 
swriteq(Stream, Xs..) :-                                   % A write into stream, or to a symbol
	$outstream(Stream,FileP),
    $fwrite(FileP,16,0,[Xs..],0,_).  


% valid input stream is a symbol or valid stream
$instream(Stream,Stream):-
	symbol(Stream),!.
$instream(Stream,FileP):-
	$validstream(Stream,FileP).					%% in R4, fails in R2, R3

% valid output stream is a variable, symbol (for unification) or valid stream
$outstream(Stream,Stream):-
	var(Stream),!.
$outstream(Stream,Stream):-
	symbol(Stream),!.		
$outstream(Stream,FileP):-
	$validstream(Stream,FileP).					%% in R4, fails in R2, R3


$coerce_term([X, Y..], Res) :-
	structure(X), $coerce_struct([X, Y..], Res), !.
$coerce_term([X], X) :- !.
$coerce_term(X, X).

$coerce_struct([Op(Args..), Rest..], Body) :- var(Op), !, $coerce_body(Rest, Op(Args..), Body).
$coerce_struct([A :- B, C..], A :- Body) :- $coerce_body(C, B, Body).
$coerce_struct([:- A, B..], :- Body) :- $coerce_body(B, A, Body).
$coerce_struct([?- A, B..], ?- Body) :- $coerce_body(B, A, Body).
$coerce_struct([A, B..], Body) :- $coerce_body(B, A, Body).

$coerce_body([X..], Only, [Only, X..]) :- tailvar(X..).
$coerce_body([], Only, Only).
$coerce_body([Rest..], First, [First, Rest..]).
