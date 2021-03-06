%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Mar 2021 18:50
%%%-------------------------------------------------------------------
-module(system_setup_SUITE).
-author("pandey").
-include_lib("eunit/include/eunit.hrl").
%% API
-export([all/0,init_per_suite/1,end_per_suite/1,node_setup/1,execute_trivial/1]).

all() -> [
  node_setup,
  execute_trivial
].

init_per_suite(Config) ->
  NodeConfig = [{runner1, 10017}, {runner2, 10018}, {runner3, 10019}],
  test_setup:start_nodes(Config, NodeConfig).


end_per_suite(Config) ->
  ok = test_setup:stop_nodes(Config),
  application:stop(distFlow),
  Config.


node_setup(Config) ->
  Nodes = proplists:get_value(nodes, Config),
  ?assert(length(Nodes) == 3),
  ct:print("Nodes:: ~p",[Nodes]).

execute_trivial(Config) ->
  [NodeA, NodeB, _NodeC] = Nodes = proplists:get_value(nodes, Config),
  task_runner:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/testCases/unitTest1.yaml"),
  FlowMap = rpc:call(NodeA,controller,getFlowMap,[]),
  ?assert(FlowMap == {ok,#{final_data => 'Final Data to be print'}}),
  ct:print("Flow Map on first node:: ~p",[FlowMap]).
