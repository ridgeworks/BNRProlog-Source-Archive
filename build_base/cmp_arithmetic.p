/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/cmp_arithmetic.p,v 1.5 1996/06/17 14:00:01 yanzhou Exp $
 *
 * $Log: cmp_arithmetic.p,v $
 * Revision 1.5  1996/06/17  14:00:01  yanzhou
 * failexit($arith) in $eval_var was causing problem in BNRProlog v4.x
 * when LCO takes place.  Now changed to cut and fail.
 *
 * Revision 1.4  1996/02/23  03:48:57  yanzhou
 * Bug fix:  expressions like 10 is X+2 were not compiled into WAM opcodes,
 * but 10 == X+2 was.  Now fixed to make "is" and "==" behave exactly the
 * same if the left hand side expression is not a variable.
 *
 * Revision 1.3  1996/02/08  05:03:03  yanzhou
 * In BNRProlog version 4.3, boolean operators and relational operators
 * (in an eval) were implemented in Prolog.  They are now moved into the
 * WAM-based BNRProlog core.
 *
 * The supported boolean operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ~                       F8             127   boolean negation
 *   and                     F9              21   boolean and
 *   or                      FA             170   boolean or
 *   xor                     FB             242   boolean xor
 *   ->                      FC              19   boolean if
 *   nand                  F9F8             201   negation of and
 *   nor                   FAF8              92   negation of or
 *
 * The supported relational operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ==                      FD             201
 *   =:=                     FD              26   same as ==
 *   <>                    FDF8             221   negation of ==
 *   =\=                   FDF8              84   same as <>
 *   >                       FE              63
 *   =<                    FEF8             200   negation of >
 *   <                       FF              61
 *   >=                    FFF8             214   negation of <
 *
 * Modifed files are:
 *   cmp_arithmetic.p   - new $func1()/$func2() clauses
 *   compile.p          - new $esc() entries for each of the operators
 *   core.c             - new WAM F8-FF entries in the body escape op-code
 *                        table (both normal and in-clause modes)
 *   crias6.p           - revised eval() clauses for the operators
 *   loader.c           - new hash entries in scanList(),
 *                        -80 entries in remEscBytes[]
 *   prim.[hc]          - new atoms for ~, and, or, and xor.
 *
 * Revision 1.3  1996/02/08  04:59:04  yanzhou
 * In BNRProlog version 4.3, boolean operators and relational operators
 * (in an eval) were implemented in Prolog.  They are now moved into the
 * WAM-based BNRProlog core.
 *
 * The supported boolean operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ~                       F8             127   boolean negation
 *   and                     F9              21   boolean and
 *   or                      FA             170   boolean or
 *   xor                     FB             242   boolean xor
 *   ->                      FC              19   boolean if
 *   nand                  F9F8             201   negation of and
 *   nor                   FAF8              92   negation of or
 *
 * The supported relational operators are:
 *
 *              WAM BODY ESCAPE   InCore Loader
 *   OPERATOR            OPCODE      HASH ENTRY   COMMENT
 *   --------   ---------------   -------------   ---------------------
 *   ==                      FD             201
 *   =:=                     FD              26   same as ==
 *   <>                    FDF8             221   negation of ==
 *   =\=                   FDF8              84   same as <>
 *   >                       FE              63
 *   =<                    FEF8             200   negation of >
 *   <                       FF              61
 *   >=                    FFF8             214   negation of <
 *
 * Modifed files are:
 *   cmp_arithmetic.p   - new $func1()/$func2() clauses
 *   compile.p          - new $esc() entries for each of the operators
 *   core.c             - new WAM F8-FF entries in the body escape op-code
 *                        table (both normal and in-clause modes)
 *   crias6.p           - revised eval() clauses for the operators
 *   loader.c           - new hash entries in scanList(),
 *                        -80 entries in remEscBytes[]
 *   core.h             - new BOOLEANREQUIRED run-time error
 *   base5.p            - new $error_string() clause for the BOOLEANREQUIRED
 *                        run-time error
 *   prim.[hc]          - new atoms for ~, and, or, and xor.
 *
 * Revision 1.2  1996/02/01  03:29:42  yanzhou
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
 * Revision 1.1  1995/09/22  11:23:05  harrisja
 * Initial version.
 *
 *
 */
%
%               WAM compiler for arithmetic 
%
%    this file should be consulted ( or merged in compilation) with 
%        cmp_clause

%   decomposing arithmetic expressions
%   maximum number of registers available for expression evaluation: set as required
$maxreg(8).

% expand an 'is' expression into subexpressions as required, so as to not
% exceed the number of registers available.
$expand_arithmetic(D is X,Xs, End):-
    $maxreg(R),
    $expand(R,X,[D is Z, End..],Xs,Z),!.
$expand_arithmetic( F(Y,X), Xs, End):-
    $rel_op(F),!,
    $maxreg(R),
    $expand(R, Y, [F(RY,RX), End..], [List..],RY),!,
    R1 is R - 1,
    $expand(R1, X, List, Xs,RX),!.
    
% Vars, numbers, recognizable symbols 
$expand(_,X,SubList,SubList,X) :- $simple_arithmetic(X),!.
$simple_arithmetic(X):-var(X).
$simple_arithmetic(X):-number(X).
$simple_arithmetic(X):- $func0(X).

% expand binary functions
$expand(1,Op(X,Y),[SubListIn..],SubListOut,Z):-
    $func2(Op),!,    % binary arith op, with only one reg left
    $maxreg(R),       % run out of regs, emit subexpression and start again
    $expand(R,Op(X,Y),[Z is Red,SubListIn..],SubListOut,Red).

