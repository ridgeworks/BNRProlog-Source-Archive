/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProMenus.c,v 1.6 1996/10/29 11:34:53 harrisj Exp $
*
*  $Log: ProMenus.c,v $
 * Revision 1.6  1996/10/29  11:34:53  harrisj
 * Added popdownmenu primitive to "hide" pop up menus.
 *
 * Revision 1.5  1996/09/25  16:33:06  harrisj
 * Changed mark attribute to mark(Att) where Att is
 * either 'on' or 'off'.  MenuCB() modified to update the
 * status of the mark MenuItemPtr attribute.  menuitem primitive
 * can toggle mark status.
 *
 * Revision 1.4  1996/09/10  14:55:24  harrisj
 * Enabled menu item mark attribute.  A marked item
 * uses a ToggleButton instead of the normal PushButton.
 * The mark attribute is no longer a structure but a single symbol
 *
 * Revision 1.3  1996/04/18  23:25:51  yanzhou
 * Two changed are made:
 *
 * 1) A disabled menu item was having attribute "disabled" (note the 'd' here), while an
 *    enabled menu item would have "enable" as its attribute.  "disabled" is now changed
 *    to "disable".
 *
 * 2) Added new primtive $menuattr/2 to change attributes of an entire menu. Only "enable"
 *    and "disable" are currently supported.  A disabled pulldown menu in menubar would
 *    have a "grayed-out" button.
 *
 * Revision 1.2  1995/10/06  16:39:17  harrisja
 * *** empty log message ***
 *
 * Revision 1.1  1995/09/22  11:26:53  harrisja
 * Initial version.
 *
*
*/

/* <:t-4:> */
/* include files */

#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifdef SYSV
#else
#include <strings.h>
#endif

#include <X11/IntrinsicP.h>   /* X and Motif libraries */
#include <X11/StringDefs.h>
#include <X11/keysym.h>
#include <X11/Shell.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>

#include <Xm/Xm.h>
#include <Xm/Protocols.h>
#include <Xm/AtomMgr.h>
#include <Xm/CascadeBG.h>
#include <Xm/PushB.h>
#include <Xm/PushBG.h>
#include <Xm/ToggleBG.h>
#include <Xm/SeparatoG.h>
#include <Xm/MainW.h>
#include <Xm/BulletinB.h>
#include <Xm/MwmUtil.h>
#include <Xm/RowColumn.h>
#include <Xm/Text.h>
#include <Xm/DialogS.h>
#include <Xm/FileSB.h>
#include <Xm/MessageB.h>
#include <Xm/SelectioB.h>
#include <Xm/CutPaste.h>

#include "BNRProlog.h"
#include "ProFiles.h"
#include "ProGraf.h"
#include "ProMenus.h"
#include "ProText.h"
#include "ProWindows.h"
#include "ProEvents.h"
#include "Prolog.h"

static long lastMenuItem,lastMenuMenu;

/*-------------------------------------------------------------
**	MenuCB
**		Process callback from PushButtons in PulldownMenus.
*/
void MenuCB (w, item, call_data) 
Widget		w;			/*  widget id		*/
MenuItemPtr		item;		/*  data from application   */
caddr_t		call_data;	/*  data from widget class  */
{
	PMenuSelectEvent *pe = (PMenuSelectEvent *) PrologEvent;
#ifdef lint
	if (call_data) ;
	if (w) ;
#endif
#ifdef xDEBUG
	if (DebugTrace)	printf("In MenuCB.\n");
#endif

      if(item->mark != 0)
	 item->mark = (XmToggleButtonGadgetGetState(item->w)) ? 2 : 1;

	pe->type = menuselect;
	pe->window = (PAnyWindow *) focus_window;
	pe->item = item->name;
	pe->menu = item->menu->name;
	lastMenuItem = (long) item;
	lastMenuMenu = (long) item->menu;
	GetModifierInfo();
}


static Cardinal nextItemPosition = 0;
Cardinal menuInsertPosition(w)
Widget	w;
{
#ifdef lint
	if (w) ;
#endif
	return nextItemPosition;
}

