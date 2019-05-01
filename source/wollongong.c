/*
 *
 * $Header: /disc9/sniff/repository/BNRProlog/source/RCS/wollongong.c,v 1.10 1998/01/21 07:51:51 harrisj Exp $
 *
 * $Log: wollongong.c,v $
 * Revision 1.10  1998/01/21  07:51:51  harrisj
 * Initialized res to be zero in asn1_to_list
 *
 * Revision 1.9  1997/12/22  12:48:48  harrisj
 * list_to_asn1 changed to set errno to -9 when buffer is full and
 * still more to decode.
 * Made buffer pointer in asn1_to_list const.
 * Updated comments in header file
 *
 * Revision 1.8  1997/05/12  13:27:04  harrisj
 * Modified date using functions to output year using 4 digits
 * instead of 2
 *
 * Revision 1.7  1997/03/14  13:43:03  harrisj
 * list_to_asn1() was not handling tag byte 0 properly.
 * tag 0 is a special case which was not being handled
 * when the tag was being scanned.  Normally leading zeros
 * are skipped in the tag which caused incorrect behaviour when
 * tag 0 is used.
 *
 * Revision 1.6  1996/10/02  17:30:09  harrisj
 * In list_to_asn1(), codeLengthWithShift could enlarge the list, hence
 * newBuffPtr would not point to the end of the list but to the end minus
 * the number of bytes that codeLengthWithShift() added to the list!
 *
 * Revision 1.5  1996/07/11  10:55:19  yanzhou
 * list_to_asn1 bug fix:
 *     multiple-byte identifiers were not handled properly.
 *     Now fixed.
 *
 * Revision 1.4  1995/10/04  09:56:39  harrisja
 * Removed list_to_asn primitive from BNRP_bindWollPrims()
 *
 * Revision 1.3  1995/09/22  18:39:54  harrisja
 * *** empty log message ***
 *
 * Revision 1.2  1995/09/22  18:37:15  harrisja
 * asn1_to_list(): primitive was not returning proper length when
 * identifier was more than one byte
 *
 * Revision 1.1  1995/09/22  11:29:15  harrisja
 * Initial version.
 *
 * */

/*******************************************************************
 * Wollongong add-ons
 *  This file contains additional functionality for the BNR Prolog
 *  system that were required for projects at the Nortel Technology
 *  Centre.  These are not part of the standard BNR Prolog
 *  distribution.
 *******************************************************************/

#include "BNRProlog.h"
#include "base.h"
#include "core.h"
#include "hardware.h"
#include "interpreter.h"
#include "utility.h"
#include <stdio.h>
#include <errno.h>
#include <time.h>

#define checkBuffer
  /* If enabled, checks to make sure we don't overrun passed in arrays
     when filling them */

/*#define asnDebug
  /* If enabled, prints out debug messages from asn1_to_list() and
     list_to_asn1() */


#define heapcheck(n) \
    if ((((TCB *)tcb)->heapend - hp) LE (n * sizeof(long))) \
        BNRP_error(HEAPOVERFLOW)
                
#define heapcheck2(n) \
    if ((((TCB *)tcb)->heapend - ((TCB *)tcb)->hp) <= (n * sizeof(long))) \
    {\
          errno = -10; \
          *bufRead = index; \
          return(res); \
    }
            
#define nextArg(p, x) \
    while (tagof(x = *p) == TVTAG) { \
        long _a = addrof(x); \
        if ((long)p == _a) break; \
        p = (long *)_a; \
    } \
    ++p; \
    while (isVAR(x)) { \
        long _tt = derefVAR(x); \
        if (x EQ _tt) break; \
        x = _tt; \
    }

#define getSimpleInteger(p, x) \
    if ((tagof(p)) == INTTAG) \
    { \
        li t; \
        if ((t.l = p) & 0x1FFFFF00) \
        { /* Value is greater than 255 */ \
            errno = -5; \
            *buffer = oldBuffPtr; \
            return(0); \
        }\
        x = t.i.b; \
    } \
    else \
    { /* Non integer term in list */ \
        errno = -2; \
        *buffer = oldBuffPtr; \
        return(0); \
    }
                    
