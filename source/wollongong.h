/*
*
*  $Header: /disc9/sniff/repository/BNRProlog/source/RCS/wollongong.h,v 1.2 1997/12/22 12:48:53 harrisj Exp $
*
*  $Log: wollongong.h,v $
 * Revision 1.2  1997/12/22  12:48:53  harrisj
 * list_to_asn1 changed to set errno to -9 when buffer is full and
 * still more to decode.
 * Made buffer pointer in asn1_to_list const.
 * Updated comments in header file
 *
 * Revision 1.1  1995/09/22  11:29:20  harrisja
 * Initial version.
 *
*
*/
/* This header file contains the prototypes of the add-on functions available
 in wollongong.c.  To use these functions, this file must be included in the 
application along with BNRProlog.h  */

#include "BNRProlog.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _NEEDS_PROTO

void BNRP_bindWollPrims(void);

BNRP_term addBytesToTerm(
	BNRP_TCB *tcb,
	char * ptr,
	unsigned long count,
	BNRP_term structName);

unsigned long removeBytesFromTerm(
	BNRP_term structTerm,
	char **buffer,
	unsigned long buf_size);

/* Sets errno on error as described in comment for list_to_asn1 */
BNRP_term asn1_to_list(
	BNRP_TCB *tcb, 
	const unsigned char bufRef[], 
	unsigned int bufLength, 
	unsigned int *bufRead);

/* Returns 0 on error and sets errno.  If errno is -9, the length of the buffer
is returned and not 0.
-1  = Term is not a list
-2  = Expecting an integer term and didn't get one in Prolog list.
	This error is also reported if while parsing the contents section of
	the list, the integer value is greater than 32767.  This is due to
	how Prolog encodes such integers.
-3  = Unexpected end of list after a constructor tag
-4  = Bad identifier
-5  = Expected integer is greater than 255
-6  = Length greater than 4 bytes
-7  = Indefinite length for primitive
-8  = Bad length
-9  = Bad Buffer
	This is reported when the buffer does not have room for at least 1 byte
	for the identifier and 1 byte for the length.  It is also reported when
	there isn't room for the terminating double 0 for an indefinite length
	construct.

-10 = Out of heap space in Prolog
*/

unsigned int list_to_asn1(
	BNRP_term term,
	unsigned char **buffer,
	unsigned int buf_size);
	
#ifdef __cplusplus
}
#endif

#else

void BNRP_bindWollPrims();
BNRP_term addBytesToTerm();
unsigned long removeBytesFromTerm();
BNRP_term asn1_to_list();
unsigned int list_to_asn1();

#endif
