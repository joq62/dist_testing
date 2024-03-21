%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(controller_test).      
 
-export([start/0]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(ConnectNodes,[controller_a@c200,controller_a@c202]).
-define(Server,controller_a@c200).
-define(Client,controller_a@c202).



%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
 
%    ok=test1(),
    ok=test2(),
    io:format("Test OK !!! ~p~n",[?MODULE]),
    timer:sleep(2000),
    init:stop(),
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test2()->    
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    rpc:call(?Server,controller,delete_application,["adder"],5000),
    rpc:call(?Server,controller,delete_application,["adder"],5000),
    rpc:call(?Server,controller,delete_application,["divi"],5000),
    timer:sleep(12000),
    []=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    []=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    
    rpc:call(?Server,controller,add_application,["adder"],5000),
    rpc:call(?Server,controller,add_application,["adder"],5000),
    rpc:call(?Server,controller,add_application,["divi"],5000),
    check_started(adder),
    check_started(divi),
   
    [{adder,NodeA1}]=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    [{divi,NodeD2}]=rpc:call(?Client,rd,fetch_resources,[divi],5000),
    42=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),
    42.0=rpc:call(?Client,rd,call,[divi,divi,[420,10],5000],5000),

    timer:sleep(12000),
    [{adder,_},{adder,_}]=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    %% 
    rpc:call(NodeA1,init,stop,[],5000),
    timer:sleep(5000),    
   
    [{adder,_}]=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    42=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),
    42.0=rpc:call(?Client,rd,call,[divi,divi,[420,10],5000],5000),

    timer:sleep(12000),
    [{adder,_},{adder,_}]=rpc:call(?Client,rd,fetch_resources,[adder],5000),

    rpc:call(?Server,controller,delete_application,["adder"],5000),
    rpc:call(?Server,controller,delete_application,["adder"],5000),
    rpc:call(?Server,controller,delete_application,["divi"],5000),
    
    timer:sleep(12000),
    []=rpc:call(?Client,rd,fetch_resources,[adder],5000),
  
    

    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test1()->    
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    rpc:call(?Server,controller,delete_application,["adder"],5000),
    timer:sleep(12000),
    {error,[eexists_resources]}=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),
    
    rpc:call(?Server,controller,add_application,["adder"],5000),
    rpc:call(?Server,controller,add_application,["adder"],5000),
    check_started(adder),
    42=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),

    rpc:call(?Server,controller,delete_application,["adder"],5000),
    timer:sleep(12000),
    42=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),

    rpc:call(?Server,controller,delete_application,["adder"],5000),
    timer:sleep(12000),
    {error,[eexists_resources]}=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),
    

    ok.

check_started(App)->
    check_started(App,100,120,false).

check_started(App,Interval,N,true)->
    true;
check_started(App,Interval,0,Bool)->
    Bool;
check_started(App,Interval,N,false)->
    Bool=case rpc:call(?Client,rd,fetch_resources,[App],5000) of
	     []->
		 timer:sleep(Interval),
		 false;
	     [{App,_Node}|_] ->
		 true
	 end,
    io:format("N ~p~n",[{?MODULE,?FUNCTION_NAME,N}]),
    check_started(App,Interval,N-1,Bool).
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% -------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    ok.
