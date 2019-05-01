#
#  $Header: /disc9/sniff/repository/BNRProlog/xsource/RCS/makefile,v 1.10 1998/01/20 15:22:24 thawker Exp $
#
#  $Log: makefile,v $
# Revision 1.10  1998/01/20  15:22:24  thawker
# Added BNRProlog.h as a target to fix error caused if
# $(LIBRARY TARGET) was made twice without a clean
#
# Revision 1.9  1997/03/21  10:59:56  harrisj
# Forced a symbolic link to be made to BNRProlog.h
# Including the source directory caused conflicts
# due to core.h and memory.h being include files for Motif or X11R5.
#
# Revision 1.8  1997/03/14  17:25:59  harrisj
# SNiFFified the makefiles so that BNRP would be
# QP compliant
#
# Revision 1.7  1996/10/11  13:41:53  harrisj
# Modified to allow compiling with debug options and/or with
# memory leak detectors.
# Set DEBUG_PROLOG to be non-zero to compile with debug options
# Set DO_MEMORY_LEAK_DETECTION to be non-zero to check for leaks.
#
# Revision 1.6  1996/02/01  03:58:38  yanzhou
# Minor change to find ../source/BNRProlog.h automatically.
#
# Revision 1.5  1995/12/04  00:12:57  yanzhou
# Now supports IBM Power/RS6000 AIX 4.1.
#
# Revision 1.4  1995/11/10  14:36:45  yanzhou
# Added target `clean'.
#
# Revision 1.3  1995/11/10  14:21:06  yanzhou
# Added `randlib $@ || true', so that if `ranlib' is missing, it will still succeed.
#
# Revision 1.2  1995/11/07  10:44:28  yanzhou
# New files xwollongong.[hc] created.
#
# Revision 1.1  1995/09/22  11:25:19  harrisja
# Initial version.
#
#

SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk

INCLUDE		:= $(XINCLUDE)
LIB_TARGET	:= libxBNRProlog.a

OFILES	:= XProlog.o \
	 ProWindows.o \
	 ProFiles.o \
	 ProEvents.o \
	 ProMenus.o \
	 ProGraf.o \
	 ProText.o \
	 scale.o \
	 xwollongong.o

LIBS		+=  xBNRProlog BNRProlog
OTHER_LIBS	+= $(XLIBS)
OTHER_CFLAGS	+= $(XDFLAGS)
OTHER_LDFLAGS	+= -L. -L$(BNRP_SOURCE_DIR) $(ALL_CFLAGS) $(XLIB_DIRS)
LIBRARY_TARGET	:= libxBNRProlog.a
MAIN		:= Prolog.o

all:: $(SNIFF_TARGETS)

xBNRProlog: $(LIBRARY_TARGET) Prolog.o
	@ $(MAKE_TARGET_SH)     $@\
	"$(LINK_CMD)"\
	$(MAKE_TARGET_PARAMS)

$(LIBRARY_TARGET) :: BNRProlog.h

BNRProlog.h:
	ln -fs $(BNRP_SOURCE_DIR)/BNRProlog.h .

clean::
	rm -f Prolog.o BNRProlog.h

include $(GMS_DIR)/common.mk
include $(WORKSPACE)/BNRProlog/prologSupport/BNRPlinker.mk
