-module(erl_sals_chain_root).

-export([init/2, info/3]).

init(Req, _Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Uuid = erl_sals_chain_uuid:get_uuid(),
    BlockHeight = erl_sals_chain_keeper:get_index_of_last_block(),
    Doc = {[{nodeId, Uuid}, {currentBlockHeight, BlockHeight}]},
    Json = jiffy:encode(Doc),
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        Json,
        Req),
    {shutdown, Req2, State}.

