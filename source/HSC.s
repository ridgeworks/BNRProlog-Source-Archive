#
#  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/HSC.s,v 1.1 1997/12/22 17:01:07 harrisj Exp $
#
#  $Log: HSC.s,v $
# Revision 1.1  1997/12/22  17:01:07  harrisj
# Added support for HSC and to build HSC and non-HSC BNRP
#
#
#

include(HSCmacros.incl)
include(HSCheadMacros.incl)
include(HSCheadWriteMacros.incl)
include(HSCbodyMacros.incl)
include(HSCbodyEscMacros.incl)
include(HSCbodyEscClMacros.incl)
#include(HSCdebugMacros.incl)

.set r0,0; .set SP,1; .set RTOC,2; .set r3,3; .set r4,4
.set r5,5; .set r6,6; .set r7,7; .set r8,8; .set r9,9
.set r10,10; .set r11,11; .set r12,12; .set r13,13; .set r14,14
.set r15,15; .set r16,16; .set r17,17; .set r18,18; .set r19,19
.set r20,20; .set r21,21; .set r22,22; .set r23,23; .set r24,24
.set r25,25; .set r26,26; .set r27,27; .set r28,28; .set r29,29
.set r30,30; .set r31,31
.set fp0,0; .set fp1,1; .set fp2,2; .set fp3,3; .set fp4,4
.set fp5,5; .set fp6,6; .set fp7,7; .set fp8,8; .set fp9,9
.set fp10,10; .set fp11,11; .set fp12,12; .set fp13,13; .set fp14,14
.set fp15,15; .set fp16,16; .set fp17,17; .set fp18,18; .set fp19,19
.set fp20,20; .set fp21,21; .set fp22,22; .set fp23,23; .set fp24,24
.set fp25,25; .set fp26,26; .set fp27,27; .set fp28,28; .set fp29,29
.set fp30,30; .set fp31,31
.set MQ,0; .set XER,1; .set FROM_RTCU,4; .set FROM_RTCL,5; .set FROM_DEC,6
.set LR,8; .set CTR,9; .set TID,17; .set DSISR,18; .set DAR,19; .set TO_RTCU,20
.set TO_RTCL,21; .set TO_DEC,22; .set SDR_0,24; .set SDR_1,25; .set SRR_0,26
.set SRR_1,27
.set BO_dCTR_NZERO_AND_NOT,0; .set BO_dCTR_NZERO_AND_NOT_1,1
.set BO_dCTR_ZERO_AND_NOT,2; .set BO_dCTR_ZERO_AND_NOT_1,3
.set BO_IF_NOT,4; .set BO_IF_NOT_1,5; .set BO_IF_NOT_2,6
.set BO_IF_NOT_3,7; .set BO_dCTR_NZERO_AND,8; .set BO_dCTR_NZERO_AND_1,9
.set BO_dCTR_ZERO_AND,10; .set BO_dCTR_ZERO_AND_1,11; .set BO_IF,12
.set BO_IF_1,13; .set BO_IF_2,14; .set BO_IF_3,15; .set BO_dCTR_NZERO,16
.set BO_dCTR_NZERO_1,17; .set BO_dCTR_ZERO,18; .set BO_dCTR_ZERO_1,19
.set BO_ALWAYS,20; .set BO_ALWAYS_1,21; .set BO_ALWAYS_2,22
.set BO_ALWAYS_3,23; .set BO_dCTR_NZERO_8,24; .set BO_dCTR_NZERO_9,25
.set BO_dCTR_ZERO_8,26; .set BO_dCTR_ZERO_9,27; .set BO_ALWAYS_8,28
.set BO_ALWAYS_9,29; .set BO_ALWAYS_10,30; .set BO_ALWAYS_11,31
.set CR0_LT,0; .set CR0_GT,1; .set CR0_EQ,2; .set CR0_SO,3
.set CR1_FX,4; .set CR1_FEX,5; .set CR1_VX,6; .set CR1_OX,7
.set CR2_LT,8; .set CR2_GT,9; .set CR2_EQ,10; .set CR2_SO,11
.set CR3_LT,12; .set CR3_GT,13; .set CR3_EQ,14; .set CR3_SO,15
.set CR4_LT,16; .set CR4_GT,17; .set CR4_EQ,18; .set CR4_SO,19
.set CR5_LT,20; .set CR5_GT,21; .set CR5_EQ,22; .set CR5_SO,23
.set CR6_LT,24; .set CR6_GT,25; .set CR6_EQ,26; .set CR6_SO,27
.set CR7_LT,28; .set CR7_GT,29; .set CR7_EQ,30; .set CR7_SO,31
.set TO_LT,16; .set TO_GT,8; .set TO_EQ,4; .set TO_LLT,2; .set TO_LGT,1
.set ppc,13; .set temp,14; .set ce,15; .set hp,16; .set stp,17
.set bh,18; .set be,19; .set te,20; .set lcp,21; .set cp,22
.set sp,23 	# Should sp go here?
.set WAMTable,24; .set arg7,25; .set arg6,26; .set arg5,27
.set arg4,28; .set arg3,29; .set arg2,30; .set arg1,31

	.rename	CORE{PR},""
	.rename	H.26.BNRP_quit{TC},"BNRP_quit"
	.rename	H.30.BNRP_RESUME{TC},"BNRP_RESUME"
	.rename	H.34.BNRP_error{TC},"BNRP_error"
	.rename BNRPerrorhandler{TC},"BNRPerrorhandler"
	.rename cutAtom{TC},"cutAtom"
	.rename cutcutAtom{TC},"cutcutAtom"
	.rename cutFailAtom{TC},"cutFailAtom"
	.rename isAtom{TC},"isAtom"
	.rename recoveryUnitAtom{TC},"recoveryUnitAtom"
	.rename plusAtom{TC},"plusAtom"
	.rename minusAtom{TC},"minusAtom"
	.rename starAtom{TC},"starAtom"
	.rename slashAtom{TC},"slashAtom"
	.rename slashslashAtom{TC},"slashslashAtom"
	.rename modAtom{TC},"modAtom"
	.rename starstarAtom{TC},"starstarAtom"
	.rename intAtom{TC},"intAtom"
	.rename floatAtom{TC},"floatAtom"
	.rename floorAtom{TC},"floorAtom"
	.rename ceilAtom{TC},"ceilAtom"
	.rename roundAtom{TC},"roundAtom"
	.rename maxAtom{TC},"maxAtom"
	.rename minAtom{TC},"minAtom"
	.rename sqrtAtom{TC},"sqrtAtom"
	.rename absAtom{TC},"absAtom"
	.rename expAtom{TC},"expAtom"
	.rename lnAtom{TC},"lnAtom"
	.rename sinAtom{TC},"sinAtom"
	.rename cosAtom{TC},"cosAtom"
	.rename tanAtom{TC},"tanAtom"
	.rename asinAtom{TC},"asinAtom"
	.rename acosAtom{TC},"acosAtom"
	.rename atanAtom{TC},"atanAtom"
	.rename maxintAtom{TC},"maxintAtom"
	.rename maxfloatAtom{TC},"maxfloatAtom"
	.rename piAtom{TC},"piAtom"
	.rename cputimeAtom{TC},"cputimeAtom"
	.rename butnotAtom{TC},"butnotAtom"
	.rename bitshiftAtom{TC},"bitshiftAtom"
	.rename bitandAtom{TC},"bitandAtom"
	.rename bitorAtom{TC},"bitorAtom"
	.rename biteqAtom{TC},"biteqAtom"
	.rename boolnotAtom{TC},"boolnotAtom"
	.rename boolandAtom{TC},"boolandAtom"
	.rename boolorAtom{TC},"boolorAtom"
	.rename boolxorAtom{TC},"boolxorAtom"
	.rename eqAtom{TC},"eqAtom"
	.rename neAtom{TC},"neAtom"
	.rename ltAtom{TC},"ltAtom"
	.rename gtAtom{TC},"gtAtom"
	.rename geAtom{TC},"geAtom"
	.rename leAtom{TC},"leAtom"
	.rename clauseAtom{TC},"clauseAtom"
	.rename failAtom{TC},"failAtom"
	.rename varAtom{TC},"varAtom"
	.rename tailvarAtom{TC},"tailvarAtom"
	.rename BNRP_filterNames{TC},"BNRP_filterNames"
	.rename attentionAtom{TC},"attentionAtom"
	.rename ifAtom{TC},"ifAtom"
	.rename indirectAtom{TC},"indirectAtom"
	.rename tracerAtom{TC},"tracerAtom"
	.rename tickAtom{TC},"tickAtom"
	.rename ssAtom{TC},"ssAtom"
	.rename evalConstrainedAtom{TC},"evalConstrainedAtom"
	.rename BNRP_combineVarAtom{TC},"BNRP_combineVarAtom"
	.rename BNRP_taskswitch_primitive{TC},"BNRP_taskswitch_primitive"
	.rename BNRP_gcFlag{TC},"BNRP_gcFlag"
	.rename BNRPflags{TC},"BNRPflags"
	.rename BNRPprimitiveCalls{TC},"BNRPprimitiveCalls"
	.rename inClause{TC},"inClause"
	.rename clauseList{TC},"clauseList"
	.rename headCount{TC},"headCount"
	.rename bodyCounter{TC},"bodyCounter"
	.rename escapeCount{TC},"escapeCount"
	DEBUG_RENAMES

	.lglobl	CORE{PR}
	.globl	.BNRP_quit
	.globl	.BNRP_RESUME
	.globl	.BNRP_error
	.lglobl	H.22.NO_SYMBOL{RO}
	.globl	BNRP_quit{DS}
	.globl	BNRP_RESUME{DS}
	.globl	BNRP_error{DS}
	.extern	.printf{PR}
	.extern ._restf20{PR}
	.extern ._savef20{PR}
	.extern .pow{PR}
	.extern .sqrt{PR}
	.extern .exp{PR}
	.extern .log{PR}
	.extern .sin{PR}
	.extern .cos{PR}
	.extern .tan{PR}
	.extern .asin{PR}
	.extern .acos{PR}
	.extern .atan{PR}
	.extern .malloc{PR}
	.extern .realloc{PR}
	.extern	.BNRP_errorTraceback{PR}
	.extern .BNRP_removeTaskFromChain{PR}
	.extern	.BNRP_lookupStateSpace{PR}
	.extern .BNRP_gc_proceed{PR}
	.extern .BNRP_getMaxFP{PR}
	.extern .getCPUTime{PR}
	.extern BNRPerrorhandler{UA}
	.extern cutAtom{UA}
	.extern cutcutAtom{UA}
	.extern cutFailAtom{UA}
	.extern isAtom{UA}
	.extern recoveryUnitAtom{UA}
	.extern plusAtom{UA}
	.extern minusAtom{UA}
	.extern starAtom{UA}
	.extern slashAtom{UA}
	.extern slashslashAtom{UA}
	.extern modAtom{UA}
	.extern starstarAtom{UA}
	.extern intAtom{UA}
	.extern floatAtom{UA}
	.extern floorAtom{UA}
	.extern ceilAtom{UA}
	.extern roundAtom{UA}
	.extern maxAtom{UA}
	.extern minAtom{UA}
	.extern sqrtAtom{UA}
	.extern absAtom{UA}
	.extern expAtom{UA}
	.extern lnAtom{UA}
	.extern sinAtom{UA}
	.extern cosAtom{UA}
	.extern tanAtom{UA}
	.extern asinAtom{UA}
	.extern acosAtom{UA}
	.extern atanAtom{UA}
	.extern maxintAtom{UA}
	.extern maxfloatAtom{UA}
	.extern piAtom{UA}
	.extern cputimeAtom{UA}
	.extern butnotAtom{UA}
	.extern bitshiftAtom{UA}
	.extern bitandAtom{UA}
	.extern bitorAtom{UA}
	.extern biteqAtom{UA}
	.extern boolnotAtom{UA}
	.extern boolandAtom{UA}
	.extern boolorAtom{UA}
	.extern boolxorAtom{UA}
	.extern eqAtom{UA}
	.extern neAtom{UA}
	.extern ltAtom{UA}
	.extern gtAtom{UA}
	.extern geAtom{UA}
	.extern leAtom{UA}
	.extern clauseAtom{UA}
	.extern failAtom{UA}
	.extern varAtom{UA}
	.extern tailvarAtom{UA}
	.extern BNRP_filterNames{UA}
	.extern attentionAtom{UA}
	.extern ifAtom{UA}
	.extern indirectAtom{UA}
	.extern tracerAtom{UA}
	.extern tickAtom{UA}
	.extern ssAtom{UA}
	.extern evalConstrainedAtom{UA}
	.extern BNRP_combineVarAtom{UA}
	.extern BNRP_taskswitch_primitive{UA}
	.extern BNRP_gcFlag{UA}
	.extern BNRPflags{UA}
	.extern BNRPprimitiveCalls{UA}
	.extern inClause{UA}
	.extern clauseList{UA}
	.extern headCount{UA}
	.extern bodyCounter{UA}
	.extern escapeCount{UA}
	DEBUG_EXTERNS
# .text section
	.file	"t.c"                   


	.csect	CORE{PR}      
.BNRP_quit:                     # 0x00000000 (H.10.NO_SYMBOL)
   lwz		r4,124(r3)			# load tcb->args[0]
   cmpwi		0,r4,0			# see if nArgs is zero
   bne		Return_False
   lwz		r12,erroraddr(RTOC)	# load in address of erroraddr
   mr		temp,r3			    # load TCB pointer
   lwz		SP,0(r12)			# get erroraddr value. erroraddr is start of BNRP_RESUME stack
   li		r4,0				# put zero into r4
   sth		r4,70(temp)			# save into ppsw		
   addic	SP,SP,800			# remove BNRP_RESUME() stack
   lmw		r13,-140(SP)		# restore GPR13-31
   bl		._restf20{PR}		# restore FPR's
   nop
   lwz		r10,4(SP)			# get CR from stack
   mtcr		r10					# restore CR
   lwz		r10,8(SP)			# get LR from stack
   mtspr	LR,r10				# restore LR
   li		r3,0				# get error code from tcb->ppsw and place in r3
   bclr		BO_ALWAYS,CR0_LT	# Return
Return_False:
   li		r3,0				# Put zero into return register
   bclr		BO_ALWAYS,CR0_LT	# Return
   .long	0x00000000  
  .byte		0x00
  .byte		0x00
  .byte		0x20
  .byte		0x43
  .byte		0x80
  .byte		0x00
  .byte		0x01
  .byte		0x00
  .long		0x00000000
  .long		0x00000060
  .short	9
  .byte		"BNRP_quit"
  .byte		0x00
# End of traceback table
.BNRP_RESUME:               # 0x00000048 (H.10.NO_SYMBOL+0x48)
   mflr		r0				# load LR
   mfcr		r12				# load CR
   stw		r12, 4(SP)		# store CR into stack
   stw		r0, 8(SP)		# store LR into stack
   bl		._savef20{PR}	# store FPR13-31
   nop
   stmw		r13,-140(SP)	# store GPR13-31
   stwu		SP, -800(SP)	# store SP backpointer into my stack and update SP
   mr		temp,r3 		# place TCB into temp
   stw		temp,56(SP)		# place TCB into stack
   # End Prologue
   LOADREGS					# load TCB registers		
   lwz		WAMTable,HeadReadTableTC(RTOC)		# load proper opcode table
   lwz		sp,56(temp)		# get spbase from tcb
#   li		r3,400			# allocate 400 bytes for pdl
#   bl		.malloc{PR}
#   nop
#   mr		sp,r3			# copy to sp
#   stw		r3,56(temp)		# start of pdl
#   addi		sp,r3,8			# leave 2 spaces for long->float conversion constants
#   addi		r3,r3,400		# calculate end of pdl
#   stw		r3,60(temp)		# end of pdl
   lwz		r12,erroraddr(RTOC)	# load erroraddr address
   stw		SP,0(r12)		# save current stack pointer
   lis		r3,0x5980		# top half of single precision float used in fp conversions
   addi		r3,r3,4			# bottom half
   stw		r3,108(SP)
   lfs		fp31,108(SP)		# store in fp31 (converts to a double precision)
   lis		r3,0x4330		# long->float conversion mask
   stw		r3,108(SP)		# store below stack
   b		GetTable
StartHead:
   cmpwi	r3,-1
   beq		AdjustArity
HeadCheck:
   addi		r10,hp,1024
   cmpw		te,r10
   bgt		Head
   b		H_full
AdjustArity:
   FIX_ARITIES
   cmpwi	r12,0		# NEW
   bgt		HeadCheck
   b		Fail
# START HEAD OPCODES
   HEAD_UTILS
   HEAD_WRITE_UTILS
   NECK_UTILS
neck:
   NECK
Runify_void:
   RUNIFY_VOID
Rend_seq:
   REND_SEQ
Runif_cons:
   RUNIFY_CONS
neckcon:
   NECKCON
gcchpt:
   li		r11,-1					# FFFFFFFF indicates dummy cp
   li		r5,4					# env/cp stack check
   subf		r5,r5,lcp
   subi		r5,r5,CHPT
   cmpw		r5,ce
   ble		E_full
   mr		r10,lcp					# store lcp value
   stwu		r11,-4(lcp)				# push arity into dummy cp
   lwz		r12,120(temp)
   stwu		r12,-4(lcp)				# push procname into dummy cp
   stwu		cp,-4(lcp)				# push cp into dummy cp
   stwu		ce,-4(lcp)				# push ce into dummy cp
   stwu		te,-4(lcp)				# push te into dummy cp
   stwu		r10,-4(lcp)				# push lcp into dummy cp
   stwu		hp,-4(lcp)				# push hp into dummy cp
   mr		bh,hp					# update critical heap
   cmpw		ce,be
   blt		gccNoCrit
   lbz		r12,0(cp)				# get save byte from caller
   addi		r12,r12,1
   rlwinm	r12,r12,2,22,31				# multiply by 4
   add		be,ce,r12				# update new critical env
gccNoCrit:
   stwu		be,-4(lcp)				# store critical env in dummy cp
   stwu		r11,-4(lcp)				# key is -1 for dummy cp
   li		r11,0
   stwu		r11,-4(lcp)				# 0 clause pointer for dummy cp
   stw		lcp,80(temp)				# update cutb to be dummy cp
   b		alloc
gcalloc:
#   b		CallingBNRP
   lwz		r12,BNRP_gcFlagTC(RTOC)			# load address of BNRP_gcFlag
   lwz		r12,0(r12)				# get BNRP_gcFlag value
   cmpwi	r12,0					# if zero then dummy not needed
   beq		alloc
   lwz		r12,80(temp)				# get cutb
   cmpw		lcp,r12					# if NE then no dummy cp
   bne		alloc
   lwz		r11,24(lcp)				# get env from lcp
   cmpw		r11,ce					# if not same env then insert dummy cp
   bne		gcchpt
   lwz		r11,28(lcp)				# load cp from lcp
   cmpw		r11,cp					# if not same then insert dummy
   bne		gcchpt
alloc:
#   b		CallingBNRP
   ALLOC
   cmpw		ce,lcp
   bge		E_full
   b		InterpreterLoop
Runify_nil:
   RUNIFY_NIL
get_cons0:
   GET_CONS_TCB
get_cons1:
   GET_CONS(arg1)
get_cons2:
   GET_CONS(arg2)
get_cons3:
   GET_CONS(arg3)
get_cons4:
   GET_CONS(arg4)
get_cons5:
   GET_CONS(arg5)
get_cons6:
   GET_CONS(arg6)