#define getInteger(p, x) \
    {   long tag; \
        if ((tag = tagof(p)) == INTTAG) {\
            li t; \
            t.l = p; \
            x = t.i.b; \
        } \
        else if (tag == STRUCTTAG) \
        { \
            long *strTerm = (long *)addrof(p); \
            li t1; \
            t1.l = *strTerm++; \
            if (t1.i.a EQ NUMBERIDshort) \
                x = *strTerm; \
            else \
            { /* Non integer term in list */ \
                errno = -2;\
                *buffer = oldBuffPtr;\
                return(0);\
            } \
        } \
        else \
        { /* Non integer term in list */ \
            errno = -2;\
            *buffer = oldBuffPtr;\
            return(0);\
        } \
    }
    
/*
 * This function converts a byte buffer into a structure containing integers
 * ptr   - buffer pointer
 * count - size of buffer not including NULL character (ptr doesn't
 *         have to be NULL terminated)
 * structName - name of the structure
 */
BNRP_term addBytesToTerm(BNRP_TCB *tcb,
                         char * ptr,
                         unsigned long count,
                         BNRP_term structName)
{

    long hp, start;
    li header;
    int index;

    if (tagof(structName) NE SYMBOLTAG)
        return((BNRP_term)NULL);

    hp = ((TCB *)tcb)->hp;
    headerLWA(hp);                              /* Align the heap */
    heapcheck(3 + count);
    start = hp;
    header.l = STRUCTHEADER + 1;                /* add 1 to the arity for the functor */
    push(long, hp, header.l);                   /* push the header onto the heap      */
    push(BNRP_term, hp, structName);            /* push the functor onto the the heap */

    for(index = 0;index LT count;index ++)
    {
        push(BNRP_term, hp, makeintterm((int)ptr[index] & 0x0000FFFF));
    }
    push(long, hp, 0L);                         /* End the structure with 0 */
    header.i.b += count;                        /* increment the arity      */
    *(long *)start = header.l;                  /* put the new header back into the heap */
    ((TCB *)tcb)->hp = hp;
    return(maketerm(STRUCTTAG, start));         /* Return the new structure */
}



/*
 * Takes a structure containing integers, and puts the integers into a
 * byte buffer.  Leaves the buffer pointer poiting at the last item in
 * the buffer
 *
 * structTerm - a structure containing integers
 * buffer     - a pointer to an allocated byte buffer
 * buf_size   - size/remaining room in the byte buffer
 */
unsigned long removeBytesFromTerm(BNRP_term structTerm,
                                  char ** buffer,
                                  unsigned long buf_size)
{
    long *addr, value;
    li intValue;
    unsigned long count = 0;
        
    addr = (long *)addrof(structTerm);          /* Get the address of the structure     */
    
    addr +=2;                                   /* Increment addr to 1st item in struct */
    
    while(*addr && (count LT buf_size))
    {
        while (tagof(value = *addr) EQ TVTAG)   /* Unwind any tailvar's */ 
        {
            long _a = addrof(value);
            if ((long)addr EQ _a) break;
            addr = (long *)_a;
        }
        if (*addr EQ 0) break;
        ++addr;
        while (isVAR(value))                    /* Dereference if value is a variable   */ 
        {
            long _tt = derefVAR(value);
            if (value EQ _tt) break;
            value = _tt;
        }

        intValue.l = value;
        **buffer = (char)intValue.i.b;          /* Put the integer into the buffer      */
        count ++;
        (*buffer) ++;
    }
    (*buffer) --;
    return(count);
}

/*
 * Determine the length of the coded length of the data in <bufRef>.
 * Check whether the correct space <lenSpace> to write this length is
 * reserved. Shift buffer if necessary. Write encoded length into
 * buffer. Return the final length of the buffer. 
 */
