/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/base0.p,v 1.19 1997/11/24 10:37:45 harrisj Exp $
 *
 * $Log: base0.p,v $
 * Revision 1.19  1997/11/24  10:37:45  harrisj
 * BNRP.mk includes the version information required to construct the predicate
 * version\1.  The makefile for build_base now constructs a file
 * containing the version\1 predicate during the build process.
 *
 * Revision 1.18  1997/09/16  04:48:14  wcorebld
 * *** empty log message ***
 *
 * Revision 1.17  1997/04/02  00:08:30  wcorebld
 * Released v4.4.9  See CHANGELOG for details
 *
 * Revision 1.16  1997/03/19  10:52:22  wcorebld
 * Release 4.4.8 See CHANGELOG
 *
 * Revision 1.15  1996/10/29  11:42:35  harrisj
 * Bug fixes & new features
 * 	- list_to_asn1 was incorrectly handling multi-byte lengths
 * 	- added selection of multiple blocks from Panel lists
 * 	- fixed deletemenu to delete submenus
 * 	- fixed popupmenu to correctly update state space info
 * 	- modified panel_menu to popdown the menu instead of deleting it
 * 	- added panel_menu_create to pre-initialize panel menus
 * 	- changed panel_close to call panel_menu_delete to delete popups
 *
 * Revision 1.14  1996/09/27  09:23:57  harrisj
 * Bug fixes & new features:
 * 	- detect & report file IO errors in handleFileIO()
 * 	- modify menu item mark attribute to be able to toggle mark on/off
 * 	- add control-click feature for Panels list class to select a block of list items
 *
 * Revision 1.13  1996/09/12  10:17:31  harrisj
 * Enabled "mark" menu attribute.
 * Allowed variable functors in external interface.
 *
 * Revision 1.12  1996/08/28  11:25:04  harrisj
 * Bug-fix release
 *
 * Revision 1.11  1996/07/04  13:22:12  yanzhou
 * Version 4.4.3: memory-related fixes and TCP enhancements.
 *
 * Revision 1.10  1996/05/16  14:13:26  yanzhou
 * Version 4.4.2 - a bug fix/enhancement release.
 *
 * Revision 1.9  1996/04/10  15:41:25  yanzhou
 * Version 4.4.1 - a bug fix/enhancement release.
 *
 * Revision 1.8  1996/02/01  03:29:41  yanzhou
 * New bit-wise operators added:
 *
 *  OPERATOR   TYPE   PRIORITY   WAM ESC CODE   HASH
 *  ------------------------------------------------
 *  butnot      yfx        600             CF    122
 *  bitshift    yfx        600             DF     94
 *  bitand      yfx        600             ED    119
 *  bitor       yfx        600             EE    197
 *  biteq       yfx        600             EF     59
 *
 *  Modified files are:
 *  base0.p            - new op() and eval() clauses.
 *  cmp_arithmetic.p   - new $func2() clauses.
 *  compile.p          - new $esc() entries.
 *  core.c             - new CF/DF/ED/EE/EF entries
 *                         in escape and in-clause modes.
 *  loader.c           - new hash entries in scanList(),
 *                         and -80 entries in remEscBytes[].
 *  prim.[hc]          - new atoms
 *
 * Revision 1.7  1996/01/08  09:58:29  yanzhou
 * Version 4.3.9
 *
 * Revision 1.6  1995/12/18  10:04:05  yanzhou
 * Version 4.3.8  - Signal rationalization.
 *
 * Revision 1.5  1995/12/04  10:19:11  yanzhou
 * Version 4.3.7, now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.4  1995/11/24  19:04:14  yanzhou
 * version 4.3.6.
 *
 * Revision 1.3  1995/11/20  14:02:10  yanzhou
 * Version 4.3.5
 *
 * Revision 1.2  1995/10/19  17:04:46  harrisja
 * *** empty log message ***
 *
 * Revision 1.1  1995/09/22  11:21:13  harrisja
 * Initial version.
 *
 *
 */

/*
 * Ring 0 of BASE
 */

% ground checks removed from arithmetic Jan 1995 

%%%
%%% Basic Language Elements
%%%

op(1200, xfx, ':-').
op(1200, fx, ':-').
op(1200, fx, '?-').
op(1100, xfy, ';').
op(1050, xfy, '->').
%% op(1000, xfy, '&').
op(950, xfx, 'where').
op(950, xfx, 'do').
op(700, xfy, ':').
op(700, xfy, '::').  % alias for : added Oct 94 for ALS
op(700, xfx, '==').
op(700, xfx, '=:=').
op(700, xfx, '<>').
op(700, xfx, '=\\=').
op(700, xfx, 'is').
op(700, xfx, '=').
op(700, xfx, '\\=').
op(700, xfx, '<').
op(700, xfx, '=<').
op(700, xfx, '>').
op(700, xfx, '>=').
op(700, xfx, '@=').
op(700, xfx, '@\\=').
op(700, xfx, '\\==').
op(700, xfx, '@<').
op(700, xfx, '@=<').
op(700, xfx, '@>').
op(700, xfx, '@>=').
op(500, yfx, '+').
op(500, yfx, '-').
op(500, fx, '-').
op(400, yfx, '*').
op(400, yfx, '/').
op(400, yfx, '//').
op(400, yfx, divf).		% the floor of integer division
op(400, yfx, divc).		% the ceiling of integer division
op(300, yfx, '**').
op(300, xfx, 'mod').

