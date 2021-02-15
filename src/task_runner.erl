%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Dec 2020 22:43
%%%-------------------------------------------------------------------
-module(task_runner).
-author("pandey").

%% API
-export([runtask/1]).

runtask(Path) ->
  application:start(yamerl),
  Spec = yamerl_constr:file(Path),
  UnnestedSpec = lists:nth(1,Spec),
  logger:warning("Starting execution of ~p",[element(2,lists:keyfind("name",1,UnnestedSpec))]),
  execute(element(2,lists:keyfind("graphs",1,UnnestedSpec)))
.
  %% task_runner:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/testgraph.yaml").


execute(Spec)->
  lists:map(fun(Document)-> executeMapping(Document) end,Spec)
.

executeMapping({_,Mapping})->
  lists:map(fun(Task)-> executeTask(Task) end, Mapping).

executeTask(Task)->
  Target = list_to_atom(element(2,lists:keyfind("target",1,Task))),
  TaskName = list_to_atom(string:lowercase(element(2,lists:keyfind("type",1,Task)))),
  apply(runner,TaskName,[{controller,Target},Task]).


