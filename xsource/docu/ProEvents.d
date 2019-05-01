#if 0
----------------------------------------------------------------------
> Global Function: GetModifierInfo ;
  $ voidGetModifierInfo ()
> Purpose:
  | This function fills in the time, modifier keys, global mouse position, and button information for the current Prolog event.  It assumes that the type and window fields of PrologEvent have already been filled in.  It also fills in the mouselx and mousely values for userupidle events.
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
> Global Function: memberEditExitSet ;
  $ BooleanmemberEditExitSet (int, char*, KeySym)
> Purpose:
  | Determines if the given key is part of the editExitSet array.  If num is equal to 1 then it uses 'buffer' which is the ascii value of the character to check,to determine if it's part of editExitSet.  If 'num' is greater than 1, then it uses KeySym to determine if it's a member of the editExit Set
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE if it's a member of the editExitSet
> Parameters:
  = int num - size of 'buffer'
  = char* buffer - keysym to check
  = KeySym keysym - keysym to check
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
> Global Function: KeyPressCB ;
  $ voidKeyPressCB (Widget, PAnyWindow*, XKeyEvent*)
> Purpose:
  | This is the callback for keypress events.  It sets up PrologEvent to be a userkey event.  If the key is part of the editExitSet, then testEditState is set to FALSE.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = Widget w - widget where the keypress occured
  = PAnyWindow* window - window where the event occured
  = XKeyEvent* event - X key event data
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
> Global Function: TrackButtonState ;
  $ voidTrackButtonState (XEvent*)
> Purpose:
  | This function sets the Button1Down flag depending on the event type of 'event'.  It typically gets used after an X event gets pulled off the queue of pending events.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = XEvent* event - X event to check.
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
> Global Function: userevent ;
  $ BNRP_Booleanuserevent (BNRP_TCB*)
> Purpose:
  | This primitive processes an X event that is on the queue of pending events and returns the appropriate Prolog event.  It terminates any graphics updates in progress, and checks to see if the scrap has changed before processing the event.  If it has 4 arguements, then the call blocks until an event occurs.  Otherwise the fifth arguement is the symbol "noblock" and if there is no event,then an userupidle event is generated.  The first three arguements get unified as per FormatPrologEvent.
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
> Global Function: FormatPrologEvent ;
  $ BooleanFormatPrologEvent (BNRP_TCB*, int, PEvent*)
> Purpose:
  | This function formats the Prolog event 'pevent' for unification with the arguements in the tcb starting at arguement 'argnum'.  It uses only 3 arguements of the tcb.  The first is the event name, the second and third are the two relevant pieces of data associated with the event (see Userevent chapter in reference manual for more on this)
> Calling Context:
  | 
> Return Value:
  | Boolean - TRUE on success
> Parameters:
  = BNRP_TCB* tcb - pointer to a task control block
  = int argnum - first arguement of tcb to unify with
  = PEvent* pevent - Prolog event to format for unification with 'tcb'
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
> Global Function: lasteventdata ;
  $ BNRP_Booleanlasteventdata (BNRP_TCB*)
> Purpose:
  | This primitive returns the last event that was processed.  it has 5 arguements which are unified with the last event data.  The first arguement is unified with the type of the event.  The second is unified with the name of the window that the event took place in (NULL if none).  The third is unified with a list that contains the mouse x position and mouse y position relative to the screen.  The fourth is unified with the time that the event occured (integer) and the fifth is unified with the modifier list [Control,Option,Capslock,Shift,Command,Mouseup].
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
> Global Function: TracePrologEvent ;
  $ voidTracePrologEvent ()
> Purpose:
  | This function traces the current Prolog event being performed.  It dumps the entire contents of the PrologEvent structure to stdout.  This is only available if DEBUG is defined.
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
> Global Function: TraceEvent ;
  $ voidTraceEvent (XEvent*)
