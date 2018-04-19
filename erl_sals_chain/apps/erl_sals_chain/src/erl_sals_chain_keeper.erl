-module(erl_sals_chain_keeper).

-behavior(gen_server).

% API:
-export([get_index_of_last_block/0, get_hash_of_last_block/0, get_list_of_blocks/0,
         put_new_block/1]).

% gen_server:
-export([init/1, handle_call/3, handle_cast/2, start_link/0]).

get_index_of_last_block() ->
    gen_server:call(erl_sals_chain_keeper, get_index_of_last_block).

get_hash_of_last_block() ->
    gen_server:call(erl_sals_chain_keeper, get_hash_of_last_block).

get_list_of_blocks() ->
    gen_server:call(erl_sals_chain_keeper, get_list_of_blocks).

put_new_block(Block) ->
    gen_server:call(erl_sals_chain_keeper, {put_new_block, Block}).

start_link() ->
    gen_server:start_link({local, erl_sals_chain_keeper}, erl_sals_chain_keeper, ignore_me, []).

init(_Arg) ->
    GenesisBlock = <<"{\"index\":1,\"timestamp\":0,\"proof\":1917336,\"transactions\":[{\"id\":\"b3c973e2-db05-4eb5-9668-3e81c7389a6d\",\"timestamp\":0,\"payload\":\"I am Heribert Innoq\"}],\"previousBlockHash\":\"0\"}">>,
    Blocks = [ GenesisBlock ],
    PreviousHash = erl_sals_hex_utils:hex_digits(crypto:hash(sha256, GenesisBlock)),
    PreviousIndex = 1,
    State = {PreviousHash, PreviousIndex, Blocks},
    {ok, State}.

handle_call(get_index_of_last_block, _From, {PreviousHash, PreviousIndex, Blocks}) ->
    {reply, PreviousIndex, {PreviousHash, PreviousIndex, Blocks}};
handle_call(get_hash_of_last_block, _From, {PreviousHash, PreviousIndex, Blocks}) ->
    {reply, PreviousHash,  {PreviousHash, PreviousIndex, Blocks}};
handle_call(get_list_of_blocks, _From, {PreviousHash, PreviousIndex, Blocks}) ->
    {reply, Blocks, {PreviousHash, PreviousIndex, Blocks}};
handle_call({put_new_block, Block}, _From, {_PreviousHash, PreviousIndex, Blocks}) ->
    {reply, ok, {erl_sals_hex_utils:hex_digits(crypto:hash(sha256, Block)), PreviousIndex + 1, Blocks ++ [Block]}}.

handle_cast(_Request, State) ->
    {stop, nicht_vorgesehen, State}.
