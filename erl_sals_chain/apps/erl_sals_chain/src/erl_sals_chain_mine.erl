-module(erl_sals_chain_mine).

-export([init/2, info/3]).

init(Req, Opts) ->
  self() ! handle_request,
  {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
  Doc = {[{message,<<"Mined a new block in x.ys. Hashing power: x hashes/s.">>},
          {block,{[
            {index, 2},
            {timestamp, 1235},
            {proof, 12351},
            {transactions, []},
            {previousBlockHash, <<"asdfas">>}
          ]}}
  ]},
  Json = jiffy:encode(Doc),
  Req2 = cowboy_req:reply(200,
    [{<<"content-type">>, <<"application/json">>}],
    Json,
    Req),
  {shutdown, Req2, State}.

