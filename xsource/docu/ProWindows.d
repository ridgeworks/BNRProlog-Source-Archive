#if 0
----------------------------------------------------------------------
> Global Function: CloseAnyWindow ;
  $ voidCloseAnyWindow (PAnyWindow*)
> Purpose:
  | This function closes any window, whether it be a graphics or a text window.  It
  | deallocates space that is specific to the type of window, but keeps the space
  | for the generic window structure around for re-use later.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = PAnyWindow* window - Window to be closed
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
> Global Function: CreateText ;
  $ WidgetCreateText (PTextWindow*<T>, Boolean, Boolean)
> Purpose:
  | This function creates the text widget for the editor and sets up the text area.  This includes setting up the initial font lists.
> Calling Context:
  | 
> Return Value:
  | Widget - The Motif scrolled text widget
> Parameters:
  = PTextWindow* w - Window the text widget is to be attached to
  = Boolean VScroll - Indicates whether a vertical scroll bar is to be 				installed.
  = Boolean HScroll - Inidicates whether a horizontal scroll bar is to be 			installed.
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
> Global Function: AllocWindowTab ;
  $ PWindow*<T>AllocWindowTab ()
> Purpose:
  | Allocates and initializes a block of window table entries.  This sets up a chain of PWindow entries.  PWindow's are generic and either window type (graphics or text) can be placed inside them.
> Calling Context:
  | 
> Return Value:
  | PWindow* - Pointer to the beginning of the chain of PWindow entries.
> Parameters:
  = No parameters...
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
> Global Function: AllocWindow ;
  $ PWindow*<T>AllocWindow ()
> Purpose:
  | Allocates a free window table entry.  If there are free entries, then the first free entry is returned.  If there aren't any free entries, then another block of entries is created and attached to the chain.  The first entry on the new chain is returned.
> Calling Context:
  | 
> Return Value:
  | PWindow* - Pointer to a a free PWindow entry.
> Parameters:
  = No parameters...
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
> Global Function: CreateApplication ;
  $ PTextWindow*<T>CreateApplication (Widget, char*<T>, char*<T>, Boolean, Boolean, Boolean, Boolean, MenuPtr*<T>)
> Purpose:
  | Creates the main text window.  This sets up the window and creates the menubar
  | if needed.  It then calls CreateText to create the actual text widget.  It also
  | sets up the event handlers for the window.
> Calling Context:
  | 
> Return Value:
  | PTextWindow* - Pointer  to the new text window.
> Parameters:
  = Widget parent - Parent widget of the new window.
  = char* newwindowname - name of the new window to be displayed in the window 				frame
  = char* newfilename - File associated with the new text window.  This can be ''.
  = Boolean VScroll - Indicates whether to use a vertical scroll bar
  = Boolean HScroll - Indicates whether to use a horizontal scroll bar
  = Boolean Read_write - Indicates whether or not the window can be written to
  = Boolean Menus - Indicates whether or not to use a menu bar
  = MenuPtr* dummyMenuPtr - pointer to a dummy menu that is created along with the
  = menubar.  This is filled in by the function.
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
> Global Function: CreateApplicationWindow ;
  $ PTextWindow*<T>CreateApplicationWindow (char*<T>, char*<T>, Arg*<T>, int, Boolean, Boolean, Boolean, Boolean, MenuPtr*<T>)
> Purpose:
  | Creates a popup shell for the text window and then creates the window through a call to CreateApplication().
> Calling Context:
  | 
> Return Value:
  | PTextWindow* - Pointer to the new text window.
> Parameters:
  = char* wname - Name of the new window to be displayed in the frame
  = char* fname - Name of the file to be associated with the window.  Can be ''.
  = Arg* windowargs - Motif/X11 arguements to be setup when the window is created
  = int numwindowargs - number of Motif/X11 arguements passed in
  = Boolean VScroll - Indicates whether a vertical scroll bar should be used
  = Boolean HScroll - Indicates whether a horizontal scroll bar should be used.
  = Boolean Read_write - Indicates that the window can be written to by the user.
  = Boolean Menus - Indicates whther or not to set up a menubar
  = MenuPtr* dummyMenuPtr - Pointer to a dummy menu that is setup when the menubar 			is created.  This is filled in by the function.
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
> Global Function: getWindowConfig ;
  $ <T>getWindowConfig (PAnyWindow*)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | No return value...
