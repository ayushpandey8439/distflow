%%%-------------------------------------------------------------------
%% @doc flow public API
%% @end
%%%-------------------------------------------------------------------

-module(flow_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    flow_sup:start_link().

stop(_State) ->
    ok.