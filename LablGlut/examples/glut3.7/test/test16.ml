#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21:18:33 MDT 2002. *)

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Exercise all the GLUT shapes. *)

#load "unix.cma"
open Printf

let shape = ref 1;;

let writeln s = print_string s; print_newline();;

let displayFunc () = 
  fprintf stderr  " %d\n"  !shape ; flush stderr;
  GlClear.clear [`color; `depth];
  begin 
    match !shape with
    | 1 -> Glut.wireSphere 1.0  20  20 ;
    | 2 -> Glut.solidSphere 1.0  20  20 ;
    | 3 -> Glut.wireCone 1.0  1.0  20  20 ;
    | 4 -> Glut.solidCone 1.0  1.0  20  20 ;
    | 5 -> Glut.wireCube 1.0;
    | 6 -> Glut.solidCube 1.0;
    | 7 -> Glut.wireTorus 0.5  1.0  15  15 ;
    | 8 -> Glut.solidTorus 0.5  1.0  15  15 ;
    | 9 -> Glut.wireDodecahedron();
    | 10 -> Glut.solidDodecahedron();
    | 11 -> Glut.wireTeapot 1.0;
    | 12 -> Glut.solidTeapot 1.0;
    | 13 -> Glut.wireOctahedron();
    | 14 -> Glut.solidOctahedron();
    | 15 -> Glut.wireTetrahedron();
    | 16 -> Glut.solidTetrahedron();
    | 17 -> Glut.wireIcosahedron();
    | 18 -> Glut.solidIcosahedron();
    | _ -> 
      begin
        printf("\nPASS : test16\n");
        exit(0);
      end;
  end;
  Glut.swapBuffers();
  incr shape;
  Unix.sleep(1); 
  Glut.postRedisplay();
  ;;

let timefunc ~value = failwith "test16";;

let main () = 
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~depth:true ~double_buffer:true ~alpha:false ();
  ignore(Glut.createWindow("test16"));
  Glut.displayFunc(displayFunc);

  GlLight.light ~num:0 (`diffuse (1.0, 0.0, 0.0, 1.0)) ;
  GlLight.light ~num:0 (`position (1.0, 1.0, 1.0, 1.0)) ; 
  List.iter Gl.enable [`lighting; `light0; `depth_test ];
  GlMat.mode `projection;
  GluMat.perspective ~fovy:22.0 ~aspect:1.0 ~z:(1.0, 10.0) ;
  GlMat.mode `modelview ;
  GluMat.look_at 
    ~eye:(0.0, 0.0, 5.0)
    ~center:(0.0, 0.0, 0.0)
    ~up:(0.0, 1.0, 0.0);      
  GlMat.translate3 (0.0,  0.0,  -3.0);
  GlMat.rotate ~angle:25.0 ~x:1.0  ~y:0.0  ~z:0.0 ();

  (* Have a reasonably large timeout since some machines make
     take a while to render all those polygons. *)
  Glut.timerFunc 35000  timefunc  1;

  Glut.mainLoop();
  ;;

let _ = main();;

