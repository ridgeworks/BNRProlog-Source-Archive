/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProEvents.c,v 1.10 1997/12/22 17:01:32 harrisj Exp $
*
*  $Log: ProEvents.c,v $
 * Revision 1.10  1997/12/22  17:01:32  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.9  1996/04/18  23:11:09  yanzhou
 * In the previous version, a change was made to check textEditState in
 * EditBoxChangedCB, which was a BAD idea, because keys like XK_KP_Enter
 * might not trigger EditBoxChangedCB at all.
 * Now reverted to check textEditState in KeyPressCB.
 *
 * Revision 1.8  1996/01/08  11:19:42  yanzhou
 * No longer modifies textEditState in KeyPressCB.
 *
 * Revision 1.7  1996/01/05  15:56:37  yanzhou
 * Minor change.  usermouseup no longer terminates the eventLoop().
 *
 * Revision 1.6  1996/01/05  15:27:18  yanzhou
 * eventLoop() modified to handle WM_DELETE_WINDOW ClientMessage correctly.
 *
 * Revision 1.5  1996/01/03  09:45:49  yanzhou
 * "Cut and Paste" now works in text fields (edit boxes).
 *
 * Revision 1.4  1995/10/20  12:10:24  yanzhou
 * Modified:
 *   To terminate the editbabs eventLoop() correctly.
 *
 * Revision 1.3  1995/10/06  17:12:42  harrisja
 * *** empty log message ***
 *
 * Revision 1.2  1995/10/06  16:40:27  harrisja
 * *** empty log message ***
 *
 * Revision 1.1  1995/09/22  11:26:16  harrisja
 * Initial version.
 *
*
*/

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
#include <memory.h>
#include <signal.h>

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
#include <Xm/CascadeB.h>
#include <Xm/PushB.h>
#include <Xm/PushBG.h>
#include <Xm/MainW.h>
#include <Xm/BulletinB.h>
#include <Xm/MwmUtil.h>
#include <Xm/RowColumn.h>
#include <Xm/Text.h>
#include <Xm/DialogS.h>
#include <Xm/FileSB.h>
#include <Xm/MessageB.h>
#include <Xm/Label.h>
#include <Xm/SelectioB.h>
#include <Xm/CutPaste.h>
#include <Xm/DrawingA.h>

#include "BNRProlog.h"
#include "ProFiles.h"
#include "ProGraf.h"
#include "ProMenus.h"
#include "ProText.h"
#include "ProWindows.h"
#include "ProEvents.h"
#include "Prolog.h"

PEvent  PrologEv;	
PEvent  *PrologEvent = &PrologEv;
PEvent  LastPrologEv;                    /* last Prolog event returned */
PEvent  *LastPrologEvent = &LastPrologEv;

Boolean Button1Down = FALSE;

Boolean InvalidrectGenerated = FALSE;

/* Variables used for edit boxes */
int     numExitChars;
editExit editExitSet[MAXEXITCHARS];
Boolean textEditState = FALSE;
Widget  editbox;
XmTextPosition editSelStart,editSelEnd;      /* selection bounds */

BNRP_term usereventsym[LASTPROLOGEVENTNUM+1];

BNRP_Boolean userevent();
#ifdef DEBUG
void TraceEvent();
void TracePrologEvent();
#ifdef heap_check
struct mallinfo heap_info;
#endif
#endif


/* GetModifierInfo - fills in the time, modifier key and button info in
         the current Prolog event record. Assumes the type and window fields
         are already filled into the event record. */

void GetModifierInfo()

