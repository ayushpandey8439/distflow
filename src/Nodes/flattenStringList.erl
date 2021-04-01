%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Apr 2021 20:57
%%%-------------------------------------------------------------------
-module(flattenStringList).
-author("pandey").

%% API
-export([flattenStringList/1]).

-spec(flattenStringList(List::list()) ->
  list()).
flattenStringList(List) ->
  lists:concat(List).
