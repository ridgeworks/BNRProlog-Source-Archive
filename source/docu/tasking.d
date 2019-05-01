#if 0
----------------------------------------------------------------------
> Global Function: task_check ;
  $ voidtask_check ()
> Purpose:
  | This is the signal handler for SIGSEGV and SIGBUS.  When we are trying to validate a task ID (which is a pointer to a TCB), we set up this handler for these signals.
> Calling Context:
  | Called by the validID() macro.
> Return Value:
  | void
> Parameters:
  = No parameters... - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_initializeTask ;
  $ intBNRP_initializeTask (TCB*<T>, long, long, TCB*<T>)
> Purpose:
  | This function initializes parts of the TCB structure and allocates memory for the heap/trail and the environment/choicepoint stacks.  It also links this TCB to the previous TCB if any exist.  If <current_task> is not NULL, then <current_task>'s push down stack.
> Calling Context:
  | 
> Return Value:
  | int - 0 on success
> Parameters:
  = TCB* tcb - pointer to a task control block
  = long heap_trailSize - desired size of the heap/trail stack in bytes
  = long env_cpSize - desired size of the env/cp stack in bytes
  = TCB* current_task - Pointer to the current TCB.  Can be NULL.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_init_task ;
  $ BNRP_BooleanBNRP_init_task (TCB*<T>)
> Purpose:
  | Primitive to create a new task and link it to the chain of tasks.  The primitive has 5 arguements:
  | - Initial goal to be executed by the new task
  | - Desired heap/trail size in Kb
  | - Desired env/cp stack size in Kb
  | - New task's name
  | - New task's ID
  | It sets up the new task to run, so that when a task switch is executed, the initial goal of the new task will be executed.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: delete_Task ;
  $ BNRP_Booleandelete_Task (TCB*<T>)
> Purpose:
  | This primitive removes a task from the task chain.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* task - Pointer to the TCB to be removed
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_end_task ;
  $ BNRP_BooleanBNRP_end_task (TCB*<T>)
> Purpose:
  | Pritive to remove a task other than the currently running task.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - XXXXX_G_PAR
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_removeTaskFromChain ;
  $ BNRP_BooleanBNRP_removeTaskFromChain (TCB**<T>)
> Purpose:
  | This removes the currently running task.  If the task can be removed, tcb will point to the previous task in the task chain.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB** tcb - Pointer to a task control block pointer.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: findTaskID ;
  $ TCB*<T>findTaskID (char*<T>)
> Purpose:
  | Given a name, this searches through the task chain for the TCB with that name.
> Calling Context:
  | 
> Return Value:
  | TCB* - pointer to the TCB with name <taskname>.  If the task can't be found, this value is NULL.
> Parameters:
  = char* taskname - string containing the name of the task.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_selfID ;
  $ BNRP_BooleanBNRP_selfID (TCB*<T>)
> Purpose:
  | This primitive has one arguement which is unified with the task ID of the TCB that called the primitive.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - pointer to a task control block
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_next_task ;
  $ BNRP_BooleanBNRP_next_task (TCB*<T>)
> Purpose:
  | This primitive has 2 arguements.  The first is a task ID.  If the first arguement is an integer, the second arguement gets unified with that task's
  | previous neighbour in the task chain.  If the first arguement is a variable, the second arguement gets unified with the task ID of the last task in the task chain.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, FALSE on failure
> Parameters:
  = TCB* tcb - Pointer to a task control block.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_test_task ;
  $ BNRP_BooleanBNRP_test_task (TCB*<T>)
> Purpose:
  | This primitive has one arguement which is either a task ID or a task name.  Using this arguement, the primitive determines whether or not this is associated with a task in the chain.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on sucess, FALSE on failure.
> Parameters:
  = TCB* tcb - Pointer to a task control block
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_task_switch ;
  $ BNRP_BooleanBNRP_task_switch (TCB**<T>)
> Purpose:
  | This primitive switches between tasks.  BNRP_RESUME() watches for this primitive when it is about to do a primitive call.  This is because this primitive has a pointer to a TCB pointer as an argument to allow it to switch TCB's.  The primtive has two arguements.  The first arguement is used when a
  | task is being initiated (ie. first switch to the new task) and when the tsk is about to perform a send.  The first arguement contains either the name or task ID ofthe task to switch to.  The second arguement indicates what kind of a switch to perform.  If it is a variable, a wait is performed.  In this case, we switch to the current task's invoker.  If it is 0, the new task is initiated.  If it greater than 0, a send is being performed and the second arguement is the message to be sent to the receiver.  This is unified into the receiver.  Upon return <tcb> points to the new TCB.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise FALSE.
