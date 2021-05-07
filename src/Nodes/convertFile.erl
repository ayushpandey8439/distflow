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
-export([convertFile/5]).

convertFile(SourceFilePath,SourceFileName,OutputFilePath,OutputFileName,TargetFormat) ->
  io:format("Called convert file ~n~n"),
  OutputFileNameStripped = filename:basename(filename:rootname(OutputFileName)),%% removes everything but the filename from the url.
  SourceFileNameStripped = filename:basename(SourceFileName),
  SourceFilePathFixed = path:fix(SourceFilePath),
  OutputFilePathFixed = path:fix(OutputFilePath),
  {async, Worker} = vice:convert(lists:append([SourceFilePathFixed,SourceFileNameStripped]),
    lists:append([OutputFilePathFixed,OutputFileNameStripped,".",TargetFormat]),[{yes, true}]),
  io:format("Worker Started:: ~p ~n~n",[Worker]).
