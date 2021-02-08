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

echo("io",Value,Map)->
  io:format("~p ~n",[Value]),
 Map;

echo(Put,Value,Map)->
      case maps:is_key(Put,Map) of
        false ->
          UpdatedMap = maps:put(Put,Value,Map),
          UpdatedMap;
        true ->
          UpdatedMap = maps:update(Put,Value,Map),
          UpdatedMap
      end.