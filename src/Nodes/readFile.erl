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
-export([read/3]).

read(Path,Output,Map) ->
  case file:read_file(Path) of
    {ok, Contents} ->
      maps:put(Output,binary_to_list(Contents),Map);
    {error, Reason}->
      {error, Reason}
  end.
