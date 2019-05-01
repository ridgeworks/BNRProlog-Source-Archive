/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/common_subex.c,v 1.1 1995/09/22 11:23:11 harrisja Exp $
*
*  $Log: common_subex.c,v $
 * Revision 1.1  1995/09/22  11:23:11  harrisja
 * Initial version.
 *
*
*/
/*Find and return common sub-expression.  Given a term, determine if it has been seen before.  If it has
then unify it's value to the variable*/

#include <stdio.h>
#include "base.h"
#include "core.h"
#include "common_subex.h"
#include "utility.h"

#define trail(te, addr)   rpush(long, te, *(long *)addr); \
                          rpush(long, te, (long)addr);

#define simplebind(val, newval){ \
                                long _addr = addrof(val); \
                                trail(tcb->te, _addr); \
				*(long *)_addr = (long)newval;\
				}

#define nextArg(p, x)		while (tagof(x = *p) EQ TVTAG) { \
					long _a = addrof(x); \
					if ((long)p EQ _a) break; \
					p = (long *)_a; \
					} \
				++p; \
				while (isVAR(x)) { \
					long _tt = derefVAR(x); \
					if (x EQ _tt) break; \
					x = _tt; \
					}

#define compareSimple(p, ap)	if((tagof(p) EQ INTTAG) && (tagof(ap) EQ INTTAG))\
				{ \
					li tt, att; \
					tt.l = p; \
					att.l = ap;\
					if(tt.i.b NE att.i.b) return(FALSE);\
				} \
				else if ((tagof(p) EQ STRUCTTAG) && (tagof(ap) EQ STRUCTTAG)) \
				{ \
					long *tt = (long *)addrof(p); \
					long *att = (long *)addrof(ap); \
					li t1; \
					li at1;\
					t1.l = *tt++; \
					at1.l = *att++; \
					if ((t1.i.a EQ NUMBERIDshort) && (at1.i.a EQ NUMBERIDshort)) \
						if ((t1.i.b EQ INTIDshort) && (at1.i.b EQ INTIDshort)) \
						{\
							if((fp)*tt NE (fp)*att) return(FALSE);\
						}\
						else if(t1.i.b EQ at1.i.b)\
						{ \
							fpLWA(tt); \
							fpLWA(att);\
							if(*(fp *)tt NE *(fp *)att) return(FALSE);\
						} \
						else return(FALSE);\
					else return(FALSE); \
				} \
				else return(FALSE);

