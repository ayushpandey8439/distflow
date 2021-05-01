%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Apr 2021 22:22
%%%-------------------------------------------------------------------
-module(path).
-author("pandey").

%% API
-export([fix/1]).

pathEnder(Path) ->
  lists:last(Path).

fix(Path) ->
  FixedPath = case pathEnder(Path) of
  47 -> Path;
  _Else ->
  lists:append([Path,"/"])
  end,
  FixedPath.