{ PAnyEvent *pe = (PAnyEvent *) PrologEvent;
  Window         root,child,ref_w;
  int            root_x,root_y,win_x,win_y;
  unsigned int   keys_buttons;

   /* Set the time in the event */
   pe->when = XtLastTimestampProcessed(display);

   /* Get modifier key info - default first in case funny error later */
   pe->control = 0;
   pe->shift = 0;
   pe->capslock = 0;
   pe->option = 0;
   pe->command = 0;
   pe->mousegx = 0;
   pe->mousegy = 0;
   pe->modifiers_valid = FALSE;

   if ((pe->window != NULL) &&
       (pe->window->type != unused) &&
       (XQueryPointer(display,
					(pe->window->type == pgraf) ? XtWindow(((PGrafWindow *)pe->window)->canvas) : 
												 XtWindow(((PTextWindow *)pe->window)->text),
                     &root,&child, &root_x,&root_y,
                     &win_x,&win_y, &keys_buttons)))

      { /* pointer on same screen as app_shell- return values valid */
	pe->modifiers_valid = TRUE;
        pe->control = ((ControlMask & keys_buttons) == ControlMask); 
        pe->shift = ((ShiftMask & keys_buttons) == ShiftMask); 
        pe->capslock = ((LockMask & keys_buttons) == LockMask); 
        pe->command = ((Mod1Mask & keys_buttons) == Mod1Mask); 
        pe->option = ((Mod2Mask & keys_buttons) == Mod2Mask); 
        pe->mouseup = !Button1Down;
        pe->mousegx = root_x;
        pe->mousegy = root_y;
/*        if (DebugTrace && (keys_buttons != 0)) 
           printf("Keys_buttons: %X.\n",keys_buttons);
*/    } 

    /* Now fill in specific fields for the useridle events - type is
       set to userupidle on entry */
    if (pe->type == userupidle)
       { PUserIdleEvent *ie = (PUserIdleEvent *) pe;
        if (ie->modifiers_valid)
          {ie->type = (Button1Down)?userdownidle:userupidle; 
           ie->mouselx = win_x;
           ie->mousely = win_y;
          }
        else
          { ie->mouselx = 0;
            ie->mousely = 0;
          }
        }
}

/* memberEditExitSet - determines if the given keysym is part of the edit exit set */

Boolean memberEditExitSet(num,buffer,keysym)
        int num;
        char *buffer;
        KeySym keysym;
{
        editExit *pe;
        for (pe=editExitSet; pe<(editExitSet+numExitChars); pe++) {
                if (((num == 1) && pe->ascii &&
                     (buffer[0] == pe->u.ascii_value)) ||
                    ((num > 1) && (!pe->ascii) &&
                     (keysym == pe->u.keysym)))
                        return TRUE;
        }
        return FALSE;
}


/* KeyPressCB - the callback for keypress events */

void KeyPressCB(w,window,event)

   Widget     w;
   PAnyWindow *window;
   XKeyEvent  *event;

{  char       buffer[16]; /* must be big enough to hold rebound keysyms */
   KeySym     keysym;
   int        num;
   PUserKeyEvent *pe = (PUserKeyEvent *)PrologEvent;

#ifdef lint
	if (w) ;
#endif

   num = XLookupString(event,buffer,sizeof(buffer),&keysym,NULL);
   buffer[num] = '\0';

#ifdef DEBUG
    if (DebugTrace)
      {printf("In KeyPressCB. Keycode: %X, KeySym: %X, Num: %d",
                         event->keycode,keysym,num);
       if (buffer[0] < ' ')
          printf(" Value: (%X)\n", buffer[0]);
       else
          if (num == 1)
             printf(" Value: %c (%X)\n", buffer[0],buffer[0]);
          else
             printf(" Value: %s\n",buffer);
      }
#endif

        if (num > 0 ) {
                if (buffer[0] == '\03')
                        kill(getpid(),SIGINT);
                else { /* Retrieve information to return to Prolog */
                        pe->type = userkey;
                        pe->window = window;
                        strcpy(pe->symbol,buffer);
                        pe->when = event->time;
                        pe->modifiers_valid = event->same_screen;
                        pe->mousegx = event->x_root;
                        pe->mousegy = event->y_root;
						pe->control = (event->state & ControlMask) == ControlMask;
                        pe->capslock = (event->state & LockMask) == LockMask;
                        pe->shift = (event->state & ShiftMask) == ShiftMask;
						pe->command = (event->state & Mod1Mask) == Mod1Mask;
						pe->option = (event->state & Mod2Mask) == Mod2Mask;
                        pe->mouseup = (event->state & Button1Mask) == 0;
 
                        /* yanzhou@bnr.ca 19/04/96
                         * 
                         * Terminate the sub eventLoop in editbabs if
                         * a key in the EditExitSet is pressed.  Note:
                         * if this is done in EditBoxChangedCB
                         * instead, keys like XK_KP_Enter may not be
                         * handled properly 
                         */
                        if (textEditState)
                            textEditState = !memberEditExitSet(num, buffer, keysym);
                }
        }
}


