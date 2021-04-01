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
{KeyLookup} :   {token,{keylookup,TokenLine,(TokenChars)}}.
{BracketOpen}   : {token,{bracketopen,TokenLine,(TokenChars)}}.
{BracketClose}    : {token,{bracketclose,TokenLine,(TokenChars)}}.
{BraceOpen}    : {token,{braceopen,TokenLine,(TokenChars)}}.
{BraceClose}    : {token,{braceclose,TokenLine,(TokenChars)}}.
{Digits}+   : {token,{digit,TokenLine,list_to_integer(TokenChars)}}.
{Letters}+   : {token,{string,TokenLine,(TokenChars)}}.

Erlang code.

atom(TokenChars) -> (TokenChars).

strip(TokenChars,TokenLen) ->
    lists:sublist(TokenChars, 2, TokenLen - 2).