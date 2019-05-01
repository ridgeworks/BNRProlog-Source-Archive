#
#  $Header: /disc9/sniff/repository/BNRProlog/utilities/Panels_3.1/RCS/makefile,v 1.3 1997/03/14 17:25:52 harrisj Exp $
#
#  $Log: makefile,v $
# Revision 1.3  1997/03/14  17:25:52  harrisj
# SNiFFified the makefiles so that BNRP would be
# QP compliant
#
# Revision 1.2  1995/11/09  14:38:44  yanzhou
# Minor changes.
#
# Revision 1.1  1995/09/22  11:25:12  harrisja
# Initial version.
#
#

SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk

SUBDIRS:= $(BNRP_PANEL_FILES_DIR)

panels.a: panels.p panel_uif.p button_editor.p field_editor.p list_editor.p panel_editor.p
	@ $(BNR_PROLOG) -execute "[load_context('$(BNR_PROLOG_COMPILER)'),load_context('build.p'),build(panels),quit];error(2)"
	@ mv panels.p.a panels.a

include $(GMS_DIR)/common.mk 
