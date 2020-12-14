%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Nov 2020 18:42
%%%-------------------------------------------------------------------
-module(parser).
-author("pandey").

%% API
-export([read/0]).

read()->
  yamerl_constr:file("testgraph.yaml",[{detailed_constr, true}]).
