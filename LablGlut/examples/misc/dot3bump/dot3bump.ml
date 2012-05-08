(* original C source and images from 
   http://www.paulsproject.net/simplebump.html
*)

open Vmaths
open Imgload

module GlI = GlInterleaved

(* torus --------------- *)

let tuple4_of_array4 v = ( v.(0), v.(1), v.(2), v.(3) )
and tuple3_of_array3 v = ( v.(0), v.(1), v.(2) )
and tuple2_of_array2 v = ( v.(0), v.(1) )

let array4_of_tuple4 (x,y,z,w) = [| x; y; z; w |]
and array3_of_tuple3 (x,y,z) = [| x; y; z |]
and array2_of_tuple2 (x,y) = [| x; y |]

let point3_of_point4 (x,y,z,w) =
  let iw = 1. /. w in
  (x *. iw, y *. iw, z *. iw)

class torus precision inner_radius outer_radius cube_map_id = 
  let numVertices = (succ precision)*(succ precision)
  and numIndices  = 2 * precision * precision * 3 in
  let get_raw4 r i =
    tuple4_of_array4 (Raw.gets_float r ~pos:(i * 4) ~len:4)
  and get_raw3 r i =
    tuple3_of_array3 (Raw.gets_float r ~pos:(i * 3) ~len:3)
  and get_raw2 r i =
    tuple2_of_array2 (Raw.gets_float r ~pos:(i * 2) ~len:2)
  and set_raw4 r i v =
    Raw.sets_float r ~pos:(i * 4) (array4_of_tuple4 v)
  and set_raw3 r i v =
    Raw.sets_float r ~pos:(i * 3) (array3_of_tuple3 v)
  and set_raw2 r i v =
    Raw.sets_float r ~pos:(i * 2) (array2_of_tuple2 v) in
