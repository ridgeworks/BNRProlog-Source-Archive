#if 0
----------------------------------------------------------------------
> Global Function: MenuCB ;
  $ voidMenuCB (Widget, MenuItemPtr, caddr_t)
> Purpose:
  | This is the callback used for menu items.  It sets up the Prolog event to indicate that a "menuselect" event has occured.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w - widget that the event occured in
  = MenuItemPtr item - menu item that the event occured in
  = caddr_t call_data - extra X event call data
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: menuInsertPosition ;
  $ CardinalmenuInsertPosition (Widget)
> Purpose:
  | This function returns the position where the next menu item is to be added.
> Calling Context:
  | 
> Return Value:
  | Cardinal - value of nextItemPosition
> Parameters:
  = Widget w - Unused unless lint is defined
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: AddMenu ;
  $ MenuPtrAddMenu (MenuBarPtr, char*)
> Purpose:
  | This function adds a menu with the name 'name' to the menubar 'menubar' at the position denoted by the function menuInsertPosition().  It instantiates and shows the new menu on the menu bar and returns the new menu.  
> Calling Context:
  | 
> Return Value:
  | MenuPtr - Pointer to the newly created menu
> Parameters:
  = MenuBarPtr menubar - menubar to add the menu to
  = char* name - Name of the new menu (must already be allocated!!).
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: CreateMenuBar ;
  $ MenuBarPtrCreateMenuBar (PTextWindow*, MenuPtr*)
> Purpose:
  | This function creates and instantiates a menubar for the window 'window'.  Since Motif displays empty menubars bizarrely (truncated height), we create a dummy menu with the name " " and return it.  This function must be called before the window appears on the screen.
> Calling Context:
  | 
> Return Value:
  | MenuBarPtr - pointer to the newly created menubar
> Parameters:
  = PTextWindow* new_window - window to add the menubar to.
  = MenuPtr* dummyMenuPtr - Pointer to the dummy menu that was created filled in by function.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: setItemCommand ;
  $ voidsetItemCommand (char, Arg[], int*, XmString*)
> Purpose:
  | This sets the item command string to be 'c'.  It sets 'args' at 'n' and n+1.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = char c - command key to be associated with the menu item.
  = Arg[] args - args array to set the command string arguements
  = int* n - 'where in 'args' to set the item command.  Incremented by function
  = XmString* s - string representing the command key sequence for the item filled in by function
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: AddItem ;
  $ MenuItemPtrAddItem (MenuPtr, MenuItemPtr, int)
> Purpose:
  | This function adds an item 'item' to the menu 'menu' at position 'pos'.  The item can be created in three modes:
  | - CascadeButton (has submenus) this is specified by instantiating 
  | the sub_menu pointer of 'item'.
  | - Separator (just create a separator) - if the name is '-'.
  | - PushButtonGadget - default mode, normal menu item
  | If the item isn't a separator, then the MenuCB is set up for the item and the item is returned
> Calling Context:
  | 
> Return Value:
  | MenuItemPtr - instantiated menu item
> Parameters:
  = MenuPtr menu - menu to add item to.
  = MenuItemPtr item - item to add
  = int pos - position to add the item after.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: addmenu ;
  $ BNRP_Booleanaddmenu (BNRP_TCB*)
