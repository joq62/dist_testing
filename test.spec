99% the node and service are running

allocate service nodes
use one -> failed -> test next etc



rpc:call(Node,Module,Function,Args,TimeOut)-> Result | {ok,Result} | {error,Reason} | {badrpc,Reason}  ({badrpc,{'EXIT',Reason}} | {badrpc,timeout})

    {badrpc,{'EXIT',{badarith,_}}}=rpc:call(node(),adder,divi,[2,0],5000),
    {badrpc,{'EXIT',{undef,[{glurk,glurk,[2,0],[]}]}}}=rpc:call(node(),glurk,glurk,[2,0],5000),
    {badrpc,{'EXIT',{noproc,{gen_server,call,[adder,{add,2,0},infinity]}}}}=rpc:call(node(),adder,add,[2,0],5000),
    ok=application:start(adder),
    pong=adder:ping(),
    {badrpc,{'EXIT',_}}=rpc:call(node(),adder,add,[m,0],5000),
    {badrpc,{'EXIT',{undef,[{adder,add,[1,2,0],[]}]}}}=rpc:call(node(),adder,add,[1,2,0],5000),
    {badrpc,timeout}=rpc:call(node(),adder,add,[1,2,0],0),

 %% cast
    ok=application:stop(adder),
    true=rpc:cast(node(),adder,divi,[2,0]),
    true=rpc:cast(node(),glurk,glurk,[2,0]),
    true=rpc:cast(node(),adder,add,[2,0]),
    ok=application:start(adder),
    pong=adder:ping(),
    true=rpc:cast(node(),adder,add,[m,0]),
    true=rpc:cast(node(),adder,add,[1,2,0]),



    
      case rpc:call(Node,M,F,A,T) of
          {badrpc,Reason}->
                {error,[badrpc,Reason,?MODULE,?LINE]};
          {ok,Result}->
                {ok,Result};
          {error,Reason}->
                {error,[error,Reason,?MODULE,?LINE]};
          Result->
               Result
     end.