> Parameters:
  = TCB** tcb - Pointer to a task control block pointer
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_reply ;
  $ BNRP_BooleanBNRP_reply (TCB*<T>)
> Purpose:
  | This primtiive acknowledges a received message.  It has no argements.  What it does is set the task's invoker's invokee field to NULL.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean
> Parameters:
  = TCB* tcb - Pointer to a task control block.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_self ;
  $ BNRP_BooleanBNRP_self (TCB*<T>)
> Purpose:
  | This primitive shows either the name or the task ID of the task that called it.  It has one arguement which is either an integer, a symbol, or a variable.  If it is a variable, it is unified with the task's name if it has one, otherwise it isunified with the task ID.  If the arguement is a symbol, it is unified with the task's name.  If it is an integer, it is unified with the task's task ID.
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise FALSE
> Parameters:
  = TCB* tcb - Pointer to a task control block.
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Global Function: BNRP_task_status ;
  $ BNRP_BooleanBNRP_task_status (TCB*<T>)
> Purpose:
  | This primitive reports the status of a task.  It has 5 arguements.  The first is the task ID of the task whose status is to be given.  The remaining 4 fields are:
  | 		- The task's invoker's task ID  (NULL if there is none)
  | 		- The task's invokee's task ID  (NULL if there is none)
  | 		- The message the task is waiting on.  This gets unified with NULL as 		  the message is held in state space.
  | 		- The task's name if it has one, otherwise NULL
> Calling Context:
  | 
> Return Value:
  | BNRP_Boolean - TRUE on success, otherwise FALSE
> Parameters:
  = TCB* tcb - Pointer to a task control block
> Exceptions:
  | Throws no exceptions, passes all exceptions through. XXXXX_G_EXC
  | Throws XXXXX_EXCEPTION if XXXXX_G_EXC
> Concurrency:
  | Multithread safe. XXXXX_G_CON
  | _Not_ multithread safe. XXXXX_G_CON
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPlast_task
  $ TCB* BNRPlast_task
> Purpose:
  | Pointer to the last task in the TCB chain.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPtask_count
  $ long BNRPtask_count
> Purpose:
  | The number of tasks in the TCB chain.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRP_SwitchedTask
  $ int BNRP_SwitchedTask
> Purpose:
  | Obsolete!
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPerrorbuf
  $ jmp_buf BNRPerrorbuf
> Purpose:
  | Used in the setjmp call in the validID macro.  This is used only on the Motorola Delta m68K machines.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Data Item: BNRPerrorbuf
  $ sigjmp_buf BNRPerrorbuf
> Purpose:
  | Same as above, but for the other unices.
> Concurrency:
  | Multithread safe. XXXXX_D_CON
  | _Not_ multithread safe. XXXXX_D_CON
> Other Considerations:
  | XXXXX_D_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: VALID_TASK
  $ #define VALID_TASK
> Purpose:
  | This is the mask used in the validation field of a TCB.  If a TCB does not have this in it's validation field, it is considered to be an invalid task.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: validID
  $ #define validID (x)
> Purpose:
  | This macro takes a task ID and checks to see if it is a valid task.  It does this by setting up SIGSEGV and SIGBUS signal handlers.  If after attempting to look at the validation field of the task, we recewive one of those signals, we know we have an invalid task.  If it doesn't generate these signals, we check to make sure the validation field is correct.  If it isn't, we return FALSE.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: validID
  $ #define validID (x)
> Purpose:
  | This is the Macintosh implementation of the above macro which does essentially the same thing.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: SaveRegisters
  $ #define SaveRegisters (task)
> Purpose:
  | This macro saves the current set of BNRPflags into the rmsgVal field of the TCB.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
#if 0
----------------------------------------------------------------------
> Macro: LoadRegisters
  $ #define LoadRegisters (task)
> Purpose:
  | Retrieves the flags from the rmsgVal field into BNRPflags.
> Other Considerations:
  | XXXXX_G_OTH
----------------------------------------------------------------------
#endif