unsigned int codeLengthWithShift( unsigned char bufRef[],
                                  unsigned int bufLen,
                                  unsigned char lenSpace,
                                  unsigned int remBuffSpace )
{
    
    /* First determine the length of the data */
    unsigned int lenVal = bufLen - lenSpace;

    /* Now determine the length of the encoded length */
    unsigned char lenLength;
    if ( !(lenVal & 0xFFFFFF80) )
        lenLength = 1;
    else if ( !(lenVal & 0xFFFFFF00) )
        lenLength = 2;
    else if ( !(lenVal & 0xFFFF0000) )
        lenLength = 3;
    else if ( !(lenVal & 0xFF000000) )
        lenLength = 4;
    else
        lenLength = 5;

    /* Check to see if buffer contains enough room for length */
    if (lenLength > remBuffSpace)
        return(bufLen - lenSpace + lenLength);

    /* Shift buffer if necessary */
    if ( lenLength != lenSpace )
        memmove( bufRef+lenLength, bufRef+lenSpace, bufLen-lenSpace );

    /* Write the length into the buffer */
    if ( lenLength == 1 )
    {
        /* Straight write of length value into buffer */
        bufRef[0] = (unsigned char)lenVal;
    }
    else
    {
        /* Otherwise it is the extended form */
        unsigned char i;
        bufRef[0] = 0x80 | lenLength-1;         /* Header octet indicates number of */
                                                /* subsequent length octets.        */
        for( i=1; i<lenLength; i++ )
            bufRef[i] = (unsigned char)( lenVal >> (lenLength-i-1)*8 );
    }
    
    return bufLen - lenSpace + lenLength;
}
                                                 

/*
 * Format and the contents of <bufRef> as a nested Prolog list of
 * integers prepended with tag values. <bufRef> must be an ASN.1
 * encoded byte buffer.
 */

