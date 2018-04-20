-module(erl_sals_chain_blocks).
-include("erl_sals_records.hrl").
-export([init/2, info/3]).

init(Req, _Opts) ->
    self() ! handle_request,
    {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
    BlockHeight = integer_to_binary(erl_sals_chain_keeper:get_index_of_last_block()),
    BlockContents = lists:map(
                      fun(#block{content=Content, transactions=_}) -> Content end, 
                      erl_sals_chain_keeper:get_list_of_blocks()),
    Output = ["{blocks:[", BlockContents, "],blockHeight:", BlockHeight, "}"],
    Req2 = cowboy_req:reply(200,
                            [{<<"content-type">>, <<"application/json">>}],
                            Output,
                            Req),
    {shutdown, Req2, State}.
