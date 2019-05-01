/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/helpmenu.p,v 1.1 1995/09/22 11:24:43 harrisja Exp $
*
*  $Log: helpmenu.p,v $
 * Revision 1.1  1995/09/22  11:24:43  harrisja
 * Initial version.
 *
*
*/
/*
 *	helpMenu
 *
 *	BNR Prolog
 *
 *	Copyright © Bell-Northern Research Ltd. 1989, 1990, 1991
 */
 
installmenu(W, 'Help') :-
	addmenu(W, 'Help', 'Help', -2), 
	additem(W, 'Version', '', 'Help', end_of_menu, _).
	
menuselect(W, 'Help', 'Version') :- version([A,B,C]),
	swrite(Message, "BNR Prolog Version ", A, ".", B, ".", C, " Copyright © Bell-Northern Research Ltd."),
	message(Message).
