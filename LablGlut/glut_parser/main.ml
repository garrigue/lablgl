(*pp camlp4o *)

(* Convert a C-based GLUT demo to OCaml, at least partially. *)

open Genlex
open Printf

let easy_lexer = make_lexer [
  ";"; ","; "{"; "}"; "."; "=="; "||"; "&&"; "+="; "*="; "-="; "/="; "|="; 
  "^="; "++"; "--"; "->"; "\""; "..."; "/*"; "*/"
];;

let pass1 fname verbose = 
  (* first pass : convert comments to OCaml style to make them work with 
     Genlex, put C preprocessing stuff into comments.  Store results in a 
     temporary file *)
  if verbose then printf "-= pass1 =-\n";
  let tempname = Filename.temp_file "/tmp" ".c" in
  let cmd = 
    "cat "^fname
    ^ " | sed 's/(\\*/( */g'" 
    ^ " | sed 's/\\/\\*/(*/g'"
    ^ " | sed 's/\\*\\//*)/g'" 
    ^ " | sed 's/^\\(#.*\\)$/(* \\1 *)/'"
    ^ " > " ^ tempname in
  let _ = match Unix.system cmd with 
  | Unix.WEXITED _ -> ()
  | Unix.WSIGNALED i -> 
      failwith("preprocess killed by signal "^(string_of_int i))
  | Unix.WSTOPPED i -> 
      failwith("preprocess stopped by signal "^(string_of_int i)) 
  in
  if verbose then printf "%s\n" cmd ;
  tempname
;;

let pass2 origname tempname verbose =
  (* second pass : open the temp file generated during pass 1 and parse using
     the modified default lexer from the genlex module *)

  if verbose then printf "-= pass 2 =-\nworking on %s\n" tempname;
  let tempfile = open_in tempname in
  let s = easy_lexer (Stream.of_channel tempfile) in
  try while true do match s with parser
    (* looking for a top-level declaration of some kind *)
      [< ' Ident ident >] ->
        printf "IDENT: %s\n" ident;
        (*
        let name =
          match s with parser
              [< ' Kwd "->" ; ' Ident name >] -> name
            | [< >] -> !prefix ^ String.uppercase tag
        in print_string name;
        print_string (if !table then "},\n" else ";\n")
        *)
    | [< ' Kwd kwd >] -> 
        begin
          printf "KWD  : %s\n" (match kwd with
            | "==" -> "EQUALITY"
            | str -> str)
        end
    | [< >] -> raise End_of_file
  done with End_of_file -> printf "all done.\n"
;;

let main () =
  let verbose = ref false 
  and filename = ref None 
  and show_pass1 = ref false in
  let speclist = ["-v", Arg.Set verbose, " Verbose mode" ] in
  Arg.parse speclist (fun s -> filename := Some s) "";
  let filename = match !filename with 
  | None -> Arg.usage speclist "<USAGE MESSAGE>"; failwith "";
  | Some s -> s in
  let tempname = pass1 filename !verbose in
  pass2 filename tempname !verbose;
;;

let _ = Printexc.print main ()

