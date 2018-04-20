-module(erl_sals_chain_mine).

-export([init/2, info/3]).

init(Req, _Opts) ->
  self() ! handle_request,
  {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
  Timestamp = os:system_time(millisecond),
  Index = erl_sals_chain_keeper:get_index_of_last_block() + 1,
  PreviousBlockHash = erl_sals_chain_keeper:get_hash_of_last_block(),
  {Proof, NextBlock} = erl_sals_worker:mine(Index, Timestamp, "[]", PreviousBlockHash),
  TimestampAfter = os:system_time(millisecond),
  Duration = (TimestampAfter - Timestamp) / 1000,
  HashingPower = Proof / Duration,
  erl_sals_chain_keeper:put_new_block(NextBlock),
  Json = [
    <<"{\"message\":\"Mined a new block in ">>,
    list_to_binary(float_to_list(Duration,[{decimals,3},compact])),
    <<"s. Hashing power: ">>,
    list_to_binary(float_to_list(HashingPower,[{decimals,3},compact])),
    <<"x hashes/s\",\"block\":">>,
    NextBlock,
    <<"}">>
  ],
  Req2 = cowboy_req:reply(200,
    [{<<"content-type">>, <<"application/json">>}],
    Json,
    Req),
  {shutdown, Req2, State}.

