%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Apr 2021 00:52
%%%-------------------------------------------------------------------
-module(listfiles).
-author("pandey").

%% API
-export([listfiles/3]).

listfiles(Path,TargetVariable,Map) ->
  case file:list_dir(Path) of
    {ok, Filenames} ->
      maps:put(TargetVariable,Filenames,Map);
    {error, Reason} ->
      maps:put(TargetVariable,Reason,Map)
  end.
