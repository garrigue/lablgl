(* $Id: glm.ml,v 1.2 1998-01-12 02:44:59 garrigue Exp $ *)

let block :mode comms =
  Gl.begin_block mode;
  List.iter comms fun:
    begin function
	`vertex2(x,y) -> Gl.vertex :x :y
      |	`vertex3(x,y,z) -> Gl.vertex :x :y :z
      |	`vertex4(x,y,z,w) -> Gl.vertex :x :y :z :w
    end;
  Gl.end_block ()

let new_list mode =
  let l = Gl.gen_lists 1 in
  Gl.new_list l :mode;
  l
