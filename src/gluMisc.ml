(* $Id: gluMisc.ml,v 1.3 2000-04-12 07:40:25 garrigue Exp $ *)

open Gl
open GlPix

external build_1d_mipmaps :
    internal:int ->
    width:int -> format:#GlTex.format -> #kind Raw.t -> unit
    = "ml_gluBuild1DMipmaps"
let build_1d_mipmaps ?internal:i img =
  let internal = match i with None -> format_size (format img) | Some i -> i in
  if height img < 1 then
    raise (GLerror "GluMisc.build_1d_mipmaps : bad height");
  build_1d_mipmaps ~internal
    ~width:(width img) ~format:(format img) (to_raw img)

external build_2d_mipmaps :
    internal:int -> width:int ->
    height:int -> format:#GlTex.format -> #kind Raw.t -> unit
    = "ml_gluBuild1DMipmaps"
let build_2d_mipmaps ?internal:i img =
  let internal = match i with None -> format_size (format img) | Some i -> i in
  build_2d_mipmaps ~internal
    ~width:(width img) ~height:(height img) ~format:(format img) (to_raw img)

external get_string : [`version|`extensions] -> string = "ml_gluGetString"

external scale_image :
    format:#Gl.format ->
    w:int -> h:int -> data:#kind Raw.t ->
    w:int -> h:int -> data:#kind Raw.t -> unit
    = "ml_gluScaleImage"
let scale_image ~width ~height img =
  let k = Raw.kind (to_raw img) and format = format img in
  let new_img = GlPix.create k ~format ~height ~width in
  scale_image ~format ~w:(GlPix.width img) ~h:(GlPix.height img)
    ~data:(to_raw img) ~w:width ~h:height ~data:(to_raw new_img);
  new_img
