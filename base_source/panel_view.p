/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/panel_view.p,v 1.1 1995/09/22 11:25:51 harrisja Exp $
*
*  $Log: panel_view.p,v $
 * Revision 1.1  1995/09/22  11:25:51  harrisja
 * Initial version.
 *
*
*/
/*
 *   panel view
 *
 *   BNR Prolog
 *
 *   Copyright © Bell-Northern Research Ltd. 1991
 */

/****************************************************************************/
    
% --------- Panel control routines -------------------------------------------
%
% This file implements panel_view which supports reading and writing objects
% in open panels. The object data base is managed here.
%
/* The general form is:

            panel_view(Panel,Item_access..)

Item_access can be any number of terms of the following forms:

    Class(Name) : Value     unify Value with a component of Items current value.
                            A component can be a property, a list of properties,
                            or a form defined by the class, e.g., if Class=field,
                            a variable Value will be unified with a symbol which
                            is the field's contents, as in

                                    field(fred):Text
                
                            Note the semantics of this operation is defined by:                              
                              panel_item_read(Item,Value)                
                            which unifies Value as appropriate for this Item.

    Name : Value            shorthand form of that above. e.g.: fred:Text

    Class(name(Name),place(Place..),Ps..) : Value

                            longhand form of the above, e.g.:
 
                                    field(name(fred),place(P..),Ps..)
                                Note that any unbound variables in the property list
                                are bound and can be used in subsequent operations.


    Class(Name) := Value    assign a new value to the panel Item. As for ':', Value
                                can be a property, a property list, or a class
                                defined form, e.g.,

                                field(fred):='1234'
                          
                            Note this calls:

                                panel_item_write(Item,Value,NewItem,Graf)

                            which is responsible for any Graf structue that
                            will cause the display to be updated appropriately.
                            dograf(Panel,Graf) is the ONLY side effect in addition
                            to the object assignment. Shorthand and longhand froms
                            of the item are allowed as described above.


Less common Item_access forms include:   

    Class(Name) <= NewItem  replace Item with NewItem. Erase and the old item,
                            draw the new one, and invalidate any exposed area.
                            Note that no property binding occurs for the replacement
                            operation due to an implementation decision to conserve
                            stack space.

    [Items..]<=[NewItems..] deletes Items and inserts NewItems
                            
    Class(Name,Place,Props..)  Unify with Item in Panels content list, this can
                              also be used as a generator.
    
    [] : Items  -- Complete list of items in the panel.
  
    [] <= Item (or [Items..]) -- to REPLACE panel item contents.

    delete(Class(Name)) -- remove an item from the panel contents

    insert(Class(Name,Place,Props..))  -- add a new item into the panel contents
*/
% ---------------------------------------------------------------------------
% -- other local predicates used:
%   $member         in 'panel works'
%   $drawobj        in 'panel sys'
%   $paint_update   in 'panel sys'
%
% operator definitions need to preceed their usage:
%
%%%op(700, xfy, :=). % Item:=Message for panel_item_write...
%
%%%op(700, xfy, <=). % Item<=NewItem for replace item...
%
$panelop(X):-var(X),!,fail.
$panelop(':').
$panelop(':=').
$panelop('<=').
$panelop('delete').
$panelop('insert').
%
% -- user access to panel items ---------------------------------------------
%    always succeeds, individual items may fail; failures should not leave side effects

panel_view(Panel,Terms..):-
    panel_id(Panel,_,Window),
    $panel_actions(Window,Terms..).

$panel_actions(Window).

$panel_actions(Window,Term,Terms..):-
    $panel_action(Window,Term),
    $panel_actions(Window,Terms..).

% Access to items in state space - internal representation only known here
%   and can be optimized for fast retrieval on hash

$getitem(Op,Window(Class(name(Name),place(Place..),Props..))):-
    get_obj(Op,Window(Name,Class,place(Place..),Props..),$local).

$putitem(Op,Window(Class(name(Name),place(Place..),Props..))):-
    put_obj(Op,Window(Name,Class,place(Place..),Props..),$local).

$newitem(Window(Class(name(Name),place(Place..),Props..)),Op):-
    new_obj(Window(Name,Class,place(Place..),Props..),Op,$local).
/*
$disposeitem(Op):-
    dispose_obj(Op,$local).
*/
    
