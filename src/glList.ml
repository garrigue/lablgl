(* $Id: glList.ml,v 1.1 1998-01-29 11:45:50 garrigue Exp $ *)

type t = int
type base = int

external is_list : t -> bool = "ml_glIsList"
external gen_lists : len:int -> base = "ml_glGenLists"
external delete_lists : base -> len:int -> unit = "ml_glDeleteLists"
external begins : t -> mode:[compile compile_and_execute] -> unit
    = "ml_glNewList"
external ends : unit -> unit = "ml_glEndList"
external call : t -> unit = "ml_glCallList"
external call_lists : [byte(string) int(int array)] -> unit
    = "ml_glCallLists"
external list_base : base -> unit = "ml_glListBase"

let nth base :pos = base + pos

let create mode =
  let l = gen_lists len:1 in begins l :mode; l

let delete l =
  delete_lists l len:1

let call_lists lists ?:base =
  begin match base with None -> ()
  | Some base -> list_base base
  end;
  call_lists lists
