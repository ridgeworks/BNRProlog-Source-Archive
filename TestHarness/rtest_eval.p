
	/*******************************************************\
	*							*
	*	BNR Prolog Regression Test Suite:		*
	*	================================		*
	*							*
	*	Program:	Test Result Evaluater		*
	*	Version:	1.1.0				*
	*	File:		'rtest_eval.p'			*
	*	Written:	I Sykes		Date: 7/1/98	*
	*	Revised:			Date:		*
	*							*
	\*******************************************************/


$initialization:- 
		evaluate.

evaluate:-
%	SHOW PROLOG VERSION...
		version([V1,V2,V3]),
		write("\nEVALUATER: Using BNR Prolog version ",V1,".",V2,".",V3,":\n\n"),

%	...RETRIEVE HOST AND PORT DETAILS,
		s_port(evaluater,_,Evl_port),
		s_port(orchestrator,Orc_host,Orc_port),
		c_port(evl,orc,_,Snd_port),
	
%	...OPEN COMMUNICATIONS: 'Rcv_ref', 'Rcv_tst' and 'SktSnd',
		delay(4),
%	    ...test receivers to evaluater socket opened.
		write("Opening Evaluater port ",Evl_port,"\n"),
		open_socket(Evl_port,tcp,Evl_rcv),
%	    ...evaluater to orchestrator socket opened.
		write("Opening for Orchestrator ",Snd_port,"\n"),
		open_socket(Snd_port,tcp,Snd_orc),

%	...LISTEN FOR TEST AND REFERENCE CLIENTS,
		make_connections(Evl_rcv,New_ref,New_tst,500),

%	...CONNECT TO ORCHESTRATOR,
		makeconnection(Snd_orc,Orc_host,Orc_port,Error),
		write("Connected to Orchestrator: ",Snd_orc,"|",Orc_host,"|",Orc_port,"|",Error),nl,
		Error @= 0,
		
%	...EVALUATE THE RESULTS,
		evaluation(New_tst,New_ref,Snd_orc,true),
	
%	& CLOSE UP SHOP.
		close_all,
		write("\nEVALUATER: Terminated normally.\n\n"),!.
evaluate:- 
		write("\nTEST EVALUATER: Main clause 'evaluate' has failed.\n"),
		close_all.




%	Listen for the tcp connection:
%	=============================
%	 Put make_connect(Socket,RHost,RPort,NewSocket,1) x3 into a loop and 
%	 check NewSocket for instantiation.

	make_connections(Skt,New_Skt1,New_Skt2,Wait):-
		c_port(tst,evl,H1,P1),
		c_port(ref,evl,H2,P2),
		time(Epochsecs),Timeup = Epochsecs + Wait,remember(timeout(Timeup)),
	    	make_connection(Skt,[H1,P1,H2,P2],[New_Skt1,New_Skt2]).

	    	make_connection(_,_,_):- timeup,write("Timed out!\n"),!.
	    	make_connection(_,_,List):- ground(List),write("Ground list:",List),nl,!.
 	   	make_connection(Skt,[H1,P1,H2,P2],[New_Skt1,New_Skt2]):-
			repeat,
			listensocket(Skt,0),
			write("Heard socket ",Skt,"...\n"),
			write("Expecting ",H1,",",P1," or ",H2,",",P2),nl,
			acceptconnection(Skt,RH,RP,NewSocket,0),
 			write("accepted ",RH,"|",RP,"|",NewSocket,".\n"),
			assert(skt(NewSocket)),
	    		make_connect(RH,RP,NewSocket,[H1,P1,H2,P2],[New_Skt1,New_Skt2]),
		    	make_connection(Skt,[H1,P1,H2,P2],[New_Skt1,New_Skt2]).

			make_connect(Host,Port,Socket,[Host,Port,_,_],[Socket,_]):-
 				write("assigned ",Host,"|",Port,"|",Socket,".\n"),!.
			make_connect(Host,Port,Socket,[_,_,Host,Port],[_,Socket]):-
 				write("assigned ",Host,"|",Port,"|",Socket,".\n"),!.
			make_connect(_,_,_,_,_):- write("No assignment made.\n").


			timeup:- recall(timeout(Timeup)),
				 time(Time),Time > Timeup.


