#
#  $Header: /disc9/sniff/repository/BNRProlog/prologSupport/RCS/BNRP.mk,v 1.20 2000/11/03 02:42:22 mcclymon Exp $
#
#  $Log: BNRP.mk,v $
# Revision 1.20  2000/11/03  02:42:22  mcclymon
# Changed for v5.0.6 and also added compiler directive +a1
#
# Revision 1.19  1999/01/06  23:58:22  csavage
# Updated for 5.0.5 release
#
# Revision 1.18  1998/06/10  02:36:16  csavage
# 5.0.4 release changes
#
# Revision 1.17  1998/03/31  11:31:57  csavage
# Settings for 5.0.3 release
#
# Revision 1.16  1998/03/27  08:01:08  csavage
# *** empty log message ***
#
# Revision 1.15  1998/03/26  15:52:16  csavage
# Updated for AIX 4.2.1 platform
#
# Revision 1.14  1998/03/16  14:59:57  wcorebld
# *** empty log message ***
#
# Revision 1.13  1998/03/10  09:24:27  wcorebld
# *** empty log message ***
#
# Revision 1.12  1998/02/13  00:58:12  wcorebld
# *** empty log message ***
#
# Revision 1.11  1998/01/20  15:02:49  thawker
# Replaced unused SunOS macro definition section
# with solaris macro definition section and definitions
#
# Revision 1.10  1998/01/05  11:10:05  harrisj
# Modified to allow HSC or non-HSC to be built on AIX
# depending on command line flag (default is HSC)
#
# Revision 1.9  1997/11/24  10:37:47  harrisj
# BNRP.mk includes the version information required to construct the predicate
# version\1.  The makefile for build_base now constructs a file
# containing the version\1 predicate during the build process.
#
# Revision 1.8  1997/09/16  10:40:01  harrisj
# Use GMS v1.0.4 and BNRP v4.4.9 to build BNRP v4.4.10
#
# Revision 1.7  1997/09/16  10:26:54  harrisj
# Use xlc_r on AIX and use the OPTIMIZE_LEVEL flag to specify optimisation
#
# Revision 1.6  1997/07/31  15:57:33  harrisj
# Added BNRP_finite primitive to return whether or not
# a number is finite.  Must use +DA1.1 to compile.
#
# Revision 1.5  1997/04/02  00:32:56  wcorebld
# Released v4.4.9
#
# Revision 1.4  1997/03/24  05:10:10  wcorebld
# Use -O2 for AIX when DO_RELEASE is set.  Also increased
# maxmem to 8192 from 4096
#
# Revision 1.3  1997/03/24  02:12:06  wcorebld
# Released v4.4.8
#
# Revision 1.2  1997/03/20  17:17:14  harrisj
# The optimization flag was not being inserted properly
# when DO_RELEASE!=0
#
#
# Common makefile definitions for the BNRP libraries
#
#
#######################################################################
##			BNRP v5.0.6				     ##
#######################################################################
VERSION_MAJOR :=	5
VERSION_MINOR :=	0
VERSION_MAINT :=	6

#######################################################################
##                                                                   ##
##                   3rd party product versions.                     ##
##-----------------------<================>--------------------------##
## BNRProlog:		5.0.3                                        ##
## GMS			1.0.8					     ##
## Motif		1.2					     ##
## X11R5                                                             ##

ifndef BNR_PROLOG_RELEASE_DIR
   BNR_PROLOG_RELEASE_DIR	:=	$(SHARED_OBJ)/BNRProlog/Releases/BNRP-v($VERSION_MAJOR).($VERSION_MINOR).($VERSION_MAINT)
endif

ifndef GMS_DIR
      GMS_DIR		:=	$(SHARED_OBJ)/GMS/Releases/GMS_v1.0.9
endif

#
# *** BNRP specific dirs
#

BNRP_DIR		:=	$(SNIFF_RELATIVE_ROOT_DIR)/BNRProlog

BNRP_BASE_DIR		:=	$(BNRP_DIR)/build_base
BNRP_XBASE_DIR		:=	$(BNRP_DIR)/base_source
BNRP_SOURCE_DIR		:=	$(BNRP_DIR)/source
BNRP_XSOURCE_DIR	:=	$(BNRP_DIR)/xsource
BNRP_UTILS_DIR		:=	$(BNRP_DIR)/utilities
BNRP_PANELS_DIR		:=	$(BNRP_UTILS_DIR)/Panels_3.1
BNRP_PANEL_FILES_DIR	:=	$(BNRP_PANELS_DIR)/panel_files

#
# *** Other common BNRP include directories
#

# BNR Prolog locations - use current release if not otherwise specified

BNR_PROLOG		:= $(BNR_PROLOG_RELEASE_DIR)/bin/BNRProlog
BNR_PROLOG_COMPILER	:= $(BNR_PROLOG_RELEASE_DIR)/utilities/compile.a

