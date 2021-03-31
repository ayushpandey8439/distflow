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
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
  NodeController = #{
    id => node_controller,
    start => {controller, start_link,[]},
    restart => permanent,
    shutdown => 5000,
    type => supervisor,
    modules => [controller]
  },
  MessageBroker = #{
    id => message_broker,
    start => {message_broker, start_link,[]},
    restart => permanent,
    shutdown => 5000,
    type => supervisor,
    modules => [message_broker]
  },
  Runner = #{
    id => runner,
    start => {runner, start_link,[]},
    restart => permanent,
    shutdown => 5000,
    type => supervisor,
    modules => [runner]
  },
    ChildSpecs = [NodeController,MessageBroker,Runner],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
