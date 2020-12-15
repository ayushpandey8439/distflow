%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Dec 2020 21:48
%%%-------------------------------------------------------------------
-module(html_parser).
-author("pandey").

%% API
-export([parse/1]).

parse(Input) ->
  mochiweb_html:parse(Input).