MenuPtr AddMenu(menubar, name)
MenuBarPtr menubar;
char	*name;
{
	MenuPtr	menu,p;
	int		n;
	Arg		args[3];
	XmString	nameStr;

	/* create submenu */   
	menu = (MenuPtr) XtMalloc(sizeof(Menu));
#ifdef DEBUG
	menu->self = menu;
#endif
	n = 0;  /* CHANGED 06/95  WAS: n = nextItemPosition = 0; */
	XtSetArg (args[n], XmNinsertPosition, menuInsertPosition);  n++;
	menu->w = XmCreatePulldownMenu(menubar->w,"menu_pane",args,n);
	menu->nItems = 0;
	menu->items = NULL;
	menu->menubar = menubar;
	menu->name = name;
	menu->next = NULL;
	if (p=menubar->menus) {
		while (p->next)
			p = p->next;
		p->next = menu;
	}
	else
		menubar->menus = menu;
	menubar->nMenus++;
		
	n = 0;
	XtSetArg (args[n], XmNsubMenuId, menu->w);  n++;
	XtSetArg(args[n], XmNlabelString, nameStr=XmStringCreateLtoR(name, charset)); n++;
	menu->cascade = XmCreateCascadeButtonGadget(menubar->w, name, args, n);
        /* REMOVED Mar. 95 XtFree(nameStr); */
        XtFree((char *)nameStr);        /* NEW */
        XtManageChild (menu->cascade);

	return menu;
}

/* CreateMenuBar - Create MenuBar in MainWindow */

MenuBarPtr CreateMenuBar (new_window, dummyMenuPtr)
 PTextWindow *new_window;
 MenuPtr * dummyMenuPtr;
	
{
   MenuBarPtr	mbar;
   Arg	args[2];
   int n;

   mbar = (MenuBarPtr) XtMalloc(sizeof(MenuBar));

   /* create menu bar in main window */
   n=0;
   XtSetArg(args[n], XmNheight, 37); n++;
   mbar->w = XmCreateMenuBar(new_window->main_window,"menu_bar",args,n);
   XtManageChild(mbar->w);
   mbar->nMenus = 0;
   mbar->menus = NULL;

   /* Create a dummy button so that mbar will be the proper height*/
   nextItemPosition = 0; /* CHANGED 06/95  WAS: n = 0; */
   *dummyMenuPtr = AddMenu(mbar, XtNewString(" "));

   return mbar;
}

void setItemCommand(c, args, n, s)
char	c;
Arg		args[];
int		*n;
XmString	*s;
{
	static char acc[15],acctext[15];

	if (c) {
		sprintf(acc,"Alt <Key> %c",c); 
		sprintf(acctext,"Alt-%c",c); 
	}
	else
		acc[0] = acctext[0] = '\0';
	XtSetArg(args[*n], XmNaccelerator, acc); (*n)++;
	XtSetArg(args[*n], XmNacceleratorText, *s=XmStringCreateLtoR(acctext,charset)); (*n)++;
}


MenuItemPtr AddItem(menu, item, pos)
MenuPtr	menu;
MenuItemPtr	item;
int		pos;
{
	Widget	button;
	MenuItemPtr	p;
	Arg		args[6];
	int		n;
	Boolean	separator;
	XmString	cmdStr;

	n = 0;
	if (item->command != '\0')
		setItemCommand(item->command, args, &n, &cmdStr);
	XtSetArg(args[n], XmNsensitive, item->enabled); n++;
	nextItemPosition = pos;
	separator = (item->name[0] == '-' && item->name[1] == '\0');
	if (item->sub_menu != NULL) {
		XtSetArg(args[n], XmNsubMenuId, item->sub_menu->w); n++;
		button = item->w = XmCreateCascadeButtonGadget(menu->w, item->name, args, n);
	}
	else if (separator)
		button = item->w = XmCreateSeparatorGadget(menu->w, item->name, args, n);
	else if (item->mark != 0)
	{
		 XtSetArg(args[n], XmNvisibleWhenOff, TRUE); n++;
		 button = item->w = XmCreateToggleButtonGadget(menu->w, item->name, args, n);
		 if(item->mark == 1)
		    XmToggleButtonGadgetSetState(button,FALSE,FALSE);
		 else
		    XmToggleButtonGadgetSetState(button,TRUE,FALSE);
	}
	else
		button = item->w = XmCreatePushButtonGadget (menu->w, item->name, args, n);
	
	if (item->command != '\0')
                /* REMOVED Mar. 95 XtFree(cmdStr); */
                XtFree((char *)cmdStr); /* NEW */

	item->menu = menu;
	item->next = NULL;
	menu->nItems++;
	if (p=menu->items) {
		while (p->next)
			p = p->next;
		p->next = item;
	}
	else
		menu->items = item;

	if ((!separator) && (item->sub_menu == NULL))
/* REMOVED Mar. 95 XtAddCallback (button, XmNactivateCallback, MenuCB, (void *)item); */
/* NEW */ 
	 if(item->mark != 0)
	    XtAddCallback (button, XmNvalueChangedCallback, (XtCallbackProc)MenuCB, (void *)item);
	 else
	    XtAddCallback (button, XmNactivateCallback, (XtCallbackProc)MenuCB, (void *)item);
 
	XtManageChild (button);

	return item;

}

