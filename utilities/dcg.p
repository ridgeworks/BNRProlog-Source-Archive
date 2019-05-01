/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/dcg.p,v 1.1 1995/09/22 11:23:45 harrisja Exp $
*
*  $Log: dcg.p,v $
 * Revision 1.1  1995/09/22  11:23:45  harrisja
 * Initial version.
 *
*
*/

/*
 *   DCG - Definite Clause Grammar Translator
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1988 
 */


 
/*
This file contains a translator for
definite clause grammars:

  h(A..) --> b1(A1..), b2(A2..),...bn(An..).

maps to:
  h(A..,In,Out):- <b(A1..,In,I2), b2(A2..,I2,I3,),...
                          bn(An..,Inn,Out)>.
For example this translator accepts the DCG rules

sentence --> [Noun], {n(Noun)}, [Verb], {v(Verb)}.
terminal --> [fred].


Usage:  execute  dcg_load( filename)  - reads named file , transforms, 
        and assert dcg expressions into the current context. 

To test this program, load it into BNR Prolog, cut and paste the DCG rules
below into a file (say 'terry.grm') and execute the goal:

?- dcg_load('terry.grm').

This loads the grammar rules from the file 'terry.grm' which allows
you to parse a sentence, with the question

?- s(Sentence,[terry,writes,a,program,that,halts]).

%%    -------------------------  CUT HERE --------------------------------
%% Grammar adapted from Pereira and Shieber "Prolog and Natural Language
%% Processing" Program 3.11 p. 75

s(s(NP,VP)) --> np(NP),vp(VP).
np(np(Det,N,Rel)) --> det(Det),n(N),optrel(Rel).
np(np(PN)) --> pn(PN).
vp(vp(TV,NP)) --> tv(TV),np(NP).
vp(vp(IV)) --> iv(IV).
optrel(rel(epsilon))-->[].
optrel(rel(pron(that),VP)) --> [that],vp(VP).

pn(pn(terry )) --> [terry].
pn(pn(shlrdu)) --> [shrldu].
iv(iv(halts)) --> [halts].
det(det(a)) --> [a].
n(n(program)) --> [program].
tv(tv(writes)) --> [writes].
%% ------------------------------ END CUT HERE ----------------------------
*/

'C'([X|S],X,S) :- !.
'C'(A,X,S) :- 
    symbol(A),
    !,
    name(A,B),
    'C'(B,X,S).

op(1200, xfx, '-->').

exp_term( [S] ,In,'C'(In,S,Out),Out) :- !.
exp_term( [] ,Out,true,Out).
exp_term( {A..} ,In, [A..] ,In):-!.         % [A..] is a list of prolog goals
exp_term( A;B,In,Ae;Be,Out):- exp_term(A,In,Ae,Out), exp_term(B,In,Be,Out),!. % ; means or
exp_term( F(A..) ,In,F(NA..),Out):-         % put the extra arguments at the end
     $app([A..],[In,Out],[NA..]),
     !.
exp_term( !,Out,!,Out):- !.                  % ! cuts the grammar rule

exp_term( F,In,F(In,Out),Out):- symbol(F),!. % symbols are assumed to be non-terminals

exp_body( [], [], In, In):-!.
exp_body( [B|Bs] , New, In, Out):-
     !,
     exp_term(B, In, Nb, In1),
     Nb=true
        -> New=Nbs
        ;  
     (list(Nb) -> $app(Nb,Nbs,New) ;
      New=[Nb|Nbs]),
     exp_body( Bs, Nbs, In1,Out).
exp_body( B ,In, Nb, Out):-exp_body( [B],In,Nb,Out).
 

expand_term( Hd --> Body, Nhd:-Nbody):-!,
    exp_term(Hd,In,Nhd,Out),
    exp_body(Body,Nbody,In,Out).
expand_term(H :- B(A..),H :- [B(A..)]).  % coerce singleton bodies to lists for assert
expand_term(H :- B,H :- [B]) :- symbol(B).
expand_term(X,X).

dcg_load(FileName):- 
   open(Stream, FileName, read_only, ErrorCode) ,
   ErrorCode @\= 0-> [write("<Error> File cannot be opened\n"), !,fail],
   foreach($read_term_from_stream(Stream,List)
        do [
            $convert_list(List,Term),
            expand_term( Term, Expanded),
            assertz( Expanded )]),
    !.
$convert_list([H --> F,R..],H --> [F,R..]) :- !.
$convert_list(H --> [ F],H --> [[F]]) :- !.
$convert_list(Term,Term).

$read_term_from_stream(Stream,Term) :-
    repeat,
        get_term(Stream,Term,Error),
         $all_done(Stream,Error) -> [close(Stream,_),!,fail]. 

$all_done(_,2).   % incomplete term error
$all_done(_,-39). % not a term error
$all_done(Stream,Error) :- Error @\=0,at(Stream,end_of_file). % end of file
 
$app([], _L, _L).
$app([_H|_T1 ], _L, [_H|_T2 ]) :- $app(_T1, _L, _T2).

