(* $Id: texturesurf.ml,v 1.12 2000-04-16 12:35:35 garrigue Exp $ *)

let texpts =
  [|[|0.0; 0.0;  0.0; 1.0|];
    [|1.0; 0.0;  1.0; 1.0|]|]

let ctrlpoints =
  [|[|-1.5; -1.5; 4.9;  -0.5; -1.5; 2.0;  0.5; -1.5; -1.0; 1.5; -1.5; 2.0|];
    [|-1.5; -0.5; 1.0;  -0.5; -0.5; 3.0;  0.5; -0.5; 0.0;  1.5; -0.5; -1.0|];
    [|-1.5; 0.5; 4.0;   -0.5; 0.5; 0.0;   0.5; 0.5; 3.0;   1.5; 0.5; 4.0|];
    [|-1.5; 1.5; -2.0;  -0.5; 1.5; -2.0;  0.5; 1.5; 0.0;   1.5; 1.5; -1.0|]|]

let image_width = 64
and image_height = 64

let pi = acos (-1.0)

let display togl =
  GlClear.clear [`color;`depth];
  GlDraw.color (1.0,1.0,1.0);
  GlMap.eval_mesh2 ~mode:`fill ~range1:(0,20) ~range2:(0,20);
  Gl.flush ();
  Togl.swap_buffers togl

let make_image () =
  let image =
    GlPix.create `ubyte ~height:image_height ~width:image_width ~format:`rgb in
  let raw = GlPix.to_raw image
  and pos = GlPix.raw_pos image in
  for i = 0 to image_width - 1 do
    let ti = 2.0 *. pi *. float i /. float image_width in
    for j = 0 to image_height - 1 do
      let tj = 2.0 *. pi *. float j /. float image_height in
      Raw.sets raw ~pos:(pos ~x:j ~y:i)
	(Array.map ~f:(fun x -> truncate (127.0 *. (1.0 +. x)))
	   [|sin ti; cos (2.0 *. ti); cos (ti +. tj)|]);
      done;
  done;
  image

let myinit () =
  let ctrlpoints = Raw.of_matrix ~kind:`double ctrlpoints
  and texpts = Raw.of_matrix ~kind:`double texpts in
  GlMap.map2 ~target:`vertex_3
    (0.0, 1.0) ~order:4 (0.0, 1.0) ~order:4 ctrlpoints;
  GlMap.map2 ~target:`texture_coord_2
    (0.0,1.0) ~order:2 (0.0,1.0) ~order:2 texpts;
  Gl.enable `map2_texture_coord_2;
  Gl.enable `map2_vertex_3;
  GlMap.grid2 ~n1:20 ~range1:(0.0,1.0) ~n2:20 ~range2:(0.0,1.0);
  let image = make_image () in
  GlTex.env (`mode `decal);
  List.iter ~f:(GlTex.parameter ~target:`texture_2d)
    [ `wrap_s `repeat;
      `wrap_t `repeat;
      `mag_filter `nearest;
      `min_filter `nearest ];
  GlTex.image2d image;
  List.iter ~f:Gl.enable [`texture_2d;`depth_test;`normalize];
  GlDraw.shade_model `flat

let my_reshape togl =
  let h = Togl.height togl and w = Togl.width togl in
  GlDraw.viewport ~x:0 ~y:0 ~w ~h;
  GlMat.mode `projection;
  GlMat.load_identity ();
  let r = float h /. float w in
  if w <= h then
    GlMat.ortho ~x:(-4.0, 4.0) ~y:(-4.0 *. r, 4.0 *. r) ~z:(-4.0, 4.0)
  else
    GlMat.ortho ~x:(-4.0 /. r, 4.0 /. r) ~y:(-4.0, 4.0) ~z:(-4.0, 4.0);
  GlMat.mode `modelview;
  GlMat.load_identity ();
  GlMat.rotate ~angle:85. ~x:1. ~y:1. ~z:1. ()

open Tk

let main () =
  let top = openTk () in
  let togl =
    Togl.create top ~rgba:true ~depth:true ~width:300 ~height:300 ~double:true
  in
  Wm.title_set top "Texture Surf";
  myinit ();
  Togl.reshape_func togl ~cb:(fun () -> my_reshape togl);
  Togl.display_func togl ~cb:(fun () -> display togl);
  bind top ~events:[`KeyPress] ~fields:[`KeySymString]
    ~action:(fun ev ->
      match ev.ev_KeySymString with
	"Up" -> GlMat.rotate ~angle:(-5.) ~z:1.0 (); display togl
      |	"Down" -> GlMat.rotate ~angle:(5.) ~z:1.0 (); display togl
      |	"Left" -> GlMat.rotate ~angle:(5.) ~x:1.0 (); display togl
      |	"Right" -> GlMat.rotate ~angle:(-5.) ~x:1.0 (); display togl
      |	"Escape" -> destroy top; exit 0
      |	_ -> ());
  pack [togl] ~expand:true ~fill:`Both;
  mainLoop ()

let _ = main ()
