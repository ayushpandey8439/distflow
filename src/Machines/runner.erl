-module(runner).

-behaviour(gen_statem).

-export([terminate/3,code_change/4,init/1,callback_mode/0]).
-export([start/0,stop/0,match/2,parse/2,extract/2,map/2,echo/2]).
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

parse(Target,Task)->
    Value = (element(2,lists:keyfind("value",1,Task))),
    Output = (element(2,lists:keyfind("output",1,Task))),
    gen_server:call(Target, {parse,Value,Output}).

extract(Target,ParsedHTML) ->
    gen_server:call(Target,{extract,ParsedHTML}).
match(Target,{Input,Regex})->
    gen_server:call(Target, {regex,Regex,Input}).
map(Target,TaskList)->
    gen_server:call(Target, {map,TaskList}).
echo(Target,Task)->
    Value = (element(2,lists:keyfind("value",1,Task))),
    Put = (element(2,lists:keyfind("put",1,Task))),
    gen_server:call(Target, {echo,Put,Value}).
stop() ->
    gen_statem:stop(name()).


