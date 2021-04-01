%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Feb 2021 20:09
%%%-------------------------------------------------------------------
-module(controller).
-author("pandey").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).
-export([getFlowMap/0]).

-define(SERVER, ?MODULE).

-record(controller_state, {flow_map,clock}).
name() -> controller.
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
  {ok, State :: #controller_state{}} | {ok, State :: #controller_state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  Clock = vector_clock:new(),
  Flow_map = maps:new(),
  {ok, #controller_state{clock = Clock, flow_map = Flow_map}}.

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #controller_state{}) ->
  {reply, Reply :: term(), NewState :: #controller_state{}} |
  {reply, Reply :: term(), NewState :: #controller_state{}, timeout() | hibernate} |
  {noreply, NewState :: #controller_state{}} |
  {noreply, NewState :: #controller_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #controller_state{}} |
  {stop, Reason :: term(), NewState :: #controller_state{}}).
handle_call({echo,Put,Value}, _From, State = #controller_state{}) ->
  UpdatedClock = vector_clock:increment(node(),State#controller_state.clock),
  UpdatedMap = echo:echo(Put,Value,State#controller_state.flow_map),
  gen_server:call({message_broker,node()},{broadcast,UpdatedMap,UpdatedClock}),
  {reply, ok, State#controller_state{flow_map = UpdatedMap,clock = UpdatedClock}};

handle_call({replaceTemplates,Task}, _From, State = #controller_state{}) ->
  TemplatedTask = template_engine:replace(Task,State#controller_state.flow_map),
  {reply, TemplatedTask, State};

handle_call({update_map,Map,Clock}, _From, State = #controller_state{}) ->
  {reply, Map, State#controller_state{flow_map = Map}};

handle_call({replace,Variable, Value},_From,  State = #controller_state{}) ->
  UpdatedClock = vector_clock:increment(node(),State#controller_state.clock),
  UpdatedMap = replace:replace(Variable, Value, State#controller_state.flow_map),
  gen_server:call({message_broker,node()},{broadcast,UpdatedMap,UpdatedClock}),
  {reply, ok, State#controller_state{flow_map = UpdatedMap}};

handle_call({fork,JoinKey,ForkTargets},_From,  State = #controller_state{}) ->
  UpdatedClock = vector_clock:increment(node(),State#controller_state.clock),
  UpdatedMap = maps:put(JoinKey,#{length => length(ForkTargets)},State#controller_state.flow_map),
  gen_server:call({message_broker,node()},{broadcast,UpdatedMap,UpdatedClock}),
  {reply, ok, State#controller_state{flow_map = UpdatedMap}};

handle_call({join,JoinKey,Keys},_From,  State = #controller_state{}) ->
  UpdatedClock = vector_clock:increment(node(),State#controller_state.clock),
  UpdatedMap = putKeyInJoinList(Keys,State#controller_state.flow_map),
  gen_server:call({message_broker,node()},{broadcast,UpdatedMap,UpdatedClock}),
  JoinStatus = checkJoinComplete(JoinKey,Keys,UpdatedMap),
  {reply,JoinStatus,State#controller_state{flow_map = UpdatedMap}};


handle_call(getMap,_From,  State = #controller_state{}) ->
  {reply, {ok,State#controller_state.flow_map} , State};
handle_call(_Request, _From, State = #controller_state{}) ->
  {reply, ok, State}.

%% @private
%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #controller_state{}) ->
  {noreply, NewState :: #controller_state{}} |
  {noreply, NewState :: #controller_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #controller_state{}}).
handle_cast({clearState}, State = #controller_state{}) ->
  Clock = vector_clock:new(),
  Flow_map = maps:new(),
  gen_server:call({message_broker,node()},{broadcast,Flow_map,Clock}),
  {noreply, State#controller_state{clock = Clock, flow_map = Flow_map}}.

%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #controller_state{}) ->
  {noreply, NewState :: #controller_state{}} |
  {noreply, NewState :: #controller_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #controller_state{}}).
handle_info(_Info, State = #controller_state{}) ->
  {noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #controller_state{}) -> term()).
terminate(_Reason, _State = #controller_state{}) ->
  ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #controller_state{},
    Extra :: term()) ->
  {ok, NewState :: #controller_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #controller_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

getFlowMap()->
  gen_server:call({controller,node()},getMap).

putKeyInJoinList([KeyList],FlowMap) ->
  SourceKey = (element(1,KeyList)),
  TargetList = element(2,KeyList),
  SourceValue = maps:get(SourceKey,FlowMap),
  InitialJoinList = maps:get(TargetList,FlowMap,[]),
  NewJoinList = lists:append(InitialJoinList,[SourceValue]),
  UpdatedMap = maps:put(TargetList,NewJoinList,FlowMap),
  UpdatedMap.

checkJoinComplete(JoinMap,[KeyList],FlowMap)->
  TargetList = element(2,KeyList),
  TargetLength = maps:get('length',JoinMap),
  CurrentLength = length(maps:get(TargetList,FlowMap,[])),
  if
  TargetLength > CurrentLength ->
    wait;
  true ->
    join_complete
  end.