$expand(Regs,Op(X,Y),SubListIn,SubListOut,Op(RX,RY)):-
    $func2(Op),    % binary arithmetic function
    (not( Op='**') ; $maxreg(Regs) ), !,     % exp only when stack is empty (impl. restr)
    $expand(Regs,X,SubListIn,SubList1,RX),  % eval LHS
    NRegs is Regs - 1,      % consume a register to hold LHS
    $expand(NRegs,Y,SubList1,SubListOut,RY).

$expand(Regs, Op(X,Y),[SubListIn..],SubListOut,Z):- 
    Op @= '**',
    !,    
    $maxreg(R),       % run out of regs, emit subexpression and start again
    $expand(R,X**Y,[Z is Red,SubListIn..],SubListOut,Red).

% expand unary functions
$expand(0,Op(X),[SubListIn..],SubListOut,Z):-
    $func1(Op),!,    % unary arith op, with no registers left 
    $maxreg(R),       % run out of regs, emit subexpression and start again
    $expand(R,Op(X),[Z is Red,SubListIn..],SubListOut,Red).

$expand(Regs,Op(X),SubListIn,SubListOut,Op(RX)):-
    $func1(Op),!,    % unary arithmetic op
    $expand(Regs,X,SubListIn,SubListOut,RX).    % expand operand

% anything else, evaluate outside and substitute
$expand(_,X,SubListIn,[ /* T = X,*/ Z is X,SubListIn..],Z):- compound(X).

%
%           arithmetic relations
%

$arith( V is Y, Size, [escape,EY..]):-
        $target(V,Size,EV),!,
        $evaluate(Y,EY,[EV]).

% 20/02/96:yanzhou@bnr.ca: change (2 is X+1) to (2 == X+1)
$arith( X is Y, Size, C):-
        $arith(X == Y, Size, C),
        !.

$arith( R(X,Y), Size, [escape, EX..]  ):-not(R@='is'),
        $rel_op(R),
        $evaluate(Y,EY,[R(Size)]),
        $evaluate(X,EX,EY),
        !.

$target(  $var(V,_,P,Vd,B,S), Size,  Popv(V, Size2)):-  
        $occurrence( B,Suffix,S,arith),     % generate pop instruction
        swrite(Popv,pop,Suffix,P),
        $varno(P,V,V2),
        Size2 is max(Size, V2),
        !.
$varno( p,V,V).   % permanent- make sure env includes var
$varno( t,V,0).   %  temp - map to 0 and use env size

$eval_var( B,S,P, Eval):- B @= 1,!,                      % eval_var instruction
        $occurrence( B,Suffix,S,arith), 
        swrite(Eval,eval,Suffix,P ).
%
% yanzhou@bnr.ca: 17/06/96
%   failexit($arith) was causing problem when LCO takes place
%   changed to cut and fail.
$eval_var(B,_,_,_) :- 
	var(B),										% undef var if B not = 1
	write('\nWarning: evaluation of new or unused variable\n'),
	!,
	fail.

%   $evaluate( Expr, Listbegin, Listrest) 
$evaluate( $var(V,_,P,Vd,B,S), [ Eval(V),X..],X):- !, $eval_var(B,S,P,Eval). 
$evaluate( N,       [eval_cons(N),X..],  X) :- numeric(N),!.
$evaluate( -X     , EX, Rest ):- !, $evaluate( X, EX,[neg,Rest..]).
$evaluate( X + 1  , EX, Rest ):- $var(X),!, $evaluate( inc(X),EX,Rest). 
$evaluate( X - 1  , EX, Rest ):- $var(X),!, $evaluate( dec(X),EX,Rest). 
$evaluate( F(X,Y) , EX, Rest):- 
    $func2(F),
    !,
    $evaluate(X,EX,EY),
    $evaluate(Y,EY,[F,Rest..]).
$evaluate( F(X)   , EX, Rest):- 
    $func1(F),
    !, 
    $evaluate(X,EX,[F,Rest..]).
$evaluate( F,  [eval_sym(F),Rest..],Rest):- 
    symbol(F), 
    $func0(F).    

$var($var(_..)).     

$rel_op( V ):- var(V), !, fail.   %  watch out for variable functors
$rel_op('is').

$rel_op('==').
$rel_op('=<').
$rel_op('>=').
$rel_op('<').
$rel_op('>').
$rel_op('<>').
$rel_op('=/=').


$func2( V ):- var(V), !, fail.   %  watch out for variable functors
$func2('+').
$func2('-').
$func2('*').
$func2('/').
$func2('//').
$func2('**').
$func2('mod').
$func2('max').
$func2('min').
% bit-wise operators, Jan 1996, yanzhou@bnr.ca
$func2(butnot).
$func2(bitshift).
$func2(bitand).
$func2(bitor).
$func2(biteq).
% boolean operators, Feb 1996, yanzhou@bnr.ca
$func2(and).
$func2(or).
$func2(xor).
$func2(nand).
$func2(nor).
$func2(->).
$func2(==).
$func2(=:=).
$func2(<>).
$func2(=\=).
$func2(<).
$func2(=<).
$func2(>).
$func2(>=).

$func1( V ):- var(V), !, fail.   %  watch out for variable functors
$func1('-').
$func1(inc).
$func1(dec).
$func1(sin).
$func1(cos).
$func1(tan).
$func1(asin).
$func1(acos).
$func1(atan).
$func1(abs).
$func1(exp).
$func1(ln).
$func1(sqrt).
$func1(integer).
$func1(float).
$func1(floor).
$func1(ceiling).
$func1(round).
% boolean negation, Feb 1996, yanzhou@bnr.ca
$func1('~').

$func0(maxint).
$func0(maxreal).
$func0(pi).
% $func0(¹).  /* Macintosh pi symbol */
$func0(cputime).
