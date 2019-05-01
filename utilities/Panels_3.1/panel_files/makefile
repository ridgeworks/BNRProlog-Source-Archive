#
#  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/panel_files/RCS/makefile,v 1.1 1997/03/14 17:16:42 harrisj Exp $
#
#  $Lo$
#
#

SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk


APROLOG := $(patsubst %.p,%.a,$(SNIFF_Prolog_FILES))

.SUFFIXES: .a

examples: $(APROLOG)

.p.a:
	$(BNR_PROLOG) -execute "[load_context('$(BNR_PROLOG_COMPILER)'),compile('$*'('$<')),quit];error(2)"

clean::
	@ rm -f *.a

include $(GMS_DIR)/common.mk 
