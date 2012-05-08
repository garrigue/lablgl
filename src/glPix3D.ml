(* extends to 3 dimension GlPix.t *)

open Gl

type ('a,'b) t = { format: 'a ; width: int ; height:int ; depth: int; raw: 'b Raw.t }

let create k ~format ~width ~height ~depth =
  let size = format_size format * width * height in
  let len = match k with `bitmap -> (size-1)/8+1 | #Gl.real_kind -> size in
  let raw = Raw.create k ~len in
  { format = format; width = width; height = height; depth = depth; raw = raw }
  
let of_raw raw ~format ~width ~height ~depth =
  let size = format_size format * width * height
  and len = Raw.length raw in
  let len =
    match Raw.kind raw with `bitmap -> len * 8 | #Gl.real_kind -> len in
  if size > len then invalid_arg "GlPix.of_raw";
  { format = format; width = width; height = height; depth = depth; raw = raw }

let to_raw img = img.raw
let format img = img.format
let width img = img.width
let height img = img.height
let depth img = img.depth

let raw_pos img =
  let width =
    match Raw.kind img.raw with `bitmap -> (img.width-1)/8+1
    | #Gl.real_kind -> img.width
  and height = img.height in
  let stride = format_size img.format in
  let line = stride * width in
  let rect = line * height in
  fun ~x ~y ~z -> x * stride + y * line + z * rect

external raster_pos :
    x:float -> y:float -> ?z:float -> ?w:float -> unit -> unit
    = "ml_glRasterPos"

(* returns a slice along the z axis of the 3d pixel storage *)
let slice (img: ('a,'b) t) depth : ('a,'b) GlPix.t = 
  let width =
    match Raw.kind img.raw with 
	`bitmap        -> (img.width-1)/8+1
      | #Gl.real_kind  -> img.width
  and height = img.height in
  let stride = format_size img.format in
  let line = stride * width in
  let rect = line * height in
  GlPix.of_raw (Raw.sub img.raw ~pos:(rect*depth) ~len:rect) ~format:img.format ~width:img.width ~height:img.height 

let of_glpix p = 
  {format = GlPix.format p; width = GlPix.width p; height = GlPix.height p; depth = 1; raw = GlPix.to_raw p}
