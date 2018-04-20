%% WIP

-module(erl_sals_chain_nodes_register).

-export([init/2, info/3, get_node_id/2]).

init(Req, _Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"POST">> ->
            {ok, Body, _} = cowboy_req:body(Req),
            {[{<<"host">>, Host}]} = jiffy:decode(Body),

            Doc = jiffy:encode({[
                {message, <<"New node added">>},
                {node, {[
                    {nodeId, <<"some id">>},
                    {host, Host}
                ]}}
            ]});
        _ -> 
            Doc = ["Heribert uses POST here, too."]
    end,
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        Doc,
        Req),
    {shutdown, Req2, State}.


get_node_id(Host, Port) ->
    {ok, Conn} = shotgun:open(Host, Port),
    {ok, Response} = shotgun:get(Conn, "/"),
    #{body := Body} = Response,
    Json = jiffy:decode(Body),
    {[{<<"nodeId">>, NodeId}]} = Json,
    shotgun:close(Conn),
    NodeId.
