(* $Id: glm.ml,v 1.1 1998-01-07 08:52:30 garrigue Exp $ *)

let block :mode comms =
  Gl.begin_block mode;
  List.iter comms fun:
    begin function
	`vertex2(x,y) -> Gl.vertex :x :y
      |	`vertex3(x,y,z) -> Gl.vertex :x :y :z
      |	`vertex4(x,y,z,w) -> Gl.vertex :x :y :z :w
    end;
  Gl.end_block ()
