#
#  $Header: /disc9/sniff/repository/BNRProlog/build_base/RCS/makefile,v 1.6 1998/01/20 15:16:48 thawker Exp $
#
#  $Log: makefile,v $
# Revision 1.6  1998/01/20  15:16:48  thawker
# Added "source_target" goal to build all non-object targets
#
# Revision 1.5  1997/11/24  10:37:49  harrisj
# BNRP.mk includes the version information required to construct the predicate
# version\1.  The makefile for build_base now constructs a file
# containing the version\1 predicate during the build process.
#
# Revision 1.4  1997/03/20  17:17:24  harrisj
# The optimization flag was not being inserted properly
# when DO_RELEASE!=0
#
# Revision 1.3  1997/03/14  17:25:49  harrisj
# SNiFFified the makefiles so that BNRP would be
# QP compliant
#
# Revision 1.2  1995/11/07  14:24:20  harrisja
# Remove SNiFF reliances
#
# Revision 1.1  1995/09/22  11:25:11  harrisja
# Initial version.
#
#

SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk
include $(GMS_DIR)/common.mk
include $(WORKSPACE)/BNRProlog/prologSupport/BNRPlinker.mk

OFILES			:= base0.o base1.o base2.o base3.o base4.o base5.o
CPROLOG 		:= base0.c base1.c base2.c base3.c base4.c base5.c

baseX: $(OFILES)

$(CPROLOG): base0.prolog base1.prolog base2.prolog base3.prolog base4.prolog base5.prolog
.SUFFIXES: .prolog

INCLUDE		:= $(BNRP_SOURCE_DIR)

.prolog.c: base0.prolog base1.prolog base2.prolog base3.prolog base4.prolog base5.prolog
	$(BNR_PROLOG) -execute "[load_context('$(BNR_PROLOG_COMPILER)'),compiletoc($*('$<')),quit];error(2)"

version.prolog:
	@echo "version([$(VERSION_MAJOR),$(VERSION_MINOR),$(VERSION_MAINT)])." > version.prolog

base0.prolog: base0.p version.prolog
	cat version.prolog base0.p > base0.prolog

base1.prolog: base1.p base0.prolog
	cat base0.prolog base1.p > base1.prolog

base2.prolog: base2.p base1.prolog
	cat base1.prolog base2.p > base2.prolog

base3.prolog: base3.p base2.prolog
	cat base2.prolog base3.p > base3.prolog

base4.prolog: base4.p base3.prolog cmp_clause.p cmp_arithmetic.p
	cat base3.prolog base4.p cmp_clause.p cmp_arithmetic.p > base4.prolog

base5.prolog: base5.p base4.prolog base_pprint.p base_listener.p crias6.p constraint_network.p tasking.p networking.p
	cat base4.prolog base_pprint.p base_listener.p base5.p crias6.p constraint_network.p tasking.p networking.p > base5.prolog

base0.o: base0.c
	@ $(MAKE_TARGET_SH)     $@\
	"$(CC_CMD)"\
	$(MAKE_TARGET_PARAMS)   

base1.o: base1.c
	@ $(MAKE_TARGET_SH)     $@\
	"$(CC_CMD)"\
	$(MAKE_TARGET_PARAMS)   

base2.o: base2.c
	@ $(MAKE_TARGET_SH)     $@\
	"$(CC_CMD)"\
	$(MAKE_TARGET_PARAMS)   

base3.o: base3.c
	@ $(MAKE_TARGET_SH)     $@\
	"$(CC_CMD)"\
	$(MAKE_TARGET_PARAMS)   

base4.o: base4.c
	@ $(MAKE_TARGET_SH)     $@\
	"$(CC_CMD)"\
	$(MAKE_TARGET_PARAMS)   

base5.o: base5.c
	@ $(MAKE_TARGET_SH)     $@\
	"$(CC_CMD)"\
	$(MAKE_TARGET_PARAMS)   

source_target: $(CPROLOG)

clean::
	@ rm -f *.prolog
	@ rm -f base?.c

