(* lex.ml : adapted from a parser by Pierre Weiss in the minilogo example.
   temporarily on the back burner while I try out genlex *)

type lexeme =
  | CppDirective of string (* preprocessor directive *)
  | Comment of string
  | Ident of string
  | Key of string
  | Operator of string
  | String of string
  | Char of char
  | Int of int 
  | Float of float;; 

let string_of_chars clist = 
  let n = List.length clist in
  let buf = String.create n in 
  let i = ref (pred n) in 
  let rec sofc = function
    | [] -> ()
    | h :: tl -> buf.[!i] <- h; i := !i - 1; sofc tl in
  sofc clist;
  buf;;

let rec skip_white = parser
  | [< ' (' ' | '\t' | '\n'); flux >] -> skip_white flux
  | [< >] -> ();;

let rec read_int accumulator = parser
  | [< ' ('0' .. '9' as c); flux >] ->
      read_int (10 * accumulator + int_of_char c - 48) flux
  | [< >] -> accumulator;;

let rec read_decimals accumulator so_far = parser
  | [< ' ('0' .. '9' as c); flux >] ->
      read_decimals (accumulator +. float_of_int(int_of_char c - 48) *. so_far)
        (so_far /. 10.0) flux
  | [< >] -> accumulator;;

(* let buffer = String.make 16 '-';; *)

let rec read_word position = parser
  | [< '( 'A' .. 'Z' | 'a' .. 'z' | '_' as c); flux >] ->
      if position < String.length buffer then
        buffer.[position] <- c;
      read_word (position + 1) flux
  | [< >] ->
      String.sub buffer 0 (min position (String.length buffer));;

(* returns list of char *)
let rec parse_comment = parser
  | [< ' "*/" >] -> []
  | [< ' c ; flux >] -> c :: (parse_comment flux)
  | [< >] -> failwith "End of file encountered while scanning comment" ;;
  
let rec parse_cpp_directive = parser
  | [< ' "\n" >] -> []
  | [< ' c ; flux -> c :: parse_cpp_directive flux
  | [< >] -> failwith "End of file encountered while scanning preprocessor " ^
        "directive";;

let rec read_lexeme flux =
  skip_white flux;
  let find_lexeme = parser
    | [< ' '#' ; flux >] ->
        CppDirective(string_of_chars(parse_cpp_directive flux))
    | [< ' '/' ; flux >] -> 
        let xeme = match flux with parser
        | [< ' '*'; flux >] -> Comment(string_of_chars(parse_comment flux))
        | [< >] -> Operator "/" in
        xeme
    | [< ' '='; flux >] -> 
        let xeme = match flux with parser 
        | [< '=' >] -> Operator "=="
        | [< >] -> Operator "=" in
        xeme
    | [< ' '|'; flux >] ->
        let xeme = match flux with parser
        | [< '|' >] -> Operator "||"
        | [< >] 
'&&' |  
'+=' |  
'*=' |  
'-=' |  
'/=' |  
'|=' |  
'^=' |  
'++' |  
'--' |  
'->' |  
'...' |  


    | [< ' '!' | '#' | '%' | '^' | '&' | '*' | '(' | ')' | '-' | '+' |  
      '=' | ';' | ':' | '"' | ''' | '.' | ',' | '?' | '[' | ']' | '{' |  
      '~' | '}' | '|' as c) >|] -> Operator(String.make 1 c)
'' |  
Operator of string
    | String of string
    | Char of char
    | Int of int 
    | Float of float;; 
    | [< '( 'A' .. 'Z' | 'a' .. 'z' | '_' as c); flux >] 
             Key s
    | [< Ident(string_of_chars(parse_ident flux))


    | [< '( 'A' .. 'Z' | 'a' .. 'z' as c) >] ->
        buffer.[0] <- c;
        Key (read_word 1 flux)
    | [< '( '0' .. '9' as c) >] ->
        let n = read_int (int_of_char c - 48) flux in
        begin match flux with parser
        | [< ''.' >] -> Float (read_decimals (float_of_int n) 0.1 flux)
        | [< >]      -> Int n end
    | [< 'c >] -> Symbol c in
  find_lexeme flux;;

let c_lexer flux =
  Stream.from
    (fun _ -> try Some (read_lexeme flux) with Stream.Failure -> None);;
