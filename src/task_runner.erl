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
  SpecList = element(2,lists:keyfind("graphs",1,UnnestedSpec)),
  {TaskNameList, TaskList} = lists:unzip(SpecList),
  StartSpecName = getStartSpec(UnnestedSpec),
  StartIndex = getIndex(StartSpecName,TaskNameList,1),
  execute(StartIndex,TaskNameList,TaskList).

  %% task_runner:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/testgraph.yaml").
  %% task_runner:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/testgraph3.yaml").
  %% task_runner:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/fork.yaml").


execute(Index,SpecNameList,SpecList) when length(SpecList) >= Index->
  Spec = lists:nth(Index,SpecList),
  %% Find the Start Mapping and execute it.
  case executeMapping(1,Spec) of
    {fork,TargetList} ->
      lists:foreach(fun(TargetTask) -> executeForkTarget(TargetTask,SpecNameList,SpecList)end ,TargetList);
    {goto,SpecName} ->
      NextSpecIndex = getIndex(SpecName, SpecNameList,1 ),
      execute(NextSpecIndex,SpecNameList,SpecList);
    {next_mapping} ->
      execute(Index+1,SpecNameList,SpecList)
  end;
execute(Index,SpecNameList,SpecList) when length(SpecList) < Index ->
  {next_graph}.

executeMapping(Index, Mapping) when length(Mapping) >= Index->
  executeTask(lists:nth(Index,Mapping)),
  case getNextTask(lists:nth(Index,Mapping)) of
    {goto, NextTask} ->
      {goto,NextTask};
    {fork, NextTask} ->
      {fork,NextTask};
    next_task ->
      executeMapping(Index+1,Mapping)
    end;
executeMapping(Index, Mapping) when length(Mapping) < Index->
  {next_mapping}.


executeTask(Task)->
  Target = list_to_atom(element(2,lists:keyfind("target",1,Task))),
  TaskName = list_to_atom(string:lowercase(element(2,lists:keyfind("type",1,Task)))),
  apply(runner,TaskName,[{controller,Target},Task]).


getStartSpec(Spec)->
  case lists:keyfind("start",1,Spec) of
    {Key, Value} ->
      Value;
    true -> "start"
  end.

getNextTask(Task)->
  case lists:keyfind("goTo",1,Task) of
    {Key, Value} ->
      {goto,Value};
    false ->
      case lists:keyfind("forkTargets",1,Task) of
        {Key, Targets} ->
          {fork,Targets};
        false ->
          next_task
      end
  end.

getIndex(Name, [Head|RestList],Index) when Head == Name->
  Index;
getIndex(Name, [Head|RestList],Index) when Head =/= Name ->
  getIndex(Name, RestList,Index+1);
getIndex(Name, [],Index = 1)->
  -1.


executeForkTarget(TargetTask,SpecNameList,SpecList)->
TaskIndex = getIndex(TargetTask, SpecNameList,1),
execute(TaskIndex,SpecNameList,SpecList).