/* TrackButtonState - tracks the state of the mouse (button1) button */

void TrackButtonState(event)

	XEvent *event;

{
	if ((event->type == ButtonPress) || (event->type == ButtonRelease)) {
		Button1Down = (event->type == ButtonPress);

#ifdef DEBUG
		if (DebugTrace) 
			printf(Button1Down ? "Button pressed\n":"Button released\n");
#endif
	}

} 


/* Prolog primitive - userevent(Event,Windowname,Data1,Data2)
                      userevent(Event,Windowname,Data1,Data2,noblock)
   - detects a user event. */

BNRP_Boolean userevent(tcb)
BNRP_TCB *tcb;

{  
	BNRP_result p;
	XEvent      event;
	int         i;
	XEvent      ExposeEvent;
	PGrafWindow *gw;

#ifdef DEBUG
#ifdef heap_check
	static noMapPrinted = TRUE;
	heap_info = mallinfo();
	if ((heap_info.arena > 5000000) && noMapPrinted) {
		mallocmap();
		noMapPrinted = FALSE;
	}
#endif
	if (DebugTrace) printf("In userevent. Numargs=%d.\n",tcb->numargs);
#endif

	/* Terminate any graphics updates in progress */
	TerminateGrafUpdate(); 

	/* Check to see if scrap has changed */
	PollScrapContents();

	/* If Invalidrect was called on any window, generate an expose X event 
	 with a zero count and a zero size rectangle to terminate the 
	 compression sequence of expose events. */
	if (InvalidrectGenerated) {
		InvalidrectGenerated = FALSE;
		for (gw = (PGrafWindow *)windowtab; gw != NULL; gw = (PGrafWindow *)gw->next_window) {
			if ((gw->type == pgraf) && (gw->invalidrect)) {
				gw->invalidrect = FALSE;
				ExposeEvent.xexpose.type = Expose;
				ExposeEvent.xexpose.serial = 0;      /* set correctly later */
				ExposeEvent.xexpose.send_event = TRUE;
				ExposeEvent.xexpose.display = display;
				ExposeEvent.xexpose.window = XtWindow(gw->canvas);
				ExposeEvent.xexpose.count = 0;
				ExposeEvent.xexpose.x = ExposeEvent.xexpose.y = 
			 	ExposeEvent.xexpose.width = ExposeEvent.xexpose.height = 0;
#ifdef DEBUG
				if (DebugTrace)
					printf("ExposeEvent generated: %s: x %d, y %d, width %d, height %d.\n",
						gw->windowname,
						ExposeEvent.xexpose.x,ExposeEvent.xexpose.y,
						ExposeEvent.xexpose.width,ExposeEvent.xexpose.height);
#endif
				XSendEvent(display,ExposeEvent.xexpose.window,TRUE,ExposureMask,&ExposeEvent);
			}
		}
	}

	PrologEvent->type = unknown;
   
	for(;;) {    /* loop until valid Prolog event occurs */
		if (tcb->numargs == 4) { /* blocking call */
			XtAppNextEvent(app_context,&event); /* may block */
#ifdef DEBUG
			if (XEventTrace) TraceEvent(&event);
#endif
			/* track state of button */
			TrackButtonState(&event);

			XtDispatchEvent(&event);
		}
		else if ((tcb->numargs == 5) &&
				(BNRP_getValue(tcb->args[5],&p) == BNRP_symbol) &&
				(strcmp(p.sym.sval,"noblock") == 0)) { /* nonblocking call */
			int evMask = XtAppPending(app_context);
			if (evMask & XtIMXEvent) { /* events pending for this application */
       	    	XtAppNextEvent(app_context,&event);
#ifdef DEBUG
				if (XEventTrace) TraceEvent(&event);
#endif
				/* track state of button */
				TrackButtonState(&event);

				XtDispatchEvent(&event);
				/* X event handlers will retrieve event info. */
			}
			else { /* no X event yet, return useridle */
				PUserIdleEvent *pe = (PUserIdleEvent *) PrologEvent;
				if (evMask != 0) /* timeout or alternate input event pending */
					XtAppProcessEvent(app_context, XtIMTimer | XtIMAlternateInput);

				/* default upidle covers funny failure cases */
				pe->type = userupidle; 
				pe->window = (PAnyWindow *)focus_window;
				/* Pick up the event time, modifier keys,etc. */
				GetModifierInfo();
			}
		}
		else { /* syntax error */
#ifdef DEBUG
			if (DebugTrace) {
				for (i=1; i<=tcb->numargs; i++) {
					BNRP_dumpArg(stdout, tcb,tcb->args[i]); printf("\n");
					printf("\nSyntax error.\n");
				}
			}
#endif
            return(FALSE);
		}
            
		/*  Now format event for return to Prolog. */            

#ifdef DEBUG
		if (PrologEventTrace || PrologIdleTrace) TracePrologEvent();
#endif
		switch (PrologEvent->type) {
			case unknown:
				break;

			case userkey: 
			case userupidle: case userdownidle: 
			case usermouseup: case usermousedown: 
			case menuselect: 
			case userupdate: 
			case userclose: 
			case userresize: 
			case userreposition: 
			case scrapchanged: 
				LastPrologEv = PrologEv;
				return FormatPrologEvent(tcb,1,PrologEvent);

			case useractivate: case userdeactivate: {
				PUserActivateEvent *pe = (PUserActivateEvent *) PrologEvent;
				PUserActivateEvent *lpe = (PUserActivateEvent *) LastPrologEvent;
	
				/* filter out duplicate activate or deactivate events */
				if ((lpe->type == pe->type) && (lpe->window == pe->window)) { 
#ifdef DEBUG
					if (PrologEventTrace) printf("Event filtered out.\n");
#endif
					break;
				}
				else
					LastPrologEv = PrologEv;

				return FormatPrologEvent(tcb,1,PrologEvent);
			}

			default: break;
		}
	/* Continue until an event is passed back to Prolog. In fact, only 
		unknown events and duplicate activate/deactivate events reach 
		this point. */
	}
	
	/* unreachable */
	return(FALSE);
}
      

