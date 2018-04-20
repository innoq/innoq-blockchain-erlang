-module(erl_sals_chain_keeper).

-behavior(gen_server).

-include("erl_sals_records.hrl").

% API:
-export([get_index_of_last_block/0, get_hash_of_last_block/0, get_list_of_blocks/0,
         put_new_block/1, confirmed_transaction/1, find_transaction/1, replace_chain/1]).

% gen_server:
-export([init/1, handle_call/3, handle_cast/2, start_link/0]).

% Pull in record definitions:

get_index_of_last_block() ->
    gen_server:call(erl_sals_chain_keeper, get_index_of_last_block).

get_hash_of_last_block() ->
    gen_server:call(erl_sals_chain_keeper, get_hash_of_last_block).

get_list_of_blocks() ->
    gen_server:call(erl_sals_chain_keeper, get_list_of_blocks).

put_new_block(Block) ->
    gen_server:call(erl_sals_chain_keeper, {put_new_block, Block}).

replace_chain(SortedListOfBlocks) ->
    ok.

confirmed_transaction(TransactionId) ->
    case find_transaction(TransactionId) of
        {not_found} -> false;
        {ok, _} -> true
    end.

% Gives back {ok, Transaction} or {not_found}.
find_transaction(TransactionId) ->
    gen_server:call(erl_sals_chain_keeper, {find_transaction, TransactionId}).

start_link() ->
    gen_server:start_link({local, erl_sals_chain_keeper}, erl_sals_chain_keeper, ignore_me, []).

init(_Arg) ->
    GenesisBlockContent = <<"{\"index\":1,\"timestamp\":0,\"proof\":1917336,\"transactions\":[{\"id\":\"b3c973e2-db05-4eb5-9668-3e81c7389a6d\",\"timestamp\":0,\"payload\":\"I am Heribert Innoq\"}],\"previousBlockHash\":\"0\"}">>,
    GenesisBlockOnlyTransactionId = <<"b3c973e2-db05-4eb5-9668-3e81c7389a6d">>,
    GenesisBlockOnlyTransaction = #transaction{
                                     id = GenesisBlockOnlyTransactionId,
                                     payload = <<"I am Heribert Innoq">>,
                                     timestamp=0},
    GenesisBlock = #block{content=GenesisBlockContent, transactions=[GenesisBlockOnlyTransaction]},
    TransactionId2Transaction = #{GenesisBlockOnlyTransactionId => GenesisBlockOnlyTransaction},
    Blocks = [ GenesisBlock ],
    PreviousHash = erl_sals_hex_utils:hex_digits(crypto:hash(sha256, GenesisBlockContent)),
    PreviousIndex = 1,
    State = {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction},
    {ok, State}.

handle_call(get_index_of_last_block, _From, {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}) ->
    {reply, PreviousIndex, {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}};
handle_call(get_hash_of_last_block, _From, {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}) ->
    {reply, PreviousHash,  {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}};
handle_call(get_list_of_blocks, _From, {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}) ->
    {reply, Blocks, {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}};
handle_call({put_new_block, Block}, _From, {_PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}) ->
    #block{content = Content, transactions = Transactions} = Block,
    {reply, ok, {erl_sals_hex_utils:hex_digits(crypto:hash(sha256, Content)),
                 PreviousIndex + 1,
                 Blocks ++ [Block],
                 add_transactions_to_map(Transactions, TransactionId2Transaction)
                }};
handle_call({find_transaction, TransactionId}, _From, {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}) ->
    Result = 
        case TransactionId2Transaction of 
            #{TransactionId := Transaction} ->
                {found, Transaction};
            _ -> {not_found}
        end,
    {reply, Result, {PreviousHash, PreviousIndex, Blocks, TransactionId2Transaction}}.    

handle_cast(_Request, State) ->
    {stop, nicht_vorgesehen, State}.

add_transactions_to_map([], TransactionId2Transaction) ->
    TransactionId2Transaction;
add_transactions_to_map([Transaction | Rest], TransactionId2Transaction) ->
    #transaction{id = Id, payload = _, timestamp = _} = Transaction,
    add_transactions_to_map(Rest, TransactionId2Transaction#{Id => Transaction}).
    