> Purpose:
  | This traces the current X event being performed.  It prints out to stdout the type of event, the window and if the event is simulated or not.  This is only available if DEBUG is defined
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = XEvent* event - X event to trace.
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
> Global Function: eventLoop ;
  $ voideventLoop ()
> Purpose:
  | This is the event loop used inside of editbabs().  All it does is process events and if the PrologEvent type is userdeactivate, menuselect, or usermousedown, then set the textEditState to FALSE which tells editbabs that editing has finished inside of the editbox.
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
> Global Function: BindPEventPrimitives ;
  $ voidBindPEventPrimitives ()
> Purpose:
  | This function binds the event primitives in and initializes the LastPrologEv and PrologEv event types to be "unknown".  it also sets up the usereventsym array.  It also rebinds the cursor keys, function keys, and enter key to be the lower case equivalents of the names (enter key bound to "enter" instead of "KP_Enter".
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
> Global Function: CheckForBoundKey ;
  $ char*CheckForBoundKey (char*)
> Purpose:
  | Given a a string 'pstring', it checks to see if the key_bindings array at 0 holds that string.  If so, it converts it to the version that X/Motif understands.  If it isn't found, then 'pstring' is returned which means that no conversion was necessary.
> Calling Context:
  | 
> Return Value:
  | char* - X/Motif version of the key string 'pstring'
> Parameters:
  = char* pstring - key string to convert to X/Motif equivalent.
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
> Global Function: StringToKeysym ;
  $ KeySymStringToKeysym (char*)
> Purpose:
  | This function converts a string to a KeySym value
> Calling Context:
  | 
> Return Value:
  | KeySym - KeySym structure representing 'str'
> Parameters:
  = char* str - XXXXX_G_PAR
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
> Data Item: PrologEv
  $ PEvent PrologEv
> Purpose:
  | This is the current Prolog event being proecessed
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: PrologEvent
  $ PEvent* PrologEvent
> Purpose:
  | Pointer to PrologEv
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: LastPrologEv
  $ PEvent LastPrologEv
> Purpose:
  | This is the last Prolog event that was returned.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: LastPrologEvent
  $ PEvent* LastPrologEvent
> Purpose:
  | Pointer to LastPrologEv
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: Button1Down
  $ Boolean Button1Down
> Purpose:
  | Thisis set when button 1 of the mouse is down.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: InvalidrectGenerated
  $ Boolean InvalidrectGenerated
> Purpose:
  | This is set when a call to the invalidrect primitive is made.  This indicates that a section of a window has been invalidated
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: numExitChars
  $ int numExitChars
> Purpose:
  | This is the current number of characters held in editExitSet that can end editing.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: editExitSet
  $ editExit[MAXEXITCHARS] editExitSet
> Purpose:
  | This is the set of characters that when pressed indicate that editing should end.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: textEditState
  $ Boolean textEditState
> Purpose:
  | This is TRUE when editing is occuring in an editbox.  FALSE when editing has finished.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: editbox
  $ Widget editbox
> Purpose:
  | This holds the widget that represents an editbox.  (ie. a field in Panels)
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: editSelStart
  $ XmTextPosition editSelStart
> Purpose:
  | Holds the start position of the current edit selection in an editbox
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: editSelEnd
  $ XmTextPosition editSelEnd
> Purpose:
  | Holds the end position ofth current edit selection in an editbox.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: usereventsym
  $ BNRP_term[LASTPROLOGEVENTNUM] usereventsym
> Purpose:
  | This is usedto hold the symbol terms representing the events.  Eaach symbol term is indexed at its event number (ie. "userkey" symbol at PrologEventType userkey).
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: heap_info
  $ mallinfo heap_info
> Purpose:
  | This is only used if DEBUG and 'heap_check' are defined.  Used to get statistics on memory allocation.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: key_bindings
  $ char*[][] key_bindings
> Purpose:
  | Maps key characters to ones that X/Motif understands.  The normal key is in position 0, and the X/Motif equivalent is in position 1.  This is used in StringToKeySym() to convert a string into a KeySym.
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
  | PAnyEvent
  $ struct PAnyEvent
> Purpose:
  | This is a mask for a generic event.  All other events fit into this "mask".
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - an event type
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent 
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
  | PUserKeyEvent
  $ struct PUserKeyEvent
> Purpose:
  | This event is generated whenever a key is pressed
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - userkey
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
  = char[] symbol - key that was pressed
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
  | PUserIdleEvent
  $ struct PUserIdleEvent
> Purpose:
  | This event is generated when the mousebutton is held down or when no other event is around (userupidle)
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - userdownidle or userupidle
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
  = int mouselx - mouse x position relative to the current window
  = int mousely - mouse y position relative to the current window
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
  | PUserActivateEvent
  $ struct PUserActivateEvent
> Purpose:
  | This is generated whenever a window is made active or inactive
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - useractivate or userdeactivate
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
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
  | PMenuSelectEvent
  $ struct PMenuSelectEvent
> Purpose:
  | This event gets generated when an item from a menu gets selected
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - menuselect
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
  = char* menu - name of the menu whose item was selected
  = char* item - name of the menu item selected
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
  | PUserMouseEvent
  $ struct PUserMouseEvent
> Purpose:
  | This is generated whenever the mouse button gets pressed or released
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - usermousedown or usermouseup
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
  = int mouselx - mouse x position relative to the current window
  = int mousely - mouse y position relative to the current window
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
  | PUserUpdateEvent
  $ struct PUserUpdateEvent
> Purpose:
  | Generated when a section of a graphics window becomes exposed hence needing to be redrawn.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - userupdate
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
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
  | PUserCloseEvent
  $ struct PUserCloseEvent
> Purpose:
  | This event gets generated whenever a window is to be closed.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - userclose
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
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
  | PUserResizeEvent
  $ struct PUserResizeEvent
> Purpose:
  | This event gets generated whenever a window gets resized. 
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - userresize
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
  = Dimension width - new width ofthe window
  = Dimension height - new height of the window
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
  | PUserRepositionEvent
  $ struct PUserRepositionEvent
> Purpose:
  | This event gets generated whenever a window gets moved
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - always userreposition
  = PAnyWindow* window - see PScrapChangedEvent
  = Time when - see PScrapChangedEvent
  = Boolean modifiers_valid - see PScrapChangedEvent
  = int mousegx - see PScrapChangedEvent
  = int mousegy - see PScrapChangedEvent
  = Boolean control - see PScrapChangedEvent
  = Boolean option - see PScrapChangedEvent
  = Boolean capslock - see PScrapChangedEvent
  = Boolean shift - see PScrapChangedEvent
  = Boolean command - see PScrapChangedEvent
  = Boolean mouseup - see PScrapChangedEvent
  = Position leftedge - new left edge position
  = Position topedge - new top edge position
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
  | PScrapChangedEvent
  $ struct PScrapChangedEvent
> Purpose:
  | This event is generated whenever the scrap gets changed.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = PrologEventType type - type of event (scrapchanged)
  = PAnyWindow* window - window associated with the event
  = Time when - when the event occured
  = Boolean modifiers_valid - TRUE if the modifiers are valid
  = int mousegx - mouse x position
  = int mousegy - mouse y position
  = Boolean control - control key press
  = Boolean option - option key press
  = Boolean capslock - caps lock is enabled
  = Boolean shift - shift key press
  = Boolean command - command key press
  = Boolean mouseup - mouse button is up.
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
  | _PEvent
  $ union _PEvent
> Purpose:
  | This union is used to hold an indeterminate Prolog event that can be identified by looking at it's 'type' value.  Useful when the generic features of the event are important (ie. 'type', 'window', 'modifiers_valid', 'mousegx', 'mousegy', 'control', 'option', 'capslock', 'shift', 'command', 'mouseup')
> Base Classes:
  = No baseclasses... - XXXXX_U_BAS
> Important Members:
  = No methods... - XXXXX_U_MET
  = PrologEventType type
  = PAnyEvent pany
  = PUserKeyEvent pkey
  = PUserIdleEvent pidle
  = PUserActivateEvent pactivate
  = PMenuSelectEvent pmenu
  = PUserMouseEvent pmouse
  = PUserUpdateEvent pupdate
  = PUserCloseEvent pclose
  = PUserResizeEvent presize
  = PUserRepositionEvent preposition
  = PScrapChangedEvent pscrapchanged - XXXXX_U_IV
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
> Struct:
  | editExit
  $ struct editExit
> Purpose:
  | This structure holds the defintions of keys that indicate the end of editing.
> Base Classes:
  = No baseclasses... - XXXXX_S_BAS
> Important Members:
  = No methods... - XXXXX_S_MET
  = Boolean ascii - Inidcates if the union 'u' holds the ascii value ofthe key or the KeySym value.
  = class  u - Union of a KeySym 'keysym' and a char 'ascii_value.
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
> Enumeration:
  | PrologEventType
  $ enum PrologEventType {unknown, userupidle, userdownidle, userkey, useractivate, userdeactivate, menuselect, usermouseup, usermousedown, userupdate, usergrow, userdrag, userzoom, userclose, userresize, userreposition, scrapchanged}
> Purpose:
  = This lists all the tags for the different Prolog events that can occur.
> Tags:
  = unknown
  = userupidle
  = userdownidle
  = userkey
  = useractivate
  = userdeactivate
  = menuselect
  = usermouseup
  = usermousedown
  = userupdate
  = usergrow
  = userdrag
  = userzoom
  = userclose
  = userresize
  = userreposition
  = scrapchanged - XXXXX_E_TAG
> Other Considerations:
  | XXXXX_E_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PAnyEvent
  $ typedef void PAnyEvent
> Purpose:
  | Type definition for the PAnyEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserKeyEvent
  $ typedef void PUserKeyEvent
> Purpose:
  | Type definition for the PUserKeyEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserIdleEvent
  $ typedef void PUserIdleEvent
> Purpose:
  | Type definition for the PUserIdleEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserActivateEvent
  $ typedef void PUserActivateEvent
> Purpose:
  | Type definition for the PUserActivateEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PMenuSelectEvent
  $ typedef void PMenuSelectEvent
> Purpose:
  | Type definition for the PMenuSelectEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserMouseEvent
  $ typedef void PUserMouseEvent
> Purpose:
  | Type definition for the PUserMouseEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserUpdateEvent
  $ typedef void PUserUpdateEvent
> Purpose:
  | Type definition for the PUserUpdateEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserCloseEvent
  $ typedef void PUserCloseEvent
> Purpose:
  | Type definition for the PUserCloseEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserResizeEvent
  $ typedef void PUserResizeEvent
> Purpose:
  | Type definition for the PUserResizeEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PUserRepositionEvent
  $ typedef void PUserRepositionEvent
> Purpose:
  | Type definition for the PUserRepositionEvent structure
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PScrapChangedEvent
  $ typedef void PScrapChangedEvent
> Purpose:
  | Type definition for the PScrapChangedEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | PEvent
  $ typedef _PEvent PEvent
> Purpose:
  | Type definition for the _PEvent structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Typedef:
  | editExit
  $ typedef void editExit
> Purpose:
  | Type definition for the editExit structure.
> Other Considerations:
  | XXXXX_T_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: _H_ProEvents
  $ #define _H_ProEvents
> Purpose:
  | XXXXX_D_PUR
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LASTPROLOGEVENTNUM
  $ #define LASTPROLOGEVENTNUM
> Purpose:
  | Highest Prolog event number
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: MAXEXITCHARS
  $ #define MAXEXITCHARS
> Purpose:
  | Maximum number of characters that can indicate that editing is done
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