%
% bit-wise operators (Jan 1996 by yanzhou@bnr.ca)
% NOTE: The priorities here are deliberately chosen to be over 500 so
%       that the unary '-' operator can have a higher priority.
%
op(600, yfx, butnot).							% negation
op(600, yfx, bitshift).							% shift
op(600, yfx, bitor).							% or
op(600, yfx, bitand).							% and
op(600, yfx, biteq).							% eq

%%%
%%% Control
%%%

block(F(A..)) :-
    symbol(F), !, 
    $block(F(A..), F).
block(Name, F) :- !, $block(F, Name).
block(Name, F..) :- $block([F..], Name).

$block(Goal, Name) :- 
    inline$(label_env),      % assign name to environment
    Goal.

(P -> Q ; R) :- P,!,Q.
(P -> Q ; R) :- !, R.

(P -> Q) :- P,!,Q.
(P -> Q).

(P ; Q) :- P.
(P ; Q) :- Q.

repeat.
repeat:- repeat.

foreach(P do Q) :- P, Q, fail.
foreach(P do Q).   

not(P) :- P,!,fail.
not(P).

(X = X).
(X \= X) :- !, fail.
(X \= Y).

%% P & Q :- P, Q.

once(P) :- P, !.

true.

fail :- fail.
failexit(X) :- failexit(X).
failexit :- $fixcutb, !, fail.
cut(X) :- cut(X).
cut :- $fixcutb, !.

%%%
%%% Filters and MetaPredicates
%%%

integer(A, As..) :- 
    integer(A),
    $filter([As..], integer).

compound(A, As..) :- 
    compound(A),
    $filter([As..], compound).

float(A, As..) :- 
    float(A),
    $filter([As..], float).

list(A, As..) :- 
    list(A),
    $filter([As..], list).

structure(A, As..) :- 
    structure(A),
    $filter([As..], structure).

var(A, As..) :- 
    var(A),
    $filter([As..], var).

tailvar(Arg..) :- tailvar(Arg..).

nonvar(A, As..) :- 
    nonvar(A),
    $filter([As..], nonvar).

number(A, As..) :- 
    number(A),
    $filter([As..], number).

numeric(A, As..) :- 
    numeric(A),
    $filter([As..], numeric).

symbol(A, As..) :- 
    symbol(A),
    $filter([As..], symbol).

noninteger(A, As..) :- 
    noninteger(A),
    $filter([As..], noninteger).

nonsymbol(A, As..) :- 
    nonsymbol(A),
    $filter([As..], nonsymbol).

nonfloat(A, As..) :- 
    nonfloat(A),
    $filter([As..], nonfloat).

nonnumeric(A, As..) :- 
    nonnumeric(A),
    $filter([As..], nonnumeric).

nonnumber(A, As..) :- 
    nonnumber(A),
    $filter([As..], nonnumber).

nonstructure(A, As..) :- 
    nonstructure(A),
    $filter([As..], nonstructure).

nonlist(A, As..) :- 
    nonlist(A),
    $filter([As..], nonlist).

noncompound(A, As..) :- 
    noncompound(A),
    $filter([As..], noncompound).

atomic(A, As..) :-                  /* must be overloadable */
    $atomic(A),
    $filter([As..], atomic).
$atomic(A) :- symbol(A), !.
$atomic(A) :- numeric(A).

$filter([As..], _) :- 
    tailvar(As..), !, fail.
$filter([], _) :-!.
$filter([As..], Pred) :-
    Pred(As..).


%%%
%%% Arithmetic
%%%

%%%%% meta-interpret is, comparisons in case compiler couldn't
%%%%% generate the code inline

R is T :- /* ground(T), */ !, eval(T, R1), R is R1.	
% N.B., 'R is R1' required to support possible rewrite system

A == B  :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 == B1.
A =:= B :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 == B1.
A <> B  :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 <> B1.
A =\= B :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 <> B1.
A < B   :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 < B1.
A =< B  :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 =< B1.
A > B   :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 > B1.
A >= B  :- /*ground(A), ground(B),*/ !, A1 is A, B1 is B, A1 >= B1.

