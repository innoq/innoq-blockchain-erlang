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
            {"/mine", erl_sals_chain_mine, []}
        ]
    } ],
    Dispatch = cowboy_router:compile(Routes),

    NumAcceptors = 10,
    TransOpts = [ {ip, {0,0,0,0}}, {port, 2938} ],
    ProtoOpts = [{env, [{dispatch, Dispatch}]}],

    {ok, _} = cowboy:start_http(chicken_poo_poo,
        NumAcceptors, TransOpts, ProtoOpts),

    {ok, Pid}.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
