open Sdlvideo
open Vmaths 

let name_of_target = function
  | `texture_cube_map_positive_x -> "positive_x"
  | `texture_cube_map_negative_x -> "negative_x"
  | `texture_cube_map_positive_y -> "positive_y"
  | `texture_cube_map_negative_y -> "negative_y"
  | `texture_cube_map_positive_z -> "positive_z"
  | `texture_cube_map_negative_z -> "negative_z"
  |  _                           -> "???"


class t size =
object(self)

  val id = GlTex.gen_texture ()

  method id = id

  method private save_tex data size name =
    let s = create_RGB_surface [] size size 24 0xff000000l 0x00ff0000l 0x0000ff00l 0xffl in 
    lock s;
    for y = 0 to pred size do
      for x = 0 to pred size do
	let offs = 3 * (y * size + x) in
	let r,g,b = Raw.get data (offs), Raw.get data (offs + 1), Raw.get data (offs + 2) in
	put_pixel_color s x y (r,g,b)
      done
    done;
    unlock s;
    save_BMP s name
      
  method private init () = 
    let pack_to_01 (x,y,z) =
       (0.5 *. x +. 0.5,0.5 *. y +. 0.5, 0.5 *. z +. 0.5)
    and to_rgb (x,y,z) =
      let f x = truncate (255. *. x) in
      [| f x; f y; f z |]
    in
    (* Create normalisation cube map *)
    GlTex.bind_texture ~target:`texture_cube_map id;
    List.iter (GlTex.parameter ~target:`texture_cube_map)
      [ `mag_filter `linear;
	`min_filter `linear;
	`wrap_s `clamp_to_edge;
	`wrap_t `clamp_to_edge;
	`wrap_r `clamp_to_edge
      ];
    let r = Raw.create `ubyte (size*size*3) in
    let offset   = 0.5
    and halfsize = (float size) *. 0.5 in
    let do_face target vecf =
      for y = 0 to pred size do
	for x = 0 to pred size do
	  let tmpv = vecf (float x) (float y) in
	  let tmpv = pack_to_01 (normalize3 tmpv) in
	  let rgb = to_rgb tmpv in
	  Raw.sets r ~pos:(3 * (y*size + x)) rgb
	done
      done;
(*      self#save_tex r size ((name_of_target target)^".bmp"); *)
      GlTex.image2d ~target ~internal:`rgb8 (GlPix.of_raw r ~format:`rgb ~width:size ~height:size)
    in
    let c i = i +. offset -. halfsize
    and nc i = -.(i +. offset -. halfsize) in
    do_face `texture_cube_map_positive_x
      (fun x y -> (   halfsize,  nc y, nc x ));
    do_face `texture_cube_map_negative_x
      (fun x y -> ( -.halfsize, nc y,  c x ));
    do_face `texture_cube_map_positive_y
      (fun x y -> (  c x,   halfsize,  c y ));
    do_face `texture_cube_map_negative_y
      (fun x y -> (  c x, -.halfsize, nc y ));
    do_face `texture_cube_map_positive_z
      (fun x y -> (  c x, nc y,   halfsize ));
    do_face `texture_cube_map_negative_z
      (fun x y -> ( nc x, nc y, -.halfsize ))

  method bind () =
    GlTex.bind_texture ~target:`texture_cube_map id;
    Gl.enable `texture_cube_map

  initializer (
    self#init ();
  )

end

(*
class t2 size =
object(self)

  val id = GlTex.gen_texture ()

  method id = id

  method private save_tex data size name =
    let s = create_RGB_surface [] size size 24 0xff000000l 0x00ff0000l 0x0000ff00l 0xffl in 
    lock s;
    for y = 0 to pred size do
      for x = 0 to pred size do
	let offs = 3 * (y * size + x) in
	let r,g,b = Raw.get data (offs), Raw.get data (offs + 1), Raw.get data (offs + 2) in
	put_pixel_color s x y (r,g,b)
      done
    done;
    unlock s;
    save_BMP s name

  method private init () = 
    let normalize3 v = 
      let l = 1. /. sqrt (dot3 v v) in
      [| v.(0) *. l ; v.(1) *. l; v.(2) *. l |]
    in
    (* Create normalisation cube map *)
    GlTex.bind_texture ~target:`texture_cube_map id;
    List.iter (GlTex.parameter ~target:`texture_cube_map)
      [ `mag_filter `linear;
	`min_filter `linear;
	`wrap_s `clamp_to_edge;
	`wrap_t `clamp_to_edge;
	`wrap_r `clamp_to_edge
      ];
    let r = Raw.create `ubyte (size*size*3) in
    let offset   = 0.5
    and invsize  = 1. /. (float size) in
    let do_face target vecf =
      for y = 0 to pred size do
	for x = 0 to pred size do
	  let tmpv = normalize3 (vecf (float x) (float y)) in
	  let rgb = Array.map (fun x -> 128 + (truncate (127. *. x))) tmpv in
	  Raw.sets r ~pos:(3 * (y*size + x)) rgb
	done
      done;
      self#save_tex r size ((name_of_target target)^".bmp");
      GlTex.image2d ~target ~internal:`rgb8 (GlPix.of_raw r ~format:`rgb ~width:size ~height:size)
    in
    let c s  =    (s +. offset) *. invsize 
    and nc s = -.((s +. offset) *. invsize) in

    do_face `texture_cube_map_positive_x
      (fun s t -> [|   1.0;   c t;  nc s |]);
    do_face `texture_cube_map_negative_x
      (fun s t -> [| -.1.0;  nc t;   c s |]);
    do_face `texture_cube_map_positive_y
      (fun s t -> [|   c s;   1.0;   c t |]);
    do_face `texture_cube_map_negative_y
      (fun s t -> [|   c s; -.1.0;  nc t |]);
    do_face `texture_cube_map_positive_z
      (fun s t -> [|   c s;  nc t;   1.0 |]);
    do_face `texture_cube_map_negative_z
      (fun s t -> [|  nc s;  nc t; -.1.0 |])

  method bind () =
    GlTex.bind_texture ~target:`texture_cube_map id;
    Gl.enable `texture_cube_map

  initializer (
    self#init ();
  )

end

*)
