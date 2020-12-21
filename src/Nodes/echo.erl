%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. Dec 2020 05:10
%%%-------------------------------------------------------------------
-module(echo).
-author("pandey").

%% API
-export([echo/1]).

echo(Input)->
  io:format("~p ~n",[Input]),
  Input.
