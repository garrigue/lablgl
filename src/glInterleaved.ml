open Gl
open GlArray

type kind =
  [ `v2f
  | `v3f
  | `c4ub_v2f
  | `c4ub_v3f
  | `c3f_v3f
  | `n3f_v3f
  | `c4f_n3f_v3f
  | `t2f_v3f
  | `t4f_v4f
  | `t2f_c4ub_v3f
  | `t2f_c3f_v3f
  | `t2f_n3f_v3f
  | `t2f_c4f_n3f_v3f
  | `t4f_c4f_n3f_v4f ]

let float_size = 4 (* size of single precision float in number of bytes *)

let sizeof_kind = function
  | `byte    -> 1
  | `float   -> float_size
  | `int     -> 4
  | `short   -> 2
  | `ubyte   -> 1
  | `uint    -> 4
  | `ushort  -> 2

let sizein_floats l = 
  match l mod float_size with
      0 -> l / float_size
    | _ -> 1 + (l / float_size)

type point2 = Gl.point2
type point3 = Gl.point3
type point4 = Gl.point4
type ivec4 = (int * int * int * int)
type ubvec4 = ivec4

type record = 
  [ `v2f of point2
  | `v3f of point3
  | `c4ub_v2f of ubvec4 * point2
  | `c4ub_v3f of ubvec4 * point3
  | `c3f_v3f of point3 * point3
  | `n3f_v3f of point3 * point3
  | `c4f_n3f_v3f of point4 * point3 * point3
  | `t2f_v3f of point2 * point3
  | `t4f_v4f of point4 * point4
  | `t2f_c4ub_v3f of point2 * ubvec4 * point3
  | `t2f_c3f_v3f of point2 * point3 * point3
  | `t2f_n3f_v3f of point2 * point3 * point3
  | `t2f_c4f_n3f_v3f of point2 * point4 * point3 * point3
  | `t4f_c4f_n3f_v4f of point4 * point4 * point3 * point4 ]
    
type 'a t = { r : [`ubyte] Raw.t; kind : 'a }
constraint 'a = [< kind ]