BNRP_term asn1_to_list(BNRP_TCB *tcb, 
                       const unsigned char bufRef[],
                       unsigned int bufLength, 
                       unsigned int *bufRead)
{
    long res=0, endList;
    BNRP_term subList;

    unsigned int subRead, tagValue, lenCheck = 0, length = 0, index = 0;
    unsigned char isConstructor, firstLenByte, isIndefiniteLength = 0;

    errno = 0;

#ifdef asnDebug
    printf("asn1_to_list: Starting buffer to list coversion\n");
#endif
    /* Start the list */
    heapcheck2(2);
    headerLWA(((TCB *)tcb)->hp);                /* Align the heap */
    res = maketerm(LISTTAG, ((TCB *)tcb)->hp);  /* Start the list */
    
    if (bufLength < 2)
    {
        push(long, ((TCB *)tcb)->hp, 0L);
#ifdef asnDebug
        printf("asn1_to_list: Buffer is too short\n");
#endif
        errno = -9;
        *bufRead = index;
        return(res);
    }

    /* The first byte(s) should be a tag value. Check the category. */
    isConstructor = bufRef[0] & 0x20;

#ifdef asnDebug
    printf("asn1_to_list: checking the identifier\n");
#endif

    tagValue = bufRef[index++];
    if (( bufRef[0] & 0x1F ) == 31 )            /* Extended tag?              */
    {
        unsigned int i=0;
        while( i++<3 )                          /* Put up to 3 more bytes in. */
        {
            if ((index + 1) >= bufLength)
            {
                push(long, ((TCB *)tcb)->hp, 0L);
                errno = -9;
                *bufRead = index;
#ifdef asnDebug
                printf("asn1_to_list: Trying to get identifier but about to run off end of buffer\n");
#endif
                return(res);
            }
            tagValue = (tagValue << 8) + bufRef[index];
            if (!(bufRef[index++] & 0x80))
                break;
        }

        if ( tagValue & 0x00000080 ) 
        {
            /* Extension bit still set? Tag value must not be > 4 bytes */
            push(long, ((TCB *)tcb)->hp, 0L);
            errno = -4;
            *bufRead = index;
#ifdef asnDebug
            printf("asn1_to_list: Identifier is longer than 4 bytes\n");
#endif
            return(res);
        }
    }

    /*
     * Since the tagValue can be 4 bytes long, we need to use the more
     * complicated makeint procedure.  Makeint is optimized so that
     * when tagValue can fit into 2 bytes, we use the cheaper encoding
     */
       
    endList = ((TCB *)tcb)->hp;                 /* Keep track of current end of List */
    push(long, ((TCB *)tcb)->hp, 0L);           /* Push a TV onto list               */
    subList = makeint(&((TCB *)tcb)->hp,tagValue); /* Create the identifier integer  */
    *(long *)endList = maketerm(TVTAG, ((TCB *)tcb)->hp);
                              /* Create a TV that points to the start of the integer */
    push(long, ((TCB *)tcb)->hp,subList);       /* Push the integer onto the list    */
    
#ifdef asnDebug
    printf("asn1_to_list: Decoding the length\n");
#endif

    /* Decode the length */
    firstLenByte = bufRef[index++];
    if ( firstLenByte == 0x80 )                 /* Check indefinite length flag. */
        isIndefiniteLength = 1;
    else
    {
        if ( firstLenByte < 128 )               /* Short form definite length.   */
            length = firstLenByte;
        else                                    /* Long form definite length.    */
        {
            unsigned char i;
            unsigned char octetsInLength = firstLenByte & 0x7F;

            if ( octetsInLength > 4 ) /* Length value of more than 4 bytes encountered */
            {
                push(long, ((TCB *)tcb)->hp, 0L);
#ifdef asnDebug
                printf("asn1_to_list: More than 4 length octets\n");
#endif
                errno = -6;
                *bufRead = index;
                return(res);
            }
            if ((index + octetsInLength) > bufLength)
            {
                push(long, ((TCB *)tcb)->hp, 0L);
#ifdef asnDebug
                printf("asn1_to_list: Attempting to get more length octets but will run off end of buffer\n");
#endif
                errno = -9;
                *bufRead = index;
                return(res);
            }
            
            for( i=0; i<octetsInLength; i++ )
                length = (length << 8) + bufRef[index++];
        }

        if ((index + length) > bufLength)
        {   /* Length will cause us to run off the end of the buffer */
            push(long, ((TCB *)tcb)->hp, 0L);
            errno = -8;
#ifdef asnDebug
            printf("asn1_to_list: Length will cause us to run off end of buffer\n");
#endif
            *bufRead = index;
            return(res);
        }
    }

        
    /* Now do the contents. */
    if ( !isConstructor )
    {
        unsigned int i;
        
#ifdef asnDebug
        printf("asn1_to_list: Encoding a primitive\n");
#endif

        /* Primitive type - just copy the bytes and return; */
        if ( isIndefiniteLength )
        {
            /* Illegal ASN.1! Indefinite length primitive encountered */
            push(long, ((TCB *)tcb)->hp, 0L);
            errno = -7;
#ifdef asnDebug
            printf("asn1_to_list: Primitives can't have indefinite lengths\n");
#endif
            *bufRead = index;
            return(0);
        }

        heapcheck2(length + 1);
#ifdef asnDebug
        printf("asn1_to_list: Encoding contents\n");
#endif
        for( i=0; i<length; i++ )
        {
            push(long, ((TCB *)tcb)->hp, makeintterm(((long)bufRef[index++]) & 0x0000FFFF));
        }
    
        /* Close the list. */
        push(long, ((TCB *)tcb)->hp, 0L);
        *bufRead = index;
        return(res);                            /* Return the list; */
    }

    /* Constructor type with indefinite length. Do recursive calls. */
    if ( isIndefiniteLength )
    {
#ifdef asnDebug
        printf("asn1_to_list: Encoding constructor of indefinite length\n");
#endif
        while( (bufRef[index] != 0x00) || (bufRef[index+1] != 0x00) )
        {
#ifdef asnDebug
            printf("asn1_to_list: Encoding subexpression\n");
#endif
            heapcheck2(3);
            endList = ((TCB *)tcb)->hp;         /* Keep track of THIS list's end */
            push(long,((TCB *)tcb)->hp,0L);     /* Push TV onto end of list      */
            subList = asn1_to_list( tcb, &bufRef[index], bufLength - index, &subRead );

            index += subRead;
            *(long *)endList = maketerm(TVTAG, ((TCB *)tcb)->hp);
                     /* Create a TV that points to the start of the next sublist */
            push(long, ((TCB *)tcb)->hp,subList);/* Push the sublist onto heap   */

            if ( errno != 0 )
            {
                push(long, ((TCB *)tcb)->hp, 0L);
                *bufRead = index;
                return(res);
            }
            if ((index + 1) >= bufLength)
            {
                push(long, ((TCB *)tcb)->hp,0L);
                errno = -9;
#ifdef asnDebug
                printf("asn1_to_list: Buffer doesn't have room for terminating zeros\n");
#endif
                *bufRead = index;
                return(res);
            }
        }

        /* Close the list. */
        push(long, ((TCB *)tcb)->hp, 0L);
        *bufRead = index + 2;                   /* Add two for the terminator octets */
        return(res);  
    }
#ifdef asnDebug
    printf("asn1_to_list: Encoding construct of definite length\n");
#endif

    /* Constructor type with definite length. Do recursive calls. */
    while( lenCheck < length )
    {
#ifdef asnDebug
        printf("asn1_to_list: Encode subexpression\n");
#endif
        endList = ((TCB *) tcb)->hp;
        heapcheck2(3);
        push(long,((TCB *) tcb)->hp,0L);
        
        subList = asn1_to_list( tcb, &bufRef[index], bufLength - index, &subRead );

        lenCheck += subRead;
        index += subRead;
        *(long *)endList = maketerm(TVTAG,((TCB *)tcb)->hp);
        push(long, ((TCB *)tcb)->hp,subList);
        
        if ( errno != 0 )
        {
            push(long, ((TCB *)tcb)->hp, 0L);
            *bufRead = index;
            return(res);
        }

    }

    if ( lenCheck > length )
    {
        /* This condition indicates that the ASN.1 buffer is bogus */
        push(long, ((TCB *)tcb)->hp, 0L);
#ifdef asnDebug
        printf("asn1_to_list: subexpression length doesn't match length\n",length,lenCheck);
#endif
        errno = -8;
        *bufRead = index;
        return(res);
    }

    push(long,((TCB *)tcb)->hp,0L);
    *bufRead = index;
    return(res);
}