% -- Unify with Item(s) in the panel ------------------------
 
$panel_action(Window,Class(name(Name),place(Place..),Props..)):-
    not($panelop(Class)),!,     % Class not an operator, e.g., :=,<=,:
    recall(Window(Name,Class,place(Place..),Props..),$local).  % no cut, so can act as a generator

% --  Operations on total content list -----------------------------

$panel_action(Window,[]:Items):-            % read complete list of items
    get_obj(_,Window(Panel,Down,IList),$local),
    $itemlist(Window,IList,Items),!.        % commit to list

$itemlist(_,[],[]).

$itemlist(Window,[[Op,P],IList..],[Item,Items..]):-
    $getitem(Op,Window(Item)),
    $itemlist(Window,IList,Items).


$panel_action(Window,[]:=New):-           % insert new item or list of items   
    $panel_action(Window,insert(New)),!.  % commit

$panel_action(Window,[]<=Items):-         % replace complete list of items 
    get_obj(Hitobj,Window(Panel,Down,IList),$local),
    foreach($member([Op,_],IList) do dispose_obj(Op,$local)),
    $savecontent(Window,Items,Hitlist),
    put_obj(Hitobj,Window(Panel,Down,Hitlist),$local),
    sizewindow(Window,W,H),
    invalidrect(Window,0,0,W,H),!. % invalidate the whole panel (saving over delete old, paint new)


% -- panel_item_read access -----------------------------------------

$panel_action(Window,Name:Value):-
    $template(Name,Item),               % expand to full object as necessary
    $getitem(_,Window(Item))->          % retrieve it from data base
        panel_item_read(Item,Value),!.  % and perform read/commit


% -- panel_item_write access ----------------------------------------

$panel_action(Window,Name:=Value):-
    nonvar(Value),          % must write non var
    $template(Name,Item),
    $getitem(Op,Window(Item))->
       [panel_item_write(Item,Value,Newitem,Graf),
        $putitem(Op,Window(Newitem)),
        $moved(Item,Newitem,P,NP) ->                % did object change cover
           [$updatehitlist(Window,[Op,P],[Op,NP]),  % update hitlist  
            $panel_action(Window,[]:Items),         % and repaint old and new
            $update_cover(P,NP,Covers),
            $paint_update(Covers,Items,Window)];
           $drawobj(Window,Graf)],                  % no change in place, just draw it
    !.                                              % commit

$moved(_(_,place(P..),_..),_(_,place(NP..),_..),P,NP):-P\=NP.

% optimize covers for grow case, prevents lots of flashing
$update_cover([XL,YT,XR,YB],[XL,YT,NXR,NYB],[XL,YT,NXR,NYB]):-
    NXR>=XR,NYB>=YB.

$update_cover([XL,YT,XR,YB],[XL,YT,NXR,NYB],[[XL,YT,NXR,NYB],[NXR,YT,XR,YB]]):-
    NXR<XR,NYB>=YB.

$update_cover([XL,YT,XR,YB],[XL,YT,NXR,NYB],[[XL,YT,NXR,NYB],[XL,NYB,XR,YB]]):-
    NXR>=XR,NYB<YB.

$update_cover([XL,YT,XR,YB],[XL,YT,NXR,NYB],[XL,YT,XR,YB]):-
    NXR<XR,NYB<YB.

$update_cover(P,NP,[P,NP]).     % top left corner not the same, just combine covers


% -- replace an old item with a new one ---------------------------------

$panel_action(Window,Name<=Newitem):-                     % complex replace (includes lists)
    not(not($panel_action(Window,delete(Name)))),         % delete old (reclaim space)
    not(not($panel_action(Window,insert(Newitem)))),      % insert new (reclaim space)
    !.                         % commit, note that no binding took place


% -- delete an item -----------------------------------------

$panel_action(Window,delete(Name)):-
    $panel_delete(Window,Name,Area,Ops)->            % Area:exposed areas,Ops:deleted item pointers
       [not(not([get_obj(Op,Window(Panel,Down,Hlist),$local),   % update hitlist
             $hitdelete(Ops,Hlist,Newhlist),
             put_obj(Op,Window(Panel,Down,Newhlist),$local)])),
        not(not([$panel_action(Window,[]:Items),     % Items is new list of objects
             $paint_update(Area,Items,Window)]))],   % repaint Items exposed by Areas
    !.                                               % commit

