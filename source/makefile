#
#  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/makefile,v 1.9 1998/05/28 14:10:27 csavage Exp $
#
#  $Log: makefile,v $
# Revision 1.9  1998/05/28  14:10:27  csavage
# *** empty log message ***
#
# Revision 1.8  1998/01/05  11:09:01  harrisj
# Fixed clean goal to clean up all files regardless of
# being HSC or non-HSC.
#
# Revision 1.7  1997/12/22  17:01:29  harrisj
# Added support for HSC and to build HSC and non-HSC BNRP
#
# Revision 1.6  1997/03/14  17:25:54  harrisj
# SNiFFified the makefiles so that BNRP would be
# QP compliant
#
# Revision 1.5  1996/10/11  13:41:45  harrisj
# Modified to allow compiling with debug options and/or with
# memory leak detectors.
# Set DEBUG_PROLOG to be non-zero to compile with debug options
# Set DO_MEMORY_LEAK_DETECTION to be non-zero to check for leaks.
#
# Revision 1.4  1996/07/05  10:48:39  yanzhou
# Minor change in the "clean" target.
#
# Revision 1.3  1995/11/10  14:18:58  yanzhou
# Now executes `ranlib' on the target library, as it is a must on SunOS 4.1.3.
#
# Revision 1.2  1995/10/19  14:30:46  harrisja
# Added networkTCP.c and networkUDP.c.
# Modified to pick up base*.c from base_source directory.
#
# Revision 1.1  1995/09/22  11:25:15  harrisja
# Initial version.
#
#

#
#  makefile for BNR Prolog
#

SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk

LIB_TARGET		:= libBNRProlog.a

OTHER_OFILES	:= $(BNRP_BASE_DIR)/base0.o \
		$(BNRP_BASE_DIR)/base1.o \
		$(BNRP_BASE_DIR)/base2.o \
		$(BNRP_BASE_DIR)/base3.o \
		$(BNRP_BASE_DIR)/base4.o \
		$(BNRP_BASE_DIR)/base5.o \

ifneq ($(HSC),0)
OFILES          += HSC.o
HSC_INCL        := HSCmacros.incl \
                HSCheadMacros.incl \
                HSCheadWriteMacros.incl \
                HSCbodyMacros.incl \
                HSCbodyEscMacros.incl \
                HSCbodyEscClMacros.incl \
                HSCdebugMacros.incl
else
OFILES          += core.o
endif

ifneq ($(HSC_DEBUG),0)
OFILES          += coreTest.o
endif

OFILES		+= common_subex.o \
		  compare.o \
		  context.o \
		  embed.o \
		  external.o \
		  fsysprim.o \
		  hash.o \
		  hardware.o \
		  interpreter.o \
		  interval.o \
		  ioprim.o \
		  loader.o \
		  memory.o \
		  network.o \
		  networkTCP.o \
		  networkUDP.o \
		  parse.o \
		  prim.o \
		  procs.o \
		  pushpop.o \
		  rings.o \
		  state.o \
		  stats.o \
		  tasking.o \
		  utility.o \
		  wollongong.o \

LIBS		+= BNRProlog
OTHER_LIBS	+= m
OTHER_CFLAGS	+= -Dring0 -Dring1 -Dring2 -Dring3 -Dring4 -Dring5 -Dring6
OTHER_LDFLAGS	+= -L. $(ALL_CFLAGS)
LIBRARY_TARGET	:= libBNRProlog.a
MAIN		:= shell.o

all:: $(SNIFF_TARGETS)

BNRProlog: $(LIBRARY_TARGET) shell.o
	@ $(MAKE_TARGET_SH)     $@\
	"$(LINK_CMD)"\
	$(MAKE_TARGET_PARAMS)

clean::
	@ rm -f shell.o core.o coreTest.o HSC.o
	@ rm -f HSC_m4.s

ifneq ($(HSC),0)
HSC_m4.s: HSC.s $(HSC_INCL)
	m4 -B16384 HSC.s > $@

HSC.o: HSC_m4.s
	@ $(MAKE_TARGET_SH)     $@\
	  "$(CC_CMD)"\
	  $(MAKE_TARGET_PARAMS)
endif

include $(GMS_DIR)/common.mk
include $(WORKSPACE)/BNRProlog/prologSupport/BNRPlinker.mk
