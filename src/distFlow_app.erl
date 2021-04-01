%%%-------------------------------------------------------------------
%% @doc distFlow public API
%% @end
%%%-------------------------------------------------------------------

-module(distFlow_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    logger:notice("Starting distFlow Application"),
    change_cookie(),
    logger:notice("Starting distFlow"),
    distFlow_sup:start_link().

change_cookie() ->
    case os:getenv("ERLANG_COOKIE") of
        false ->
            ok;
        Cookie ->
            try
                erlang:set_cookie(node(), list_to_atom(Cookie))
            catch
                E:Err ->
                    logger:error("Could not set erlang cookie: ~p:~p", [E, Err])
            end
    end.

stop(_State) ->
    ok.

%% internal functions