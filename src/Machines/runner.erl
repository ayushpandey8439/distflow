%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Feb 2021 20:10
%%%-------------------------------------------------------------------
-module(runner).
-author("pandey").

%% API
-export([echo/2,replace/2]).

echo(Target,Task)->
  TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
  Value = (element(2,lists:keyfind("value",1,TemplatedTask))),
  Put = (element(2,lists:keyfind("put",1,TemplatedTask))),
  gen_server:call(Target, {echo,Put,Value}).

replace(Target, Task)->
  TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
  Value = (element(2,lists:keyfind("value",1,TemplatedTask))),
  Variable = (element(2,lists:keyfind("variable",1,TemplatedTask))),
  gen_server:call(Target, {replace,Variable,Value}).
