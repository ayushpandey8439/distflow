%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Dec 2020 22:43
%%%-------------------------------------------------------------------
-module(sampleRun).
-author("pandey").

%% API
-export([runtask/1]).

runtask(Input) ->
  Target = {controller,'node2@127.0.0.1'},
  Regex = "This",
  Parsed = runner:parse(Target,Input),
  Text = runner:extract(Target,Parsed),
  MatchCount = runner:match(Target,Regex,Text).
