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
  FixedPath = path:fix(Path),
  case file:list_dir(Path) of
    {ok, Filenames} ->
      UpdatedFileNames = lists:map(fun(FileName) -> lists:append([FixedPath,FileName]) end,Filenames),
      maps:put(TargetVariable,UpdatedFileNames,Map);
    {error, Reason} ->
      maps:put(TargetVariable,Reason,Map)
  end.