#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* This tests Glut.bitmapLength and Glut.strokeLength. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 2002. *)

open Printf

let abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

let null = ""
let space = "      "

let bitmap_fonts = [|
  Glut.BITMAP_TIMES_ROMAN_24 ;
  Glut.BITMAP_TIMES_ROMAN_10 ;
  Glut.BITMAP_9_BY_15 ;
  Glut.BITMAP_8_BY_13 ;
  Glut.BITMAP_HELVETICA_10 ;
  Glut.BITMAP_HELVETICA_12 ;
  Glut.BITMAP_HELVETICA_18 |]

let bitmap_names = [| 
  "Times Roman 24" ;
  "Times Roman 10" ;
  "9 by 15" ;
  "8 by 13" ;
  "Helvetica 10" ;
  "Helvetica 12" ;
  "Helvetica 18" |]

let bitmap_lens = [|
  2399 ;
  1023 ;
  2016 ;
  1792 ;
  1080 ;
  1291 ;
  1895 |]

let bitmap_abc_lens = [|
  713 ;
  305 ;
  468 ;
  416 ;
  318 ;
  379 ;
  572 |]

let stroke_fonts = [|
  Glut.STROKE_ROMAN ;
  Glut.STROKE_MONO_ROMAN |]

let stroke_names = [|
  "Roman" ;
  "Monospaced Roman" |]

let stroke_lens = [| 
  6635 ;
  9984 |]

let stroke_abc_lens = [|
  3683 ;
  5408 |]

(* apply the given function to values of [i] running from 0 to the length 
  of the array [a] minus one *)
let array_do a f = for i = 0 to ((Array.length a)-1) do f i done

let (+=) x y = x := !x + y;; (* :) *)

let main () = 
  ignore(Glut.init Sys.argv);

  (* Touch test the width determination of all bitmap
     characters. *)
  array_do bitmap_fonts (fun i -> 
    let font = bitmap_fonts.(i) 
    and total = ref 0 in
    for j = -2 to 258 do total := !total + Glut.bitmapWidth font j done;
    printf "  %s: bitmap total = %d (expected %d)"  
      bitmap_names.(i) !total bitmap_lens.(i);
    print_newline();
    if !total <> bitmap_lens.(i) then failwith " test25\n";
  );

  (* Touch test the width determination of all stroke
     characters. *)
  (* for i = 0 to ((Array.length stroke_fonts)-1) do *)
  array_do stroke_fonts (fun i -> 
    let font = stroke_fonts.(i) 
    and total = ref 0 in
    for j = -1 to 258 do total += Glut.strokeWidth font j done;
    printf "  %s: stroke total = %d (expected %d)\n"  
      stroke_names.(i) !total stroke_lens.(i);
    if !total <> stroke_lens.(i) then failwith(" test25\n");
  );

  array_do bitmap_fonts (fun i -> 
    let font = bitmap_fonts.(i) in
    let total = Glut.bitmapLength font abc in
    printf "  %s: bitmap abc len = %d (expected %d)\n" 
      bitmap_names.(i) total bitmap_abc_lens.(i);
    if total <> bitmap_abc_lens.(i) then failwith " test25\n";
  );

  array_do bitmap_fonts (fun i ->
    let font = bitmap_fonts.(i) in
    let total = Glut.bitmapLength font  "" in
    printf "  %s: bitmap abc len = %d (expected %d)\n" 
      bitmap_names.(i) total 0;
    if total <> 0 then failwith " test25\n";
  );

  array_do stroke_fonts (fun i ->
    let font = stroke_fonts.(i) in
    let total = Glut.strokeLength font abc in
    printf "  %s: stroke abc len = %d (expected %d)\n"  
      stroke_names.(i) total stroke_abc_lens.(i);
    if (total <> stroke_abc_lens.(i)) then failwith " test25\n";
  );

  array_do stroke_fonts (fun i -> 
    let font = stroke_fonts.(i) in
    let total = Glut.strokeLength font "" in
    printf "  %s: stroke null len = %d (expected %d)\n" 
      stroke_names.(i) total 0;
    if total <> 0 then failwith " test25\n";
  );

  printf("PASS: test25\n");
  ;;

let _ = main();;

