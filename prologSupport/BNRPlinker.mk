#
#  $Header: /disc9/sniff/repository/BNRProlog/prologSupport/RCS/BNRPlinker.mk,v 1.4 1997/09/16 10:26:57 harrisj Exp $
#
# 
#  $Log: BNRPlinker.mk,v $
# Revision 1.4  1997/09/16  10:26:57  harrisj
# Use xlc_r on AIX and use the OPTIMIZE_LEVEL flag to specify optimisation
#
# Revision 1.3  1997/03/24  05:15:36  wcorebld
# Use -O2 compile option on AIX when DO_RELEASE is set
#
# Revision 1.2  1997/03/20  17:17:19  harrisj
# The optimization flag was not being inserted properly
# when DO_RELEASE!=0
#
# Revision 1.1  1997/03/14  16:54:36  harrisj
# Make support files for BNR Prolog.
#
#
# Common makefile definitions for the BNRP libraries
#

LINK	:= $(CC)


LINK_CMD = $(LINK) $(LDFLAGS) $(OTHER_LDFLAGS) -o `basename $@` $(MAIN) $(LIBS)  $(OTHER_LIBS)