object(self)

  val texcoords_normals_positions = GlI.make `t2f_n3f_v3f numVertices
  val stangents = Raw.create_static `float (numVertices * 3)
  val ttangents = Raw.create_static `float (numVertices * 3)
  val ts_lights = Raw.create_static `float (numVertices * 3)
  val indices = Raw.create_static `uint numIndices

  method get_position pos = 
    match (GlI.get texcoords_normals_positions pos) with
      | `t2f_n3f_v3f (t,n,p) -> p
      | _                    -> assert false
  method get_texcoord pos =
    match (GlI.get texcoords_normals_positions pos) with
      | `t2f_n3f_v3f (t,n,p) -> t
      | _                    -> assert false
  method get_stangent i = get_raw3 stangents i
  method get_ttangent i = get_raw3 ttangents i
  method get_normal pos = 
    match (GlI.get texcoords_normals_positions pos) with
      | `t2f_n3f_v3f (t,n,p) -> n
      | _                    -> assert false
  method get_ts_light i = get_raw3 ttangents i

  method set_tex_norm_pos pos v =
    GlI.set texcoords_normals_positions pos (`t2f_n3f_v3f v)
      (*
  method set_position i v = Raw.sets_float positions (i * 4) v
  method set_texcoord i v = Raw.sets_float texcoords (i * 2) v
  method set_normal i v = 
    let v =
      match Array.length v with
	  4 -> let fact = 1. /. v.(3) in
	       [| v.(0) *. fact ; v.(1) *. fact ; v.(2) *. fact |]
	| 3 -> v
	| _ -> failwith "set_normal"
    in Raw.sets_float normals (i * 3) v
      *)
  method set_stangent i v = set_raw3 stangents i v
  method set_ttangent i v = set_raw3 ttangents i v
  method set_ts_light i v = set_raw3 ts_lights i v
  method get_index i = Raw.get indices i
  method set_index i k = Raw.set indices i k

  val mutable draw_bumps = true
  val mutable draw_color = true

  method toggle_bumps () = draw_bumps <- not draw_bumps
  method toggle_color () = draw_color <- not draw_color

  val texid  = setup_img "data/decal.bmp"

  val normid = setup_img "data/normal.bmp"

  method private init () = 
    let step = 1. /. (float precision) in
    guard (fun () -> for i = 0 to precision do
      let fi = float i in
      let a = fi *. step *. 2. *. pi in
      let stgt = (0.,0.,-1.0)
      and ttgt = rotate_z (0.,-1.0,0.) a in
      let n = cross3 ttgt stgt in
      self#set_tex_norm_pos i 
	((0.,fi *. step), n, (vadd (rotate_z (outer_radius,0.,0.) a) (inner_radius,0.,0.)));
      self#set_stangent i stgt;
      self#set_ttangent i ttgt;
      self#set_ts_light i (0.,0.,0.);
    done;) "init1";
    guard (fun () -> for ring = 1 to precision do
	let a = (float ring) *. step *. 2. *. pi in
	for i = 0 to precision do
	  let k = ring * (succ precision) + i in
	  let p = self#get_position i
	  and (t0,t1) = self#get_texcoord i
	  and n = self#get_normal i in
	  self#set_tex_norm_pos k ((2.*.step*.(float ring),t1),(rotate_y n a),(rotate_y p a));
	  self#set_stangent k (rotate_y (self#get_stangent i) a);
	  self#set_ttangent k (rotate_y (self#get_ttangent i) a);
	  self#set_ts_light k (0.,0.,0.);
	done
      done;) "init2";
    guard (fun () -> for ring = 0 to pred precision do
      for i = 0 to pred precision do
	self#set_index (((ring*precision+i)*2)*3+0) (ring*(precision+1)+i);
        self#set_index (((ring*precision+i)*2)*3+1) ((ring+1)*(precision+1)+i);
        self#set_index (((ring*precision+i)*2)*3+2) (ring*(precision+1)+i+1);
        self#set_index (((ring*precision+i)*2+1)*3+0) (ring*(precision+1)+i+1);
        self#set_index (((ring*precision+i)*2+1)*3+1) ((ring+1)*(precision+1)+i);
        self#set_index (((ring*precision+i)*2+1)*3+2) ((ring+1)*(precision+1)+i+1)
      done
      done) "init3";
    (* Set vertex, texcoords, normals arrays for torus *)
    GlInterleaved.arrays texcoords_normals_positions;

  method update_space_light light_pos = 
    for i = 0 to pred (numVertices) do
      let light_vector = vsub light_pos (self#get_position i) in
      (* Calculate tangent space light vector *)
      let v = 
	(
	  dot3 (self#get_stangent i) light_vector,
	  dot3 (self#get_ttangent i) light_vector,
	  dot3 (self#get_normal i) light_vector
	)
      in 
      self#set_ts_light i v
    done

  method render light_pos =
    (* Draw bump pass *)
    if draw_bumps then (
      (* Bind normal map to texture unit 0 *)
      GlTex.bind_texture ~target:`texture_2d normid;
      Gl.enable `texture_2d;

      (* Bind normalisation cube map to texture unit 1 *)
      GlMultiTex.active (`texture1);
      GlTex.bind_texture ~target:`texture_cube_map cube_map_id;
      Gl.enable `texture_cube_map;
      GlMultiTex.active (`texture0);

      GlArray.enable `vertex;
      GlArray.enable `texture_coord;

      (* Send tangent space light vectors for normalisation to unit 1 *)
      GlMultiTex.client_active (`texture1);
      GlArray.tex_coord `three ts_lights;
      GlArray.enable `texture_coord;
      GlMultiTex.client_active (`texture0);
      GlMultiTex.active (`texture0);
      (* Set up texture environment to do (tex0 dot tex1)*color *)
      GlMultiTex.env (`mode `combine);
      GlMultiTex.env (`source0_rgb `texture);
      GlMultiTex.env (`combine_rgb `replace);

      GlMultiTex.active (`texture1);

      GlMultiTex.env (`mode `combine);
      GlMultiTex.env (`source0_rgb `texture);
      GlMultiTex.env (`combine_rgb `dot3_rgb);
      GlMultiTex.env (`source1_rgb `previous);

      GlMultiTex.active (`texture0);
      (* Draw torus *)
      GlArray.draw_elements `triangles numIndices indices;

      (* Disable textures *)
      Gl.disable `texture_2d;
      GlMultiTex.active (`texture1);
      Gl.disable `texture_cube_map;
      GlMultiTex.active (`texture0);

      (* disable vertex arrays *)
      List.iter GlArray.disable [ `vertex; `texture_coord ];
      GlMultiTex.client_active (`texture1);
      GlArray.disable `texture_coord;
      GlMultiTex.client_active (`texture0);

      (* Return to standard modulate texenv *)
      GlMultiTex.env (`mode `modulate);
    );

    (* If we are drawing both passes, enable blending to multiply them together *)
    if draw_bumps && draw_color then (
      (* Enable multiplicative blending *)
      GlFunc.blend_func ~src:`dst_color ~dst:`zero;
      Gl.enable `blend;
    );

    if draw_color then (
      if not draw_bumps then (
	List.iter Gl.enable [ `light1; `lighting];
	GlLight.light 1 (`position light_pos);
      );
      (* Bind decal texture *)
      GlTex.bind_texture ~target:`texture_2d texid;
      Gl.enable `texture_2d;

      (* Set vertex arrays for torus *)
      GlArray.enable `vertex;
      GlArray.enable `normal;
      GlArray.enable `texture_coord;

      (* Draw torus *)
      GlArray.draw_elements `triangles numIndices indices;

      if (not draw_bumps) then
        Gl.disable `lighting;

      Gl.disable `texture_2d;
      
      List.iter GlArray.disable [ `vertex ; `normal ; `texture_coord ];

    );
    (* Disable blending if it is enabled *)
    if (draw_bumps && draw_color) then 
      Gl.disable `blend
	
  initializer(
    self#init ();
  )

end

class scene cb =
object(self)

  val cubemap = cb
(*
  val data = new cube 3.0 cb#id
*)
  val data = new torus 48 4.0 1.5 cb#id

  val light_pos =  ( 10.0, 10.0, 10.0, 1.0 )

  val mutable angle = 0.0

  method toggle_bumps () = data#toggle_bumps ()

  method toggle_color () = data#toggle_color ()

  method display () = 
    GlClear.clear [ `color ; `depth ];
    GlMat.load_identity ();
    GluMat.look_at 
      (0.0,10.0,10.0)
      (0.0,0.0,0.0)
      (0.0,1.0,0.0);
    (* rotate torus *)
    angle <- angle +. 0.1;
    GlMat.rotate ~angle ~y:1.0 ();
    GlMat.push ();
    GlMat.load_identity ();
    GlMat.rotate ~angle:(-.angle) ~y:(1.0) ();
    let mat = GlMat.to_array (GlMat.get_matrix `modelview_matrix) in
    GlMat.pop ();
    (* Get the object space light vector *)
    let lp = vmat_mul mat light_pos in
    data#update_space_light (point3_of_point4 lp);
    data#render lp;
    Gl.flush ();
    Glut.swapBuffers ()

  (* Handle window reshape events *)
  method reshape ~w ~h =
    let ratio = (float_of_int w) /. (float_of_int h) in
    GlDraw.viewport 0 0 w h;
    GlMat.mode `projection;
    GlMat.load_identity ();
    GluMat.perspective 45.0 ratio (0.1, 100.0);
    GlMat.mode `modelview;
    GlMat.load_identity ()

end

let init () =

  (* Shading states *)

  GlDraw.shade_model `smooth;
  GlClear.color ~alpha:0.0 (0.2, 0.4, 0.2);
  GlDraw.color ~alpha:1.0 (1.0, 1.0, 1.0);
  GlMisc.hint `perspective_correction `nicest;

  (* Depth states *)
  GlClear.depth 1.0;
  GlFunc.depth_func `lequal;

  (* Light 1 states *)
  let white = (1.,1.,1.,1.)
  and black = (0.,0.,0.,1.) in
  GlLight.light 1 (`diffuse white);
  GlLight.light 1 (`ambient black);
  GlLight.light_model (`ambient black);
  GlLight.material ~face:`front (`diffuse white);


  List.iter Gl.enable [ 
    `depth_test;
    `cull_face;
  ];
  GlDraw.cull_face `back;
  GlDraw.front_face `cw

      