# Flag to compile debug version of HSC
ifndef HSC_DEBUG
   HSC_DEBUG		:= 0
endif

ifeq "$(PLATFORM)" "rs6000-ibm-aix4.2.1"
OTHER_CFLAGS		+= -qchars=signed -qmaxmem=8192 -qproto -qarch=ppc -Dunix -D_AIX 
XDFLAGS			:= -DSYSV
XINCLUDE		:=
XLIBS			:= Xm Xt X11 m
XLIB_DIRS		:=
MULTI_THREADED		:= 1
ifndef HSC
HSC			:= 1
endif
endif


ifeq "$(PLATFORM)" "rs6000-ibm-aix4.1.5"
OTHER_CFLAGS		+= -qchars=signed -qmaxmem=8192 -qproto -qarch=ppc -Dunix -D_AIX
XDFLAGS			:= -DSYSV
XINCLUDE		:=
XLIBS			:= Xm Xt X11 m
XLIB_DIRS		:=
MULTI_THREADED		:= 1
ifndef HSC
HSC			:= 1
endif
endif

ifeq "$(PLATFORM)" "pa_risc-hp-hpux9.0"
HP_ARCHITECTURE		:= 1.1
OTHER_CFLAGS		+= -Ae -Dunix -Dhpux -Dhppa
XDFLAGS			:= -DSYSV
XINCLUDE		:= /usr/include/X11R5 /usr/include/Motif1.2
XLIBS			:= Xm Xt X11 m PW
XLIB_DIRS		:= -L/usr/lib/Motif1.2 -L/usr/lib/X11R5
HSC			:= 0
endif

ifeq "$(PLATFORM)" "pa_risc-hp-hpux10.20"
OTHER_CFLAGS		+= -Ae +e -Dunix -Dhpux -Dhppa -Dhpux_10 +a1
XDFLAGS			:= -DSYSV
XINCLUDE		:= /usr/include/X11R5 /usr/include/Motif1.2
XLIBS			:= Xm Xt X11 m PW
XLIB_DIRS		:= -L/usr/lib/Motif1.2 -L/usr/lib/X11R5
HSC			:= 0
endif

ifeq "$(PLATFORM)" "pa_risc-hp-hpux10.0"
OTHER_CFLAGS		+= -Ae +e -Dunix -Dhpux -Dhppa -Dhpux_10
XDFLAGS			:= -DSYSV
XINCLUDE		:= /usr/include/X11R5 /usr/include/Motif1.2
XLIBS			:= Xm Xt X11 m PW
XLIB_DIRS		:= -L/usr/lib/Motif1.2 -L/usr/lib/X11R5
HSC			:= 0
endif

ifeq "$(PLATFORM)" "pa_risc1.0-hp-hpux9.0"
OTHER_CFLAGS		+= -g -Ae -Dunix -Dhpux -Dhppa +DA1.0 +DS1.0
XDFLAGS			:= -DSYSV
XINCLUDE		:= /usr/include/X11R5 /usr/include/Motif1.2
XLIBS			:= Xm Xt X11 m PW
XLIB_DIRS		:= -L/usr/lib/Motif1.2 -L/usr/lib/X11R5
HSC			:= 0
endif

ifeq "$(PLATFORM)" "nav-88k"
OTHER_CFLAGS		+= -Dm88k -Xlinker -YP,:/usr/lib:/usr/ccs/lib:/usr/local/lib
OTHER_LIBS		+= -lnsl -lsocket
XDFLAGS			:= -DSYSV
XINCLUDE		:=
XLIBS			:= Xm Xt X11 m form
XLIB_DIRS		:=
HSC			:= 0
endif

ifeq "$(PLATFORM)" "sparc-sun-solaris2.3"
OTHER_CFLAGS		+= -DSTRINGS_ALLOWED -DNO_REGEX -DUSE_RE_COMP \
			-DNO_ISDIR -DUSE_GETWD -DR4_INTRINSICS
OTHER_LIBS		+= nsl socket
XDFLAGS			:= -DSYSV
XINCLUDE		:= /usr/openwin/include /usr/dt/include
XLIBS			:= Xm Xt Xmu X11 m
XLIB_DIRS		:= -L/usr/lib/debug/malloc.o -L/usr/lib/debug/mallocmap.o \
			-L/usr/dt/lib -L/usr/openwin/lib -L/lib
HSC			:= 0
endif

ifndef DO_RELEASE
DO_RELEASE		:= 0
endif

ifneq ($(DO_RELEASE),0)
OPTIMISE_LEVEL		:= 2
endif

# Add this flag if building HSC
ifneq ($(HSC),0)
OTHER_CFLAGS		+= -DHSC
endif
