%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(controller).

-behaviour(gen_server).
-include_lib("kernel/include/logger.hrl").

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(controller_state, {flow_map}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================
name() -> controller.

start_link() ->
  gen_server:start_link({local, name()}, ?MODULE, [], []).

init([]) ->
  Flow_map = maps:new(),
  {ok, #controller_state{flow_map = Flow_map}}.

handle_call({regex,Expression,Target}, _From, State = #controller_state{}) ->
  MatchCount = regex:match(Target, Expression),
  {reply, {ok,MatchCount}, State};

handle_call({parse,"@"++Value,Output}, _From, State = #controller_state{}) ->
  case maps:is_key(Value,State#controller_state.flow_map) of
    false ->
      io:format("Key does not exist in the map"),
      {reply, ok, State};
    true ->
      Input = maps:get(Value,State#controller_state.flow_map),
      ParsedHtml = html_parser:parse(Input),
      {reply, ok, State#controller_state{flow_map = maps:put(Output,ParsedHtml,State#controller_state
      .flow_map)}}
  end;


handle_call({parse,Value,Output}, _From, State = #controller_state{}) ->
  ParsedHtml = html_parser:parse(Value),
  {reply, ok, State#controller_state{flow_map = maps:put(Output,ParsedHtml,State#controller_state
  .flow_map)}};

handle_call({extract,Input}, _From, State = #controller_state{}) ->
  Reply = extract:extract(Input,""),
  {reply, Reply, State};

handle_call({map,TaskList}, _From, State = #controller_state{}) ->
  Reply = map:map(TaskList),
  {reply, Reply, State};

handle_call({echo,Put,Value}, _From, State = #controller_state{}) ->
  UpdatedMap = echo:echo(Put,Value,State#controller_state.flow_map),
  %%lists:foreach(fun(Node)-> gen_server:cast({controller,Node}, {update_map,UpdatedMap}) end,
  %% nodes ()),
  {reply, ok, State#controller_state{flow_map = UpdatedMap}};

handle_call(_Request, _From, State = #controller_state{}) ->
  {reply, ok, State}.

handle_cast({update_map,Map}, State = #controller_state{}) ->
  io:format("Map update"),
  {noreply, State#controller_state{flow_map = Map}};

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
