%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Mar 2021 18:44
%%%-------------------------------------------------------------------
-module(test_setup).
-author("pandey").

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").
-include_lib("kernel/include/inet.hrl").

%% API
-export([start_nodes/2,stop_nodes/1]).



start_nodes(Config, NodeConfig) ->
  Nodes = lists:map(fun(N) -> start_node(N, Config) end, NodeConfig),
  [{_, FirstPort}|_] = NodeConfig,
  ct:pal("First port: ~p", [FirstPort]),
  {ok, Pid} = distFlow_app:start("127.0.0.1",FirstPort),
  Disconnected = distFlow_app:stop(Pid),
  ?assertMatch(ok, Disconnected),
  [{nodes, Nodes}, {node_config, NodeConfig} | Config].

start_node({Node, Port}, Config) ->
  ErlFlags =
    "-pa " ++ string:join(code:get_path(), " ") ++ " ",
  %PrivDir = proplists:get_value(priv_dir, Config),
  PrivDir = ".",
  NodeDir = filename:join([PrivDir, Node]),
  CodePath = lists:filter(fun filelib:is_dir/1, code:get_path()),
  case ct_slave:start(Node,
    [{kill_if_fail, true},
      {monitor_master, true},
      {init_timeout, 10000},
      {startup_timeout, 10000},
      {env, [
        {"RUNNER_PORT", integer_to_list(Port)},
        {"LOG_DIR", NodeDir},
        {"OP_LOG_DIR", filename:join([NodeDir, "op_log"])}
      ]},
      {startup_functions,
        [{code, set_path, [CodePath]}]},
      {erl_flags, ErlFlags}]) of
    {ok, HostNode} ->
      ct:pal("Node ~p [OK1]", [HostNode]),
      rpc:call(HostNode, application, ensure_all_started, [distFlow]),
      ct:pal("Node ~p [OK2]", [HostNode]),
      pong = net_adm:ping(HostNode),
      HostNode;
    {error, started_not_connected, HostNode} ->
      ct:pal("Node ~p [START failed] started_not_connected", [HostNode]),
      rpc:call(HostNode, application, ensure_all_started, [microdote]),
      ct:pal("Node ~p [OK2]", [HostNode]),
      pong = net_adm:ping(HostNode),
      HostNode;
    {error, already_started, HostNode} ->
      ct:pal("Node ~p [START failed] already_started", [HostNode]),
      % try again:
      stop_node(Node),
      start_node({Node, Port}, Config)
  end.

stop_nodes(Config) ->
  NodeConfig = proplists:get_value(node_config, Config),
  lists:map(fun({Node, _}) -> stop_node(Node) end, NodeConfig),
  ok.

stop_node(Node) ->
  case ct_slave:stop(Node) of
    {ok, HostNode} ->
      ct:pal("Node ~p [STOP OK]", [HostNode]);
    {error, not_started, Name} ->
      ct:pal("Node ~p [STOP FAILED] not started", [Name]);
    {error, not_connected, Name} ->
      ct:pal("Node ~p [STOP FAILED] not connected", [Name]);
    {error, stop_timeout, Name} ->
      ct:pal("Node ~p [STOP FAILED] stop_timeout", [Name])
  end.