/* prolog primitive $addmenu(+WindowId, +MenuName, +MenuPos, -MenuId) */
BNRP_Boolean addmenu(tcb)
BNRP_TCB *tcb;
{
	BNRP_result	p;
	PAnyWindow	*window;
	char	*menuName;
	MenuPtr	menu;
	Arg	args[2];
	int	n;

#ifdef xDEBUG
	if (DebugTrace)	printf("In addmenu.\n");
#endif

	if (tcb->numargs != 4)
		return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	window = (PAnyWindow *) p.ival;
	if ((int) window == -1) {
		window = NULL; 
	}
        /* NEW Apr. 95 Need to check if we have a menubar */
        if(window)
                if(window->menu_bar == NULL)
                        return FALSE;

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;
	menuName = XtNewString(p.sym.sval);

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) {
		XtFree(menuName);
		return FALSE;
	}
	nextItemPosition = (p.ival > 0) ? p.ival : 0;  /* NEW 06/95 */

	if (window) {
		menu = AddMenu(window->menu_bar, menuName);
		if (p.ival == -2) {
			n = 0;
   			XtSetArg(args[n],XmNmenuHelpWidget,menu->cascade); n++;
   			XtSetValues(menu->menubar->w,args,n);
		}
	}
	else { /* pop up menu */
		menu = (MenuPtr) XtMalloc(sizeof(Menu));
#ifdef DEBUG
		menu->self = menu;
#endif
		n = 0;
		XtSetArg(args[n], XmNmenuPost, "<Btn1Down>"); n++;
		menu->w = XmCreatePopupMenu(toplevel_app_shell, menuName, args, n);
		menu->nItems = 0;
		menu->items = NULL;
		menu->name = menuName;
		menu->menubar = NULL;
		menu->cascade = NULL;
	}	

	return BNRP_unify(tcb, tcb->args[4], BNRP_makeInteger(tcb,(long int) menu));
}

/* prolog primitive $addsubmenu(+Name, +ParentMenuId, -MenuId) */
BNRP_Boolean addsubmenu(tcb)
BNRP_TCB *tcb;
{
	BNRP_result	p;
	MenuPtr	menu,parent;
	Arg	args[2];
	int	n;
	char	*menuName;

#ifdef xDEBUG
	if (DebugTrace)	printf("In addsubmenu.\n");
#endif

	if (tcb->numargs != 3)
		return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_symbol) return FALSE;
	menuName = XtNewString(p.sym.sval);

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) {
		XtFree(menuName);
		return FALSE;
	}
	parent = (MenuPtr) p.ival;

	menu = (MenuPtr) XtMalloc(sizeof(Menu));
#ifdef DEBUG
	menu->self = menu;
#endif
	n = nextItemPosition = 0;
	XtSetArg(args[n], XmNmenuPost, "<Btn1Down>"); n++;
	XtSetArg (args[n], XmNinsertPosition, menuInsertPosition);  n++;
	menu->next = NULL;
	menu->w = XmCreatePulldownMenu(parent->w, menuName, args, n); 
	menu->nItems = 0;
	menu->items = NULL;
	menu->name = menuName;
	menu->menubar = NULL;
	menu->cascade = NULL;

	return BNRP_unify(tcb, tcb->args[3], BNRP_makeInteger(tcb,(long int) menu));
}

