-module(erl_sals_worker).

-export([mine/4]).

mine(Index, Timestamp, TransactionJson, PreviousBlockHash) ->
    BeforeProof = list_to_binary(
                    [<<"{\"index\":">>, io_lib:write(Index), 
                     <<",\"timestamp\":">>, io_lib:write(Timestamp),
                     <<",\"proof\":">>]),
    PostProof = list_to_binary(
                  [<<",\"transactions\":">>, TransactionJson,
                  <<",\"previousBlockHash\":\"">>, PreviousBlockHash,
                  <<"\"}">>]
                 ),
    BlockGenerator = fun (I) -> [BeforeProof, io_lib:write(I), PostProof] end,
    Proof = find_block_hashing_with_6_leading_zeros(BlockGenerator),
    BlockGenerator(Proof).    

% BlockGenerator is a function expecting one integer argument
% and producing an IOlist to hash.
find_block_hashing_with_6_leading_zeros(BlockGenerator) ->
    Proof = 0,
    Block = BlockGenerator(Proof),
    Hash = crypto:hash(sha256, Block),
    find_block_hashing_with_6_leading_zeros(BlockGenerator, Proof, Hash).

find_block_hashing_with_6_leading_zeros(_BlockGenerator, Proof, <<0:24, _Rest/binary>>) ->
    Proof;
find_block_hashing_with_6_leading_zeros(BlockGenerator, Proof, Hash) ->
    NewProof = Proof + 1,
    NewBlock = BlockGenerator(NewProof),
    NewHash = crypto:hash(sha256, NewBlock),
    find_block_hashing_with_6_leading_zeros(BlockGenerator, NewProof, NewHash).


