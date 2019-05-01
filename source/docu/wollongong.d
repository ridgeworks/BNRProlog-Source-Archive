#if 0
----------------------------------------------------------------------
> Global Function: addBytesToTerm ;
  $ BNRP_termaddBytesToTerm (BNRP_TCB*, char*<T>, unsigned long, BNRP_term)
> Purpose:
  | Converts a byte buffer into a structure containing integers and returns that structure.
> Calling Context:
  | 
> Return Value:
  | BNRP_term
> Parameters:
  = BNRP_TCB* tcb - Pointer to a task control block
  = char* ptr - Buffer pointer
  = unsigned long count - Length of buffer
  = BNRP_term structName - Desired functor of new structure.
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: removeBytesFromTerm ;
  $ unsigned longremoveBytesFromTerm (BNRP_term, char**, unsigned long)
> Purpose:
  | Translates a structure of integers into a byte buffer and returns the number
  | of bytes written.  When the function returns, buffer points to the last item
  | written to the buffer
> Calling Context:
  | 
> Return Value:
  | unsigned long - Number of bytes written
> Parameters:
  = BNRP_term structTerm - Prolog structure term
  = char** buffer - Pointer to a byte buffer
  = unsigned long buf_size - Size of buffer
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: codeLengthWithShift ;
  $ unsigned intcodeLengthWithShift (unsigned char[], unsigned int, unsigned char, unsigned int)
> Purpose:
  | Determine the length of the coded length of the data in <bufref>.  Check whether the correct space <lenSpace> to write this length is reserved.  Shift buffer if necessary.  Write encoded length into buffer.  Return the final length of the buffer.
> Calling Context:
  | Local function used by list_to_asn1()
> Return Value:
  | unsigned int - Final length of buffer
> Parameters:
  = unsigned char[] bufRef - Byte buffer
  = unsigned int bufLen - Size of buffer
  = unsigned char lenSpace - Amount of space left for encoding length
  = unsigned int remBuffSpace - Amount of space left in buffer
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: asn1_to_list ;
  $ BNRP_termasn1_to_list (BNRP_TCB*, unsigned char[], unsigned int, unsigned int*)
> Purpose:
  | Converts an ASN.1 byte buffer to a list of integers and possibly sublists in the case of constructors.  Length data is not encoded into the term.  Returns
  | the encoded list and puts the number of bytes read from the buffer in <bufRead>.  The function also does somesanity checks to make sure the buffer
  | is legal ASN.1.  
> Calling Context:
  | 
> Return Value:
  | BNRP_term - List containing the encoded ASN.1 byte buffer.  If an error occurs,
  | the term is completed (ie. lists get closed) and an errcode is returned in errno.  On success, errno is 0.
> Parameters:
  = BNRP_TCB* tcb - Pointer to a Task Control Block
  = unsigned char[] bufRef - Byte buffer
  = unsigned int bufLength - Size of buffer
  = unsigned int* bufRead - Pointer to an integer.  The number of bytes read 				gets placed here.
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | N/A
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: list_to_asn1 ;
  $ unsigned intlist_to_asn1 (BNRP_term, unsigned char**, unsigned int)
> Purpose:
  | Converts a Prolog list of integers (with possible sublists) into an ASN.1 byte buffer.  Sanity checks to make sure we are constructing a legal ASN.1 buffer are made.  
> Calling Context:
  | 
> Return Value:
  | unsigned int - Number of bytes written to the buffer.  When an error occurs errno is set.  On success errno is 0.
> Parameters:
  = BNRP_term listTerm - Prolog list to be converted
  = unsigned char** buffer - pointer to a byte buffer
  = unsigned int buf_size - size of byte buffer
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | N/A
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_list_to_asn ;
  $ BNRP_BooleanBNRP_list_to_asn (TCB*)
> Purpose:
  | Prolog Primitive to convert a Prolog list to an ASN.1 buffer.  The primitive has 3 arguements.  The first beingthe list to be converted.  The second is the length of the ASN.1 buffer that gets constructed, and the third is the value of errno returned by list_to_asn1().
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | A call to BNRP_bindWollPrims() must be made to bind this primitive in.
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_readLocalTime ;
  $ BNRP_BooleanBNRP_readLocalTime (TCB*)
> Purpose:
  | This is a Prolog primitive that converts a value in seconds since Jan. 1 1970 00:00:00 UTC to local time.  The primitive has two forms.  The first has 6
  | arguements which are as follows:
  | 1. seconds since the Epoch
  | 2. year since 1900
  | 3. month value ranging from 0 to 11
  | 4. day of the month ranging from 0 to 31
  | 5. day of the week ranging from 0 to 6 days since Sunday
  | 6. seconds of the day
  | The second form takes the seconds since the epoch in 4 1 byte chunks.  The rest of the arguements are the same.  For both forms, the seconds since the Epoch can be variable(s), in which case, the terms are unified with the current time.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | A call to BNRP_bindWollPrims() must be made to bind this primitive in.
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_bcdEncode ;
  $ BNRP_BooleanBNRP_bcdEncode (TCB*)
> Purpose:
  | 
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_bindWollPrims ;
  $ voidBNRP_bindWollPrims (void)
> Purpose:
  | Binds the following primitives into the Prolog system:
  | 		1. BNRP_readLocalTime()
  | 		2. BNRP_list_to_asn()
  | 		3. BNRP_bcdEncode()
  | This needs to be called before any of the primitives get used.
> Calling Context:
  | 
> Return Value:
  | void
> Parameters:
  = void  
> Exceptions:
  | N/A
> Concurrency:
  | N/A
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: checkBuffer
  $ #define checkBuffer
> Purpose:
  | This flag enables checks in list_to_asn1 that make sure we don't overrun the buffer.
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapcheck
  $ #define heapcheck (n)
> Purpose:
  | Makes sure we don't overrun the heap when we push terms onto it.  <n> is the
  | number of terms to check for.  This is called before the actual terms are 
  | pushed onto the heap.  This check generates the HEAPOVERFLOW error in the Prolog engine when an overflow will occur.
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: heapcheck2
  $ #define heapcheck2 (n)
> Purpose:
  | This macro is the same as heapcheck(), except it has been specialized for use in asn1_to_list().  When an overflow will occur, errno is set.
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: nextArg
  $ #define nextArg (p, x)
> Purpose:
  | Gets the next term of <p>, chases down tailvariables and does any necessary
  | dereferencing to return the term <x>.  Subsequent calls to this macro on the same term will return the consequent terms of <p>.
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getSimpleInteger
  $ #define getSimpleInteger (p, x)
> Purpose:
  | Used in list_to_asn1() to get the integer value <x> from the term <p>. A simple integer is encoded in 2 bytes and in this case must be less than 256.  If this is not true, or if <p> is not an integer, errno is set.
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: getInteger
  $ #define getInteger (p, x)
> Purpose:
  | This is the same as getSimpleInteger, except that the integers can be up to 4 bytes in length.
> Other Considerations:
  | 
----------------------------------------------------------------------
#endif