Boolean parseItemAttributes(term, item)
BNRP_term	term;
MenuItemPtr	item;
{
	BNRP_result	p;
	BNRP_tag	tag;
	BNRP_term	first;
	MenuItem	newItem;

	newItem = *(MenuItem *) item;
	 
	while ((tag = BNRP_getNextValue(&term, &p)) != BNRP_end) {
		if (tag == BNRP_symbol) {
			if (strcmp(p.sym.sval, "disable") == 0)
				newItem.enabled = FALSE;
			else if (strcmp(p.sym.sval, "enable") == 0)
				newItem.enabled = TRUE;
		}
		else if (tag == BNRP_structure) {
			if (p.term.arity != 1) {
				printf("parseItemAttributes: Wrong arity: %d\n",p.term.arity);
				/*return FALSE;*/
			}
			first = p.term.first;
			if (strcmp(p.term.functor,"command") == 0) {
				if (BNRP_getIndexedValue(first, 1, &p) != BNRP_symbol) return FALSE;
				newItem.command = *p.sym.sval;
			}
			else if (strcmp(p.term.functor,"menu") == 0) {
				 if(newItem.mark > 0) return FALSE;
				if (BNRP_getIndexedValue(first, 1, &p) != BNRP_integer) return FALSE;
				newItem.sub_menu = (MenuPtr) p.ival;
			}
			else if (strcmp(p.term.functor,"icon") == 0) {
				if (BNRP_getIndexedValue(first, 1, &p) != BNRP_integer) return FALSE;
				newItem.icon = p.ival;
			}
			else if (strcmp(p.term.functor,"style") == 0) {
				if (BNRP_getIndexedValue(first, 1, &p) != BNRP_symbol) return FALSE;
				newItem.style = *p.sym.sval;
			}
			else if (strcmp(p.term.functor, "mark") == 0) {
				 if(newItem.mark == 0) return FALSE;
				 if(newItem.sub_menu != NULL) return FALSE;
				 if (BNRP_getIndexedValue(first, 1, &p) != BNRP_symbol) return FALSE;
				 newItem.mark = (strcmp("on",p.sym.sval) == 0) ? 2 : 1;
			}	 
		}
		else return FALSE;
	}
      *(MenuItem *) item = newItem;
	
	if(item->mark == -1)
	   item->mark = 0;
	return TRUE;
}

BNRP_term getItemAttributes(tcb,item)
BNRP_TCB	*tcb;
MenuItemPtr	item;
{
	BNRP_term	res;
	char		s[2];
	BNRP_term markerValueTerm;

	s[1] = '\0';
	res = BNRP_startList(tcb);
	BNRP_addTerm(tcb, res, BNRP_makeSymbol(tcb, (item->enabled) ? "enable" : "disable"));
	if (item->command != 0) {
		s[0] = item->command;
		BNRP_addTerm(tcb, res, BNRP_makeStructure(tcb, "command", 1, BNRP_makeSymbol(tcb, s)));
	}
	if (item->mark != 0)
	{
	   if (item->mark == 1)
	       markerValueTerm = BNRP_makeSymbol(tcb, "off");
	   else
	       markerValueTerm = BNRP_makeSymbol(tcb, "on");
		  
	   BNRP_addTerm(tcb,res, BNRP_makeStructure(tcb, "mark", 1, markerValueTerm));
	 }
	if ((long int)item->sub_menu != 0)
		BNRP_addTerm(tcb, res, BNRP_makeStructure(tcb, "menu", 1, BNRP_makeInteger(tcb, (long int) item->sub_menu)));
	if ((long int)item->icon != 0)
		BNRP_addTerm(tcb, res, BNRP_makeStructure(tcb, "icon", 1, BNRP_makeInteger(tcb, (long int) item->icon)));
	BNRP_addTerm(tcb, res, BNRP_makeStructure(tcb, "style", 1, BNRP_makeSymbol(tcb, "plain")));
	return res;
}

