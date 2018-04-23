-module(erl_sals_chain_keeper).

-behavior(gen_server).

-include("erl_sals_records.hrl").

% API:
-export([get_index_of_last_block/0, get_hash_of_last_block/0, get_list_of_blocks/0,
         put_new_block/1, confirmed_transaction/1, find_transaction/1,
         replace_chain/1, replace_chain_from_JSON/1]).

% gen_server:
-export([init/1, handle_call/3, handle_cast/2, start_link/0]).

% Pull in record definitions:

get_index_of_last_block() ->
    gen_server:call(erl_sals_chain_keeper, get_index_of_last_block).

get_hash_of_last_block() ->
    gen_server:call(erl_sals_chain_keeper, get_hash_of_last_block).

get_list_of_blocks() ->
    gen_server:call(erl_sals_chain_keeper, get_list_of_blocks).

% returns ok or {invalid, Reason}, where "Reason" is an IOlist.
put_new_block(Block) ->
    gen_server:call(erl_sals_chain_keeper, {put_new_block, Block}).

% returns ok or {invalid, Reason}, where "Reason" is an IOlist.
replace_chain(_SortedListOfBlocks) ->
    {invalid, <<"Not yet implemented">>}.

% returns ok or {invalid, Reason}, where "Reason" is an IOlist.
replace_chain_from_JSON(_JsonIoList) ->
    {invalid, <<"Not yet implemented">>}.

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
    Checks = [
              fun() -> 
                      if 
                          is_list(Transactions) -> ok;
                          true -> {invalid, <<"Internal error: Transactions isn't a list.">>}
                      end
              end,
              fun() ->
                      TransactionJson = jiffy:encode(Block#block.transactions),
                      if
                          Block#block.content 
                          end
              end
             ],
    {reply, ok, {erl_sals_hex_utils:hex_digits(crypto:hash(sha256, Block#block.content)),
                 PreviousIndex + 1,
                 Blocks ++ [Block],
                 add_transactions_to_map(Block#block.transactions, TransactionId2Transaction)
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
    Id = Transaction#transaction.id,
    CleanId =
        if
            is_binary(Id) -> Id;
            true -> erlang:error(<<"Transaction id isn't binary">>)
        end,
    add_transactions_to_map(Rest, TransactionId2Transaction#{CleanId => Transaction}).

