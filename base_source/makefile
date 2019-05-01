#
#  $Header: /disc9/sniff/repository/BNRProlog/base_source/RCS/makefile,v 1.8 1998/01/20 15:20:20 thawker Exp $
#
#  $Log: makefile,v $
# Revision 1.8  1998/01/20  15:20:20  thawker
# Added "source_target" goal to build all non-object targets
#
# Revision 1.7  1997/03/20  17:17:21  harrisj
# The optimization flag was not being inserted properly
# when DO_RELEASE!=0
#
# Revision 1.6  1997/03/14  17:25:43  harrisj
# SNiFFified the makefiles so that BNRP would be
# QP compliant
#
# Revision 1.5  1995/11/10  14:17:27  yanzhou
# Now executes `ranlib' on the target library, as it is a must on SunOS 4.1.3.
#
# Revision 1.4  1995/11/07  14:24:18  harrisja
# Remove SNiFF reliances
#
# Revision 1.3  1995/10/20  08:45:22  harrisja
# chnaged base5.prolog reference to look in build_base directory
#
# Revision 1.2  1995/10/19  14:29:53  harrisja
# Modified to produce libBNRPbase.a.
#
# Revision 1.1  1995/09/22  11:25:07  harrisja
# Initial version.
#
#
SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/ofiles.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk 
include $(GMS_DIR)/common.mk
include $(WORKSPACE)/BNRProlog/prologSupport/BNRPlinker.mk

OFILES			:= base.o

INCLUDE			:= $(BNRP_SOURCE_DIR)
PROLOG = ContextsMenu.p \
	 PostEvent.p \
	 acton.p \
	 bounding_rect.p \
	 build_base.p \
	 button_class.p \
	 defaultevents.p \
	 dialogs.p \
	 dograf.p \
	 dotext.p \
	 dragregion.p \
	 editmenu.p \
	 field_class.p \
	 filemenu.p \
	 findmenu.p \
	 helpmenu.p \
	 list_class.p \
	 menus.p \
	 panel_sys.p \
	 panel_view.p \
	 panel_works.p \
	 pde_init.p \
	 pictures.p \
	 postscript.p \
	 resources.p \
	 stringlistresource.p \
	 textbox.p \
	 windowmenu.p \
	 windowpredicates.p \
	 windows.p \
	 $(BNRP_BASE_DIR)/base5.prolog

all::$(SNIFF_TARGETS)

base.a: base
	$(BNR_PROLOG) -execute "[load_context('$(BNR_PROLOG_COMPILER)'),compile(base),quit];error(2)"

libBNRPbase.a: base.o
	ar rc $@ $?
	ranlib $@ 2>/dev/null || true

base.o: base.c
	@ $(MAKE_TARGET_SH)     $@\
	"$(CC_CMD)"\
	$(MAKE_TARGET_PARAMS)   

base.c: base
	$(BNR_PROLOG) -execute "[load_context('$(BNR_PROLOG_COMPILER)'),compiletoc(base),quit];error(2)"

base: $(PROLOG)
	 sh cat_base.sh

source_target: base.a base.c

clean::
	@ rm -f base.c
	@ rm -f base.a
	@ rm -f libBNRPbase.a

