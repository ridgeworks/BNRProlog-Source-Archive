/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/list_class.p,v 1.5 1996/10/08 11:14:49 harrisj Exp $
*
*  $Log: list_class.p,v $
 * Revision 1.5  1996/10/08  11:14:49  harrisj
 * Added support for selecting multiple blocks of list class items
 * by using control-shift click.  This required modifications to click
 * and shift-click event handlers to update a state space structure
 * which indicates the last item clicked on.
 *
 * Revision 1.4  1996/09/25  16:24:50  harrisj
 * Added support for multiple selected lines by
 * control-click.  Selects all list items from
 * beginning of previous selection to control-
 * clicked item.
 *
 * Revision 1.3  1996/02/02  06:18:37  yanzhou
 * In $lcontainer, an extra ',' is removed.
 *
 * Revision 1.2  1995/10/19  12:04:12  yanzhou
 * modified: $invert: to set correct backcolor before fillpat(invert).
 *
 * Revision 1.1  1995/09/22  11:24:59  harrisja
 * Initial version.
 *
*
*/
/*
 *   list_class
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
/*
    List Class

    Object Form:
        list(name(Name),        % a symbol identifying the button in a panel
             place(Place..),    % a list of 4 integers defining a rectangle
             contents(L..),     % contents (terms) of the list
             selection(I,Sel),  % current selection: index (integer) and selection (term)
                                %   or lists of indices and selected terms 
             top(T),            % index into list of top displayed term 
             style(Style),      % one of rectangle, shadow, or motif
             font(F,S,St..)     % font name, size and style specification
            )                   % end of value specification
*/


% *** list ***   Animation...

% two step select/doubleclick to permit applications to handle list item selects without
% having to map co-ordinates themselves (refer R.S.):
%   1. map X,Y coordinates to an item in the list and generate a 3-arity select event
%      including the index of the potentially selected item
%   2. if nobody acts on select/3 event, cause referenced item to become selected

panel_event(Panel,select(X,Y),list(Etc..)):-
    $list_event(Panel,select(X,Y),list(Etc..)).

panel_event(Panel,doubleclick(X,Y),list(Etc..)):-
    $list_event(Panel,doubleclick(X,Y),list(Etc..)).