/* FormatPrologEvent - formats the specified Prolog event, unifying it with 
     the arguments in the tcb. */

Boolean FormatPrologEvent(tcb,argnum,pevent)

   BNRP_TCB *tcb;
   int      argnum;
   PEvent *pevent;

{
   switch (pevent->type)
    { case unknown:
          return FALSE;

      case userkey: 
         { PUserKeyEvent *pe = (PUserKeyEvent *) pevent;
           return(BNRP_unify(tcb,tcb->args[argnum],usereventsym[(int) userkey]) &&
                  BNRP_unify(tcb,tcb->args[argnum+1],
			         BNRP_makeSymbol(tcb, pe->window->windowname)) &&
                  BNRP_unify(tcb,tcb->args[argnum+2],
                                 BNRP_makeSymbol(tcb,pe->symbol)) &&
                  BNRP_unify(tcb,tcb->args[argnum+3],
                                 BNRP_makeList(tcb,6,
                                    BNRP_makeInteger(tcb,(long int)pe->control),
                                    BNRP_makeInteger(tcb,(long int)pe->option),
                                    BNRP_makeInteger(tcb,(long int)pe->capslock),
                                    BNRP_makeInteger(tcb,(long int)pe->shift),
                                    BNRP_makeInteger(tcb,(long int)pe->command),
                                    BNRP_makeInteger(tcb,(long int)pe->mouseup))));
         }	

      case userupidle: case userdownidle: 
         { PUserIdleEvent *pe = (PUserIdleEvent *) pevent;
           return(BNRP_unify( tcb,tcb->args[argnum], usereventsym[(int) pe->type]) && 
                  BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)) &&
                  BNRP_unify(tcb,tcb->args[argnum+2],
                             BNRP_makeInteger(tcb,(long int)pe->mouselx)) &&    
                  BNRP_unify(tcb,tcb->args[argnum+3],
                             BNRP_makeInteger(tcb,(long int)pe->mousely)));
         }

      case usermouseup: case usermousedown: 
         { PUserMouseEvent *pe = (PUserMouseEvent *) pevent;
           return(BNRP_unify( tcb,tcb->args[argnum], usereventsym[(int) pe->type]) && 
                  BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)) &&
                  BNRP_unify(tcb,tcb->args[argnum+2],
                             BNRP_makeInteger(tcb,(long int)pe->mouselx)) &&    
                  BNRP_unify(tcb,tcb->args[argnum+3],
                             BNRP_makeInteger(tcb,(long int)pe->mousely)));
         }

      case menuselect: 
         { PMenuSelectEvent *pe = (PMenuSelectEvent *) pevent;
           return(BNRP_unify( tcb,tcb->args[argnum], usereventsym[(int) menuselect]) &&
                  BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)) &&
                  BNRP_unify(tcb,tcb->args[argnum+2], BNRP_makeSymbol(tcb,pe->menu)) &&    
                  BNRP_unify(tcb,tcb->args[argnum+3],BNRP_makeSymbol(tcb,pe->item)));
         }
		
      case useractivate: case userdeactivate: 
         { PUserActivateEvent *pe = (PUserActivateEvent *) pevent;
           return(BNRP_unify(tcb,tcb->args[argnum], usereventsym[(int) pe->type]) &&
                  BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)));
         }

      case userupdate: 
         { PUserUpdateEvent *pe = (PUserUpdateEvent *) pevent;
           return(BNRP_unify( tcb,tcb->args[argnum], usereventsym[(int) userupdate]) &&
                  BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)));
         }

      case userclose: 
         { PUserCloseEvent *pe = (PUserCloseEvent *) pevent;
           return(BNRP_unify( tcb,tcb->args[argnum], usereventsym[(int) userclose]) &&
                  BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)) &&
                  BNRP_unify(tcb,tcb->args[argnum+2],
                             BNRP_makeInteger(tcb,(long int)pe->mousegx)) &&
                  BNRP_unify(tcb,tcb->args[argnum+3],
                             BNRP_makeInteger(tcb,(long int)pe->mousegy)));
          }

      case userresize: 
         { PUserResizeEvent *pe = (PUserResizeEvent *) pevent;
           return( BNRP_unify(tcb,tcb->args[argnum], usereventsym[(int) userresize]) &&
                   BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)) &&
                   BNRP_unify(tcb,tcb->args[argnum+2],
                              BNRP_makeInteger(tcb,(long int)pe->width)) &&
                   BNRP_unify(tcb,tcb->args[argnum+3], 
                              BNRP_makeInteger(tcb,(long int)pe->height)));
         }

      case userreposition: 
         { PUserRepositionEvent *pe = (PUserRepositionEvent *) pevent;
           return(BNRP_unify(tcb,tcb->args[argnum], usereventsym[(int) userreposition]) &&
                  BNRP_unify(tcb,tcb->args[argnum+1],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)) &&
                  BNRP_unify(tcb,tcb->args[argnum+2],
                             BNRP_makeInteger(tcb,(long int)pe->leftedge)) &&
                  BNRP_unify(tcb,tcb->args[argnum+3], 
                             BNRP_makeInteger(tcb,(long int)pe->topedge)));
          }

      case scrapchanged: 
         { PScrapChangedEvent *pe = (PScrapChangedEvent *) pevent;
           return BNRP_unify(tcb,tcb->args[argnum], usereventsym[(int) scrapchanged]); 
          }

     default:
	 return FALSE;
    }
    return FALSE;  /* unreachable */
}


