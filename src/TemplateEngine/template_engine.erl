%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Feb 2021 17:28
%%%-------------------------------------------------------------------
-module(template_engine).
-author("pandey").
%% API
-export([replace/2]).

replace([Target|Rest],Map) when is_tuple(Target)->
  UpdatedTarget = lists:map(fun(TargetElement)-> replace(TargetElement,Map) end, [Target|Rest]),
  UpdatedTarget;
replace(Target,Map) when is_tuple(Target) ->
  {Key,Value} = Target,
  if Key =/= "target" ->
    UpdatedValue =  replace(Value,Map),
    {Key,UpdatedValue};
    true -> {Key,Value}
  end;
replace(Target,Map)->
  {ok,Tokens,_} = tokens:string(Target),
  {ok,AST} = template:parse(Tokens),
  treewalker(AST,Map).

treewalker({string,Position,VariableName},Map)->
  VariableName;
treewalker({variable,VariableString},Map)->
  VariableName = treewalker(VariableString,Map),
  maps:get(VariableName,Map);
treewalker({concat,Part1,Part2},Map)->
  Left= treewalker(Part1,Map),
  Right = treewalker(Part2,Map),
  string:concat(
    if is_atom(Left)->
      atom_to_list(Left);
      true-> Left end,
    if is_atom(Right) ->
      atom_to_list(Right);
      true -> Right end
  ).