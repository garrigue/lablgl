(* $Id: var2switch.ml,v 1.3 1998-01-29 11:46:19 garrigue Exp $ *)

(* Build a switch statement translating variants to C tags *)

open Genlex

let lexer = make_lexer ["->"; "$$"]

let main () =
  let table = ref false and prefix = ref "" and tag_number = ref 0 in
  Arg.parse keywords:["-table", Arg.Set table, " Produce table output"]
    others:(fun s -> prefix := s) errmsg:"";
  let s = lexer (Stream.of_channel stdin) in
  try while true do match s with parser
      [< ' Ident tag >] ->
	incr tag_number;
	print_string (if !table then "    {MLTAG_" else "    case MLTAG_");
	print_string tag;
	print_string (if !table then ", " else ":\treturn ");
	let name =
	  match s with parser
	      [< ' Kwd "->" ; ' Ident name >] -> name
	    | [< >] -> !prefix ^ String.uppercase tag
	in print_string name;
	print_string (if !table then "},\n" else ";\n")
    | [< ' Kwd "$$" >] -> raise End_of_file
    | [< >] -> raise End_of_file
  done with End_of_file ->
    Printf.printf "#define TAG_NUMBER %d\n" !tag_number

let _ = Printexc.print main ()
