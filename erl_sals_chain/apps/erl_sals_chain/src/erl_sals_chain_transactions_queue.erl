-module(erl_sals_chain_transactions_queue).

-behavior(gen_server).

% API:
-export([pop_five_transactions/0,
    find_transaction/1,
    put_new_transaction/1]).

-include("erl_sals_records.hrl").

% gen_server:
-export([init/1, handle_call/3, handle_cast/2, start_link/0]).

pop_five_transactions() ->
    gen_server:call(erl_sals_chain_transactions_queue, pop_five_transactions).

find_transaction(TransactionId) ->
    gen_server:call(erl_sals_chain_transactions_queue, {find_transaction, TransactionId}).

put_new_transaction(Transaction) ->
    gen_server:call(erl_sals_chain_transactions_queue, {put_new_transaction, Transaction}).

start_link() ->
    gen_server:start_link({local, erl_sals_chain_transactions_queue},
        erl_sals_chain_transactions_queue,
        ignore_me,
        []).

init(_Arg) ->
    State = [],
    {ok, State}.

handle_call(pop_five_transactions, _From, State) ->
    {reply, lists:sublist(State, 5), lists:nthtail(State, 5)};

handle_call({find_transaction, TransactionId}, _From, State) ->
    {reply, find(State, TransactionId), State};

handle_call({put_new_transaction, Transaction}, _From, State) ->
    {reply, ok, State ++ Transaction}.

handle_cast(_Request, State) ->
    {stop, nicht_vorgesehen, State}.

find([#transaction{id = TransactionId, payload = Payload, timestamp = Timestamp} | Tail], TransactionId) ->
    {ok, #transaction{id = TransactionId, payload = Payload, timestamp = Timestamp}};
find([_Transaction | Tail], TransactionId) -> find(Tail, TransactionId);
find([], _TransactionId) -> {not_found}.