> Parameters:
  = PAnyWindow* w - XXXXX_G_PAR
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
> Global Function: setWindowGeometry ;
  $ <T>setWindowGeometry (PAnyWindow*)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | No return value...
> Parameters:
  = PAnyWindow* w - XXXXX_G_PAR
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
> Global Function: StructureNotifyCB ;
  $ voidStructureNotifyCB (Widget, PAnyWindow*, XAnyEvent*)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = PAnyWindow* window
  = XAnyEvent* event - XXXXX_G_PAR
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
> Global Function: FocusChangeCB ;
  $ voidFocusChangeCB (Widget, PAnyWindow*, XFocusChangeEvent*)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = PAnyWindow* window
  = XFocusChangeEvent* event - XXXXX_G_PAR
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
> Global Function: FileChangedCB ;
  $ voidFileChangedCB (Widget, PTextWindow*<T>, XmTextVerifyPtr)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = PTextWindow* tw
  = XmTextVerifyPtr call_data - XXXXX_G_PAR
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
> Global Function: SelectionChangeCB ;
  $ voidSelectionChangeCB (Widget, caddr_t, XmAnyCallbackStruct*<T>)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = caddr_t client_data
  = XmAnyCallbackStruct* call_data - XXXXX_G_PAR
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
> Global Function: CloseWindowCB ;
  $ voidCloseWindowCB (Widget, PAnyWindow*, caddr_t)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = PAnyWindow* window
  = caddr_t call_data - XXXXX_G_PAR
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
> Global Function: openwindow ;
  $ BNRP_Booleanopenwindow (BNRP_TCB*)
> Purpose:
  | This primitive opens either a new text or graf window.  It has 10 parameters which are:
  | 	Name - Name of the window
  | 	Type - Type of the new window (text or graf)
  | 	Id - ID of the new window if the primitive succeeds
  | 	LeftEdge - top left corner X position
  | 	TopEdge - top left corner Y position
  | 	Width - Width of the window in pixels
  | 	Height - Height of the window in pixels
  | 	Options - A list of options which indicate whther or not to use scrollbars, window type, menubars, etc.
  | 	Fname - File name associated with the window
  | 	DummyMenuPtr - Filled in by the primitive and points to the dummy menu created if a menubar was asked for.
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
> Global Function: CreateGrafWindow ;
  $ PGrafWindow*CreateGrafWindow (char*<T>, Arg*<T>, int, Boolean, Boolean, Boolean, MenuPtr*<T>)
> Purpose:
  | Sets up a graphics window.  This function sets up scroll bars, menus, and any other window attributes passed in through the windowargs parameter,
> Calling Context:
  | 
> Return Value:
  | PGrafWindow* - This points to the new graf window.
> Parameters:
  = char* name - Name of the new window.
  = Arg* windowargs - Set of arguements to be used during Motif window creation
  = int numwindowargs - Number of window arguments.
  = Boolean VScroll - Need vertical scroll bar?
  = Boolean HScroll - Need horizontal scroll bar?
  = Boolean Menus - Need a menubar?
  = MenuPtr* dummyMenuPtr - If a menubar is created, this points to the dummy menu that was created.
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
> Global Function: ButtonActionCB ;
  $ voidButtonActionCB (Widget, PAnyWindow*, XButtonEvent*, Boolean*)
> Purpose:
  | This callback is used whenever a mouse button action is recorded.  It then either sets up the mousedown or mouseup Prolog events.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = PAnyWindow* window
  = XButtonEvent* ev
  = Boolean* continue_flag - XXXXX_G_PAR
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
> Global Function: ExposeCB ;
  $ voidExposeCB (Widget, PGrafWindow*, XmDrawingAreaCallbackStruct*)
