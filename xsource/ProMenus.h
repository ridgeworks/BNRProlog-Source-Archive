/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProMenus.h,v 1.3 1996/09/25 16:34:53 harrisj Exp $
*
*  $Log: ProMenus.h,v $
 * Revision 1.3  1996/09/25  16:34:53  harrisj
 * Changed _item structure member 'mark' to an integer.
 * A mark value of 0 indicates a normal menu item. A non-zero
 * value indicates that a toggleButton menu item is used.
 * Specifically a 1 value means the toggleButton is off and a 2
 * means that the toggleButton is on.
 *
 * Revision 1.2  1996/09/10  14:56:32  harrisj
 * Change _item structure member 'mark' from a char to a Boolean.  An item is either
 * marked or it is not marked.
 *
 * Revision 1.1  1995/09/22  11:26:55  harrisja
 * Initial version.
 *
*
*/

#ifndef _H_ProMenus
#define _H_ProMenus

typedef struct _item {
#ifdef DEBUG
	struct _item	*self;
#endif
	struct _item	*next;
	Widget	w;
	char	*name;
	struct _menu	*menu;
	Boolean	enabled;
	char	command;
	int		icon;
	struct _menu	*sub_menu;
	int	mark;
	char	style;
} MenuItem, *MenuItemPtr;

typedef struct _menu {
#ifdef DEBUG
	struct _menu	*self;
#endif
	struct _menu	*next;
	Widget	w;
	Widget	cascade;
	char	*name;
	struct  _menubar	*menubar;
	int	nItems;
	MenuItemPtr	items;
} Menu,*MenuPtr;

typedef struct _menubar {
	Widget	w;
	int	nMenus;
	MenuPtr	menus;
} MenuBar,*MenuBarPtr;

extern MenuBarPtr CreateMenuBar();
extern void BindPMenuPrimitives();

#define destroyMenu(menu) 	XtDestroyWidget(menu->w);\
				if (menu->cascade) XtDestroyWidget(menu->cascade);\
				menu->menubar->menus = menu->menubar->menus->next; \
				menu->menubar->nMenus --; \
        			XtFree(menu->name); \
				XtFree((char *)menu);
#endif
