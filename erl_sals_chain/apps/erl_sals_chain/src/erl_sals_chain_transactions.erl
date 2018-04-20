-module(erl_sals_chain_transactions).

-export([init/2, info/3]).

-include("erl_sals_records.hrl").

init(Req, _Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"POST">> ->
            {ok, Body, _} = cowboy_req:body(Req),
            {[{<<"payload">>, Payload}]} = jiffy:decode(Body),
            Transaction = create_transaction(Payload),
            erl_sals_chain_transactions_queue:put_new_transaction(Transaction),
            Doc = jiffy:encode({[
                {id, Transaction#transaction.id},
                {payload, Transaction#transaction.payload},
                {timestamp, Transaction#transaction.timestamp},
                {confirmed, false}
            ]});
        _ -> 
            Doc = ["Heribert uses POST here."]
    end,
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        Doc,
        Req),
    {shutdown, Req2, State}.

create_transaction(Payload) ->
    Id = list_to_binary(uuid:uuid_to_string(uuid:get_v4())),
    Timestamp = os:system_time(second),
    #transaction{
        id = Id,
        payload = Payload,
        timestamp = Timestamp
    }.