-module(erl_sals_chain_uuid).

-behavior(gen_server).

% API:
-export([get_uuid/0]).

% gen_server:
-export([init/1, handle_call/3, handle_cast/2, start_link/0]).

get_uuid() ->
    gen_server:call(erl_sals_chain_uuid, get_uuid).

start_link() ->
    gen_server:start_link({local, erl_sals_chain_uuid}, erl_sals_chain_uuid, ignore_me, []).

init(_Arg) ->
    State = list_to_binary(uuid:uuid_to_string(uuid:get_v4())),
    {ok, State}.

handle_call(get_uuid, _From, State) ->
    {reply, State, State}. 

handle_cast(_Request, State) ->
    {stop, nicht_vorgesehen, State}.

                
    
    
