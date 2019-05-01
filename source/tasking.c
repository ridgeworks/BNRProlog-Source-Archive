/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/tasking.c,v 1.4 1997/12/22 17:01:44 harrisj Exp $
*
*  $Log: tasking.c,v $
 * Revision 1.4  1997/12/22  17:01:44  harrisj
 * Added support for HSC and to build HSC and non-HSC BNRP
 *
 * Revision 1.3  1995/12/12  14:21:55  yanzhou
 * 1) Signals, depending on the underlying OS, can now be handled
 * in one of the 3 ways listed below:
 *    USE_SIGACTION (POSIX) hpux9,ibm-aix4.1,nav88k-sysVr4,sunOS4.1
 *    USE_SIGSET    (SVID2) mdelta
 *    USE_SIGVECTOR (BSD)   sgi
 *
 * 2) Also changed is the way in which connect() timed-outs are
 * detected.  Was using SIGALRM to force a blocking connect() to
 * exit prematurally.  Now uses a combination of POSIX non-blocking
 * I/O mode (O_NONBLOCK) and select(), which handles the
 * situation more elegantly.
 *
 * 3) Now uses SA_RESTART if it is supported by the underlying OS.
 * This way, when a system call is interrupted by a signal, it is
 * transparently restarted on exit of the signal.
 * There is no need to define TICK_INTERRUPTS_SYSTEM_CALLS if
 * SA_RESTART is in effect.
 *
 * Revision 1.2  1995/12/04  00:10:24  yanzhou
 * Now supports IBM Power/RS6000 AIX 4.1.
 *
 * Revision 1.1  1995/09/22  11:28:50  harrisja
 * Initial version.
 *
*
*/
/*	Tasking code for BNR Prolog */

/* Log:
Originally written by Jason Harris - June-July-Aug 1994

Sept 12 1994 task inititiation revised to copy spbase/spend into new task
			  for wama - wjo
Sept 15 1994 task search loops modified for maintainability -wjo
*/

#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include "BNRProlog.h"
#include "base.h"
#include "core.h"
#include "context.h"
#include "hardware.h"
#include "interpreter.h"
#include "memory.h"
#include "tasking.h"
#include "prim.h"
#include "utility.h"

#define VALID_TASK	0xbaa0003	/*Mask to check for valid TCB's */

#ifdef ring0
TCB * BNRPlast_task = NULL;			/*Pointer to the last task in the task chain*/
long BNRPtask_count = -1;			/* # of tasks created */
int BNRP_SwitchedTask = 0;
#else
extern TCB * BNRPlast_task;
extern long BNRPtask_count;
extern int BNRP_SwitchedTask;
#endif


#ifdef unix
#ifdef mdelta /*  NEW Use jmp_buf on mdelta -- Oz 04/95 */
jmp_buf BNRPerrorbuf;
#else
sigjmp_buf BNRPerrorbuf;
#endif
#endif

/* External variable from core.c to store registers*/
extern li BNRPflags;



/*Signal handling functions and macros to check that passed in task addresses are really TCB addresses*/

#ifdef unix
#ifdef ring5
void task_check(int signo)	/*Signal handler to make sure passed in arguements are task id's */
{
	longjmp(BNRPerrorbuf, 1);
}
#endif

/* New from Oz 14/04/95 */

#define validID(x)      {\
    long validate;\
    BNRP_sighandler oldSigSegvHandler;\
    BNRP_sighandler oldSigBusHandler;\
    /*Catch segmentation faults and bus errors*/\
    oldSigSegvHandler = BNRP_installSighandler(SIGSEGV, BNRP_initSighandler(task_check));\
    oldSigBusHandler  = BNRP_installSighandler(SIGBUS,  BNRP_initSighandler(task_check));\
    if(setjmp(BNRPerrorbuf) EQ 0)\
    {\
        validate = x->validation;\
    }\
    else  validate = 0;  /*Received a signal*/\
    BNRP_installSighandler(SIGSEGV,oldSigSegvHandler);\
    BNRP_installSighandler(SIGBUS,oldSigBusHandler);\
    if(validate NE VALID_TASK) return(FALSE);\
}
#else
#define validID(x)	if ((long)x & 0x03) return(FALSE); \
			if(x->validation NE VALID_TASK) return(FALSE)

#endif
				
/*SaveRegisters and LoadRegisters are used for task switching  */

#define SaveRegisters(task) task->rmsgVal = BNRPflags.l;
#define LoadRegisters(task) BNRPflags.l = task->rmsgVal;

