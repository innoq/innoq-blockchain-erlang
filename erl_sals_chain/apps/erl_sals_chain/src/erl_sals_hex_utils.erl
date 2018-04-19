%%%-------------------------------------------------------------------
%%% @author ramirez
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Apr 2018 17:16
%%%-------------------------------------------------------------------
-module(erl_sals_hex_utils).

%% API
-export([hex_digits/1]).

one_hex_digit(D) when 0 =< D, D =< 9 ->
  $0 + D;
one_hex_digit(D) when 10 =< D, D =< 15 ->
  $a + D - 10.

hex_digits(<< >>, Acc) -> lists:reverse(Acc);
hex_digits(<<First:8, Rest/binary>>, Acc) ->
  hex_digits(Rest, [one_hex_digit(First rem 16), one_hex_digit(First div 16) | Acc]).

hex_digits(Value) -> hex_digits(Value, []).