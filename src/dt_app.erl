%%%-------------------------------------------------------------------
%% @doc adder public API
%% @end
%%%-------------------------------------------------------------------

-module(dt_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    dt_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
