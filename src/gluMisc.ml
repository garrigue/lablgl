(* $Id: gluMisc.ml,v 1.1 1998-01-29 11:46:07 garrigue Exp $ *)

open Gl
open GlPix

external build_1d_mipmaps :
    internal:int ->
    width:int -> format:#GlTex.format -> #kind Raw.t -> unit
    = "ml_gluBuild1DMipmaps"
let build_1d_mipmaps img ?:internal [< format_size (format img) >] =
  if height img < 1 then
    raise (GLerror "GluMisc.build_1d_mipmaps : bad height");
  build_1d_mipmaps :internal
    width:(width img) format:(format img) (to_raw img)

external build_2d_mipmaps :
    internal:int -> width:int ->
    height:int -> format:#GlTex.format -> #kind Raw.t -> unit
    = "ml_gluBuild1DMipmaps"
let build_2d_mipmaps img ?:internal [< format_size (format img) >] =
  build_2d_mipmaps :internal
    width:(width img) height:(height img) format:(format img) (to_raw img)

external get_string : [version extensions] -> string = "ml_gluGetString"

external scale_image :
    format:#Gl.format ->
    w:int -> h:int -> data:#kind Raw.t ->
    w:int -> h:int -> data:#kind Raw.t -> unit
    = "ml_gluScaleImage"
let scale_image img :width :height =
  let k = Raw.kind (to_raw img) and format = format img in
  let new_img = GlPix.create k :format :height :width in
  scale_image :format w:(GlPix.width img) h:(GlPix.height img)
    data:(to_raw img) w:width h:height data:(to_raw new_img);
  new_img
