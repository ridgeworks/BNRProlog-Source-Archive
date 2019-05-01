
	/*******************************************************\
	*							*
	*	BNR Prolog Regression Test Suite:		*
	*	================================		*
	*							*
	*	Program:	Test orchestrator		*
	*	Version:	2.1.2				*
	*	File:		RTEST				*
	*	Written:	I Sykes		Date: 29/1/97	*
	*	Revised:			Date:		*
	*							*
	\*******************************************************/


%	Main:
%	====

	test(Script,ID):-
%	    ...get server port data,
		delay(Delay),
		s_port(orchestrator,_,S_port),
%	    ...open ports,
		initialise(S_Skt,Stream,S_port,Delay,Script,ID),
%	    ...listen for connections,
	    	make_connections(S_Skt,New_Skt1,New_Skt2,New_Skt3,500),
%	    ...send test ID to the Test receiver:
		handshake(New_Skt1,New_Skt2,New_Skt3,ID),!,
%	    ...run the test script,
		run_tests(New_Skt1,New_Skt2,New_Skt3,Stream,go),
%	    ...close the connections.
		close_all,!.
	test(Script,ID):- 
		write("\nORCHESTRATOR: Test run ",ID," from script '",Script,"' has failed.\n\n"),
		close_all.
		
		
%	Initialisation operations:
%	=========================

	initialise(Socket,Stream,Port,Delay,Script,ID):-
%	    ...show prolog version and session ID:
		version([V1,V2,V3]),
		write("\nORCHESTRATOR: Using BNR Prolog version ",V1,".",V2,".",V3,":\n\n"),
		write("\nORCHESTRATOR: Test ID is ",ID),nl,
%	    ...open socket:
		open_socket(Port,tcp,Socket),
		networkconfig(Port, Delay, Delay, 8192),
		write("ORCHESTRATOR: Port ",Port," socket ",Socket," opened\n"),
%	    ...open test script file:
		open_stream(Stream,Script,read_only),
%	    ...generate test result file name:
		symbol_string(ID,ID_string),
		concat("rslt",ID_string,Result),
%	    ...open test result file:
		open_stream(Result_stream,Result,read_write),
%	    ...generalise test result file name to 'result':
		retract(strm(Result,Result_stream)),
		assert(strm(result,Result_stream)),
%	    ...write to log file:
		write("ORCHESTRATOR: Initialisation complete.\n\n"),!.
	initialise(Skt,Stream,_,_,_,ID):-
		write("\nORCHESTRATOR: Initialisation in test run ",ID," has failed."), % log failure
		fail.
			


%	Listen for the tcp connections:
%	==============================
	make_connections(Skt,New_Skt1,New_Skt2,New_Skt3,Wait):-
		c_port(orc,tst,H1,P1),
		c_port(orc,ref,H2,P2),
		c_port(evl,orc,H3,P3),
		time(Epochsecs),Timeup = Epochsecs + Wait,remember(timeout(Timeup)),
	    	make_connection(Socket,[H1,P1,H2,P2,H3,P3],[New_Skt1,New_Skt2,New_Skt3]).


	    	make_connection(_,_,_):- timeup,write("Timed out!\n"),!.
	    	make_connection(_,_,List):- ground(List),write("Ground list:",List),nl,!.
 	   	make_connection(Skt,[H1,P1,H2,P2,H3,P3],[New_Skt1,New_Skt2,New_Skt3]):-
			repeat,
			listensocket(Skt,0),
			write("Heard socket ",Skt,"...\n"),
			write("Expecting ",H1,",",P1," or ",H2,",",P2," or ",H3,",",P3),nl,
			acceptconnection(Skt,RH,RP,NewSocket,0),
 			write("accepted ",RH,"|",RP,"|",NewSocket,".\n"),
			assert(skt(NewSocket)),
	    		make_connect(RH,RP,NewSocket,[H1,P1,H2,P2,H3,P3],[New_Skt1,New_Skt2,New_Skt3]),
		    	make_connection(Skt,[H1,P1,H2,P2,H3,P3],[New_Skt1,New_Skt2,New_Skt3]).


			make_connect(Host,Port,Socket,[Host,Port,_,_,_,_],[Socket,_,_]):-
 				write("assigned ",Host,"|",Port,"|",Socket,".\n"),!.
			make_connect(Host,Port,Socket,[_,_,Host,Port,_,_],[_,Socket,_]):-
 				write("assigned ",Host,"|",Port,"|",Socket,".\n"),!.
			make_connect(Host,Port,Socket,[_,_,_,_,Host,Port],[_,_,Socket]):-
 				write("assigned ",Host,"|",Port,"|",Socket,".\n"),!.
			make_connect(_,_,_,_,_):- write("No assignment made.\n").


			timeup:- recall(timeout(Timeup)),
				 time(Time),Time > Timeup.


