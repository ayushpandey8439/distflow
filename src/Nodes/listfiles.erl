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

listfiles(Path,TargetVariable,Map)->
  FixedPath = case pathEnder(Path) of
                47 -> Path;
                _Else ->
                  lists:append([Path,"/"])
              end,

  case file:list_dir(Path) of
    {ok, Filenames} ->
      UpdatedFileNames = lists:map(fun(FileName) -> lists:append([FixedPath,FileName]) end,Filenames),
      maps:put(TargetVariable,UpdatedFileNames,Map);
    {error, Reason} ->
      maps:put(TargetVariable,Reason,Map)
  end.

pathEnder(Path) ->
  lists:last(Path).