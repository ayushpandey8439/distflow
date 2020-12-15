-module(runner).

-behaviour(gen_statem).

-export([terminate/3,code_change/4,init/1,callback_mode/0]).
-export([start/0,stop/0,match/3,parse/2,extract/2,map/2]).
name() -> runner_statem.


%% Mandatory callback functions
terminate(_Reason, _State, _Data) ->
    void.
code_change(_Vsn, State, Data, _Extra) ->
    {ok,State,Data}.
init([]) ->
    %% Set the initial state + data.  Data is used only as a counter.
    State = off, Data = 0,
    {ok,State,Data}.
callback_mode() -> state_functions.



start() ->
    gen_statem:start({local,name()}, ?MODULE, [], []).
parse(Target,Input)->
    gen_server:call(Target, {parse,Input}).
extract(Target,ParsedHTML) ->
    gen_server:call(Target,{extract,ParsedHTML}).
match(Target,Regex,Input)->
    gen_server:call(Target, {regex,Regex,Input}).
map(Target,TaskList)->
    io:format("Called map with the task list :: ~p ~n ~n",[TaskList]),
    gen_server:call(Target, {map,TaskList}).
stop() ->
    gen_statem:stop(name()).