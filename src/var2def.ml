open StdLabels

(* Compile a list of variant tags into CPP defines *) 

(* hash_variant, from ctype.ml *)

let hash_variant s =
  let accu = ref 0 in
  for i = 0 to String.length s - 1 do
    accu := 223 * !accu + Char.code s.[i]
  done;
  (* reduce to 31 bits *)
  accu := !accu land (1 lsl 31 - 1);
  (* make it signed for 64 bits architectures *)
  if !accu > 0x3FFFFFFF then !accu - 1 lsl 31 else !accu

open Genlex

let lexer = make_lexer ["->"; "$$"]

let main () =
  let s = lexer (Stream.of_channel stdin) in
  let tags = Hashtbl.create 57 in
  try
    while true do
      let (strm__ : _ Stream.t) = s in
      match Stream.peek strm__ with
        Some (Ident tag) ->
          Stream.junk strm__;
          print_string "#define MLTAG_";
          print_string tag;
          print_string "\tVal_int(";
          let hash = hash_variant tag in
          begin try
            failwith
              (String.concat ~sep:" "
                 ["Doublon ~tag:"; tag; "and"; Hashtbl.find tags hash])
          with Not_found -> Hashtbl.add tags hash tag
          end;
          print_int hash;
          print_string ")\n"
      | Some (Kwd "->") ->
          Stream.junk strm__;
          begin match Stream.peek strm__ with
            Some (Ident _) -> Stream.junk strm__; ()
          | _ -> raise (Stream.Error "")
          end
      | Some (Kwd "$$") -> Stream.junk strm__; ()
      | _ -> raise End_of_file
    done
  with End_of_file -> ()

let _ = Printexc.print main ()
