(* $Id: aux.ml,v 1.5 1998-01-09 13:12:31 garrigue Exp $ *)

let init_window = Tk.init_window

let init_display_mode = Tk.init_display_mode

let init_position = Tk.init_position

let reshape_func f =
  Tk.expose_func f;
  Tk.reshape_func f

let set_one_color = Tk.set_one_color

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
  Tk.display_func display;
  Tk.exec ()