/* Prolog primitive - lasteventdata(Event,Windowname,[Mousegx,Mousegy],
            When,[Control,Option,Capslock,Shift,Command,Mouseup])	
   - returns information on the last user event */

BNRP_Boolean lasteventdata(tcb)

   BNRP_TCB *tcb;

{ PAnyEvent *pe = (PAnyEvent *)PrologEvent;

#ifdef xDEBUG
   if (DebugTrace) printf("In lasteventdata.\n"); 
#endif

   if (tcb->numargs != 5)
      return(FALSE);

   return (BNRP_unify(tcb,tcb->args[1],usereventsym[(int) pe->type]) &&
           BNRP_unify(tcb,tcb->args[2],
                     BNRP_makeSymbol(tcb, (pe->window == NULL) ? "NULL" : pe->window->windowname)) &&
           BNRP_unify(tcb,tcb->args[3],
                      BNRP_makeList(tcb,2,
                                    BNRP_makeInteger(tcb,(long int)pe->mousegx),
                                    BNRP_makeInteger(tcb,(long int)pe->mousegy))) &&
           BNRP_unify(tcb,tcb->args[4],BNRP_makeInteger(tcb,(long int)pe->when)) &&
           BNRP_unify(tcb,tcb->args[5],
                      BNRP_makeList(tcb,6,
                                    BNRP_makeInteger(tcb,(long int)pe->control),
                                    BNRP_makeInteger(tcb,(long int)pe->option),
                                    BNRP_makeInteger(tcb,(long int)pe->capslock),
                                    BNRP_makeInteger(tcb,(long int)pe->shift),
                                    BNRP_makeInteger(tcb,(long int)pe->command),
                                    BNRP_makeInteger(tcb,(long int)pe->mouseup))));
}