get_cons7:
   GET_CONS(arg7)
get_struct0:
   GET_STRUCT_TCB
get_struct1:
   GET_STRUCT(arg1)
get_struct2:
   GET_STRUCT(arg2)
get_struct3:
   GET_STRUCT(arg3)
get_struct4:
   GET_STRUCT(arg4)
get_struct5:
   GET_STRUCT(arg5)
get_struct6:
   GET_STRUCT(arg6)
get_struct7:
   GET_STRUCT(arg7)
get_list0:
   GET_LIST_TCB
get_list1:
   GET_LIST(arg1)
get_list2:
   GET_LIST(arg2)
get_list3:
   GET_LIST(arg3)
get_list4:
   GET_LIST(arg4)
get_list5:
   GET_LIST(arg5)
get_list6:
   GET_LIST(arg6)
get_list7:
   GET_LIST(arg7)
get_nil0:
   GET_NIL_TCB
get_nil1:
   GET_NIL(arg1)
get_nil2:
   GET_NIL(arg2)
get_nil3:
   GET_NIL(arg3)
get_nil4:
   GET_NIL(arg4)
get_nil5:
   GET_NIL(arg5)
get_nil6:
   GET_NIL(arg6)
get_nil7:
   GET_NIL(arg7)
get_valt0:
   GET_VALT_TCB
get_valt1:
   GET_VALT(arg1)
get_valt2:
   GET_VALT(arg2)
get_valt3:
   GET_VALT(arg3)
get_valt4:
   GET_VALT(arg4)
get_valt5:
   GET_VALT(arg5)
get_valt6:
   GET_VALT(arg6)
get_valt7:
   GET_VALT(arg7)
get_valp0:
   GET_VALP_TCB
get_valp1:
   GET_VALP(arg1)
get_valp2:
   GET_VALP(arg2)
get_valp3:
   GET_VALP(arg3)
get_valp4:
   GET_VALP(arg4)
get_valp5:
   GET_VALP(arg5)
get_valp6:
   GET_VALP(arg6)
get_valp7:
   GET_VALP(arg7)
Runify_vart0:
   RUNIFY_VART_TCB
   b		HeadWrite
Runify_vart1:
   RUNIFY_VART(arg1)
   b		HeadWrite
Runify_vart2:
   RUNIFY_VART(arg2)
   b		HeadWrite
Runify_vart3:
   RUNIFY_VART(arg3)
   b		HeadWrite
Runify_vart4:
   RUNIFY_VART(arg4)
   b		HeadWrite
Runify_vart5:
   RUNIFY_VART(arg5)
   b		HeadWrite
Runify_vart6:
   RUNIFY_VART(arg6)
   b		HeadWrite
Runify_vart7:
   RUNIFY_VART(arg7)
   b		HeadWrite
Runify_varp0:
   RUNIFY_VARP_TCB
Runify_varp1:
   RUNIFY_VARP(1)
Runify_varp2:
   RUNIFY_VARP(2)
Runify_varp3:
   RUNIFY_VARP(3)
Runify_varp4:
   RUNIFY_VARP(4)
Runify_varp5:
   RUNIFY_VARP(5)
Runify_varp6:
   RUNIFY_VARP(6)
Runify_varp7:
   RUNIFY_VARP(7)
Runify_valt0:
   RUNIFY_VALT_TCB
Runify_valt1:
   RUNIFY_VALT(arg1)
Runify_valt2:
   RUNIFY_VALT(arg2)
Runify_valt3:
   RUNIFY_VALT(arg3)
Runify_valt4:
   RUNIFY_VALT(arg4)
Runify_valt5:
   RUNIFY_VALT(arg5)
Runify_valt6:
   RUNIFY_VALT(arg6)
Runify_valt7:
   RUNIFY_VALT(arg7)
Runify_valp0:
   RUNIFY_VALP_TCB
Runify_valp1:
   RUNIFY_VALP(1)
Runify_valp2:
   RUNIFY_VALP(2)
Runify_valp3:
   RUNIFY_VALP(3)
Runify_valp4:
   RUNIFY_VALP(4)
Runify_valp5:
   RUNIFY_VALP(5)
Runify_valp6:
   RUNIFY_VALP(6)
Runify_valp7:
   RUNIFY_VALP(7)
Rtunify_vart0:
   RTUNIFY_VART_TCB
Rtunify_vart1:
   RTUNIFY_VART(arg1)
Rtunify_vart2:
   RTUNIFY_VART(arg2)
Rtunify_vart3:
   RTUNIFY_VART(arg3)
Rtunify_vart4:
   RTUNIFY_VART(arg4)
Rtunify_vart5:
   RTUNIFY_VART(arg5)
Rtunify_vart6:
   RTUNIFY_VART(arg6)
Rtunify_vart7:
   RTUNIFY_VART(arg7)
Rtunify_varp0:
   RTUNIFY_VARP_TCB
Rtunify_varp1:
   li		r9,1
   RTUNIFY_VARP(r9)
Rtunify_varp2:
   li		r9,2
   RTUNIFY_VARP(r9)
Rtunify_varp3:
   li		r9,3
   RTUNIFY_VARP(r9)
Rtunify_varp4:
   li		r9,4
   RTUNIFY_VARP(r9)
Rtunify_varp5:
   li		r9,5
   RTUNIFY_VARP(r9)
Rtunify_varp6:
   li		r9,6
   RTUNIFY_VARP(r9)
Rtunify_varp7:
   li		r9,7
   RTUNIFY_VARP(r9)
Rtunify_valt0:
   RTUNIFY_VALT_TCB
Rtunify_valt1:
   RTUNIFY_VALT(arg1)
Rtunify_valt2:
   RTUNIFY_VALT(arg2)
Rtunify_valt3:
   RTUNIFY_VALT(arg3)
Rtunify_valt4:
   RTUNIFY_VALT(arg4)
Rtunify_valt5:
   RTUNIFY_VALT(arg5)
Rtunify_valt6:
   RTUNIFY_VALT(arg6)
Rtunify_valt7:
   RTUNIFY_VALT(arg7)
Rtunify_valp0:
   RTUNIFY_VALP_TCB
Rtunify_valp1:
   RTUNIFY_VALP(1)
Rtunify_valp2:
   RTUNIFY_VALP(2)
Rtunify_valp3:
   RTUNIFY_VALP(3)
Rtunify_valp4:
   RTUNIFY_VALP(4)
Rtunify_valp5:
   RTUNIFY_VALP(5)
Rtunify_valp6:
   RTUNIFY_VALP(6)
Rtunify_valp7:
   RTUNIFY_VALP(7)
unif_address:
   UNIFY_ADDRESS
get_cons_by_value:
   GET_CONS_BY_VALUE
   b		InterpreterLoop
Runif_cons_by_value:
   RUNIF_CONS_BY_VALUE
copy_valp:
   COPY_VALP
get_vart00:
   GET_VART_TCB
   b		InterpreterLoop
get_vart01:
   GET_VART_ARG1(arg1)
   b		InterpreterLoop
get_vart02:
   GET_VART_ARG1(arg2)
   b		InterpreterLoop
get_vart03:
   GET_VART_ARG1(arg3)
   b		InterpreterLoop
get_vart04:
   GET_VART_ARG1(arg4)
   b		InterpreterLoop
get_vart05:
   GET_VART_ARG1(arg5)
   b		InterpreterLoop
get_vart06:
   GET_VART_ARG1(arg6)
   b		InterpreterLoop
get_vart07:
   GET_VART_ARG1(arg7)
   b		InterpreterLoop
get_vart10:
   GET_VART_ARG2(arg1)
   b		InterpreterLoop
get_vart12:
   GET_VART(arg1,arg2)
   b		InterpreterLoop
get_vart13:
   GET_VART(arg1,arg3)
   b		InterpreterLoop
get_vart14:
   GET_VART(arg1,arg4)
   b		InterpreterLoop
get_vart15:
   GET_VART(arg1,arg5)
   b		InterpreterLoop
get_vart16:
   GET_VART(arg1,arg6)
   b		InterpreterLoop
get_vart17:
   GET_VART(arg1,arg7)
   b		InterpreterLoop
get_vart20:
   GET_VART_ARG2(arg2)
   b		InterpreterLoop
get_vart21:
   GET_VART(arg2,arg1)
   b		InterpreterLoop
get_vart23:
   GET_VART(arg2,arg3)
   b		InterpreterLoop
get_vart24:
   GET_VART(arg2,arg4)
   b		InterpreterLoop
get_vart25:
   GET_VART(arg2,arg5)
   b		InterpreterLoop
get_vart26:
   GET_VART(arg2,arg6)
   b		InterpreterLoop
get_vart27:
   GET_VART(arg2,arg7)
   b		InterpreterLoop
get_vart30:
   GET_VART_ARG2(arg3)
   b		InterpreterLoop
get_vart31:
   GET_VART(arg3,arg1)
   b		InterpreterLoop
get_vart32:
   GET_VART(arg3,arg2)
   b		InterpreterLoop
get_vart34:
   GET_VART(arg3,arg4)
   b		InterpreterLoop
get_vart35:
   GET_VART(arg3,arg5)
   b		InterpreterLoop
get_vart36:
   GET_VART(arg3,arg6)
   b		InterpreterLoop
get_vart37:
   GET_VART(arg3,arg7)
   b		InterpreterLoop
get_vart40:
   GET_VART_ARG2(arg4)
   b		InterpreterLoop
get_vart41:
   GET_VART(arg4,arg1)
   b		InterpreterLoop
get_vart42:
   GET_VART(arg4,arg2)
   b		InterpreterLoop
get_vart43:
   GET_VART(arg4,arg3)
   b		InterpreterLoop
get_vart45:
   GET_VART(arg4,arg5)
   b		InterpreterLoop
get_vart46:
   GET_VART(arg4,arg6)
   b		InterpreterLoop
get_vart47:
   GET_VART(arg4,arg7)
   b		InterpreterLoop
get_vart50:
   GET_VART_ARG2(arg5)
   b		InterpreterLoop
get_vart51:
   GET_VART(arg5,arg1)
   b		InterpreterLoop
get_vart52:
   GET_VART(arg5,arg2)
   b		InterpreterLoop
get_vart53:
   GET_VART(arg5,arg3)
   b		InterpreterLoop
get_vart54:
   GET_VART(arg5,arg4)
   b		InterpreterLoop
get_vart56:
   GET_VART(arg5,arg6)
   b		InterpreterLoop
get_vart57:
   GET_VART(arg5,arg7)
   b		InterpreterLoop
get_vart60:
   GET_VART_ARG2(arg6)
   b		InterpreterLoop
get_vart61:
   GET_VART(arg6,arg1)
   b		InterpreterLoop
get_vart62:
   GET_VART(arg6,arg2)
   b		InterpreterLoop
get_vart63:
   GET_VART(arg6,arg3)
   b		InterpreterLoop
get_vart64:
   GET_VART(arg6,arg4)
   b		InterpreterLoop
get_vart65:
   GET_VART(arg6,arg5)
   b		InterpreterLoop
get_vart67:
   GET_VART(arg6,arg7)
   b		InterpreterLoop
get_vart70:
   GET_VART_ARG2(arg7)
   b		InterpreterLoop
get_vart71:
   GET_VART(arg7,arg1)
   b		InterpreterLoop
get_vart72:
   GET_VART(arg7,arg2)
   b		InterpreterLoop
get_vart73:
   GET_VART(arg7,arg3)
   b		InterpreterLoop
get_vart74:
   GET_VART(arg7,arg4)
   b		InterpreterLoop
get_vart75:
   GET_VART(arg7,arg5)
   b		InterpreterLoop
get_vart76:
   GET_VART(arg7,arg6)
   b		InterpreterLoop
get_varp00:
   GET_VARP_TCB
   b		InterpreterLoop
get_varp01:
   li		r9,1
   GET_VARP_ARG1(r9)
   b		InterpreterLoop
get_varp02:
   li		r9,2
   GET_VARP_ARG1(r9)
   b		InterpreterLoop
get_varp03:
   li		r9,3
   GET_VARP_ARG1(r9)
   b		InterpreterLoop
get_varp04:
   li		r9,4
   GET_VARP_ARG1(r9)
   b		InterpreterLoop
get_varp05:
   li		r9,5
   GET_VARP_ARG1(r9)
   b		InterpreterLoop
get_varp06:
   li		r9,6
   GET_VARP_ARG1(r9)
   b		InterpreterLoop
get_varp07:
   li		r9,7
   GET_VARP_ARG1(r9)
   b		InterpreterLoop
get_varp10:
   GET_VARP_ARG2(arg1)
   b		InterpreterLoop
get_varp11:
   li		r9,1
   GET_VARP(r9,arg1)
   b		InterpreterLoop
get_varp12:
   li		r9,2
   GET_VARP(r9,arg1)
   b		InterpreterLoop
get_varp13:
   li		r9,3
   GET_VARP(r9,arg1)
   b		InterpreterLoop
get_varp14:
   li		r9,4
   GET_VARP(r9,arg1)
   b		InterpreterLoop
get_varp15:
   li		r9,5
   GET_VARP(r9,arg1)
   b		InterpreterLoop
get_varp16:
   li		r9,6
   GET_VARP(r9,arg1)
   b		InterpreterLoop
get_varp17:
   li		r9,7
   GET_VARP(r9,arg1)
   b		InterpreterLoop
get_varp20:
   GET_VARP_ARG2(arg2)
   b		InterpreterLoop
get_varp21:
   li		r9,1
   GET_VARP(r9,arg2)
   b		InterpreterLoop
get_varp22:
   li		r9,2
   GET_VARP(r9,arg2)
   b		InterpreterLoop
get_varp23:
   li		r9,3
   GET_VARP(r9,arg2)
   b		InterpreterLoop
get_varp24:
   li		r9,4
   GET_VARP(r9,arg2)
   b		InterpreterLoop
get_varp25:
   li		r9,5
   GET_VARP(r9,arg2)
   b		InterpreterLoop
get_varp26:
   li		r9,6
   GET_VARP(r9,arg2)
   b		InterpreterLoop
get_varp27:
   li		r9,7
   GET_VARP(r9,arg2)
   b		InterpreterLoop
get_varp30:
   GET_VARP_ARG2(arg3)
   b		InterpreterLoop
get_varp31:
   li		r9,1
   GET_VARP(r9,arg3)
   b		InterpreterLoop
get_varp32:
   li		r9,2
   GET_VARP(r9,arg3)
   b		InterpreterLoop
get_varp33:
   li		r9,3
   GET_VARP(r9,arg3)
   b		InterpreterLoop
get_varp34:
   li		r9,4
   GET_VARP(r9,arg3)
   b		InterpreterLoop
get_varp35:
   li		r9,5
   GET_VARP(r9,arg3)
   b		InterpreterLoop
get_varp36:
   li		r9,6
   GET_VARP(r9,arg3)
   b		InterpreterLoop
get_varp37:
   li		r9,7
   GET_VARP(r9,arg3)
   b		InterpreterLoop
get_varp40:
   GET_VARP_ARG2(arg4)
   b		InterpreterLoop
get_varp41:
   li		r9,1
   GET_VARP(r9,arg4)
   b		InterpreterLoop
get_varp42:
   li		r9,2
   GET_VARP(r9,arg4)
   b		InterpreterLoop
get_varp43:
   li		r9,3
   GET_VARP(r9,arg4)
   b		InterpreterLoop
get_varp44:
   li		r9,4
   GET_VARP(r9,arg4)
   b		InterpreterLoop
get_varp45:
   li		r9,5
   GET_VARP(r9,arg4)
   b		InterpreterLoop
get_varp46:
   li		r9,6
   GET_VARP(r9,arg4)
   b		InterpreterLoop
get_varp47:
   li		r9,7
   GET_VARP(r9,arg4)
   b		InterpreterLoop
get_varp50:
   GET_VARP_ARG2(arg5)
   b		InterpreterLoop
get_varp51:
   li		r9,1
   GET_VARP(r9,arg5)
   b		InterpreterLoop
get_varp52:
   li		r9,2
   GET_VARP(r9,arg5)
   b		InterpreterLoop
get_varp53:
   li		r9,3
   GET_VARP(r9,arg5)
   b		InterpreterLoop
get_varp54:
   li		r9,4
   GET_VARP(r9,arg5)
   b		InterpreterLoop
get_varp55:
   li		r9,5
   GET_VARP(r9,arg5)
   b		InterpreterLoop
get_varp56:
   li		r9,6
   GET_VARP(r9,arg5)
   b		InterpreterLoop
get_varp57:
   li		r9,7
   GET_VARP(r9,arg5)
   b		InterpreterLoop
get_varp60:
   GET_VARP_ARG2(arg6)
   b		InterpreterLoop
get_varp61:
   li		r9,1
   GET_VARP(r9,arg6)
   b		InterpreterLoop
get_varp62:
   li		r9,2
   GET_VARP(r9,arg6)
   b		InterpreterLoop
get_varp63:
   li		r9,3
   GET_VARP(r9,arg6)
   b		InterpreterLoop
get_varp64:
   li		r9,4
   GET_VARP(r9,arg6)
   b		InterpreterLoop
get_varp65:
   li		r9,5
   GET_VARP(r9,arg6)
   b		InterpreterLoop
get_varp66:
   li		r9,6
   GET_VARP(r9,arg6)
   b		InterpreterLoop
get_varp67:
   li		r9,7
   GET_VARP(r9,arg6)
   b		InterpreterLoop
get_varp70:
   GET_VARP_ARG2(arg7)
   b		InterpreterLoop
get_varp71:
   li		r9,1
   GET_VARP(r9,arg7)
   b		InterpreterLoop
get_varp72:
   li		r9,2
   GET_VARP(r9,arg7)
   b		InterpreterLoop
get_varp73:
   li		r9,3
   GET_VARP(r9,arg7)
   b		InterpreterLoop
get_varp74:
   li		r9,4
   GET_VARP(r9,arg7)
   b		InterpreterLoop
get_varp75:
   li		r9,5
   GET_VARP(r9,arg7)
   b		InterpreterLoop
get_varp76:
   li		r9,6
   GET_VARP(r9,arg7)
   b		InterpreterLoop
get_varp77:
   li		r9,7
   GET_VARP(r9,arg7)
   b		InterpreterLoop
# Head Write Table
Wunify_void:
   b		push_void
tunif_void:
   b		tpush_void
Wend_seq:
   WEND_SEQ
Wunif_cons:
   b		push_cons
Wunify_nil:
   WUNIFY_NIL
   b		InterpreterLoop
Wunify_vart0:
   PUSH_VART_TCB
   b		InterpreterLoop
Wunify_vart1:
   PUSH_VART(arg1)
   b		InterpreterLoop
Wunify_vart2:
   PUSH_VART(arg2)
   b		InterpreterLoop
Wunify_vart3:
   PUSH_VART(arg3)
   b		InterpreterLoop
Wunify_vart4:
   PUSH_VART(arg4)
   b		InterpreterLoop
Wunify_vart5:
   PUSH_VART(arg5)
   b		InterpreterLoop
Wunify_vart6:
   PUSH_VART(arg6)
   b		InterpreterLoop
Wunify_vart7:
   PUSH_VART(arg7)
   b		InterpreterLoop
Wunify_varp0:
   WUNIFY_VARP_TCB
   b		InterpreterLoop
Wunify_varp1:
   li		r9,1
   PUSH_VARP(r9)
Wunify_varp2:
   li		r9,2
   PUSH_VARP(r9)
Wunify_varp3:
   li		r9,3
   PUSH_VARP(r9)
