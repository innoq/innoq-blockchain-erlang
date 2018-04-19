-module(erl_sals_chain_root).

-export([init/2, info/3]).

init(Req, Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/plain">>}],
        <<"Hello Heribert!">>,
        Req),
    {shutdown, Req2, State}.

