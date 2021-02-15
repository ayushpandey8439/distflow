Definitions.

Digits = [0-9]
Letters = [A-Za-z_\s]
BraceOpen = {
BraceClose = }
BracketOpen = \[
BracketClose = \]
KeyLookup = @
WhiteSpace =


Rules.
{KeyLookup} :   {token,{keylookup,TokenLine,list_to_atom(TokenChars)}}.
{BracketOpen}   : {token,{bracketopen,TokenLine,list_to_atom(TokenChars)}}.
{BracketClose}    : {token,{bracketclose,TokenLine,list_to_atom(TokenChars)}}.
{BraceOpen}    : {token,{braceopen,TokenLine,list_to_atom(TokenChars)}}.
{BraceClose}    : {token,{braceclose,TokenLine,list_to_atom(TokenChars)}}.
{Digits}+   : {token,{digit,TokenLine,list_to_integer(TokenChars)}}.
{Letters}+   : {token,{string,TokenLine,list_to_atom(TokenChars)}}.

Erlang code.

atom(TokenChars) -> list_to_atom(TokenChars).

strip(TokenChars,TokenLen) ->
    lists:sublist(TokenChars, 2, TokenLen - 2).