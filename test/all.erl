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
-module(all).      
 
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
    ok=controller_test:start(),
  %  ok=test1(),
   % ok=test2(),
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
    rpc:call(?Server,controller,reconciliate,[],5000),
    timer:sleep(2000),
    
    []=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    
    rpc:call(?Server,controller,add_application,["adder"],5000),
    rpc:call(?Server,controller,reconciliate,[],5000),
    check_started(adder),
    timer:sleep(500),
    [{adder,Node1}]=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    42=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),

    %% 
    rpc:call(Node1,init,stop,[],5000),
    timer:sleep(5000),
    rpc:call(?Server,controller,reconciliate,[],5000),
    check_started(adder),
    timer:sleep(500),
    [{adder,Node2}]=rpc:call(?Client,rd,fetch_resources,[adder],5000),
    42=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),

    rpc:call(?Server,controller,delete_application,["adder"],5000),
    rpc:call(?Server,controller,reconciliate,[],5000),
    timer:sleep(2000),
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
    rpc:call(?Server,controller,reconciliate,[],5000),
    timer:sleep(2000),
    
    {error,[eexists_resources]}=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),
    
    rpc:call(?Server,controller,add_application,["adder"],5000),
    rpc:call(?Server,controller,reconciliate,[],5000),
    check_started(adder),
    timer:sleep(500),
    42=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),

    rpc:call(?Server,controller,delete_application,["adder"],5000),
    rpc:call(?Server,controller,reconciliate,[],5000),
    timer:sleep(2000),
    {error,[eexists_resources]}=rpc:call(?Client,rd,call,[adder,add,[20,22],5000],5000),
    

    ok.

check_started(App)->
    check_started(App,100,100,false).

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
    PingResult=[{rpc:call(N1,net_adm,ping,[N2],5000),N1}||N1<-?ConnectNodes,
							  N2<-?ConnectNodes],
    Nodes=lists:append([rpc:call(N,erlang,nodes,[],5000)||{pong,N}<-PingResult]),
    PingR=[{net_adm:ping(N),N}||N<-lists:usort(Nodes)],
    io:format("PingR ~p~n",[{?MODULE,?FUNCTION_NAME,PingR}]),
    
    ok=application:start(log),
    ok=application:start(rd),
    
    [rd:add_local_resource(ResourceType,Resource)||{ResourceType,Resource}<-[]],
    [rd:add_target_resource_type(TargetType)||TargetType<-[adder,divi,controller,catalog,host,deployment]],
    rd:trade_resources(),
    timer:sleep(3000),
    [rpc:call(?Client,rd,add_target_resource_type,[TargetType],5000)||TargetType<-[adder,divi]],
    rpc:call(?Client,rd,trade_resources,[],2*5000),
    timer:sleep(3000),
     
    ok.