> Purpose:
  | This primitive adds a new menu to a menubar or creates a new popup menu (doesn't make the popup menu appear).  It has 4 arguements.  The first is the window ID of the window to add the menu to.  If the window doesn't have a menubar, then FALSE is returned.  The second arguement is the name of the new menu.  The third is the position in the menubar to place the menu.  If the window ID passed in is 0 then a popup menu is created.  The fourth arguement gets unified with the ID of the new menu.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: addsubmenu ;
  $ BNRP_Booleanaddsubmenu (BNRP_TCB*)
> Purpose:
  | This primitive creates a submenu for a menu.  It has three arguements.  The first is the name of the new menu.  The second is the ID of the menu to which the new submenu is to be attached.  The third arguement gets unified with the ID of the new submenu.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: parseItemAttributes ;
  $ BooleanparseItemAttributes (BNRP_term, MenuItemPtr)
> Purpose:
  | This function parses the list 'term' to get out the menu item attributes.  It sets the attributes of 'item' to be the values it finds in the list.  (See menuitem primitive for format of the list).  All of the list if parsed, or all of it until it becomes corrupt is parsed.
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on success, FALSE if 'term' is corrupt.
> Parameters:
  = BNRP_term term - List of attributes
  = MenuItemPtr item - menu item whose attributes are to be set.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: getItemAttributes ;
  $ BNRP_termgetItemAttributes (BNRP_TCB*, MenuItemPtr)
> Purpose:
  | This function creates a list of the the menu item 'item' attributes and returns it. (see menuitem primitive for description of list)
> Calling Context:
  | 
> Return Value:
  | BNRP_term - list of the menu item's attributes
> Parameters:
  = BNRP_TCB* tcb - pointer to a task control block
  = MenuItemPtr item - menu item whose attributes are to be returned
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: additem ;
  $ BNRP_Booleanadditem (BNRP_TCB*)
> Purpose:
  | This primitive adds a new menu item to a menu.  It has 5 arguements.  The first arguement is the menu ID (integer) ofthe menu that the item is to be added to.  The second is the name of the new item, the third is a list of attributes to be associated with the new menu item (see menuitem primitive).  The fourth arguement is the position in the menu to place the new item.  The fifth arguement gets unified with the ID of the new menu item.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: menuitem ;
  $ BNRP_Booleanmenuitem (BNRP_TCB*)
> Purpose:
  | This primitive sets or queries the attributes for a menuitem.  The first arguement is ithe ID of the menu item to be modified.  The second arguement can both be variables which are unified with the name of the menu and a list of it's attributes of the form [attr(attrVal),attr1(attrVal),flag, flag1,...]  If the second arguement is a symbol then the name of the menu item is set to this.  If the third arguement is a list, then the attributes specified in the list are set to the values specified.  valid attributes are: 
  | - disable - disable the menu item
  | - enable - enable the menu item
  | - command(Symbol) - key sequence assocaited with the menu item
  | - menu(Integer) - ID of the sub menu associated with the menu item
  | - mark(Symbol) - Whish letter of the menu item to highlight
  | - icon(Integer) - icon ID to be associated with the menu item
  | - style(Symbol) - text style for the menu item
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: deleteitem ;
  $ BNRP_Booleandeleteitem (BNRP_TCB*)
> Purpose:
  | This primitive deletes an item from a menu.  The first arguement is the ID of the menu where the item resides (Integer) and the second is the ID of the item to be deleted (integer).  All space associated with the menu item is reclaimed.  The item chain for the menu is repaired.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: deletemenu ;
  $ BNRP_Booleandeletemenu (BNRP_TCB*)
> Purpose:
  | This primitive has a single arguement which is the menu ID (integer) of the menu to be deleted.  It deletes all of the associated items from the menu, and removes the menu from the menubar and deletes it.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: lastmenudata ;
  $ BNRP_Booleanlastmenudata (BNRP_TCB*)
> Purpose:
  | This primitive returns the ID of the menu where the last menu item event took place and the item where the last menu item event took place.  The first arguement is unified with the Menu Id and the second with the item ID.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: popupmenu ;
  $ BNRP_Booleanpopupmenu (BNRP_TCB*)
> Purpose:
  | This displays a popup menu at a certain location on the monitor.  The first arguement is the menu ID (integer), the second is the Item Id (integer) and the third is the position for the top of the menu (integer). The fourth arguement is the position for the left side of the popup menu.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: mbarheight ;
  $ BNRP_Booleanmbarheight (BNRP_TCB*)
> Purpose:
  | This primitive gets the menubar height ofthe menu specified in the first arguement (integer) and unifies it with the second arguement. 
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: dumpmenu ;
  $ BNRP_Booleandumpmenu (BNRP_TCB*)
> Purpose:
  | This primitive has a single arguement which is the menu ID (integer) of the menu to dump.  The contents of the menu is dumped to stdout.  Only available if 'menuDEBUG' is enabled.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: dumpwidget ;
  $ BNRP_Booleandumpwidget (BNRP_TCB*)
> Purpose:
  | This primitive takes a single arguement which is a widget ID (integer).  This widget's contents is then dumped to stdout.  Only available if 'menuDEBUG' is enabled.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = BNRP_TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: _tabs ;
  $ void_tabs (int)
> Purpose:
  | Prints out 'level' tabs to stdout.  Only available if 'menuDEBUG' is enabled.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = int level - Number of tabs to print out.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: _dumpwindow ;
  $ void_dumpwindow (Window, int)
> Purpose:
  | This function prints out to stdout the heirarchy of windows associated with 'w' including all child windows.  Only available if 'menuDEBUG' is enabled.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Window w - window to dump
  = int level - How may tabs to use to indent output
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: _dumpwidget ;
  $ void_dumpwidget (Widget, int)
> Purpose:
  | This fucntion prints out to stdout the contents of the widget 'w'. 'level' specifies how many tabs to indent the out by.  Only available if 'menuDEBUG' is enabled.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w - Widget to dump
  = int level - How may tabs to use to indent output
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BindPMenuPrimitives ;
  $ voidBindPMenuPrimitives ()
> Purpose:
  | Binds the primitives associated with menus into the Prolog system.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: lastMenuItem
  $ long lastMenuItem
> Purpose:
  | This is the menu item where the last X event on a menu item occured.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: lastMenuMenu
  $ long lastMenuMenu
> Purpose:
  | This is the menu where the last X event on a menu item occured.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: nextItemPosition
  $ Cardinal nextItemPosition
> Purpose:
  | This is the position where the next menu item will be added to the menu.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | _item
  $ struct _item
> Purpose:
  | Holds the information relevant to an item in a menu.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = _item* self - self reference
  = _item* next - next item in the item chain for the menu
  = Widget w - Motif Widget (one of CascadeButton, Separator gadget, PushButton Gadget)
  = char* name - name of the item
  = _menu* menu - back pointer to the associated menu
  = Boolean enabled - TRUE if the item is enabled FALSE otherwise
  = char command - accelerator string for the item
  = int icon - icon associated with the item
  = _menu* sub_menu - pointer to a sub_menu (NULL if none)
  = int mark - indicates whether or not this is a toggleButton or not
  = char style - text style for the name of item
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | _menu
  $ struct _menu
> Purpose:
  | Holds the information relevant to a menu in a menubar
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = _menu* self - self reference
  = _menu* next - Pointer to the next menu in the chain
  = Widget w - Motif PulldownMenu widget
  = Widget cascade - Motif CascadeButton gadget
  = char* name - name of the menu
  = _menubar* menubar - back pointer to the menubar associated with this menu
  = int nItems - number of items in the menu
  = MenuItemPtr items - Pointer to the first menu item in the chain
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | _menubar
  $ struct _menubar
> Purpose:
  | This structure is used to hold the information relevant to handling menubars.  This structure also holds the chain of associated menus.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = Widget w - Motif MenuBar widget
  = int nMenus - Number of menus associated with the menubar
  = MenuPtr menus - Pointer to the first menu structure in the chain
  = No enumerations defined... - XXXXX_S_ENU
  = No typedefs defined... - XXXXX_S_TYP
> Concurrency:
  | Multithread safe. XXXXX_S_CON
  | _Not_ multithread safe. XXXXX_S_CON
> Other Considerations:
  | XXXXX_S_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | MenuItem
  $ typedef _item MenuItem
> Purpose:
  | Type definition for an _item structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | MenuItemPtr
  $ typedef _item* MenuItemPtr
> Purpose:
  | Type definition for a pointer to an _item structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | Menu
  $ typedef _menu Menu
> Purpose:
  | Type definition for a _menu structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | MenuPtr
  $ typedef _menu* MenuPtr
> Purpose:
  | Type definition for a pointer to _menu structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | MenuBar
  $ typedef _menubar MenuBar
> Purpose:
  | Type definition for a _menubar structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | MenuBarPtr
  $ typedef _menubar* MenuBarPtr
> Purpose:
  | Type definition for a pointer to a _menubar structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_ProMenus
  $ #define _H_ProMenus
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: destroyMenu
  $ #define destroyMenu (menu)
> Purpose:
  | This macro removes a menu structure from the associated menubar and deallocates it.  The chain of menus for the menubar is fixed up.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: menuattr ;
  $ BNRP_Boolean menuattr (BNRP_TCB*)
> Purpose
  | [Purpose]
> Return Value
  | BNRP_Boolean [- Meaning of return value]
> Parameters
  | BNRP_TCB* tcb [- Purpose of parameter]
> Exceptions
  | [Throws no exceptions, passes all exceptions through.]
  | [Throws EXCEPTION if CONDITION]
> Notes
  | [Other information e.g. special conditions, what it does/does not do]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::self ;
  $ _item* self
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::next ;
  $ _item* next
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::w ;
  $ Widget w
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::name ;
  $ char* name
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::menu ;
  $ _menu* menu
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::enabled ;
  $ Boolean enabled
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::command ;
  $ char command
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::icon ;
  $ int icon
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::sub_menu ;
  $ _menu* sub_menu
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::mark ;
  $ int mark
> Purpose
  | 0 if item is not a toggleButton.  1 if toggleButton is disabled, 2 if enabled.
> Initial/Default Value
  | 0
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _item::style ;
  $ char style
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::self ;
  $ _menu* self
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::next ;
  $ _menu* next
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::w ;
  $ Widget w
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::cascade ;
  $ Widget cascade
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::name ;
  $ char* name
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::menubar ;
  $ _menubar* menubar
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::nItems ;
  $ int nItems
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menu::items ;
  $ MenuItemPtr items
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menubar::w ;
  $ Widget w
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menubar::nMenus ;
  $ int nMenus
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> DataMember Item: _menubar::menus ;
  $ MenuPtr menus
> Purpose
  | [Purpose]
> Initial/Default Value
  | [Initial value]
> Notes
  | [Other information e.g. special values]
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: popdownmenu ;
  $ BNRP_Boolean popdownmenu (BNRP_TCB*)
> Purpose
  | Hides a popped up menu.
> Return Value
  | BNRP_Boolean
> Parameters
  | BNRP_TCB* tcb
> Exceptions
  | [Throws no exceptions, passes all exceptions through.]
  | [Throws EXCEPTION if CONDITION]
> Notes
  | [Other information e.g. special conditions, what it does/does not do]
----------------------------------------------------------------------
#endif
