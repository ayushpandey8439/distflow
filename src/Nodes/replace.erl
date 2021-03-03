%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Mar 2021 19:51
%%%-------------------------------------------------------------------
-module(replace).
-author("pandey").

%% API
-export([replace/3]).



replace(Variable, Value, Map) ->
  maps:update(Variable,Value,Map).