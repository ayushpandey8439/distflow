%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Feb 2021 20:09
%%%-------------------------------------------------------------------
-module(message_broker).
-author("pandey").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(message_broker_state, {clock}).
name() -> message_broker.
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
  {ok, State :: #message_broker_state{}} | {ok, State :: #message_broker_state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  spawn_link(fun find_other_nodes/0),
  Clock = vector_clock:new(),
  {ok, #message_broker_state{clock = Clock}}.

%% @private
%% @doc Handling call messages
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #message_broker_state{}) ->
  {reply, Reply :: term(), NewState :: #message_broker_state{}} |
  {reply, Reply :: term(), NewState :: #message_broker_state{}, timeout() | hibernate} |
  {noreply, NewState :: #message_broker_state{}} |
  {noreply, NewState :: #message_broker_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #message_broker_state{}} |
  {stop, Reason :: term(), NewState :: #message_broker_state{}}).
handle_call({broadcast,Map}, _From, State = #message_broker_state{}) ->
  UpdatedClock = vector_clock:increment(State#message_broker_state.clock),
  gen_server:multi_call(nodes(),message_broker,{update_map,Map,UpdatedClock}),
  {reply, ok, State#message_broker_state{clock = UpdatedClock}};

handle_call({update_map,Map,Clock}, _From, State = #message_broker_state{}) ->
  UpdatedClock = vector_clock:increment(State#message_broker_state.clock),
  MergedClock = vector_clock:merge(UpdatedClock,Clock),
  gen_server:call({controller,node()},{update_map,Map}),
  {reply, ok, State#message_broker_state{clock = MergedClock}};

handle_call(_Request, _From, State = #message_broker_state{}) ->
  {reply, ok, State}.

%% @private
%% @doc Handling cast messages
-spec(handle_cast(Request :: term(), State :: #message_broker_state{}) ->
  {noreply, NewState :: #message_broker_state{}} |
  {noreply, NewState :: #message_broker_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #message_broker_state{}}).
handle_cast(_Request, State = #message_broker_state{}) ->
  {noreply, State}.

%% @private
%% @doc Handling all non call/cast messages
-spec(handle_info(Info :: timeout() | term(), State :: #message_broker_state{}) ->
  {noreply, NewState :: #message_broker_state{}} |
  {noreply, NewState :: #message_broker_state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #message_broker_state{}}).
handle_info(_Info, State = #message_broker_state{}) ->
  {noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #message_broker_state{}) -> term()).
terminate(_Reason, _State = #message_broker_state{}) ->
  ok.

%% @private
%% @doc Convert process state when code is changed
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #message_broker_state{},
    Extra :: term()) ->
  {ok, NewState :: #message_broker_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State = #message_broker_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================


find_other_nodes() ->
  Nodes = os_or_app_env(),
  logger:notice("Connecting ~p to other nodes: ~p", [node(), Nodes]),
  try_connect(Nodes, 500).



os_or_app_env() ->
  Nodes = string:tokens(os:getenv("RUNNER_NODES", ""), ","),
  case Nodes of
    "" ->
      Nodes2 = application:get_env(distFlow, runner_nodes, []);
    _ ->
      Nodes2 = [list_to_atom(N) || N <- Nodes]
  end,
  Nodes2.

try_connect(Nodes, T) ->
  {Ping, Pong} = lists:partition(fun (N) ->
    pong == net_adm:ping(N)
                                 end,
    Nodes),
  [logger:notice("Connected to node ~p", [N]) || N <- Ping],
  case T > 1000 of
    true ->
      [logger:notice("Failed to connect ~p to node ~p", [node(), N]) || N <- Pong];
    _ ->
      ok
  end,
  case Pong of
    [] ->
      logger:notice("Connected to all nodes");
    _ ->
      timer:sleep(T),
      try_connect(Pong, 2 * T)
  end.
