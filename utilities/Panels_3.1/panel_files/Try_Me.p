/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/panel_files/RCS/Try_Me.p,v 1.1 1995/09/22 11:29:01 harrisja Exp $
*
*  $Log: Try_Me.p,v $
 * Revision 1.1  1995/09/22  11:29:01  harrisja
 * Initial version.
 *
*
*/

/*
 *   Try Me
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/

% -- Introduction to panel examples --

panel_event('Try Me',open):-
    panel_view('Try Me',msg:='  I suggest you try the examples in order...').

panel_event('Try Me',click,button(Example)):-
    run_example(Path,Example).

panel_event('Try Me',click,button(Example)):-
    panel_view('Try Me',msg:='** Sorry:  Could not find this example.').

panel_event('Try Me',close):-
    exit_context('Try_Me').

% ---------------------------------------------------------------------------

run_example(Path,Example):-
    panel_directory(Folder),
    defaultdir(Dd),
    defaultdir(Folder);[defaultdir(Dd),fail],  % undo defaultdir on failure
    $exname(Example,ExampleF),
    fullfilename(ExampleF,Path),     % check example master file exists
    panel_view('Try Me',msg:=' OK, now opening the example...'),!,
    openwindow(text,Path,pos(0,40),size(400,300),options()),
    load_context(ExampleF),
    defaultdir(Dd),
    panel_view('Try Me',msg:='Try another example?   (If not: Close Try Me)').

run_example(_):-
    message('Thwarted: unable to load this example.').

$exname('Example 1','Example_1').
$exname('Example 2','Example_2').
$exname('Example 3','Example_3').
$exname('Example 4','Example_4').
/*
open_window(Name,Path):-
    fullfilename(Name,Path),
    iswindow(Path,text,_).

open_window(Name,Name):-
    openwindow(text,Name,pos(_,_),size(_,_),options(hidden)).
*/

% --  panel definition --

panel_definition('Try Me', 
    pos(40,50),
    size(360,161),
    options(nogrowdocproc),
    field(msg,[8,126,344,146],'Try another example?   (If not: Close Try Me)'),
    text('A Simple Calculator.',[104,92,238,108],_3),
    text('Adding your own panel objects.',[104,68,316,84],_1),
    text('More on fields and other things.',[104,44,320,60],_2),
    text('Basic buttons and field. ',[104,20,267,36],_3),
    button('Example 4',[8,88,88,108],_4),
    button('Example 3',[8,64,88,84],_5),
    button('Example 2',[8,40,88,60],_6),
    button('Example 1',[8,16,88,36],_7)).

% ------------------------------------------------------------

$initialization:-
    panel_open('Try Me').
