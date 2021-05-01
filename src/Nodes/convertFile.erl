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
-export([convertFile/3]).

convertFile(SourceFile,OutputFile,TargetFormat) ->
  OutputFileName = filename:rootname(OutputFile),
  {async, Worker} = vice:convert(SourceFile,lists:append([OutputFileName,".",TargetFormat]),[{yes, true}]),
  io:format("Worker Started:: ~p ~n~n",[Worker]).
