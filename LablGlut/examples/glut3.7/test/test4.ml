#!/usr/bin/env lablglut

(*
   Copyright (c) Mark J. Kilgard, 1994. 

   This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. 

   Ported to lablglut by Issac Trotts on Aug 5, 2002.

*)

open Printf;;

let ch = ref(-2);;

let font = ref Glut.STROKE_ROMAN;;

let tick () = 
  incr ch;
  if (!ch > 180) then begin
    if (!font == Glut.STROKE_MONO_ROMAN) then begin
      printf("PASS: test4\n");
      exit(0);
      end
    ch := -2;
    font := Glut.STROKE_MONO_ROMAN;
    end;
  Glut.postRedisplay(); 
  ;;

let mytick () = ();;

let display () =
  GlClear.clear [`color];
  GlMat.push ();
  Glut.strokeCharacter !font !ch ;
  GlMat.pop ();
  Glut.swapBuffers();
  ;;

let main() = 
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~double_buffer:true ~alpha:false ();
  Glut.initWindowSize 200 200 ;
  ignore(Glut.createWindow "Test stroke fonts");
  Glut.idleFunc (Some tick); 
  if (Glut.get(Glut.WINDOW_COLORMAP_SIZE) <> 0) then 
    failwith "bad RGBA colormap size";
  GlMat.mode `projection;
  GlMat.load_identity();
  GluMat.ortho2d (-50.0, 150.0) (-50.0, 150.0);
  GlClear.color (0.0, 0.0, 0.0);
  GlDraw.color (1.0, 1.0, 1.0);
  Glut.displayFunc(display);
  Glut.mainLoop();
  ;;

let _ = main();;


