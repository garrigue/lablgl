#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 17:48:54 MDT 2002. *)

open Printf

let win = ref(-1)
let subwin = ref(-1)
let mainmenu = ref(-1)
let submenu = ref(-1)
let item = ref 666

let fail where = failwith ("menu_test failed in "^where)

let display () = 
  GlClear.clear [`color];
  Gl.flush();
  ;;

let gokey ~key ~x ~y = 
  let mods = Glut.getModifiers() in
  printf "key = %d  mods = 0x%x\n" key mods;
  if (mods land Glut.active_alt <> 0) then
    match char_of_int key with
    | '1' -> begin
      printf "Change to sub menu 1\n";
      Glut.changeToSubMenu 1 "sub 1" !submenu;
      end
    | '2' -> begin
      printf "Change to sub menu 2\n";
      Glut.changeToSubMenu 2 "sub 2" !submenu;
      end
    | '3' -> begin
      printf "Change to sub menu 3\n";
      Glut.changeToSubMenu 3  "sub 3"  !submenu;
      end
    | '4' -> begin
      printf "Change to sub menu 4\n";
      Glut.changeToSubMenu 4  "sub 4"  !submenu;
      end
    | '5' -> begin
      printf "Change to sub menu 5\n";
      Glut.changeToSubMenu 5  "sub 5"  !submenu;
      end;
    | _ -> ();
  else 
    match char_of_int key with
    | '1' -> begin
      printf "Change to menu entry 1\n";
      Glut.changeToMenuEntry 1  "entry 1"  1;
      end
    | '2' -> begin
      printf "Change to menu entry 2\n";
      Glut.changeToMenuEntry 2  "entry 2"  2;
      end
    | '3' -> begin
      printf "Change to menu entry 3\n";
      Glut.changeToMenuEntry 3  "entry 3"  3;
      end
    | '4' -> begin
      printf "Change to menu entry 4\n";
      Glut.changeToMenuEntry 4  "entry 4"  4;
      end
    | '5' -> begin
      printf "Change to menu entry 5\n";
      Glut.changeToMenuEntry 5  "entry 5"  5;
      end
    | 'a' | 'A' -> begin
      printf "Adding menu entry %d\n" !item;
      Glut.addMenuEntry (sprintf "added entry %d" !item) !item;
      incr item;
      end
    | 's' | 'S' -> begin
      printf "Adding !submenu %d\n" !item;
      Glut.addSubMenu (sprintf "added !submenu %d" !item)  !submenu;
      incr item;
      end
    | 'q' -> begin
      printf "Remove 1\n";
      Glut.removeMenuItem 1;
      end
    | 'w' -> begin
      printf "Remove 2\n";
      Glut.removeMenuItem 2;
      end
    | 'e' -> begin
      printf "Remove 3\n";
      Glut.removeMenuItem 3;
      end
    | 'r' -> begin
      printf "Remove 4\n";
      Glut.removeMenuItem 4;
      end
    | 't' -> begin
      printf "Remove 5\n";
      Glut.removeMenuItem 5;
      end
    | _ -> (); 
  ;;

let keyboard ~key ~x ~y = 
  Glut.setMenu !mainmenu;
  gokey key x y;
  ;;

let keyboard2 ~key ~x ~y = 
  Glut.setMenu !submenu;
  gokey key x y;
  ;;

let menu ~value = printf "menu: entry = %d\n" value ;;

let menu2 ~value = printf "menu2: entry = %d\n" value ;;

let main () = 
  ignore(Glut.init Sys.argv);
  win := Glut.createWindow "menu test";
  GlClear.color (0.3, 0.3, 0.3);
  Glut.displayFunc display;
  Glut.keyboardFunc keyboard;
  submenu := Glut.createMenu menu2;
  Glut.addMenuEntry "Sub menu 1"  1001;
  Glut.addMenuEntry "Sub menu 2"  1002;
  Glut.addMenuEntry "Sub menu 3"  1003;
  mainmenu := Glut.createMenu menu;
  Glut.addMenuEntry "First"  (-1);
  Glut.addMenuEntry "Second"  (-2);
  Glut.addMenuEntry "Third"  (-3);
  Glut.addSubMenu "Submenu init" !submenu;
  Glut.attachMenu Glut.RIGHT_BUTTON;
  subwin := Glut.createSubWindow !win  50  50  50  50;
  GlClear.color (0.7, 0.7, 0.7);
  Glut.displayFunc display;
  Glut.keyboardFunc keyboard2;
  Glut.mainLoop ();
  ;;

let _ = main();;

