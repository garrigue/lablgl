(* $Id: togl.ml,v 1.13 1999-11-17 13:23:27 garrigue Exp $ *)

open Tk
open Protocol

let may x name f =
  match x with None -> []
  | Some a -> [TkToken name; TkToken (f a)]

let cbool x = if x then "1" else "0"
let cint = string_of_int
let id x = x

let togl_options_optionals f =
  fun
      ?:accum
      ?:accumalphasize
      ?:accumbluesize
      ?:accumgreensize
      ?:accumredsize
      ?:alpha
      ?:alphasize
      ?:auxbuffers
      ?:bluesize
      ?:depth
      ?:depthsize
      ?:double
      ?:greensize
      ?:height
      (* ?:ident *)
      ?:overlay
      ?:privatecmap
      ?:redsize
      ?:rgba
      ?:stencil
      ?:stencilsize
      ?:stereo
      (* ?:time *)
      ?:width
    ->
      f (may accum "-accum" cbool
	 @ may accumalphasize "-accumalphasize" cint
	 @ may accumbluesize "-accumbluesize" cint
	 @ may accumgreensize "-accumgreensize" cint
	 @ may accumredsize "-accumredsize" cint
	 @ may alpha "-alpha" cbool
	 @ may alphasize "-alphasize" cint
	 @ may auxbuffers "-auxbuffers" cint
	 @ may bluesize "-bluesize" cint
	 @ may depth "-depth" cbool
	 @ may depthsize "-depthsize" cint
	 @ may double "-double" cbool
	 @ may greensize "-greensize" cint
	 @ may height "-height" cint
	 (* @ may ident "-ident" id *)
	 @ may overlay "-overlay" cbool
	 @ may privatecmap "-privatecmap" cbool
	 @ may redsize "-redsize" cint
	 @ may rgba "-rgba" cbool
	 @ may stencil "-stencil" cbool
	 @ may stencilsize "-stencilsize" cint
	 @ may stereo "-stereo" cbool
	 (* @ may time "-time" cint *)
	 @ may width "-width" cint)

type t

external init : unit -> unit = "ml_Togl_Init"

external _create_func : unit -> unit = "ml_Togl_CreateFunc"
external _display_func : unit -> unit = "ml_Togl_DisplayFunc"
external _reshape_func : unit -> unit = "ml_Togl_ReshapeFunc"
external _destroy_func : unit -> unit = "ml_Togl_DestroyFunc"
external _timer_func : unit -> unit = "ml_Togl_TimerFunc"
external _overlay_display_func : unit -> unit = "ml_Togl_OverlayDisplayFunc"

external _reset_default_callbacks : unit -> unit
    = "ml_Togl_ResetDefaultCallbacks"
external _post_redisplay : t -> unit = "ml_Togl_PostRedisplay"
external _swap_buffers : t -> unit = "ml_Togl_SwapBuffers"

external _ident : t -> string = "ml_Togl_Ident"
external _height : t -> int = "ml_Togl_Height"
external _width : t -> int = "ml_Togl_Width"

type font = [
    `fixed_8x13
  | `fixed_9x15
  | `times_10
  | `times_24
  | `helvetica_10
  | `helvetica_12
  | `helvetica_18
  | `Xfont string
]

external _load_bitmap_font : t -> font:font -> GlList.base
    = "ml_Togl_LoadBitmapFont"
external _unload_bitmap_font : t -> base:GlList.base -> unit
    = "ml_Togl_UnloadBitmapFont"

external _use_layer : t -> num:int -> unit = "ml_Togl_UseLayer"
external _show_overlay : t -> unit = "ml_Togl_ShowOverlay"
external _hide_overlay : t -> unit = "ml_Togl_HideOverlay"
external _post_overlay_redisplay : t -> unit = "ml_Togl_PostOverlayRedisplay"

external _exists_overlay : t -> bool = "ml_Togl_ExistsOverlay"
external _get_overlay_transparent_value : t -> int
    = "ml_Togl_GetOverlayTransparentValue"

external _dump_to_eps_file : t -> string -> bool -> unit
    = "ml_Togl_DumpToEpsFile"

type w
type widget = w Widget.widget

let togl_table = Hashtbl.create 7

let wrap f (w : widget) =
  let togl =
    try Hashtbl.find togl_table key:w
    with Not_found -> raise (TkError "Unreferenced togl widget")
  in f togl

