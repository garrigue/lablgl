(* FrontC -- abstract syntax
**
** Project:	FrontC
** File:	frontc.ml
** Version:	2.0
** Date:	3.22.99
** Author:	Hugues Cassé
**
**	1.0	2.18.99	Hugues Cassé	First release.
**	2.0	3.22.99	Hugues Cassé	Full ANSI C and GCC attributes supported.
**								Cprint improved.
*)

let version = "FrontC 2.0 3.22.99 Hugues Cassé"

(*
** Parsing functions
*)
type parsing_result =
	PARSING_ERROR
	| PARSING_OK of Cabs.definition list


(* parse_interactive input output -> AST
**		Parse C from an interactive input channel.
*)
let parse_interactive  (inp : in_channel) (out : out_channel) : parsing_result =
	Clexer.init (true, inp, "", "", 0, 0, out, "");
	try PARSING_OK (Cparser.interpret
		Clexer.initial
		(Lexing.from_function (Clexer.get_buffer Clexer.current_handle)))
	with Parsing.Parse_error -> PARSING_ERROR


(* parse_console () -> AST
**		Parse interactive from the console input, producing error on console error.
*)
let parse_console _ : parsing_result =
	parse_interactive stdin stderr


(* parse_file file_name output -> AST
**		Parse C program from a file.
*)	
let parse_file (file_name : string) (out : out_channel) : parsing_result =
	try let file = open_in file_name in
		Clexer.init (false, file, "", "", 0, 0, out, file_name);
		PARSING_OK (Cparser.file
			Clexer.initial
			(Lexing.from_function (Clexer.get_buffer Clexer.current_handle)))
	with (Sys_error msg) ->
			output_string out
				("Error while opening " ^ file_name
				^ ": " ^ msg ^ "\n");
			PARSING_ERROR
	| Parsing.Parse_error -> PARSING_ERROR


(*
** Main program
*)
(*let main _ = parse_console ()*)