let kind (a : 'a t) = a.kind

let data = function      (* texture, color, normal, vertex size; color type *)
  | `v2f              -> 0,0,0,2,`ubyte
  | `v3f              -> 0,0,0,3,`ubyte
  | `c4ub_v2f         -> 0,4,0,2,`ubyte
  | `c4ub_v3f         -> 0,4,0,3,`ubyte
  | `c3f_v3f          -> 0,3,0,3,`float
  | `n3f_v3f          -> 0,0,3,3,`ubyte
  | `c4f_n3f_v3f      -> 0,4,3,3,`float
  | `t2f_v3f          -> 2,0,0,3,`ubyte
  | `t4f_v4f          -> 4,0,0,4,`ubyte
  | `t2f_c4ub_v3f     -> 2,4,0,3,`ubyte
  | `t2f_c3f_v3f      -> 2,3,0,3,`float
  | `t2f_n3f_v3f      -> 2,0,3,3,`ubyte
  | `t2f_c4f_n3f_v3f  -> 2,4,3,3,`float
  | `t4f_c4f_n3f_v4f  -> 4,4,3,4,`float

  (* size of record of kind kind in floats *)
let record_size kind = 
  let st,sc,sn,sv,tc = data kind in
  st * float_size + (sizein_floats (sc * (sizeof_kind tc))) + sn * float_size + sv * float_size

let make (kind: 'a) length : 'a t =
  let l = record_size kind in
  {r = Raw.create `ubyte (l * length); kind = kind }

let get_point2 r i = 
  let r = Raw.cast r `float in
  match Raw.gets_float r i 2 with
    | [| f1 ; f2 |] -> f1, f2
    | _             -> assert false

let get_point3 r i =
  let r = Raw.cast r `float in
  match Raw.gets_float r i 3 with
    | [| f1 ; f2; f3 |] -> f1, f2, f3
    | _                 -> assert false

let get_point4 r i =
  let r = Raw.cast r `float in
  match Raw.gets_float r i 4 with
    | [| f1 ; f2; f3 ; f4 |] -> f1, f2, f3, f4
    | _                 -> assert false

let get_ubvec4 r i =
  let r = Raw.cast r `ubyte in
  match Raw.gets r i 4 with
    | [| i1 ; i2; i3 ; i4 |] -> i1, i2, i3, i4
    | _                      -> assert false

let set_point2 r pos (f1,f2) = 
  let r = Raw.cast r `float in
  Raw.sets_float r ~pos [| f1 ; f2 |]

let set_point3 r pos (f1,f2,f3) =
  let r = Raw.cast r `float in
  Raw.sets_float r ~pos [| f1 ; f2; f3 |] 

let set_point4 r pos (f1,f2,f3,f4) =
  let r = Raw.cast r `float in
  Raw.sets_float r ~pos [| f1 ; f2; f3 ; f4 |]

let set_ubvec4 r pos (i1,i2,i3,i4) =
  let r = Raw.cast r `ubyte in
  Raw.sets r ~pos [| i1 ; i2; i3 ; i4 |]


  (* getters *)

let get_v2f (x : [`v2f] t) i =
  let r = x.r in
  get_point2 r (i * 2)

let get_v3f (x : [`v3f] t) i =
  let r = x.r in
  get_point3 r (i * 3)

let get_c4ub_v2f (x : [`c4ub_v2f] t) i =
  let r = x.r in
  let rl = record_size `c4ub_v2f in
  let i4 = 
    let i = Raw.gets r (rl * i) 4 in
    i.(0), i.(1), i.(2), i.(3)
  and f2 = 
    let r = Raw.sub r ~pos:(rl * i + 4) ~len:rl in
    get_point2 r 0
  in
  i4, f2

let get_c4ub_v3f (x : [`c4ub_v3f] t) i =
  let r = x.r in
  let rl = record_size `c4ub_v3f in
  let c4 = 
    let i = Raw.gets r (rl * i) 4 in
    i.(0), i.(1), i.(2), i.(3)
  and v3 = 
    let r = Raw.sub r ~pos:(rl * i + 4) ~len:rl in
    get_point3 r 0
  in
  c4, v3

let get_c3f_v3f (x : [`c3f_v3f] t) i =
  let r = x.r in
  get_point3 r (i * 6), get_point3 r (i * 6 + 3)
    
let get_n3f_v3f (x : [`n3f_v3f] t) i =
  let r = x.r in
  get_point3 r (i * 6), get_point3 r (i * 6 + 3)
    
let get_c4f_n3f_v3f (x : [`c4f_n3f_v3f] t) i =
  let r = x.r in
  get_point4 r (i * 10), get_point3 r (i * 10 + 4), get_point3 r (i * 10 + 7)
    
let get_t2f_v3f (x : [`t2f_v3f] t) i = 
  let r = x.r in
  get_point2 r (i * 5), get_point3 r (i * 5 + 2)

let get_t4f_v4f (x : [`t4f_v4f] t) i = 
  let r = x.r in
  get_point4 r (i * 8), get_point4 r (i * 8 + 4)