let main () =
  let width  = 640 
  and height = 480 in
  ignore (Glut.init Sys.argv);
  Glut.initDisplayMode ~alpha:true ~depth:true ~double_buffer:true ();
  Glut.initWindowSize width height;
  ignore (Glut.createWindow "Dot3 based Bumpmap Demo");
  init ();
  let scene = new scene (new Cubemap.t 256) in
  Glut.displayFunc scene#display;
  Glut.keyboardFunc (fun ~key ~x ~y ->
    let k_c = Char.code 'c'
    and k_C = Char.code 'C'
    and k_b = Char.code 'b'
    and k_B = Char.code 'B' 
    and k_w = Char.code 'w'
    and k_W = Char.code 'W' 
    and k_f = Char.code 'f'
    and k_F = Char.code 'F' 
    in
    match key with
      | k when k = k_b || k = k_B -> scene#toggle_bumps ()
      | k when k = k_c || k = k_C -> scene#toggle_color ()
      | k when k = k_w || k = k_W -> GlDraw.polygon_mode `front `line
      | k when k = k_f || k = k_F -> GlDraw.polygon_mode `front `fill
      | 27 (* ESC *)  -> exit 0
      | _             -> ()
  );
  Glut.specialFunc (fun ~key ~x ~y -> ());
  Glut.idleFunc (Some scene#display);
  Glut.reshapeFunc scene#reshape;
  Glut.mainLoop ()

let _ = main ()