/*
 * Takes a BNR Prolog list and creates an ASN.1 encoding
 */
unsigned int list_to_asn1(BNRP_term listTerm,
                          unsigned char **buffer,
                          unsigned int buf_size)
{
    BNRP_term term = listTerm;
    BNRP_term nextTerm;
    long *next;
    long tag;
    long value;
    int newLen;
    int index;
    li byteValue;
    unsigned char *oldBuffPtr = *buffer;
    unsigned char *newBuffPtr = *buffer;
    short identifierStarted = FALSE;
    int length = 0;       /* length counter                             */
    int idlen  = 0;       /* yanzhou@bnr.ca:10/07/96: identifier length */
    
    errno = 0;

#ifdef asnDebug
    printf("list_to_asn1: Starting list to buffer conversion\n");
#endif

    if (tagof(term) != LISTTAG)                 /* Check to see if the term is a list */
    {
        while(tagof(term) == TVTAG)             /* Chase down tail variables          */
        {
            long _a = *(long *)addrof(term);
            if (_a == term)
            {
#ifdef asnDebug
                printf("list_to_asn1:Incoming term was a tailvar not a list\n");
#endif
                errno = -1;
                return(0);
            }
            term = _a;
        }

        while(isVAR(term))                      /* Dereference variables */
        {
            register long _l = derefVAR(term);
            if (_l == term)
            {
#ifdef asnDebug
                printf("list_to_asn1:Incoming term was a variable not a list\n");
#endif
                errno = -1;
                return(0);
            }
            term = _l;
        }

        if (tagof(term) != LISTTAG)
        {
            /* If term is still not a list report an error */
#ifdef asnDebug
            printf("list_to_asn1:  Incoming term is not a list\n");
#endif
            errno = -1;
            return(0);
        }
    }
    
#ifdef checkBuffer
    if (buf_size == 0)
    {
	errno = -9;
        return(0);
    }
#endif
    
    /* Get the first item in the list */    
    next = (long *)addrof(term);
    nextArg(next, nextTerm);
    
    /* Check to see if list is empty  */
    if (nextTerm == 0)
        return(0);
    
#ifdef asnDebug
    printf("list_to_asn1: Getting identifier\n");
#endif  
    getInteger(nextTerm,value);
    
    /* Put the identifier into the buffer */
    if(value != 0)
    {
       for(index = 0;index < 4; index++)
       {
	   unsigned char topValue = (value & 0xFF000000) >> 24;
	   value <<= 8;

	   if (!identifierStarted && !topValue) 
	       continue;                           /* ignore leading 0's */

	   if (identifierStarted) {
	       if (index < 3) {
		   /* high bit must be set for the subsequent octets */
		   if (!(topValue & 0x80))
		   {
		       errno = -4;
		       *buffer = oldBuffPtr;
#ifdef asnDebug
		       printf("list_to_asn1: Bad identifier\n");
#endif
		       return(0);
		   }
	       }
	       else {
		   if (topValue & 0x80) { 
		       /* high bit must be zero for the final octet */
		       errno = -4;
		       *buffer = oldBuffPtr;
#ifdef asnDebug
		       printf("list_to_asn1: Bad identifier\n");
#endif
		       return(0);
		   }
	       }
	   } else {                                /* !identifierStarted */
	       if (index < 3) { 
		   /*
		    * Beginning of tag but in the midst of the 4
		    * bytes hence topValue must be a leading octet
		    */
		   if ((topValue & 0x1F) != 0x1F) {
		       errno = -4;
		       *buffer = oldBuffPtr;
#ifdef asnDebug
		       printf("list_to_asn1: Bad identifier\n");
#endif
		       return(0);
		   }
	       }
	       identifierStarted = TRUE;
	   }

	   **buffer = topValue;
	   (*buffer)++;
#ifdef checkBuffer
	   if (length == buf_size) {
#ifdef asnDebug
	       printf("list_to_asn1: Filled Buffer\n");
#endif
	       errno = -9;
	       return(0);
	   }
#endif
	   length++;
	   idlen ++;                               /* identifier length ++      */
       }
    }
    else {
	 **buffer = value;
	 (*buffer)++;
#ifdef checkbuffer
	 if (length == buf_size) {
#ifdef asnDebug
	    printf("list_to_asn1: Filled Buffer\n");
#endif
	    errno = -9;
	    return(0);
	 }
#endif
	 
	 length++;
	 idlen ++;
    }
    /* Now, leave a 1-byte gap for the length octect */
    newBuffPtr = (*buffer + 1);
    length ++;
    
    /* Constructed or Primitive? */
    if (oldBuffPtr[0] & 0x20)
    {   
        /* term is constructed */

#ifdef asnDebug
        printf("list_to_asn1: Term is constructed\n");
#endif

        nextArg(next,nextTerm);

        if (nextTerm == 0)
        {
            /* If constructor, then list can't be empty yet */
#ifdef asnDebug
            printf("list_to_asn1: Term is constructed but list is empty\n");
#endif
            errno = -3;
            return(0);
        }
        /* Walk across the list and convert all sublists */     
#ifdef checkBuffer      
        while((nextTerm != 0) && (length < buf_size))
#else
        while(nextTerm != 0)
#endif
        {
#ifdef asnDebug
            printf("list_to_asn1: convert sublist\n");
#endif
            length += list_to_asn1(nextTerm,&newBuffPtr, buf_size - length);
            if (errno != 0) {
                *buffer = oldBuffPtr;
                return(0);
            }
            nextArg(next,nextTerm);
        }

#ifdef checkBuffer
	/* Check to see if buffer is full */
	if((nextTerm != 0) && (length == buf_size))
	{
	   errno = -9;
	   return(0);
	}
#endif
    
#ifdef asnDebug
        /* printf("list_to_asn1: encode trailing zeros\n"); */
        printf("list_to_asn1: encode constructor length %d\n",length);
#endif
        newLen = codeLengthWithShift(*buffer, length-idlen, 1, buf_size-length);

#ifdef asnDebug
        printf("list_to_asn: encoded constructor of length: %d\n",newLen);
#endif

    }
    else
    {   /* term is a primitive */
#ifdef asnDebug
        printf("list_to_asn1: Term is primitive\n");
#endif

        nextArg(next,nextTerm);

#ifdef asnDebug
        printf("list_to_asn1: encode contents\n");
#endif
        /* Walk across the list of what should hopefully be Prolog integers */
#ifdef checkBuffer
        while((nextTerm != 0) && (length < buf_size))
#else
        while(nextTerm != 0)
#endif
        {
            getSimpleInteger(nextTerm,*newBuffPtr);
            newBuffPtr ++;
            length ++;
            nextArg(next,nextTerm);
        }

#ifdef checkBuffer
	/* Check to see if buffer is full */
	if((nextTerm != 0) && (length == buf_size))
	{
	   errno = -9;
	   return(0);
	}
#endif

#ifdef asnDebug
        printf("list_to_asn1: encode primitive length  %d\n", length-idlen);
#endif

        /* Use the definite form for length */
        newLen = codeLengthWithShift(*buffer, length-idlen, 1, buf_size-length);
#ifdef asnDebug
        printf("list_to_asn1: encoded primitive of length: %d\n", newLen);
#endif
    }

#ifdef asnDebug
    fprintf(stderr, "list_to_asn1: %s TotalLength=%d, IdentifierLength=%d",
            (oldBuffPtr[0] & 0x20) ? "CONSTRUCTED" : "PRIMITIVE", newLen+idlen, idlen);
    {
        unsigned char *p = oldBuffPtr;
        int            c = 0;
        while (p < newBuffPtr) {
            if (c % 8 == 0)
                fprintf(stderr, "\n    ");
            fprintf(stderr, "%02x[%03d] ", *p, *p);
            p++; c++;
        }
        fprintf(stderr,"\n");
    }
#endif
   /* If codeLengthWithShift() required > 1 byte for length, then the end of the buffer has changed */
    *buffer = (newBuffPtr + (newLen - (length-idlen)));                       /* Move buffer pointer to end of buffer */
    return(newLen + idlen);
}

