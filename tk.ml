(* $Id: tk.ml,v 1.1 1998-01-09 09:11:40 garrigue Exp $ *)

exception TKerror of string

external _init_display : unit -> bool = "ml_tkInitDisplay"
let init_display () =
  if _init_display () then ()
  else raise (TKerror "init_display")

type display_mode = [
      rgb
      rgba
      index
      single
      direct
      indirect
      double
      depth
      accum
      stencil
  ]

external init_display_mode : display_mode list -> unit
    = "ml_tkInitDisplayMode"

type display_policy = [use_id exact_match minimum_criteria]

external init_display_mode_policy : display_policy -> unit
    = "ml_tkInitDisplayModePolicy"

external _init_display_mode_id : int -> bool =
  "ml_tkInitDisplayModeID"
let init_display_mode_id id =
  if _init_display_mode_id id then ()
  else raise (TKerror "init_display_mode_id")

external init_position : x:int -> y:int -> w:int -> h:int -> unit
    = "ml_tkInitPosition"

external _init_window : string -> bool = "ml_tkInitWindow"
let init_window :title =
  if _init_window title then ()
  else raise (TKerror "init_window")

external close_window : unit -> unit = "ml_tkCloseWindow"
external quit : unit -> unit = "ml_tkQuit"

external _set_window_level : display_mode -> bool = "ml_tkSetWindowLevel"
let set_window_level mode =
  if _set_window_level mode then ()
  else raise (TKerror "set_window_level")

external swap_buffers : unit -> unit = "ml_tkSwapBuffers"

external exec : unit -> unit = "ml_tkExec"

let register_func :name :init :call =
  let func_ref = ref init in
  Callback.register name func_ref;
  fun f -> func_ref := f; call ()

let wh_func w:(_ : int) h:(_ : int) = ()

external _expose_func : unit -> unit = "ml_tkExposeFunc"
let expose_func =
  register_func name:"expose_func" init:wh_func call:_expose_func

external _reshape_func : unit -> unit = "ml_tkReshapeFunc"
let reshape_func =
  register_func name:"reshape_func" init:wh_func call:_reshape_func

let null_func () = ()

external _display_func : unit -> unit = "ml_tkDisplayFunc"
let display_func =
  register_func name:"display_func" init:null_func call:_display_func

type key_desc = [
    return
    escape
    space
    left
    up
    right
    down
    char(char)
  ]

type key_mode = [shift control]

external _key_down_func : unit -> unit = "ml_tkKeyDownFunc"
let key_down_func =
  register_func name:"key_down_func" call:_key_down_func 
    init:(fun key:(_ : key_desc) mode:(_ : key_mode) -> ())

type button = [left middle right]

let mouse_func x:(_ : int) y:(_ : int) (_ : button list) = ()

external _mouse_down_func : unit -> unit = "ml_tkMouseDownFunc"
let mouse_down_func =
  register_func name:"mouse_down_func" init:mouse_func call:_mouse_down_func

external _mouse_up_func : unit -> unit = "ml_tkMouseUpFunc"
let mouse_up_func =
  register_func name:"mouse_up_func" init:mouse_func call:_mouse_up_func

external _mouse_move_func : unit -> unit = "ml_tkMouseMoveFunc"
let mouse_move_func =
  register_func name:"mouse_move_func" init:mouse_func call:_mouse_move_func

external _idle_func : unit -> unit = "ml_tkIdleFunc"
let idle_func =
  register_func name:"idle_func" init:null_func call:_idle_func

external get_color_map_size : unit -> int = "ml_tkGetColorMapSize"
external get_mouse_loc : unit -> int * int = "ml_tkGetMouseLoc"

type sys_info = [
      x_display
      x_window
      x_screen
      context
  ] 

(* external get_system : sys_info -> various *)

external get_display_mode_policy : unit -> display_policy
    = "ml_tkGetDisplayModePolicy"
external get_display_mode_id : unit -> int
    = "ml_tkGetDisplayModeID"
external get_display_mode : unit -> display_mode
    = "ml_tkGetDisplayMode"

external set_one_color :
    int -> red:float -> green:float -> blue:float -> unit
    = "ml_tkSetOneColor"
external set_fog_ramp : density:int -> start:int -> unit
    = "ml_tkSetFogRamp"
external set_grey_ramp : unit -> unit = "ml_tkSetGreyRamp"
external set_rgb_map : (float * float * float) array -> unit
    = "ml_tkSetRGBMap"
external set_overlay_map : (float * float * float) array -> unit
    = "ml_tkSetOverlayMap"

external _new_cursor :
    id:int -> shape:string -> mask:string ->
    fg:int -> bg:int -> hotx:int -> hoty:int -> unit
    = "ml_tkNewCursor"
let new_cursor :id :shape :mask :fg :bg :hotx :hoty =
  if String.length shape <> 32 then raise (TKerror "new_cursor : bad shape");
  if String.length mask <> 32  then raise (TKerror "new_cursor : bad mask");
  _new_cursor :id :shape :mask :fg :bg :hotx :hoty

external set_cursor : id:int -> unit = "ml_tkSetCursor"

external wire_sphere : radius:float -> unit = "ml_tkWireSphere"
external solid_sphere : radius:float -> unit = "ml_tkSolidSphere"

external wire_cube : size:float -> unit = "ml_tkWireCube"
external solid_cube : size:float -> unit = "ml_tkSolidCube"

external wire_box : width:float -> height:float -> depth:float -> unit
    = "ml_tkWireBox"
external solid_box : width:float -> height:float -> depth:float -> unit
    = "ml_tkSolidBox"

external wire_torus : inner:float -> outer:float -> unit
    = "ml_tkWireTorus"
external solid_torus : inner:float -> outer:float -> unit
    = "ml_tkSolidTorus"

external wire_cylinder : radius:float -> height:float -> unit
    = "ml_tkWireCylinder"
external solid_cylinder : radius:float -> height:float -> unit
    = "ml_tkSolidCylinder"

external wire_cone : radius:float -> height:float -> unit
    = "ml_tkWireCone"
external solid_cone : radius:float -> height:float -> unit
    = "ml_tkSolidCone"
