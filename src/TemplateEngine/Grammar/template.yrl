Nonterminals root template fmlookup arraylookup keyaccess stringcontent.

Rootsymbol root.

Terminals braceopen braceclose bracketopen bracketclose keylookup string digit.

root -> template:'$1'.

template -> stringcontent:'$1'.
template -> fmlookup : '$1'.
template -> braceopen template braceclose arraylookup: {arraylookup,'$2','$4'}.
template -> braceopen template keyaccess braceclose : {key_lookup,'$2','$3'}.
template -> template template : {concat, '$1', '$2'}.

fmlookup -> braceopen template braceclose : {variable,'$2'}.

keyaccess -> keylookup template : '$2'.

arraylookup -> bracketopen template bracketclose: '$2'.

stringcontent -> string: '$1'.
stringcontent -> digit: '$1'.