Wunify_varp4:
   li		r9,4
   PUSH_VARP(r9)
Wunify_varp5:
   li		r9,5
   PUSH_VARP(r9)
Wunify_varp6:
   li		r9,6
   PUSH_VARP(r9)
Wunify_varp7:
   li		r9,7
   PUSH_VARP(r9)
Wunify_valt0:
   PUSH_VALT_TCB
   b		InterpreterLoop
Wunify_valt1:
   PUSH_VALT(arg1)
   b		InterpreterLoop
Wunify_valt2:
   PUSH_VALT(arg2)
   b		InterpreterLoop
Wunify_valt3:
   PUSH_VALT(arg3)
   b		InterpreterLoop
Wunify_valt4:
   PUSH_VALT(arg4)
   b		InterpreterLoop
Wunify_valt5:
   PUSH_VALT(arg5)
   b		InterpreterLoop
Wunify_valt6:
   PUSH_VALT(arg6)
   b		InterpreterLoop
Wunify_valt7:
   PUSH_VALT(arg7)
   b		InterpreterLoop
Wunify_valp0:
   WUNIFY_VALP_TCB
   b		InterpreterLoop
Wunify_valp1:
   li		r9,1
   PUSH_VALP(r9)
   b		InterpreterLoop
Wunify_valp2:
   li		r9,2
   PUSH_VALP(r9)
   b		InterpreterLoop
Wunify_valp3:
   li		r9,3
   PUSH_VALP(r9)
   b		InterpreterLoop
Wunify_valp4:
   li		r9,4
   PUSH_VALP(r9)
   b		InterpreterLoop
Wunify_valp5:
   li		r9,5
   PUSH_VALP(r9)
   b		InterpreterLoop
Wunify_valp6:
   li		r9,6
   PUSH_VALP(r9)
   b		InterpreterLoop
Wunify_valp7:
   li		r9,7
   PUSH_VALP(r9)
   b		InterpreterLoop
Wtunify_vart0:
   WTUNIFY_VART_TCB
Wtunify_vart1:
   WTUNIFY_VART(arg1)
Wtunify_vart2:
   WTUNIFY_VART(arg2)
Wtunify_vart3:
   WTUNIFY_VART(arg3)
Wtunify_vart4:
   WTUNIFY_VART(arg4)
Wtunify_vart5:
   WTUNIFY_VART(arg5)
Wtunify_vart6:
   WTUNIFY_VART(arg6)
Wtunify_vart7:
   WTUNIFY_VART(arg7)
Wtunify_varp0:
   WTUNIFY_VARP_TCB
Wtunify_varp1:
   li		r9,1
   WTUNIFY_VARP(r9)
Wtunify_varp2:
   li		r9,2
   WTUNIFY_VARP(r9)
Wtunify_varp3:
   li		r9,3
   WTUNIFY_VARP(r9)
Wtunify_varp4:
   li		r9,4
   WTUNIFY_VARP(r9)
Wtunify_varp5:
   li		r9,5
   WTUNIFY_VARP(r9)
Wtunify_varp6:
   li		r9,6
   WTUNIFY_VARP(r9)
Wtunify_varp7:
   li		r9,7
   WTUNIFY_VARP(r9)
Wtunify_valt0:
   WTUNIFY_VALT_TCB
Wtunify_valt1:
   WTUNIFY_VALT(arg1)
Wtunify_valt2:
   WTUNIFY_VALT(arg2)
Wtunify_valt3:
   WTUNIFY_VALT(arg3)
Wtunify_valt4:
   WTUNIFY_VALT(arg4)
Wtunify_valt5:
   WTUNIFY_VALT(arg5)
Wtunify_valt6:
   WTUNIFY_VALT(arg6)
Wtunify_valt7:
   WTUNIFY_VALT(arg7)
Wtunify_valp0:
   WTUNIFY_VALP_TCB
Wtunify_valp1:
   li		r9,1
   WTUNIFY_VALP(r9)
Wtunify_valp2:
   li		r9,2
   WTUNIFY_VALP(r9)
Wtunify_valp3:
   li		r9,3
   WTUNIFY_VALP(r9)
Wtunify_valp4:
   li		r9,4
   WTUNIFY_VALP(r9)
Wtunify_valp5:
   li		r9,5
   WTUNIFY_VALP(r9)
Wtunify_valp6:
   li		r9,6
   WTUNIFY_VALP(r9)
Wtunify_valp7:
   li		r9,7
   WTUNIFY_VALP(r9)
Wunif_cons_by_value:
   WUNIFY_CONS_BY_VALUE
   b		InterpreterLoop
# Body Table
proceed:
   PROCEED
   b		InterpreterLoop
push_void:
   PUSH_VOID
   b		InterpreterLoop
tpush_void:
   TPUSH_VOID
   b		InterpreterLoop
push_end:
   PUSH_END
   b		InterpreterLoop
push_cons:
   PUSH_CONS
   b		InterpreterLoop
dealloc:
   DEALLOC
   b		InterpreterLoop
escape:
   ESCAPE
put_cons0:
   PUT_CONS_TCB
   b		InterpreterLoop
put_cons1:
   PUT_CONS(arg1)
   b		InterpreterLoop
put_cons2:
   PUT_CONS(arg2)
   b		InterpreterLoop
put_cons3:
   PUT_CONS(arg3)
   b		InterpreterLoop
put_cons4:
   PUT_CONS(arg4)
   b		InterpreterLoop
put_cons5:
   PUT_CONS(arg5)
   b		InterpreterLoop
put_cons6:
   PUT_CONS(arg6)
   b		InterpreterLoop
put_cons7:
   PUT_CONS(arg7)
   b		InterpreterLoop
put_struct0:
   PUT_STRUCT_TCB
   b		InterpreterLoop
put_struct1:
   PUT_STRUCT(arg1)
   b		InterpreterLoop
put_struct2:
   PUT_STRUCT(arg2)
   b		InterpreterLoop
put_struct3:
   PUT_STRUCT(arg3)
   b		InterpreterLoop
put_struct4:
   PUT_STRUCT(arg4)
   b		InterpreterLoop
put_struct5:
   PUT_STRUCT(arg5)
   b		InterpreterLoop
put_struct6:
   PUT_STRUCT(arg6)
   b		InterpreterLoop
put_struct7:
   PUT_STRUCT(arg7)
   b		InterpreterLoop
put_list0:
   PUT_LIST_TCB()
   b		InterpreterLoop
put_list1:
   PUT_LIST(arg1)
   b		InterpreterLoop
put_list2:
   PUT_LIST(arg2)
   b		InterpreterLoop
put_list3:
   PUT_LIST(arg3)
   b		InterpreterLoop
put_list4:
   PUT_LIST(arg4)
   b		InterpreterLoop
put_list5:
   PUT_LIST(arg5)
   b		InterpreterLoop
put_list6:
   PUT_LIST(arg6)
   b		InterpreterLoop
put_list7:
   PUT_LIST(arg7)
   b		InterpreterLoop
put_nil0:
   PUT_NIL_TCB
   b		InterpreterLoop
put_nil1:
   PUT_NIL(arg1)
   b		InterpreterLoop
put_nil2:
   PUT_NIL(arg2)
   b		InterpreterLoop
put_nil3:
   PUT_NIL(arg3)
   b		InterpreterLoop
put_nil4:
   PUT_NIL(arg4)
   b		InterpreterLoop
put_nil5:
   PUT_NIL(arg5)
   b		InterpreterLoop
put_nil6:
   PUT_NIL(arg6)
   b		InterpreterLoop
put_nil7:
   PUT_NIL(arg7)
   b		InterpreterLoop
put_void0:
   PUT_VOID_TCB
   b		InterpreterLoop
put_void1:
   PUT_VOID(arg1)
   b		InterpreterLoop
put_void2:
   PUT_VOID(arg2)
   b		InterpreterLoop
put_void3:
   PUT_VOID(arg3)
   b		InterpreterLoop
put_void4:
   PUT_VOID(arg4)
   b		InterpreterLoop
put_void5:
   PUT_VOID(arg5)
   b		InterpreterLoop
put_void6:
   PUT_VOID(arg6)
   b		InterpreterLoop
put_void7:
   PUT_VOID(arg7)
   b		InterpreterLoop
put_varp0:
   PUT_VARP_TCB
   b		InterpreterLoop
put_varp1:
   PUT_VARP(arg1)
   b		InterpreterLoop
put_varp2:
   PUT_VARP(arg2)
   b		InterpreterLoop
put_varp3:
   PUT_VARP(arg3)
   b		InterpreterLoop
put_varp4:
   PUT_VARP(arg4)
   b		InterpreterLoop
put_varp5:
   PUT_VARP(arg5)
   b		InterpreterLoop
put_varp6:
   PUT_VARP(arg6)
   b		InterpreterLoop
put_varp7:
   PUT_VARP(arg7)
   b		InterpreterLoop
push_vart0:
   PUSH_VART_TCB
   b		InterpreterLoop
push_vart1:
   PUSH_VART(arg1)
   b		InterpreterLoop
push_vart2:
   PUSH_VART(arg2)
   b		InterpreterLoop
push_vart3:
   PUSH_VART(arg3)
   b		InterpreterLoop
push_vart4:
   PUSH_VART(arg4)
   b		InterpreterLoop
push_vart5:
   PUSH_VART(arg5)
   b		InterpreterLoop
push_vart6:
   PUSH_VART(arg6)
   b		InterpreterLoop
push_vart7:
   PUSH_VART(arg7)
   b		InterpreterLoop
push_varp0:
   PUSH_VARP_TCB
   b		InterpreterLoop
push_varp1:
   li		r9,1
   PUSH_VARP(r9)
   b		InterpreterLoop
push_varp2:
   li		r9,2
   PUSH_VARP(r9)
   b		InterpreterLoop
push_varp3:
   li		r9,3
   PUSH_VARP(r9)
   b		InterpreterLoop
push_varp4:
   li		r9,4
   PUSH_VARP(r9)
   b		InterpreterLoop
push_varp5:
   li		r9,5
   PUSH_VARP(r9)
   b		InterpreterLoop
push_varp6:
   li		r9,6
   PUSH_VARP(r9)
   b		InterpreterLoop
push_varp7:
   li		r9,7
   PUSH_VARP(r9)
   b		InterpreterLoop
push_valt0:
   PUSH_VALT_TCB
   b		InterpreterLoop
push_valt1:
   PUSH_VALT(arg1)
   b		InterpreterLoop
push_valt2:
   PUSH_VALT(arg2)
   b		InterpreterLoop
push_valt3:
   PUSH_VALT(arg3)
   b		InterpreterLoop
push_valt4:
   PUSH_VALT(arg4)
   b		InterpreterLoop
push_valt5:
   PUSH_VALT(arg5)
   b		InterpreterLoop
push_valt6:
   PUSH_VALT(arg6)
   b		InterpreterLoop
push_valt7:
   PUSH_VALT(arg7)
   b		InterpreterLoop
push_valp0:
   PUSH_VALP_TCB
   b		InterpreterLoop
push_valp1:
   li		r9,1
   PUSH_VALP(r9)
   b		InterpreterLoop
push_valp2:
   li		r9,2
   PUSH_VALP(r9)
   b		InterpreterLoop
push_valp3:
   li		r9,3
   PUSH_VALP(r9)
   b		InterpreterLoop
push_valp4:
   li		r9,4
   PUSH_VALP(r9)
   b		InterpreterLoop
push_valp5:
   li		r9,5
   PUSH_VALP(r9)
   b		InterpreterLoop
push_valp6:
   li		r9,6
   PUSH_VALP(r9)
   b		InterpreterLoop
push_valp7:
   li		r9,7
   PUSH_VALP(r9)
   b		InterpreterLoop
tpush_vart0:
   TPUSH_VART_TCB
   b		InterpreterLoop
tpush_vart1:
   TPUSH_VART(arg1)
   b		InterpreterLoop
tpush_vart2:
   TPUSH_VART(arg2)
   b		InterpreterLoop
tpush_vart3:
   TPUSH_VART(arg3)
   b		InterpreterLoop
tpush_vart4:
   TPUSH_VART(arg4)
   b		InterpreterLoop
tpush_vart5:
   TPUSH_VART(arg5)
   b		InterpreterLoop
tpush_vart6:
   TPUSH_VART(arg6)
   b		InterpreterLoop
tpush_vart7:
   TPUSH_VART(arg7)
   b		InterpreterLoop
tpush_varp0:
   TPUSH_VARP_TCB
   b		InterpreterLoop
tpush_varp1:
   li		r9,1
   TPUSH_VARP(r9)
   b		InterpreterLoop
tpush_varp2:
   li		r9,2
   TPUSH_VARP(r9)
   b		InterpreterLoop
tpush_varp3:
   li		r9,3
   TPUSH_VARP(r9)
   b		InterpreterLoop
tpush_varp4:
   li		r9,4
   TPUSH_VARP(r9)
   b		InterpreterLoop
tpush_varp5:
   li		r9,5
   TPUSH_VARP(r9)
   b		InterpreterLoop
tpush_varp6:
   li		r9,6
   TPUSH_VARP(r9)
   b		InterpreterLoop
tpush_varp7:
   li		r9,7
   TPUSH_VARP(r9)
   b		InterpreterLoop
tpush_valt0:
   TPUSH_VALT_TCB
   b		InterpreterLoop
tpush_valt1:
   TPUSH_VALT(arg1)
   b		InterpreterLoop
tpush_valt2:
   TPUSH_VALT(arg2)
   b		InterpreterLoop
tpush_valt3:
   TPUSH_VALT(arg3)
   b		InterpreterLoop
tpush_valt4:
   TPUSH_VALT(arg4)
   b		InterpreterLoop
tpush_valt5:
   TPUSH_VALT(arg5)
   b		InterpreterLoop
tpush_valt6:
   TPUSH_VALT(arg6)
   b		InterpreterLoop
tpush_valt7:
   TPUSH_VALT(arg7)
   b		InterpreterLoop
tpush_valp0:
   TPUSH_VALP_TCB
   b		InterpreterLoop
tpush_valp1:
   li		r9,1
   TPUSH_VALP(r9)
   b		InterpreterLoop
tpush_valp2:
   li		r9,2
   TPUSH_VALP(r9)
   b		InterpreterLoop
tpush_valp3:
   li		r9,3
   TPUSH_VALP(r9)
   b		InterpreterLoop
tpush_valp4:
   li		r9,4
   TPUSH_VALP(r9)
   b		InterpreterLoop
tpush_valp5:
   li		r9,5
   TPUSH_VALP(r9)
   b		InterpreterLoop
tpush_valp6:
   li		r9,6
   TPUSH_VALP(r9)
   b		InterpreterLoop
tpush_valp7:
   li		r9,7
   TPUSH_VALP(r9)
   b		InterpreterLoop
put_valt00:
   PUT_VALT_TCB
   b		InterpreterLoop
put_valt01:
   PUT_VALT_ARG1(arg1)
   b		InterpreterLoop
put_valt02:
   PUT_VALT_ARG1(arg2)
   b		InterpreterLoop
put_valt03:
   PUT_VALT_ARG1(arg3)
   b		InterpreterLoop
put_valt04:
   PUT_VALT_ARG1(arg4)
   b		InterpreterLoop
put_valt05:
   PUT_VALT_ARG1(arg5)
   b		InterpreterLoop
put_valt06:
   PUT_VALT_ARG1(arg6)
   b		InterpreterLoop
put_valt07:
   PUT_VALT_ARG1(arg7)
   b		InterpreterLoop
put_valt10:
   PUT_VALT_ARG2(arg1)
   b		InterpreterLoop
put_valt12:
   PUT_VALT(arg1,arg2)
   b		InterpreterLoop
put_valt13:
   PUT_VALT(arg1,arg3)
   b		InterpreterLoop
put_valt14:
   PUT_VALT(arg1,arg4)
   b		InterpreterLoop
put_valt15:
   PUT_VALT(arg1,arg5)
   b		InterpreterLoop
put_valt16:
   PUT_VALT(arg1,arg6)
   b		InterpreterLoop
put_valt17:
   PUT_VALT(arg1,arg7)
   b		InterpreterLoop
put_valt20:
   PUT_VALT_ARG2(arg2)
   b		InterpreterLoop
put_valt21:
   PUT_VALT(arg2,arg1)
   b		InterpreterLoop
put_valt23:
   PUT_VALT(arg2,arg3)
   b		InterpreterLoop
put_valt24:
   PUT_VALT(arg2,arg4)
   b		InterpreterLoop
put_valt25:
   PUT_VALT(arg2,arg5)
   b		InterpreterLoop
put_valt26:
   PUT_VALT(arg2,arg6)
   b		InterpreterLoop
put_valt27:
   PUT_VALT(arg2,arg7)
   b		InterpreterLoop
put_valt30:
   PUT_VALT_ARG2(arg3)
   b		InterpreterLoop
put_valt31:
   PUT_VALT(arg3,arg1)
   b		InterpreterLoop
put_valt32:
   PUT_VALT(arg3,arg2)
   b		InterpreterLoop
put_valt34:
   PUT_VALT(arg3,arg4)
   b		InterpreterLoop
put_valt35:
   PUT_VALT(arg3,arg5)
   b		InterpreterLoop
put_valt36:
   PUT_VALT(arg3,arg6)
   b		InterpreterLoop
put_valt37:
   PUT_VALT(arg3,arg7)
   b		InterpreterLoop
put_valt40:
   PUT_VALT_ARG2(arg4)
   b		InterpreterLoop
put_valt41:
   PUT_VALT(arg4,arg1)
   b		InterpreterLoop
put_valt42:
   PUT_VALT(arg4,arg2)
   b		InterpreterLoop
put_valt43:
   PUT_VALT(arg4,arg3)
   b		InterpreterLoop
put_valt45:
   PUT_VALT(arg4,arg5)
   b		InterpreterLoop
put_valt46:
   PUT_VALT(arg4,arg6)
   b		InterpreterLoop
put_valt47:
   PUT_VALT(arg4,arg7)
   b		InterpreterLoop
put_valt50:
   PUT_VALT_ARG2(arg5)
   b		InterpreterLoop
put_valt51:
   PUT_VALT(arg5,arg1)
   b		InterpreterLoop
put_valt52:
   PUT_VALT(arg5,arg2)
   b		InterpreterLoop
put_valt53:
   PUT_VALT(arg5,arg3)
   b		InterpreterLoop
put_valt54:
   PUT_VALT(arg5,arg4)
   b		InterpreterLoop
put_valt56:
   PUT_VALT(arg5,arg6)
   b		InterpreterLoop
put_valt57:
   PUT_VALT(arg5,arg7)
   b		InterpreterLoop
put_valt60:
   PUT_VALT_ARG2(arg6)
   b		InterpreterLoop
put_valt61:
   PUT_VALT(arg6,arg1)
   b		InterpreterLoop
put_valt62:
   PUT_VALT(arg6,arg2)
   b		InterpreterLoop
put_valt63:
   PUT_VALT(arg6,arg3)
   b		InterpreterLoop
put_valt64:
   PUT_VALT(arg6,arg4)
   b		InterpreterLoop
put_valt65:
   PUT_VALT(arg6,arg5)
   b		InterpreterLoop
put_valt67:
   PUT_VALT(arg6,arg7)
   b		InterpreterLoop
put_valt70:
   PUT_VALT_ARG2(arg7)
   b		InterpreterLoop
put_valt71:
   PUT_VALT(arg7,arg1)
   b		InterpreterLoop
put_valt72:
   PUT_VALT(arg7,arg2)
   b		InterpreterLoop
