(* $Id: glList.ml,v 1.3 2000-04-03 02:57:41 garrigue Exp $ *)

type t = int
type base = int

external is_list : t -> bool = "ml_glIsList"
external gen_lists : len:int -> base = "ml_glGenLists"
external delete_lists : base -> len:int -> unit = "ml_glDeleteLists"
external begins : t -> mode:[`compile|`compile_and_execute] -> unit
    = "ml_glNewList"
external ends : unit -> unit = "ml_glEndList"
external call : t -> unit = "ml_glCallList"
external call_lists : [ `byte of string | `int of int array] -> unit
    = "ml_glCallLists"
external list_base : base -> unit = "ml_glListBase"

let nth base :pos = base + pos

let create mode =
  let l = gen_lists len:1 in begins l :mode; l

let delete l =
  delete_lists l len:1

let call_lists ?:base lists =
  begin match base with None -> ()
  | Some base -> list_base base
  end;
  call_lists lists
