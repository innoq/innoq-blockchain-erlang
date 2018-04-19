-module(erl_sals_chain_root).

-export([init/2, info/3]).

init(Req, Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Uuid = <<uuid:uuid_to_string(uuid:get_v4())>>,
    Doc = {[{nodeId,Uuid}, {currentBlockHeight,1}]},
    Json = jiffy:encode(Doc),
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        Json,
        Req),
    {shutdown, Req2, State}.

