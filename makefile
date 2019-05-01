#
#  $Header: /disc9/sniff/repository/BNRProlog/RCS/makefile,v 1.21 1998/01/20 15:14:56 thawker Exp $
#
#  $Log: makefile,v $
# Revision 1.21  1998/01/20  15:14:56  thawker
# Added "Source_Release" goal to build all non-object (.a, .c) files
# and copy the whole resulting source to a source release directory
# where it can be built without using an existing Prolog.
# Changed "release" goal to use macros instead of explicit directory
# names when copying
#
# Revision 1.20  1997/04/01  17:02:34  harrisj
# make "release" goal now copies the correct files from Panels_3.1 and from panel_files
#
# Revision 1.19  1997/03/14  17:25:46  harrisj
# SNiFFified the makefiles so that BNRP would be
# QP compliant
#
# Revision 1.18  1997/02/27  17:23:50  harrisj
# To support HPUX 10.10 a command line flag HPUX_VERSION is needed
# If this flag is set to 10, then hpux_10 is defined
#
# Revision 1.17  1996/10/11  13:41:42  harrisj
# Modified to allow compiling with debug options and/or with
# memory leak detectors.
# Set DEBUG_PROLOG to be non-zero to compile with debug options
# Set DO_MEMORY_LEAK_DETECTION to be non-zero to check for leaks.
#
# Revision 1.16  1996/08/28  11:27:21  harrisj
# Changed Release goal to chgrp to dept_7r34
#
# Revision 1.15  1996/05/20  16:44:16  neilj
# Fixed PWD variable to use $(shell pwd)
#
# Revision 1.14  1996/01/03  15:58:47  yanzhou
# Added new targets to make libslee_listener.a from slee_listener.p.
#
# Revision 1.13  1995/12/12  18:21:53  yanzhou
# CFLAGS changed to include DAFLAGS (+DA1.0 or +DA1.1).
# Can now produce HP9000/800 (PA RISC 1.0) libs and executables.
#
# Revision 1.12  1995/12/07  14:17:27  yanzhou
# For nav88k and hpux9: CFLAGS cleaned up.
#
# Revision 1.11  1995/12/06  16:10:36  yanzhou
# Now the target "Release" copies utilities/*.[ap] to the release dir.
#
# Revision 1.10  1995/12/04  00:12:58  yanzhou
# Now supports IBM Power/RS6000 AIX 4.1.
#
# Revision 1.9  1995/11/09  14:36:35  yanzhou
# Minor changes.
#
# Revision 1.8  1995/11/07  15:50:41  harrisja
# utilities goal wasn't executing so changed to BNRPutilities and worked
# Possible conflict with utilities dir name???
#
# Revision 1.7  1995/11/07  14:33:41  harrisja
# Modified for ease of portability
#
# Revision 1.6  1995/10/19  16:19:44  harrisja
# xBNRProlog goal called 'base' and not 'basefile'
#
# Revision 1.5  1995/10/19  14:37:43  harrisja
# changed base goal to basefile.
# pass basefile goal compiler and flags info. to make base.o and libBNRPbase.a
# change Release to copy BNRPbase.h and libBNRPbase.a to release directory
#
# Revision 1.4  95/10/06  17:52:51  17:52:51  harrisja (Jason Harris)
# *** empty log message ***
# 
# Revision 1.3  1995/10/06  17:51:20  harrisja
# Removed -g option from NAV compile
#
# Revision 1.2  1995/10/06  16:38:10  harrisja
# Added optimization option to compile
#
# Revision 1.1  1995/09/22  11:25:09  harrisja
# Initial version.
#
#
#
############################################################################################
#                                                                                          #
# DESCRIPTION:  Makefile for the Prolog libraries and executables                        #
#                                                                                          #
#     OPTIONS:	DO_FAST_LINK          Avoid reinstantiating existing templates             #
#             	DO_PURIFY             Build with purify                                    #
#             	DO_LOAD_SHARE         Build with load sharing                              #
#             	DO_INT_TEST           Build with integration test options                  #
#             	DEBUG_LEVEL=0/1/2/3   Debugging intensity control [default=0]              #
#                                                                                          #
############################################################################################

SNIFF_MAKEDIR=.sniffdir

include $(SNIFF_MAKEDIR)/macros.incl
include $(SNIFF_MAKEDIR)/ofiles.incl
include $(SNIFF_MAKEDIR)/vpath.incl
include $(WORKSPACE)/BNRProlog/prologSupport/BNRP.mk
include $(GMS_DIR)/common.mk

LINK_TARGET	:=	dummy_link_target
RELINK_TARGET	:=	dummy_relink_target
LIB_TARGET	:=	dummy_lib_target

SUBDIRS 	:=	$(BNRP_BASE_DIR)	\
			$(BNRP_XBASE_DIR)	\
			$(BNRP_SOURCE_DIR)	\
			$(BNRP_XSOURCE_DIR)	\
			$(BNRP_UTILS_DIR)	\
			$(BNRP_DIR)/prologSupport
 
 
#######################################################################
##                         Make a release.                           ##
##-----------------------<================>--------------------------##
## Ensure the release directories are created.			     ##
##                                                                   ##

ifndef BNRP_RELEASE_DIR
   BNRP_RELEASE_DIR		:=	$(BNRP_DIR)/release
endif

Release:	_clean_release_dirs release
	@ cp -f CHANGELOG $(BNRP_RELEASE_DIR);			\
	chmod -R ugo+r,ug+w $(BNRP_RELEASE_DIR);		\
	chmod -R a+x $(BNRP_RELEASE_DIR)/bin

