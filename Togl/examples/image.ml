(* $Id: image.ml,v 1.1 1998-01-16 00:19:37 garrigue Exp $ *)

let short_of_string s :pos =
  (Char.code s.[pos]) shl 8 + Char.code s.[pos+1]

let raw_image_open :name =
  let ic = open_in_bin :name in
  let buffer = String.create len:12 in
  input ic :buffer pos:0 len:12;
  let imagic :: itype :: dim :: size_x :: size_y :: size_z :: _ =
     List.map fun:(fun pos -> short_of_string s :pos)
       [0;2;4;6;8;10]
  in
  let tmp = String.create len:(size_x shl 8)
  and tmpR = String.create len:(size_x shl 8)
  and tmpG = String.create len:(size_x shl 8)
  and tmpB = String.create len:(size_x shl 8)
  and tmpA = String.create len:(size_x shl 8)
  in
  if itype land 0xff00 = 0x0100 then
    let len = size_y * size_z in
    let start = Array.create :len fill:0
    and size = Array.create :len fill:0
    in
    seek_in ic pos:512;
    let start = Array.init :len fun:(fun _ -> 