#ifdef DEBUG
void TracePrologEvent()

{   
   switch(PrologEvent->type)
      { case unknown:
           /* printf("Unknown Prolog event.\n"); */
           break;
           
        case userkey: 
         { PUserKeyEvent *pe = (PUserKeyEvent *) PrologEvent;

           printf("Userkey: %s ",pe->window->windowname);
           if (pe->symbol[0] >= ' ')
              printf("'%s'",pe->symbol);
           else
              printf("X'%X'",pe->symbol[0]);
           if (pe->control) printf(" control");
           if (pe->option) printf(" option");
           if (pe->capslock) printf(" capslock");
           if (pe->shift) printf(" shift");
           if (pe->command) printf(" command");
           if (!(pe->mouseup)) printf(" mousedown");
           printf("\n");
           break;
          }
          
        case userupidle: case userdownidle: 
          { PUserIdleEvent *pe = (PUserIdleEvent *) PrologEvent;

           if (PrologIdleTrace)
              { if (pe->type == userupidle)
                   printf("Userupidle: ");
                else
                   printf("Userdownidle: ");
                if (pe->window == NULL)
                   printf("NULL. ");
                else
                   printf("%s. ",pe->window->windowname); 
                printf("(%d,%d).\n",pe->mouselx,pe->mousely);
               }
           break;
          }

        case usermouseup: case usermousedown: 
          { PUserMouseEvent *pe = (PUserMouseEvent *) PrologEvent;

            if (pe->type == usermouseup)
                printf("Usermouseup: ");
            else
                printf("Usermousedown: ");
            if (pe->window == NULL)
                printf("NULL. ");
            else
                printf("%s. ",pe->window->windowname); 
            printf("(%d,%d).\n",pe->mouselx,pe->mousely);
            break;
          }
          
        case useractivate: case userdeactivate:
         { PUserActivateEvent *pe = (PUserActivateEvent *) PrologEvent;

           if (pe->type == useractivate)
              printf("Useractivate: ");
           else
              printf("Userdeactivate: ");
           printf("%s\n",pe->window->windowname);
           break;
         }

	case menuselect:
	{ PMenuSelectEvent *pe = (PMenuSelectEvent *) PrologEvent;

	   printf("MenuSelect: %s,%s,%s\n",pe->window->windowname,pe->menu,pe->item);
	   break;
	}

        case userupdate:
         { PUserUpdateEvent *pe = (PUserUpdateEvent *) PrologEvent;

           printf("Userupdate: ");
           if (pe->window == NULL)
              printf("NULL\n");
           else
              printf("%s\n",pe->window->windowname);
           break;
         }

        case userclose:
         { PUserCloseEvent *pe = (PUserCloseEvent *) PrologEvent;

           printf("Userclose: ");
           if (pe->window == NULL)
              printf("NULL.");
           else
              printf("%s",pe->window->windowname);
           printf(" X %d, Y %d.\n",pe->mousegx,pe->mousegy);
           break;
         }

        case userresize:
         { PUserResizeEvent *pe = (PUserResizeEvent *) PrologEvent;

           printf("Userresize: ");
           if (pe->window == NULL)
              printf("NULL.");
           else
              printf("%s",pe->window->windowname);
           printf(" Width %d, height %d.\n",pe->width,pe->height);
           break;
         }

        case userreposition:
         { PUserRepositionEvent *pe = (PUserRepositionEvent *) PrologEvent;

           printf("Userreposition: ");
           if (pe->window == NULL)
              printf("NULL.");
           else
              printf("%s",pe->window->windowname);
           printf(" Leftedge %d, topedge %d.\n",pe->leftedge,pe->topedge);
           break;
         }

        case scrapchanged:
         {
           printf("Scrapchanged.\n");
           break;
         }

        default:
           break;
       }
}

void TraceEvent(event)
  XEvent  *event; 
  
