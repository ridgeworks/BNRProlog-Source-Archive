#
#  $Header: /disc9/sniff/repository/BNRProlog/utilities/RCS/makefile,v 1.8 1998/01/20 15:19:19 thawker Exp $
#
#  $Log: makefile,v $
# Revision 1.8  1998/01/20  15:19:19  thawker
# Added "source_target" goal to build all non-object targets
#
# Revision 1.7  1997/03/20  17:17:27  harrisj
# The optimization flag was not being inserted properly
# when DO_RELEASE!=0
#
# Revision 1.6  1997/03/14  17:25:57  harrisj
# SNiFFified the makefiles so that BNRP would be
# QP compliant
#
# Revision 1.5  1996/07/05  10:50:34  yanzhou
# Minor change in the "clean" target.
#
# Revision 1.4  1996/01/03  15:58:58  yanzhou
# Added new targets to make libslee_listener.a from slee_listener.p.
#
# Revision 1.3  1995/11/07  15:46:55  harrisja
# utilities goal wasn't beingexecuted by top level makefile
# for some unknown reason.  Changed it to BNRPutilities
#
# Revision 1.2  1995/11/07  14:24:21  harrisja
# Remove SNiFF reliances
#
# Revision 1.1  1995/09/22  11:25:18  harrisja
# Initial version.
#
#

SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk

SUBDIRS:= $(BNRP_PANELS_DIR)

INCLUDE		:= $(BNRP_SOURCE_DIR)

LIB_TARGET	:= libslee_listener.a

APROLOG := $(patsubst %.p,%.a,$(SNIFF_Prolog_FILES))

OFILES := slee_listener.o

.SUFFIXES: .a

all:: $(SNIFF_TARGETS)

utilities: $(APROLOG)

.p.a:
	$(BNR_PROLOG) -execute "[load_context('$(BNR_PROLOG_COMPILER)'),compile($*('$<')),quit];error(2)"

slee_listener.c: slee_listener.p
	$(BNR_PROLOG) -execute "[load_context('$(BNR_PROLOG_COMPILER)'),compiletoc($*('$<')),quit];error(2)"

source_target: slee_listener.c utilities
	$(MAKE) -C $(BNRP_PANELS_DIR) --no-print-directory

clean::
	@ rm -f *.a *.c


include $(GMS_DIR)/common.mk
include $(WORKSPACE)/BNRProlog/prologSupport/BNRPlinker.mk
