%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Apr 2021 20:35
%%%-------------------------------------------------------------------
-module(stringToList).
-author("pandey").

%% API
-export([convert/3]).

convert(Variable,Delimiter,Map) ->
  String = maps:get(Variable,Map),
  List = string:tokens(String,Delimiter),
  maps:put(Variable,List,Map).

