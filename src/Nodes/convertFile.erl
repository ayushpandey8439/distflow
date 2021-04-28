%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Apr 2021 20:44
%%%-------------------------------------------------------------------
-module(convertFile).
-author("pandey").

%% API
-export([convertFile/4]).

convertFile(SourceFile,OutputFile,TargetFormat,Map) ->
  OutputFileName = filename:rootname(OutputFile),
  {async, Worker} = vice:convert(SourceFile,lists:append([OutputFileName,".",TargetFormat])),
  io:format("Worker Started:: ~p ~n~n",[Worker]),
  Map.
