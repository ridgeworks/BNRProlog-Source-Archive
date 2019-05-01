/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/ProEvents.h,v 1.1 1995/09/22 11:26:19 harrisja Exp $
*
*  $Log: ProEvents.h,v $
 * Revision 1.1  1995/09/22  11:26:19  harrisja
 * Initial version.
 *
*
*/

#ifndef _H_ProEvents
#define _H_ProEvents

#include	"ProWindows.h"

/* Prolog event data structures - set up by event handlers */

enum PrologEventType {unknown,userupidle,userdownidle,userkey,useractivate,
                      userdeactivate,menuselect,usermouseup,usermousedown,
                      userupdate,usergrow,userdrag,userzoom,userclose,
                      userresize,userreposition,scrapchanged};
#define LASTPROLOGEVENTNUM scrapchanged

typedef struct  /* any event */
   { enum PrologEventType			type;   
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
   } PAnyEvent;

typedef struct  /* userkey */
   { enum PrologEventType			type;   
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
     char           symbol[16];
   } PUserKeyEvent;
      
typedef struct  /* userupidle/userdownidle */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
     int            mouselx,mousely;
   } PUserIdleEvent;

typedef struct  /* useractivate/userdeactivate */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
   } PUserActivateEvent;

typedef struct  /* menuselect */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
     char	    *menu;
     char	    *item;
   } PMenuSelectEvent;

typedef struct  /* usermouseup/down */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
     int            mouselx,mousely;
   } PUserMouseEvent;

typedef struct  /* userupdate */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
   } PUserUpdateEvent;

typedef struct  /* userclose */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
   } PUserCloseEvent;

typedef struct  /* userresize */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
     Dimension      width,height;
   } PUserResizeEvent;

typedef struct  /* userreposition */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
     Position       leftedge,topedge;
   } PUserRepositionEvent;

typedef struct  /* scrapchanged */ 
   { enum PrologEventType            type;
     PAnyWindow     *window;
     Time           when;
     Boolean        modifiers_valid;
     int            mousegx,mousegy;  
     Boolean        control,option,capslock,shift,command,mouseup;
   } PScrapChangedEvent;

typedef union _PEvent
   { enum PrologEventType            type;    /* PrologEventType */
     PAnyEvent      pany;
     PUserKeyEvent  pkey; 
     PUserIdleEvent pidle;
     PUserActivateEvent pactivate;
     PMenuSelectEvent pmenu;
     PUserMouseEvent pmouse;
     PUserUpdateEvent pupdate;
     PUserCloseEvent pclose;
     PUserResizeEvent presize;
     PUserRepositionEvent preposition;
     PScrapChangedEvent   pscrapchanged;
   } PEvent;

extern PEvent *PrologEvent;

extern Boolean Button1Down;

extern Boolean textEditState;
extern int numExitChars;
typedef struct {
        Boolean ascii;
        union {
                KeySym keysym;
                char   ascii_value;
                } u;
        } editExit;
#define MAXEXITCHARS 50
extern editExit editExitSet[MAXEXITCHARS];
extern Widget  editbox;
extern XmTextPosition editSelStart,editSelEnd;

extern Boolean InvalidrectGenerated;

extern Boolean FormatPrologEvent();

#ifdef DEBUG
extern void TraceEvent();
extern void TracePrologEvent();
#endif

extern BNRP_Boolean userevent();
extern BNRP_Boolean lasteventdata();
extern void KeyPressCB();
extern void BindPEventPrimitives();
extern void GetModifierInfo();
extern void TrackButtonState();
extern void eventLoop();
extern Boolean memberEditExitSet();
extern KeySym StringToKeysym();


#endif
