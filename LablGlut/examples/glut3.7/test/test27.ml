#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21 -> 18 -> 43 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This tests creation of a subwindow that gets "popped" to
   check if it also (erroneously) gets moved.  GLUT 3.5 had
   this bug (fixed in GLUT 3.6). *)

let parent = ref 0;;
let child = ref 0;;

let parentDrawn = ref false;;
let childDrawn = ref false;;

let failTest ~value = failwith(" test27\n") ;;

let passTest ~value = 
  printf("PASS ->  test27\n");
  exit(0);
  ;;

let installFinish () = 
  if (!childDrawn && !parentDrawn) then
    Glut.timerFunc 1000  passTest  0 ;
  ;;

let output ~x ~y ~str = 
  GlPix.raster_pos ~x ~y ();
  let len = (String.length str) in 
  for i = 0 to (len-1) do 
    Glut.bitmapCharacter Glut.BITMAP_9_BY_15  (int_of_char str.[i]) ;
    done
  ;;

let displayParent () = 
  GlClear.clear [`color];
  Gl.flush();
  parentDrawn := true;
  installFinish();
  ;;

let displayChild () = 
  GlClear.clear [`color];
  output(-0.4) (0.5)  "this";
  output(-0.8) (0.1)  "subwindow";
  output(-0.8) (-0.3)  "should be";
  output(-0.7) (-0.7)  "centered";
  Gl.flush();
  childDrawn := true;
  installFinish();
  ;;

let main () = 
  ignore(Glut.init Sys.argv);
  Glut.initWindowSize 300  300 ;
  Glut.initWindowPosition 5  5 ;
  Glut.initDisplayMode ~alpha:false ();
  parent := Glut.createWindow("test27");
  GlClear.color (1.0, 0.0, 0.0);
  Glut.displayFunc(displayParent);
  let possible = Glut.getBool Glut.DISPLAY_MODE_POSSIBLE in
  if not possible then
    failwith(sprintf " Glut.get returned display mode not possible ->  %d\n"  
      (if possible then 1 else 0));
  child := Glut.createSubWindow ~win:!parent ~x:100  ~y:100 ~w:100 ~h:100 ;
  GlClear.color (0.0, 1.0, 0.0);
  GlDraw.color (0.0, 0.0, 0.0);
  Glut.displayFunc(displayChild);
  Glut.popWindow();

  Glut.timerFunc 10000  failTest  0 ;

  Glut.mainLoop();
  ;;

let _ = main();;

