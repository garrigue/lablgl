(* $Id: togl.ml,v 1.2 1998-01-12 14:08:54 garrigue Exp $ *)

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
type t = Togl

let togl_table = Hashtbl.create size:3
let callback_table : (t -> unit) array =
  Array.create len:7 fill:(fun _ -> ())
let _ = Callback.register "togl_callbacks" callback_table
let create_id = 0
and display_id = 1
and reshape_id = 2
and destroy_id = 3
and timer_id = 4
and overlay_display_id = 5
and render_id = 6

external _create_func : unit -> unit = "ml_Togl_CreateFunc"
external _display_func : unit -> unit = "ml_Togl_DisplayFunc"
external _reshape_func : unit -> unit = "ml_Togl_ReshapeFunc"
external _destroy_func : unit -> unit = "ml_Togl_DestroyFunc"
external _timer_func : unit -> unit = "ml_Togl_TimerFunc"
external _overlay_display_func : unit -> unit = "ml_Togl_OverlayDisplayFunc"

let display_func f =
  callback_table.(display_id) <- f; _display_func ()
let reshape_func f =
  callback_table.(reshape_id) <- f; _reshape_func ()
let destroy_func f =
  callback_table.(destroy_id) <- f; _destroy_func ()
let timer_func f =
  callback_table.(timer_id) <- f; _timer_func ()
let overlay_display_func f =
  callback_table.(overlay_display_id) <- f; _overlay_display_func ()

external init : unit -> unit = "ml_Togl_Init"
external reset_default_callbacks : unit -> unit
    = "ml_Togl_ResetDefaultCallbacks"
external post_redisplay : t -> unit = "ml_Togl_PostRedisplay"
external swap_buffers : t -> unit = "ml_Togl_SwapBuffers"

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
    = "ml_Togl_GetOverlayTransparentValue"

external _dump_to_eps_file : t -> string -> bool -> unit
    = "ml_Togl_DumpToEpsFile"
let dump_to_eps_file togl :filename ?:rgba [< false >]
    ?:render [< callback_table.(display_id) >] =
  callback_table.(render_id) <- render;
  _dump_to_eps_file togl filename rgba

let rec timer_func :ms fun:f =
  Timer.add :ms callback:(fun () -> f (); timer_func :ms fun:f);
  ()

let configure w ?:height ?:width =
  let options = may height "-height" cint @ may width "-width" cint in
  tkEval [|TkToken (Widget.name w); TkTokenList options|]

class widget w t =
  val w : w Widget.widget = w
  val t = t
  method widget = w
  method name = coe w
  method configure = configure ?w
  method bind = bind w
  method redisplay = post_redisplay t
  method swap_buffers = swap_buffers t
  method ident = ident t
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
    tkEval [|TkToken (Widget.name w); TkToken "makecurrent"|]
end

let ready = ref false

let create :parent ?:name =
  togl_options_optionals
    ?(fun options ->
      if not !ready then (init (); ready := true);
      let w : w Widget.widget =
	Widget.new_atom class:"togl" :parent ?:name in
      let togl = ref None in
      callback_table.(create_id) <-
	 (fun t -> togl := Some t; Hashtbl.add togl_table key:w data:t);
      _create_func ();
      tkEval [|TkToken "togl"; TkToken (Widget.name w); TkTokenList options|];
      match !togl with None -> raise (TkError "Togl widget creation failed")
      |	Some t -> new widget w t)
