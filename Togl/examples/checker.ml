(* $Id: checker.ml,v 1.2 1998-01-23 13:30:16 garrigue Exp $ *)

let image_height = 64
and image_width = 64

let make_image () =
  let image = Raw.create `ubyte len:(image_height*image_width*3) in
  for i = 0 to image_width - 1 do
    for j = 0 to image_height - 1 do
      Raw.sets image pos:(3*(i*image_height+j))
	(if (i land 8 ) lxor (j land 8) = 0
	 then [|255;255;255|]
	 else [|0;0;0|])
    done
  done;
  { Gl.width = image_width;
    Gl.height = image_height;
    Gl.format = `rgb;
    Gl.raw = image }

let myinit () =
  Gl.clear_color (0.0, 0.0, 0.0);
  Gl.enable `depth_test;
  Gl.depth_func `less;

  let image = make_image () in
  Gl.pixel_store (`unpack_alignment 1);
  Gl.tex_image2d image;
  List.iter fun:(Gl.tex_parameter target:`texture_2d)
    [ `wrap_s `clamp;
      `wrap_t `clamp;
      `mag_filter `nearest;
      `min_filter `nearest ];
  Gl.tex_env (`mode `decal);
  Gl.enable `texture_2d;
  Gl.shade_model `flat

let display () =
  Gl.clear [`color;`depth];
  Gl.begin_block `quads;
  Gl.tex_coord2(0.0, 0.0); Gl.vertex3(-2.0, -1.0, 0.0);
  Gl.tex_coord2(0.0, 1.0); Gl.vertex3(-2.0, 1.0, 0.0);
  Gl.tex_coord2(1.0, 1.0); Gl.vertex3(0.0, 1.0, 0.0);
  Gl.tex_coord2(1.0, 0.0); Gl.vertex3(0.0, -1.0, 0.0);
  
  Gl.tex_coord2(0.0, 0.0); Gl.vertex3(1.0, -1.0, 0.0);
  Gl.tex_coord2(0.0, 1.0); Gl.vertex3(1.0, 1.0, 0.0);
  Gl.tex_coord2(1.0, 1.0); Gl.vertex3(2.41421, 1.0, -1.41421);
  Gl.tex_coord2(1.0, 0.0); Gl.vertex3(2.41421, -1.0, -1.41421);
  Gl.end_block ();
  Gl.flush ()

let reshape togl =
  let w = Togl.width togl and h = Togl.height togl in
  Gl.viewport x:0 y:0 :w :h;
  Gl.matrix_mode `projection;
  Gl.load_identity ();
  Glu.perspective fovy:60.0 aspect:(1.0 *. float w /. float h) z:(1.0,30.0);
  Gl.matrix_mode `modelview;
  Gl.load_identity ();
  Gl.translate z:(-3.6)

open Tk

let main () =
  let top = openTk () in
  let togl =
    Togl.create parent:top width:500 height:500 rgba:true depth:true in
  myinit ();
  Togl.display_func togl cb:display;
  Togl.reshape_func togl cb:(fun () -> reshape togl);
  pack [togl] expand:true fill:`Both;
  mainLoop ()

let _ = main ()
