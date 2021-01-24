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

runtask(Path) ->
  Spec = parser:read(Path),
  execute(Spec).
  %% sampleRun:runtask("/Users/pandey/Desktop/Notes/thesis/flow/specGraphs/testgraph.yaml").


  %%Input= "<html> <head>  <title>This is a title</title> </head> <body> This is the body </body> </html>",
  %%Target = {controller,'runner2@127.0.0.1'},
  %%Regex = "This",
  %%Parsed = apply(runner,"parse",[Target,Input]),
  %%Text = runner:extract(Target,Parsed),
  %%MatchCount = runner:match(Target,Regex,Text).


execute(Spec)->
  lists:map(fun(Document)-> executeMappings(Document) end, Spec).

executeMappings(Mappings)->
  lists:map(fun(Mapping)-> executeTasks(Mapping) end, Mappings).

executeTasks(Task)->
  Target = list_to_atom(element(2,lists:keyfind("target",1,Task))),
  TaskName = list_to_atom(string:lowercase(element(2,lists:keyfind("task",1,Task)))),
  apply(runner,TaskName,[{controller,Target},Task]).


  %%if TaskName == match ->
  %%  Regex = element(2,lists:keyfind("regex",1,Task)),
   %% Input = (element(2,lists:keyfind("input",1,Task))),
   %% if Input == "$" ->
    %%  Output = apply(runner,TaskName,[{controller,Target},{ReceivedInput,Regex}]);
     %% true ->
      %%  Output = apply(runner,TaskName,[{controller,Target},{Input,Regex}])
    %%end;
  %%true ->
  %%  Input = (element(2,lists:keyfind("input",1,Task))),
  %%  if Input == "$" ->
  %%    Output = apply(runner,TaskName,[{controller,Target},ReceivedInput]);
  %%    true ->
  %%      Output = apply(runner,TaskName,[{controller,Target},Input])
  %%  end
  %%end.


