open Ocamlbuild_plugin;;
open Command;;

dispatch begin function
  | After_rules -> (
    (* create the use_ tags *)
    ocaml_lib ~dir:"+lablgtk2" ~extern:true "lablgtk";
    ocaml_lib ~dir:"+lablgl" ~extern:true "lablgl";
    ocaml_lib ~dir:"+lablgl" ~extern:true "lablglut";
    ocaml_lib ~dir:"+sdl" ~extern:true "sdl";
    ocaml_lib ~dir:"+camlimages" ~extern:true "camlimages"
  )
  | _           -> ()
end