put_valt73:
   PUT_VALT(arg7,arg3)
   b		InterpreterLoop
put_valt74:
   PUT_VALT(arg7,arg4)
   b		InterpreterLoop
put_valt75:
   PUT_VALT(arg7,arg5)
   b		InterpreterLoop
put_valt76:
   PUT_VALT(arg7,arg6)
   b		InterpreterLoop
put_valp00:
   PUT_VALP_TCB
   b		InterpreterLoop
put_valp01:
   li		r9,1
   PUT_VALP_ARG1(r9)
   b		InterpreterLoop
put_valp02:
   li		r9,2
   PUT_VALP_ARG1(r9)
   b		InterpreterLoop
put_valp03:
   li		r9,3
   PUT_VALP_ARG1(r9)
   b		InterpreterLoop
put_valp04:
   li		r9,4
   PUT_VALP_ARG1(r9)
   b		InterpreterLoop
put_valp05:
   li		r9,5
   PUT_VALP_ARG1(r9)
   b		InterpreterLoop
put_valp06:
   li		r9,6
   PUT_VALP_ARG1(r9)
   b		InterpreterLoop
put_valp07:
   li		r9,7
   PUT_VALP_ARG1(r9)
   b		InterpreterLoop
put_valp10:
   PUT_VALP_ARG2(arg1)
   b		InterpreterLoop
put_valp11:
   li		r9,1
   PUT_VALP(arg1,r9)
   b		InterpreterLoop
put_valp12:
   li		r9,2
   PUT_VALP(arg1,r9)
   b		InterpreterLoop
put_valp13:
   li		r9,3
   PUT_VALP(arg1,r9)
   b		InterpreterLoop
put_valp14:
   li		r9,4
   PUT_VALP(arg1,r9)
   b		InterpreterLoop
put_valp15:
   li		r9,5
   PUT_VALP(arg1,r9)
   b		InterpreterLoop
put_valp16:
   li		r9,6
   PUT_VALP(arg1,r9)
   b		InterpreterLoop
put_valp17:
   li		r9,7
   PUT_VALP(arg1,r9)
   b		InterpreterLoop
put_valp20:
   PUT_VALP_ARG2(arg2)
   b		InterpreterLoop
put_valp21:
   li		r9,1
   PUT_VALP(arg2,r9)
   b		InterpreterLoop
put_valp22:
   li		r9,2
   PUT_VALP(arg2,r9)
   b		InterpreterLoop
put_valp23:
   li		r9,3
   PUT_VALP(arg2,r9)
   b		InterpreterLoop
put_valp24:
   li		r9,4
   PUT_VALP(arg2,r9)
   b		InterpreterLoop
put_valp25:
   li		r9,5
   PUT_VALP(arg2,r9)
   b		InterpreterLoop
put_valp26:
   li		r9,6
   PUT_VALP(arg2,r9)
   b		InterpreterLoop
put_valp27:
   li		r9,7
   PUT_VALP(arg2,r9)
   b		InterpreterLoop
put_valp30:
   PUT_VALP_ARG2(arg3)
   b		InterpreterLoop
put_valp31:
   li		r9,1
   PUT_VALP(arg3,r9)
   b		InterpreterLoop
put_valp32:
   li		r9,2
   PUT_VALP(arg3,r9)
   b		InterpreterLoop
put_valp33:
   li		r9,3
   PUT_VALP(arg3,r9)
   b		InterpreterLoop
put_valp34:
   li		r9,4
   PUT_VALP(arg3,r9)
   b		InterpreterLoop
put_valp35:
   li		r9,5
   PUT_VALP(arg3,r9)
   b		InterpreterLoop
put_valp36:
   li		r9,6
   PUT_VALP(arg3,r9)
   b		InterpreterLoop
put_valp37:
   li		r9,7
   PUT_VALP(arg3,r9)
   b		InterpreterLoop
put_valp40:
   PUT_VALP_ARG2(arg4)
   b		InterpreterLoop
put_valp41:
   li		r9,1
   PUT_VALP(arg4,r9)
   b		InterpreterLoop
put_valp42:
   li		r9,2
   PUT_VALP(arg4,r9)
   b		InterpreterLoop
put_valp43:
   li		r9,3
   PUT_VALP(arg4,r9)
   b		InterpreterLoop
put_valp44:
   li		r9,4
   PUT_VALP(arg4,r9)
   b		InterpreterLoop
put_valp45:
   li		r9,5
   PUT_VALP(arg4,r9)
   b		InterpreterLoop
put_valp46:
   li		r9,6
   PUT_VALP(arg4,r9)
   b		InterpreterLoop
put_valp47:
   li		r9,7
   PUT_VALP(arg4,r9)
   b		InterpreterLoop
put_valp50:
   PUT_VALP_ARG2(arg5)
   b		InterpreterLoop
put_valp51:
   li		r9,1
   PUT_VALP(arg5,r9)
   b		InterpreterLoop
put_valp52:
   li		r9,2
   PUT_VALP(arg5,r9)
   b		InterpreterLoop
put_valp53:
   li		r9,3
   PUT_VALP(arg5,r9)
   b		InterpreterLoop
put_valp54:
   li		r9,4
   PUT_VALP(arg5,r9)
   b		InterpreterLoop
put_valp55:
   li		r9,5
   PUT_VALP(arg5,r9)
   b		InterpreterLoop
put_valp56:
   li		r9,6
   PUT_VALP(arg5,r9)
   b		InterpreterLoop
put_valp57:
   li		r9,7
   PUT_VALP(arg5,r9)
   b		InterpreterLoop
put_valp60:
   PUT_VALP_ARG2(arg6)
   b		InterpreterLoop
put_valp61:
   li		r9,1
   PUT_VALP(arg6,r9)
   b		InterpreterLoop
put_valp62:
   li		r9,2
   PUT_VALP(arg6,r9)
   b		InterpreterLoop
put_valp63:
   li		r9,3
   PUT_VALP(arg6,r9)
   b		InterpreterLoop
put_valp64:
   li		r9,4
   PUT_VALP(arg6,r9)
   b		InterpreterLoop
put_valp65:
   li		r9,5
   PUT_VALP(arg6,r9)
   b		InterpreterLoop
put_valp66:
   li		r9,6
   PUT_VALP(arg6,r9)
   b		InterpreterLoop
put_valp67:
   li		r9,7
   PUT_VALP(arg6,r9)
   b		InterpreterLoop
put_valp70:
   PUT_VALP_ARG2(arg7)
   b		InterpreterLoop
put_valp71:
   li		r9,1
   PUT_VALP(arg7,r9)
   b		InterpreterLoop
put_valp72:
   li		r9,2
   PUT_VALP(arg7,r9)
   b		InterpreterLoop
put_valp73:
   li		r9,3
   PUT_VALP(arg7,r9)
   b		InterpreterLoop
put_valp74:
   li		r9,4
   PUT_VALP(arg7,r9)
   b		InterpreterLoop
put_valp75:
   li		r9,5
   PUT_VALP(arg7,r9)
   b		InterpreterLoop
put_valp76:
   li		r9,6
   PUT_VALP(arg7,r9)
   b		InterpreterLoop
put_valp77:
   li		r9,7
   PUT_VALP(arg7,r9)
   b		InterpreterLoop

# Body Escape
ESCAPE_UTILS
INTERRUPTS
CALLSUPPORT
INDIRECTSUPPORT
GetTable:
   lbz		r11,69(temp)	# get mode
   cmpwi	r11,0
   beq		HeadMode
   cmpwi	r11,0x01
   beq		HeadWriteMode
   cmpwi	r11,0x80
   beq		BodyMode
   cmpwi	r11,0x90
   beq		BodyEscMode
   b		BodyEscClauseMode
Head:
   HEAD_CHANGE
HeadMode:
   lwz		WAMTable,HeadReadTableTC(RTOC)
   b		InterpreterLoop
HeadWrite:
   HEAD_WRITE_CHANGE
HeadWriteMode:
   lwz		WAMTable,HeadWriteTableTC(RTOC)
   b		InterpreterLoop
Body:
   BODY_CHANGE
BodyMode:
   lwz		WAMTable,BodyTableTC(RTOC)
   b		InterpreterLoop
BodyEscape:
   BODY_ESCAPE_CHANGE
BodyEscMode:
   lwz		WAMTable,BodyEscTableTC(RTOC)
   b		InterpreterLoop
BodyEscapeClause:
   BODY_ESCCL_CHANGE
BodyEscClauseMode:
   lwz		WAMTable,BodyEscClauseTableTC(RTOC)
InterpreterLoop:
   lbzu 	r8, 1(ppc)
   rlwinm	r8,r8,2,22,31
   lwzx		r4,WAMTable,r8
   mtctr	r4
   bcctr	BO_ALWAYS,0
Fail:
   lwz		sp,56(temp)			# reset sp to spbase
   li		r9,0				# load 0 into r9
   stw		r9,112(temp)		# zero out constraint head
   stw		r9,116(temp)		# zero out constraint tail
   cmpwi	lcp,0
   beq		Failure
   mr		r12,lcp				# expect cp in r12
   b		Fnext
Argerr:
   ERROR(-4)
Badins:
   ERROR(-5)
MiscError:
   ERROR(-9)
ArError:
   ERROR(105)
E_full:
   ERROR(102)
H_full:
   ERROR(101)
S_full:
   ERROR(-14)
FPerror:
   ERROR(105)
Cuterror:
   mr		arg1,r12
   cmpwi	ppc,0x0036
   bne		doCutError
   lwz		r11,cutFailAtomTC(RTOC)
   lwz		r11,0(r11)
   stw		r11,120(temp)
   b		doError
doCutError:
   lwz		r11,cutcutAtomTC(RTOC)
   lwz		r11,0(r11)
   stw		r11,120(temp)
doError:
   ERROR(103)
Verror1:
   ERROR(-17)
Badcallerr:
   ERROR(16)
Oerror:
   ERROR(-50)
ARITH_SUPPORT
break:
   BREAK
ecut:
   ECUT
dcut:
   DCUT
push_nil:
   PUSH_NIL
eval_cons:
   EVAL_CONS
call_indirect:
   CALLINDIRECT
call:
   CALL
exec_indirect:
   EXECINDIRECT
exec:
   EXEC
call_clause:
   CALL_CLAUSE
exec_addr:
   EXEC_ADDR
fail:
   FAIL
vart0:
   VART_TCB
vart1:
   VART(arg1)
vart2:
   VART(arg2)
vart3:
   VART(arg3)
vart4:
   VART(arg4)
vart5:
   VART(arg5)
vart6:
   VART(arg6)
vart7:
   VART(arg7)
varp0:
   VARP_TCB
varp1:
   VARP(1)
varp2:
   VARP(2)
varp3:
   VARP(3)
varp4:
   VARP(4)
varp5:
   VARP(5)
varp6:
   VARP(6)
varp7:
   VARP(7)
tvart0:
   TVART_TCB
tvart1:
   TVART(arg1)
tvart2:
   TVART(arg2)
tvart3:
   TVART(arg3)
tvart4:
   TVART(arg4)
tvart5:
   TVART(arg5)
tvart6:
   TVART(arg6)
tvart7:
   TVART(arg7)
tvarp0:
   TVARP_TCB
tvarp1:
   TVARP(1)
tvarp2:
   TVARP(2)
tvarp3:
   TVARP(3)
tvarp4:
   TVARP(4)
tvarp5:
   TVARP(5)
tvarp6:
   TVARP(6)
tvarp7:
   TVARP(7)
more_choicepoints:
   MORE_CHPTS
cCut:
   CCUT
cdCut:
   CDCUT
cCutFail:
   CCUTFAIL
cdCutFail:
   CDCUTFAIL
cut:
   NAMED_CUT
failexit:
   FAILEXIT
label_env:
   LABEL_ENV
testt0:
   TESTT_TCB
testt1:
   TESTT(arg1)
testt2:
   TESTT(arg2)
testt3:
   TESTT(arg3)
testt4:
   TESTT(arg4)
testt5:
   TESTT(arg5)
testt6:
   TESTT(arg6)
testt7:
   TESTT(arg7)
testp0:
   TESTP_TCB
testp1:
   TESTP(1)
testp2:
   TESTP(2)
testp3:
   TESTP(3)
testp4:
   TESTP(4)
testp5:
   TESTP(5)
testp6:
   TESTP(6)
testp7:
   TESTP(7)
pop_valt0:
   POP_VALT_TCB
pop_valt1:
   POP_VALT(arg1)
pop_valt2:
   POP_VALT(arg2)
pop_valt3:
   POP_VALT(arg3)
pop_valt4:
   POP_VALT(arg4)
pop_valt5:
   POP_VALT(arg5)
pop_valt6:
   POP_VALT(arg6)
pop_valt7:
   POP_VALT(arg7)
pop_valp0:
   POP_VALP_TCB
pop_valp1:
   POP_VALP(1)
pop_valp2:
   POP_VALP(2)
pop_valp3:
   POP_VALP(3)
pop_valp4:
   POP_VALP(4)
pop_valp5:
   POP_VALP(5)
pop_valp6:
   POP_VALP(6)
pop_valp7:
   POP_VALP(7)
evalt0:
   EVALT_TCB
evalt1:
   EVALT(arg1)
evalt2:
   EVALT(arg2)
evalt3:
   EVALT(arg3)
evalt4:
   EVALT(arg4)
evalt5:
   EVALT(arg5)
evalt6:
   EVALT(arg6)
evalt7:
   EVALT(arg7)
evalp0:
   EVALP_TCB
evalp1:
   EVALP(1)
evalp2:
   EVALP(2)
evalp3:
   EVALP(3)
evalp4:
   EVALP(4)
evalp5:
   EVALP(5)
evalp6:
   EVALP(6)
evalp7:
   EVALP(7)
pop_vart0:
   POP_VART_TCB
pop_vart1:
   POP_VART(arg1)
pop_vart2:
   POP_VART(arg2)
pop_vart3:
   POP_VART(arg3)
pop_vart4:
   POP_VART(arg4)
pop_vart5:
   POP_VART(arg5)
pop_vart6:
   POP_VART(arg6)
pop_vart7:
   POP_VART(arg7)
pop_varp0:
   POP_VARP_TCB
pop_varp1:
   POP_VARP(1)
pop_varp2:
   POP_VARP(2)
pop_varp3:
   POP_VARP(3)
pop_varp4:
   POP_VARP(4)
pop_varp5:
   POP_VARP(5)
pop_varp6:
   POP_VARP(6)
pop_varp7:
   POP_VARP(7)
put_vart00:
   PUT_VART_TCB
put_vart01:
   PUT_VART_ARG1(arg1)
put_vart02:
   PUT_VART_ARG1(arg2)
put_vart03:
   PUT_VART_ARG1(arg3)
put_vart04:
   PUT_VART_ARG1(arg4)
put_vart05:
   PUT_VART_ARG1(arg5)
put_vart06:
   PUT_VART_ARG1(arg6)
put_vart07:
   PUT_VART_ARG1(arg7)
put_vart10:
   PUT_VART_ARG1(arg1)
put_vart12:
   PUT_VART(arg1,arg2)
put_vart13:
   PUT_VART(arg1,arg3)
put_vart14:
   PUT_VART(arg1,arg4)
put_vart15:
   PUT_VART(arg1,arg5)
put_vart16:
   PUT_VART(arg1,arg6)
put_vart17:
   PUT_VART(arg1,arg7)
put_vart20:
   PUT_VART_ARG1(arg2)
put_vart21:
   PUT_VART(arg2,arg1)
put_vart23:
   PUT_VART(arg2,arg3)
put_vart24:
   PUT_VART(arg2,arg4)
put_vart25:
   PUT_VART(arg2,arg5)
put_vart26:
   PUT_VART(arg2,arg6)
put_vart27:
   PUT_VART(arg2,arg7)
put_vart30:
   PUT_VART_ARG1(arg3)
put_vart31:
   PUT_VART(arg3,arg1)
put_vart32:
   PUT_VART(arg3,arg2)
put_vart34:
   PUT_VART(arg3,arg4)
put_vart35:
   PUT_VART(arg3,arg5)
put_vart36:
   PUT_VART(arg3,arg6)
put_vart37:
   PUT_VART(arg3,arg7)
put_vart40:
   PUT_VART_ARG1(arg4)
put_vart41:
   PUT_VART(arg4,arg1)
put_vart42:
   PUT_VART(arg4,arg2)
put_vart43:
   PUT_VART(arg4,arg3)
put_vart45:
   PUT_VART(arg4,arg5)
put_vart46:
   PUT_VART(arg4,arg6)
put_vart47:
   PUT_VART(arg4,arg7)
put_vart50:
   PUT_VART_ARG1(arg5)
put_vart51:
   PUT_VART(arg5,arg1)
put_vart52:
   PUT_VART(arg5,arg2)
put_vart53:
   PUT_VART(arg5,arg3)
put_vart54:
   PUT_VART(arg5,arg4)
put_vart56:
   PUT_VART(arg5,arg6)
put_vart57:
   PUT_VART(arg5,arg7)
put_vart60:
   PUT_VART_ARG1(arg6)
put_vart61:
   PUT_VART(arg6,arg1)
put_vart62:
   PUT_VART(arg6,arg2)
put_vart63:
   PUT_VART(arg6,arg3)
put_vart64:
   PUT_VART(arg6,arg4)
put_vart65:
   PUT_VART(arg6,arg5)
put_vart67:
   PUT_VART(arg6,arg7)
put_vart70:
   PUT_VART_ARG1(arg7)
put_vart71:
   PUT_VART(arg7,arg1)
put_vart72:
   PUT_VART(arg7,arg2)
put_vart73:
   PUT_VART(arg7,arg3)
put_vart74:
   PUT_VART(arg7,arg4)
put_vart75:
   PUT_VART(arg7,arg5)
put_vart76:
   PUT_VART(arg7,arg6)
cCutsp:
   CCUTSP
addition:
   ADD
subtraction:
   SUBTRACT
multiplication:
   MULTIPLY
int_division:
   INT_DIVIDE
division:
   DIVIDE
mod:
   MOD
power:
   POWER
int:
   INT
float:
   FLOATING
floor:
   FLOOR
ceiling:
   CEILING
round:
   ROUND
max:
   MAX
min:
   MIN
sqrt:
   SQRT
abs:
   ABS
exp:
   EXP
ln:
   LOG
increment:
   INCREMENT
decrement:
   DECREMENT
negate:
   NEGATE
sin:
   SIN
cos:
   COS
tan:
   TAN
asin:
   ASIN
acos:
   ACOS
atan:
   ATAN
bin_butnot:
   BIN_BUTNOT
equal:
   EQUAL
less_equal:
   EQUAL_LESS
greater_equal:
   EQUAL_GREATER
less_than:
   LESS_THAN
greater_than:
   GREATER_THAN
not_equal:
   NOT_EQUAL
bin_bitshift:
   BIN_BITSHIFT
dcut_exec:
   DCUT_EXEC
maxint:
   MAXINT
maxfloat:
   MAXFLOAT
pi:
   PI
cputime:
   CPUTIME
bin_bitand:
   BIN_BITAND
bin_bitor:
   BIN_BITOR
bin_biteq:
   BIN_BITEQ
unary_not:
   UNARY_NOT
binary_and:
   BINARY_AND
binary_or:
   BINARY_OR
binary_xor:
   BINARY_XOR
binary_compare:
   BINARY_COMPARE
rel_equal:
   REL_EQUAL
rel_greater:
   REL_GREATER
rel_less:
   REL_LESS

