/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/panel_trace.p,v 1.1 1995/09/22 11:25:47 harrisja Exp $
*
*  $Log: panel_trace.p,v $
 * Revision 1.1  1995/09/22  11:25:47  harrisja
 * Initial version.
 *
*
*/

panel_event(Panel,E,I):-   % trace mechanism
    E\=upidle(_..),E\=downidle(_..),E\=upidle,E\=downidle,
    nl,write(Panel,':',E,':',I),fail.

panel_event(Panel,E):-   % trace mechanism
    E\=upidle(_..),E\=downidle(_..),E\=upidle,E\=downidle,
    nl,write(Panel,':',E),fail.
/*
panel_view(Panel,A,As..):-
    nl,write('Action:',Panel,':',A),fail.

panel_item_graf(Obj,_):-
    nl,write('Graph:',Obj),fail.

panel_item_write(Obj,Val,_..):-
    nl,write('Write:',Obj,Val),fail.
*/