#ifdef ring0
int BNRP_initializeTask(TCB *tcb, long heap_trailSize, long env_cpSize, TCB * current_task)
{  /*Initialize the parts of the TCB structure*/

	int i;
	choicepoint *newcp;

 /*	tcb->space = tcb->freePtr = tcb->ASTbase = tcb->heapbase = 
	tcb->trailbase = tcb->envbase = tcb->cpbase = tcb->spbase = tcb->spend =
        tcb->emptyList = tcb->ppsw = 0; */

	i = BNRP_allocMemory(tcb, heap_trailSize, env_cpSize);
	if (i) return(i);

	tcb->nargs = tcb->ppsw = tcb->stp = tcb->glbctx = tcb->svsp = tcb->ppc = 
	tcb->procname = tcb->rmsgVal = tcb->smsgVal =0;

	tcb->invokee = NULL;
	tcb->invoker = current_task;			/*Set the invoker of the task*/
	tcb->validation = VALID_TASK;				/*Validate the task*/

	tcb->te = tcb->trailbase;
	tcb->lcp = tcb->cutb = tcb->cpbase;
	
	tcb->hp = tcb->heapbase;
	tcb->emptyList = maketerm(LISTTAG, tcb->heapbase);
	push(long, tcb->hp, 0);				/* make actual empty list */
	tcb->ce = tcb->envbase;
	/* make dummy self-referencing environment */
	push(BYTE, tcb->ce, 0x07);				/* break code */
	tcb->cp = tcb->ce;							/* cp points at 0 */
	push(BYTE, tcb->ce, 0x00);
	push(BYTE, tcb->ce, 0x07);
	push(BYTE, tcb->ce, 0x00);
	push(long, tcb->ce, 0);					/* no name in environment */
	push(long, tcb->ce, ((TCB *)tcb)->cutb);
	push(long, tcb->ce, ((TCB *)tcb)->ce+sizeof(long));
	*(long *)tcb->ce = ((TCB *)tcb)->envbase;
			/* wjo sept 94: make dummy choicepoint: */
	newcp = (choicepoint *)((long)tcb->cpbase - sizeof(choicepoint));
	newcp->numRegs = 0;			/* arity */
	newcp->procname = 0;
	newcp->bcp = tcb->cp;
	newcp->bce = tcb->ce;
	newcp->te = tcb->te;
	newcp->lcp = 0;
	newcp->hp = tcb->hp;
	newcp->critical = 0;
	newcp->key = 0;
	newcp->clp = 0;
	tcb->lcp = tcb->cutb = (long)newcp;
		/* wjo sept 94: end make dummy choicepoint */
    if (current_task NE NULL) 
		{ 	/* wjo sept 94: copy pdl region from parent task */
		 tcb->spbase = current_task->spbase;
		 tcb->spend =current_task->spend;
		};
		/* wjo sept 94: end copy pdl region from parent task */
	for (i = 1; i LT MAXREGS; ++i)
		tcb->args[i] = 0xAAAAAAAA;
	tcb->constraintHead = tcb->constraintTail = 0;

	tcb->prevTask = BNRPlast_task;		/* Add tcb to the task chain*/
	BNRPlast_task = tcb;			/* Move BNRPlast_task pointer*/
	BNRPtask_count ++;

	return(0);	/*Success*/
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_init_task(TCB *tcb)	/*Create a new task*/
{
	TCB * task;
	long csize, gsize, new_taskname, flag = 0;
	BNRP_Boolean default_unify = TRUE;

	if (tcb->numargs NE 5) return(FALSE);
	if ((checkArg(tcb->args[2],&gsize) NE INTT) || (checkArg(tcb->args[3],&csize) NE INTT)) return(FALSE);

	gsize *= 1024;	/*Convert from Kb to bytes*/
	csize *= 1024;

	switch(checkArg(tcb->args[4], &new_taskname))
	{
		case SYMBOLT:	/*User specified a taskname*/
			if (strcmp(nameof(new_taskname),"main") EQ 0) return(FALSE);	/*Users can't use the taskname 'main' */
			if ((task = (TCB *)BNRP_malloc(sizeof(TCB))) EQ NULL) return(FALSE);
			if (BNRP_initializeTask(task,gsize,csize,tcb) NE 0)
			{/*Couldn't allocate space for stacks*/
				BNRP_free((void *)task);
				return(FALSE);
			}
			task->taskName = (BNRP_term)new_taskname;
			break;
		case VART:	/*User doesn't care about the task name, so use the default name*/
			if ((task = (TCB *)BNRP_malloc(sizeof(TCB))) EQ NULL) return(FALSE);
			if(BNRP_initializeTask(task,gsize,csize,tcb) NE 0)
			{
				BNRP_free((void *)task);
				return(FALSE);
			}
			task->taskName = BNRP_defaultTaskName;
			flag = 1;
			break;
		default: return(FALSE);
	}
	tcb->invokee = task;
	initialGoal(task,tcb->args[1],0);
#ifdef HSC
	task->cp = task->ppc;
#else
	task->cp = task->ppc - 1;
#endif

	if(flag) default_unify = unify(tcb,tcb->args[4],makeint(&tcb->hp,(long)task));
	return(default_unify && unify(tcb,tcb->args[5],makeint(&tcb->hp,(long)task)));
}
#endif

static BNRP_Boolean delete_Task(TCB * task)	/* Remove a task from the task chain */
{	TCB  *tp, *t;

	t = BNRPlast_task;
	while ((t NE NULL) AND (t NE task)) { tp=t; t=tp->prevTask;} ;
	if (t EQ task) 
	{
		if (t EQ BNRPlast_task)  
		  	{ BNRPlast_task= t->prevTask;}
		else
			{tp->prevTask = t->prevTask; };
		BNRP_disposeTCB((BNRP_TCB **)&task);
		BNRPtask_count --;
		return(TRUE);
	}
	else return(FALSE);
}

#ifdef ring5
BNRP_Boolean BNRP_end_task(TCB * tcb)	/* Remove a task from the task chain */
/* wjo Sept 15 94 rewritten somewhat
This is the primitive used to kill tasks OTHER than the running task or
any suspended in Send (ie the invoker chain)  */
{
	TCB *task;
	long id;

	if (BNRPtask_count LT 1) return(FALSE);	/* Can't delete the main task (task 0) */
	if(tcb->numargs NE 1) return(FALSE);
	if(checkArg(tcb->args[1],&id) NE INTT) return(FALSE);

	task = (TCB *)id;
	validID(task);
	if (task->prevTask EQ NULL) return(FALSE); /* Can't delete the main task (task 0) */
	if (task->invoker  NE NULL) return(FALSE); /* Can't delete if on return chain */
	return( delete_Task(task));
}
#endif




#ifdef ring0
BNRP_Boolean BNRP_removeTaskFromChain(TCB ** tcb)	/* Remove a task from the task chain */
/* wjo Sept 15 94 rewritten somewhat
This is used by the RUNNING task - typically during normal termination 
The tcb pointer is updated to the invoker 
Returns FALSE if (1) no invoker to switch to or (2) unable to delete from chain */

{
	TCB *newtcb, *t;
	
	t= *tcb;	
	newtcb = t->invoker;
	if (newtcb EQ NULL) return(FALSE);
	newtcb->invokee = NULL;
	LoadRegisters(newtcb);
	*tcb = newtcb;
 	return( delete_Task(t));
}
#endif

#ifdef ring5
static TCB * findTaskID(char * taskname)	/*Find the tcb with 'taskname' as its name */	
{
	TCB * t;
	t = BNRPlast_task;
	while(t)
	{   /*Iterate through the task chain until t->taskName equals taskname, then return the address of t*/

		if((strcmp(nameof(t->taskName),taskname) EQ 0) && (t->validation EQ VALID_TASK)) return(t);
		t = t->prevTask;
	}
	return(NULL);
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_selfID(TCB *tcb)		/* Return the address of the current task, as the task ID */
{
	if (tcb->numargs NE 1) return(FALSE);
	return(unify(tcb,tcb->args[1],makeint(&tcb->hp,(long)tcb)));
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_next_task(TCB * tcb)		/* Find the next task in the task chain */
{
	long var;
	TCB * task;

	if (tcb->numargs NE 2) return(FALSE);
	switch(checkArg(tcb->args[1], &var))
	{
		case INTT:			/*Unify with the task's previous task*/
			task = (TCB *)var;
			validID(task);
			if(task->prevTask EQ NULL) return(FALSE);
			return(unify(tcb,tcb->args[2],makeint(&tcb->hp,(long)task->prevTask)));
		case VART:			/*Unify with the BNRPlast_task*/
			return(unify(tcb,tcb->args[2],makeint(&tcb->hp,(long)BNRPlast_task)));
		default: return(FALSE);
	}
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_test_task(TCB * tcb)		/*Return whether or not the given task id or name is associated with a valid task*/
{
	long var;

	if (tcb->numargs NE 1) return(FALSE);
	switch(checkArg(tcb->args[1],&var))
	{
		case INTT:
			validID(((TCB *)var));
			return(TRUE);
		case SYMBOLT:
			if(findTaskID(nameof(var)) NE NULL) return(TRUE);
			return(FALSE);
		default: return(FALSE);
	}
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_task_switch(TCB ** tcb)
{
	TCB *t1;	
	long task, pointer;
	
	if((* tcb)->numargs NE 2) return(FALSE);

	switch(checkArg((* tcb)->args[2],&pointer))
	{
		case VART:
			if((* tcb)->prevTask EQ NULL) return(FALSE);		/* WAIT */

			t1 = (* tcb)->invoker;
			(* tcb)->invoker = NULL;
			t1->invokee = NULL;

			SaveRegisters((*tcb));	/* Save the tasks registers */
			LoadRegisters(t1);		/* Load the registers of the sending task */
			*tcb = t1;			/* Switch tasks */
			return(TRUE);
		case INTT:
			switch(checkArg((* tcb)->args[1],&task))
			{
				case INTT:
					t1 = (TCB *)task;
					validID(t1);
					break;
				case SYMBOLT:
					if ((t1 = findTaskID(nameof(task))) EQ NULL) return(FALSE);
					break;
				default:
					return(FALSE);
			}
			if(pointer LE 0)					/* INITIATE */
			{
				SaveRegisters((*tcb));
				BNRPflags.l = 0;
				*tcb = t1;
				return(TRUE);
			}
			else							/* SEND */
			{
				if (t1->invoker NE NULL) return(FALSE);		/* Can't send to an active task */
				if (t1 EQ *tcb) return(FALSE);			/* Can't send to yourself */
				if (t1->prevTask EQ NULL) return(FALSE);	/* Can't send to the main task */

				(* tcb)->invokee = t1;
				t1->invoker = *tcb;

				unify(t1,t1->args[2],makeint(&t1->hp,pointer));	/* Give the receiver the message pointer */

				SaveRegisters((*tcb));			/* Save the sender's registers */
				LoadRegisters(t1);				/* Load the registers of the waiting task */
				*tcb = t1;					/* Switch tasks */
				return(TRUE);
			}
		default:
			return(FALSE);
	}
	return(TRUE);
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_reply(TCB * tcb)	/*Aknowledge a received message*/
{
	TCB *task;

	if (((task = tcb->invoker) EQ NULL) || (tcb->numargs NE 0))
		return(FALSE);

	task->invokee = NULL;
	return(TRUE);
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_self(TCB *tcb)
{
	long name;

	if (tcb->numargs NE 1) return(FALSE);
	switch(checkArg(tcb->args[1],&name))
	{
		case INTT:
			return(unify(tcb,tcb->args[1],makeint(&tcb->hp,(long)tcb)));
		case SYMBOLT:
			return(unify(tcb,tcb->args[1],tcb->taskName));
		case VART:
			if (tcb->taskName NE BNRP_defaultTaskName)
			{
				return(unify(tcb,tcb->args[1],tcb->taskName));
			}
			else return(unify(tcb,tcb->args[1],makeint(&tcb->hp,(long)tcb)));
		default:
			return(FALSE);
	} 
}
#endif

#ifdef ring5
BNRP_Boolean BNRP_task_status(TCB *tcb)
{
	TCB * th;
	long task;
	BNRP_Boolean a,b,c,d;

	if (tcb->numargs NE 5) return(FALSE);
	if (checkArg(tcb->args[1],&task) NE INTT) return(FALSE);
	th = (TCB *)task;

	a = unify(tcb,tcb->args[2],makeint(&tcb->hp,(long)th->invoker));
	b = unify(tcb,tcb->args[3],makeint(&tcb->hp,(long)th->invokee));
	c = unify(tcb,tcb->args[4],makeint(&tcb->hp,(long)NULL));

	if(th->taskName EQ BNRP_defaultTaskName)
	{
		d = unify(tcb,tcb->args[5],makeint(&tcb->hp,(long)NULL));
	}
	else
	{
		d = unify(tcb,tcb->args[5],th->taskName);
	}
	return(a && b && c && d);
}
#endif