%		Open Socket:
%		-------------
		open_socket(X,Y,Z):- 
			opensocket(X,Y,Z),
			assert(skt(Z)),
			write("Opened socket ",Z),nl,!.
		open_socket(X,Y,Z):- write("opensocket(",X,",",Y,",",Z,") did not succeed.\n").


%	Close Sockets and Streams:
%	=========================

	close_all:-
		findall(Skt,skt(Skt),Skt_list),
		findall(Strm,strm(Strm),Strm_list),
		close_socket(Skt_list),
		close_stream(Strm_list),
		write("\nORCHESTRATOR: Files & sockets closed.\n").

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
		


%	PROCESS TERMS:
		evaluation(_,_,_,Quit):- % Finish up on 'quit'.
			Quit @= "quit",!.
		evaluation(_,_,_,Quit):- % Finish up on 'halt'.
			Quit @= "halt",!.
		evaluation(Rcv_tst,Rcv_ref,Snd_Orc,_):-
%		    ...get test term,
			fetch_term(Rcv_tst,X,Err1,"\nRECEIVED FROM TEST:\n"),
%		    ...get reference term,
			fetch_term(Rcv_ref,Y,Err2,"RECEIVED FROM REFERENCE:\n"),
%		    ...check for sprurious reads,
			trap_vars(X,Y,XX,YY,Rcv_tst,Rcv_ref),
%		    ...evaluate the responses,
			compare(XX,YY,Z),
%		    ...handshake to orchestrator &
			sendTCPterm(Snd_Orc,Z,Err3),
			write("Result ",Z," returned to Orchestrater with error ",Err3),nl,!,
%		    ...fetch the next pair.
			evaluation(Rcv_tst,Rcv_ref,Snd_Orc,Z).



%		CHECK FOR SPRURIOUS READS:
%		    ...two instantiated values are OK.
			trap_vars(Val1,Val2,Val1,Val2,_,_):- nonvar(Val1),nonvar(Val2),!.
%		    ...two variables are OK (maybe).
			trap_vars(Val1,Val2,Val,Val,_,_):- 
				var(Val1),var(Val2),
				write("\nRECEIVED VARIABLE PAIR\n"),
				Val = "received variable pair.",!.
%		    ...check 'test': if value un-instantiated then read again.
			trap_vars(Val1,Val2,ValA,ValB,Rcv_tst,Rcv_ref):-
				var(Val1),nonvar(Val2),
				write("\nSUSPECT VAR...re-reading TEST\n"),
				fetch_term(Rcv_tst,X,_,"\nRECEIVED FROM TEST:\n"),!,
				trap_vars(X,Val2,ValA,ValB,Rcv_tst,Rcv_ref).
%		    ...check 'reference': if value un-instantiated then read again.
			trap_vars(Val1,Val2,ValA,ValB,Rcv_tst,Rcv_ref):-
				var(Val2),nonvar(Val1),
				write("\nSUSPECT VAR...re-reading REFERENCE\n"),
				fetch_term(Rcv_ref,Y,_,"RECEIVED FROM REFERENCE:\n"),!,
				trap_vars(Val1,Y,ValA,ValB,Rcv_tst,Rcv_ref).


%		      Get TCP term.
			fetch_term(Rcv,X,Err,Text):-
				receiveTCPterm(Rcv,X,Err),
				write(Text,X),nl.


%	EVALUATE THE RESPONSES.
%	    ...perform a literal comparison, or
	compare(X,Y,X):- 
		write("literal equiv\n"),
		X @= Y,
		write("COMPARISON SUCCESSFUL (literal equiv)\n\n"),!.