/* prolog primitive $additem(+Menu, +Item, +Attributes, +ItemPos, -ItemId) */
BNRP_Boolean additem(tcb)
BNRP_TCB *tcb;
{
	BNRP_result	p;
	char	*itemName;
	MenuItemPtr	item;
	MenuPtr	menu;
	int		itemPos;

#ifdef xDEBUG
	if (DebugTrace)	printf("In additem.\n");
#endif

	if (tcb->numargs != 5) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	menu = (MenuPtr) p.ival;
#ifdef DEBUG
	if (menu->self != menu) {
		printf("ERROR: Bad menu pointer\n");
		abort();
	}
#endif

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_symbol) return FALSE;
	itemName = XtNewString(p.sym.sval);

	if (BNRP_getValue(tcb->args[4], &p) != BNRP_integer) {
		XtFree(itemName);
		return FALSE;
	}
	itemPos = p.ival-1;

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_list) {
		XtFree(itemName);
		return FALSE;
	}
	item = (MenuItemPtr) XtMalloc(sizeof(MenuItem));
#ifdef DEBUG
	item->self = item;
#endif
	item->name = itemName;
	 item->mark = -1;
	 item->style = item->command = '\0';
	item->sub_menu = NULL;
	item->icon = 0;
	item->enabled = TRUE;
	if (!parseItemAttributes(p.term.first, item)) {
		XtFree((char *) item);
		XtFree(itemName);
		return FALSE;
	}
	AddItem(menu, item, itemPos);
	return BNRP_unify(tcb, tcb->args[5], BNRP_makeInteger(tcb,(long int) item));
}

/* prolog primitive $menuitem(+Item, ?ItemName, ?Attributes) */
BNRP_Boolean menuitem(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result		p;
	MenuItemPtr		item;
	Arg				args[3];
	int				n;
	BNRP_tag		tag;
	Boolean			setLabel = FALSE;
	XmString		labelStr;
	Boolean			setCmd = FALSE;
	XmString		cmdStr;

#ifdef DEBUG
	if (DebugTrace) printf("In menuitem.\n");
#endif

	if (tcb->numargs != 3)	return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	item = (MenuItemPtr) p.ival;
#ifdef DEBUG
	if (item->self != item) {
		printf("ERROR: Bad item pointer\n");
		abort();
	}
#endif

	n = 0;
	tag = BNRP_getValue(tcb->args[2], &p);
	if (tag == BNRP_var) {
		if (!BNRP_unify(tcb, tcb->args[2], BNRP_makeSymbol(tcb, item->name)))
			return FALSE;
	}
	else if (tag == BNRP_symbol) {
		XtSetArg(args[n], XmNlabelString, labelStr=XmStringCreateLtoR(p.sym.sval, charset)); n++;
		setLabel = TRUE;
		item->name = XtRealloc(item->name,strlen(p.sym.sval)+1);
		strcpy(item->name, p.sym.sval);
	}
	else return FALSE;

	tag = BNRP_getValue(tcb->args[3], &p);
	if (tag == BNRP_var) {
		if (!BNRP_unify(tcb, tcb->args[3], getItemAttributes(tcb,item)))
			return FALSE;
	}
	else if (tag == BNRP_list) {
		char c = item->command;
		int mark = item->mark;

		if (!parseItemAttributes(p.term.first, item))
			return FALSE;
		XtSetArg(args[n], XmNsensitive, item->enabled); n++;

		if(item->mark != mark)
		{
		   if (item->mark == 1)
		      XmToggleButtonGadgetSetState(item->w,FALSE,FALSE);
		   else
		      XmToggleButtonGadgetSetState(item->w,TRUE,FALSE);
		}
		if (item->command != c) {
			setCmd = TRUE;
			setItemCommand(item->command,args,&n,&cmdStr);
		}
	}
	else return FALSE;

	if (n) XtSetValues(item->w, args, n);
        /* REMOVED Mar. 95 if (setCmd) XtFree(cmdStr);
        if (setLabel) XtFree(labelStr);  */

        if (setCmd) XtFree((char *)cmdStr);     /* NEW */
        if (setLabel) XtFree((char *)labelStr); /* NEW */

	return TRUE;
}

