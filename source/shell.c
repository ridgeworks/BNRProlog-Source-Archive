/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/shell.c,v 1.2 1997/12/22 17:01:34 harrisj Exp $
*
*  $Log: shell.c,v $
 * Revision 1.2  1997/12/22  17:01:34  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.1  1995/09/22  11:27:44  harrisja
 * Initial version.
 *
*
*/
#include <stdio.h>
#include <string.h>
#include "BNRProlog.h"
#include "base.h"

#ifdef mdelta
#include <time.h>
#else
#ifdef unix
#include <sys/time.h>
#include <sys/resource.h>
#else
#include <time.h>
#endif
#endif
#include "core.h"
#include "memory.h"
#include "interpreter.h"
#include "prim.h"
#include "stats.h"
#include "loader.h"
#include "context.h"
#include "utility.h"
#include "hardware.h"
#include "fsysprim.h"

#ifdef __mpw				/* MPW only */
#include <QuickDraw.h>
#include <Fonts.h>
#include <Events.h>
#include <Windows.h>
#include <Menus.h>
#include <TextEdit.h>
#include <Dialogs.h>
#include <memory.h>			/* for MoveHHi, HLock */
#include <resources.h>		/* for Count1Resources, Get1IndResource */
#include <stdlib.h>			/* for atof */
#endif

#ifdef __MWERKS__                       /* CodeWarrior only */
#include <sioux.h>
#include <fonts.h>
#include <memory.h>                     /* for MoveHHi, HLock */
#include <resources.h>          /* for Count1Resources, Get1IndResource */
#include <stdlib.h>                     /* for atof */
#endif

#ifdef THINK_C
#include <console.h>
	char *progname = "base.a";
#include <stdlib.h>			/* for atof */
#endif

#ifdef HSC
extern li BNRPflags;
#endif

long HEAPSIZE = 0;
long ENVSIZE = 0;

BNRP_Boolean initialTest(TCB *tcb)
{
	tcb->ppsw = bodyMode;
#ifdef HSC
        tcb->ppc = tcb->freePtr-1;
#else
        tcb->ppc = tcb->freePtr;
#endif
	push(BYTE, tcb->freePtr, 0x07);
	push(BYTE, tcb->freePtr, 0x00);
	(void)BNRP_RESUME(tcb);
	return(((long)&tcb & 0x03) NE 0);
	}

void getSetup()
{
	char *conf;
	
	if ((conf = BNRP_getConfig()) NE NULL)
		sscanf(conf, "configuration(%*ld, %ld, %ld", &HEAPSIZE, &ENVSIZE);
#ifdef unix
        HEAPSIZE = (HEAPSIZE LE 0) ? 1048576 : HEAPSIZE * 1024;
#else
        HEAPSIZE = (HEAPSIZE LE 0) ? 300000 : HEAPSIZE * 1024;
#endif
        ENVSIZE = (ENVSIZE LE 0) ? 300000 : ENVSIZE * 1024;
	}

TCB tcb;