{ char          name[20];

   switch (event->type)
      { case KeyPress: strcpy(name,"KeyPress"); break;
        case KeyRelease: strcpy(name,"KeyRelease"); break;
        case ButtonPress: strcpy(name,"ButtonPress"); break;
        case ButtonRelease: strcpy(name,"ButtonRelease"); break;
        case MotionNotify: strcpy(name,"MotionNotify"); break;
        case EnterNotify: strcpy(name,"EnterNotify"); break;
        case LeaveNotify: strcpy(name,"LeaveNotify"); break;
        case FocusIn: strcpy(name,"FocusIn"); break;
        case FocusOut: strcpy(name,"FocusOut"); break;
        case KeymapNotify: strcpy(name,"KeymapNotify"); break;
        case Expose: strcpy(name,"Expose"); break;
        case GraphicsExpose: strcpy(name,"GraphicsExpose"); break;
        case NoExpose: strcpy(name,"NoExpose"); break;
        case CirculateRequest: strcpy(name,"CirculateRequest"); break;
        case ConfigureRequest: strcpy(name,"ConfigureRequest"); break;
        case MapRequest: strcpy(name,"MapRequest"); break;
        case ResizeRequest: strcpy(name,"ResizeRequest"); break;
        case CirculateNotify: strcpy(name,"CirculateNotify"); break;
        case ConfigureNotify: strcpy(name,"ConfigureNotify"); break;
        case CreateNotify: strcpy(name,"CreateNotify"); break;
        case DestroyNotify: strcpy(name,"DestroyNotify"); break;
        case GravityNotify: strcpy(name,"GravityNotify"); break;
        case MapNotify: strcpy(name,"MapNotify"); break;
        case MappingNotify: strcpy(name,"MappingNotify"); break;
        case ReparentNotify: strcpy(name,"ReparentNotify"); break;
        case UnmapNotify: strcpy(name,"UnmapNotify"); break;
        case VisibilityNotify: strcpy(name,"VisibilityNotify"); break;
        case ColormapNotify: strcpy(name,"ColormapNotify"); break;
        case ClientMessage: strcpy(name,"ClientMessage"); break;
        case PropertyNotify: strcpy(name,"PropertyNotify"); break;
        case SelectionClear: strcpy(name,"SelectionClear"); break;
        case SelectionNotify: strcpy(name,"SelectionNotify"); break;
        case SelectionRequest: strcpy(name,"SelectionRequest"); break;
        default: strcpy(name,"Unknown");  return;
      }
      printf("Next event is %s, window = %x ",name,event->xany.window);
      if (((XAnyEvent *)event)->send_event) 
         printf("(simulated)");
      printf("\n");
}
#endif

void eventLoop()
{
    XEvent  event;

    if (PrologEvent->type != unknown) {
        LastPrologEv = PrologEv;
        PrologEvent->type = unknown;
    }

    XtAppNextEvent(app_context, &event);
    
#ifdef DEBUG
    if (XEventTrace) TraceEvent(&event);
#endif

    TrackButtonState(&event);
    XtDispatchEvent(&event);

    /*
     * 05/01/96: added by yanzhou@bnr.ca
     *
     * reason: to handle WM_DELETE_WINDOW ClientMessage correctly
     */
    if (event.type == ClientMessage)
        textEditState = FALSE;

    /*
     * 20/10/95: added by yanzhou@bnr.ca
     * 02/01/96: modified by yanzhou@bnr.ca
     *
     * reason: to terminate this inner eventLoop correctly
     */
    switch (PrologEvent->type) {
    case menuselect:     /* select menu    */
    case usermousedown:  /* button press   */
        textEditState = FALSE;
    }
}

