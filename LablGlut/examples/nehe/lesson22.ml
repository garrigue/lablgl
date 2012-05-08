(*
 * lesson 22 of Nehe OpenGL tutorial
 * demonstrating the use of multitexturing
 *
 *)

open GlDraw

(* Maximum Emboss-Translate. Increase To Get Higher Immersion *)
let max_emboss = 0.01

let use_multitexture = ref true           (* Do we use multitexture ? *)
let multitexture_supported = ref false    (* is multitexture available ? *)

let max_texel_units = ref 1

(* Position Is Somewhat In Front Of Screen *)

let light_position = ( 0.0, 0.0, 2.0, 1.0)
let light_ambient  = ( 0.2, 0.2, 0.2, 1.0)
let light_diffuse  = ( 1.0, 1.0, 1.0, 1.0)

(* fake bumpmapping color *)
let gray = (0.5, 0.5, 0.5, 1.0) 


open GlTex

type tex_data = {
  ids        : texture_id array;
  bumps      : texture_id array;
  invs       : texture_id array;
  logo       : texture_id;
  multi_logo : texture_id;
}

let data = [|
   (* front face *)
   0.0; 1.0;    -1.0; -1.0;  1.0; (* 1 *)
   1.0; 1.0;     1.0; -1.0;  1.0; (* 2 *)
   1.0; 0.0;     1.0;  1.0;  1.0; (* 3 *)
   0.0; 0.0;    -1.0;  1.0;  1.0; (* 4 *)
   (* back face *)
   0.0; 1.0;     1.0; -1.0; -1.0; (* 5 *)
   1.0; 1.0;    -1.0; -1.0; -1.0; (* 6 *)
   1.0; 0.0;    -1.0;  1.0; -1.0; (* 7 *)
   0.0; 0.0;     1.0;  1.0; -1.0; (* 8 *) 
   (* top face *)
   0.0; 1.0;    -1.0;  1.0;  1.0; (* 4 *)
   1.0; 1.0;     1.0;  1.0;  1.0; (* 3 *)
   1.0; 0.0;     1.0;  1.0; -1.0; (* 8 *)
   0.0; 0.0;    -1.0;  1.0; -1.0; (* 7 *)
   (* bottom face *)
   0.0; 1.0;     1.0; -1.0;  1.0; (* 2 *)
   1.0; 1.0;    -1.0; -1.0;  1.0; (* 1 *)
   1.0; 0.0;    -1.0; -1.0; -1.0; (* 6 *)
   0.0; 0.0;     1.0; -1.0; -1.0; (* 5 *)
   (* right face *)
   0.0; 1.0;     1.0; -1.0;  1.0; (* 2 *)
   1.0; 1.0;     1.0; -1.0; -1.0; (* 5 *)
   1.0; 0.0;     1.0;  1.0; -1.0; (* 8 *)
   0.0; 0.0;     1.0;  1.0;  1.0; (* 3 *)
   (* left face *)
   0.0; 1.0;    -1.0; -1.0; -1.0; (* 6 *)
   1.0; 1.0;    -1.0; -1.0;  1.0; (* 1 *)
   1.0; 0.0;    -1.0;  1.0;  1.0; (* 4 *)
   0.0; 0.0;    -1.0;  1.0; -1.0  (* 7 *)
	   |]

let xspeed = ref 0.                       (* X Rotation Speed             *)
let yspeed = ref 0.                       (* Y Rotation Speed             *)
let z      = ref (-5.0)                   (* Depth Into The Screen        *)
let emboss = ref false                    (* Emboss Only, No Basetexture? *)
let bumps  = ref true                     (* Do Bumpmapping?              *)
let filter = ref 1                        (* Which Filter To Use          *)

let rot = [| 0. ; 0. ; 0. |]

