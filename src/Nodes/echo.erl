%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Dec 2020 05:10
%%%-------------------------------------------------------------------
-module(echo).
-author("pandey").

%% API
-export([echo/3]).

echo(Put,Value,Map) when Put == "io" ->
  io:format("~p ~n",[Value]),
 Map;

echo(Put,Value,Map) when Put =/= "io" ->
  UpdatedMap = maps:put(Put,Value,Map),
  UpdatedMap.