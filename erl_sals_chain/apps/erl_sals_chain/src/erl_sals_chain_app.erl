%%%-------------------------------------------------------------------
%% @doc erl_sals_chain public API
%% @end
%%%-------------------------------------------------------------------

-module(erl_sals_chain_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    {ok, Pid} = erl_sals_chain_sup:start_link(),
    Routes = [ {
        '_',
        [
            {"/", erl_sals_chain_root, []},
            {"/blocks", erl_sals_chain_blocks, []},
            {"/mine", erl_sals_chain_mine, []},
            {"/transactions", erl_sals_chain_transactions, []},
            {"/transactions/:id", erl_sals_chain_transactions_find, []},
            {"/nodes/register", erl_sals_chain_nodes_register, []}
        ]
    } ],
    Dispatch = cowboy_router:compile(Routes),

    {ok, _} = cowboy:start_clear(steffen_andreas_simon_leonardo,
                                 [{port, 8888}],
                                 #{env => #{dispatch => Dispatch}}),

    {ok, Pid}.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