eval(Op(A..), R) :- var(Op), !, fail.
eval(R, R) :- numeric(R), !.
eval(A + B, R) :- A1 is A, B1 is B, R is A1 + B1.
eval(A - B, R) :- !, A1 is A, B1 is B, R is A1 - B1.
eval(-A, R) :- A1 is A, R is 0 - A1.
eval(A * B, R) :- A1 is A, B1 is B, R is A1 * B1.
eval(A ** B, R) :- A1 is A, B1 is B, R is A1 ** B1.
eval(A / B, R) :- A1 is A, B1 is B, R is A1 / B1.
eval(A // B, R) :- A1 is A, B1 is B, R is A1 // B1.
eval(A divf B, R) :- A1 is A, B1 is B, R is floor(A1 / B1).
eval(A divc B, R) :- A1 is A, B1 is B, R is ceiling(A1 / B1).
eval(A mod B, R) :- A1 is A, B1 is B, R is A1 mod B1.
eval(max(A, B), R) :- A1 is A, B1 is B, R is max(A1, B1).
eval(min(A, B), R) :- A1 is A, B1 is B, R is min(A1, B1).
eval((A ; B), R) :- R is A ; R is B.
eval(sin(A), R) :- A1 is A, R is sin(A1).
eval(cos(A), R) :- A1 is A, R is cos(A1).
eval(tan(A), R) :- A1 is A, R is tan(A1).
eval(asin(A), R) :- A1 is A, R is asin(A1).
eval(acos(A), R) :- A1 is A, R is acos(A1).
eval(atan(A), R) :- A1 is A, R is atan(A1).
eval(abs(A), R) :- A1 is A, R is abs(A1).
eval(ceiling(A), R) :- A1 is A, R is ceiling(A1).
eval(floor(A), R) :- A1 is A, R is floor(A1).
eval(exp(A), R) :- A1 is A, R is exp(A1).
eval(float(A), R) :- A1 is A, R is float(A1).
eval(integer(A), R) :- A1 is A, R is integer(A1).
eval(ln(A), R) :- A1 is A, R is ln(A1).
eval(round(A), R) :- A1 is A, R is round(A1).
eval(sqrt(A), R) :- A1 is A, R is sqrt(A1).
eval(pi,R) :- R is pi.
% eval(¹,R) :- R is pi.  /* only for macintosh */
eval(cputime,R) :- R is cputime.
eval(maxint,R) :- R is maxint.
eval(maxreal,R) :- R is maxreal.
% bit-wise operators
eval(A butnot   B, R) :- A1 is A, B1 is B, R is A1 butnot   B1.
eval(A bitshift B, R) :- A1 is A, B1 is B, R is A1 bitshift B1.
eval(A bitand   B, R) :- A1 is A, B1 is B, R is A1 bitand   B1.
eval(A bitor    B, R) :- A1 is A, B1 is B, R is A1 bitor    B1.
eval(A biteq    B, R) :- A1 is A, B1 is B, R is A1 biteq    B1.

% $evalconstrained is called when the LHS of an is contains a
% constrained variable.  We first do the unify in case the constraint
% simply succeeds (which is what we normally would do).  If this fails,
% we ripple into the second clause which calls == to handle intervals
% being bound to inappropriate things (X:real, X is 2)
$evalconstrained(Var, Result) :- Var = Result, !.
$evalconstrained(Var, Result) :- Var == Result.


%
%   $$callindirect is called to meta interpret a goal that is
%       too complex to be handled inline (i.e. symbols and 
%       definite arity functors are handled inline). Thus this
%       code need only handle lists.
%
$$callindirect(X) :-				% call subgoal, leaving env around for cut/failexit
    $$calllistindirect(X),
	true.

$$calllistindirect([X, Xs..]) :-	% non-empty list, do first thing
    X,                              % system will complain if this is a var
    $$calllistindirect([Xs..]).
$$calllistindirect([]).				% empty list, terminate


%%%
%%% Error Recovery
%%%

%%%% If an internal error occurs, the interpreter checks the ancestor stack for
% the occurrance of an ancestor goal having the form "recovery_unit(_X..)".
% If found, the goal is failed. Intuitively:
%              <<Internal Error>> :-
%                                 goal(recovery_unit(_X..)),
%                                 failexit(recovery_unit).
%              <<Internal Error>> :- <<internal recovery>>.         (in case failexit fails)

% Associate a goal, _Goal, with an internal error trap handler, _Handler.

capsule(Goal, Handler) :- recovery_unit(Goal),true.	% true to prvent L.C.O.
capsule(Goal, Handler) :- Handler.

recovery_unit(Goal) :- Goal.                    % Do Goal. If Goal fails,
recovery_unit(Goal) :- failexit(capsule).       % prevent invocation of Handler

halt :- quit.
quit :- $quit.			% Call primitive, can be overloaded

$initialization.