# Clause Mode
CLAUSESUPPORT
Cecut:
   CL_ECUT
Cdcut:
   CL_DCUT
Ceval_cons:
   CL_EVAL_CONS
Ccall_indirect:
   CL_CALLINDIRECT
Ccall:
   CL_CALL
Cexec_indirect:
   CL_EXECINDIRECT
Cexec:
   CL_EXEC
Ccall_clause:
   CL_CLAUSE
Cexec_addr:
   CL_EXECADDR
Cvart0:
   CL_VART_TCB
Cvart1:
   CL_VART(arg1)
Cvart2:
   CL_VART(arg2)
Cvart3:
   CL_VART(arg3)
Cvart4:
   CL_VART(arg4)
Cvart5:
   CL_VART(arg5)
Cvart6:
   CL_VART(arg6)
Cvart7:
   CL_VART(arg7)
Cvarp0:
   CL_VARP_TCB
Cvarp1:
   CL_VARP(1)
Cvarp2:
   CL_VARP(2)
Cvarp3:
   CL_VARP(3)
Cvarp4:
   CL_VARP(4)
Cvarp5:
   CL_VARP(5)
Cvarp6:
   CL_VARP(6)
Cvarp7:
   CL_VARP(7)
Ctvart0:
   CL_TVART_TCB
Ctvart1:
   CL_TVART(arg1)
Ctvart2:
   CL_TVART(arg2)
Ctvart3:
   CL_TVART(arg3)
Ctvart4:
   CL_TVART(arg4)
Ctvart5:
   CL_TVART(arg5)
Ctvart6:
   CL_TVART(arg6)
Ctvart7:
   CL_TVART(arg7)
Ctvarp0:
   CL_TVARP_TCB
Ctvarp1:
   CL_TVARP(1)
Ctvarp2:
   CL_TVARP(2)
Ctvarp3:
   CL_TVARP(3)
Ctvarp4:
   CL_TVARP(4)
Ctvarp5:
   CL_TVARP(5)
Ctvarp6:
   CL_TVARP(6)
Ctvarp7:
   CL_TVARP(7)
Cfail:
   CL_FAIL
CcCut:
   CL_CCUT
CcdCut:
   CL_CDCUT
CcCutFail:
   CL_CCUTFAIL
CcdCutFail:
   CL_CDCUTFAIL
Ccut:
   CL_CUT
Cfailexit:
   CL_FAILEXIT
Ctestt0:
   CL_TESTT_TCB
Ctestt1:
   CL_TESTT(arg1)
Ctestt2:
   CL_TESTT(arg2)
Ctestt3:
   CL_TESTT(arg3)
Ctestt4:
   CL_TESTT(arg4)
Ctestt5:
   CL_TESTT(arg5)
Ctestt6:
   CL_TESTT(arg6)
Ctestt7:
   CL_TESTT(arg7)
Ctestp0:
   CL_TESTP_TCB
Ctestp1:
   CL_TESTP(1)
Ctestp2:
   CL_TESTP(2)
Ctestp3:
   CL_TESTP(3)
Ctestp4:
   CL_TESTP(4)
Ctestp5:
   CL_TESTP(5)
Ctestp6:
   CL_TESTP(6)
Ctestp7:
   CL_TESTP(7)
Cpop_valt0:
   CL_POP_VALT_TCB
Cpop_valt1:
   CL_POP_VALT(arg1)
Cpop_valt2:
   CL_POP_VALT(arg2)
Cpop_valt3:
   CL_POP_VALT(arg3)
Cpop_valt4:
   CL_POP_VALT(arg4)
Cpop_valt5:
   CL_POP_VALT(arg5)
Cpop_valt6:
   CL_POP_VALT(arg6)
Cpop_valt7:
   CL_POP_VALT(arg7)
Cpop_valp0:
   CL_POP_VALP_TCB
Cpop_valp1:
   CL_POP_VALP(1)
Cpop_valp2:
   CL_POP_VALP(2)
Cpop_valp3:
   CL_POP_VALP(3)
Cpop_valp4:
   CL_POP_VALP(4)
Cpop_valp5:
   CL_POP_VALP(5)
Cpop_valp6:
   CL_POP_VALP(6)
Cpop_valp7:
   CL_POP_VALP(7)
Cevalt0:
   CL_EVALT_TCB
Cevalt1:
   CL_EVALT(arg1)
Cevalt2:
   CL_EVALT(arg2)
Cevalt3:
   CL_EVALT(arg3)
Cevalt4:
   CL_EVALT(arg4)
Cevalt5:
   CL_EVALT(arg5)
Cevalt6:
   CL_EVALT(arg6)
Cevalt7:
   CL_EVALT(arg7)
Cevalp0:
   CL_EVALP_TCB
Cevalp1:
   CL_EVALP(1)
Cevalp2:
   CL_EVALP(2)
Cevalp3:
   CL_EVALP(3)
Cevalp4:
   CL_EVALP(4)
Cevalp5:
   CL_EVALP(5)
Cevalp6:
   CL_EVALP(6)
Cevalp7:
   CL_EVALP(7)
Cpop_vart0:
   CL_POP_VART_TCB
Cpop_vart1:
   CL_POP_VART(arg1)
Cpop_vart2:
   CL_POP_VART(arg2)
Cpop_vart3:
   CL_POP_VART(arg3)
Cpop_vart4:
   CL_POP_VART(arg4)
Cpop_vart5:
   CL_POP_VART(arg5)
Cpop_vart6:
   CL_POP_VART(arg6)
Cpop_vart7:
   CL_POP_VART(arg7)
Cpop_varp0:
   CL_POP_VARP_TCB
Cpop_varp1:
   CL_POP_VARP(1)
Cpop_varp2:
   CL_POP_VARP(2)
Cpop_varp3:
   CL_POP_VARP(3)
Cpop_varp4:
   CL_POP_VARP(4)
Cpop_varp5:
   CL_POP_VARP(5)
Cpop_varp6:
   CL_POP_VARP(6)
Cpop_varp7:
   CL_POP_VARP(7)
CcCutsp:
   CL_CCUTSP
Caddition:
   CL_ADD
Csubtraction:
   CL_SUBTRACT
Cmultiplication:
   CL_MULTIPLY
Cint_division:
   CL_INT_DIVIDE
Cdivision:
   CL_DIVIDE
Cmod:
   CL_MOD
Cpower:
   CL_POWER
Cint:
   CL_INT
Cfloat:
   CL_FLOATING
Cfloor:
   CL_FLOOR
Cceiling:
   CL_CEILING
Cround:
   CL_ROUND
Cmax:
   CL_MAX
Cmin:
   CL_MIN
Csqrt:
   CL_SQRT
Cabs:
   CL_ABS
Cexp:
   CL_EXP
Cln:
   CL_LOG
Cincrement:
   CL_INCREMENT
Cdecrement:
   CL_DECREMENT
Cnegate:
   CL_NEGATE
Csin:
   CL_SIN
Ccos:
   CL_COS
Ctan:
   CL_TAN
Casin:
   CL_ASIN
Cacos:
   CL_ACOS
Catan:
   CL_ATAN
Cbin_butnot:
   CL_BIN_BUTNOT
Cequal:
   CL_EQUAL
Cless_equal:
   CL_EQUAL_LESS
Cgreater_equal:
   CL_EQUAL_GREATER
Cless_than:
   CL_LESS_THAN
Cgreater_than:
   CL_GREATER_THAN
Cnot_equal:
   CL_NOT_EQUAL
Cbin_bitshift:
   CL_BIN_BITSHIFT
Cdcut_exec:
   CL_DCUT_EXEC
Cmaxint:
   CL_MAXINT
Cmaxfloat:
   CL_MAXFLOAT
Cpi:
   CL_PI
Ccputime:
   CL_CPUTIME
Cbin_bitand:
   CL_BIN_BITAND
Cbin_bitor:
   CL_BIN_BITOR
Cbin_biteq:
   CL_BIN_BITEQ
Cunary_not:
   CL_UNARY_NOT
Cbinary_and:
   CL_BINARY_AND
Cbinary_or:
   CL_BINARY_OR
Cbinary_xor:
   CL_BINARY_XOR
Cbinary_compare:
   CL_BINARY_COMPARE
Crel_equal:
   CL_REL_EQUAL
Crel_greater:
   CL_REL_GREATER
Crel_less:
   CL_REL_LESS
unused:
   ERROR(106)
CallingBNRP:
   CALLING_BNRP
Recovery:
   mr		r3,temp				# copy TCB into r3
   stw		ce,96(temp)			# store ce into TCB
   bl		.BNRP_errorTraceback{PR}
   nop
RecovP:
   lwz		r12,recoveryUnitAtomTC(RTOC)	# get atom address
   lwz		r12,0(r12)			# get atom value
   mr		r8,ce
RecoveryLoop:
   lwz		r10,-12(r8)			# get pname of ce
   cmpw		r12,r10				# is it recoveryUnitAtom?
   beq		RecoveryDone
   lwz		r11,-4(r8)			# get previous env from ce
   cmpw		r11,r8				# check for self-ref environment
   beq		ExitTask			# end of environments
   mr		r8,r11				# get previous environment
   b		RecoveryLoop
RecoveryDone:
   lwz		r11,-8(r8)			# get cutpoint from environment
   cmpw		lcp,r11
   bge		Fail				# nothing to cut
   mr		lcp,r11				# update lcp reg
   lwz		bh,12(lcp)			# load critical hp from lcp
   lwz		be,8(lcp)			# load criticalenv from lcp
   lwz		r10,20(lcp)			# load trail end from lcp
   TRIMTRAIL(r10,r9,te)
   mr		te,r10				# update TCB te
   b		Fail
PopCP:							# remove choicepoint
   lwz		r12,16(r12)			# r12 now points at previous cp
   mr		lcp,r12
Fnext:
   lwz		r9,4(r12)			# load key from choicepoint
   cmpwi	r9,-1
   lwz		r10,0(r12)			# get next clause
   beq		PopCP				# skip dummy choicepoint
   lwz		r11,36(r12)			# load arity from choicepoint
   mr		ppc,r10				# update ppc
   stw		r11,124(temp)		# update TCB arity
   mr.		r5,r10				# temporary?? exit escape ????
   beq		Failure
   lwz		r10,4(r12)			# get hashkey
   cmpwi	r10,0
   beq		NonDeter
   FINDCLAUSE(ppc,r11,r10,r9,LastClause,PopCP)
   b		MoreClauses
NonDeter:
   NEXTCLAUSE(ppc,r11,r9,LastClause,PopCP)
MoreClauses:
   stw		r9,0(r12)			# update nextclause
   lwz		be,8(r12)			# update be
   lwz		hp,12(r12)			# update hp
   mr		bh,hp				# update bh
   lwz		r9,16(r12)			# get cutb from cp
   stw		r9,80(temp)			# update cutb of TCB
   b		Untrail				# unwind trail
LastClause:
   lwz		hp,12(r12)			# update hp from cp
   lwz		r9,16(r12)			# get previous cp from cp
   stw		r9,80(temp)			# update cutb of TCB
   lwz		be,8(r9)			# update be from new cp
   lwz		bh,12(r9)			# update bh from new cp
   mr		lcp,r9				# update lcp thus removing choicepoint
Untrail:
   lwz		r9,20(r12)			# get te from cp
   cmpw		r9,te
   beq		DoneTrailUnwind
   blt		MiscError
TrailUnwind:
   lwz		r5,0(te)			# get address of trail item
   lwz		r6,4(te)			# get value of item
   stw		r6,0(r5)			# place value into address
   addi		te,te,8
   cmpw		r9,te
   bgt		TrailUnwind
DoneTrailUnwind:
   lwz		ce,24(r12)			# update ce
   lwz		cp,28(r12)			# update continuation pointer
   lwz		r10,32(r12)			# load goalname from cp
   stw		r10,120(temp)		# update TCB procname
   li		r9,0
   stw		r9,112(temp)		# clear constraint head
   mr		r10,r11
   cmpwi	r11,0				# compare tcb arity
   bge		ReloadRegs
#   clrlwi	r10,r11,1				# clear sign bit
   neg		r10,r11
ReloadRegs:
   cmpwi	r10,0				
   lwz		WAMTable,HeadReadTableTC(RTOC)
   beq		ZeroRegs
   cmpwi	r10,1
   beq		OneReg
   cmpwi	r10,2
   beq		TwoRegs
   cmpwi	r10,3
   beq		ThreeRegs
   cmpwi	r10,4
   beq		FourRegs
   cmpwi	r10,5
   beq		FiveRegs
   cmpwi	r10,6
   beq		SixRegs
   cmpwi	r10,7
   beq		SevenRegs
Reload7Plus:
   addi		r8,r10,-7			# subtract 7 from arity
   addi		r10,temp,152		# address of TCB arg #7
   addi		r7,r12,64			# address of cp arg #7
ReloadLoop:
   lwzu		r9,4(r7)			# load arg from cp and update
   stwu		r9,4(r10)			# store cp arg into TCB
   addi		r8,r8,-1			# decrement arity count
   cmpwi	r8,0
   bgt		ReloadLoop
SevenRegs:
   lwz		arg7,64(r12)		# 7 args
SixRegs:
   lwz		arg6,60(r12)		# 6 args
FiveRegs:
   lwz		arg5,56(r12)		# 5 args
FourRegs:
   lwz		arg4,52(r12)		# 4 args
ThreeRegs:
   lwz		arg3,48(r12)		# 3 args
TwoRegs:
   lwz		arg2,44(r12)		# 2 args
OneReg:
   lwz		arg1,40(r12)		# 1 args
ZeroRegs:
   b		StartHead
ExitTask:
   lwz		r10,20(temp)		# get TCB invoker
   cmpwi	r10,0				# is there and invoker?
   beq		Exit				# no invoker, exit
   lhz		r11,70(temp)		# get status
   extsh	r11,r11				# sign extend it
   cmpwi	r11,-1				# Is error code -1?
   beq		NormalExit
   lhz		r12,68(r10)			# get top 2 bytes of invoker ppsw
   rlwinm	r12,r12,16,0,15		# left justify r12
   rlwinm	r11,r11,0,16,31		# clear top 16 bits of r11
   ori		r11,r11,r12			# combine r11 and r12 to make ppsw
   stw		r11,68(r10)			# store ppsw into invoker
NormalExit:						# reclaim task storage
   addi		r3,SP,56			# get pointer to pointer to TCB
   bl		.BNRP_removeTaskFromChain{PR}
   nop
   lwz		temp,56(SP)			# TCB may have changed
   lhz		r12,70(temp)		# get status
   cmpwi	r12,0				# if error != zero
   bne		RecovP
   li		r3,1				# put TRUE in return reg
   b		Retdc				# Return from primitive call
Failure:
   li		r12,-1				# error code is -1 for normal failure	
   sth		r12,70(temp)
   b		ExitTask
Exit:
   SAVEREGS						# Save Registers back into TCB
   lhz		r3,70(temp)			# get error code from tcb->ppsw and place in r3
   extsh	r3,r3				# sign extend it
   addic	SP,SP,800			# remove BNRP_RESUME() stack
   lmw		r13,-140(SP)		# restore GPR13-31
   bl		._restf20{PR}		# restore FPR's
   nop
   lwz		r10,4(SP)			# get CR from stack
   mtcr		r10					# restore CR
   lwz		r0,8(SP)			# get LR from stack
   mtspr	LR,r0				# restore LR
   bclr		BO_ALWAYS,CR0_LT	# Return
   .long	0x00000000
   .byte	0x00
   .byte	0x00
   .byte	0x00
   .byte	0x43
   .byte	0x80
   .byte	0x13
   .byte	0x01
   .byte	0x01
   .long	0x00000000
   .long	0x00000000
   .short	11
   .byte	"BNRP_RESUME"
   .byte	0x00
   .byte	0x00
   .byte	0x00
# End of traceback table
.BNRP_error:                            # 0x00000098 (H.10.NO_SYMBOL+0x98)
   lwz		r12,BNRPerrorhandlerTC(RTOC)
   lwz		r8,0(r12)
   lwz		r12,erroraddr(RTOC)	# load in address of erroraddr
   lwz		SP,0(r12)			# get erroraddr value. erroraddr is start of BNRP_RESUME stack
   lwz		temp,56(SP)			# load TCB pointer
   LOADREGS2
   sth		r3,70(temp)
   cmpwi	0,r8,0
   beq		startError		
   mtctr	r8
   bcctrl	BO_ALWAYS,0
   nop
startError:
   b		Recovery
   .long	0x00000000
   .byte	0x00
   .byte	0x00
   .byte	0x20
   .byte	0x43
   .byte	0x80
   .byte	0x00
   .byte	0x01
   .byte	0x00
   .long	0x00000000
   .long	0x00000080
   .short	10
   .byte	"BNRP_error"
# End of traceback table
	.long	0x00000000              # "\0\0\0\0"
# End	csect	H.10.NO_SYMBOL{PR}

# .data section


	.toc	                        # 0x000000e8 
CORETC:
   .tc CORE{TC},CORE{PR}
T.26.BNRP_quit:
	.tc	H.26.BNRP_quit{TC},BNRP_quit{DS}
HeadReadTableTC:
	.tc	HeadReadTable{TC},HeadReadTable{RW}
HeadWriteTableTC:
	.tc	HeadWriteTable{TC},HeadWriteTable{RW}
BodyTableTC:
	.tc	BodyTable{TC},BodyTable{RW}
BodyEscTableTC:
	.tc	BodyEscTable{TC},BodyEscTable{RW}
BodyEscClauseTableTC:
	.tc	BodyEscClauseTable{TC},BodyEscClauseTable{RW}
T.30.BNRP_RESUME:
	.tc	H.30.BNRP_RESUME{TC},BNRP_RESUME{DS}
T.34.BNRP_error:
	.tc	H.34.BNRP_error{TC},BNRP_error{DS}
erroraddr:
	.tc	erroraddr{TC},erroraddr{RW}
BNRPerrorhandlerTC:
	.tc	BNRPerrorhandler{TC},BNRPerrorhandler{UA}
cutAtomTC:
	.tc	cutAtom{TC},cutAtom{UA}
cutcutAtomTC:
	.tc	cutcutAtom{TC},cutcutAtom{UA}
cutFailAtomTC:
	.tc	cutFailAtom{TC},cutFailAtom{UA}
isAtomTC:
	.tc	isAtom{TC},isAtom{UA}
recoveryUnitAtomTC:
	.tc	recoveryUnitAtom{TC},recoveryUnitAtom{UA}
plusAtomTC:
	.tc	plusAtom{TC},plusAtom{UA}
minusAtomTC:
	.tc	minusAtom{TC},minusAtom{UA}
starAtomTC:
	.tc	starAtom{TC},starAtom{UA}
slashAtomTC:
	.tc	slashAtom{TC},slashAtom{UA}
slashslashAtomTC:
	.tc	slashslashAtom{TC},slashslashAtom{UA}
modAtomTC:
	.tc	modAtom{TC},modAtom{UA}
starstarAtomTC:
	.tc	starstarAtom{TC},starstarAtom{UA}
intAtomTC:
	.tc	intAtom{TC},intAtom{UA}
floatAtomTC:
	.tc	floatAtom{TC},floatAtom{UA}
floorAtomTC:
	.tc	floorAtom{TC},floorAtom{UA}
ceilAtomTC:
	.tc	ceilAtom{TC},ceilAtom{UA}
roundAtomTC:
	.tc	roundAtom{TC},roundAtom{UA}
maxAtomTC:
	.tc	maxAtom{TC},maxAtom{UA}
