%%%-------------------------------------------------------------------
%% @doc distFlow top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(distFlow_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 0,
                 period => 1},
  NodeController = #{
    id => node_controller,
    start => {controller, start_link,[]},
    restart => permanent,
    shutdown => 5000,
    type => worker,
    modules => [controller]
  },
  MessageBroker = #{
    id => message_broker,
    start => {message_broker, start_link,[]},
    restart => permanent,
    shutdown => 5000,
    type => worker,
    modules => [message_broker]
  },
  Router = #{
    id => router,
    start => {router, start_link,[]},
    restart => permanent,
    shutdown => 5000,
    type => worker,
    modules => [router]
  },
    ChildSpecs = [NodeController,MessageBroker,Router],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
