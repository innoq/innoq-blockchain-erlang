-module(erl_sals_chain_transactions_find).

-export([init/2, info/3]).

-include("erl_sals_records.hrl").

init(Req, _Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Id = cowboy_req:binding(id, Req),
    Doc = case erl_sals_chain_keeper:find_transaction(Id) of
              {ok, Transaction} -> {[
                  {id, Transaction#transaction.id},
                  {payload, Transaction#transaction.payload},
                  {timestamp, Transaction#transaction.timestamp},
                  {confirmed, true}
              ]};
              {not_found} ->
                  case erl_sals_chain_transactions_queue:find_transaction(Id) of
                      {ok, Transaction} -> {[
                          {id, Transaction#transaction.id},
                          {payload, Transaction#transaction.payload},
                          {timestamp, Transaction#transaction.timestamp},
                          {confirmed, false}
                      ]};
                      {not_found} -> {[]}
                  end
          end,
    Json = jiffy:encode(Doc),
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        Json,
        Req),
    {shutdown, Req2, State}.