/* deleteitem(+MenuId,+ItemId) */
BNRP_Boolean deleteitem(tcb)
BNRP_TCB	*tcb;
{
	MenuItemPtr	item,itemp;
	MenuPtr		menu;
	BNRP_result	p;

	if (tcb->numargs != 2) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	menu = (MenuPtr) p.ival;
#ifdef DEBUG
	if (menu->self != menu) {
		printf("ERROR: Bad menu pointer.\n");
		abort();
	}
#endif

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	item = (MenuItemPtr) p.ival;
#ifdef DEBUG
	if (item->self != item) {
		printf("ERROR: Bad item pointer.\n");
		abort();
	}
#endif

	if ((itemp=menu->items) == item)
		menu->items = item->next;
	else {
		while (itemp->next != item)
			itemp = itemp->next;
		itemp->next = item->next;
	}
	menu->nItems--;

	XtDestroyWidget(item->w);	
	XtFree(item->name);
	XtFree((char *)item);
	
	return TRUE;
}

BNRP_Boolean deletemenu(tcb)
BNRP_TCB	*tcb;
{
	MenuPtr	menu,menup;
	MenuItemPtr	item;
	BNRP_result	p;

	if (tcb->numargs != 1) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	menu = (MenuPtr) p.ival;
#ifdef DEBUG
	if (menu->self != menu) {
		printf("ERROR: Bad menu pointer.\n");
		abort();
	}
#endif

	if (menu->menubar) {
		if ((menup=menu->menubar->menus) == menu) {
			menu->menubar->menus = menu->next;
			menu->menubar->nMenus--;
		}
		else {
			while (menup && menup->next != menu)
				menup = menup->next;
			if (menup) {
				menup->next = menu->next;
				menu->menubar->nMenus--;
			}
		}
	}

	while (item=menu->items) {
		menu->items = item->next;
		XtDestroyWidget(item->w);	
                XtFree(item->name); /* NEW 18/04/95 */
		XtFree((char *)item);
	}
	XtDestroyWidget(menu->w);	
	if (menu->cascade) XtDestroyWidget(menu->cascade);	
        XtFree(menu->name); /* NEW 18/04/95 */
	XtFree((char *)menu);
	return TRUE;
}

/* lastmenudata(?MenuId,?ItemId) */
BNRP_Boolean lastmenudata(tcb)
BNRP_TCB	*tcb;
{
	if (tcb->numargs != 2) return FALSE;

	return BNRP_unify(tcb, tcb->args[1], BNRP_makeInteger(tcb, lastMenuMenu))
		&& BNRP_unify(tcb, tcb->args[2], BNRP_makeInteger(tcb, lastMenuItem));
}

/* popupmenu(+MenuId,+ItemId,+Top,+Left) */
BNRP_Boolean popupmenu(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	MenuPtr	menu;
	MenuItemPtr	item;
	Position	top,left;
	Arg		args[3];
	int		n;

	if (tcb->numargs != 4) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	menu = (MenuPtr) p.ival;
#ifdef DEBUG
	if (menu->self != menu) {
		printf("ERROR: Bad menu pointer.\n");
		abort();
	}
#endif

	if (BNRP_getValue(tcb->args[2], &p) != BNRP_integer) return FALSE;
	item = (MenuItemPtr) p.ival;
#ifdef DEBUG
	if (item && (item->self != item)) {
		printf("ERROR: Bad item pointer.\n");
		abort();
	}
#endif
#ifdef lint
	if (item) ;
#endif

	if (BNRP_getValue(tcb->args[3], &p) != BNRP_integer) return FALSE;
	top = (short) p.ival;

	if (BNRP_getValue(tcb->args[4], &p) != BNRP_integer) return FALSE;
	left = (short) p.ival;

#ifdef xDEBUG
	if (DebugTrace)
		printf("popupmenu(%d,%d).\n",top,left);
#endif
	n = 0;
	XtSetArg(args[n], XmNx, left); n++;
	XtSetArg(args[n], XmNy, top); n++;
	XtSetValues(menu->w, args, n);

	XtManageChild(menu->w);
	return TRUE;
}

