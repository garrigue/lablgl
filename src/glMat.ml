(* $Id: glMat.ml,v 1.4 1999-11-23 17:18:16 garrigue Exp $ *)

type t = [`double] Raw.t

external frustum :
    x:(float * float) -> y:(float * float) -> z:(float * float) -> unit
    = "ml_glFrustum"

external load_identity : unit -> unit = "ml_glLoadIdentity"
external load : t -> unit = "ml_glLoadMatrixd"
let load m =
  if Raw.length m <> 16 then invalid_arg "Gl.load_matrix";
  load m

external mode : [`modelview|`projection|`texture] -> unit
    = "ml_glMatrixMode"
external mult : t -> unit = "ml_glMultMatrixd"
let mult m =
  if Raw.length m <> 16 then invalid_arg "Gl.mult_matrix";
  mult m

external ortho :
    x:(float * float) -> y:(float * float) -> z:(float * float) -> unit
    = "ml_glOrtho"

external pop : unit -> unit = "ml_glPopMatrix"
external push : unit -> unit = "ml_glPushMatrix"

external rotate : angle:float -> x:float -> y:float -> z:float -> unit
    = "ml_glRotated"
let rotate3 :angle (x,y,z) = rotate :angle :x :y :z
let rotate :angle ?:x{=0.} ?:y{=0.} ?:z{=0.} () = rotate :angle :x :y :z

external scale : x:float -> y:float -> z:float -> unit = "ml_glScaled"
let scale3 (x,y,z) = scale :x :y :z
let scale ?:x{=0.} ?:y{=0.} ?:z{=0.} () = scale :x :y :z

external translate : x:float -> y:float -> z:float -> unit = "ml_glTranslated"
let translate3 (x,y,z) = translate :x :y :z
let translate ?:x{=0.} ?:y{=0.} ?:z{=0.} () = translate :x :y :z

let of_raw mat =
  if Raw.length mat <> 16 then invalid_arg "GlMatrix.of_array";
  mat
external to_raw : t -> [`double] Raw.t = "%identity"

let of_array m : t =
  if Array.length m <> 4 then invalid_arg "GlMatrix.of_array";
  let mat = Raw.create `double len:16 in
  for i = 0 to 3 do
    let arr = Array.unsafe_get m i in
    if Array.length arr <> 4 then invalid_arg "GlMatrix.of_array";
    Raw.sets_float mat pos:(i*4) arr
  done;
  mat

let to_array (mat : t) =
  let m = Array.create len:4 [||] in
  for i = 0 to 3 do
    Array.unsafe_set m i (Raw.gets_float mat pos:(i*4) len:4)
  done;
  m
