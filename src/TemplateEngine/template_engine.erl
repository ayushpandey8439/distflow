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
  try tokens:string(Target) of
    {error,_,_} ->
      Target;
    {ok,Tokens,_} ->
      tokens:string(Target),
      {ok,AST} = template:parse(Tokens),
      treewalker(AST,Map)
  catch
    Throw -> {throw,caught,Throw}
  end.

treewalker({string,Position,VariableName},Map)->
  VariableName;
treewalker({variable,VariableString},Map)->
  VariableName = treewalker(VariableString,Map),
  maps:get(VariableName,Map);
treewalker({key_lookup,MapName,KeyName},Map)->
  MapMap = treewalker(MapName,Map),
  {_,Value} = lists:keyfind(atom_to_list(treewalker(KeyName,Map)),1,MapMap),
  Value;
treewalker({arraylookup,Array,Index},Map)->
  MapArray = treewalker(Array,Map),
  ArrayIndex = treewalker(Index,Map),
  lists:nth(ArrayIndex,MapArray);
treewalker({concat,Part1,Part2},Map)->
  Left= treewalker(Part1,Map),
  Right = treewalker(Part2,Map),
  string:concat(
    if
      is_atom(Left)->
        atom_to_list(Left);
      is_integer(Left) ->
        integer_to_list(Left);
      is_float(Left) ->
        float_to_list(Left);
      true-> Left end,
    if
      is_atom(Right) ->
        atom_to_list(Right);
      is_integer(Right) ->
        integer_to_list(Right);
      is_float(Right) ->
        float_to_list(Right);
      true -> Right end);
treewalker({digit,Position,Value},Map)->
  Value.