%	Handshake using the test run ID:
%	===============================
		
	handshake(New_Skt1,New_Skt2,New_Skt3,ID):-

		sendTCPterm(New_Skt1,handshake(ID),Err1),
		trap_err(Err1,"Test_host handshake."),
		write("Handshake ",ID," going via socket ",New_Skt1),nl,
		
		sendTCPterm(New_Skt2,handshake(ID),Err2),
		trap_err(Err2,"Ref_host handshake."),
		write("Handshake ",ID," going via socket ",New_Skt2),nl,
		
		delay(3),
		
		receiveTCPterm(New_Skt1,ID_back,E3),
		write("Received ",ID_back," via socket ",New_Skt1," with error ",E3),nl,
		trap_err(Err3,"Reference handshake."),
		receiveTCPterm(New_Skt2,ID_back,Er3),
		write("Received ",ID_back," via socket ",New_Skt2," with error ",Er3),nl,
		trap_err(Err3,"Test handshake."),
		receiveTCPterm(New_Skt3,ID_back,Err3),
		write("Received ",ID_back," via socket ",New_Skt3," with error ",Err3),nl,
		trap_err(Err3,"Evaluation handshake."),

		handshake(ID) @= ID_back,
		write("ORCHESTRATOR: Handshaking for session ",ID," is complete.\n\n"),!.
	handshake(_,_,_,_,_,_,_,_,ID):-
		write("\nORCHESTRATOR: Handshake for session ",ID," has failed."),fail. 


			
%	Execute test script:
%	===================
			
	run_tests(SktR,SktT,SktE,File,go):- % Execute test script...
		write("========\n"),
% 	    ...log filepos:
		at(File, Where), 
%	    ...if:
		not(at(File, end_of_file)),
%	    ...get a term from the test script:	
		get_term(File,Term,Err1),
		write("ORCHESTRATOR: Retrieved term ",Term," from file position ",Where),nl, % log get
		flag_err(Err1,"'get_term'."),
		check_term(Term,Err2),
%	    ...send the term to the test receiver:
		sendTCPterm(SktT,Term,Err3),
		trap_err(Err3,"Test_host handshake."),
%	    ...send the term to the reference receiver:
		sendTCPterm(SktR,Term,Err4),
		trap_err(Err4,"Ref_host handshake."),
%	    ...wait for receiver to complete and echo:
		poll_it(Term,SktR,SktT,SktE,Err5),
%	    ...collect the errors:
		status(Err1,Err2,Err3,Err4,Err5,Status),
%	    ...log status:
		write("\nStatus:\t error codes: ",Err1,Err2,Err3,Err4,Err5,"->",Status),nl,!, 
		run_tests(SktR,SktT,SktE,File,Status).
	run_tests(SktR,SktT,SktE,File,go):-	% ...possible 'check_term' failure...
		not(at(F, end_of_file)),!,
		run_tests(SktR,SktT,SktE,File,Status).
	run_tests(_,_,_,File,go):-	% ...or carry on to close...
%	    ...if:
		at(File, end_of_file),
%	    ...move on:
		write("\nORCHESTRATOR: End of test script file reached.\n"),!. % log end of script
	run_tests(_,_,_,_,stop):-	% ...or end of test script file...
		write("\nORCHESTRATOR: Script contains terminal ('quit' or 'halt').\n"),!.
	run_tests(SktR,SktT,SktE,File,Status):-	% ...or terminate due to error.
		write("\nORCHESTRATOR: Status at failure: ",Status), % log errors
		at(File, Where),write("\nORCHESTRATOR: Failed at file position: ",Where),nl,!, % log filepos
		fail.



