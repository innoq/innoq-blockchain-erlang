-module(erl_sals_chain_nodes_keeper).

-behavior(gen_server).

% API:
-export([get_nodes/0,
    put_new_node/1]).

% -include("erl_sals_records.hrl").

% gen_server:
-export([init/1, handle_call/3, handle_cast/2, start_link/0]).

get_nodes() ->
    gen_server:call(erl_sals_chain_nodes_keeper, get_nodes).

put_new_node(Node) ->
    gen_server:call(erl_sals_chain_nodes_keeper, {put_new_node, Node}).

start_link() ->
    gen_server:start_link({local, erl_sals_chain_nodes_keeper},
        erl_sals_chain_nodes_keeper,
        ignore_me,
        []).

init(_Arg) ->
    State = [],
    {ok, State}.

handle_call(get_nodes, _From, State) ->
    {reply, State, State};

handle_call({put_new_node, Node}, _From, State) ->
    {reply, ok, [Node | State]}.

handle_cast(_Request, State) ->
    {stop, nicht_vorgesehen, State}.