minAtomTC:
	.tc	minAtom{TC},minAtom{UA}
sqrtAtomTC:
	.tc	sqrtAtom{TC},sqrtAtom{UA}
absAtomTC:
	.tc	absAtom{TC},absAtom{UA}
expAtomTC:
	.tc	expAtom{TC},expAtom{UA}
lnAtomTC:
	.tc	lnAtom{TC},lnAtom{UA}
sinAtomTC:
	.tc	sinAtom{TC},sinAtom{UA}
cosAtomTC:
	.tc	cosAtom{TC},cosAtom{UA}
tanAtomTC:
	.tc	tanAtom{TC},tanAtom{UA}
asinAtomTC:
	.tc	asinAtom{TC},asinAtom{UA}
acosAtomTC:
	.tc	acosAtom{TC},acosAtom{UA}
atanAtomTC:
	.tc	atanAtom{TC},atanAtom{UA}
maxintAtomTC:
	.tc	maxintAtom{TC},maxintAtom{UA}
maxfloatAtomTC:
	.tc	maxfloatAtom{TC},maxfloatAtom{UA}
piAtomTC:
	.tc	piAtom{TC},piAtom{UA}
cputimeAtomTC:
	.tc	cputimeAtom{TC},cputimeAtom{UA}
butnotAtomTC:
	.tc	butnotAtom{TC},butnotAtom{UA}
bitshiftAtomTC:
	.tc	bitshiftAtom{TC},bitshiftAtom{UA}
bitandAtomTC:
	.tc	bitandAtom{TC},bitandAtom{UA}
bitorAtomTC:
	.tc	bitorAtom{TC},bitorAtom{UA}
biteqAtomTC:
	.tc	biteqAtom{TC},biteqAtom{UA}
boolnotAtomTC:
	.tc	boolnotAtom{TC},boolnotAtom{UA}
boolandAtomTC:
	.tc	boolandAtom{TC},boolandAtom{UA}
boolorAtomTC:
	.tc	boolorAtom{TC},boolorAtom{UA}
boolxorAtomTC:
	.tc	boolxorAtom{TC},boolxorAtom{UA}
eqAtomTC:
	.tc	eqAtom{TC},eqAtom{UA}
neAtomTC:
	.tc	neAtom{TC},neAtom{UA}
ltAtomTC:
	.tc	ltAtom{TC},ltAtom{UA}
gtAtomTC:
	.tc	gtAtom{TC},gtAtom{UA}
geAtomTC:
	.tc	geAtom{TC},geAtom{UA}
leAtomTC:
	.tc	leAtom{TC},leAtom{UA}
clauseAtomTC:
	.tc	clauseAtom{TC},clauseAtom{UA}
failAtomTC:
	.tc	failAtom{TC},failAtom{UA}
varAtomTC:
	.tc	varAtom{TC},varAtom{UA}
tailvarAtomTC:
	.tc	tailvarAtom{TC},tailvarAtom{UA}
BNRP_filterNamesTC:
	.tc	BNRP_filterNames{TC},BNRP_filterNames{UA}
attentionAtomTC:
	.tc attentionAtom{TC},attentionAtom{UA}
ifAtomTC:
	.tc ifAtom{TC},ifAtom{UA}
indirectAtomTC:
	.tc indirectAtom{TC},indirectAtom{UA}
tracerAtomTC:
	.tc tracerAtom{TC},tracerAtom{UA}
tickAtomTC:
	.tc tickAtom{TC},tickAtom{UA}
ssAtomTC:
	.tc ssAtom{TC},ssAtom{UA}
evalConstrainedAtomTC:
	.tc evalConstrainedAtom{TC},evalConstrainedAtom{UA}
combineVarAtomTC:
	.tc BNRP_combineVarAtom{TC},BNRP_combineVarAtom{UA}
taskswitchTC:
	.tc BNRP_taskswitch_primitive{TC},BNRP_taskswitch_primitive{UA}
BNRP_gcFlagTC:
   .tc BNRP_gcFlag{TC},BNRP_gcFlag{UA}
BNRPflagsTC:
   .tc BNRPflags{TC},BNRPflags{UA}
BNRPprimitiveCallsTC:
   .tc BNRPprimitiveCalls{TC},BNRPprimitiveCalls{UA}
inClauseTC:
   .tc inClause{TC},inClause{UA}
clauseListTC:
   .tc clauseList{TC},clauseList{UA}
headCountTC:
   .tc headCount{TC},headCount{UA}
bodyCounterTC:
   .tc bodyCounter{TC},bodyCounter{UA}
escapeCountTC:
   .tc escapeCount{TC},escapeCount{UA}
DEBUG_TOCS

	.csect	BNRP_quit{DS}           
	.long	.BNRP_quit              # "\0\0\0\0"
	.long	TOC{TC0}                # "\0\0\0\350"
	.long	0x00000000              # "\0\0\0\0"
# End	csect	BNRP_quit{DS}


	.csect	BNRP_RESUME{DS}         
	.long	.BNRP_RESUME            # "\0\0\0H"
	.long	TOC{TC0}                # "\0\0\0\350"
	.long	0x00000000              # "\0\0\0\0"
# End	csect	BNRP_RESUME{DS}


	.csect	BNRP_error{DS}          
	.long	.BNRP_error             # "\0\0\0\230"
	.long	TOC{TC0}                # "\0\0\0\350"
	.long	0x00000000              # "\0\0\0\0"
