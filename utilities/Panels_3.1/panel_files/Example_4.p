/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/panel_files/RCS/Example_4.p,v 1.1 1995/09/22 11:24:12 harrisja Exp $
*
*  $Log: Example_4.p,v $
 * Revision 1.1  1995/09/22  11:24:12  harrisja
 * Initial version.
 *
*
*/
/*
 *   Example 4
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
/*
    This is a (very) simple four function calculator.
    It has no memory, clear keys, or fancy scientific
    functions, but it should be easy to add some or
    all of these features yourself. (Note that the calculator
    can also be driven from the keyboard using default
    button behaviour.)
*/

panel_definition('Example 4',
    pos(376,160),
    size(164,194),
    options(style(motif,menubar),background(white,yellow),picture(),lock(off),dialog(off)),
    button(close,[3,3,15,15],[rectangle,'',off,font(0,12),icon(0),menu()]),
    button(button1,[20,9,140,29],[transparent,'Simple Calculator',nil,font(0,12),icon(0),menu()]),
    field(display,[16,40,145,62],[['','','',0],font(3,12),lock(off),lines(off),style(motif),menu()]),
    button(digit,[25,156,45,176],[motif,'0',off,font(0,12),icon(0),menu()]),
    button('.',[55,156,75,176],[motif,'.',off,font(0,12),icon(0),menu()]),
    button(op,[85,156,105,176],[motif,'=',off,font(0,12),icon(0),menu()]),
    button(op,[115,156,135,176],[motif,'+',off,font(0,12),icon(0),menu()]),
    button(op,[115,128,135,148],[motif,'-',off,font(0,12),icon(0),menu()]),
    button(digit,[85,128,105,148],[motif,'3',off,font(0,12),icon(0),menu()]),
    button(digit,[55,128,75,148],[motif,'2',off,font(0,12),icon(0),menu()]),
    button(digit,[25,128,45,148],[motif,'1',off,font(0,12),icon(0),menu()]),
    button(op,[115,100,135,120],[motif,'*',off,font(0,12),icon(0),menu()]),
    button(digit,[85,100,105,120],[motif,'6',off,font(0,12),icon(0),menu()]),
    button(digit,[55,100,75,120],[motif,'5',off,font(0,12),icon(0),menu()]),
    button(digit,[25,100,45,120],[motif,'4',off,font(0,12),icon(0),menu()]),
    button(op,[115,72,135,92],[motif,'/',off,font(0,12),icon(0),menu()]),
    button(digit,[85,72,105,92],[motif,'9',off,font(0,12),icon(0),menu()]),
    button(digit,[55,72,75,92],[motif,'8',off,font(0,12),icon(0),menu()]),
    button(digit,[25,72,45,92],[motif,'7',off,font(0,12),icon(0),menu()])).

panel_event('Example 4',open,nil):-
    remember(acc(0,'='),$local),
    remember(newnumber(true),$local).

panel_event('Example 4',click,button(name(digit),_,_,label(Digit),Etc..)):-
    update(newnumber(true),newnumber(false),$local)->
        NewStr=Digit;
        [panel_view('Example 4',field(display):Str),
         Str='0'->NewStr=Digit;concat(Str,Digit,NewStr)], %treat leading zeros
    panel_view('Example 4',field(display):=NewStr).

panel_event('Example 4',click,button('.')):-
    panel_view('Example 4',field(display):Str),
    substring(Str,_,1,'.')->
        beep;           % display already has a decimal point
        [concat(Str,'.',NewStr),
         panel_view('Example 4',field(display):=NewStr)].

panel_event('Example 4',click,button(name(op),_,_,label(Op),Etc..)):-
    recall(acc(Acc,PrevOp),$local),
    panel_view('Example 4',field(display):Str),
    once($value(Str,Value)),
    $calc(PrevOp,Acc,Value,NewAcc),
    swrite(NewStr,NewAcc),
    panel_view('Example 4',field(display):=NewStr),
    update(acc(Acc,PrevOp),acc(NewAcc,Op),$local),
    update(newnumber(_),newnumber(true),$local),!.  % commit

panel_event('Example 4',click,button(close)):-
    panel_close('Example 4').

panel_event('Example 4',close):-
    context('Example_4',Path),
    concat(Window,'.a',Path)->true;Window=Path,
    closewindow(Window)->true,
    exit_context('Example_4').

$value(Str,Value):- concat(Str,'. ',Term),sread(Term,Value).
$value(Str,Value):- concat(Str,'.0. ',Term),sread(Term,Value).  % integer overflow, cobvert to float

$calc('=',Acc,Value,Value):-number(Value).
$calc('+',Acc,Value,NewValue):-NewValue is Acc+Value.
$calc('-',Acc,Value,NewValue):-NewValue is Acc-Value.
$calc('*',Acc,Value,NewValue):-NewValue is Acc*Value.
$calc('/',Acc,0,NewValue):-beep,fail.   % divide by 0, beep and fail
$calc('/',Acc,Value,NewValue):-NewValue is Acc/Value.
    
$initialization:-
    panel_open('Example 4').
