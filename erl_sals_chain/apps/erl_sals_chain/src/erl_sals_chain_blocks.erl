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