BNRP_Boolean BNRP_list_to_asn(TCB *tcb)
{
    unsigned char * buffer = BNRP_malloc(200);
    long lengthList;
    
    if (tcb->numargs NE 3)
        return(FALSE);
        
    errno = 0;
    lengthList = list_to_asn1(tcb->args[1],&buffer,200);
    
    BNRP_free(buffer - lengthList);
    return(unify(tcb,tcb->args[2],makeint(&tcb->hp,lengthList)) &&
           unify(tcb,tcb->args[3],makeint(&tcb->hp,errno)));
}

BNRP_Boolean BNRP_readLocalTime(TCB *tcb)
{
    TAG tag;
    struct tm * timeValue;
    time_t currentTime;
    long secVal;
    
    if (tcb->numargs EQ 9)
    {
        long intVal;
        BNRP_Boolean isInt = FALSE;
        
        if ((tag = checkArg(tcb->args[1],&intVal)) EQ INTT)
        {
            if ((intVal > 255) || (intVal < 0))
                return(FALSE);
            secVal = intVal;
            isInt = TRUE;
        }
        else if (tag NE VART)
            return(FALSE);
        else {};
        
        if ((tag = checkArg(tcb->args[2],&intVal)) EQ VART)
        {
            if (isInt) return(FALSE);
        }
        else if (tag EQ INTT)
        {
            if (!isInt) return(FALSE);
            if ((intVal > 255) || (intVal < 0))
                return(FALSE);
            secVal = (secVal << 8) + (unsigned char)intVal;
        }
        else
            return(FALSE);
        
        if ((tag = checkArg(tcb->args[3],&intVal)) EQ VART)
        {
            if (isInt) return(FALSE);
        }
        else if (tag EQ INTT)
        {
            if (!isInt) return(FALSE);
            if ((intVal > 255) || (intVal < 0))
                return(FALSE);
            secVal = (secVal << 8) + (unsigned char)intVal;
        }
        else
            return(FALSE);
        
        if ((tag = checkArg(tcb->args[4],&intVal)) EQ VART)
        {
            if (isInt) return(FALSE);
        }
        else if (tag EQ INTT)
        {
            if (!isInt) return(FALSE);
            if ((intVal > 255) || (intVal < 0))
                return(FALSE);
            secVal = (secVal << 8) + (unsigned char)intVal;
        }
        else
            return(FALSE);
            
        if (!isInt)
            secVal = time(&currentTime);

        timeValue = localtime((time_t *)&secVal);
    
        return( unify(tcb,tcb->args[4],makeint(&tcb->hp,secVal & 0x000000FF)) &&
                unify(tcb,tcb->args[3],makeint(&tcb->hp,(secVal >> 8) & 0x000000FF)) &&
                unify(tcb,tcb->args[2],makeint(&tcb->hp,(secVal >> 16) & 0x000000FF)) &&
                unify(tcb,tcb->args[1],makeint(&tcb->hp,secVal >> 24)) &&
                unify(tcb,tcb->args[5],makeint(&tcb->hp,timeValue->tm_year+1900)) &&
                unify(tcb,tcb->args[6],makeint(&tcb->hp,timeValue->tm_mon)) &&
                unify(tcb,tcb->args[7],makeint(&tcb->hp,timeValue->tm_mday)) &&
                unify(tcb,tcb->args[8],makeint(&tcb->hp,timeValue->tm_wday)) &&
                unify(tcb,tcb->args[9],makeint(&tcb->hp,(timeValue->tm_hour * 60) + 
                                               timeValue->tm_min + (timeValue->tm_sec > 59 ? 1 : 0))));

    }
    else if (tcb->numargs EQ 6)
    {
        if ((tag = checkArg(tcb->args[1],&secVal)) == VART)
            secVal = time(&currentTime);
        else if (tag == INTT)
            if (secVal < 0)
                return(FALSE);
            else
                return(FALSE);
        
        timeValue = localtime((time_t *)&secVal);
    
        return( unify(tcb,tcb->args[1],makeint(&tcb->hp,secVal)) &&
                unify(tcb,tcb->args[2],makeint(&tcb->hp,timeValue->tm_year+1900)) &&
                unify(tcb,tcb->args[3],makeint(&tcb->hp,timeValue->tm_mon)) &&
                unify(tcb,tcb->args[4],makeint(&tcb->hp,timeValue->tm_mday))&&
                unify(tcb,tcb->args[5],makeint(&tcb->hp,timeValue->tm_wday))&&
                unify(tcb,tcb->args[6],makeint(&tcb->hp,(timeValue->tm_hour * 60) + 
                                               timeValue->tm_min + (timeValue->tm_sec > 59 ? 1 : 0))));

    }
    else
        return(FALSE);
    
}

