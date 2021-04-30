%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Dec 2020 22:43
%%%-------------------------------------------------------------------
-module(scheduler).
-author("pandey").

%% API
-export([runtask/1]).
-record(run_target, {target = node()}).

runtask(Path) ->
  application:start(yamerl),
  Spec = yamerl_constr:file(Path),
  UnnestedSpec = lists:nth(1,Spec),
  logger:warning("Starting execution of ~p",[element(2,lists:keyfind("name",1,UnnestedSpec))]),
  SpecList = element(2,lists:keyfind("labels",1,UnnestedSpec)),
  {TaskNameList, TaskList} = lists:unzip(SpecList),
  StartSpecName = getStartSpec(UnnestedSpec),
  StartIndex = getIndex(StartSpecName,TaskNameList,1),
  TargetRecord = #run_target{},
  execute(StartIndex,TaskNameList,TaskList,TargetRecord),
  resetState().

  %% scheduler:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/testgraph.yaml").
  %% scheduler:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/testgraph1.yaml").
  %% scheduler:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/fork.yaml").
  %% scheduler:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/listfiles.yaml").
  %% scheduler:runtask("/Users/pandey/Desktop/Notes/thesis/distFlow/specGraphs/listfileshttp.yaml").


execute(Index,SpecNameList,SpecList,TargetRecord) when length(SpecList) >= Index->
  Spec = lists:nth(Index,SpecList),
  %% Find the Start Mapping and execute it.
  case executeMapping(1,Spec,TargetRecord) of
    {fork,TargetList} ->
      lists:foreach(fun(TargetTask) -> executeForkTarget(TargetTask,SpecNameList,SpecList,TargetRecord)end ,TargetList);
    {map, {MapList,MapOperation,PutElement,Targets}} ->
      lists:foldl(fun(ScopeValue,Index) ->
        ExecutionTarget = list_to_atom(lists:nth((Index rem length(Targets))+1,Targets)),
        executeMapOperation(ExecutionTarget,ScopeValue,MapOperation,PutElement,SpecNameList,SpecList,TargetRecord),
        Index+1 end,
        0,MapList);
    {goto,SpecName} ->
      NextSpecIndex = getIndex(SpecName, SpecNameList,1 ),
      execute(NextSpecIndex,SpecNameList,SpecList,TargetRecord);
    {next_mapping} ->
      execute(Index+1,SpecNameList,SpecList,TargetRecord);
    wait ->
      wait
  end;
execute(Index,_SpecNameList,SpecList,_TargetRecord) when length(SpecList) < Index ->
  {next_graph}.

executeMapping(Index, Mapping,TargetRecord) when length(Mapping) >= Index->
  case executeTask(lists:nth(Index,Mapping),TargetRecord) of
    {goto, NextTask} ->
      {goto,NextTask};
    {fork, ForkTargets} ->
      {fork,ForkTargets};
    {map, MapList} ->
      {map, MapList};
    next_task ->
      executeMapping(Index+1,Mapping,TargetRecord);
    wait ->
      wait
    end;
executeMapping(Index, Mapping,_TargetRecord) when length(Mapping) < Index->
  {next_mapping}.

executeTask(Task,TargetRecord)->
  Target = case lists:keyfind("target",1,Task) of
              false -> TargetRecord#run_target.target;
              Tuple -> list_to_atom(element(2,Tuple))
            end,
  TaskName = list_to_atom(element(2,lists:keyfind("type",1,Task))),
  apply(router,TaskName,[{controller,Target},Task]).


getStartSpec(Spec)->
  case lists:keyfind("start",1,Spec) of
    {_Key, Value} ->
      Value;
    true -> "start"
  end.

getIndex(Name, [Head|_RestList],Index) when Head == Name->
  Index;
getIndex(Name, [Head|RestList],Index) when Head =/= Name ->
  getIndex(Name, RestList,Index+1);
getIndex(_Name, [],_Index = 1)->
  -1.


executeForkTarget(TargetTask,SpecNameList,SpecList,TargetRecord)->
  TaskIndex = getIndex(TargetTask, SpecNameList,1),
  execute(TaskIndex,SpecNameList,SpecList,TargetRecord).

executeMapOperation(ExecutionTarget,PutValue,MapOperation,PutElement,SpecNameList,SpecList,TargetRecord)->
  TaskIndex = getIndex(MapOperation, SpecNameList,1),
  UpdatedTargetRecord = TargetRecord#run_target{target = ExecutionTarget},
  apply(router,setScope,[{controller,ExecutionTarget},PutElement,PutValue]),
  execute(TaskIndex,SpecNameList,SpecList,UpdatedTargetRecord).


resetState()->
  apply(router,resetState,[controller]).