int main(argc, argv)
int argc;
char **argv;
{
	fp f;
	long sym, gsa, gsu, cp, env, h, trail;
	long orig_reg;
	BNRP_term init;
	li test;
	int i;
	long err;
	unsigned long startTime, finishTime;
	char prog[1000];
	extern int BNRP_embedIgnoreContext;
	void BNRP_removeStateSpaces(long generation);
	void BNRP_removeAllContexts(void);
	void BNRP_freeAM(void);

#ifdef Macintosh
#ifdef THINK_C
	struct cons_options {
		short top;
		short left;
		short nrows;
		short ncols;
		short txFont;
		short txSize;
		short procID;
		unsigned char name;
	} **cons;
	Handle hh;

	if ((hh = GetResource('cons', 128)) NE NULL) {
		unsigned char *p;
		MoveHHi(hh);
		HLock(hh);
		cons = (struct cons_options **)hh;
		console_options.top = (**cons).top;
		console_options.left = (**cons).left;
		console_options.nrows = (**cons).nrows;
		console_options.ncols = (**cons).ncols;
		console_options.txFont = (**cons).txFont;
		console_options.txSize = (**cons).txSize;
		console_options.procID = (**cons).procID;
		console_options.title = p = &(**cons).name;
		p += (*p + 1);		/* skip over title string */
		if (*p) cecho2file((char *)p, 0, stdout);
		}
	else {
		console_options.procID = 0;
		console_options.nrows = 35; console_options.ncols += 10;
		cecho2file("compiler.run", 0, stdout);
		}
	argv[1] = progname;
#endif
#ifdef __mpw
	extern int StandAlone;
	extern void _DataInit();

	UnloadSeg((Ptr) _DataInit);		/* note that _DataInit must not be in Main! */
	if ((argc GE 2) && (strcmp(argv[1], "-debug") EQ 0)) debugstr("\pstarting");
	if (StandAlone) {
/*		MoreMasters();
		MoreMasters();
		MaxApplZone();  */				/* expand the heap so code segments load at the top */
/*		InitGraf((Ptr) &qd.thePort);
		InitFonts();
		InitWindows();
		InitMenus();
		TEInit();
		InitDialogs(nil);
		InitCursor();			*/
		}
#endif
#ifdef __MWERKS__
        {
        tSIOUXSettings mySettings ={TRUE,               //      Do we initialize the ToolBox ...
                                                                TRUE,           //      Do we draw the SIOUX menus ...
                                                                FALSE,          //      Do we close the SIOUX window on program termination ...
                                                                FALSE,          //      Do we offer to save on a close ...
                                                                FALSE,           //      Do we draw the status line ..
                                                                0,                      //      Unused bits ...
                                                                0,                      //      if non-zero, replace tabs with 'tabspaces' spaces ...
                                                                80, 24,         //      The initial size of the SIOUX window ...
                                                                0, 0,           //      The topleft window position (in pixels)
                                                                                        //              (0,0 centers on main screen) ...
                                                                monaco,         //      SIOUXs font, size and textface (i.e. bold, etc...) ...
                                                                9,
                                                                normal};
 
       SIOUXSettings = mySettings;
        }
#endif

	{
	Handle hh;
	short i, numItems;
	
	numItems = Count1Resources('CODE');
	for (i = 1; i LE numItems; ++i) {
		hh = Get1IndResource('CODE', i);
		if (ResError() EQ noErr) { 
			MoveHHi(hh);
			HLock(hh);
			}
		}
	}
#endif
	if (sizeof(li) NE sizeof(long)) printf("long not equal to 2 shorts\n");
	test.l = 0x12345678;
	if (test.i.b NE 0x5678) printf("order mismatch between 2 shorts\n");
	if (BNRP_CheckAlignment()) {
		printf("Assembler core incorrect\n");
		return(-1);
		}
	
	setvbuf(stdout, NULL, _IOLBF, 100);
	getSetup();

#ifdef Macintosh
#ifndef __MWERKS__
	init = 0;
	BNRP_initializeAllLowerRings(argc, argv);
	for (i = 1; i LT argc; ++i)
		if (strcmp(argv[i], "-load") EQ 0) {
			if (i = BNRP_loadBase(1, argv, argv[i+1])) {
				printf("Unable to load %s, rc = %d\n", argv[i+1], i);
				return(i);
				}
			init = 1;
			break;
			}
	if (init EQ 0) {
		if (Count1Resources('CNTX') EQ 1) {
			Handle hh;
			long *context;
			short i, numItems, num;
			long size, *index;
			ResType theType;
			unsigned char name[257];	// room for 255 characters, size, plus 0
			BNRP_term atom;
					
			
			hh = Get1IndResource('CNTX', 1);
			MoveHHi(hh);
			HLock(hh);
			DetachResource(hh);
			context = (long *)*hh;
			
			numItems = Count1Resources('INTG');
			for (i = 1; i LE numItems; ++i) {
				hh = Get1IndResource('INTG', i);
				if (ResError() EQ noErr) { 
					GetResInfo(hh, &num, &theType, name);
					atom = BNRP_embedInt(num);
					size = SizeResource(hh);
					index = (long *)(*hh);
					for (; size GT 0; size -= sizeof(long))
						context[*index++] = atom;
					ReleaseResource(hh);
					}
				}
			
			numItems = Count1Resources('FLOT');
			for (i = 1; i LE numItems; ++i) {
				hh = Get1IndResource('FLOT', i);
				if (ResError() EQ noErr) { 
					GetResInfo(hh, &num, &theType, name);
					name[name[0]+1] = '\0';
					atom = BNRP_embedFloat(atof((char *)&name[1]));
					size = SizeResource(hh);
					index = (long *)(*hh);
					for (; size GT 0; size -= sizeof(long))
						context[*index++] = atom;
					ReleaseResource(hh);
					}
				}
			
			numItems = Count1Resources('SMBL');
			for (i = 1; i LE numItems; ++i) {
				hh = Get1IndResource('SMBL', i);
				if (ResError() EQ noErr) {
					char *p;
					
					GetResInfo(hh, &num, &theType, name);
					name[name[0]+1] = '\0';
					while (p = strchr((char *)&name[1], '\r')) *p = '\n';
					atom = BNRP_embedSymbol((char *)&name[1]);
					size = SizeResource(hh);
					index = (long *)(*hh);
					for (; size GT 0; size -= sizeof(long))
						context[*index++] = atom;
					ReleaseResource(hh);
					}
				}
			
			numItems = Count1Resources('CLAS');
			for (i = 1; i LE numItems; ++i) {
				hh = Get1IndResource('CLAS', i);
				if (ResError() EQ noErr) { 
					GetResInfo(hh, &num, &theType, name);
					name[name[0]+1] = '\0';
					size = SizeResource(hh);
					index = (long *)(*hh);
					for (; size GT 0; size -= (3 * sizeof(long))) {
						long off, arity, hash;
						off = *index++;
						arity = *index++;
						hash = *index++;
    					BNRP_embedClause((char *)&name[1], arity, hash, &context[off]);
						}
					ReleaseResource(hh);
					}
				}
			
			numItems = Count1Resources('OPER');
			for (i = 1; i LE numItems; ++i) {
				hh = Get1IndResource('OPER', i);
				if (ResError() EQ noErr) { 
					long prec;
					GetResInfo(hh, &num, &theType, name);
					name[name[0]+1] = '\0';
					index = (long *)(*hh);
					prec = *index++;
   					BNRP_embedOperator((char *)&name[1], prec, (char *)index);
					ReleaseResource(hh);
					}
				}
			}
		else if (i = BNRP_loadBase(1, argv, "base.a")) {
			printf("Unable to load base.a, rc = %d\n", i);
			return(i);
			}
		}
#else
	if (i = BNRP_initializeRing5(argc, argv)) {
		printf("Unable to initialize, rc = %d\n", i);
		return(i);
		}
#endif
#else
        if (i = BNRP_initializeRing5(argc, argv)) {
                printf("Unable to initialize, rc = %d\n", i);
                return(i);
                }
#endif

	tcb.space = tcb.freePtr = tcb.ASTbase = tcb.heapbase =
	tcb.trailbase = tcb.envbase = tcb.cpbase = tcb.spbase = tcb.spend =
	tcb.emptyList = tcb.ppsw = 0;
 
	if (BNRP_initializeTCB((BNRP_TCB *)&tcb, "main", HEAPSIZE, ENVSIZE)) {
		printf("Insufficient memory\n");
		return(-1);
		}

	if (initialTest(&tcb)) 
		printf("***** Stack not longword aligned: may affect performance\n");
	if (BNRPFindSymbol("pde_init", GLOBAL, &init)) {
		initialGoal(&tcb, init, 0);
		orig_reg = 0;
		}
	else {
		initialGoal(&tcb, BNRPLookupPermSymbol("main"), 1);
		orig_reg = tcb.args[1];
		}

#if defined(THINK_C)
	printf("Starting...\n");
#else
#if defined(__MWERKS__)
        printf("Starting...\n");
        SIOUXSettings.autocloseonquit = TRUE;
#else
	BNRP_findfile(*argv, prog);
	printf("%s starting...\n", prog);
#endif
#endif
#ifdef HSC
       oldSigIntHandler = BNRP_installSighandler(SIGINT, BNRP_initSighandler(abortHandler));
       oldSigFpeHandler = BNRP_installSighandler(SIGFPE, BNRP_initSighandler(arithHandler));
#endif

	startTime = BNRP_getUserTime(TRUE, &f);
	err = BNRP_RESUME(&tcb);
	finishTime = BNRP_getUserTime(TRUE, &f);
	f = (finishTime - startTime - f) / 1000.0;

#ifdef HSC
      BNRP_installSighandler(SIGINT,oldSigIntHandler); /* Modified Oz 08/12/95 */
      BNRP_installSighandler(SIGFPE,oldSigFpeHandler); /* Modified Oz 08/12/95 */
#endif

	if (err) {
		printf("\n\n*** ERROR ***  ");
		switch (err) {
			case OUTOFCHOICEPOINTS:
						printf("Goal fails\n");
						break;
			case UNEXECUTABLETERM:
						printf("Unexecutable term\n");
						break;
			case OUTOFMEMORY:
						printf("Out of available memory\n");
						break;
			case GLOBALSTACKOVERFLOW:
						printf("Global stack (heap + trail) overflow\n");
						break;
			case LOCALSTACKOVERFLOW:
						printf("Local stack (choicepoint + environments) overflow\n");
						break;
			case NAMEDCUTNOTFOUND:
						printf("Name specified for cut/failexit not found\n");
						break;
			case DIVIDEBY0:
						printf("Divide by 0\n");
						break;
			case ARITHERROR:
						printf("System detected arithmetic error\n");
						break;
			case STATESPACECORRUPT:
						printf("State space corrupt\n");
						break;
			case STATESPACELOOP:
						printf("Looped functor in state space\n");
						break;
			case INTERNALERROR:
						printf("Internal error\n");
						break;
			default:
						printf("Execution returns %ld\n", err);
						break;
			}
		printf("%s\n\n", BNRP_lastErrorTraceback);
		}
#ifdef unix
	printf("Process time = %f sec\n\n", f);
#else
	printf("Elapsed time = %f sec\n\n", f);
#endif

	if (orig_reg NE 0) {
		BNRP_dumpArg(stdout, &tcb, orig_reg);
		printf("\n\n");
		}
	
	BNRP_contextSpaceUsed(&gsa, &gsu, &sym);
	BNRP_stackSpaceUsed((BNRP_TCB *)&tcb, &h, &trail, &env, &cp);
	printf("Number of symbols = %ld\n", sym);
	printf("Context space used = %ld bytes (out of %ld)\n", gsu, gsa);
	printf("Heap used = %ld bytes ", h);
	printf("Trail used = %ld bytes ", trail);
	printf("(out of %ld)\n",HEAPSIZE);
	printf("Choicepoint used = %ld bytes ", cp);
	printf("Environment used = %ld bytes ", env);
	printf("(out of %ld)\n", ENVSIZE);
	if (h = BNRP_getLIPS()) {
		/* BNRP_printStats(); */
#if defined(THINK_C) || defined(__MWERKS__)
		printf("\n%ld LI, ", h);
#else
		printf("\n%s %ld LI, ", prog, h);
#endif
		if (f GT 0.0)
			printf("%f LI/sec\n", h / f);
		else
			printf("INF LI/sec\n");
		}
/*********
	printf("Ending Heap:"); BNRP_dumpHex(stdout, (void *)tcb.heapbase, (void *)tcb.hp);
*********/

	/* following added 93/06/24 JR to remove allocated    */
	/* memory so that proper checks can be done for leaks */
	(void)BNRP_terminateTCB((BNRP_TCB *)&tcb);	/* free up stacks */
	BNRP_removeStateSpaces(0);					/* remove all state spaces */
	BNRP_removeAllContexts();					/* remove contexts and state spaces */
	BNRP_freeAM();								/* remove AM if it exists */	
	return(err);
	}
