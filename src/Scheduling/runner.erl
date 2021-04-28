%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Mar 2021 03:18
%%%-------------------------------------------------------------------
-module(runner).
-author("pandey").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).
-export([echo/2,replace/2,fork/2,join/2,flattenStringList/2,listfiles/2,map/2,convertFile/2]).
-export([resetState/1,setScope/3]).
-define(SERVER, ?MODULE).
name() ->runner.
-record(runner_state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%% @doc Spawns the server and registers the local name (unique)
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, name()}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
-spec(init(Args :: term()) ->
  {ok, State :: #runner_state{}} | {ok, State :: #runner_state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  {ok, #runner_state{}}.

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #runner_state{}) ->
  {reply, Reply :: term(), NewState :: #runner_state{}} |
  {reply, Reply :: term(), NewState :: #runner_state{}, timeout() | hibernate} |
  {noreply, NewState :: #runner_state{}} |
  {noreply, NewState :: #runner_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #runner_state{}} |
  {stop, Reason :: term(), NewState :: #runner_state{}}).
handle_call({getJoinLength,JoinKey}, _From, State = #runner_state{}) when is_atom(JoinKey) ->
  JoinKeyString = atom_to_list(JoinKey),
  JoinLength = maps:get(JoinKeyString,State),
  {reply, {ok,JoinLength}, State};
handle_call({getJoinLength,JoinKey}, _From, State = #runner_state{})->
  JoinLength = maps:get(JoinKey,State),
  {reply, {ok,JoinLength}, State};
handle_call(_Request, _From, State = #runner_state{}) ->
  {reply, ok, State}.
%% @private
%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #runner_state{}) ->
  {noreply, NewState :: #runner_state{}} |
  {noreply, NewState :: #runner_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #runner_state{}}).
handle_cast(_Request, State = #runner_state{}) ->
  {noreply, State};
handle_cast({setJoinLength,JoinKey,Length}, State = #runner_state{}) ->
  UpdatedState = maps:put(JoinKey,Length,State),
  {noreply, ok, UpdatedState}.
%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #runner_state{}) ->
  {noreply, NewState :: #runner_state{}} |
  {noreply, NewState :: #runner_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #runner_state{}}).
handle_info(_Info, State = #runner_state{}) ->
  {noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #runner_state{}) -> term()).
terminate(_Reason, _State = #runner_state{}) ->
  ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #runner_state{},
    Extra :: term()) ->
  {ok, NewState :: #runner_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #runner_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================


echo(Target,Task)->
    TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
    gen_server:call(Target, {echo,TemplatedTask}),
    nextTask(TemplatedTask).

listfiles(Target,Task)->
  TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
  gen_server:call(Target, {listfiles,TemplatedTask}),
  nextTask(TemplatedTask).

replace(Target, Task)->
    TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
    gen_server:call(Target, {replace,TemplatedTask}),
    nextTask(TemplatedTask).

map(Target,Task) ->
  TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
  MapList = (element(2,lists:keyfind("list",1,TemplatedTask))),
  MapOperation = (element(2,lists:keyfind("mapOperation",1,TemplatedTask))),
  PutElement = (element(2,lists:keyfind("putElement",1,TemplatedTask))),
  Targets = (element(2,lists:keyfind("targets",1,TemplatedTask))),
  {map, {MapList,MapOperation,PutElement,Targets}}.


fork(Target,Task) ->
    TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
    JoinKey = (element(2,lists:keyfind("joinKey",1,TemplatedTask))),
    ForkTargets = (element(2,lists:keyfind("forkTargets",1,TemplatedTask))),
    gen_server:cast(self(),{setJoinLength,JoinKey,length(ForkTargets)}),
    gen_server:call(Target,{fork,TemplatedTask}),
    {fork, ForkTargets}.

join(Target, Task) ->
    TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
    JoinTarget = (element(2,lists:keyfind("joinTarget",1,TemplatedTask))),
    case gen_server:call(Target,{join,TemplatedTask}) of
      wait ->
        wait;
      join_complete ->
        {goto,(JoinTarget)}
    end.
convertFile(Target,Task)->
  TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
  gen_server:call(Target,{convertFile,TemplatedTask}),
  nextTask(TemplatedTask).


setScope(Target, ScopeVariable, ScopeValue)->
  gen_server:call(Target,{setScope, ScopeVariable,ScopeValue}).



nextTask(TaskTemplate) ->
    case lists:keyfind("goTo",1,TaskTemplate) of
        {Key, Value} -> {goto, Value};
        false -> next_task
    end.

resetState(Target)->
  gen_server:cast(Target,{clearState}).

flattenStringList(Target,Task) ->
  TemplatedTask = gen_server:call(Target,{replaceTemplates,Task}),
  gen_server:call(Target, {flattenStringList,TemplatedTask}),
  nextTask(TemplatedTask).