#define getConstraintList(x,y)	if (tagof(x ## var) EQ VARTAG)\
				{/*Move through the structure to get the constraints.  See interval.c for description of the structure*/\
					long s1, *t = (long *)addrof(x ## var);\
					if (t[1] NE CONSTRAINTMARK) return(FALSE);\
					s1 = t[2];\
					if(tagof(s1) EQ LISTTAG)\
					{\
						s1 = *(long *)addrof(s1);\
					}\
					if(tagof(s1) NE STRUCTTAG) return(FALSE);\
					t = (long *)addrof(s1);\
					t++;\
					nextArg(t,s1);\
					nextArg(t,s1);\
					nextArg(t,x ## constraints);\
				}\
				else if (tagof(y ## var) EQ VARTAG)\
				{/*Move through the structure to get the constraints.  See interval.c for description of the structure*/\
					long s1, *t = (long *)addrof(y ## var);\
					if (t[1] NE CONSTRAINTMARK) return(FALSE);\
					s1 = t[2];\
					if(tagof(s1) EQ LISTTAG)\
					{\
						s1 = *(long *)addrof(s1);\
					}\
					if(tagof(s1) NE STRUCTTAG) return(FALSE);\
					t = (long *)addrof(s1);\
					t++;\
					nextArg(t,s1);\
					nextArg(t,s1);\
					nextArg(t,y ## constraints);\
					x ## constraints = 0; /* was not in JR's version */\
				}\
				else return(FALSE);

#define searchList(x,y)	if(tagof(x ## constraints) EQ LISTTAG)\
			{\
				constraint = (long *)addrof(x ## constraints);\
			}\
			else if (tagof(y ## constraints) EQ LISTTAG)\
			{\
				constraint = (long *)addrof(y ## constraints);\
			}\
			else return(FALSE);\
			{\
				while(1)\
				{\
					long tt, *t;\
					nextArg(constraint,tt);\
					if(tagof(tt) NE STRUCTTAG) break;\
					t = (long *)addrof(tt);\
					t++;\
					nextArg(t,afunctor);\
					if(afunctor EQ functor)  /*Found a subexpression with the same functor*/\
					{\
						nextArg(t,azvar);\
						nextArg(t,axvar);\
						nextArg(t,ayvar);\
					/*	printf("\nLooking at node with FUNCTOR: %x   ZVAR: %x   XVAR: %x    YVAR: %x\n",afunctor,azvar,axvar,ayvar);*/\
						switch(number)\
						{\
							case 1: /*Bind z*/\
								if((tagof(xvar) EQ SYMBOLTAG)||(tagof(xvar) EQ VARTAG))\
									{if(xvar NE axvar) return(FALSE);}\
								else compareSimple(xvar, axvar);\
								if((tagof(yvar) EQ SYMBOLTAG)||(tagof(yvar) EQ VARTAG))\
									{if(yvar NE ayvar) return(FALSE);}\
								else compareSimple(yvar, ayvar);\
								simplebind(zvar,azvar);\
								return(TRUE);\
							case 2: /*Bind x*/\
								if((tagof(zvar) EQ SYMBOLTAG)||(tagof(zvar) EQ VARTAG))\
									{if(zvar NE azvar) return(FALSE);}\
								else compareSimple(zvar, azvar);\
								if((tagof(yvar) EQ SYMBOLTAG)||(tagof(yvar) EQ VARTAG))\
									{if(yvar NE ayvar) return(FALSE);}\
								else compareSimple(yvar, ayvar);\
								simplebind(xvar, axvar);\
								return(TRUE);\
							case 3:/*Bind y*/\
								if((tagof(zvar) EQ SYMBOLTAG)||(tagof(zvar) EQ VARTAG))\
									{if(zvar NE azvar) return(FALSE);}\
								else compareSimple(zvar, azvar);\
								if((tagof(xvar) EQ SYMBOLTAG)||(tagof(xvar) EQ VARTAG))\
									{if(xvar NE axvar) return(FALSE);}\
								else compareSimple(xvar, axvar);\
								simplebind(yvar, ayvar);\
								return(TRUE);\
							default:\
								return(FALSE);\
						}\
					}\
				}\
			}

BNRP_Boolean BNRP_findCommonSubex(TCB * tcb)
{
	long xvar, yvar, zvar, xconstraints, yconstraints, zconstraints, functor;
	long axvar, ayvar, azvar, afunctor, node, number, * constraint;

/*
	xvar, yvar, zvar  -> x, y, and z variables
	xconstraints, yconstraints, zconstraints  -> constraint lists of structures that use xvar, yvar, and zvar
	functor -> The name of the action involving xvar, yvar, and zvar.

	node -> a structure to look for in the constraint lists
	number -> an integer from 1 to 3 representing which variable to bind
	constraint -> which constraint list will be searched for 'node'.

	axvar, ayvar, azvar -> x, y and z variables from a structure in a constraint list
	afunctor -> name of the action using axvar, ayvar, and azvar
*/

	if (tcb->numargs NE 2) return(FALSE);
	if (checkArg(tcb->args[1],&node) NE STRUCTT) return(FALSE);
	if (checkArg(tcb->args[2],&number) NE INTT) return(FALSE);

	{
		long * pointer = (long *)node;
		++pointer;		/*Get the functor and the variables*/
		nextArg(pointer,functor);
		nextArg(pointer,zvar);
		nextArg(pointer,xvar);
		nextArg(pointer,yvar);
	}
	
/*	printf("\nSearching for node with FUNCTOR: %x   ZVAR: %x   XVAR: %x    YVAR: %x\n",functor,zvar,xvar,yvar);*/

	
	switch(number)
	{
		case 1:		/*Search the constraint lists for x and y looking to bind z*/
			getConstraintList(x,y);
			searchList(x,y);
			return(FALSE);
		case 2:		/*Search the constraint lists for z and y looking to bind x*/
			getConstraintList(z,y);
			searchList(z,y);
			return(FALSE);
		case 3:		/*Search the constraint lists for z and x looking to bind y*/
			getConstraintList(z,x);
			searchList(z,x);
			return(FALSE);
		default:
			return(FALSE);
	}
}