BNRP_Boolean BNRP_bcdEncode( TCB* tcb )
{
    long symbol;
    int y = 0, len = 0;
    char temp[4];
    char* symPtr;
    BNRP_term newList;
   
    if (tcb->numargs != 3)
        return 0;
   
    if (checkArg( tcb->args[1], &symbol ) != SYMBOLT)
        return FALSE;
   
    temp[1] = 0;
    temp[3] = 0;
    symPtr = nameof(symbol);
   
    if ((tcb->heapend - tcb->hp) LE ((strlen(symPtr) + 2) * sizeof(long)))
        BNRP_error(HEAPOVERFLOW);

    headerLWA(tcb->hp);
    newList = maketerm(LISTTAG, tcb->hp);
    while (*symPtr)
    {
        if (*(symPtr+1))
        {
            temp[0] = *symPtr;
            temp[2] = *(symPtr+1);
            y = atoi(&temp[2]) * 16 + atoi(&temp[0]);
            push(long,tcb->hp,makeintterm((long)y & 0x0000FFFF));
            symPtr+=2;
            len+=2;
        }
        else
        {
            temp[0] = *symPtr;
            y = atoi(&temp[0]);
            push(long,tcb->hp,makeintterm((long)y & 0x0000FFFF));
            symPtr++;
            len++;
        }
    }
    push(long,tcb->hp,0L);
   
    return(unify(tcb,tcb->args[2],makeint(&tcb->hp,len)) &&
           unify(tcb,tcb->args[3],newList));
}

void BNRP_bindWollPrims(void)
{
    BNRPBindPrimitive("readlocaltime",BNRP_readLocalTime);
    /* BNRPBindPrimitive("list_to_asn",BNRP_list_to_asn); */
    BNRPBindPrimitive("bcdEncode",BNRP_bcdEncode);
}
