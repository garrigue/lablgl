(* $Id: aux.ml,v 1.4 1998-01-09 09:11:37 garrigue Exp $ *)

let null_func () = ()

external init_window : title:string -> unit = "ml_auxInitWindow"

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
    = "ml_auxInitDisplayMode"

external init_position : x:int -> y:int -> w:int -> h:int -> unit
    = "ml_auxInitPosition"

let reshape_func_ref = ref (fun :w :h -> ())
let _ =  Callback.register "reshape_func" reshape_func_ref
external auxReshapeFunc : unit -> unit = "ml_auxReshapeFunc"

let reshape_func (f : w:int -> h:int -> unit) =
  reshape_func_ref := f; auxReshapeFunc ()

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

let key_func_ref = ref null_func
let _ =  Callback.register "key_func" key_func_ref
external auxKeyFunc : key_desc -> unit = "ml_auxKeyFunc"

let key_func :key fun:(f : unit -> unit) =
  key_func_ref := f;
  auxKeyFunc key

let mouse_func_ref = ref (fun :x :y -> ())
let _ =  Callback.register "mouse_func" mouse_func_ref
external auxMouseFunc :
    button:[left middle right] -> mode:[up down] -> unit
    = "ml_auxMouseFunc"

let mouse_func :button :mode fun:(f : x:int -> y:int -> unit) =
  mouse_func_ref := f;
  auxMouseFunc :button :mode

external set_one_color :
    index:int -> red:float -> green:float -> blue:float -> unit
    = "ml_auxSetOneColor"

external wire_sphere : radius:float -> unit = "ml_auxWireSphere"
external solid_sphere : radius:float -> unit = "ml_auxSolidSphere"

external wire_cube : size:float -> unit = "ml_auxWireCube"
external solid_cube : size:float -> unit = "ml_auxSolidCube"

external wire_box : width:float -> height:float -> depth:float -> unit
    = "ml_auxWireBox"
external solid_box : width:float -> height:float -> depth:float -> unit
    = "ml_auxSolidBox"

external wire_torus : inner:float -> outer:float -> unit
    = "ml_auxWireTorus"
external solid_torus : inner:float -> outer:float -> unit
    = "ml_auxSolidTorus"

external wire_cylinder : radius:float -> height:float -> unit
    = "ml_auxWireCylinder"
external solid_cylinder : radius:float -> height:float -> unit
    = "ml_auxSolidCylinder"

external wire_icosahedron : radius:float -> unit = "ml_auxWireIcosahedron"
external solid_icosahedron : radius:float -> unit = "ml_auxSolidIcosahedron"

external wire_octahedron : radius:float -> unit = "ml_auxWireOctahedron"
external solid_octahedron : radius:float -> unit = "ml_auxSolidOctahedron"

external wire_tetrahedron : radius:float -> unit = "ml_auxWireTetrahedron"
external solid_tetrahedron : radius:float -> unit = "ml_auxSolidTetrahedron"

external wire_dodecahedron : radius:float -> unit = "ml_auxWireDodecahedron"
external solid_dodecahedron : radius:float -> unit = "ml_auxSolidDodecahedron"

external wire_cone : radius:float -> height:float -> unit
    = "ml_auxWireCone"
external solid_cone : radius:float -> height:float -> unit
    = "ml_auxSolidCone"

external wire_teapot : size:float -> unit = "ml_auxWireTeapot"
external solid_teapot : size:float -> unit = "ml_auxSolidTeapot"

let idle_func_ref = ref null_func
let _ =  Callback.register "idle_func" idle_func_ref
external auxIdleFunc : bool -> unit = "ml_auxIdleFunc"

let idle_func = function
    None -> auxIdleFunc false; idle_func_ref := null_func
  | Some f -> idle_func_ref := f; auxIdleFunc true

let display_func_ref = ref null_func
let _ =  Callback.register "display_func" display_func_ref
external auxMainLoop : unit -> unit = "ml_auxMainLoop"

let main_loop :display =
  display_func_ref := display;
  auxMainLoop ()