%	    ...decompose lists and test term by term, or
	compare(X,Y,X):- 
		write("list decomp\n"),
		list(X),list(Y),
		termlength(X,Len1,Xt),termlength(Y,Len1,Yt),tv_check(Xt,Yt,Tv),
		write("\tList lengths are ",Len1," plus ",Tv,"tailvars."),nl,
		process_lists(X,Y),
		write("COMPARISON SUCCESSFUL (list decomp)\n\n"),!.
%	    ...align the variables in the terms and compare the results, or
	compare(X,Y,X):- 
		write("var align\n"),
		not(list(X)),not(list(Y)),
		variable_alignment(X,Y,Total),
		write("COMPARISON SUCCESSFUL (align x ",Total,")\n\n"),!.
%	    ...conclude that the terms are not equivalent.
	compare(X,Y,fail(X,Y)):- write("\nCOMPARISON FAILED\n"),nl.
	

%	    Check for mismatched tail variables.
		tv_check(Xt,Yt,""):- tailvar(Xt..),tailvar(Yt..),!.
		tv_check(Xt,Yt,"no "):- not(tailvar(Xt..)),not(tailvar(Yt..)),!.
		tv_check(Xt,Yt,_):- tailvar(Xt..),not(tailvar(Yt..)),!,fail.
		tv_check(Xt,Yt,_):- tailvar(Yt..),not(tailvar(Xt..)),fail.


%	    Decomposes lists and compares term by term.
		process_lists([],[]):- !.
		process_lists([X,XX..],[Y,YY..]):- !,
			write("\tProcess list items ",X,"|",Y),nl,
			compare(X,Y,Z),
			not([Z = fail(_..)]),
			process_lists(XX,YY).

	

%	     Takes the variables and tail variables in a term and grounds them to integers.
		variable_alignment(Term1,Term2,Total):-
			write(Term1,"|",Term2),nl,
%		    ...if the Term1 and Term2 are clauses then compare their names,
			get_clause_name(Term1,Name1),
			get_clause_name(Term2,Name2),
			Name1 @= Name2,write("\tClause: ",Name2),nl,
%		    ...collect the vars & tail vars into lists,
			variables(Term1,List1,List2),
			variables(Term2,List3,List4),
%		    ...compare list sizes and fail if all are empty,
			termlength(List1,Len1,_),termlength(List3,Len1,_),
			write("Var list lengths are ",Len1),nl,
			termlength(List2,Len2,_),termlength(List4,Len2,_),
			write("Tailvar list lengths are ",Len2),nl,
			not([Len1 = 0,Len2 = 0]),
%		    ...remove duplicates from var lists,
			sort(List1,Ulist1),sort(List2,Ulist2), % write(Ulist1,"|",Ulist2),nl,
			sort(List3,Ulist3),sort(List4,Ulist4), % write(Ulist3,"|",Ulist4),nl,
%		    ...instantiate variables to integers.
			instantiate(Ulist1,Ulist3,Cnt1),
%		    ...instantiate tail vars to integers.
			instantiate(Ulist2,Ulist4,Cnt2),
			Total is Cnt1 + Cnt2.
				
%		     If the input term is a clause the head name is returned.
			get_clause_name(Clause,Name):- arg(0,Clause,Name),!.
			get_clause_name(_,"No clause name").


%		     Works through the variable list and instantiates the variables to integers.
			instantiate(ListA,ListB,Cnt):- 
				inst(ListA,ListA,ListB,ListB,888,N),
				Cnt is N - 888. %,write(Cnt," instantiations.\n").
				
				inst([],List,[],List,Cnt,Cnt):- !. % Terminating condition: empty lists.
				inst([N,T1..],L1,[N,T2..],L2,N,Cnt):- % For variables:
					M is N + 1,!, % ...increment and
					inst(T1,L1,T2,L2,M,Cnt). % ...go around again.
				inst([[N],T1..],L1,[[N],T2..],L2,N,Cnt):- % For tail variables:
					M is N + 1,!, % ...increment and
					inst(T1,L1,T2,L2,M,Cnt). % ...go around again.
	
			

