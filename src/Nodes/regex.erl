%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Dec 2020 15:33
%%%-------------------------------------------------------------------
-module(regex).
-author("pandey").

%% API
-export([match/2]).

match(Input,Regex) ->
  {ok,MP} = re:compile(Regex),
  MatchStatus = re:run(Input,MP,[global]),
  case MatchStatus of
    {match,L} -> length(L);
    nomatch -> 0
  end.