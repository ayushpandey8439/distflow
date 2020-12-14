%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Dec 2020 18:04
%%%-------------------------------------------------------------------
-module(map).
-author("pandey").

%% API
-export([map/2]).

map(Function,List) ->
  %%TODO Perform map operation on the List and then spawn the process on the target node
  lists:foreach(Function,List).