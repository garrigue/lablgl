#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21:18:32 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This test makes sure that if you post a redisplay within a
   display callback  another display callback will be
   generated. I believe this is useful for progressive
   refinement of an image.  Draw it once at a coarse
   tesselation to get something on the screen; then redraw at a
   higher level of tesselation.  Pre-GLUT 2.3 fails this test. *)

let light_position = [|1.0, 1.0, 1.0, 0.0|];;
let qobj = GluQuadric.create ();;

let tesselation = ref 3;;

let displayFunc () = 
  fprintf stderr  " %d"  !tesselation ;
  flush stderr;
  (* if (!tesselation > 23) then begin *)
  if (!tesselation > 60) then begin 
    printf("\nPASS ->  test15\n");
    exit(0);
    end;
  GlClear.clear [`color; `depth];
  GluQuadric.sphere ~quad:qobj ~radius:1.0 
    ~slices:!tesselation  ~stacks:!tesselation ();
  Glut.swapBuffers();
  incr tesselation;
  Glut.postRedisplay();
  ;;

let timefunc ~value = failwith "test15";;

let main () = 
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~depth:true ~double_buffer:true ~alpha:false ();
  ignore(Glut.createWindow("test15"));
  Glut.displayFunc(displayFunc);

  GluQuadric.draw_style qobj  `fill ;
  GlLight.light ~num:0  (`diffuse (1.0, 0.0, 0.0, 1.0));
  GlLight.light ~num:0  (`position (1.0, 1.0, 1.0, 0.)); 
  Gl.enable `lighting; 
  Gl.enable `light0;
  Gl.enable `depth_test;
  GlMat.mode `projection;
  GluMat.perspective ~fovy:22.0  ~aspect:1.0 ~z:(1.0, 10.0);
  GlMat.mode `modelview;
  GluMat.look_at 
    ~eye:(0.0, 0.0, 5.0)
    ~center:(0.0, 0.0, 0.0)
    ~up:(0.0, 1.0, 0.0);      (* up is in postivie Y direction *)
  GlMat.translate3 (0.0, 0.0, -1.0);

  (* Have a reasonably large timeout since some machines make
     take a while to render all those polygons. *)
  Glut.timerFunc 15000  timefunc  1 ;

  fprintf stderr  "tesselations =" ;
  Glut.mainLoop();
  ;;

let _ = main();;

