-module(erl_sals_chain_transactions).

-export([init/2, info/3]).

init(Req, _Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"POST">> ->
            {ok, Body, _} = cowboy_req:read_body(Req),
            % {[{payload, Payload}]} = jiffy:decode(Body),
            % Transaction = create_transaction(Payload),
            % Doc = jiffy:encode({Transaction});
            Doc = [Body];
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
    [
        {id, Id},
        {payload, Payload},
        {timestamp, Timestamp},
        {confirmed, false}
    ].


% add_transaction() ->
%     Uuid = list_to_binary(uuid:uuid_to_string(uuid:get_v4())),
%     BlockHeight = erl_sals_chain_keeper:get_index_of_last_block(),
%     Doc = {[{nodeId, Uuid}, {currentBlockHeight, BlockHeight}]},
%     Json = jiffy:encode(Doc),
    

    
%     get_transactions(),
%     .

% get_transactions() ->
%     .