void BindPEventPrimitives()
{
   /* userevent */
   LastPrologEv.type = unknown;
   PrologEv.type = unknown;
   BNRPBindPrimitive("$userevent",userevent);

   usereventsym[(int) unknown] = BNRP_makePermSymbol("unknown");
   usereventsym[(int) userupidle] = BNRP_makePermSymbol("userupidle");
   usereventsym[(int) userdownidle] = BNRP_makePermSymbol("userdownidle");
   usereventsym[(int) userkey] = BNRP_makePermSymbol("userkey");
   usereventsym[(int) useractivate] = BNRP_makePermSymbol("useractivate");
   usereventsym[(int) userdeactivate] = BNRP_makePermSymbol("userdeactivate");
   usereventsym[(int) menuselect] = BNRP_makePermSymbol("menuselect");
   usereventsym[(int) usermouseup] = BNRP_makePermSymbol("usermouseup");
   usereventsym[(int) usermousedown] = BNRP_makePermSymbol("usermousedown");
   usereventsym[(int) userupdate] = BNRP_makePermSymbol("userupdate");
   usereventsym[(int) usergrow] = BNRP_makePermSymbol("usergrow");
   usereventsym[(int) userzoom] = BNRP_makePermSymbol("userzoom");
   usereventsym[(int) userdrag] = BNRP_makePermSymbol("userdrag");
   usereventsym[(int) userclose] = BNRP_makePermSymbol("userclose");
   usereventsym[(int) userresize] = BNRP_makePermSymbol("userresize");
   usereventsym[(int) userreposition] = BNRP_makePermSymbol("userreposition");
   usereventsym[(int) scrapchanged] = BNRP_makePermSymbol("scrapchanged");

   BNRPBindPrimitive("$lasteventdata",lasteventdata);

   /* Rebind the keysyms for the special keys. This code is dependent on the
      order of the keysym assigned codes */
  { char  *sym_name;
	char	symbol[16];
    KeySym key;

   /* Cursor arrow keys */
	for (key = XK_Left; key <=  XK_Down; key++)
		if ((sym_name=XKeysymToString(key)) != NULL) {
			strcpy(symbol,sym_name);
			symbol[0] = tolower(symbol[0]);
        /*   REMOVED Mar. 95 XRebindKeysym(display,key,NULL,0,symbol,strlen(symbol)); */
 /* NEW */     XRebindKeysym(display,key,NULL,0,(unsigned char *)symbol,strlen(symbol));

		}
   /* Function keys */
   for (key = XK_F1; key <=  XK_F35; key++)
		if ((sym_name=XKeysymToString(key)) != NULL) {
			strcpy(symbol,sym_name);
			symbol[0] = tolower(symbol[0]);
     /*     REMOVED Mar. 95 XRebindKeysym(display,key,NULL,0,symbol,strlen(symbol)); */
 /* NEW */  XRebindKeysym(display,key,NULL,0,(unsigned char *)symbol,strlen(symbol));

		}
   /* Enter key */
   XRebindKeysym(display,XK_KP_Enter,NULL,0,(unsigned char *)"enter",5);

  }
}


static char *key_bindings[40][2] = {
     {"left", "Left"},
     {"up", "Up"},
     {"right", "Right"},
     {"down", "Down"},
     {"enter", "KP_Enter"},
     {"f1", "F1"},
     {"f2", "F2"},
     {"f3", "F3"},
     {"f4", "F4"},
     {"f5", "F5"},
     {"f6", "F6"},
     {"f7", "F7"},
     {"f8", "F8"},
     {"f9", "F9"},
     {"f10", "F10"},
     {"f11", "F11"},
     {"f12", "F12"},
     {"f13", "F13"},
     {"f14", "F14"},
     {"f15", "F15"},
     {"f16", "F16"},
     {"f17", "F17"},
     {"f18", "F18"},
     {"f19", "F19"},
     {"f20", "F20"},
     {"f21", "F21"},
     {"f22", "F22"},
     {"f23", "F23"},
     {"f24", "F24"},
     {"f25", "F25"},
     {"f26", "F26"},
     {"f27", "F27"},
     {"f28", "F28"},
     {"f29", "F29"},
     {"f30", "F30"},
     {"f31", "F31"},
     {"f32", "F32 "},
     {"f33", "F33"},
     {"f34", "F34"},
     {"f35", "F35"},
};

char* CheckForBoundKey(pstring)
char *pstring;
{
   int i;
   for(i = 0; i < 40; i++)
   {
         if (strcmp(pstring, key_bindings[i][0]) == 0)
         {
	    /*	    printf("returning the string = %s\n",key_bindings[i][1]); */
	    return key_bindings[i][1];
	 }    
    }
    return pstring;
}

KeySym StringToKeysym(str)
char *str;
{
	char *bound_key_str;
	
	bound_key_str = CheckForBoundKey(str);
	
	return XStringToKeysym(bound_key_str);		
}
