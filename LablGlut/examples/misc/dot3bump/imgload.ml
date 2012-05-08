(* CamlImages stuff *)
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
  for i = 0 to width - 1 do
    for j = 0 to height - 1 do
      let pixel = Rgb24.get img i j in (* pixel is a Color.rgb *)
      Raw.sets raw ~pos:(3*(i*height+j)) [| pixel.r; pixel.g; pixel.b |];
    done
  done;
  GlPix.of_raw raw ~format:`rgb ~width ~height


let load_file = camlimg_load_file
let pix_of_img = pix_of_camlimg

let setup_img filename = 
  (* Load image *)
  Gl.enable `texture_2d;
  let img,w,h = load_file filename in
  let pix = pix_of_img img in
  (* Convert image to texture *)
  let texid = GlTex.gen_texture () in
  GlTex.bind_texture ~target:`texture_2d texid;
  List.iter (GlTex.parameter ~target:`texture_2d)
    [ `mag_filter `linear;
      `min_filter `linear;
      `wrap_s `repeat;
      `wrap_t `repeat;
      `wrap_r `repeat];
  GlTex.image2d pix;
  texid
