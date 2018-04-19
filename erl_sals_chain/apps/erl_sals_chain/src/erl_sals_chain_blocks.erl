-module(erl_sals_chain_blocks).

-export([init/2, info/3]).

init(Req, Opts) ->
  self() ! handle_request,
  {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
  GenesisBlock = {[{index, 1},
                   {timestamp, 0},
                   {proof, 1917336},
                   {transactions, [
                     {[{id, <<"b3c973e2-db05-4eb5-9668-3e81c7389a6d">>}]},
                     {[{timestamp, 0}]},
                     {[{payload, <<"I am Heribert Innoq">>}]}
                   ]},
                   {previousBlockHash, 0}
  ]},
  Doc = {[{blocks,[GenesisBlock]}, {blockHeight,1}]},
  Json = jiffy:encode(Doc),
  Req2 = cowboy_req:reply(200,
    [{<<"content-type">>, <<"application/json">>}],
    Json,
    Req),
  {shutdown, Req2, State}.

candidate_block(PreviousBlock) ->
  {[{index, get_index_from_block(PreviousBlock) + 1},
    {timestamp, os:system_time()},
    {proof, 0},
    {transactions, []},
    {previousBlockHash, hash(PreviousBlock)}]}.

next_proof({[
  {index, Index},
  {timestamp, Timestamp},
  {proof, Proof},
  {transactions, Transactions},
  {previousBlockHash, PreviousBlockHash}
    ]}) ->
  {[
    {index, Index},
    {timestamp, Timestamp},
    {proof, Proof + 1},
    {transactions, Transactions},
    {previousBlockHash, PreviousBlockHash}
  ]}.

get_index_from_block({[{index, Index} | _]}) -> Index.

hash(Block) -> <<"asdf">>. % crypto:hash(sha256,jiffy.encode(Block)).
