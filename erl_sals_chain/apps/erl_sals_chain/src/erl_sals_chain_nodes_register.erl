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
            io:write(io:format("~p~n",[Host])),
            [_ , _ , HostNoProtocol] = string:replace(Host, "http://", ""),
            [Hostname, Port] = string:split(HostNoProtocol, ":"),
            NodeId = get_node_id(<<Hostname>>, binary_to_integer(Port)),
            Node = {[
                {nodeId, NodeId},
                {host, Host}
            ]},
            erl_sals_chain_nodes_keeper:put_new_node(Node),
            Doc = jiffy:encode({[
                {message, <<"New node added">>},
                {node, Node}
            ]});
        _ ->
            Doc = ["Heribert uses POST here, too."]
    end,
    Req2 = cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        Doc,
        Req),
    {stop, Req2, State}.

get_node_id(Hostname, Port) ->
    io:write(io:format("~p~n",[Hostname])),
    io:write(io:format("~p~n",[Port])),
    {ok, Conn} = shotgun:open(Hostname, Port),
    {ok, Response} = shotgun:get(Conn, "/"),
    #{body := Body} = Response,
    Json = jiffy:decode(Body),
    io:write(io:format("~p~n",[Json])),
    {[{<<"nodeId">>, NodeId}]} = Json,
    shotgun:close(Conn),
    NodeId.
