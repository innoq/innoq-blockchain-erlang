-module(erl_sals_chain_blocks).

-export([init/2, info/3]).

init(Req, Opts) ->
  self() ! handle_request,
  {cowboy_loop, Req, rumpelstielzchen}.

info(_Msg, Req, State) ->
  BlockHeight = erl_sals_chain_keeper:get_index_of_last_block(),
  Blocks = erl_sals_chain_keeper:get_list_of_blocks(),
  Output = ["{blocks:[", Blocks, "],blockHeight:", BlockHeight, "}"],
  Req2 = cowboy_req:reply(200,
    [{<<"content-type">>, <<"application/json">>}],
    Output,
    Req),
  {shutdown, Req2, State}.
