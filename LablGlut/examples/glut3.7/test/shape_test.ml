#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 13:41:10 MDT 2002. *)

open Printf

let w = ref 0 and h = ref 0

let light_diffuse = (1.0, 1.0, 1.0, 1.0)
let light_position = (1.0, 1.0, 1.0, 1.0)

let qobj = ref None

(* reshape has to have arguments labled w and h, but this masks the
   w and h in the global scope.  I don't know if OCaml let's to do 
   something like C++'s ::myvar trick for getting around this. *)
let workaround w' h' = 
  w:=w'; 
  h:=h';
  ;;

let reshape ~w ~h = workaround w h;;

let render shape = 
  match shape with
   | 1 -> begin
    GlMat.push() ;
    GlMat.scale3 (1.2, 1.2, 1.2);
    Glut.wireSphere ~radius:1.0  ~slices:20  ~stacks:20;
    GlMat.pop() ;
    end
   | 10 -> begin
    GlMat.push() ;
    GlMat.scale3 (1.2, 1.2, 1.2);
    Gl.enable `lighting;
    Glut.solidSphere 1.0  20  20;
    Gl.disable `lighting;
    GlMat.pop() ;
    end
   | 2 -> begin
    GlMat.push() ;
    GlMat.rotate ~angle:(-90.0) ~x:1.0 ();
    Glut.wireCone ~base:1.0 ~height:1.3 ~slices:20 ~stacks:20;
    GlMat.pop() ;
    end
   | 11 -> begin
    GlMat.push() ;
    GlMat.rotate ~angle:(-90.0) ~x:1.0 ();
    Gl.enable `lighting;
    Glut.solidCone 1.0  1.3  20  20;
    Gl.disable `lighting;
    GlMat.pop() ;
    end
   | 3 -> begin
    GlMat.push() ;
    GlMat.rotate ~angle:(-20.0) ~z:1.0 ();
    GlMat.scale3 (1.8, 1.8, 1.8);
    Glut.wireCube ~size:1.0;
    GlMat.pop() ;
    end
   | 12 -> begin
    GlMat.push() ;
    GlMat.rotate ~angle:(-20.0) ~z:1.0 ();
    GlMat.scale3 (1.8, 1.8, 1.8);
    Gl.enable `lighting;
    Glut.solidCube 1.0;
    Gl.disable `lighting;
    GlMat.pop() ;
    end
   | 4 -> begin
    GlMat.push() ;
    GlMat.scale3 (0.9, 0.9, 0.9);
    Glut.wireTorus ~innerRadius:0.5 ~outerRadius:1.0 ~sides:15 ~rings:15;
    GlMat.pop() ;
    end
   | 13 -> begin
    GlMat.push() ;
    GlMat.scale3 (0.9, 0.9, 0.9);
    Gl.enable `lighting; 
    Glut.solidTorus ~innerRadius:0.5 ~outerRadius:1.0 ~sides:15 ~rings:15;
    Gl.disable `lighting;
    GlMat.pop() ;
    end
   | 5 -> begin
    GlMat.push() ;
    GlMat.scale3 (0.8, 0.8, 0.8);
    Glut.wireDodecahedron ();
    GlMat.pop() ;
    end
   | 14 -> begin
    GlMat.push() ;
    GlMat.scale3 (0.8, 0.8, 0.8);
    Gl.enable `lighting;
    Glut.solidDodecahedron ();
    Gl.disable `lighting;
    GlMat.pop() ;
    end
   | 6 -> begin
    GlMat.push() ;
    GlMat.scale3 (0.9, 0.9, 0.9);
    Glut.wireTeapot 1.0;
    GlMat.pop() ;
    end
   | 15 -> begin
    GlMat.push() ;
    GlMat.scale3 (0.9, 0.9, 0.9);
    Gl.enable `lighting; 
    Glut.solidTeapot 1.0;
    Gl.disable `lighting;
    GlMat.pop() ;
    end
   | 7 -> Glut.wireOctahedron ();
   | 16 -> begin
    Gl.enable `lighting;
    Glut.solidOctahedron ();
    Gl.disable `lighting;
    end
   | 8 -> begin
    GlMat.push() ;
    GlMat.scale3 (1.2, 1.2, 1.2);
    Glut.wireTetrahedron ();
    GlMat.pop() ;
    end
   | 17 -> begin
    GlMat.push() ;
    GlMat.scale3 (1.2, 1.2, 1.2);
    Gl.enable `lighting;
    Glut.solidTetrahedron ();
    Gl.disable `lighting;
    GlMat.pop() ;
    end
   | 9 -> Glut.wireIcosahedron ();
   | 18 -> begin
    Gl.enable `lighting;
    Glut.solidIcosahedron ();
    Gl.disable `lighting;
    end
  | _ -> failwith "invalid shape index"
  ;;

let display () = 
  GlDraw.viewport ~x:0 ~y:0 ~w:!w ~h:!h;
  GlClear.clear [`color; `depth];
  for j = 0 to 5 do
    for i = 0 to 2 do
      GlDraw.viewport (!w / 3 * i)  (!h / 6 * j)  (!w / 3) (!h / 6);
      render (18 - (j * 3 + (2 - i)));
    done;
  done;
  Gl.flush ();
  ;;

let main () = 
  Glut.initWindowSize ~w:475 ~h:950;
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~depth:true ();
  ignore(Glut.createWindow "GLUT geometric shapes");
  Glut.displayFunc display;
  Glut.reshapeFunc reshape;

  GlClear.color (1.0, 1.0, 1.0);
  GlDraw.color (0.0, 0.0, 0.0);
  GlLight.light ~num:0 (`diffuse light_diffuse);
  GlLight.light ~num:0 (`position light_position);
  Gl.enable `light0; 
  Gl.enable `depth_test; 
  GlMat.mode `projection;
  GluMat.perspective ~fovy:22.0 ~aspect:1.0 ~z:(1.0, 10.0);
  GlMat.mode `modelview;
  GluMat.look_at 
    ~eye:(0.0, 0.0, 5.0)
    ~center:(0.0, 0.0, 0.0)
    ~up:(0.0, 1.0, 0.0);
  GlMat.translate3 (0.0, 0.0, -3.0);
  GlMat.rotate ~angle:25.0 ~x:1.0 ();
  GlMat.rotate ~angle:5.0 ~y:1.0 ();

  Glut.mainLoop();
  ;;

let _ = main();;

