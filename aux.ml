(* $Id: aux.ml,v 1.6 1998-01-12 05:20:01 garrigue Exp $ *)

let init_window = Gltk.init_window

let init_display_mode = Gltk.init_display_mode

let init_position = Gltk.init_position

let reshape_func f =
  Gltk.expose_func f;
  Gltk.reshape_func f

let set_one_color = Gltk.set_one_color

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

let main_loop :display =
  Gltk.display_func display;
  Gltk.exec ()

let _mouse_up_funcs = ref []
and _mouse_down_funcs = ref []

let _mouse_func :funcs :x :y buttons =
  let changed = ref false in
  List.iter buttons fun:
    begin fun button ->
      try List.assoc button in:funcs :x :y ; changed := true
      with Not_found -> ()
    end;
  if not !changed then Gltk.no_changes ()

let push x on:stack = stack := x :: !stack

let mouse_func :button :mode fun:f =
  if (mode : [up down]) = `up then begin
    push (button,f) on:_mouse_up_funcs;
    Gltk.mouse_up_func (_mouse_func funcs:!_mouse_up_funcs)
  end else begin
    push (button,f) on:_mouse_down_funcs;
    Gltk.mouse_down_func (_mouse_func funcs:!_mouse_down_funcs)
  end

let _key_funcs = ref []

let _key_func :key :mode =
  let changed = ref false in
  begin try
    List.assoc key in:!_key_funcs ();
    changed := true
  with Not_found -> ()
  end;
  if not !changed then Gltk.no_changes ()
 

let key_func :key fun:f =
  push (key,f) on:_key_funcs;
  Gltk.key_down_func _key_func