> Purpose:
  | This is a callback that is called when a graf window is exposed.  It creates the Prolog exposeWindow event.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w
  = PGrafWindow* window
  = XmDrawingAreaCallbackStruct* call_data - XXXXX_G_PAR
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
> Global Function: closewindow ;
  $ BNRP_Booleanclosewindow (BNRP_TCB*)
> Purpose:
  | This primitive closes a window given it's window ID.
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
> Global Function: hidewindow ;
  $ BNRP_Booleanhidewindow (BNRP_TCB*)
> Purpose:
  | This primitive hides a window given a window ID.
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
> Global Function: showwindow ;
  $ BNRP_Booleanshowwindow (BNRP_TCB*)
> Purpose:
  | This primitive displays a hidden window.  It's only arguement is a window ID.
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
> Global Function: positionwindow ;
  $ BNRP_Booleanpositionwindow (BNRP_TCB*)
> Purpose:
  | This primitive, given a window id, top left corner X position and Y position, moves the window to a new location if necessary.
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
> Global Function: sizewindow ;
  $ BNRP_Booleansizewindow (BNRP_TCB*)
> Purpose:
  | This primitive given a window ID, a width and a height, resizes the window with the given ID if necessary.
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
> Global Function: renamewindow ;
  $ BNRP_Booleanrenamewindow (BNRP_TCB*)
> Purpose:
  | Given a window ID and a symbol, this primitive renames the window associated with the ID.
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
> Global Function: activewindow ;
  $ BNRP_Booleanactivewindow (BNRP_TCB*)
> Purpose:
  | This primitive makes thewindow associated with the given window ID active.  This means bringing it into focus and raising it.
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
> Global Function: getgc ;
  $ BNRP_Booleangetgc (BNRP_TCB*)
> Purpose:
  | This primitive returns the graf context associated with a graph window.  It has two argements, the first being the window ID and the second being the graphics context id which the primitive fills in.
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
> Global Function: changedtext ;
  $ BNRP_Booleanchangedtext (BNRP_TCB*)
> Purpose:
  | This primitive succeeds if the contents of the text window have been changed since the last save.  It's single argement is the window ID.
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
> Global Function: savetext ;
  $ BNRP_Booleansavetext (BNRP_TCB*)
> Purpose:
  | This primitive saves the contents of the text window given it's ID.
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
> Global Function: reloadtext ;
  $ BNRP_Booleanreloadtext (BNRP_TCB*)
> Purpose:
  | This primitive reloads the contents of the text window from disk. It's single argement is the window ID of the window whose contents is to be reloaded.
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
> Global Function: retargettext ;
  $ BNRP_Booleanretargettext (BNRP_TCB*)
> Purpose:
  | This primitive retargets the contents of the text window from disk.  Essentially it associates with the window id (first arguement) the name of the file (second arguement).
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
> Global Function: localglobal ;
  $ BNRP_Booleanlocalglobal (BNRP_TCB*)
> Purpose:
  | This primitive translates between local and global coordinates.  The local coordinates are in relation to the canvas or text area and the global coordinates are in relation to the whole window.  This has 5 arguements: window name, local X and Y, and global X andY.
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
> Global Function: scrndimensions ;
  $ BNRP_Booleanscrndimensions (BNRP_TCB*)
> Purpose:
  | This primitive returns the dimensions of the screen in pixels.  The first argement is the width and the second is the height of the screen.
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
> Global Function: doubletime ;
  $ BNRP_Booleandoubletime (BNRP_TCB*)
> Purpose:
  | This primitve sets the double click time of the mouse.  The only arguement is the time between clicks in milliseconds.
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
> Global Function: invalidrect ;
  $ BNRP_Booleaninvalidrect (BNRP_TCB*)
> Purpose:
  | This primitive invalidates a rectangular region in a window.  IT takes 5 arguements which are: window name, top left corner X position, top left corner Y position, width, and height in pixels.
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
> Global Function: validrect ;
  $ BNRP_Booleanvalidrect (BNRP_TCB*)
> Purpose:
  | This primitive validates the rectangular region in a window.  It is only valid while an update operation is in progress.  It has 5 arguements: window name, top left corner X position, top left corner Y position, width and height.
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
> Global Function: setcursor ;
  $ BNRP_Booleansetcursor (BNRP_TCB*)
