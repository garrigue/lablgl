type lexeme =
   | Word of string
   | Symbol of char
   | Int of int
   | Float of float;;

val c_lexer : char Stream.t -> lexeme Stream.t;;

val string_of_lexeme :  lexeme -> string;;

