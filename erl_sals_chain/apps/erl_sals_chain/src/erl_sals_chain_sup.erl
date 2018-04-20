%%%-------------------------------------------------------------------
%% @doc erl_sals_chain top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(erl_sals_chain_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok,
      {{one_for_all, 0, 1},
        [
          #{
            id => erl_sals_chain_keeper,
            start => {erl_sals_chain_keeper, start_link, []}
          },
          #{
            id => erl_sals_chain_uuid,
            start => {erl_sals_chain_uuid, start_link, []}
          },
          #{
              id => erl_sals_chain_transactions_queue,
              start => {erl_sals_chain_transactions_queue, start_link, []}
          },
          #{
              id => erl_sals_chain_nodes_keeper,
              start => {erl_sals_chain_nodes_keeper, start_link, []}
          }
        ]
      }
    }.

%%====================================================================
%% Internal functions
%%====================================================================
