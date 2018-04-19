-module(erl_sals_chain_keeper).

% -behavior(gen_server).
-export([init/1, get_index_of_last_block/0, get_hash_of_last_block/0, get_list_of_blocks/0]).


get_index_of_last_block() ->
    1.

get_hash_of_last_block() ->
    <<"000000aaaaaaaaaaaaaaaaaaaaaaaaaa">>.

get_list_of_blocks() ->
    [<<"{\"index\":1,\"timestamp\":0,\"proof\":1917336,\"transactions\":[{\"id\":\"b3c973e2-db05-4eb5-9668-3e81c7389a6d\",\"timestamp\":0,\"payload\":\"I am Heribert Innoq\"}],\"previousBlockHash\":\"0\"}">>].

init(_Arg) ->
    GenesisBlock = <<"{\"index\":1,\"timestamp\":0,\"proof\":1917336,\"transactions\":[{\"id\":\"b3c973e2-db05-4eb5-9668-3e81c7389a6d\",\"timestamp\":0,\"payload\":\"I am Heribert Innoq\"}],\"previousBlockHash\":\"0\"}">>,
    Blocks = [ GenesisBlock ],
    PreviousHash = hex_digits(crypto:hash(sha256, GenesisBlock), []),
    State = {PreviousHash, Blocks},
    {ok, State}.

one_hex_digit(D) when 0 =< D, D =< 9 ->
    $0 + D;
one_hex_digit(D) when 10 =< D, D =< 15 ->
    $a + D - 10.

hex_digits(<< >>, Acc) -> lists:reverse(Acc);
hex_digits(<<First:8, Rest/binary>>, Acc) ->
    hex_digits(Rest, [one_hex_digit(First rem 16), one_hex_digit(First div 16) | Acc]).


                
    
    