%	POLL INPUTS FROM TEST, REFERENCE & EVALUATER:
%	============================================
		poll_it(Term,SktR,SktT,SktE,0):-
			write("Polling for term ",Term),nl,
			poll(Term,SktR,_,SktT,_,SktE,_),
			write_result("Executing ",Term,"\n"),
			assess_results(Term),!.
		poll_it(_,_,_,_,1).
			
%	      Exit condition....all inputs equal 'Term' or..		
		poll(Term,_,A,_,B,_,C):- 
			nonvar(A),A @= Term,
			nonvar(B),B @= Term,
			nonvar(C),C @= Term,
			write("Inputs matched"),nl,!.
%	      ...check the responses (again).
		poll(Term,SktR,A,SktT,B,SktE,C):- 
%		    ...check the 'reference' response,
			test_poll(Term,SktR,A,AA),%write("\npolled ref:"),
%		    ...check the 'test' response,
			test_poll(Term,SktT,B,BB),%write("\npolled test:"),
%		    ...check the 'evaluater' response and
			test_poll_evl(Term,SktE,C,CC),%write("\npolled eval:"),
%		    ...indicate end of cycle in the log file,
			write("--------\n"),!,
%		    ...assign new values to AA,BB & CC and go around the loop again.
			poll(Term,SktR,AA,SktT,BB,SktE,CC).


			test_poll(_,Skt,X,XX):- 
%			     If the input (X) is a variable then..
				var(X),
%			    ...look at the socket 'Skt'.
				look_at(Skt,XX),!.
			test_poll(Term,_,X,XX):- 
%			     If the input is not a variable then.. 
				nonvar(X),
%			    ...check for literal equivalence and pass it back.
				X @= Term,XX=X,!.
			test_poll(Term,_,X,XX):- 
%			     If the input is neither a variable or matches 'Term' then fail.
				!,fail.

			test_poll_evl(Term,Skt,C,CC):- 
%			     If the input (C) is a variable..
				var(C),
%			    ...look at the socket 'Skt'.
				look_at(Skt,CC),!.
			test_poll_evl(Term,Skt,C,CC):- 
%			     If the input is not a variable.. 
				nonvar(C),
%			    ...check for literal non-equivalence and evaluation failure,
				C @\= Term,C = fail(_..),
%			    ...write comment to log and..
				write("EVALUATION FAILURE:\n",C),nl,
%			    ...record the failure,
				assertz(failure(Term,C)),
%			    ...look at the socket 'Skt'.
				look_at(Skt,CC),!.
			test_poll_evl(Term,Skt,C,CC):- 
%			     If the input is not a variable then.. 
				nonvar(C),
%			    ...check for literal non-equivalence,
				C @\= Term,
%			    ...write comment to log and..
				write("Successful evaluation:\n",C),nl,
%			    ...look at the socket 'Skt'.
				look_at(Skt,CC),!.
			test_poll_evl(Term,_,C,C):- 
%			     If the input is not a variable then.. 
				nonvar(C),
%			    ...check for literal equivalence and pass it back.
				C @= Term.

				look_at(Socket,String):-
					receiveTCPterm(Socket,String,Err),
					flag_err(Err,"'look_at(Socket,Term)'."),!.
				look_at(Socket,String):- write("\nlook_at failed with ",Socket,":",String),nl.



		assess_results(Term):-
			count(failure(Term,C),N),N > 0,
			list_fails(Term),!.
		assess_results(Term):-
			write_result(Term," has succeeded.\n\n").

			list_fails(Term):-
				write_result("\tThe following evaluation failures occurred:\n"),
				failure(Term,[Test_no,_,Result]),
				write_result("\tTest output ",Test_no," has failed evaluation.\n\t\tData is: ",Result,".\n"),
				fail.
			list_fails(_):-
				write_result("\n",Term," has failed.\n\n").