_clean_release_dirs:
	@ -rm -rf $(BNRP_RELEASE_DIR)

release:
	@ -mkdir -m 755 -p $(BNRP_RELEASE_DIR)
	@ -mkdir -m 755 -p $(BNRP_RELEASE_DIR)/lib
	@ -mkdir -m 755 -p $(BNRP_RELEASE_DIR)/bin
	@ -mkdir -m 755 -p $(BNRP_RELEASE_DIR)/include
	@ -mkdir -m 755 -p $(BNRP_RELEASE_DIR)/utilities/Panels_3.1/panel_files
	@ -cp $(BNRP_SOURCE_DIR)/libBNRProlog.a $(BNRP_RELEASE_DIR)/lib
	@ -cp $(BNRP_SOURCE_DIR)/BNRProlog $(BNRP_RELEASE_DIR)/bin
	@ -cp $(BNRP_SOURCE_DIR)/BNRProlog.h $(BNRP_RELEASE_DIR)/include
	@ -cp $(BNRP_SOURCE_DIR)/wollongong.h $(BNRP_RELEASE_DIR)/include
	@ -cp $(BNRP_SOURCE_DIR)/BNRPbase.h $(BNRP_RELEASE_DIR)/include
	@ -cp $(BNRP_SOURCE_DIR)/slee_listener.h $(BNRP_RELEASE_DIR)/include
	@ -cp $(BNRP_XSOURCE_DIR)/xwollongong.h $(BNRP_RELEASE_DIR)/include
	@ -cp $(BNRP_XSOURCE_DIR)/libxBNRProlog.a $(BNRP_RELEASE_DIR)/lib
	@ -cp $(BNRP_XSOURCE_DIR)/xBNRProlog $(BNRP_RELEASE_DIR)/bin
	@ -cp $(BNRP_XBASE_DIR)/base $(BNRP_RELEASE_DIR)/bin
	@ -cp $(BNRP_XBASE_DIR)/base.a $(BNRP_RELEASE_DIR)/bin
	@ -cp $(BNRP_XBASE_DIR)/libBNRPbase.a $(BNRP_RELEASE_DIR)/lib
	@ -cp $(BNRP_UTILS_DIR)/*.[ap] $(BNRP_RELEASE_DIR)/utilities
	@ -mv $(BNRP_RELEASE_DIR)/utilities/libslee_listener.a $(BNRP_RELEASE_DIR)/lib
	@ -cp $(BNRP_PANELS_DIR)/panels.a $(BNRP_RELEASE_DIR)/utilities/Panels_3.1
	@ -cp $(BNRP_PANELS_DIR)/panel_trace.p $(BNRP_RELEASE_DIR)/utilities/Panels_3.1
	@ -cp $(BNRP_PANEL_FILES_DIR)/*.[ap] $(BNRP_RELEASE_DIR)/utilities/Panels_3.1/panel_files
	@ -cp $(BNRP_PANEL_FILES_DIR)/Editing $(BNRP_RELEASE_DIR)/utilities/Panels_3.1/panel_files
	@ -cp $(BNRP_PANEL_FILES_DIR)/Info $(BNRP_RELEASE_DIR)/utilities/Panels_3.1/panel_files
	@ -cp $(BNRP_PANEL_FILES_DIR)/Interface $(BNRP_RELEASE_DIR)/utilities/Panels_3.1/panel_files

	
 #######################################################################
##                         Make a source release.                    ##
##-----------------------<================>--------------------------##
## Ensure the source release directories are created.		     ##
##                                                                   ##
 
ifndef BNRP_SOURCE_RELEASE_DIR
   BNRP_SOURCE_RELEASE_DIR		:=	$(BNRP_DIR)/source_release/BNRProlog
endif
 
Source_Release:	_clean_source_release_dirs do_source_release
 
_clean_source_release_dirs:
	rm -rf $(BNRP_SOURCE_RELEASE_DIR)
 
do_source_release:
	 $(MAKE) -C $(BNRP_BASE_DIR) --no-print-directory source_target
	 $(MAKE) -C $(BNRP_XBASE_DIR) --no-print-directory source_target
	 $(MAKE) -C $(BNRP_UTILS_DIR) --no-print-directory source_target
	 $(MAKE) -C $(BNRP_PANELS_DIR) --no-print-directory
	 $(MAKE) -C $(BNRP_PANEL_FILES_DIR) --no-print-directory
	 mkdir -m 755 -p $(BNRP_SOURCE_RELEASE_DIR)
	 cp -rf $(BNRP_BASE_DIR) $(BNRP_SOURCE_RELEASE_DIR)
	 cp -rf $(BNRP_XBASE_DIR) $(BNRP_SOURCE_RELEASE_DIR)
	 cp -rf $(BNRP_SOURCE_DIR) $(BNRP_SOURCE_RELEASE_DIR)
	 cp -rf $(BNRP_XSOURCE_DIR) $(BNRP_SOURCE_RELEASE_DIR)
	 cp -rf $(BNRP_UTILS_DIR) $(BNRP_SOURCE_RELEASE_DIR)
	 cp -rf prologSupport $(BNRP_SOURCE_RELEASE_DIR)
	 cp -rf .sniffdir $(BNRP_SOURCE_RELEASE_DIR)
	 cp -f CHANGELOG BNRProlog.shared makefile $(BNRP_SOURCE_RELEASE_DIR)
 
