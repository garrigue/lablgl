#!/usr/bin/env lablglut

(*
   Copyright (c) Mark J. Kilgard, 1994. 

   This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain.   

   Ported to lablglut by Issac Trotts on Aug 5, 2002.

*)

open Printf

let n = 6;;
let m = 6;;

let exposed = Array.create (m*n) false;;
let ecount = ref 0;;

let viewable = Array.create (m*n) false;;
let vcount = ref 0;;

let display () = 
  let win = Glut.getWindow() - 1 in
  if not exposed.(win) then begin
    exposed.(win) <- true;
    incr ecount;
    end;
  GlClear.clear [`depth];
  Gl.flush();
  if (!ecount == (m * n)) && (!vcount == (m * n)) then begin
    printf("PASS: test3\n");
    exit(0);
    end
  ;;

let view ~state = 
  let win = Glut.getWindow() - 1 in
  if not viewable.(win) then begin
    viewable.(win) <- true;
    incr vcount;
    end;
  if ((!ecount == (m * n)) && (!vcount == (m * n))) then begin
    printf("PASS: test3\n");
    exit(0);
    end
  ;;

let timer ~value = if (value <> 23) then failwith "bad timer value";;

let main () = 
  ignore(Glut.init Sys.argv);
  Glut.initWindowSize 10  10 ;
  Glut.initDisplayMode ~double_buffer:false ~alpha:false ();
  for i = 0 to (m - 1) do 
    for j = 0 to (n - 1) do 
      exposed.(i * n + j) <- false;
      viewable.(i * n + j) <- false;
      Glut.initWindowPosition (100 * i) (100 * j);
      ignore(Glut.createWindow(sprintf "%d\n" (i*n + j + 1)));
      Glut.displayFunc display ;
      Glut.visibilityFunc view ;
      GlClear.color ~alpha:1.0 (1.0, 0.0, 0.0) ;
      done
    done;
  (* XXX Hopefully in 45 seconds, all the windows should
     appear, or they probably won't ever appear! *)
  Glut.timerFunc (45 * 1000) timer 23;
  Glut.mainLoop();
  ;;

let _ = main();;