let get_t2f_c4ub_v3f (x : [`t2f_c4ub_v3f] t) i =
  let r = x.r in
  let rl = record_size `t2f_c4ub_v3f in
  let t2 = 
    get_point2 r (rl * i)
  and c4 = 
    let i = Raw.gets r (rl * i + 8) 4 in
    i.(0), i.(1), i.(2), i.(3)
  and v3 = 
    let r = Raw.sub r ~pos:(rl * i + 8 + 4) ~len:rl in
    get_point3 r 0
  in
  t2,c4,v3

let get_t2f_c3f_v3f (x : [`t2f_c3f_v3f] t) i =
  let r = x.r in
  get_point2 r (i * 8), get_point3 r (i * 8 + 2), get_point3 r (i * 8 + 5)
    
let get_t2f_n3f_v3f (x : [`t2f_n3f_v3f] t) i =
  let r = x.r in
  get_point2 r (i * 8), get_point3 r (i * 8 + 2), get_point3 r (i * 8 + 5)

let get_t2f_c4f_n3f_v3f (x : [`t2f_c4f_n3f_v3f] t) i =
  let r = x.r in
  get_point2 r (i * 12), get_point4 r (i * 12 + 2), 
  get_point3 r (i * 12 + 6), get_point3 r (i * 12 + 9)

let get_t4f_c4f_n3f_v4f (x : [`t4f_c4f_n3f_v4f] t) i =
  let r = x.r in
  get_point4 r (i * 15), get_point4 r (i * 15 + 4), 
  get_point3 r (i * 15 + 8), get_point4 r (i * 15 + 11)

let get x i : record = 
  match x with
    | {r = _; kind = `v2f} as x             -> `v2f (get_v2f x i)
    | {r = _; kind = `v3f} as x             -> `v3f (get_v3f x i)
    | {r = _; kind = `c4ub_v2f} as x        -> `c4ub_v2f (get_c4ub_v2f x i)
    | {r = _; kind = `c4ub_v3f} as x        -> `c4ub_v3f (get_c4ub_v3f x i)
    | {r = _; kind = `c3f_v3f} as x         -> `c3f_v3f (get_c3f_v3f x i)
    | {r = _; kind = `n3f_v3f} as x         -> `n3f_v3f (get_n3f_v3f x i)
    | {r = _; kind = `c4f_n3f_v3f} as x     -> `c4f_n3f_v3f (get_c4f_n3f_v3f x i)
    | {r = _; kind = `t2f_v3f} as x         -> `t2f_v3f (get_t2f_v3f x i)
    | {r = _; kind = `t4f_v4f} as x         -> `t4f_v4f (get_t4f_v4f x i)
    | {r = _; kind = `t2f_c4ub_v3f} as x    -> `t2f_c4ub_v3f (get_t2f_c4ub_v3f x i)
    | {r = _; kind = `t2f_c3f_v3f} as x     -> `t2f_c3f_v3f (get_t2f_c3f_v3f x i)
    | {r = _; kind = `t2f_n3f_v3f} as x     -> `t2f_n3f_v3f (get_t2f_n3f_v3f x i)
    | {r = _; kind = `t2f_c4f_n3f_v3f} as x -> `t2f_c4f_n3f_v3f (get_t2f_c4f_n3f_v3f x i)
    | {r = _; kind = `t4f_c4f_n3f_v4f} as x -> `t4f_c4f_n3f_v4f (get_t4f_c4f_n3f_v4f x i)

  (* setters *)

let set_v2f (x : [`v2f] t) i v =
  let r = x.r in
  set_point2 r (i * 2) v

let set_v3f (x : [`v3f] t) i v =
  let r = x.r in
  set_point3 r (i * 3) v

let set_c4ub_v2f (x : [`c4ub_v2f] t) i ((c1,c2,c3,c4),v2) =
  let r = x.r in
  let rl = record_size `c4ub_v2f in
  Raw.sets r (rl * i) [|c1;c2;c3;c4|];
  let r = Raw.sub r ~pos:(rl * i + 4) ~len:rl in
  set_point2 r 0 v2

let set_c4ub_v3f (x : [`c4ub_v3f] t) i ((c1,c2,c3,c4),v3) =
  let r = x.r in
  let rl = record_size `c4ub_v3f in
  Raw.sets r (rl * i) [|c1;c2;c3;c4|];
  let r = Raw.sub r ~pos:(rl * i + 4) ~len:rl in
  set_point3 r 0 v3

let set_c3f_v3f (x : [`c3f_v3f] t) i (c3,v3) =
  let r = x.r in
  set_point3 r (i * 6) c3;
  set_point3 r (i * 6 + 3) v3
    
let set_n3f_v3f (x : [`n3f_v3f] t) i (n3,v3) =
  let r = x.r in
  set_point3 r (i * 6) n3;
  set_point3 r (i * 6 + 3) v3
    
let set_c4f_n3f_v3f (x : [`c4f_n3f_v3f] t) i (c4,n3,v3) =
  let r = x.r in
  set_point4 r (i * 10) c4;
  set_point3 r (i * 10 + 4) n3;
  set_point3 r (i * 10 + 7) v3
    
let set_t2f_v3f (x : [`t2f_v3f] t) i (t2,v3) = 
  let r = x.r in
  set_point2 r (i * 5) t2;
  set_point3 r (i * 5 + 2) v3

let set_t4f_v4f (x : [`t4f_v4f] t) i (t4,v4) = 
  let r = x.r in
  set_point4 r (i * 8) t4;
  set_point4 r (i * 8 + 4) v4

let set_t2f_c4ub_v3f (x : [`t2f_c4ub_v3f] t) i (t2,(c1,c2,c3,c4),v3) =
  let r = x.r in
  let rl = record_size `t2f_c4ub_v3f in
  set_point2 r (rl * i) t2;
  Raw.sets r (rl * i + 8) [|c1;c2;c3;c4|];
  let r = Raw.sub r ~pos:(rl * i + 8 + 4) ~len:rl in
  set_point3 r 0 v3

let set_t2f_c3f_v3f (x : [`t2f_c3f_v3f] t) i (t2,c3,v3) =
  let r = x.r in
  set_point2 r (i * 8) t2;
  set_point3 r (i * 8 + 2) c3;
  set_point3 r (i * 8 + 5) v3
    
let set_t2f_n3f_v3f (x : [`t2f_n3f_v3f] t) i (t2,n3,v3) =
  let r = x.r in
  set_point2 r (i * 8) t2;
  set_point3 r (i * 8 + 2) n3;
  set_point3 r (i * 8 + 5) v3

let set_t2f_c4f_n3f_v3f (x : [`t2f_c4f_n3f_v3f] t) i (t2,c4,n3,v3) =
  let r = x.r in
  set_point2 r (i * 12) t2;
  set_point4 r (i * 12 + 2) c4; 
  set_point3 r (i * 12 + 6) n3;
  set_point3 r (i * 12 + 9) v3

let set_t4f_c4f_n3f_v4f (x : [`t4f_c4f_n3f_v4f] t) i (t4,c4,n3,v4) =
  let r = x.r in
  set_point4 r (i * 15) t4;
  set_point4 r (i * 15 + 4) c4;
  set_point3 r (i * 15 + 8) n3;
  set_point4 r (i * 15 + 11) v4

let set x i v = 
  match v, x with
    | `v2f (v)            ,({r = _; kind = `v2f} as x)             -> set_v2f x i v
    | `v3f (v)            ,({r = _; kind = `v3f} as x)             -> set_v3f x i v
    | `c4ub_v2f (v)       ,({r = _; kind = `c4ub_v2f} as x)        -> set_c4ub_v2f x i v
    | `c4ub_v3f (v)       ,({r = _; kind = `c4ub_v3f} as x)        -> set_c4ub_v3f x i v
    | `c3f_v3f (v)        ,({r = _; kind = `c3f_v3f} as x)         -> set_c3f_v3f x i v
    | `n3f_v3f (v)        ,({r = _; kind = `n3f_v3f} as x)         -> set_n3f_v3f x i v
    | `c4f_n3f_v3f (v)    ,({r = _; kind = `c4f_n3f_v3f} as x)     -> set_c4f_n3f_v3f x i v
    | `t2f_v3f (v)        ,({r = _; kind = `t2f_v3f} as x)         -> set_t2f_v3f x i v
    | `t4f_v4f (v)        ,({r = _; kind = `t4f_v4f} as x)         -> set_t4f_v4f x i v
    | `t2f_c4ub_v3f (v)   ,({r = _; kind = `t2f_c4ub_v3f} as x)    -> set_t2f_c4ub_v3f x i v
    | `t2f_c3f_v3f (v)    ,({r = _; kind = `t2f_c3f_v3f} as x)     -> set_t2f_c3f_v3f x i v
    | `t2f_n3f_v3f (v)    ,({r = _; kind = `t2f_n3f_v3f} as x)     -> set_t2f_n3f_v3f x i v
    | `t2f_c4f_n3f_v3f (v),({r = _; kind = `t2f_c4f_n3f_v3f} as x) -> set_t2f_c4f_n3f_v3f x i v
    | `t4f_c4f_n3f_v4f (v),({r = _; kind = `t4f_c4f_n3f_v4f} as x) -> set_t4f_c4f_n3f_v4f x i v
    | _                                                            -> invalid_arg "GlArray.Interleaved.set"

type fkind =
  [ `v2f
  | `v3f
  | `c3f_v3f
  | `n3f_v3f
  | `c4f_n3f_v3f
  | `t2f_v3f
  | `t4f_v4f
  | `t2f_c3f_v3f
  | `t2f_n3f_v3f
  | `t2f_c4f_n3f_v3f
  | `t4f_c4f_n3f_v4f ]

  (* create a float only interleaved array from a float array *)
let of_float_array (fkind : [< fkind ]) (a : float array) =
  let l = record_size fkind in
  if ((Array.length a) mod l) <> 0 then raise (Invalid_argument "glArray.Interleaved.of_float_array : float arry size not a multiple of the requested interleaved kind size");
  {r = Raw.cast (Raw.of_float_array ~kind:`float a) `ubyte; kind = fkind }

(* create an empty interleaved array *)
let make kind size =
  let r = Raw.create ~len:(size * (record_size kind)) `ubyte in
  {r = r; kind = kind}

let of_array_f (kind : [< kind] as 'a) (f : 'a t -> int -> 'b -> unit) (a : 'b array) = 
  let ia = make kind (Array.length a) in
  Array.iteri (fun i v -> f ia i v) a

let of_array_v2f             = of_array_f `v2f set_v2f
let of_array_v3f             = of_array_f `v3f set_v3f
let of_array_c4ub_v3f        = of_array_f `c4ub_v3f set_c4ub_v3f
let of_array_c3f_v3f         = of_array_f `c3f_v3f set_c3f_v3f
let of_array_n3f_v3f         = of_array_f `n3f_v3f set_n3f_v3f
let of_array_c4f_n3f_v3f     = of_array_f `c4f_n3f_v3f set_c4f_n3f_v3f
let of_array_t2f_v3f         = of_array_f `t2f_v3f set_t2f_v3f
let of_array_t4f_v4f         = of_array_f `t4f_v4f set_t4f_v4f
let of_array_t2f_c4ub_v3f    = of_array_f `t2f_c4ub_v3f set_t2f_c4ub_v3f
let of_array_t2f_c3f_v3f     = of_array_f `t2f_c3f_v3f set_t2f_c3f_v3f
let of_array_t2f_n3f_v3f     = of_array_f `t2f_n3f_v3f set_t2f_n3f_v3f
let of_array_t2f_c4f_n3f_v3f = of_array_f `t2f_c4f_n3f_v3f set_t2f_c4f_n3f_v3f
let of_array_t4f_c4f_n3f_v4f = of_array_f `t4f_c4f_n3f_v4f set_t4f_c4f_n3f_v4f

(* 
(* build an interleaved array from an array containing the
   matching data records *)
   let of_array (kind : kind) = 
   match kind with
   | `v2f              -> of_array_v2f
   | `v3f              -> of_array_v3f
   | `c4ub_v2f         -> of_array_c4ub_v2f
   | `c4ub_v3f         -> of_array_c4ub_v3f
   | `c3f_v3f          -> of_array_c3f_v3f
   | `n3f_v3f          -> of_array_n3f_v3f
   | `c4f_n3f_v3f      -> of_array_c4f_n3f_v3f
   | `t2f_v3f          -> of_array_t2f_v3f
   | `t4f_v4f          -> of_array_t4f_v4f
   | `t2f_c4ub_v3f     -> of_array_t2f_c4ub_v3f
   | `t2f_c3f_v3f      -> of_array_t2f_c3f_v3f
   | `t2f_n3f_v3f      -> of_array_t2f_n3f_v3f
   | `t2f_c4f_n3f_v3f  -> of_array_t2f_c4f_n3f_v3f
   | `t4f_c4f_n3f_v4f  -> of_array_t4f_c4f_n3f_v4f
*)

let of_raw kind r =
  let r = Raw.cast r `ubyte
  and l = record_size kind in
  if ((Raw.sizeof (Raw.kind r)) mod l) <> 0 
  then 
    raise (Invalid_argument "glArray.interleaved : Raw.t size not a multiple of the requested interleaved kind size")
  else
    {r = r ; kind = kind }

external arrays : format:[< kind ] -> size:int -> [< `ubyte ] Raw.t -> unit = "ml_glInterleavedArrays" "noalloc"

let arrays r = 
  let k = kind r in
  arrays ~format:k ~size:(record_size k) r.r