let init_multitexture () = 
  multitexture_supported := GlMisc.check_extension "GL_ARB_multitexture";
  max_texel_units := GlState.get_int `max_texture_units;
  prerr_endline ("number of texture units : "^string_of_int !max_texel_units)


let init_lights () =
  (* Load Light-Parameters into GL_LIGHT1 *)
  GlLight.light ~num:1 (`ambient light_ambient);
  GlLight.light ~num:1 (`diffuse light_diffuse);
  GlLight.light ~num:1 (`position light_position);
  Gl.enable `light1

(*
open Sdlvideo

let sdl_load_file filename =
  let s = load_BMP filename in
  let w,h,_ = surface_dims s in
  s,w,h

let pix_of_sdlsurface (img : surface) =
  let width, height,_ = surface_dims img in
  let pix = GlPix.create `ubyte ~format:`rgb ~width ~height in
  let format = GlPix.format pix in
    let raw = GlPix.to_raw pix in
  for y = 0 to height - 1 do
  for x = 0 to width - 1 do
	let r,g,b = Sdlvideo.get_pixel_color img x y in
	Raw.sets raw ~pos:(3*(y*width+x)) [| r; g; b |];
      done
    done;
    GlPix.of_raw raw ~format ~width ~height

let load_file = sdl_load_file
let pix_of_img = pix_of_sdlsurface
*)

open Images
open Rgb24

let camlimg_load_file filename = 
  let img = 
    match Images.load filename [] with
	Index8 v  -> Index8.to_rgb24 v
      | Rgb24 v   -> v
      | Index16 v -> Index16.to_rgb24 v
      | Rgba32 v  -> Rgb24.of_rgba32 v
      | Cmyk32 v  -> raise (Invalid_argument "unhandled image type (cmyk)")
  in
  img, img.width, img.height

let pix_of_camlimg img = 
    let width,height = img.width, img.height in
    let raw = Raw.create `ubyte ~len:(3*width*height) in
    for y = 0 to height - 1 do
      for x = 0 to width - 1 do
	let pixel = Rgb24.get img x y in (* pixel is a Color.rgb *)
	Raw.sets raw ~pos:(3*(y*width+x)) [| pixel.r; pixel.g; pixel.b |];
      done
    done;
    GlPix.of_raw raw ~format:`rgb ~width ~height

let load_file = camlimg_load_file
let pix_of_img = pix_of_camlimg

let load_gl_textures () =
  let setup_imgs pix ids = 
    GlTex.bind_texture ~target:`texture_2d ids.(0);
    List.iter (GlTex.parameter ~target:`texture_2d)
      [ `mag_filter `nearest;
	`min_filter `nearest ];
    GlTex.image2d pix;
    GlTex.bind_texture ~target:`texture_2d ids.(1);
    List.iter (GlTex.parameter ~target:`texture_2d)
      [ `mag_filter `linear;
	`min_filter `linear ];
    GlTex.image2d pix;
    GlTex.bind_texture ~target:`texture_2d ids.(2);
    List.iter (GlTex.parameter ~target:`texture_2d)
      [ `mag_filter `linear;
	`min_filter `linear_mipmap_linear ];
    GlTex.image2d pix;
    GluMisc.build_2d_mipmaps pix
  in
  let load_imgs filename = 
    Gl.enable `texture_2d;
    let img,w,h = load_file filename in
    let pix = pix_of_img img in
    let texids = GlTex.gen_textures ~len:3 in
    setup_imgs pix texids;
    texids
  and load_bumps filename =
    Gl.enable `texture_2d;
    let img,w,h = load_file filename in
    let pix = pix_of_img img in
    let bumpids = GlTex.gen_textures ~len:3 
    and invbumpids = GlTex.gen_textures ~len:3 in
    GlPix.transfer (`red_scale 0.5);           (* Scale RGB By 50%, So That We *)
    GlPix.transfer (`green_scale 0.5);         (* Have Only Half Intensity     *)
    GlPix.transfer (`blue_scale 0.5);
    (* No Wrapping, Please! *)
    List.iter (GlTex.parameter ~target:`texture_2d)
      [  `wrap_s `clamp;
	 `wrap_t `clamp;
	 `border_color gray ];
    setup_imgs pix bumpids;
    let raw = GlPix.to_raw pix in
    (* Invert The Bumpmap *)
    for i = 0 to pred (Raw.length raw) do
      let c = Raw.get raw ~pos:i in
      Raw.set raw ~pos:i (255 - c)
    done;
    let format, width, height = GlPix.format pix, GlPix.width pix, GlPix.height pix in
    setup_imgs (GlPix.of_raw raw ~format ~width ~height) invbumpids;
    GlPix.transfer (`red_scale 1.0);           (* Reset color scales *)
    GlPix.transfer (`green_scale 1.0);
    GlPix.transfer (`blue_scale 1.0);
    bumpids, invbumpids
  in
  let load_logo fname_alpha fname = 
    (* Load The Logo-Bitmaps *)
    let img,w,h = load_file fname_alpha in
    let pix = pix_of_img img in
    let format, width, height = `rgba, w, h in
    let raw = GlPix.to_raw pix in
    (* Create Memory For RGBA8-Texture *)
    let alpha = Raw.create `ubyte (4 * w * h) in
    for a = 0 to pred (w * h) do
      Raw.set alpha (4*a+3) (Raw.get raw (a*3)) (* Pick Only Red Value As Alpha! *)
    done;
    let img,w,h = load_file fname in
    let pix = pix_of_img img in
    let raw = GlPix.to_raw pix in
    for a = 0 to pred (w * h) do
      Raw.sets alpha (4*a) (Raw.gets raw ~pos:(a*3) ~len:3)
    done;
    let logo = GlTex.gen_texture () in
    (* Create Linear Filtered RGBA8-Texture *)
    GlTex.bind_texture ~target:`texture_2d logo;
    List.iter (fun x -> GlTex.parameter ~target:`texture_2d x)
      [ `mag_filter `linear;
	`min_filter `linear ];
    GlTex.image2d (GlPix.of_raw alpha ~format ~width ~height);
    logo
  in
  (*  GlPix.store (`unpack_alignment 1); *)
  let logo = load_logo "Data/opengl_alpha.bmp" "Data/opengl.bmp"
  (* Load The "Extension Enabled"-Logo *)
  and multi_logo = load_logo "Data/multi_on_alpha.bmp" "Data/multi_on.bmp"
  and ids = load_imgs "Data/Base.bmp"
  and bumps1, invs1 = load_bumps "Data/Bump.bmp" in
  { ids = ids; bumps = bumps1; invs = invs1; logo = logo; multi_logo = multi_logo }


let init_gl width height =
  init_multitexture ();
  shade_model `smooth;
  GlClear.color ~alpha:0.0 (0.0, 0.0, 0.0);
  GlClear.depth 1.0;
  GlClear.clear [`color; `depth];
  Gl.enable `depth_test;
  Gl.enable `cull_face;
  GlDraw.cull_face `back;
  GlDraw.front_face `ccw;
  GlFunc.depth_func `lequal;
  GlMisc.hint `perspective_correction `nicest;
  init_lights ();
  load_gl_textures ()


let do_cube () =
  let do_face k n =
    normal3 n;
    for i = k to k+3 do
      GlTex.coord2 (data.(5*i),data.(5*i+1));
      vertex3 (data.(5*i+2),data.(5*i+3),data.(5*i+4));
    done
  in
  begins `quads;
  (* Front Face *)
  do_face 0 ( 0.0, 0.0, 1.0);
  (* Back Face *)
  do_face 4 ( 0.0, 0.0,-1.0);
  (* Top Face *)
  do_face 8 ( 0.0, 1.0, 0.0);
  (* Bottom Face *)
  do_face 12 ( 0.0,-1.0, 0.0);
  (* Right Face *)
  do_face 16 ( 1.0, 0.0, 0.0);
  (* Left Face *)
  do_face 20 (-1.0, 0.0, 0.0);
  ends ()

(* some useful vector functions --- *)
let dot v1 v2 =
  v1.(0) *. v2.(0) +. v1.(1) *. v2.(1) +. v1.(2) *. v2.(2) 

let add v1 v2 =
  [| v1.(0) +. v2.(0) ; v1.(1) +. v2.(1) ; v1.(2) +. v2.(2) |]

let sub v1 v2 =
  [| v1.(0) -. v2.(0) ; v1.(1) -. v2.(1) ; v1.(2) -. v2.(2) |]

let normalize v = 
  let l = sqrt (dot v v) in
  let il = 1. /. l in
  Array.map (fun x -> x *. il) v

(* -------------------------------- *)

(* Calculates v=vM, M Is 4x4 In Column-Major, v Is 4dim. Row (i.e. "Transposed") *)
let vmat_mult m (x,y,z,w) = 
  let dot v1 = 
    v1.(0) *. x +. v1.(1) *. y +. v1.(2) *. z  +. v1.(3) *. w
  in
    [| dot m.(0); dot m.(1); dot m.(2) ; m.(3).(3) |]

(* compute the vector surface vertex to light source *)
let inv_ray l c =
  normalize (sub l c)

(* Sets Up The Texture-Offsets
 * r : direction vector from Current Vertex On Surface to Lightposition
 * s : Direction Of s-Texture-Coordinate In Object Space (Must Be Normalized!)
 * t : Direction Of t-Texture-Coordinate In Object Space (Must Be Normalized!)
 **)
let setup_bumps r s t =
  [| max_emboss *. (dot s r) ; max_emboss *. (dot t r) |]

(* compute the diffuse coefficient of inverse light ray r with normal n *)
let diffuse_coef r n =
  dot r n


let do_logo tex =
  let coord2 = GlTex.coord2 in
  (* MUST CALL THIS LAST!!!, Billboards The Two Logos *)
  GlFunc.depth_func `always;
  GlFunc.blend_func ~src:`src_alpha ~dst:`one_minus_src_alpha;
  Gl.enable `blend;
  Gl.disable `lighting;
  Gl.enable `texture_2d;
  GlMat.load_identity ();
  GlTex.bind_texture ~target:`texture_2d tex.logo;
  GlDraw.begins `quads;
  coord2 (0.0,1.0); vertex3 (0.23, -0.35, -1.0);
  coord2 (1.0,1.0); vertex3 (0.53, -0.35, -1.0);
  coord2 (1.0,0.0); vertex3 (0.53, -0.25, -1.0);
  coord2 (0.0,0.0); vertex3 (0.23, -0.25, -1.0);
  GlDraw.ends ();
  if !use_multitexture then (
    GlTex.bind_texture ~target:`texture_2d tex.multi_logo;
    GlDraw.begins `quads;
    coord2 (0.0,1.0); vertex3 (-0.53, -0.20, -1.0);
    coord2 (1.0,1.0); vertex3 (-0.33, -0.20, -1.0);
    coord2 (1.0,0.0); vertex3 (-0.33, -0.15, -1.0);
    coord2 (0.0,0.0); vertex3 (-0.53, -0.15, -1.0);
    GlDraw.ends ()
  )

let setup_inv_modelview () =
  (* Simply Build It By Doing All Transformations Negated And In Reverse Order *)
  GlMat.load_identity ();
  GlMat.rotate3 ~angle:(-.rot.(1)) (0.0,1.0,0.0);
  GlMat.rotate3 ~angle:(-.rot.(0)) (1.0,0.0,0.0);
  GlMat.translate3 (0.0,0.0, -.(!z))

let setup_modelview () =
  GlMat.load_identity ();
  GlMat.translate3 (0.0,0.0,!z);
  GlMat.rotate3 ~angle:(rot.(0)) (1.0,0.0,0.0);
  GlMat.rotate3 ~angle:(rot.(1)) (0.0,1.0,0.0)

let do_cube_bump do_face =
  GlDraw.begins `quads;
  (* Front Face *)
  let n = [|  0.;  0.;  1. |]
  and s = [|  1.;  0.;  0. |]
  and t = [|  0.;  1.;  0. |] in
  do_face 0 n s t;
  (* Back Face *)
  let n = [|  0.;  0.; -1. |]
  and s = [| -1.;  0.;  0. |]
  and t = [|  0.;  1.;  0. |] in
  do_face 4 n s t;
  (* Top Face *)
  let n = [|  0.;  1.;  0. |]
  and s = [|  1.;  0.;  0. |]
  and t = [|  0.;  0.; -1. |] in
  do_face 8 n s t;
  (* Bottom Face *)
  let n = [|  0.; -1.;  0. |]
  and s = [| -1.;  0.;  0. |]
  and t = [|  0.;  0.; -1. |] in
  do_face 12 n s t;
  (* Right Face *)
  let n = [|  1.;  0.;  0. |]
  and s = [|  0.;  0.; -1. |]
  and t = [|  0.;  1.;  0. |] in
  do_face 16 n s t;
  (* Left Face *)
  let n = [| -1.;  0.;  0. |]
  and s = [|  0.;  0.;  1. |]
  and t = [|  0.;  1.;  0. |] in
  do_face 20 n s t;
  GlDraw.ends ()


let update_rotation () =
  rot.(0) <- mod_float (rot.(0) +. !xspeed) 360.;
  rot.(1) <- mod_float (rot.(1) +. !yspeed) 360.
    
let do_mesh1_texel_units tex =
  let coord2 = GlTex.coord2 in
  (* Clear The Screen And The Depth Buffer *)
  GlClear.clear [ `color ; `depth ];
  (* Build Inverse Modelview Matrix First. *)
  setup_inv_modelview ();
  let minv = GlMat.to_array (GlMat.get_matrix `modelview_matrix) in
  setup_modelview ();
  (* Transform The Lightposition Into Object Coordinates: *)
  let l = vmat_mult minv light_position in
  (* First Pass *)
  GlTex.bind_texture ~target:`texture_2d tex.bumps.(!filter);
  Gl.disable `blend;
  Gl.disable `lighting;
  do_cube ();
  (* Second Pass *)
  GlTex.bind_texture ~target:`texture_2d tex.invs.(!filter);
  GlFunc.blend_func ~src:`one ~dst:`one;
  GlFunc.depth_func `lequal;
  Gl.enable `blend;
  let do_face r n s t = 
    for i = r to r + 3 do
      let c = [| data.(5*i+2) ; data.(5*i+3); data.(5*i+4) |] in
      let v = inv_ray l c in
      let st = setup_bumps v s t in
      coord2 (data.(5*i) +. st.(0), data.(5*i+1) +. st.(1));
      vertex3 (data.(5*i+2), data.(5*i+3), data.(5*i+4));
    done
  in
  do_cube_bump do_face;
  (* Third Pass *)
  if (not !emboss) then (
    GlTex.env `texture_env (`mode `modulate);
    GlTex.bind_texture ~target:`texture_2d tex.ids.(!filter);
    GlFunc.blend_func ~src:`dst_color ~dst:`src_color;
    Gl.enable `lighting;
    do_cube ();
  );
  update_rotation ();
  do_logo tex
    
let do_mesh2_texel_units tex = 
  let coord2 = GlMultiTex.coord2 in
  (* Clear The Screen And The Depth Buffer *)
  GlClear.clear [ `color ; `depth ];
  (* Build Inverse Modelview Matrix First. *)
  setup_inv_modelview ();
  let minv = GlMat.to_array (GlMat.get_matrix `modelview_matrix) in
  setup_modelview ();
  (* Transform The Lightposition Into Object Coordinates: *)
  let l = vmat_mult minv light_position in
  (* First Pass *)
  (* TEXTURE-UNIT #0 *)
  GlMultiTex.active (`texture0);
  Gl.enable `texture_2d;
  GlTex.bind_texture ~target:`texture_2d  tex.bumps.(!filter);
  GlMultiTex.env `texture_env (`mode `combine);
  GlMultiTex.env `texture_env (`combine_rgb `replace);
  (* TEXTURE-UNIT #1 *)
  GlMultiTex.active (`texture1);
  Gl.enable `texture_2d;
  GlTex.bind_texture ~target:`texture_2d  tex.invs.(!filter);
  GlMultiTex.env `texture_env (`mode `combine);
  GlMultiTex.env `texture_env (`combine_rgb `add);
  (* General Switches *)
  Gl.disable `blend;
  Gl.disable `lighting;
(*  GlFunc.depth_func `lequal; *)
  let do_face r n s t =
    for i = r to r + 3 do
      let c = [| data.(5*i+2) ; data.(5*i+3); data.(5*i+4) |] in
      let v = inv_ray l c in
      let st = setup_bumps v s t in
      coord2 (`texture0) (data.(5*i), data.(5*i+1));
      coord2 (`texture1) (data.(5*i) +. st.(0), data.(5*i+1) +. st.(1));
      vertex3 (data.(5*i+2), data.(5*i+3), data.(5*i+4));
    done
  in
  do_cube_bump do_face;
  (* Second Pass *)
  GlMultiTex.active (`texture1);
  Gl.disable `texture_2d;
  Gl.disable `blend;
  GlMultiTex.active (`texture0);
  if (not !emboss) then (
    GlMultiTex.env `texture_env (`mode `modulate);
    GlTex.bind_texture ~target:`texture_2d tex.ids.(!filter);
    GlFunc.blend_func ~src:`dst_color ~dst:`src_color;
    Gl.enable `blend;
    Gl.enable `lighting;
    do_cube ();
  );
  update_rotation ();
  do_logo tex

    

let do_mesh_nobumps tex =
  (* Clear The Screen And The Depth Buffer *)
  GlClear.clear [ `color ; `depth ];
  setup_modelview ();
  GlTex.bind_texture ~target:`texture_2d tex.ids.(!filter);
  Gl.disable `blend;
  GlFunc.blend_func ~src:`dst_color ~dst:`src_color;
  Gl.enable `lighting;
  GlFunc.depth_func `lequal;
  do_cube ();
  update_rotation ();
  do_logo tex

let draw_gl_scene t =
  Glut.swapBuffers ();
  GlClear.clear [`color; `depth];
  GlMat.load_identity ();
  match !bumps, !use_multitexture,  !max_texel_units > 1 with
      true, true, true -> do_mesh2_texel_units t
    | true, _,  _      -> do_mesh1_texel_units t
    | _                -> do_mesh_nobumps t

(* Handle window reshape events *)
let reshape_cb ~w ~h =
  let ratio = (float_of_int w) /. (float_of_int h) in
  viewport 0 0 w h;
  GlMat.mode `projection;
  GlMat.load_identity ();
  GluMat.perspective 45.0 ratio (0.1, 100.0);
  GlMat.mode `modelview;
  GlMat.load_identity ()


(* Handle keyboard events *)
let keyboard_cb  ~key ~x ~y =
  let k_e = Char.code 'e'
  and k_E = Char.code 'E'
  and k_m = Char.code 'm'
  and k_M = Char.code 'M'
  and k_b = Char.code 'b'
  and k_B = Char.code 'B'
  and k_f = Char.code 'f'
  and k_F = Char.code 'F' in
  match key with
      k when k = k_e || k = k_E -> emboss := not !emboss
    | k when k = k_m || k = k_M -> use_multitexture := not (!use_multitexture) && !multitexture_supported
    | k when k = k_b || k = k_B -> bumps := not !bumps
    | k when k = k_f || k = k_F -> filter := (succ !filter) mod 3
    | 27 (* ESC *)                  -> exit 0
    | _                  -> ()

let special_cb ~key ~x ~y =
  match key with
    | Glut.KEY_PAGE_UP   -> z := !z -. 0.02
    | Glut.KEY_PAGE_DOWN -> z := !z +. 0.02
    | Glut.KEY_UP        -> xspeed := !xspeed -. 0.01
    | Glut.KEY_DOWN      -> xspeed := !xspeed +. 0.01
    | Glut.KEY_RIGHT     -> yspeed := !yspeed +. 0.01
    | Glut.KEY_LEFT      -> yspeed := !yspeed -. 0.01
    | _                  -> ()


let main () =
  let width  = 640 
  and height = 480 in
  ignore (Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:true ~depth:true ~double_buffer:true ();
  Glut.initWindowSize width height;
  ignore (Glut.createWindow "O'Caml OpenGL Lesson 22");
  let t = init_gl width height in
  let draw () = draw_gl_scene t in
  Glut.displayFunc draw;
  Glut.keyboardFunc keyboard_cb;
  Glut.specialFunc special_cb;
  Glut.reshapeFunc reshape_cb;
  Glut.idleFunc (Some draw);
  Glut.mainLoop ()

let _ = main ()
