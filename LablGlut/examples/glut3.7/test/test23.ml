#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Sat Aug 10 12:12:42 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This tests unexpected interactions between
   Glut.initDisplayMode and Glut.initDisplayString. *)

let modes = [|
  Glut.rgb lor Glut.single;
  Glut.rgb lor Glut.double;
  Glut.index lor Glut.single;
  Glut.index lor Glut.double 
  |];;

let strings = [|
  "rgb double" ;
  "rgba double" ;
  "rgba single" ;
  "index" ;
  "index double" ;
  "rgb samples=4" ;
  "stencil depth red green blue alpha conformant auxbufs buffer acc acca double rgb rgba" ;
  "stereo index samples slow" 
  |];;

let ostrings = [| 
  "index double" ;
  "index single" ;
  "index buffer=4" ;
  "index buffer=8" ;
  "index buffer~4" ;
  "index buffer=4 depth" 
  |];;

let verbose = ref false;;

let main () = 
  ignore(Glut.init Sys.argv);
  if Array.length Sys.argv > 1 then
    if Sys.argv.(1) <>  "-v" then
      verbose := true;
  Glut.initWindowPosition 10 10;
  Glut.initWindowSize 200 200;
  for k = 0 to ((Array.length modes)-1) do 
    let m = modes.(k) in
    Glut.initDisplayMode 
      ~index:(m land Glut.index <> 0) 
      ~double_buffer:(m land Glut.double <> 0) ();
    printf "Display Mode = %d (%s %s)" m
      (if m land Glut.index <> 0 then "index" else "rgba") 
      (if m land Glut.double <> 0 then "double" else "single");
    print_newline();
    for i = 0 to ((Array.length strings)-1) do 
      Glut.initDisplayString(strings.(i));
      if Glut.getBool Glut.DISPLAY_MODE_POSSIBLE then begin
        if !verbose then printf "  Possible: %s\n"  strings.(i);
        let win = Glut.createWindow("test23") in
        if !verbose then printf "    Created: %s\n" strings.(i);
        for j = 0 to ((Array.length ostrings)-1) do 
          Glut.initDisplayString(ostrings.(j));
          if (Glut.layerGet Glut.OVERLAY_POSSIBLE) then begin
            if !verbose then begin
              printf "    Overlay possible: %s" ostrings.(j);
              print_newline();
              end;
            Glut.establishOverlay();
            if !verbose then begin
              printf "      Overlay establish: %s" ostrings.(j);
              print_newline();
              end;
            Glut.removeOverlay();
            if !verbose then begin
              printf "        Overlay remove: %s" ostrings.(j);
              print_newline();
              end;
            end;
          done;
        Glut.destroyWindow(win);
        if !verbose then printf "      Destroyed: %s\n"  strings.(i);
        end else if !verbose then printf "Not possible: %s\n" strings.(i);
      done
    done;

  Glut.initDisplayString "";

  let num = ref 1 
  and exists = ref true in
  while !exists do
    let mode = sprintf "rgb num=%d" !num in 
    Glut.initDisplayString mode;
    exists := Glut.getBool Glut.DISPLAY_MODE_POSSIBLE;
    if !exists then begin
      if !verbose then printf "  Possible: %s\n" mode;
      let win = Glut.createWindow("test23") in
      if !verbose then printf "    Created: %s\n" mode;
      Glut.destroyWindow(win);
      if !verbose then printf "      Destroyed: %s\n" mode;
      let mode = sprintf "rgb num=0x%x" !num in
      Glut.initDisplayString(mode);
      exists := Glut.getBool Glut.DISPLAY_MODE_POSSIBLE;
      if not !exists then failwith("test23 (hex num= don't work)\n");
      let win = Glut.createWindow "test23" in
      Glut.destroyWindow win;
      incr num;
    end else if !verbose then printf "Not possible: %s\n" mode;
  done;

  Glut.initDisplayString "";

  printf "PASS: test23\n";
  ;;

let _ = main();;

