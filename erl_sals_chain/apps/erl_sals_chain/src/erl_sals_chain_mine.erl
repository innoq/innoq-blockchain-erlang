-module(erl_sals_chain_mine).

-export([init/2, info/3]).
-include("erl_sals_records.hrl").

init(Req, _Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Timestamp = os:system_time(millisecond),
    TimestampInSeconds = os:system_time(second),
    Index = erl_sals_chain_keeper:get_index_of_last_block() + 1,
    PreviousBlockHash = erl_sals_chain_keeper:get_hash_of_last_block(),
    Transactions = erl_sals_chain_transactions_queue:pop_five_transactions(),
    TransactionsJson = jiffy:encode([Transactions]),
    {Proof, NextBlockContent} = erl_sals_worker:mine(Index,
        TimestampInSeconds,
        TransactionsJson,
        PreviousBlockHash),
    TimestampAfter = os:system_time(millisecond),
    Duration = (TimestampAfter - Timestamp) / 1000,
    HashingPower = Proof / Duration,
    erl_sals_chain_keeper:put_new_block(#block{content = NextBlockContent, transactions = []}),
    Json = [
        <<"{\"message\":\"Mined a new block in ">>,
        list_to_binary(float_to_list(Duration, [{decimals, 3}, compact])),
        <<"s. Hashing power: ">>,
        list_to_binary(float_to_list(HashingPower, [{decimals, 3}, compact])),
        <<"x hashes/s\",\"block\":">>,
        NextBlockContent,
        <<"}">>
    ],
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        Json,
        Req),
    {shutdown, Req2, State}.