panel_event(Panel,select(X,Y,selection(I1,S1)),
            list(Name,Place,Contents,selection(I0,S0),Ps..)):-
    I1\=I0->   % update selection?
       [panel_view(Panel,list(Name,Place,Contents,selection(I0,S0),Ps..):=selection(I1,S1)),
        dispatch_panel_event(Panel,update(selection(I0,S0)),
                             list(Name,Place,Contents,selection(I1,S1),Ps..))],
    % check for drag
    panel_scroll_item_info(list(Name,Place,Contents,selection(I1,S1),Ps..),[CXl,CYt,CXr,CYb],Span,Max),
    Ps=[top(Top),Style,Font,Etc..],
    $fontheight(Font,H),
    I1 == Top + ((Y-CYt)//H) 
    -> [ % make sure we drag the right line (shift-click unselect case)
        Y1 is CYt + (I1-Top)*H,
        Y2 is Y1 + H,
        LX1 is CXl-16,
        LX2 is CXr+16,
        panel_id(Panel,_,Window),  % convert to window for dograf
        $dragit(Window,[rectabs(CXl,Y1,CXr,Y2)],
                                X,Y,
                                LX1,CYt,LX2,CYb,
                                LX1,-4000,LX2,4000,
                                vert,
                                _,YDelta),
        YDelta = -32768 
        -> NewY = Y   % workaround dragregion bug
        ;  NewY is Y+YDelta,
        Line is (NewY-CYt)//H + Top,
        $adjustsel(Contents,[Line],_,I2,S2),
        I2 \= I1 -> [
            $move_element(I1,I2,Contents,Contents2,_),
            panel_view(Panel,list(Name,Place,Contents,selection(I1,S1),Ps..):=[selection(I2,_),Contents2],
                             list(Name,Place,NEtc..)),
            dispatch_panel_event(Panel,update(Contents,selection(I1,S1)),list(Name,Place,NEtc..))]].

% move element in position SrcI to position DestI, sliding others as appropriate
$move_element(SrcI,DestI,Contents,Contents,_):-                 % terminate
    SrcI<1,DestI<1.     % past both 'to' and 'from', rest is the same

$move_element(1,DestI,contents(T,Ts..),Contents2,T):-           % hit from position
    !,$move_element(0,DestI,contents(Ts..),Contents2,T).

$move_element(SrcI,1,Contents1,contents(Moved,Ts..),Moved):-    % hit to position
    !,$move_element(SrcI,0,Contents1,contents(Ts..),Moved).

$move_element(SrcI,DestI,contents(T,T1s..),contents(T,T2s..),Moved):-
    SrcO is SrcI-1,
    DestO is DestI-1,
    $move_element(SrcO,DestO,contents(T1s..),contents(T2s..),Moved).

% map list events/2 to list events/3
$list_event(Panel,Ev(X,Y),list(name(Name),Ps..)):-  % full format
    panel_scroll_item_info(list(name(Name),Ps..),[CXl,CYt,CXr,CYb],Span,Max),
    X<CXr,X>CXl,                % new item selection
    Ps=[_,Contents,_,top(Top),_,Font,_..], % pick up top and font info
    $fontheight(Font,H),
    Selofs is ((Y-CYt) // H),Selofs=<Span-1,
    Ix is Top+Selofs,
    Ix =< Max->
       [arg(Ix,Contents,Sel),
	$updateShiftSelectedStart(Panel,Name,Ix),
        dispatch_panel_event(Panel,Ev(X,Y,selection(Ix,Sel)),list(name(Name),Ps..))].

% support multiple selected lines by shift-click
panel_event(Panel,select(X,Y,0,0,1,0),list(name(Name),Ps..)):-
    panel_scroll_item_info(list(name(Name),Ps..),[CXl,CYt,CXr,CYb],Span,Max),
    X < CXr,X > CXl,                % new item selection
    Ps=[_,Contents,selection(Indx,Sel),top(Top),_,Font,_..], % pick up top and font info
    $fontheight(Font,H),
    Selofs is ((Y-CYt) // H),Selofs=<Span-1,
    Ix is Top+Selofs,
    Ix =< Max->
        [arg(Ix,Contents,Item),
	   $listMember(Ix,Indx) -> $removeShiftSelected(Panel,Name) ;
         $updateShiftSelectedStart(Panel,Name,Ix),
         $addselect(Contents,Ix,Indx,NewIndx,Sel,NewSelect)],
    NewSelect \= Sel ->
        dispatch_panel_event(Panel,select(X,Y,selection(NewIndx,NewSelect)),list(name(Name),Ps..)).

% support multiple selected lines by control-click
panel_event(Panel,select(X,Y,1,0,0,0),list(name(Name),Ps..)):-
    panel_scroll_item_info(list(name(Name),Ps..),[CXl,CYt,CXr,CYb],Span,Max),
    X < CXr,X > CXl,                % new item selection
    Ps=[_,Contents,selection(Indx,Sel),top(Top),_,Font,_..], % pick up top and font info
    $fontheight(Font,H),
    Selofs is ((Y-CYt) // H),Selofs=<Span-1,
    Ix is Top+Selofs,
    Ix =< Max->
        $addMultipleSelect(Contents,Ix,Indx,NewIndx,NewSelect),
    NewSelect \= Sel ->
        dispatch_panel_event(Panel,select(X,Y,selection(NewIndx,NewSelect)),list(name(Name),Ps..)).

% support multiple selected blocks by control-shift-click
panel_event(Panel,select(X,Y,1,0,1,0),list(name(Name),Ps..)):-
    panel_scroll_item_info(list(name(Name),Ps..),[CXl,CYt,CXr,CYb],Span,Max),
    X < CXr,X > CXl,                % new item selection
    Ps=[_,Contents,selection(Indx,Sel),top(Top),_,Font,_..], % pick up top and font info
    $fontheight(Font,H),
    Selofs is ((Y-CYt) // H),Selofs=<Span-1,
    Ix is Top+Selofs,
    Ix =< Max->
	  [$getShiftSelectedStart(Panel,Name,Index),
	   $getShiftSelectedEnd(Panel,Name,EndIndex),
	   $addMultipleSelect(Contents,Ix,Index,NewIndex,NewSelection),
	   $appendLists(Indx, NewIndex,NewIndx),
	   sort(NewIndx,SortedIndx),
	   $adjustSelectedList(Ix,Index,EndIndex,SortedIndx,NewSorted),
	   $fixItems(Contents,NewSorted,NewSelect)],
    NewSelect \= Sel ->
        dispatch_panel_event(Panel,select(X,Y,selection(NewSorted,NewSelect)),list(name(Name),Ps..)),
        $updateShiftSelectedEnd(Panel,Name,Ix).

$listMember(X,X).
$listMember(X,List) :-
   $member(X,List).

$adjustSelectedList(Ix,StartIndex,EndIndex,IndexList,IndexList) :-
	Ix =< EndIndex,
	EndIndex =< StartIndex,!.
$adjustSelectedList(Ix,StartIndex,EndIndex,IndexList,IndexList) :-
	Ix >= EndIndex,
	EndIndex >= StartIndex,!.
$adjustSelectedList(Ix,StartIndex,EndIndex,IndexList,NewIndexList) :-
	Ix =< StartIndex,
	StartIndex =< EndIndex,!,
	NewIx is StartIndex + 1,
	$trimSelectedList(IndexList,NewIx,EndIndex,NewIndexList).
$adjustSelectedList(Ix,StartIndex,EndIndex,IndexList,NewIndexList) :-
	StartIndex =< Ix,
	Ix =< EndIndex,!,
	NewIx is Ix + 1,
	$trimSelectedList(IndexList,NewIx,EndIndex,NewIndexList).
$adjustSelectedList(Ix,StartIndex,EndIndex,IndexList,NewIndexList) :-
	EndIndex =< Ix,
	Ix =< StartIndex,!,
	NewIx is Ix - 1,
	$trimSelectedList(IndexList,EndIndex,NewIx,NewIndexList).
$adjustSelectedList(Ix,StartIndex,EndIndex,IndexList,NewIndexList) :-
	EndIndex =< StartIndex,
	StartIndex =< Ix,!,
	NewIx is StartIndex - 1,
	$trimSelectedList(IndexList,EndIndex,NewIx,NewIndexList).

$trimSelectedList([],_,_,[]).
$trimSelectedList([X,Rest..],SelectedIndex,Upto,[X,NewRest..]) :-
	X < SelectedIndex;X > Upto,!,
	$trimSelectedList(Rest,SelectedIndex,Upto,NewRest).
$trimSelectedList([X,Rest..],SelectedIndex,Upto,NewIndex) :-
	X =< Upto,
	$trimSelectedList(Rest,SelectedIndex,Upto,NewIndex).

$fixItems(_,[],[]).
$fixItems(Contents,[Idx,RestIdx..],[Item,RestItems..]) :-
	arg(Idx,Contents,Item),
	$fixItems(Contents,RestIdx,RestItems).

$appendLists([],[Y..],[Y..]) :- !.
$appendLists([X,Rest..],Y,[X,Final..]) :-
   $appendLists(Rest,Y,Final).
$appendLists(X,[Y..],[X,Y..]).

$updateShiftSelectedStart(Panel,Name,Index) :-
   recall(shiftSelectedStart(Panel,Name,OldIndex),$local),!,
   update(shiftSelectedStart(Panel,Name,OldIndex),shiftSelectedStart(Panel,Name,Index),$local),
   $updateShiftSelectedEnd(Panel,Name,Index).
$updateShiftSelectedStart(Panel,Name,Index) :-
   remember(shiftSelectedStart(Panel,Name,Index),$local).

$updateShiftSelectedEnd(Panel,Name,Index) :-
   recall(shiftSelectedEnd(Panel,Name,OldIndex),$local),!,
   update(shiftSelectedEnd(Panel,Name,OldIndex),shiftSelectedEnd(Panel,Name,Index),$local).
$updateShiftSelectedEnd(Panel,Name,Index) :-
   remember(shiftSelectedEnd(Panel,Name,Index),$local).

$getShiftSelectedStart(Panel,Name,Index) :-
   recall(shiftSelectedStart(Panel,Name,Index),$local),!.
$getShiftSelectedStart(_,_,0).

$getShiftSelectedEnd(Panel,Name,Index) :-
   recall(shiftSelectedEnd(Panel,Name,Index),$local),!.
$getShiftSelectedEnd(Panel,Name,Index) :-
   $getShiftSelectedStart(Panel,Name,Index).

$removeShiftSelected(Panel,Name) :-
   forget_all(shiftSelectedStart(Panel,Name,_),$local),
   forget_all(shiftSelectedEnd(Panel,Name,_),$local).

% add a sequence of list items from Ix to Indx to the selection list
$addMultipleSelect(Contents,Ix,Indx,NewIndx,NewSelect) :-
   integer(Indx),!,
   Ix =< Indx -> $addMultiples(Contents,Ix,Indx,NewIndx,NewSelect) ;
      $addMultiples(Contents,Indx,Ix,NewIndx,NewSelect).

$addMultipleSelect(Contents,Ix,[Indx,X..],NewIndx,NewSelect) :-
   Ix =< Indx -> $addMultiples(Contents,Ix,Indx,NewIndx,NewSelect) ;
      $addMultiples(Contents,Indx,Ix,NewIndx,NewSelect).

$addMultiples(Contents,Ix,Ix,Ix,Item) :-
   $addselect(Contents,Ix,0,Ix,_,Item),!.
% If nothing is selected, be careful not to add item 0 (i.e. contents(...) functor) to selection list
$addMultiples(Contents,0,Ix,NewIndx,NewSelect) :-
   !,
   $addMultiples(Contents,1,Ix,NewIndx,NewSelect).
$addMultiples(Contents,Ix,Indx,NewIndx,NewSelect) :-
   Ix1 is Ix + 1,
   $addMultiples(Contents,Ix1,Indx,NewIdx,NewSel),
   $addselect(Contents,Ix,NewIdx,NewIndx,NewSel,NewSelect),!.

$addselect(Contents,Ix,0,Ix,_,Item) :-
    arg(Ix,Contents,Item).
$addselect(Contents,Ix,Ix1,NewIndx,Item1,NewSel) :-
    integer(Ix1),
    $addselect1(Contents,Ix,[Ix1],Indx1,[Item1],Sel1),
    $selectedlist(Indx1,NewIndx,Sel1,NewSel).
$addselect(Contents,Ix,Indx,NewIndx,Sel,NewSel) :-
    $addselect1(Contents,Ix,Indx,Indx1,Sel,Sel1),
    $selectedlist(Indx1,NewIndx,Sel1,NewSel).
    
$addselect1(Contents,Ix,[],[Ix],[],[Item]) :-
    arg(Ix,Contents,Item).
$addselect1(Contents,Ix,[I,Indx..],[Ix,I,Indx..],[S,Sel..],[Item,S,Sel..]) :-
    Ix < I,
    arg(Ix,Contents,Item).
$addselect1(Contents,Ix,[Ix,Indx..],Indx,[S,Sel..],Sel). % shift-clicking a selected line unselects it
$addselect1(Contents,Ix,[I,Indx..],[I,NewIndx..],[S,Sel..],[S,NewSel..]) :-
    $addselect1(Contents,Ix,Indx,NewIndx,Sel,NewSel).

$selectedlist([],0,_,'').
$selectedlist([Ix],Ix,[Sel],Sel).
$selectedlist(Ix,Ix,Sel,Sel).

% *** list ***  Graphics...

panel_item_class(list). %-- this was in the file panel objects 

panel_item_new(list,Name,X1,Y1,
               list(name(Name),place(X1,Y1,X2,Y2),contents(),selection(0,''),top(1),
                    style(rectangle),font(0,12))):-
    X2 is X1+120,  Y2 is Y1+82.

% draw method
panel_item_graf(list(Name,Place,Ps..),
        [[BP,BC,Cont,
          VSlider,
          Internals]]):-
    Ps=[Contents,Selection,Top,Style,Font,Etc..],
    $lcontainer(Style,Place,Cont,BP,BC),
    panel_scroll_item_info(list(Name,Place,Ps..),Clip,Span,Max),
    panel_scroll_vslider(Style,Place,Top,Span,Max,nil,VSlider),
    $draw_list(move,Clip,Ps,Span,Internals).

% write methods
panel_item_write(list(_..),list(N,P,Contents,selection(I,S),Top,Etc..),
            list(N,P,Contents,AdjSel,AdjTop,Etc..),Graf):-
    panel_scroll_item_adjust(list(N,P,Contents,selection(I,S),Top,Etc..),AdjTop,AdjSel),
    panel_item_graf(list(N,P,Contents,AdjSel,AdjTop,Etc..),Graf).

panel_item_write(list(N,P,Contents,selection(I0,_),Top,Style,Font,Etc..),
                 selection(I,S),
                 list(N,P,Contents,selection(I1,S1),Top,Style,Font,Etc..),
                 G):-   % special case situation where only selection has changed
    $adjustsel(Contents,I,S,I1,S1), % make sure selection consistent
    $cliprect(Style,P,CP),
    $fontheight(Font,H),
    $ord_diff(I0,I1,Invert),
    $invert(Style,CP,H,Top,Invert,G).	% yanzou@bnr.ca:19/10/95:
										% added: Style
										% reason: choose the right backcolor

$ord_diff(X,0,Diff) :- 
    $ord_diff(X,[],Diff).
$ord_diff(0,Y,Diff) :- 
    $ord_diff([],Y,Diff).
$ord_diff(X,Y,Diff) :-
    integer(X),
    $ord_diff([X],Y,Diff).
$ord_diff(X,Y,Diff) :-
    integer(Y),
    $ord_diff(X,[Y],Diff).
$ord_diff(X,Y,Diff) :-
    list(X,Y),
    $ord_diff1(X,Y,Diff).

$ord_diff1(X,X,[]).
$ord_diff1([],Y,Y).
$ord_diff1(X,[],X).
$ord_diff1([X,Xs..],[X,Ys..],Diff) :-
    $ord_diff1(Xs,Ys,Diff).
$ord_diff1([X,Xs..],[Y,Ys..],[X,Diff..]) :-
    X < Y,
    $ord_diff1(Xs,[Y,Ys..],Diff).
$ord_diff1([X,Xs..],[Y,Ys..],[Y,Diff..]) :-
    X > Y,
    $ord_diff1([X,Xs..],Ys,Diff).

panel_item_write(list(Name,Place,Contents,Selection,Top,Style,Font..),   % scroll
                 scroll(SType,Delta),
                 list(Name,Place,Contents,Selection,NewTop,Style,Font..),
                 [[BP,BC,             
                   VSlider,
                   Internals]]):-
    panel_scroll_item(SType,list(Name,Place,Contents,Selection,Top,Style,Font..),Delta,
            NewTop,Clip,Span,VSlider),
    $lcontainer(Style,Place,Cont,BP,BC),
    $draw_list(SType,Clip,[Contents,Selection,NewTop,Style,Font..],Span,Internals).

panel_item_write(list(Name,Place,Contents,Selection,Top,Style,Font..),
                 scroll(SType,up(X,Y)),
                 list(Name,Place,Contents,Selection,Top,Style,Font..),
                 [[BP,BC,                      % $scroll_it failed, but mouse up
                   VSlider]]):-                % so clear arrows
    panel_scroll_item_info(list(Name,Place,Contents,Selection,Top,Style,Font..),
                 [CXl,CYt,CXr,CYb],Span,Max),
    Top=top(Val),$slider_offset(Val,Span,Max,CYt,CYb,So),
    Place=place(Xl,Yt,Xr,Yb),$scroll_step(SType,up,Y,So,Yt,CYb,Span,D,Fill),
    $lcontainer(Style,Place,Cont,BP,BC),
    panel_scroll_vslider(Style,Place,Top,Span,Max,Fill,VSlider).

panel_item_write(list(Etc..),scroll(_,_),list(Etc..),[]).  % can't scroll -> no change

% grow method
panel_item_grow(list(_..),17,34). % slider width=16,slider height=top box+2+bottom box

% list characteristics
panel_scroll_item_info(list(Name,P,Contents,Selection,Top,Style,Font,Etc..),
        [CXl,CYt,CXr,CYb],Span,Max):-
    $cliprect(Style,P,[CXl,CYt,CXr,CYb]),
    termlength(Contents,Max,_),
    $fontheight(Font,H),
    Span is (CYb-CYt)//H.

% list graphics
% toggle selections

% yanzhou@bnr.ca:19/10/95: added $invert/6
% reason: to set correct backcolor before fillpat(invert)
$invert(Style, CP, H, Top, Invert, [backpat(BP), backcolor(BC), G]):-
	$lcontainer(Style, _, _, BP, BC),
	$invert(CP, H, Top, Invert, G).

$invert(CP,H,Top,[],[]).
$invert([XL,YT,XR,YB],H,top(Top),[I,Is..],[fillpat(invert),rectabs(XL,YST,XR,YSB),Inverts..]):-
    YST is YT+(I-Top)*H,
    YSB is YST+H,
    YSB=<YB,YST>=YT,!,  % commit
    $invert([XL,YT,XR,YB],H,top(Top),Is,Inverts).
$invert(CP,H,Top,[I,Is..],Inverts):-    % item not displayed, ignore it
    $invert(CP,H,Top,Is,Inverts).

% update list after scroll
$draw_list(Stype,[CXl,CYt,CXr,CYb],[contents(L..),selection(I,_),top(NT),Style,font(F,S,St..),Etc..],Span,
        [scrollrect(CXl,CYt,CXr,SYb,0,Scroll),
         textfont(F),textsize(S),textface(St..),Line]):-
    $fontheight(font(F,S,St..),H),
    [Stype=up,  Scroll=H,    LYt = CYt,            IX = NT];
    [Stype=down,Scroll is -H,LYt is CYt+(Span-1)*H,IX is NT+Span-1],
    !,
    LYb is LYt+H,
    SYb is CYt+Span*H,
    $setup_list([CXl,LYt,CXr,LYb],[IX,I,L],font(F,S,St..),Line).

% draw visible list contents
$draw_list(Stype,Clip,[contents(L..),selection(I,_),top(Top),Style,font(F,S,St..),Etc..],Span,
        [fillpat(clear),rectabs(Clip..),textfont(F),textsize(S),textface(St..),Graf..]):-
    $setup_list(Clip,[Top,I,L],font(F,S,St..),Graf).

$setup_list([CXl,CYt,CXr,CYb],V,font(F,S,St..),Graf):-
    iswindow(W,graf,_),                     % pick a window for text width test
    isfont(F,S,_,[A,D,L,_],face(St..)),     % font info
    $draw_lines(W,V,[CXl,CYt,CXr,CYb],CYt,font(F,S,St,A,D,L),Graf).

$draw_lines(W,[Top,Select,Contents],[CXl,CYt,CXr,CYb],YC,font(F,S,St,A,D,L),[Line,Lines..]):-
    YY is YC+A+D+L,
    YY =< CYb,
    arg(Top,Contents,Item),
    once($line_graf([Top,Select,Item],[CXl,YC,CXr,YY],font(F,S,St,A,D,L),W,Line)),
    successor(Top,Next),
    $draw_lines(W,[Next,Select,Contents],[CXl,CYt,CXr,CYb],YY,font(F,S,St,A,D,L),Lines).
    
$draw_lines(_,_,[CXl,CYt,CXr,CYb],YC,Font,[fillpat(clear),rectabs(CXl,YC,CXr,CYb)]):-
    CYb>YC.                % no more room or end of list, clear the rest

$draw_lines(_,_,_,_,_,[]). % just in case there's no room to clear

$line_graf([Select,Selected,Item],[XL,YT,XR,YB],Font,W,
   [Line,fillpat(invert),rectabs(XL,YT,XR,YB)]):-
    $selected(Select,Selected),
    panel_list_line_graf(Item,[XL,YT,XR,YB],Font,W,Line).          % selected line

$line_graf([Top,_,Item],[XL,YT,XR,YB],Font,W,Line):-
    panel_list_line_graf(Item,[XL,YT,XR,YB],Font,W,Line).          % unselected line

$selected(L,L).
$selected(L,Ls) :- $member(L,Ls).

% default line grafer, convert term to text and write it in space
panel_list_line_graf(Item,[XL,YT,XR,YB],font(F,S,St,A,D,L),W,textabs(X,Y,Line)):-
    swrite(Text,Item),              % write term to symbol              
    successor(XL,X),Y is YT+A+L-1,  % X,Y coordinates of text line
    Width is XR-XL+1,               % visible width of line (text may be longer)
    $fit(W,Text,Width,font(F,S,St,A,D,L),Line).

$fit(W,Line,Width,font(F,S,St,Etc..),AdjLine):-
    $textwidth(W,Line,font(F,S,St..),Tlength),
    Length is Tlength+2,
    Length=<Width->
       AdjLine=Line;
       [namelength(Line,L),
        AL is ceiling(Width/Length*L),
        (L-AL)<4->NL is L-4;NL=AL,   % adjust length by at least 4 (char + '...')
        substring(Line,1,NL,T1),     % lop off characters
        concat(T1,'...',T2),         % add ellipsis
        $fit(W,T2,Width,font(F,S,St,Etc..),AdjLine)].   % and try again 


% support for list graphics
% define clipping rectangle for lists
$cliprect(style(rectangle),place(Xl,Yt,Xr,Yb),[CXl,CYt,CXr,CYb]):-
    CXr is Xr-16,successor(CYb,Yb),
    successor(Xl,CXl),successor(Yt,CYt).

$cliprect(style(shadow),place(Xl,Yt,Xr,Yb),[CXl,CYt,CXr,CYb]):-
    CXr is Xr-18,CYb is Yb-3,
    successor(Xl,CXl),successor(Yt,CYt).

$cliprect(style(motif),place(Xl,Yt,Xr,Yb),[CXl,CYt,CXr,CYb]):-
    CXr is Xr-18,CYb is Yb-3,
    CXl is Xl+3,CYt is Yt+3.

% various container styles
$lcontainer(style(rectangle),place(Place..),
        [fillpat(hollow),rectabs(Place..)],
        backpat(white),backcolor(white)).

$lcontainer(style(shadow),place(Xl,Yt,Xr,Yb),
       [fillpat(clear),rectabs(Xl,Yt,XFr,YFb),fillpat(hollow),rectabs(Xl,Yt,XFr,YFb),
        moveabs(XSl,YFb),penmode(or),pensize(2,2),lineabs(XFr,YFb,XFr,YSt)],
       backpat(white),backcolor(white)):-
    XFr is Xr-2,YFb is Yb-2,    % field boundaries
    XSl is Xl+3,YSt is Yt+3.    % shadow boundaries

$lcontainer(style(motif),place(Xl,Yt,OXr,Yb),
       [fillpat(clear),rectabs(XFl,YFt,XFr,YFb),
        fillpat(pentype),backcolor(white),
        penpat(black),moveabs(Xl,Yt),
        polygon(lineabs(Xr,Yt,XFr,YFt,XFl,YFt,XFl,YFb,Xl,Yb,Xl,Yt)),
        penpat(white),moveabs(Xr,Yb),
        polygon(lineabs(Xl,Yb,XFl,YFb,XFr,YFb,XFr,YFt,Xr,Yt,Xr,Yb)),
        penpat(black),fillpat(hollow),rectabs(Xl,Yt,Xr,Yb)],
        backpat(white),backcolor(BC)):-
    Xr is OXr-15,
    $motif_colour(BC),
    panel_expand_rect([Xl,Yt,Xr,Yb],-3,-3,[XFl,YFt,XFr,YFb]).    % field boundaries

% graphics for vertical slider
panel_scroll_vslider(style(shadow),place(Xl,Yt,Xr,Yb),Top,Span,Max,Type,Graf):-
    !,  % map shadow style slider to rectangle
    RXr is Xr-2,RYb is Yb-2,
    panel_scroll_vslider(style(rectangle),place(Xl,Yt,RXr,RYb),Top,Span,Max,Type,Graf).

panel_scroll_vslider(style(Style),place(Xl,Yt,Xr,Yb),top(Top),Span,Max,Type,
        [moveabs(CXr,Yt),
         UpArrow,
         Slider,
         lineabs(CXr,YBl),
         DownArrow]):-
    successor(Yt,CYt),successor(CYb,Yb),CXr is Xr-16,YBl is CYb-15,
    $slider(Style,Top,Span,Max,CYt,CYb,Slider),
    $arrowboxes(Type,Style,UpArrow,DownArrow).

$slider(motif,Top,Span,Max,CYt,CYb,        
         [fillpat(clear),rectrel(1,16,15,YSb), % shaded portion
          moverel(15,LSb),
		  fillpat(pentype), linerel(0,NYSb),	% RW - due to fillpat affecting lines
          moverel(-15,RSo),
          Box]):-                                    % thumb box        
    $slider_offset(Top,Span,Max,CYt,CYb,So),         % need a thumb
    YSb is CYb-CYt-14,
    So>15,So+15=<YSb,    % don't draw a thumb if there's no room
    successor(LSb,YSb),NYSb is 16-LSb,RSo is So-16,
    $arrowbox(white,black,Box,[]),!.

$slider(motif,Top,Span,Max,CYt,CYb,         
          [fillpat(clear),rectrel(0,16,15,YSb),moverel(15,LSb),
		   fillpat(pentype),linerel(0,NYSb)]):-	% RW - due to fillpat affecting lines
    YSb is CYb-CYt-14,
    successor(LSb,YSb),NYSb is 16-LSb.

$slider(Style,Top,Span,Max,CYt,CYb,        
         [[penpat(lightgray),fillpat(pentype),rectrel(1,16,15,YSb)], % shaded portion
          fillpat(clear),rectrel(1,So,15,SB),
          fillpat(hollow),rectrel(1,So,15,SB)]):-
    Style\=motif,
    $slider_offset(Top,Span,Max,CYt,CYb,So),         % need a thumb
    YSb is CYb-CYt-14,
    So>15,SB is So+16,SB=<YSb,!.    % don't draw a thumb if there's no room

$slider(Style,Top,Span,Max,CYt,CYb,         
          [fillpat(clear),rectrel(1,16,15,YSb)]):-
    Style\=motif,
    YSb is CYb-CYt-14.

$arrowboxes(pageup,_,_,_).

$arrowboxes(pagedown,_,_,_).

$arrowboxes(up,rectangle,[fillpat(pentype),UpArrow..],_):-
    $uparrow(rectangle,[UpArrow..]).

$arrowboxes(down,rectangle,_,[fillpat(pentype),DownArrow..]):-
    $downarrow(rectangle,[DownArrow..]).

$arrowboxes(upnil,rectangle,UpBox,_):-
    $arrowbox(UpBox,UpArrow),
    $uparrow(rectangle,UpArrow).

$arrowboxes(downnil,rectangle,_,DownBox):-
    $arrowbox(DownBox,DownArrow),
    $downarrow(rectangle,DownArrow).

$arrowboxes(nil,rectangle,UpBox,DownBox):-
    $arrowbox(UpBox,UpArrow),
    $uparrow(rectangle,UpArrow),
    $arrowbox(DownBox,DownArrow),
    $downarrow(rectangle,DownArrow).

$arrowboxes(up,motif,UpBox,_):-
    $arrowbox(black,white,UpBox,UpArrow).

$arrowboxes(down,motif,_,DownBox):-
    $arrowbox(black,white,DownBox,DownArrow).

$arrowboxes(upnil,motif,UpBox,_):-
    $arrowbox(white,black,UpBox,UpArrow).

$arrowboxes(downnil,motif,_,DownBox):-
    $arrowbox(white,black,DownBox,DownArrow).

$arrowboxes(nil,motif,[fillpat(clear),rectrel(2,2,14,14),UpBox..],
                      [fillpat(clear),rectrel(2,2,14,14),DownBox..]):-
    $arrowbox(white,black,UpBox,UpArrow),
    $uparrow(motif,UpArrow),
    $arrowbox(white,black,DownBox,DownArrow),
    $downarrow(motif,DownArrow).

$uparrow(rectangle,[moverel(1,8),polygon(linerel(6,-6,6,6,-3,0,0,4,-6,0,0,-4,-2,0))]).
$uparrow(motif,[moverel(4,8),polygon(linerel(4,-4,4,4,-2,0,0,3,-3,0,0,-3,-3,0))]).
$downarrow(rectangle,[moverel(7,13),polygon(linerel(-6,-6,3,0,0,-4,6,0,0,4,3,0,-5,5))]).
$downarrow(motif,[moverel(8,12),polygon(linerel(-4,-4,3,0,0,-3,3,0,0,3,2,0,-4,4))]).

$arrowbox([fillpat(clear),rectrel(1,1,15,15),fillpat(hollow),rectrel(0,0,16,16),Arrow..],Arrow).
$arrowbox(UL,BR,[fillpat(clear),
                 [backcolor(UL),
                  moverel(1,1),polygon(linerel(14,0,-2,2,-10,0,0,10,-2,2,0,-14)),
                  backcolor(BR),
                  moverel(14,14),polygon(linerel(-14,0,2,-2,10,0,0,-10,2,-2,0,14)),
                  fillpat(hollow),rectrel(-15,-15,1,1)],
                 fillpat(hollow),Arrow..],Arrow).

$slider_offset(_,Span,Max,CL,CU,So):-  % no slider case, list fits into box
    Span>=Max,
    failexit($slider_offset).

$slider_offset(Top,Span,Max,CL,CU,So):-  % offset calculate 
    So is 16+round((CU-CL-46)*(Top-1)/(Max-Span)).

%  ------ animation support for scrolling class events ---------------------------

panel_event(Panel,select(X,Y),Class(Name,Place,Contents,Selection,top(Top),Etc..)) :-
    panel_scroll_item_info(Class(Name,Place,Contents,Selection,top(Top),Etc..),[CXl,CYt,CXr,CYb],Span,Max),
    X >= CXr,
    $slider_offset(Top,Span,Max,CYt,CYb,So),
    $scroll_request(Y,So,Panel,Class(Name,Place,Contents,Selection,top(Top),Etc..)).

$scroll_request(Y,So,Panel,Class(Name,Place,Contents,Selection,Top,style(Style),Etc..)):-
    $scroll_dragger(Y,So,Panel,Place,Delta,Style),
    panel_view(Panel,Class(Name,Place,Contents,Selection,Top,style(Style),Etc..):=scroll(move,Delta)). 

$scroll_request(Y,So,Panel,Class(Name,place(Xl,Yt,Xr,Yb),_..)):-
    $scroll_type(Y,So,Yt,Yb,SType),
    remember(scroll(Class,Name,place(Xl,Yt,Xr,Yb),scroll,SType,0),$local).

$scroll_dragger(Y,So,Panel,place(Xl,Yt,Xr,Yb),Delta,Style):-
    Yb-Yt>47,   % need to have room for a thumb
    To is Yt+So,
    Y>=To,TYb is To+15,Y=<TYb,  % mouse inside thumb
    MXl is Xr-32,MXr is Xr+16,  % define limits for mouse (within 16 pixels of thumb)
    MYt is Yt+15,
    $thumb_limits(Style,Xr,TXr,Yb,MYb),TXl is TXr-14,
    X is TXr-8,
    panel_id(Panel,_,Window),   % convert panel to window for dograf
    $dragit(Window,[rectabs(TXl,To,TXr,TYb)],X,Y,
                            MXl,MYt,MXr,MYb,
                            MXl,-4000,MXr,4000,
                            vert,_,Delta).

$thumb_limits(shadow,Xr,TXr,Yb,MYb):-TXr is Xr-3,MYb is Yb-18,!.
$thumb_limits(_,Xr,TXr,Yb,MYb):-successor(TXr,Xr),MYb is Yb-16.

$scroll_type(M,So,CL,CU,up):-M<(CL+16).
$scroll_type(M,So,CL,CU,pageup):-M>=(CL+16),M<(CL+So).
$scroll_type(M,So,CL,CU,pagedown):-M>=(CL+So+16),M<(CU-16).
$scroll_type(M,So,CL,CU,down):-M>=(CU-16).

$dragit(Args..):-dragregion(Args..),!.
$dragit(Window,Args..):-dograf(Window,dragregion(Args..)).

userdownidle(Panel,X,Y):-   % scrolling
    get_obj(Op,scroll(Class,Name,Place,Dir,SType,C),$local),
    C>5->panel_view(Panel,Class(Name,Place,_..):=Dir(SType,idle(X,Y))),
    successor(C,C1),
    put_obj(Op,scroll(Class,Name,Place,Dir,SType,C1),$local).

usermouseup(Panel,X,Y):-    % end scrolling
    forget(scroll(Class,Name,Place,Dir,SType,C),$local),
    panel_view(Panel,Class(Name,Place,_..):=Dir(SType,up(X,Y))).

%  ------ support for scrolling class methods  -------------------------------
%   for list class and icon list in button editor

% bounds checks on top and selection
panel_scroll_item_adjust(Class(N,P,Contents,selection(I0,S0),top(T0),Etc..),top(T1),selection(I1,S1)):-
    panel_scroll_item_info(Class(N,P,Contents,selection(I0,S0),top(T0),Etc..),_,Span,Max),
    $adjustsel(Contents,I0,S0,I1,S1),
    $adjusttop(Span,Max,T0,T1).

$adjusttop(Span,Max,Top,1):-Top<1.
$adjusttop(Span,Max,Top,1):-Span>=Max.
$adjusttop(Span,Max,Top,Top):-Top>=1,Top=<Max-Span+1.
$adjusttop(Span,Max,Top,MaxTop):-MaxTop is Max-Span+1,Top>MaxTop.

$adjustsel(contents(L..),Ix,Sel,AdjIx,AdjSel) :-
    integer(Ix),
    $adjustsel1(contents(L..),Ix,AdjIx,AdjSel).
$adjustsel(contents(L..),Ix,Sel,AdjIx,AdjSel) :-
    list(Ix),
    sort(Ix,SortedIx),
    $adjustsel2(contents(L..),SortedIx,Ix1,Sel1),
    $selectedlist(Ix1,AdjIx,Sel1,AdjSel).
$adjustsel(contents(L..),Ix,Sel,AdjIx,AdjSel) :-
    var(Ix),
    list(Sel),
    $adjustsel3(contents(L..),Sel,Ix),
    sort(Ix,SortedIx),
    $adjustsel2(contents(L..),SortedIx,Ix1,Sel1),
    $selectedlist(Ix1,AdjIx,Sel1,AdjSel).
$adjustsel(contents(L..),Ix,Sel,Ix,Sel) :-
    var(Ix),
    arg(Ix,L,Sel).
$adjustsel(contents(L..),_,_,0,'').

% given a single index
$adjustsel1(contents(L..),Ix,0,'') :- Ix =< 0.
$adjustsel1(contents(L..),Ix,Ix,AdjSel) :- arg(Ix,L,AdjSel).
$adjustsel1(contents(L..),Ix,Max,AdjSel) :- termlength(L,Max,_),arg(Max,L,AdjSel).

% given a list of indices
$adjustsel2(_,[],[],[]).
$adjustsel2(contents(L..),[Ix,Ixs..],[Ix,AdjIxs..],[Sel,AdjSels..]) :-
    arg(Ix,L,Sel),!,
    $adjustsel2(contents(L..),Ixs,AdjIxs,AdjSels).
$adjustsel2(contents(L..),[Ix,Ixs..],AdjIxs,AdjSels) :-
    Ix=<0,
    $adjustsel2(contents(L..),Ixs,AdjIxs,AdjSels).
$adjustsel2(contents(L..),[Ix,_..],[Max],[S]) :-
    termlength(L,Max,_), Ix > Max,  % index greater than length
    arg(Max,L,S).

% given a list of items
$adjustsel3(contents(L..),[],[]).
$adjustsel3(contents(L..),[Sel,Sels..],[Ix,Ixs..]) :-
    arg(Ix,L,Sel),
    $adjustsel3(contents(L..),Sels,Ixs).
$adjustsel3(contents(L..),[Sel,Sels..],Ixs) :-
    $adjustsel3(contents(L..),Sels,Ixs).

%  ------ support for scrolling class methods  -------------------------------

% scroll request: drag, page or line
%   return new top, draw area clipping rectangle, Span, and and slider graphics

panel_scroll_item(move,Class(Name,Place,Contents,Select,top(Top),Style,Etc..),Delta,
            top(NewTop),[CXl,CYt,CXr,CYb],Span,VSlider):- % drag scroll
    panel_scroll_item_info(Class(Name,Place,Contents,Select,top(Top),Style,Etc..),
                 [CXl,CYt,CXr,CYb],Span,Max),
    $scroll_amount(Span,Max,CYt,CYb,Delta,D),
    $scroll_list(Top,D,Span,Max,NewTop),
    panel_scroll_vslider(Style,Place,top(NewTop),Span,Max,pageup,VSlider),!.

panel_scroll_item(SType,Class(Name,place(Xl,Yt,Xr,Yb),Contents,Select,top(Top),Style,Etc..),
            M(X,Y),top(NewTop),[CXl,CYt,CXr,CYb],Span,VSlider):- % line or page scroll
    panel_scroll_item_info(Class(Name,place(Xl,Yt,Xr,Yb),Contents,Select,top(Top),Style,Etc..),
                 [CXl,CYt,CXr,CYb],Span,Max),
    X>CXr,X=<Xr,    % still in scroll area
    $slider_offset(Top,Span,Max,CYt,CYb,So),
    $scroll_step(SType,M,Y,So,Yt,CYb,Span,D,Fill),
    $scroll_list(Top,D,Span,Max,NewTop),
    panel_scroll_vslider(Style,place(Xl,Yt,Xr,Yb),top(NewTop),Span,Max,Fill,VSlider),!.

% scroll limit checking
$scroll_list(T,D,Span,Max,NT):-
    D<0,    % negative scrolling 
    T>1,    % scrolling is possible
    N is T+D,
    $adjusttop(Span,Max,N,NT),!.

$scroll_list(T,D,Span,Max,NT):-
    D>0,            % positive scrolling 
    T<Max-Span+1,   % scrolling is possible
    N is T+D,
    $adjusttop(Span,Max,N,NT),!.

% calculate change in top from change in slider position
$scroll_amount(Span,Max,Yt,Yb,Delta,D):-
    D is round((Max-Span)*Delta/(Yb-Yt-45)).
      
% calculate scroll amount and arrow fill from mouse coordinates (X,Y) 
%   and scrolling type (page or increment)

$scroll_step(up,idle,M,So,CL,CU,_,-1,up):-
    M>=CL,M<CL+15.
$scroll_step(down,idle,M,So,CL,CU,_,1,down):-
    M>(CU-15),M=<CU.
$scroll_step(pageup,_,M,So,CL,CU,Span,Step,pageup):-
    M>=CL+15,M=<(CL+So),
    Step is -Span+1.
$scroll_step(pagedown,_,M,So,CL,CU,Span,Step,pagedown):-
    M>=(CL+So+15),M=<CU-15,
    Step is Span-1.
$scroll_step(up,up,M,So,CL,CU,_,D,upnil):-
    [M>=CL,M<CL+15]->D= -1;D=0.
$scroll_step(down,up,M,So,CL,CU,_,D,downnil):-
    [M>(CU-15),M=<CU]->D=1;D=0.

% -- conversion routines for old list objects

$upgradeobj(list(Name,Place,V),Item):-
    var(V),!,
    $upgradeobj(list(Name,Place,[0,0,[]]),Item).

$upgradeobj(list(Name,Place,[T,S,[L..]]),Item):-
    $upgradeobj(list(Name,Place,[[T,S,[L..]],style(rectangle),font(0,12)]),Item).

$upgradeobj(list(Name,Place,[[T,S,[L..]],Style,Font]),
            list(name(Name),place(Place..),contents(L..),selection(S,Sel),top(T),Style,Font)):-
    once(arg(S,L,Sel);Sel='').