# End	csect	BNRP_error{DS}


	.csect	HeadReadTable{RW}, 3   
		.long 	neck		# 0x00
		.long	Runify_void	# 0x01
		.long	InterpreterLoop		# 0x02 tunif_void does nothing in read mode
		.long	Rend_seq	# 0x03
		.long	Runif_cons	# 0x04
		.long	neckcon		# 0x05
		.long	alloc		# 0x06
		.long	Runify_nil	# 0x07
		.long	get_cons0	# 0x08
		.long	get_cons1	# 0x09
		.long	get_cons2	# 0x0a
		.long	get_cons3	# 0x0b
		.long	get_cons4	# 0x0c
		.long	get_cons5	# 0x0d
		.long	get_cons6	# 0x0e
		.long	get_cons7	# 0x0f
		.long	get_struct0	# 0x10
		.long	get_struct1	# 0x11
		.long	get_struct2	# 0x12
		.long	get_struct3	# 0x13
		.long	get_struct4	# 0x14
		.long	get_struct5	# 0x15
		.long	get_struct6	# 0x16
		.long	get_struct7	# 0x17
		.long	unused		# 0x18
		.long	unused		# 0x19
		.long	unused		# 0x1a
		.long	unused		# 0x1b
		.long	unused		# 0x1c
		.long	unused		# 0x1d
		.long	unused		# 0x1e
		.long	unused		# 0x1f
		.long	get_list0	# 0x20
		.long	get_list1	# 0x21
		.long	get_list2	# 0x22
		.long	get_list3	# 0x23
		.long	get_list4	# 0x24
		.long	get_list5	# 0x25
		.long	get_list6	# 0x26
		.long	get_list7	# 0x27
		.long	get_nil0	# 0x28
		.long	get_nil1	# 0x29
		.long	get_nil2	# 0x2a
		.long	get_nil3	# 0x2b
		.long	get_nil4	# 0x2c
		.long	get_nil5	# 0x2d
		.long	get_nil6	# 0x2e
		.long	get_nil7	# 0x2f
		.long	get_valt0	# 0x30
		.long	get_valt1	# 0x31
		.long	get_valt2	# 0x32
		.long	get_valt3	# 0x33
		.long	get_valt4	# 0x34
		.long	get_valt5	# 0x35
		.long	get_valt6	# 0x36
		.long	get_valt7	# 0x37
		.long	get_valp0	# 0x38
		.long	get_valp1	# 0x39
		.long	get_valp2	# 0x3a
		.long	get_valp3	# 0x3b
		.long	get_valp4	# 0x3c
		.long	get_valp5	# 0x3d
		.long	get_valp6	# 0x3e
		.long	get_valp7	# 0x3f
		.long	Runify_vart0	# 0x40
		.long	Runify_vart1	# 0x41
		.long	Runify_vart2	# 0x42
		.long	Runify_vart3	# 0x43
		.long	Runify_vart4	# 0x44
		.long	Runify_vart5	# 0x45
		.long	Runify_vart6	# 0x46
		.long	Runify_vart7	# 0x47
		.long	Runify_varp0	# 0x48
		.long	Runify_varp1	# 0x49
		.long	Runify_varp2	# 0x4a
		.long	Runify_varp3	# 0x4b
		.long	Runify_varp4	# 0x4c
		.long	Runify_varp5	# 0x4d
		.long	Runify_varp6	# 0x4e
		.long	Runify_varp7	# 0x4f
		.long	Runify_valt0	# 0x50
		.long	Runify_valt1	# 0x51
		.long	Runify_valt2	# 0x52
		.long	Runify_valt3	# 0x53
		.long	Runify_valt4	# 0x54
		.long	Runify_valt5	# 0x55
		.long	Runify_valt6	# 0x56
		.long	Runify_valt7	# 0x57
		.long	Runify_valp0	# 0x58
		.long	Runify_valp1	# 0x59
		.long	Runify_valp2	# 0x5a
		.long	Runify_valp3	# 0x5b
		.long	Runify_valp4	# 0x5c
		.long	Runify_valp5	# 0x5d
		.long	Runify_valp6	# 0x5e
		.long	Runify_valp7	# 0x5f
		.long	Rtunify_vart0	# 0x60
		.long	Rtunify_vart1	# 0x61
		.long	Rtunify_vart2	# 0x62
		.long	Rtunify_vart3	# 0x63
		.long	Rtunify_vart4	# 0x64
		.long	Rtunify_vart5	# 0x65
		.long	Rtunify_vart6	# 0x66
		.long	Rtunify_vart7	# 0x67
		.long	Rtunify_varp0	# 0x68
		.long	Rtunify_varp1	# 0x69
		.long	Rtunify_varp2	# 0x6a
		.long	Rtunify_varp3	# 0x6b
		.long	Rtunify_varp4	# 0x6c
		.long	Rtunify_varp5	# 0x6d
		.long	Rtunify_varp6	# 0x6e
		.long	Rtunify_varp7	# 0x6f
		.long	Rtunify_valt0	# 0x70
		.long	Rtunify_valt1	# 0x71
		.long	Rtunify_valt2	# 0x72
		.long	Rtunify_valt3	# 0x73
		.long	Rtunify_valt4	# 0x74
		.long	Rtunify_valt5	# 0x75
		.long	Rtunify_valt6	# 0x76
		.long	Rtunify_valt7	# 0x77
		.long	Rtunify_valp0	# 0x78
		.long	Rtunify_valp1	# 0x79
		.long	Rtunify_valp2	# 0x7a
		.long	Rtunify_valp3	# 0x7b
		.long	Rtunify_valp4	# 0x7c
		.long	Rtunify_valp5	# 0x7d
		.long	Rtunify_valp6	# 0x7e
		.long	Rtunify_valp7	# 0x7f
		.long	get_vart00	# 0x80
		.long	get_vart01	# 0x81
		.long	get_vart02	# 0x82
		.long	get_vart03	# 0x83
		.long	get_vart04	# 0x84
		.long	get_vart05	# 0x85
		.long	get_vart06	# 0x86
		.long	get_vart07	# 0x87
		.long	get_varp00	# 0x88
		.long	get_varp01	# 0x89
		.long	get_varp02	# 0x8a
		.long	get_varp03	# 0x8b
		.long	get_varp04	# 0x8c
		.long	get_varp05	# 0x8d
		.long	get_varp06	# 0x8e
		.long	get_varp07	# 0x8f
		.long	get_vart10	# 0x90
		.long	unused		# 0x91
		.long	get_vart12	# 0x92
		.long	get_vart13	# 0x93
		.long	get_vart14	# 0x94
		.long	get_vart15	# 0x95
		.long	get_vart16	# 0x96
		.long	get_vart17	# 0x97
		.long	get_varp10	# 0x98
		.long	get_varp11	# 0x99
		.long	get_varp12	# 0x9a
		.long	get_varp13	# 0x9b
		.long	get_varp14	# 0x9c
		.long	get_varp15	# 0x9d
		.long	get_varp16	# 0x9e
		.long	get_varp17	# 0x9f
		.long	get_vart20	# 0xa0
		.long	get_vart21	# 0xa1
		.long	unif_address	# 0xa2
		.long	get_vart23	# 0xa3
		.long	get_vart24	# 0xa4
		.long	get_vart25	# 0xa5
		.long	get_vart26	# 0xa6
		.long	get_vart27	# 0xa7
		.long	get_varp20	# 0xa8
		.long	get_varp21	# 0xa9
		.long	get_varp22	# 0xaa
		.long	get_varp23	# 0xab
		.long	get_varp24	# 0xac
		.long	get_varp25	# 0xad
		.long	get_varp26	# 0xae
		.long	get_varp27	# 0xaf
		.long	get_vart30	# 0xb0
		.long	get_vart31	# 0xb1
		.long	get_vart32	# 0xb2
		.long	get_cons_by_value	# 0xb3
		.long	get_vart34	# 0xb4
		.long	get_vart35	# 0xb5
		.long	get_vart36	# 0xb6
		.long	get_vart37	# 0xb7
		.long	get_varp30	# 0xb8
		.long	get_varp31	# 0xb9
		.long	get_varp32	# 0xba
		.long	get_varp33	# 0xbb
		.long	get_varp34	# 0xbc
		.long	get_varp35	# 0xbd
		.long	get_varp36	# 0xbe
		.long	get_varp37	# 0xbf
		.long	get_vart40	# 0xc0
		.long	get_vart41	# 0xc1
		.long	get_vart42	# 0xc2
		.long	get_vart43	# 0xc3
		.long	Runif_cons_by_value	# 0xc4
		.long	get_vart45	# 0xc5
		.long	get_vart46	# 0xc6
		.long	get_vart47	# 0xc7
		.long	get_varp40	# 0xc8
		.long	get_varp41	# 0xc9
		.long	get_varp42	# 0xca
		.long	get_varp43	# 0xcb
		.long	get_varp44	# 0xcc
		.long	get_varp45	# 0xcd
		.long	get_varp46	# 0xce
		.long	get_varp47	# 0xcf
		.long	get_vart50	# 0xd0
		.long	get_vart51	# 0xd1
		.long	get_vart52	# 0xd2
		.long	get_vart53	# 0xd3
		.long	get_vart54	# 0xd4
		.long	copy_valp	# 0xd5
		.long	get_vart56	# 0xd6
		.long	get_vart57	# 0xd7
		.long	get_varp50	# 0xd8
		.long	get_varp51	# 0xd9
		.long	get_varp52	# 0xda
		.long	get_varp53	# 0xdb
		.long	get_varp54	# 0xdc
		.long	get_varp55	# 0xdd
		.long	get_varp56	# 0xde
		.long	get_varp57	# 0xdf
		.long	get_vart60	# 0xe0
		.long	get_vart61	# 0xe1
		.long	get_vart62	# 0xe2
		.long	get_vart63	# 0xe3
		.long	get_vart64	# 0xe4
		.long	get_vart65	# 0xe5
		.long	gcalloc		# 0xe6
		.long	get_vart67	# 0xe7
		.long	get_varp60	# 0xe8
		.long	get_varp61	# 0xe9
		.long	get_varp62	# 0xea
		.long	get_varp63	# 0xeb
		.long	get_varp64	# 0xec
		.long	get_varp65	# 0xed
		.long	get_varp66	# 0xee
		.long	get_varp67	# 0xef
		.long	get_vart70	# 0xf0
		.long	get_vart71	# 0xf1
		.long	get_vart72	# 0xf2
		.long	get_vart73	# 0xf3
		.long	get_vart74	# 0xf4
		.long	get_vart75	# 0xf5
		.long	get_vart76	# 0xf6
		.long	InterpreterLoop		# 0xf7 NOOP
		.long	get_varp70	# 0xf8
		.long	get_varp71	# 0xf9
		.long	get_varp72	# 0xfa
		.long	get_varp73	# 0xfb
		.long	get_varp74	# 0xfc
		.long	get_varp75	# 0xfd
		.long	get_varp76	# 0xfe
		.long	get_varp77	# 0xff
		.long   0x00000000
	# End csect HeadReadTable{RW}

	.csect	HeadWriteTable{RW},3
		.long 	neck		# 0x00
		.long	Wunify_void	# 0x01
		.long	tunif_void	# 0x02
		.long	Wend_seq	# 0x03
		.long	Wunif_cons	# 0x04
		.long	neckcon		# 0x05
		.long	alloc		# 0x06
		.long	Wunify_nil	# 0x07
		.long	get_cons0	# 0x08
		.long	get_cons1	# 0x09
		.long	get_cons2	# 0x0a
		.long	get_cons3	# 0x0b
		.long	get_cons4	# 0x0c
		.long	get_cons5	# 0x0d
		.long	get_cons6	# 0x0e
		.long	get_cons7	# 0x0f
		.long	get_struct0	# 0x10
		.long	get_struct1	# 0x11
		.long	get_struct2	# 0x12
		.long	get_struct3	# 0x13
		.long	get_struct4	# 0x14
		.long	get_struct5	# 0x15
		.long	get_struct6	# 0x16
		.long	get_struct7	# 0x17
		.long	unused		# 0x18
		.long	unused		# 0x19
		.long	unused		# 0x1a
		.long	unused		# 0x1b
		.long	unused		# 0x1c
		.long	unused		# 0x1d
		.long	unused		# 0x1e
		.long	unused		# 0x1f
		.long	get_list0	# 0x20
		.long	get_list1	# 0x21
		.long	get_list2	# 0x22
		.long	get_list3	# 0x23
		.long	get_list4	# 0x24
		.long	get_list5	# 0x25
		.long	get_list6	# 0x26
		.long	get_list7	# 0x27
		.long	get_nil0	# 0x28
		.long	get_nil1	# 0x29
		.long	get_nil2	# 0x2a
		.long	get_nil3	# 0x2b
		.long	get_nil4	# 0x2c
		.long	get_nil5	# 0x2d
		.long	get_nil6	# 0x2e
		.long	get_nil7	# 0x2f
		.long	get_valt0	# 0x30
		.long	get_valt1	# 0x31
		.long	get_valt2	# 0x32
		.long	get_valt3	# 0x33
		.long	get_valt4	# 0x34
		.long	get_valt5	# 0x35
		.long	get_valt6	# 0x36
		.long	get_valt7	# 0x37
		.long	get_valp0	# 0x38
		.long	get_valp1	# 0x39
		.long	get_valp2	# 0x3a
		.long	get_valp3	# 0x3b
		.long	get_valp4	# 0x3c
		.long	get_valp5	# 0x3d
		.long	get_valp6	# 0x3e
		.long	get_valp7	# 0x3f
		.long	Wunify_vart0	# 0x40
		.long	Wunify_vart1	# 0x41
		.long	Wunify_vart2	# 0x42
		.long	Wunify_vart3	# 0x43
		.long	Wunify_vart4	# 0x44
		.long	Wunify_vart5	# 0x45
		.long	Wunify_vart6	# 0x46
		.long	Wunify_vart7	# 0x47
		.long	Wunify_varp0	# 0x48
		.long	Wunify_varp1	# 0x49
		.long	Wunify_varp2	# 0x4a
		.long	Wunify_varp3	# 0x4b
		.long	Wunify_varp4	# 0x4c
		.long	Wunify_varp5	# 0x4d
		.long	Wunify_varp6	# 0x4e
		.long	Wunify_varp7	# 0x4f
		.long	Wunify_valt0	# 0x50
		.long	Wunify_valt1	# 0x51
		.long	Wunify_valt2	# 0x52
		.long	Wunify_valt3	# 0x53
		.long	Wunify_valt4	# 0x54
		.long	Wunify_valt5	# 0x55
		.long	Wunify_valt6	# 0x56
		.long	Wunify_valt7	# 0x57
		.long	Wunify_valp0	# 0x58
		.long	Wunify_valp1	# 0x59
		.long	Wunify_valp2	# 0x5a
		.long	Wunify_valp3	# 0x5b
		.long	Wunify_valp4	# 0x5c
		.long	Wunify_valp5	# 0x5d
		.long	Wunify_valp6	# 0x5e
		.long	Wunify_valp7	# 0x5f
		.long	Wtunify_vart0	# 0x60
		.long	Wtunify_vart1	# 0x61
		.long	Wtunify_vart2	# 0x62
		.long	Wtunify_vart3	# 0x63
		.long	Wtunify_vart4	# 0x64
		.long	Wtunify_vart5	# 0x65
		.long	Wtunify_vart6	# 0x66
		.long	Wtunify_vart7	# 0x67
		.long	Wtunify_varp0	# 0x68
		.long	Wtunify_varp1	# 0x69
		.long	Wtunify_varp2	# 0x6a
		.long	Wtunify_varp3	# 0x6b
		.long	Wtunify_varp4	# 0x6c
		.long	Wtunify_varp5	# 0x6d
		.long	Wtunify_varp6	# 0x6e
		.long	Wtunify_varp7	# 0x6f
		.long	Wtunify_valt0	# 0x70
		.long	Wtunify_valt1	# 0x71
		.long	Wtunify_valt2	# 0x72
		.long	Wtunify_valt3	# 0x73
		.long	Wtunify_valt4	# 0x74
		.long	Wtunify_valt5	# 0x75
		.long	Wtunify_valt6	# 0x76
		.long	Wtunify_valt7	# 0x77
		.long	Wtunify_valp0	# 0x78
		.long	Wtunify_valp1	# 0x79
		.long	Wtunify_valp2	# 0x7a
		.long	Wtunify_valp3	# 0x7b
		.long	Wtunify_valp4	# 0x7c
		.long	Wtunify_valp5	# 0x7d
		.long	Wtunify_valp6	# 0x7e
		.long	Wtunify_valp7	# 0x7f
		.long	get_vart00	# 0x80
		.long	get_vart01	# 0x81
		.long	get_vart02	# 0x82
		.long	get_vart03	# 0x83
		.long	get_vart04	# 0x84
		.long	get_vart05	# 0x85
		.long	get_vart06	# 0x86
		.long	get_vart07	# 0x87
		.long	get_varp00	# 0x88
		.long	get_varp01	# 0x89
		.long	get_varp02	# 0x8a
		.long	get_varp03	# 0x8b
		.long	get_varp04	# 0x8c
		.long	get_varp05	# 0x8d
		.long	get_varp06	# 0x8e
		.long	get_varp07	# 0x8f
		.long	get_vart10	# 0x90
		.long	unused		# 0x91
		.long	get_vart12	# 0x92
		.long	get_vart13	# 0x93
		.long	get_vart14	# 0x94
		.long	get_vart15	# 0x95
		.long	get_vart16	# 0x96
		.long	get_vart17	# 0x97
		.long	get_varp10	# 0x98
		.long	get_varp11	# 0x99
		.long	get_varp12	# 0x9a
		.long	get_varp13	# 0x9b
		.long	get_varp14	# 0x9c
		.long	get_varp15	# 0x9d
		.long	get_varp16	# 0x9e
		.long	get_varp17	# 0x9f
		.long	get_vart20	# 0xa0
		.long	get_vart21	# 0xa1
		.long	unif_address	# 0xa2
		.long	get_vart23	# 0xa3
		.long	get_vart24	# 0xa4
		.long	get_vart25	# 0xa5
		.long	get_vart26	# 0xa6
		.long	get_vart27	# 0xa7
		.long	get_varp20	# 0xa8
		.long	get_varp21	# 0xa9
		.long	get_varp22	# 0xaa
		.long	get_varp23	# 0xab
		.long	get_varp24	# 0xac
		.long	get_varp25	# 0xad
		.long	get_varp26	# 0xae
		.long	get_varp27	# 0xaf
		.long	get_vart30	# 0xb0
		.long	get_vart31	# 0xb1
		.long	get_vart32	# 0xb2
		.long	get_cons_by_value	# 0xb3
		.long	get_vart34	# 0xb4
		.long	get_vart35	# 0xb5
		.long	get_vart36	# 0xb6
		.long	get_vart37	# 0xb7
		.long	get_varp30	# 0xb8
		.long	get_varp31	# 0xb9
		.long	get_varp32	# 0xba
		.long	get_varp33	# 0xbb
		.long	get_varp34	# 0xbc
		.long	get_varp35	# 0xbd
		.long	get_varp36	# 0xbe
		.long	get_varp37	# 0xbf
		.long	get_vart40	# 0xc0
		.long	get_vart41	# 0xc1
		.long	get_vart42	# 0xc2
		.long	get_vart43	# 0xc3
		.long	Wunif_cons_by_value	# 0xc4
		.long	get_vart45	# 0xc5
		.long	get_vart46	# 0xc6
		.long	get_vart47	# 0xc7
		.long	get_varp40	# 0xc8
		.long	get_varp41	# 0xc9
		.long	get_varp42	# 0xca
		.long	get_varp43	# 0xcb
		.long	get_varp44	# 0xcc
		.long	get_varp45	# 0xcd
		.long	get_varp46	# 0xce
		.long	get_varp47	# 0xcf
		.long	get_vart50	# 0xd0
		.long	get_vart51	# 0xd1
		.long	get_vart52	# 0xd2
		.long	get_vart53	# 0xd3
		.long	get_vart54	# 0xd4
		.long	copy_valp	# 0xd5
		.long	get_vart56	# 0xd6
		.long	get_vart57	# 0xd7
		.long	get_varp50	# 0xd8
		.long	get_varp51	# 0xd9
		.long	get_varp52	# 0xda
		.long	get_varp53	# 0xdb
		.long	get_varp54	# 0xdc
		.long	get_varp55	# 0xdd
		.long	get_varp56	# 0xde
		.long	get_varp57	# 0xdf
		.long	get_vart60	# 0xe0
		.long	get_vart61	# 0xe1
		.long	get_vart62	# 0xe2
		.long	get_vart63	# 0xe3
		.long	get_vart64	# 0xe4
		.long	get_vart65	# 0xe5
		.long	gcalloc		# 0xe6
		.long	get_vart67	# 0xe7
		.long	get_varp60	# 0xe8
		.long	get_varp61	# 0xe9
		.long	get_varp62	# 0xea
		.long	get_varp63	# 0xeb
		.long	get_varp64	# 0xec
		.long	get_varp65	# 0xed
		.long	get_varp66	# 0xee
		.long	get_varp67	# 0xef
		.long	get_vart70	# 0xf0
		.long	get_vart71	# 0xf1
		.long	get_vart72	# 0xf2
		.long	get_vart73	# 0xf3
		.long	get_vart74	# 0xf4
		.long	get_vart75	# 0xf5
		.long	get_vart76	# 0xf6
		.long	InterpreterLoop		# 0xf7 NOOP
		.long	get_varp70	# 0xf8
		.long	get_varp71	# 0xf9
		.long	get_varp72	# 0xfa
		.long	get_varp73	# 0xfb
		.long	get_varp74	# 0xfc
		.long	get_varp75	# 0xfd
		.long	get_varp76	# 0xfe
		.long	get_varp77	# 0xff
		.long   0x00000000
	# End csect HeadWriteTable{RW}

	.csect	BodyTable{RW}, 3   
		.long	proceed		# 0x00
		.long	push_void	# 0x01
		.long	tpush_void	# 0x02
		.long	push_end	# 0x03
		.long	push_cons	# 0x04
		.long	InterpreterLoop	# 0x05 NOOP
		.long	dealloc		# 0x06
		.long	escape		# 0x07
		.long	put_cons0	# 0x08
		.long	put_cons1	# 0x09
		.long	put_cons2	# 0x0a
		.long	put_cons3	# 0x0b
		.long	put_cons4	# 0x0c
		.long	put_cons5	# 0x0d
		.long	put_cons6	# 0x0e
		.long	put_cons7	# 0x0f
		.long	put_struct0	# 0x10
		.long	put_struct1	# 0x11
		.long	put_struct2	# 0x12
		.long	put_struct3	# 0x13
		.long	put_struct4	# 0x14
		.long	put_struct5	# 0x15
		.long	put_struct6	# 0x16
		.long	put_struct7	# 0x17
		.long	unused		# 0x18
		.long	unused		# 0x19
		.long	unused		# 0x1a
		.long	unused		# 0x1b
		.long	unused		# 0x1c
		.long	unused		# 0x1d
		.long	unused		# 0x1e
		.long	unused		# 0x1f
		.long	put_list0	# 0x20
		.long	put_list1	# 0x21
		.long	put_list2	# 0x22
		.long	put_list3	# 0x23
		.long	put_list4	# 0x24
		.long	put_list5	# 0x25
		.long	put_list6	# 0x26
		.long	put_list7	# 0x27
		.long	put_nil0	# 0x28
		.long	put_nil1	# 0x29
		.long	put_nil2	# 0x2a
		.long	put_nil3	# 0x2b
		.long	put_nil4	# 0x2c
		.long	put_nil5	# 0x2d
		.long	put_nil6	# 0x2e
		.long	put_nil7	# 0x2f
		.long	put_void0	# 0x30
		.long	put_void1	# 0x31
		.long	put_void2	# 0x32
		.long	put_void3	# 0x33
		.long	put_void4	# 0x34
		.long	put_void5	# 0x35
		.long	put_void6	# 0x36
		.long	put_void7	# 0x37
		.long	put_varp0	# 0x38
		.long	put_varp1	# 0x39
		.long	put_varp2	# 0x3a
		.long	put_varp3	# 0x3b
		.long	put_varp4	# 0x3c
		.long	put_varp5	# 0x3d
		.long	put_varp6	# 0x3e
		.long	put_varp7	# 0x3f
		.long	push_vart0	# 0x40
		.long	push_vart1	# 0x41
		.long	push_vart2	# 0x42
		.long	push_vart3	# 0x43
		.long	push_vart4	# 0x44
		.long	push_vart5	# 0x45
		.long	push_vart6	# 0x46
		.long	push_vart7	# 0x47
		.long	push_varp0	# 0x48
		.long	push_varp1	# 0x49
		.long	push_varp2	# 0x4a
		.long	push_varp3	# 0x4b
		.long	push_varp4	# 0x4c
		.long	push_varp5	# 0x4d
		.long	push_varp6	# 0x4e
		.long	push_varp7	# 0x4f
		.long	push_valt0	# 0x50
		.long	push_valt1	# 0x51
		.long	push_valt2	# 0x52
		.long	push_valt3	# 0x53
		.long	push_valt4	# 0x54
		.long	push_valt5	# 0x55
		.long	push_valt6	# 0x56
		.long	push_valt7	# 0x57
		.long	push_valp0	# 0x58
		.long	push_valp1	# 0x59
		.long	push_valp2	# 0x5a
		.long	push_valp3	# 0x5b
		.long	push_valp4	# 0x5c
		.long	push_valp5	# 0x5d
		.long	push_valp6	# 0x5e
		.long	push_valp7	# 0x5f
		.long	tpush_vart0	# 0x60
		.long	tpush_vart1	# 0x61
		.long	tpush_vart2	# 0x62
		.long	tpush_vart3	# 0x63
		.long	tpush_vart4	# 0x64
		.long	tpush_vart5	# 0x65
		.long	tpush_vart6	# 0x66
		.long	tpush_vart7	# 0x67
		.long	tpush_varp0	# 0x68
		.long	tpush_varp1	# 0x69
		.long	tpush_varp2	# 0x6a
		.long	tpush_varp3	# 0x6b
		.long	tpush_varp4	# 0x6c
		.long	tpush_varp5	# 0x6d
		.long	tpush_varp6	# 0x6e
		.long	tpush_varp7	# 0x6f
		.long	tpush_valt0	# 0x70
		.long	tpush_valt1	# 0x71
		.long	tpush_valt2	# 0x72
		.long	tpush_valt3	# 0x73
		.long	tpush_valt4	# 0x74
		.long	tpush_valt5	# 0x75
		.long	tpush_valt6	# 0x76
		.long	tpush_valt7	# 0x77
		.long	tpush_valp0	# 0x78
		.long	tpush_valp1	# 0x79
		.long	tpush_valp2	# 0x7a
		.long	tpush_valp3	# 0x7b
		.long	tpush_valp4	# 0x7c
		.long	tpush_valp5	# 0x7d
		.long	tpush_valp6	# 0x7e
		.long	tpush_valp7	# 0x7f
		.long	put_valt00	# 0x80
		.long	put_valt01	# 0x81
		.long	put_valt02	# 0x82
		.long	put_valt03	# 0x83
		.long	put_valt04	# 0x84
		.long	put_valt05	# 0x85
		.long	put_valt06	# 0x86
		.long	put_valt07	# 0x87
		.long	put_valp00	# 0x88
		.long	put_valp01	# 0x89
		.long	put_valp02	# 0x8a
		.long	put_valp03	# 0x8b
		.long	put_valp04	# 0x8c
		.long	put_valp05	# 0x8d
		.long	put_valp06	# 0x8e
		.long	put_valp07	# 0x8f
		.long	put_valt10	# 0x90
		.long	unused		# 0x91
		.long	put_valt12	# 0x92
		.long	put_valt13	# 0x93
		.long	put_valt14	# 0x94
		.long	put_valt15	# 0x95
		.long	put_valt16	# 0x96
		.long	put_valt17	# 0x97
		.long	put_valp10	# 0x98
		.long	put_valp11	# 0x99
		.long	put_valp12	# 0x9a
		.long	put_valp13	# 0x9b
		.long	put_valp14	# 0x9c
		.long	put_valp15	# 0x9d
		.long	put_valp16	# 0x9e
		.long	put_valp17	# 0x9f
		.long	put_valt20	# 0xa0
		.long	put_valt21	# 0xa1
		.long	unused		# 0xa2
		.long	put_valt23	# 0xa3
		.long	put_valt24	# 0xa4
		.long	put_valt25	# 0xa5
		.long	put_valt26	# 0xa6
		.long	put_valt27	# 0xa7
		.long	put_valp20	# 0xa8
		.long	put_valp21	# 0xa9
		.long	put_valp22	# 0xaa
		.long	put_valp23	# 0xab
		.long	put_valp24	# 0xac
		.long	put_valp25	# 0xad
		.long	put_valp26	# 0xae
		.long	put_valp27	# 0xaf
		.long	put_valt30	# 0xb0
		.long	put_valt31	# 0xb1
		.long	put_valt32	# 0xb2
		.long	unused		# 0xb3
		.long	put_valt34	# 0xb4
		.long	put_valt35	# 0xb5
		.long	put_valt36	# 0xb6
		.long	put_valt37	# 0xb7
		.long	put_valp30	# 0xb8
		.long	put_valp31	# 0xb9
		.long	put_valp32	# 0xba
		.long	put_valp33	# 0xbb
		.long	put_valp34	# 0xbc
		.long	put_valp35	# 0xbd
		.long	put_valp36	# 0xbe
		.long	put_valp37	# 0xbf
		.long	put_valt40	# 0xc0
		.long	put_valt41	# 0xc1
		.long	put_valt42	# 0xc2
		.long	put_valt43	# 0xc3
		.long	unused		# 0xc4
		.long	put_valt45	# 0xc5
		.long	put_valt46	# 0xc6
		.long	put_valt47	# 0xc7
		.long	put_valp40	# 0xc8
		.long	put_valp41	# 0xc9
		.long	put_valp42	# 0xca
		.long	put_valp43	# 0xcb
		.long	put_valp44	# 0xcc
		.long	put_valp45	# 0xcd
		.long	put_valp46	# 0xce
		.long	put_valp47	# 0xcf
		.long	put_valt50	# 0xd0
		.long	put_valt51	# 0xd1
		.long	put_valt52	# 0xd2
		.long	put_valt53	# 0xd3
		.long	put_valt54	# 0xd4
		.long	unused		# 0xd5
		.long	put_valt56	# 0xd6
		.long	put_valt57	# 0xd7
		.long	put_valp50	# 0xd8
		.long	put_valp51	# 0xd9
		.long	put_valp52	# 0xda
		.long	put_valp53	# 0xdb
		.long	put_valp54	# 0xdc
		.long	put_valp55	# 0xdd
		.long	put_valp56	# 0xde
		.long	put_valp57	# 0xdf
		.long	put_valt60	# 0xe0
		.long	put_valt61	# 0xe1
		.long	put_valt62	# 0xe2
		.long	put_valt63	# 0xe3
		.long	put_valt64	# 0xe4
		.long	put_valt65	# 0xe5
		.long	unused		# 0xe6
		.long	put_valt67	# 0xe7
		.long	put_valp60	# 0xe8
		.long	put_valp61	# 0xe9
		.long	put_valp62	# 0xea
		.long	put_valp63	# 0xeb
		.long	put_valp64	# 0xec
		.long	put_valp65	# 0xed
		.long	put_valp66	# 0xee
		.long	put_valp67	# 0xef
		.long	put_valt70	# 0xf0
		.long	put_valt71	# 0xf1
		.long	put_valt72	# 0xf2
		.long	put_valt73	# 0xf3
		.long	put_valt74	# 0xf4
		.long	put_valt75	# 0xf5
		.long	put_valt76	# 0xf6
		.long	InterpreterLoop	# 0xf7 NOOP
		.long	put_valp70	# 0xf8
		.long	put_valp71	# 0xf9
		.long	put_valp72	# 0xfa
		.long	put_valp73	# 0xfb
		.long	put_valp74	# 0xfc
		.long	put_valp75	# 0xfd
		.long	put_valp76	# 0xfe
		.long	put_valp77	# 0xff
		 .long	0x00000000
	  # END .csect	BodyTable{RW}

   .csect	BodyEscTable{RW}, 3   
		.long	break		# 0x00
		.long	ecut		# 0x01
		.long	dcut		# 0x02
		.long	push_nil	# 0x03
		.long	eval_cons	# 0x04
		.long	InterpreterLoop		# 0x05 NOOP
		.long	unused		# 0x06
		.long	unused		# 0x07
		.long	unused		# 0x08
		.long	call_indirect	# 0x09
		.long	call		# 0x0a
		.long	exec_indirect	# 0x0b
		.long	exec		# 0x0c
		.long	call_clause	# 0x0d
		.long	exec_addr	# 0x0e
		.long	fail		# 0x0f
		.long	vart0		# 0x10
		.long	vart1		# 0x11
		.long	vart2		# 0x12
		.long	vart3		# 0x13
		.long	vart4		# 0x14
		.long	vart5		# 0x15
		.long	vart6		# 0x16
		.long	vart7		# 0x17
		.long	varp0		# 0x18
		.long	varp1		# 0x19
		.long	varp2		# 0x1a
		.long	varp3		# 0x1b
		.long	varp4		# 0x1c
		.long	varp5		# 0x1d
		.long	varp6		# 0x1e
		.long	varp7		# 0x1f
		.long	tvart0		# 0x20
		.long	tvart1		# 0x21
		.long	tvart2		# 0x22
		.long	tvart3		# 0x23
		.long	tvart4		# 0x24
		.long	tvart5		# 0x25
		.long	tvart6		# 0x26
		.long	tvart7		# 0x27
		.long	tvarp0		# 0x28
		.long	tvarp1		# 0x29
		.long	tvarp2		# 0x2a
		.long	tvarp3		# 0x2b
		.long	tvarp4		# 0x2c
		.long	tvarp5		# 0x2d
		.long	tvarp6		# 0x2e
		.long	tvarp7		# 0x2f
		.long	more_choicepoints	# 0x30
		.long	cCut		# 0x31
		.long	cdCut		# 0x32
		.long	cCutFail	# 0x33
		.long	cdCutFail	# 0x34
		.long	cut		# 0x35
		.long	failexit	# 0x36
		.long	label_env	# 0x37
		.long	unused		# 0x38
		.long	unused		# 0x39
		.long	unused		# 0x3a
		.long	unused		# 0x3b
		.long	unused		# 0x3c
		.long	unused		# 0x3d
		.long	unused		# 0x3e
		.long	unused		# 0x3f
		.long	testt0		# 0x40
		.long	testt1		# 0x41
		.long	testt2		# 0x42
		.long	testt3		# 0x43
		.long	testt4		# 0x44
		.long	testt5		# 0x45
		.long	testt6		# 0x46
		.long	testt7		# 0x47
		.long	testp0		# 0x48
		.long	testp1		# 0x49
		.long	testp2		# 0x4a
		.long	testp3		# 0x4b
		.long	testp4		# 0x4c
		.long	testp5		# 0x4d
		.long	testp6		# 0x4e
		.long	testp7		# 0x4f
		.long	pop_valt0	# 0x50
		.long	pop_valt1	# 0x51
		.long	pop_valt2	# 0x52
		.long	pop_valt3	# 0x53
		.long	pop_valt4	# 0x54
		.long	pop_valt5	# 0x55
		.long	pop_valt6	# 0x56
		.long	pop_valt7	# 0x57
		.long	pop_valp0	# 0x58
		.long	pop_valp1	# 0x59
		.long	pop_valp2	# 0x5a
		.long	pop_valp3	# 0x5b
		.long	pop_valp4	# 0x5c
		.long	pop_valp5	# 0x5d
		.long	pop_valp6	# 0x5e
		.long	pop_valp7	# 0x5f
		.long	evalt0		# 0x60
		.long	evalt1		# 0x61
		.long	evalt2		# 0x62
		.long	evalt3		# 0x63
		.long	evalt4		# 0x64
		.long	evalt5		# 0x65
		.long	evalt6		# 0x66
		.long	evalt7		# 0x67
		.long	evalp0		# 0x68
		.long	evalp1		# 0x69
		.long	evalp2		# 0x6a
		.long	evalp3		# 0x6b
		.long	evalp4		# 0x6c
		.long	evalp5		# 0x6d
		.long	evalp6		# 0x6e
		.long	evalp7		# 0x6f
		.long	pop_vart0	# 0x70
		.long	pop_vart1	# 0x71
		.long	pop_vart2	# 0x72
		.long	pop_vart3	# 0x73
		.long	pop_vart4	# 0x74
		.long	pop_vart5	# 0x75
		.long	pop_vart6	# 0x76
		.long	pop_vart7	# 0x77
		.long	pop_varp0	# 0x78
		.long	pop_varp1	# 0x79
		.long	pop_varp2	# 0x7a
		.long	pop_varp3	# 0x7b
		.long	pop_varp4	# 0x7c
		.long	pop_varp5	# 0x7d
		.long	pop_varp6	# 0x7e
		.long	pop_varp7	# 0x7f
		.long	put_vart00	# 0x80
		.long	put_vart01	# 0x81
		.long	put_vart02	# 0x82
		.long	put_vart03	# 0x83
		.long	put_vart04	# 0x84
		.long	put_vart05	# 0x85
		.long	put_vart06	# 0x86
		.long	put_vart07	# 0x87
		.long	unused		# 0x88
		.long	unused		# 0x89
		.long	unused		# 0x8a
		.long	unused		# 0x8b
		.long	unused		# 0x8c
		.long	unused		# 0x8d
		.long	unused		# 0x8e
		.long	unused		# 0x8f
		.long	put_vart10	# 0x90
		.long	unused		# 0x91
		.long	put_vart12	# 0x92
		.long	put_vart13	# 0x93
		.long	put_vart14	# 0x94
		.long	put_vart15	# 0x95
		.long	put_vart16	# 0x96
		.long	put_vart17	# 0x97
		.long	cCutsp		# 0x98
		.long	addition	# 0x99
		.long	subtraction	# 0x9a
		.long	multiplication	# 0x9b
		.long	int_division	# 0x9c
		.long	division	# 0x9d
		.long	mod			# 0x9e
		.long	power		# 0x9f
		.long	put_vart20	# 0xa0
		.long	put_vart21	# 0xa1
		.long	unused		# 0xa2
		.long	put_vart23	# 0xa3
		.long	put_vart24	# 0xa4
		.long	put_vart25	# 0xa5
		.long	put_vart26	# 0xa6
		.long	put_vart27	# 0xa7
		.long	unused		# 0xa8
		.long	int			# 0xa9
		.long	float		# 0xaa
		.long	floor		# 0xab
		.long	ceiling		# 0xac
		.long	round		# 0xad
		.long	max			# 0xae
		.long	min			# 0xaf
		.long	put_vart30	# 0xb0
		.long	put_vart31	# 0xb1
		.long	put_vart32	# 0xb2
		.long	unused		# 0xb3
		.long	put_vart34	# 0xb4
		.long	put_vart35	# 0xb5
		.long	put_vart36	# 0xb6
		.long	put_vart37	# 0xb7
		.long	unused		# 0xb8
		.long	sqrt		# 0xb9
		.long	abs			# 0xba
		.long	exp			# 0xbb
		.long	ln			# 0xbc
		.long	increment	# 0xbd
		.long	decrement	# 0xbe
		.long	negate		# 0xbf
		.long	put_vart40	# 0xc0
		.long	put_vart41	# 0xc1
		.long	put_vart42	# 0xc2
		.long	put_vart43	# 0xc3
		.long	unused		# 0xc4
		.long	put_vart45	# 0xc5
		.long	put_vart46	# 0xc6
		.long	put_vart47	# 0xc7
		.long	unused		# 0xc8
		.long	sin			# 0xc9
		.long	cos			# 0xca
		.long	tan			# 0xcb
		.long	asin		# 0xcc
		.long	acos		# 0xcd
		.long	atan		# 0xce
		.long	bin_butnot	# 0xcf
		.long	put_vart50	# 0xd0
		.long	put_vart51	# 0xd1
		.long	put_vart52	# 0xd2
		.long	put_vart53	# 0xd3
		.long	put_vart54	# 0xd4
		.long	unused		# 0xd5
		.long	put_vart56	# 0xd6
		.long	put_vart57	# 0xd7
		.long	unused		# 0xd8
		.long	equal		# 0xd9
		.long	less_equal	# 0xda
		.long	greater_equal	# 0xdb
		.long	less_than	# 0xdc
		.long	greater_than	# 0xdd
		.long	not_equal	# 0xde
		.long	bin_bitshift	# 0xdf
		.long	put_vart60	# 0xe0
		.long	put_vart61	# 0xe1
		.long	put_vart62	# 0xe2
		.long	put_vart63	# 0xe3
		.long	put_vart64	# 0xe4
		.long	put_vart65	# 0xe5
		.long	dcut_exec	# 0xe6
		.long	put_vart67	# 0xe7
		.long	unused		# 0xe8
		.long	maxint		# 0xe9		
		.long	maxfloat	# 0xea
		.long	pi		# 0xeb
		.long	cputime		# 0xec
		.long	bin_bitand	# 0xed
		.long	bin_bitor	# 0xee
		.long	bin_biteq	# 0xef
		.long	put_vart70	# 0xf0
		.long	put_vart71	# 0xf1
		.long	put_vart72	# 0xf2
		.long	put_vart73	# 0xf3
		.long	put_vart74	# 0xf4
		.long	put_vart75	# 0xf5
		.long	put_vart76	# 0xf6
		.long	InterpreterLoop	# 0xf7	NOOP
		.long	unary_not	# 0xf8
		.long	binary_and	# 0xf9
		.long	binary_or	# 0xfa
		.long	binary_xor	# 0xfb
		.long	binary_compare	# 0xfc
		.long	rel_equal	# 0xfd
		.long	rel_greater	# 0xfe
		.long	rel_less	# 0xff
		.long	0x00000000
	# End csect BodyEscTable{RW}

	.csect BodyEscClauseTable{RW},3
		.long	break		# 0x00
		.long	Cecut		# 0x01
		.long	Cdcut		# 0x02
		.long	push_nil	# 0x03
		.long	Ceval_cons	# 0x04
		.long	InterpreterLoop		# 0x05 NOOP
		.long	unused		# 0x06
		.long	unused		# 0x07
		.long	unused		# 0x08
		.long	Ccall_indirect	# 0x09
		.long	Ccall		# 0x0a
		.long	Cexec_indirect	# 0x0b
		.long	Cexec		# 0x0c
		.long	Ccall_clause	# 0x0d
		.long	Cexec_addr	# 0x0e
		.long	Cfail		# 0x0f
		.long	Cvart0		# 0x10
		.long	Cvart1		# 0x11
		.long	Cvart2		# 0x12
		.long	Cvart3		# 0x13
		.long	Cvart4		# 0x14
		.long	Cvart5		# 0x15
		.long	Cvart6		# 0x16
		.long	Cvart7		# 0x17
		.long	Cvarp0		# 0x18
		.long	Cvarp1		# 0x19
		.long	Cvarp2		# 0x1a
		.long	Cvarp3		# 0x1b
		.long	Cvarp4		# 0x1c
		.long	Cvarp5		# 0x1d
		.long	Cvarp6		# 0x1e
		.long	Cvarp7		# 0x1f
		.long	Ctvart0		# 0x20
		.long	Ctvart1		# 0x21
		.long	Ctvart2		# 0x22
		.long	Ctvart3		# 0x23
		.long	Ctvart4		# 0x24
		.long	Ctvart5		# 0x25
		.long	Ctvart6		# 0x26
		.long	Ctvart7		# 0x27
		.long	Ctvarp0		# 0x28
		.long	Ctvarp1		# 0x29
		.long	Ctvarp2		# 0x2a
		.long	Ctvarp3		# 0x2b
		.long	Ctvarp4		# 0x2c
		.long	Ctvarp5		# 0x2d
		.long	Ctvarp6		# 0x2e
		.long	Ctvarp7		# 0x2f
		.long	Body		# 0x30
		.long	CcCut		# 0x31
		.long	CcdCut		# 0x32
		.long	CcCutFail	# 0x33
		.long	CcdCutFail	# 0x34
		.long	Ccut		# 0x35
		.long	Cfailexit	# 0x36
		.long	Body		# 0x37
		.long	unused		# 0x38
		.long	unused		# 0x39
		.long	unused		# 0x3a
		.long	unused		# 0x3b
		.long	unused		# 0x3c
		.long	unused		# 0x3d
		.long	unused		# 0x3e
		.long	unused		# 0x3f
		.long	Ctestt0		# 0x40
		.long	Ctestt1		# 0x41
		.long	Ctestt2		# 0x42
		.long	Ctestt3		# 0x43
		.long	Ctestt4		# 0x44
		.long	Ctestt5		# 0x45
		.long	Ctestt6		# 0x46
		.long	Ctestt7		# 0x47
		.long	Ctestp0		# 0x48
		.long	Ctestp1		# 0x49
		.long	Ctestp2		# 0x4a
		.long	Ctestp3		# 0x4b
		.long	Ctestp4		# 0x4c
		.long	Ctestp5		# 0x4d
		.long	Ctestp6		# 0x4e
		.long	Ctestp7		# 0x4f
		.long	Cpop_valt0	# 0x50
		.long	Cpop_valt1	# 0x51
		.long	Cpop_valt2	# 0x52
		.long	Cpop_valt3	# 0x53
		.long	Cpop_valt4	# 0x54
		.long	Cpop_valt5	# 0x55
		.long	Cpop_valt6	# 0x56
		.long	Cpop_valt7	# 0x57
		.long	Cpop_valp0	# 0x58
		.long	Cpop_valp1	# 0x59
		.long	Cpop_valp2	# 0x5a
		.long	Cpop_valp3	# 0x5b
		.long	Cpop_valp4	# 0x5c
		.long	Cpop_valp5	# 0x5d
		.long	Cpop_valp6	# 0x5e
		.long	Cpop_valp7	# 0x5f
		.long	Cevalt0		# 0x60
		.long	Cevalt1		# 0x61
		.long	Cevalt2		# 0x62
		.long	Cevalt3		# 0x63
		.long	Cevalt4		# 0x64
		.long	Cevalt5		# 0x65
		.long	Cevalt6		# 0x66
		.long	Cevalt7		# 0x67
		.long	Cevalp0		# 0x68
		.long	Cevalp1		# 0x69
		.long	Cevalp2		# 0x6a
		.long	Cevalp3		# 0x6b
		.long	Cevalp4		# 0x6c
		.long	Cevalp5		# 0x6d
		.long	Cevalp6		# 0x6e
		.long	Cevalp7		# 0x6f
		.long	Cpop_vart0	# 0x70
		.long	Cpop_vart1	# 0x71
		.long	Cpop_vart2	# 0x72
		.long	Cpop_vart3	# 0x73
		.long	Cpop_vart4	# 0x74
		.long	Cpop_vart5	# 0x75
		.long	Cpop_vart6	# 0x76
		.long	Cpop_vart7	# 0x77
		.long	Cpop_varp0	# 0x78
		.long	Cpop_varp1	# 0x79
		.long	Cpop_varp2	# 0x7a
		.long	Cpop_varp3	# 0x7b
		.long	Cpop_varp4	# 0x7c
		.long	Cpop_varp5	# 0x7d
		.long	Cpop_varp6	# 0x7e
		.long	Cpop_varp7	# 0x7f
		.long	put_vart00	# 0x80
		.long	put_vart01	# 0x81
		.long	put_vart02	# 0x82
		.long	put_vart03	# 0x83
		.long	put_vart04	# 0x84
		.long	put_vart05	# 0x85
		.long	put_vart06	# 0x86
		.long	put_vart07	# 0x87
		.long	unused		# 0x88
		.long	unused		# 0x89
		.long	unused		# 0x8a
		.long	unused		# 0x8b
		.long	unused		# 0x8c
		.long	unused		# 0x8d
		.long	unused		# 0x8e
		.long	unused		# 0x8f
		.long	put_vart10	# 0x90
		.long	unused		# 0x91
		.long	put_vart12	# 0x92
		.long	put_vart13	# 0x93
		.long	put_vart14	# 0x94
		.long	put_vart15	# 0x95
		.long	put_vart16	# 0x96
		.long	put_vart17	# 0x97
		.long	CcCutsp		# 0x98
		.long	Caddition	# 0x99
		.long	Csubtraction	# 0x9a
		.long	Cmultiplication	# 0x9b
		.long	Cint_division	# 0x9c
		.long	Cdivision	# 0x9d
		.long	Cmod		# 0x9e
		.long	Cpower		# 0x9f
		.long	put_vart20	# 0xa0
		.long	put_vart21	# 0xa1
		.long	unused		# 0xa2
		.long	put_vart23	# 0xa3
		.long	put_vart24	# 0xa4
		.long	put_vart25	# 0xa5
		.long	put_vart26	# 0xa6
		.long	put_vart27	# 0xa7
		.long	unused		# 0xa8
		.long	Cint		# 0xa9
		.long	Cfloat		# 0xaa
		.long	Cfloor		# 0xab
		.long	Cceiling	# 0xac
		.long	Cround		# 0xad
		.long	Cmax		# 0xae
		.long	Cmin		# 0xaf
		.long	put_vart30	# 0xb0
		.long	put_vart31	# 0xb1
		.long	put_vart32	# 0xb2
		.long	unused		# 0xb3
		.long	put_vart34	# 0xb4
		.long	put_vart35	# 0xb5
		.long	put_vart36	# 0xb6
		.long	put_vart37	# 0xb7
		.long	unused		# 0xb8
		.long	Csqrt		# 0xb9
		.long	Cabs		# 0xba
		.long	Cexp		# 0xbb
		.long	Cln			# 0xbc
		.long	Cincrement	# 0xbd
		.long	Cdecrement	# 0xbe
		.long	Cnegate		# 0xbf
		.long	put_vart40	# 0xc0
		.long	put_vart41	# 0xc1
		.long	put_vart42	# 0xc2
		.long	put_vart43	# 0xc3
		.long	unused		# 0xc4
		.long	put_vart45	# 0xc5
		.long	put_vart46	# 0xc6
		.long	put_vart47	# 0xc7
		.long	unused		# 0xc8
		.long	Csin		# 0xc9
		.long	Ccos		# 0xca
		.long	Ctan		# 0xcb
		.long	Casin		# 0xcc
		.long	Cacos		# 0xcd
		.long	Catan		# 0xce
		.long	Cbin_butnot	# 0xcf
		.long	put_vart50	# 0xd0
		.long	put_vart51	# 0xd1
		.long	put_vart52	# 0xd2
		.long	put_vart53	# 0xd3
		.long	put_vart54	# 0xd4
		.long	unused		# 0xd5
		.long	put_vart56	# 0xd6
		.long	put_vart57	# 0xd7
		.long	unused		# 0xd8
		.long	Cequal		# 0xd9
		.long	Cless_equal	# 0xda
		.long	Cgreater_equal	# 0xdb
		.long	Cless_than	# 0xdc
		.long	Cgreater_than	# 0xdd
		.long	Cnot_equal	# 0xde
		.long	Cbin_bitshift	# 0xdf
		.long	put_vart60	# 0xe0
		.long	put_vart61	# 0xe1
		.long	put_vart62	# 0xe2
		.long	put_vart63	# 0xe3
		.long	put_vart64	# 0xe4
		.long	put_vart65	# 0xe5
		.long	Cdcut_exec	# 0xe6
		.long	put_vart67	# 0xe7
		.long	unused		# 0xe8
		.long	Cmaxint		# 0xe9		
		.long	Cmaxfloat	# 0xea
		.long	Cpi			# 0xeb
		.long	Ccputime	# 0xec
		.long	Cbin_bitand	# 0xed
		.long	Cbin_bitor	# 0xee
		.long	Cbin_biteq	# 0xef
		.long	put_vart70	# 0xf0
		.long	put_vart71	# 0xf1
		.long	put_vart72	# 0xf2
		.long	put_vart73	# 0xf3
		.long	put_vart74	# 0xf4
		.long	put_vart75	# 0xf5
		.long	put_vart76	# 0xf6
		.long	InterpreterLoop	# 0xf7	NOOP
		.long	Cunary_not	# 0xf8
		.long	Cbinary_and	# 0xf9
		.long	Cbinary_or	# 0xfa
		.long	Cbinary_xor	# 0xfb
		.long	Cbinary_compare	# 0xfc
		.long	Crel_equal	# 0xfd
		.long	Crel_greater# 0xfe
		.long	Crel_less	# 0xff
		.long	0x00000000
# End csect BodyEscClauseTable{RW}

   .csect	erroraddr{RW}
	  .long		0x00000001
	  .long		0x00000000
   # End   csect   erroraddr	


# .bss section
