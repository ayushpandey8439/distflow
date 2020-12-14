%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Dec 2020 21:06
%%%-------------------------------------------------------------------
-module(extract).
-author("pandey").

%% API
-export([extract/2]).

extract({_,[],Children},Text)->
  lists:foldl(fun(Child,Text) -> extract(Child,Text) end,Text, Children);
extract(Child,Text)->

  string:concat(string:concat(Text," ; "),erlang:binary_to_list(Child)).

