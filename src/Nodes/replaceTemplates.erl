%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Feb 2021 17:28
%%%-------------------------------------------------------------------
-module(replaceTemplates).
-author("pandey").

%% API
-export([replace/2]).

replace([Target|Rest],Map) when is_tuple(Target)->
  UpdatedTarget = lists:map(fun(TargetElement)-> replace(TargetElement,Map) end, [Target|Rest]),
  UpdatedTarget;
replace(Target,Map) when is_tuple(Target)->
  {Key,Value} = Target,
  UpdatedValue =  replace(Value,Map),
  {Key,UpdatedValue};
replace("{"++Target,Map)->
  Key= string:slice(Target,0, string:length(Target)-1),
  replaceFromMap(Key,Map);
replace(Target,_)->
  Target.

replaceFromMap("{"++TemplateVariable,Map)->
  Key = string:slice(TemplateVariable,0, string:length(TemplateVariable)-1),
  replaceFromMap(Key,Map)
;
replaceFromMap(TemplateVariable,Map)->
  maps:get(TemplateVariable,Map).