> Purpose:
  | This primitive changes the cursor to a new cursor type (eg. arrow).  It has two arguements, the first being the window id, and the second either a symbol or an integer.  The second arguement indicates what to change the cursor to.
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
> Global Function: Beep ;
  $ BNRP_BooleanBeep (BNRP_TCB*)
> Purpose:
  | This primitive tells the X server to cause a beeping noise to be generated to the associated display.
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
> Global Function: BindPWindowPrimitives ;
  $ voidBindPWindowPrimitives ()
> Purpose:
  | This function binds the windowing primitives into the Prolog system
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
> Data Item: windowtab
  $ PWindow* windowtab
> Purpose:
  | Start of the chain of allocated window entries.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: focus_window
  $ PWindow* focus_window
> Purpose:  | 
  | Window currently in focus.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: defaultHeight
  $ int defaultHeight
> Purpose:
  | Default height of a new window in pixels
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: defaultWidth
  $ int defaultWidth
> Purpose:
  | Default width of a new window in pixels
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Enumeration:
  | WindowDefnType
  $ enum WindowDefnType {documentproc, dboxproc, plaindbox, altdboxproc, namedboxproc, nogrowdocproc, rdocproc, zoomdocproc, zoomnogrow}
> Purpose:
  = Type of window.  These indicate what kind of window decorations should be in place.  These are used when opening a new window.  See the reference manual for details on what each means.
> Tags:
  = documentproc
  = dboxproc
  = plaindbox
  = altdboxproc
  = namedboxproc
  = nogrowdocproc
  = rdocproc
  = zoomdocproc
  = zoomnogrow - XXXXX_E_TAG
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: INCRNUMWINDOWS
  $ #define INCRNUMWINDOWS
> Purpose:
  | When new window entries need to be allocated, this indicates how many should be allocated at a time.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Struct:
  | _pany
  $ struct _pany
> Purpose:
  | This structure contains generic information that is applicable to both text and graph windows.  Graph and Text windows can be cast into a _pany structure to eliminate information that is specific to the type of window.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologWindowType type - type of window. Allows a cast to a text or a graph window
  = _pany* next_window - Next window in the chain of allocated window entries
  = Widget app_shell - The popup shell associated with this window
  = char* windowname - Name of the window
  = Dimension width - Width of the window in pixels
  = Dimension height - Height of the window in pixels.
  = Position leftedge - Posiition of the left edge of the window in relation to it's parent's origin
  = Position topedge - Position of the top edge of the window in relation to it's parent's origin.
  = int offsetX - See leftedge
  = int offsetY - See topedge.
  = MenuBarPtr menu_bar - Pointer to the menubar structure of the window.  if the window does not have a menubar then this is NULL.
  = Boolean invalidrect - Indidctaes if the window has an invalidated rectangular region inside of it.
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
  | PTextWindow
  $ struct PTextWindow
> Purpose:
  | This structure contains all the information necessary to instantiate and manage a Prolog Text Window.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologWindowType type - Type of the window.  This is included so that it 	can be cast as a PAny and we will still beable to figure out what kind of window the PAny window is.
  = _pany* next_window - Pointer to the next window in the chain of allocated window chain
  = Widget app_shell - The popup shell assocaiated with this window
  = char* windowname - Name of the window
  = Dimension width - Width of the window
  = Dimension height - Height of the window
  = Position leftedge - Position of the left edge in relation to the origin of it's parent.
  = Position topedge - Position of the top edge oin relation to the origin of it's parent.
  = int offsetX - See leftedge.
  = int offsetY - See topedge
  = MenuBarPtr menu_bar - Menubar structure associated with this window.  If the window does not have a menubar then this is set to NULL.
  = Boolean invalidrect - Indicates whether or not the window contains an invalidated rectangular region.
  = Widget main_window - The main window widget associated with the window.  The main window manages the parts of the window (ie. text area, menubar, etc...).
  = Widget text - The window's text widget.
  = Boolean file_saved - Indicates whether or not the contents of the window need saving.
  = char* filename - Name of the file associated with the contents of the window.
  = Boolean read_write - Indicates whether or not the contents of the window can be written to.
  = Boolean caseSense - Indicates whether or not the window is case sensitive.
  = Boolean scanForward - Indicates which way the contents of the window are being scanned in a find operation for example.
  = XmTextPosition selStart - Start position of the currently selected text
  = XmTextPosition selEnd - End position of the currently selected text
  = short err - This is set if an IO error occurs.
  = XFontStruct* font - Font structure of the font being used.
  = FontInfo fontInfo - Font information
  = char* contents - Contents of the selected text.
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
  | _pgraf
  $ struct _pgraf
