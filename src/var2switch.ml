(* Build a switch statement translating variants to C tags *)

open Genlex

let lexer = make_lexer ["->"; "$$"]

let main () =
  let table = ref false
  and prefix = ref ""
  and tag_number = ref 0 in
  Arg.parse ["-table", Arg.Set table, " Produce table output"]
    (fun s -> prefix := s) "";
  let s = lexer (Stream.of_channel stdin) in
  try
    while true do
      let (strm__ : _ Stream.t) = s in
      match Stream.peek strm__ with
        Some (Ident tag) ->
          Stream.junk strm__;
          incr tag_number;
          print_string (if !table then "    {MLTAG_" else "    case MLTAG_");
          print_string tag;
          print_string (if !table then ", " else ":\treturn ");
          let name =
            let (strm__ : _ Stream.t) = s in
            match Stream.peek strm__ with
              Some (Kwd "->") ->
                Stream.junk strm__;
                begin match Stream.peek strm__ with
                  Some (Ident name) -> Stream.junk strm__; name
                | _ -> raise (Stream.Error "")
                end
            | _ -> !prefix ^ String.uppercase_ascii tag
          in
          print_string name; print_string (if !table then "},\n" else ";\n")
      | Some (Kwd "$$") -> Stream.junk strm__; raise End_of_file
      | _ -> raise End_of_file
    done
  with End_of_file -> Printf.printf "#define TAG_NUMBER %d\n" !tag_number

let _ = Printexc.print main ()
