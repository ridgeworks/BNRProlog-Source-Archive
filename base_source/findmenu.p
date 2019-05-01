/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/findmenu.p,v 1.1 1995/09/22 11:24:23 harrisja Exp $
*
*  $Log: findmenu.p,v $
 * Revision 1.1  1995/09/22  11:24:23  harrisja
 * Initial version.
 *
*
*/
/*
 *   FindMenu
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1989, 1990, 1991
 */

installmenu(W,'Find') :- 
	addmenu(W,'Find','Find',0),
		additem(W,'Find...', [command('F')], 'Find', end_of_menu, _),
		additem(W,'Find Same', [command('G')], 'Find', end_of_menu, _),
		additem(W,'Find Selection', [command('H')], 'Find', end_of_menu, _),
		additem(W,'-',[disable],'Find',end_of_menu, _),
		additem(W,'Replace...', [command('R')], 'Find', end_of_menu, _),
		additem(W,'Replace Same', [command('T')], 'Find', end_of_menu, _),
		additem(W,'-',[disable],'Find',end_of_menu, _),
		additem(W,'Search Backwards', [command('D')], 'Find', end_of_menu, _).

menuselect(Window, 'Find', 'Find...')          :- $findnew(Window).
menuselect(Window, 'Find', 'Find Same')        :- $find(Window).
menuselect(Window, 'Find', 'Find Selection')   :- $findselection(Window).
menuselect(Window, 'Find', 'Replace...')       :- $replacenew(Window).
menuselect(Window, 'Find', 'Replace Same')     :- $$replace(Window).
menuselect(Window, 'Find', 'Search Backwards') :- findinfo(_, _, _, backward),
                                                  dotext(Window, scandirection(backward)),
                                                  menuitem(Window, 'Find', 8, 'Search Forwards', _) -> [].
menuselect(Window, 'Find', 'Search Forwards')  :- findinfo(_, _, _, forward),
                                                  dotext(Window, scandirection(forward)),
                                                  menuitem(Window, 'Find', 8, 'Search Backwards', _) -> [].

findinfo(F, R, C, D) :- 
    var(F, R, C, D),                        
    recall(findinfo(F, R, C, D), $local),
    !.                                          % cut out the OR choice points
findinfo(NF, NR, NC, ND) :- 
    forget(findinfo(F, R, C, D), $local) ; [F, R, C, D] = ['','', yes, forward],
    NF = F ; true,
    NR = R ; true,
    NC = C ; true,
    ND = D ; true,
    remember(findinfo(NF, NR, NC, ND), $local),
    !.                                          % cut out the OR choice points

$getinfo(TW, F, R, C, D) :-
    iswindow(TW, text, _),
    findinfo(F, R, C, D).

$findnew(TW) :-  % find ; getting new find info
    $getinfo(TW, F, _, C, D),
    queryfind([F, C, D], [NF, NC, ND]),
    findinfo(NF, _, NC, ND),
    postevent($find, TW, _, _).

$find(TW,_..) :-  % find using current find info ... DOUBLES as an event handler due to tailvar
    $getinfo(TW, F, _, C, D),
    dotext(TW, [casesense(C), scandirection(D), selection(F)]) ; beep,
    !.         % remove the OR choicepoint

$findselection(TW) :-  %find using existing find info and selection
    inqtext(TW, selection(NF)),
    $getinfo(TW, NF, _, C, D),
    dotext(TW, [casesense(C), scandirection(D), selection(NF)]) ; beep,
    !.         % remove the OR choicepoint

$replacenew(TW) :-  % replace geting new find info
    $getinfo(TW, F, R, C, D),
    queryreplace([F, R, C, D], [NF, NR, NC, ND], FUNC),
    findinfo(NF, NR, NC, ND),
    $convertFUNC(FUNC, FUNC2),
    postevent(FUNC2, TW, _, _).

$convertFUNC(find, $find).
$convertFUNC(replace, $$replace).
$convertFUNC(replaceall, $replaceall).

$$replace(TW,_..) :-  % replace using current find info ... DOUBLES as an event handler due to tailvar
    $getinfo(TW, F, R, C, D),
    $scanfrom(D,S1,E1,SE1,S2,E2,SE2),   % bind SE1 AND SE2 to the variables they should track
    [dotext(TW, [casesense(C), scandirection(D), 
        inq(selectcabs(S1, E1)), selectcabs(SE1, SE1), selection(F), inq(selectcabs(S2, E2)), 
        replace(R),selectcabs(SE2, SE2)])]
    ; beep,
    !. % remove the OR choicepoint

$replaceall(TW, _..) :-  % replace all using current find info ... DOUBLES as an event handler due to tailvar
    $$replace(TW),        % use replace to replace the first then repeat..loop the rest.
    findinfo(F, R, C, D),
    $scanfrom(D,S1,E1,SE1,S2,E2,SE2),   % bind SE1 AND SE2 to the variables they should track
    repeat, 
        dotext(TW, [selection(F), inq(selectcabs(S2, E2)), replace(R), selectcabs(SE2, SE2)])
        -> fail,
    !.  % remove the REPEAT choicepoints

$scanfrom(forward,  S, _, S, _, E, E).   % scan forward from start at first, from end thereafter
$scanfrom(backward, _, E, E, S, _, S).   % scan backward from end  at first, from start thereafter