> Purpose:
  | This structure contains all the information required to create and maintain a Prolog Graph window.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologWindowType type - Set to pgraf
  = _pany* next_window - The next window in the chain of allocated window 			entries.
  = Widget app_shell - The application shell associated with the window.  Usually set to the popup shell widget created for the window.
  = char* windowname - Name of the window.
  = Dimension width - Width of the window
  = Dimension height - Height of the window
  = Position leftedge - Position of the left edge of the window relative to 		the origin of it's parent.
  = Position topedge - Position of the top edge of the window relative to the 		origin of it's parent.
  = int offsetX - See leftedge
  = int offsetY - See topedge
  = MenuBarPtr menu_bar - Pointer to the menubar structure for the window.  		This is set to Null if the window does not have a menubar.
  = Boolean invalidrect - Indicates whether or not the window has a 			rectangular invalidated region.
  = Widget main_window - Main window widget for the window.  The main window 		controls all of the window's components.  (ie. text area/graph area, 		menubar, etc...)
  = Widget canvas - Drawing area widget
  = Boolean first_expose - Indicates whether or not the window is exposed.
  = _grafStruct* graf - Pointer to a _grafStruct structure
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
> Union:
  | _PWindow
  $ union _PWindow
> Purpose:
  | This union creates a generic structure in which all three window types (pany, ptext, and pgrsf) may reside.
> Base Classes:
  = No baseclasses... - XXXXX_U_BAS
> Important Members:
  = No methods... - XXXXX_U_MET
  = PrologWindowType type - Type of window that is being held inside
  = PAnyWindow anywindow
  = PTextWindow textwindow
  = PGrafWindow grafwindow - XXXXX_U_IV
  = No enumerations defined... - XXXXX_U_ENU
  = No typedefs defined... - XXXXX_U_TYP
> Concurrency:
  | Multithread safe. XXXXX_U_CON
  | _Not_ multithread safe. XXXXX_U_CON
> Other Considerations:
  | XXXXX_U_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Enumeration:
  | PrologWindowType
  $ enum PrologWindowType {unused, ptext, pgraf}
> Purpose:
  = This enumeration is used in the _pwindow structure to identify which type of window is held in the _pwindow union.  It is also held in the _pany, PTextWindow and _pgrafstructures so that a _pany can be cast to a PTextWindow or a _pgraf if necessary.
> Tags:
  = unused
  = ptext
  = pgraf - XXXXX_E_TAG
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PAnyWindow
  $ typedef _pany PAnyWindow
> Purpose:
  | Generic Prolog window type.  This type can be used when you don't care what type of window you have (ptext or pgraph) and you only need to look at the common properties of windows.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PTextWindow
  $ PTextWindow
> Purpose:
  | Type definition for Prolog text window.  See PTextWindow structure definition.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PGrafWindow
  $ typedef _pgraf PGrafWindow
> Purpose:
  | Prolog graph window type.  See _pgraf documentation.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PWindow
  $ typedef _PWindow PWindow
> Purpose:
  | Generic Prolog window structure.  See the _Pwindow union documentation.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_ProWindows
  $ #define _H_ProWindows
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CANVASHEIGHT
  $ #define CANVASHEIGHT
> Purpose:
  | Default height in pixels of the drawing area of a graph window.  Used in the creation of a graph window.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: CANVASWIDTH
  $ #define CANVASWIDTH
> Purpose:
  | Default width in pixels of the drawing area of a graph window.  Used in the creation of a graph window.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