BNRP_Boolean	popdownmenu(tcb)
BNRP_TCB	*tcb;
{
	BNRP_result	p;
	MenuPtr	menu;

	if (tcb->numargs != 1) return FALSE;

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	menu = (MenuPtr) p.ival;
#ifdef DEBUG
	if (menu->self != menu) {
		printf("ERROR: Bad menu pointer.\n");
		abort();
	}
#endif
#ifdef xDEBUG
	if (DebugTrace)
		printf("popdownmenu.\n");
#endif

	XtUnmanageChild(menu->w);
	return TRUE;
}
/* Prolog primitive - $mbarheight(WindowID,Height)
   - queries the height of the menu bar in the given window. */

BNRP_Boolean    mbarheight(tcb)
BNRP_TCB        *tcb;
{
        BNRP_result     p;
        Dimension       height;
        PAnyWindow     *tw;
        Arg             args[2];
        int             n;

        if (tcb->numargs != 2)  return FALSE;

        if ((BNRP_getValue(tcb->args[1],&p)) != BNRP_integer)
            return FALSE;
        tw = (PAnyWindow *) p.ival;

        if (tw->menu_bar != NULL)
           { n = 0;
             XtSetArg(args[n], XmNheight, &height); n++;
             XtGetValues(tw->menu_bar->w, args, n);
           }
        else
			height = 0;

        return BNRP_unify(tcb,tcb->args[2],
                          BNRP_makeInteger(tcb,(long int) height));
}

/* prolog primitive $menuattr(+MenuPtr, ?Attributes) */
BNRP_Boolean menuattr(BNRP_TCB *tcb)
{
	BNRP_result		p;
	MenuPtr		    menu;
    Boolean         enable;
    BNRP_term       term;
 
#ifdef DEBUG
	if (DebugTrace) printf("In menuattr.\n");
#endif
 
	if (tcb->numargs != 2)	return FALSE;
 
	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	menu = (MenuPtr) p.ival;
 
#ifdef DEBUG
	if (menu->self != menu) {
		printf("ERROR: Bad menu pointer\n");
		abort();
	}
#endif
 
    switch (BNRP_getValue(tcb->args[2], &p)) {
        case BNRP_var:
            term = BNRP_makeList(tcb, 1,
                                 BNRP_makeSymbol(tcb, 
                                                 XtIsSensitive(menu->w) ? "enable"
                                                                        : "disable"));
            return BNRP_unify(tcb, tcb->args[2], term);
            break;
        case BNRP_list:
            if (BNRP_getValue(p.term.first, &p) == BNRP_symbol) {
                if (strcmp(p.sym.sval, "disable") == 0)
                    enable = FALSE;
                else if (strcmp(p.sym.sval, "enable") == 0)
                    enable = TRUE;
                else
                    return FALSE;
            }
            break;
        default:
            return FALSE;
    }

    if (menu->cascade)
        XtSetSensitive(menu->cascade, enable);
    if (menu->w)
        XtSetSensitive(menu->w, enable);
 
    return TRUE;
}
 
#ifdef menuDEBUG
BNRP_Boolean dumpmenu(tcb)
BNRP_TCB *tcb;
{
	BNRP_result	p;
	MenuPtr		menu;
	extern void _dumpwidget();

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	menu = (MenuPtr) p.ival;

	printf("Menu %s:\n",menu->name);
	printf("\tnext:\t%s\n", (menu->next) ? menu->next->name:"nil");
	printf("\tw:\t%x\n", menu->w);
	printf("\tcascade:\t%x\n", menu->cascade);
	printf("\tmenubar:\t%x\n", menu->menubar);
	printf("\tnItems:\t%d\n", menu->nItems);
	printf("\titems:\t%x\n", menu->items);

	_dumpwidget(menu->w,1);
	return TRUE;
}

BNRP_Boolean dumpwidget(tcb)
BNRP_TCB *tcb;
{
	BNRP_result	p;
	Widget		w;
	extern void _dumpwidget();

	if (BNRP_getValue(tcb->args[1], &p) != BNRP_integer) return FALSE;
	w = (Widget) p.ival;
	_dumpwidget(w,0);
	return TRUE;
}

