(* $Id: texturesurf.ml,v 1.1 1998-01-21 03:29:33 garrigue Exp $ *)

let ctrlpoints =
  [|[|-1.5; -1.5; 4.9;  -0.5; -1.5; 2.0;  0.5; -1.5; -1.0;  1.5; -1.5; 2.0|];
    [|-1.5; -0.5; 1.0;  -0.5; -0.5; 3.0;  0.5; -0.5; 0.0;   1.5; -0.5; -1.0|];
    [|-1.5; 0.5; 4.0;   -0.5; 0.5; 0.0;   0.5; 0.5; 3.0;    1.5; 0.5; 4.0|];
    [|-1.5; 1.5; -2.0;  -0.5; 1.5; -2.0;  0.5; 1.5; 0.0;    1.5; 1.5; -1.0|]|]

let texpts =
  [|[|0.0; 0.0;  0.0; 1.0|];
    [|1.0; 0.0;  1.0; 1.0|]|]

let display () =
  Gl.clear [`color;`depth];
  Gl.color (1.0,1.0,1.0);
  Gl.eval_mesh2 mode:`fill 0 20 0 20;
  Gl.flush ()

let image_width = 64
and image_height = 64

let pi = acos (-1.0)

let make_image () =
  let image = Raw.create `ubyte len:(3*image_height*image_width) in
  for i = 0 to image_width - 1 do
    let ti = 2.0 *. pi *. float i /. float image_width in
    for j = 0 to image_height - 1 do
      let tj = 2.0 *. pi *. float j /. float image_height in
      Raw.write image pos:(3*(image_height*i+j))
	src:(Array.map fun:(fun x -> truncate (127.0 *. (1.0 +. x)))
	       [|sin ti; cos (2.0 *. ti); cos (ti +. tj)|]);
      done;
  done;
  image

let myinit () =
  (*
  let rawctrl = Raw.create `float len:(4*4*3) in
  Array.iteri ctrlpoints fun:
    begin fun :i :data ->
      Array.iteri data fun:
	begin fun i:j data:(r,g,b) ->
	  Raw.write_float rawctrl pos:(3*(4*i+j)) src:[|r;g;b|]
	end
    end;
  *)
  Gl.map2 target:`vertex_3 (0.0, 1.0) (0.0, 1.0) ctrlpoints;
  Gl.map2 target:`texture_coord_2 (0.0,1.0) (0.0,1.0) texpts;
  Gl.enable `map2_texture_coord_2;
  Gl.enable `map2_vertex_3;
  Gl.map_grid2 n:20 range:(0.0,1.0) n:20 range:(0.0,1.0);
  let image = make_image () in
  Gl.tex_env (`mode `decal);
  List.iter fun:(Gl.tex_parameter target:`texture_2d)
    [ `wrap_s `repeat;
      `wrap_t `repeat;
      `mag_filter `nearest;
      `min_filter `nearest ];
  Gl.tex_image2d image proxy:false  level:0 internal:3 width:image_width
    height:image_height border:false format:`rgb;
  List.iter fun:Gl.enable [`texture_2d;`depth_test;`normalize];
  Gl.shade_model `flat

let my_reshape togl =
  let h = Togl.height togl and w = Togl.width togl in
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  let r = float h /. float w in
  if w <= h then
    Gl.ortho left:(-4.0) right:4.0 bottom:(-4.0 *. r)
      top:(4.0 *. r) near:(-4.0) far:(4.0)
  else
    Gl.ortho left:(-4.0 /. r) right:(4.0 /. r) bottom:(-4.0)
      top:(4.0) near:(-4.0) far:(4.0);
  Gl.matrix_mode `modelview;
  Gl.load_identity ();
  Gl.rotate angle:(85.0) x:1.0 y:1.0 z:1.0

open Tk

let main () =
  let top = openTk () in
  let togl =
    Togl.create parent:top rgba:true depth:true width:300 height:300
  in
  Wm.title_set top title:"Texture Surf";
  myinit ();
  Togl.reshape_func togl cb:(fun () -> my_reshape togl);
  Togl.display_func togl cb:display;
  pack [togl] expand:true fill:`Both;
  mainLoop ()

let _ = main ()
