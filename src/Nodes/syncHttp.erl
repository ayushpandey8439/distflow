%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Apr 2021 21:14
%%%-------------------------------------------------------------------
-module(syncHttp).
-author("pandey").

%% API
-export([get/4]).


get(Url,ContentType, OutputPath,Map) ->
  case httpc:request(get,{Url,[]},[],[]) of
    {ok, {{Version, 200, ReasonPhrase}, Headers, Body}} ->
      case lists:keyfind("content-type",1,Headers) of
        {_,ContentType} ->
          file:write_file(lists:append(path:fix(OutputPath),filename:basename(Url)),Body),
          maps:put(Url,Body,Map);
        {_,ReceivedContentType} -> io:format("Request successful but content type did not match. ~n Expected: ~p ~n Received: ~p",[ContentType,ReceivedContentType]),
          Map
      end;
    _ -> io:format("Could not get ~p",[Url]),
      Map
  end.
