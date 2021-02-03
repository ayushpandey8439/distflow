%%%-------------------------------------------------------------------
%%% @author pandey
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(messageBroker).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,code_change/3]).

-define(SERVER, ?MODULE).

-record(messageBroker_state, {leader}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #messageBroker_state{}}.

handle_call(_Request, _From, State = #messageBroker_state{}) ->
{reply, ok, State}.

handle_cast(_Request, State = #messageBroker_state{}) ->
{noreply, State}.

handle_info(_Info, State = #messageBroker_state{}) ->
{noreply, State}.

terminate(_Reason, messageBroker_state = #messageBroker_state{}) ->
ok.

code_change(_OldVsn, State = #messageBroker_state{}, _Extra) ->
{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
