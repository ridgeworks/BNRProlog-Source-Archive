
	/*******************************************************\
	*							*
	*	BNR Prolog Regression Test Suite:		*
	*	================================		*
	*							*
	*	Program:	Reference Receiver		*
	*	Version:	2.1.0				*
	*	File:		'rfrnce_rec.p'			*
	*	Written:	I Sykes		Date: 8/1/98	*
	*	Revised:			Date:		*
	*							*
	\*******************************************************/


$initialization:- 
		ref_rec.

ref_rec:-
%	SHOW PROLOG VERSION...
		version([V1,V2,V3]),
		write("\nStarted BNR Prolog version ",V1,".",V2,".",V3,":\n\n"),

%	RETRIEVE HOST AND PORT DETAILS:
		s_port(orchestrator,Orc_Host,Orc_port),
		s_port(evaluater,Eval_Host,Eval_port),
		c_port(orc,ref,_,Rec_port),
		c_port(ref,evl,_,Snd_port),
	
%	OPEN COMMUNICATIONS:
%	    ...orchestrator to test receiver socket opened.
		write("Opening to Orchestrater using port ",Rec_port,"\n"),
		open_socket(Rec_port,tcp,OrcRcv),
%	    ...local socket to send opened.
		write("Opening to Evaluater using port ",Snd_port,"\n"),
		open_socket(Snd_port,tcp,EvlSnd),
%	...CONNECT TO ORCHESTRATER,
		delay(8),
		makeconnection(OrcRcv,Orc_Host,Orc_port,0),
		write("Made connection to Orchestrator on host ",Orc_Host," using port ",Orc_port,".\n"),
%	...CONNECT TO EVALUATER.
		makeconnection(EvlSnd,Eval_Host,Eval_port,0),
		write("Made connection to Evaluater on host ",Eval_Host," using port ",Eval_port,".\n"),

%	    ...store for 'write_test'.
		remember(skt(EvlSnd)),

%	PROCESS TERMS...
		assign(cnt(0)), % ...initialise counter.
		receive_term(OrcRcv,EvlSnd),

%	& CLOSE UP SHOP.
		closesocket(OrcRcv),
		closesocket(EvlSnd),
		write("\n\nReceiver terminated!\n\n").
ref_rec:- write("\nTest Receiver main clause 'ref_rec' has failed.\n").



%	READ, WRITE AND EXECUTE TERMS.
		receive_term(SktRcv,SktSnd):- rec(SktRcv,SktSnd,go),!.
		receive_term(SktRcv,SktSnd):- write("\nLeaving test 'receive' loop.\n").
		
			rec(SktOrc,SktEvl,go):-
%			    ...get term from orchestrator,
				receiveTCPterm(SktOrc,X,Err1),
				write("\nReceived term: ",X," with error ",Err1),nl,
%			    ...handshake to orchestrator,
				sendTCPterm(SktOrc,X,Err2),
				write("Handshake term (orc): ",X," with error ",Err2),nl,!,
%			    ...execute the term,
				execute(X,Signal),
%			    ...sign-off to evaluater,
				sendTCPterm(SktEvl,X,Err3),
				write("Sign-off term (eval): ",X," with error ",Err2),nl,!,
%			    ...get the next instruction.
				rec(SktOrc,SktEvl,Signal).



%	EXECUTE TERMS, SIGNALS TERM FAILURE OR TERMINATES PROGRAM AS REQUIRED.	
		execute(Quit,stop):- 
			Quit @= 'quit',
			write("Acknowledged terminal 'quit'\n"),!.
		execute(Halt,stop):- 
			Halt @= 'halt',
			write("Acknowledged terminal 'halt'\n"),!.
		execute(X,go):- 
			var(X),
			write("Skipping variable '",X,"'\n"),!.
		execute(THE_TERM,go):- 
			write("Resolving term '",THE_TERM,"'\n"),
			THE_TERM,
			write("Term '",THE_TERM,"' succeeded.\n"),!.
		execute(The_term,go):- write("Term '",The_term,"' failed!\n").

					
%	ACKNOWLEDGE HANDSHAKE:
		handshake(X):- write("Handshake ",X," acknowledged.\n").

					
%	WRITE A TEST RESULT TO THE EVALUATER (to be used in place of 'write' in a test call)
		write_test(Terms..):-
			recall(skt(SktSnd)),
			cnt(Val),New_val is Val + 1,assign(cnt(New_val)),
			sendTCPterm(SktSnd,[Val,":",Terms..],Err),
			write(Err,"**",Val,Terms),nl,!.
		write_test(Term..):- write("'write_test' failed writing ",Terms),nl.


		assign(X(Y)):-
			retractall(X(_)),
			assert(X(Y)).


%		Open Socket:
%		-------------
		open_socket(X,Y,Z):- opensocket(X,Y,Z),
			write("Opened port ",X," with socket ",Z,"\n"),!.
		open_socket(X,Y,Z):- 
			write("opensocket(",X,",",Y,",",Z,") did not succeed.\n").



