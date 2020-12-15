%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(controller).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(controller_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================
name() -> controller.

start_link() ->
  gen_server:start_link({local, name()}, ?MODULE, [], []).

init([]) ->
  {ok, #controller_state{}}.

handle_call({regex,Expression,Target}, _From, State = #controller_state{}) ->
  MatchCount = regex:match(Target, Expression),
  {reply, {ok,MatchCount}, State};

handle_call({parse,Input}, _From, State = #controller_state{}) ->
  io:format("Received a call to parse"),
  Reply = html_parser:parse(Input),
  {reply, Reply, State};

handle_call({extract,Input}, _From, State = #controller_state{}) ->
  Reply = extract:extract(Input,Text=""),
  {reply, Reply, State};

handle_call({map,TaskList}, _From, State = #controller_state{}) ->
  io:format("Received a call to map"),
  Reply = map:map(TaskList),
  {reply, Reply, State};

handle_call(_Request, _From, State = #controller_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #controller_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #controller_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #controller_state{}) ->
  ok.

code_change(_OldVsn, State = #controller_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