void _tabs(level)
int	level;
{
	for (;level;level--)
		printf("\t");
}

void _dumpwindow(w,level)
Window	w;
int		level;
{
	Window	root,parent,*children;
	unsigned int	nchildren,i;
	
	XQueryTree(display, w, &root, &parent, &children, &nchildren);
	_tabs(level);
	printf("Window %x\n",w);
	_tabs(level);
	printf("  parent: %x\n",parent);
	_tabs(level);
	printf("  root:   %x\n",root);
	level++;
	for (i=0;i<nchildren;i++)
		_dumpwindow(children[i],level);
	XFree(children);
}
void _dumpwidget(w,level)
Widget	w;
int		level;
{
	Window	root,parent,children[100];
	unsigned int	nchildren;
	CorePart	*core = (CorePart *) w;
	Boolean		isWidget;
	
	_tabs(level);
	if (XtIsWidget(w)) {
		printf("Widget %x\n",w);
		isWidget = TRUE;
	}
	else if (XtIsRectObj(w)) {
		printf("Gadget %x\n",w);
		isWidget = FALSE;
	}
	else if (XtIsObject(w)) {
		printf("Object %x\n",w);
		return;
	}
	else {
		printf("UNKNOWN %x\n",w);
		return;
	}

	_tabs(level);
	printf("class:\t%x\n", core->widget_class);
	_tabs(level);
	printf("parent:\t%x\n", core->parent);
	_tabs(level);
	printf("being_destroyed:\t%s\n", core->being_destroyed?"TRUE":"FALSE");
	_tabs(level);
	printf("x,y:\t%d,%d\n", core->x,core->y);
	_tabs(level);
	printf("w,h:\t%d,%d\n", core->width,core->height);
	_tabs(level);
	printf("managed:\t%s\n", core->managed?"TRUE":"FALSE");
	_tabs(level);
	printf("sensitive:\t%s\n", core->sensitive?"TRUE":"FALSE");
	_tabs(level);
	printf("ancestor_sensitive:\t%s\n", core->ancestor_sensitive?"TRUE":"FALSE");
	if (!isWidget) return;
	_tabs(level);
	printf("visible:\t%s\n", core->visible?"TRUE":"FALSE");
	_tabs(level);
	printf("mapped_when_managed:\t%s\n", core->mapped_when_managed?"TRUE":"FALSE");
	_tabs(level);
	printf("num_popups:\t%d\n", core->num_popups);
	_tabs(level);
	printf("name:\t%s\n", core->name);
	if (core->visible)
		_dumpwindow(XtWindow(w),level);
	if (XtIsComposite(w)) {
		int i,n = 0;
		Arg	args[3];
		WidgetList	children;
		Cardinal	nchildren;
   		XtSetArg(args[n], XmNchildren, &children); n++;
   		XtSetArg(args[n], XmNnumChildren, &nchildren); n++;
		XtGetValues(w, args, n);
		_tabs(level);
		printf("\t%d Children:\n",nchildren);
		level++;
		for (i=0;i<nchildren;i++)
			_dumpwidget(children[i],level);
	}
}
#endif
void BindPMenuPrimitives()
{
	BNRPBindPrimitive("$additem",additem);
	BNRPBindPrimitive("$deleteitem",deleteitem);
	BNRPBindPrimitive("$addmenu",addmenu);
	BNRPBindPrimitive("$addsubmenu",addsubmenu);
	BNRPBindPrimitive("$deletemenu",deletemenu);
	BNRPBindPrimitive("$menuitem",menuitem);
	BNRPBindPrimitive("$lastmenudata",lastmenudata);
	BNRPBindPrimitive("$popupmenu",popupmenu);
	BNRPBindPrimitive("$popdownmenu",popdownmenu);
	BNRPBindPrimitive("$mbarheight",mbarheight);
    BNRPBindPrimitive("$menuattr",menuattr);
#ifdef menuDEBUG
	BNRPBindPrimitive("$dumpmenu",dumpmenu);
	BNRPBindPrimitive("$dumpwidget",dumpwidget);
#endif
}
