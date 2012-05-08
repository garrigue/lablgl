(* $Id: var2def.ml,v 1.9 2001-09-06 08:27:02 garrigue Exp $ *)

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
  if !accu > 0x3FFFFFFF then !accu - (1 lsl 31) else !accu

open Genlex

let lexer = make_lexer ["->"; "$$"]

let doublons = ref []

let main () =
  let s = lexer (Stream.of_channel stdin) in
  let tags = Hashtbl.create 57 in
  try while true do match s with parser
      [< ' Ident tag >] ->
	print_string "#define MLTAG_";
	print_string tag;
	print_string "\tVal_int(";
	let hash = hash_variant tag in
	begin 
	  try
	    doublons := (hash, Hashtbl.find tags hash)::!doublons
	  with Not_found -> Hashtbl.add tags hash tag
	end;
	print_int hash;
	print_string ")\n"
    | [< ' Kwd "->"; ' Ident _ >] -> ()
    | [< ' Kwd "$$" >] -> ()
    | [< >] -> raise End_of_file
  done with End_of_file -> (
    match !doublons with
	[] -> ()
      | l  -> 
	prerr_endline "doublons : ";
	List.iter (fun (h,v) -> prerr_endline (v^" = "^string_of_int h)) l;
	failwith "doublons founds"
  )

let _ = Printexc.print main ()