$panel_delete(Window,[],[],[]).

$panel_delete(Window,[Name,Names..],[Cover,Covers..],[Op,Ops..]):-
    $panel_delete(Window,Name,Cover,Op),!,  % delete and commit
    $panel_delete(Window,Names,Covers,Ops).

$panel_delete(Window,[Name,Names..],Covers,Ops):-   %  delete Name failed, ignore it
    $panel_delete(Window,Names,Covers,Ops).

$panel_delete(Window,Item,Cover,Op):-
    $template(Item,Class(Name,place(Cover..),Etc..)),
    $getitem(Op,Window(Class(Name,place(Cover..),Etc..))),
    dispose_obj(Op,$local).      % coverage for later paint


% -- insert a new item --------------------------------------

$panel_action(Window,insert(Name)):-
    get_obj(Op,Window(Panel,Down,Hlist),$local),
    $panel_insert(Window,Name,Hlist,Newhlist),
    put_obj(Op,Window(Panel,Down,Newhlist),$local),!.   % commit

$panel_insert(Window,[],Hlist,Hlist).

$panel_insert(Window,[Item,Items..],Hlist,Newhlist):-
    $panel_insert(Window,Items,Hlist,Hlist1),     % preserve order
    $panel_insert(Window,Item,Hlist1,Newhlist).

$panel_insert(Window,Item,[Hlist..],[[Op,NP],Hlist..]):-
    $newitem(Window(Item),Op)->  % create new item
       [not(not([panel_item_write(Item,Item,NewItem,Graf),  
                 $putitem(Op,Window(NewItem)),
                 $drawobj(Window,Graf)])),   % space reclaim
        $getitem(Op,Window(Class(Name,place(NP..),_..)))]. % retrieve position


% -- Item reference can be in several flavours ---

$template(Class(Name,Place,Props..),Class(Name,Place,Props..)).
$template(Class(Name),Class(name(Name),_..)).
$template(Name,Class(name(Name),_..)):-nonvar(Name).

% -- build contents of a panel including a new hitlist

$savecontent(Window,[],[]).

$savecontent(Window,[Class(name(Name),place(Place..),Etc..),Items..],[[Op,Place],Hitems..]):-
    $newitem(Window(Class(name(Name),place(Place..),Etc..)),Op),
    $savecontent(Window,Items,Hitems).

% -- update hitlist, handles replacement, insertion (Old=[]), and deletion (New=[])

$updatehitlist(Window,[Old..],[New..]):-Old@=New.    % identical item, no replace 

$updatehitlist(Window,[Old..],[New..]):-
    get_obj(Op,Window(Panel,Down,Hlist),$local)->
       [$hitreplace(Old,Hlist,New,Newhlist),
        put_obj(Op,Window(Panel,Down,Newhlist),$local)].

$hitreplace([],[Rest..],[N,P],[[N,P],Rest..]).          % insert

$hitreplace([Old,_..],[],[N,P],[]).                     % no match, ignore it
$hitreplace(Old,[Old,Rest..],[],Rest).                  % delete
$hitreplace(Old,[Old,Rest..],[N,P],[[N,P],Rest..]).     % replace
$hitreplace(Old,[R,Rest..],New,[R,Newrest..]):-
    Old@\=R,
    $hitreplace(Old,Rest,New,Newrest).

% delete a list of item pointers from hitlist
$hitdelete(Op,Hlist,Newhlist):-
    integer(Op),
    $hitreplace([Op,_],Hlist,[],Newhlist).
$hitdelete([],Hlist,Hlist).
$hitdelete([Op,Ops..],Hlist,Newhlist):-
    $hitdelete(Op,Hlist,Hlist1),
    $hitdelete(Ops,Hlist1,Newhlist).

% -- draw all items in the panel in reverse order
$grafpanel(Window):-
    get_obj(_,Window(Panel,Down,IList),$local),
    $graflist(Window,IList).

$graflist(_,[]).

$graflist(Window,[[Op,P],IList..]):-
    $graflist(Window,IList),
    not(not([$getitem(Op,Window(Item)),
             panel_item_graf(Item,Graf),
             dograf(Window,Graf)])).