%		Validate a term from the orchestration script:
%		---------------------------------------------
%	    ...stop a variable being sent to the test and reference programs.
		check_term(Term,_):- 
			var(Term),
			write("\nORCHESTRATOR: Retrieved a variable: ",Term,". Ignore!"),nl,!,fail.
%	    ...shutdown gracefully on receipt of 'quit' or 'halt'.
		check_term(quit,1):- write("\nORCHESTRATOR: Acknowledged terminal 'quit'"),nl,!.
		check_term(halt,1):- write("\nORCHESTRATOR: Acknowledged terminal 'halt'"),nl,!.
%	    ...send the term out to be tested.
		check_term(Term,0):- nonvar(Term).



%		Respond to error/s:
%		------------------
		status(0,0,0,0,0,go):-!.
		status(0,1,0,0,0,stop):-!.
		status(Err1,Err2,Err3,Err4,Err5,Status):-
			Status is Err1+Err2+Err3+Err4+Err5.
			
/*		Intention was to add intelligence to 'status' here:	
			symbol_string(Errl,Str1),write(Str1),nl,
			concat("\n\tGet term: ",Str1,Msg1),write(Msg1),nl,
			symbol_string(Err2,Str2),write(Str2),nl,
			concat("\n\tCheck term: ",Str2,Msg2),write(Msg2),nl,
			symbol_string(Err3,Str3),write(Str3),nl,
			concat("\n\tPut term: ",Str3,Msg3),write(Msg3),nl,
			symbol_string(Err4,Str4),write(Str4),nl,
			concat("\n\tGet echoed term: ",Str4,Msg4),write(Msg4),nl,
			concat(Msg1,Msg2,Msg5),write(Msg5),nl,
			concat(Msg5,Msg3,Msg6),write(Msg6),nl,
			concat(Msg6,Msg4,Status),write(Status).
*/



%		Writes to the result file:
%		-------------------------
		write_result(Val..):- 
			strm(result,Result_stream),
			swrite(Result_stream,Val..).



%		Converts a symbol to a string:
%		-----------------------------
		symbol_string(Symbol,String):-
			numeric(Symbol),
			swrite(String,Symbol),!.
		symbol_string(String,String).



				
%	File/Stream Handling:
%	====================	


%	Close Sockets and Streams:
%	-------------------------
	close_all:-
		findall(Skt,skt(Skt),Skt_list),
		findall(Strm,strm(_,Strm),Strm_list),
		close_socket(Skt_list),
		close_stream(Strm_list),
		write("\nORCHESTRATOR: Files & sockets closed.\n").

		
%		Open File:
%		---------
		 open_stream(Stream,File,Mode):-
			open(Stream,File,Mode,0),
			assert(strm(File,Stream)),
			write("ORCHESTRATOR: Opening stream ",Stream," with error code ",Err,"\n"),
			stream(Stream,A,B),
			write("ORCHESTRATOR: Confirming that stream ",Stream," is file ",A," and is a ",B,":\n"),!.
		 open_stream(Stream,File,Mode):- write("Stream for file ",File," failed to open using mode ",Mode,".\n").


%		Open Socket:
%		-------------
		open_socket(X,Y,Z):- 
			opensocket(X,Y,Z),
			assert(skt(Z)),
			write("Opened socket ",Z),nl,!.
		open_socket(X,Y,Z):- write("opensocket(",X,",",Y,",",Z,") did not succeed.\n").


%		Close Sockets:
%		-------------
		close_socket([]):- !.
		close_socket([X,Y..]):-
			closesocket(X),
			write("\nClosing socket ",X,".\n"),
			close_socket(Y).

%		Close Streams:
%		-------------
		close_stream([]):- !.		
		close_stream([X,Y..]):-		
			stream(X,A,_),
			close(X,Err),
			flag_err(Err,"file close."),
			write("\nClosing file stream ",X,".\n"),
			close_stream(Y).		
		

	
%		Error Handlers:
%		--------------
			trap_err(0,_):-!.
			trap_err(Err,X):- flag_err(Err,X),fail.

			flag_err(0,_):-!.
			flag_err(Err,X):- write("\nWARNING! Error code ",Err," for ",X),nl.

			error_handler:-
				get_error_code(Error_code),
				write('Received error ', Error_code, '\n').
