%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Apr 2021 19:40
%%%-------------------------------------------------------------------
-module(readFile).
-author("pandey").

%% API
-export([read/2]).

read(Path,Map) ->
  case file:read_file(Path) of
    {ok, Contents} ->
      Contents;
    {error, Reason}->
      {error, Reason}
  end.