let render = wrap _post_redisplay
let swap_buffers = wrap _swap_buffers
let height = wrap _height
let width = wrap _width
let load_bitmap_font = wrap _load_bitmap_font
let unload_bitmap_font = wrap _unload_bitmap_font
let use_layer = wrap _use_layer
let show_overlay = wrap _show_overlay
let hide_overlay = wrap _hide_overlay
let overlay_redisplay = wrap _post_overlay_redisplay
let exists_overlay = wrap _exists_overlay
let get_overlay_transparent_value = wrap _get_overlay_transparent_value

let make_current togl =
  ignore (tkEval [|TkToken (Widget.name togl); TkToken "makecurrent"|])

let null_func _ = ()
let display_table = Hashtbl.create 7
and reshape_table = Hashtbl.create 7
and overlay_table = Hashtbl.create 7

let cb_of_togl table togl =
  try 
    let key = _ident togl in
    let cb = Hashtbl.find :key table in
    ignore (tkEval [|TkToken key; TkToken "makecurrent"|]);
    cb ()
  with Not_found -> ()

let create_id = 0
and display_id = 1
and reshape_id = 2
and destroy_id = 3
and timer_id = 4
and overlay_display_id = 5
and render_id = 6

let callback_table =
  [|null_func;
    cb_of_togl display_table;
    cb_of_togl reshape_table;
    null_func;
    null_func;
    cb_of_togl overlay_table;
    null_func|]
let _ = Callback.register "togl_callbacks" callback_table

let callback_func table (w : widget) :cb =
  let key = Widget.name w in
  (try Hashtbl.remove :key table with Not_found -> ());
  Hashtbl.add :key data:cb table

let display_func = callback_func display_table
let reshape_func w :cb =
  make_current w; cb ();
  callback_func reshape_table w :cb
let overlay_display_func = callback_func overlay_table

let dump_to_eps_file :filename ?:rgba{=false} ?:render togl =
  let render =
    match render with Some f -> f
    | None ->
	try Hashtbl.find key:(_ident togl) display_table
	with Not_found ->
	  raise (TkError "Togl.dump_to_eps_file : no render function")
  in
  callback_table.(render_id) <- (fun _ -> render());
  _dump_to_eps_file togl filename rgba

let dump_to_eps_file :filename ?:rgba ?:render =
  wrap (dump_to_eps_file :filename ?:rgba ?:render)

let rec timer_func :ms :cb =
  Timer.add :ms callback:(fun () -> cb (); timer_func :ms :cb);
  ()

let configure ?:height ?:width w =
  let options = may height "-height" cint @ may width "-width" cint in
  tkEval [|TkToken (Widget.name w); TkTokenList options|]

(*
class widget w t =
  val w : widget = w
  val t = t
  method widget = w
  method name = coe w
  method configure = configure ?w
  method bind = bind w
  method redisplay = post_redisplay t
  method swap_buffers = swap_buffers t
  method width = width t
  method height = height t
  method load_font = load_bitmap_font t
  method unload_font = unload_bitmap_font t
  method use_layer = use_layer t
  method show_overlay = show_overlay t
  method hide_overlay = hide_overlay t
  method overlay_redisplay = post_overlay_redisplay t
  method exist_overlay = exists_overlay t
  method overlay_transparent_value = get_overlay_transparent_value t
  method dump_to_eps_file = dump_to_eps_file t
  method make_current =
    tkEval [|TkToken (Widget.name w); TkToken "makecurrent"|]; ()
end
*)

let ready = ref false

let init_togl () =
  init ();
  _create_func ();
  _display_func ();
  _reshape_func ();
  _overlay_display_func ();
  _destroy_func ();
  ready := true

let create ?:name =
  togl_options_optionals
    (fun options parent ->
      if not !ready then init_togl ();
      let w : widget =
	Widget.new_atom "togl" :parent ?:name in
      let togl = ref None in
      callback_table.(create_id) <-
	 (fun t -> togl := Some t; Hashtbl.add togl_table key:w data:t);
      callback_table.(destroy_id) <-
        (fun t ->
	  begin try Hashtbl.remove key:w togl_table with Not_found -> () end;
	  List.iter [display_table; reshape_table; overlay_table] fun:
	    begin fun tbl ->
	      try Hashtbl.remove tbl key:(Widget.name w) with Not_found -> ()
	    end);
      let command =
	[|TkToken "togl"; TkToken (Widget.name w);
	  TkToken "-ident"; TkToken (Widget.name w);
	  TkTokenList options|] in
      begin
	try tkEval command
	with TkError "invalid command name \"togl\"" ->
	  init_togl (); tkEval command
      end;
      match !togl with None -> raise (TkError "Togl widget creation failed")
      |	Some t -> w)
