(* $Id: togl.ml,v 1.1 1998-01-12 09:27:26 garrigue Exp $ *)

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
      ?:ident
      ?:overlay
      ?:privatecmap
      ?:redsize
      ?:rgba
      ?:stencil
      ?:stencilsize
      ?:stereo
      ?:time
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
	 @ may ident "-ident" id
	 @ may overlay "-overlay" cbool
	 @ may privatecmap "-privatecmap" cbool
	 @ may redsize "-redsize" cint
	 @ may rgba "-rgba" cbool
	 @ may stencil "-stencil" cbool
	 @ may stencilsize "-stencilsize" cint
	 @ may stereo "-stereo" cbool
	 @ may time "-time" cint
	 @ may width "-width" cint)

type w = Widget.any
type t = unit

let togl_table = Hashtbl.create size:3
let callback_table : (t -> unit) array =
  Array.create len:6 fill:(fun _ -> ())
let _ = Callback.register "togl_callbacks" callback_table
let create_id = 0
and display_id = 1
and reshape_id = 2
and destroy_id = 3
and timer_id = 4
and overlay_display_id = 5

external _create_func : unit -> unit = "ml_Togl_CreateFunc"
external _display_func : unit -> unit = "ml_Togl_DisplayFunc"
external _reshape_func : unit -> unit = "ml_Togl_ReshapeFunc"
external _destroy_func : unit -> unit = "ml_Togl_DestroyFunc"
external _timer_func : unit -> unit = "ml_Togl_TimerFunc"
external _overlay_display_func : unit -> unit = "ml_Togl_OverlayDisplayFunc"

let create :parent ?:name =
  togl_options_optionals
    ?(fun options ->
      let w : w Widget.widget =
	Widget.new_atom class:"togl" :parent ?:name in
      callback_table.(create_id) <-
	 (fun t -> Hashtbl.add togl_table key:w data:t);
      Protocol.tkEval
	[|Protocol.TkToken wclass; Protocol.TkToken (Widget.name w);
	  Protocol.TkTokenList options|];
      w)

external reset_default_callbacks : unit -> unit
    = "ml_Togl_ResetDefaultCallbacks"
external post_redisplay : t -> unit = "ml_Togl_PostRedisplay"
external _swap_buffers : t -> unit = "ml_Togl_SwapBuffers"

external ident : t -> string = "ml_Togl_Ident"
external height : t -> int = "ml_Togl_Height"
external width : t -> int = "ml_Togl_Width"

external load_bitmap_font : t -> name:string -> Gl.glist
    = "ml_Togl_LoadBitmapFont"
external unload_bitmap_font : t -> base:Gl.glist -> unit
    = "ml_Togl_UnloadBitmapFont"

external use_layer : t -> int -> unit = "ml_Togl_UseLayer"
external show_overlay : t -> unit = "ml_Togl_ShowOverlay"
external hide_overlay : t -> unit = "ml_Togl_HideOverlay"
external post_overlay_redisplay : t -> unit = "ml_Togl_PostOverlayRedisplay"

external exists_overlay : t -> bool = "ml_Togl_ExistsOverlay"
external get_overlay_transparent_value : t -> int
    = "ml_Togl_GetOVerlayTransparentValue"

external _dump_to_eps_file : t -> string -> bool -> unit
    = "ml_Togl_DumpToEpsFile"
let dump_to_eps_file togl :filename ?:rgba [< false >]
    ?:redraw [< callbacks_table.(display_id) >] =
  callback_table.(overlay_display_id) <- redraw;
  _dump_to_eps_file togl filename rgba
