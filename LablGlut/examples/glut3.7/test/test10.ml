#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Tue Aug  6 21 -> 18 -> 29 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* XXX As a test of 16-bit font support in capturexfont  I made
   a font out of the 16-bit Japanese font named
   '-jis-fixed-medium-r-normal--24-230-75-75-c-240-jisx0208.1'
   and tried it out.  Defining JIS_FONT uses it in this test. *)
(* #define JIS_FONT *)

(*  
  hmmm... how do we emulate this in OCaml? -ijt
#ifdef JIS_FONT
extern void *Glut.bitmapJis;
#endif
*)

let ch = ref (-2);;

let fonts = [|
  Glut.BITMAP_TIMES_ROMAN_24 ;
  Glut.BITMAP_TIMES_ROMAN_10 ;
  Glut.BITMAP_9_BY_15 ;
  Glut.BITMAP_8_BY_13 ;
  Glut.BITMAP_HELVETICA_10 ;
  Glut.BITMAP_HELVETICA_12 ;
  Glut.BITMAP_HELVETICA_18 
(* #ifdef JIS_FONT *)
  (* &glutBitmapJis *)
(* #endif *)
  |];;

let names = [|
  "Times Roman 24" ;
  " Times Roman 10" ;
  "  9 by 15" ;
  "   8 by 13" ;
  "    Helvetica 10" ;
  "     Helvetica 12" ;
  "      Helvetica 18" 
(* #ifdef JIS_FONT *)
  (* "    Mincho JIS" *)
(* #endif *)
  |];;

let num_fonts = (Array.length fonts);;
let font = ref 0;;

let limit = ref 270;; 
let tick () = 
  ch := !ch + 5;
  if (!ch > !limit) then begin
    ch := -2;
    incr font;
    end;
(* #ifdef JIS_FONT
    if (font = 4) then
      limit = 0x747e;
      ch = 0x2121;
#endif *)
    if (!font = num_fonts) then begin
      printf("PASS ->  test10\n");
      exit(0);
      end
  Glut.postRedisplay();
  ;;

let output ~x ~y ~msg = 
  GlPix.raster_pos ~x ~y ();
  for i=0 to ((String.length msg)-1) do 
    Glut.bitmapCharacter Glut.BITMAP_9_BY_15  (int_of_char msg.[i]);
    done
  ;;

let display () =
  Glut.idleFunc(Some tick);
  GlClear.clear [`color];
  GlPix.raster_pos ~x:0.0 ~y:0.0 ();
  Glut.bitmapCharacter fonts.(!font)  !ch ;
  GlPix.raster_pos 30.0  30.0 ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 1) ;
  GlPix.raster_pos (-30.0)  (-30.0) ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 2) ;
  GlPix.raster_pos 30.0  (-30.0) ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 3) ;
  GlPix.raster_pos (-30.0)  30.0  ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 4) ;
  GlPix.raster_pos 0.0  30.0  ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 5) ;
  GlPix.raster_pos 0.0  (-30.0) ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 6) ;
  GlPix.raster_pos(-30.0)  0.0  ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 7) ;
  GlPix.raster_pos 30.0  0.0  ();
  Glut.bitmapCharacter fonts.(!font)  (!ch + 8) ;
  output (-48.0)  (-48.0) names.(!font);
  Glut.swapBuffers();
  ;;

let main() = 
  ignore(Glut.init Sys.argv);
  Glut.initDisplayMode ~double_buffer:true ~alpha:false (); 
  Glut.initWindowSize 200  200 ;
  ignore(Glut.createWindow("Test bitmap fonts"));
  GlMat.mode  `projection ;
  GlMat.load_identity ();
  GluMat.ortho2d ~x:(-50.0, 50.0)  ~y:(-50.0, 50.0);
  GlClear.color (0.0, 0.0, 0.0);
  GlDraw.color (1.0, 1.0, 1.0);
  Glut.displayFunc(display);
  Glut.mainLoop();
  ;;

let _ = main();;

