#!/usr/bin/env lablglut

(* Copyright (c) Mark J. Kilgard  1996  1997. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

(* Test Glut.extensionSupported. *)

(* Ported to lablglut by Issac Trotts on Sat Aug 10 2002. *)

open Printf

let wrangleExtensionName ~extension = 
  let buffer = ref "" in
  buffer := sprintf " %s" extension;
  let rc = Glut.extensionSupported !buffer in
  if rc then failwith "test20  space prefix";

  buffer := sprintf "%s " extension;
  let rc = Glut.extensionSupported !buffer in
  if rc then failwith "test20  space suffix";

  buffer := sprintf "GL_%s" extension;
  let rc = Glut.extensionSupported !buffer in
  if rc then failwith "test20  GL_ prefix";

  let len = (String.length extension) in
  let rc = Glut.extensionSupported (String.sub extension 1 (len-1)) in 
  if rc then failwith "test20  missing first character";

  buffer := sprintf "%s" extension;
  let len = (String.length !buffer) in 
  if len > 0 then buffer := String.sub !buffer 0 (len-1);
  let rc = Glut.extensionSupported !buffer in
  if rc then failwith "test20  mising last character";

  buffer := sprintf "%s" extension;
  let len = (String.length !buffer) in
  if len > 0 then (!buffer).[len-1] <- 'X';
  let rc = Glut.extensionSupported !buffer in
  if rc then failwith "test20  changed last character";
  ;;

let main () = 
  ignore(Glut.init Sys.argv);
  ignore(Glut.createWindow "test20");

  let extension = ref "" in
  extension := "GL_EXT_blend_color";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if rc then wrangleExtensionName !extension;

  extension := "GL_EXT_abgr";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if rc then wrangleExtensionName !extension;

  extension := "GL_EXT_blend_minmax";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  extension := "GL_EXT_blend_logic_op";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  extension := "GL_EXT_blend_subtract";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  extension := "GL_EXT_polygon_offset";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  extension := "GL_EXT_subtexture";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  extension := "GL_EXT_texture";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  extension := "GL_EXT_texture_object";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  extension := "GL_SGIX_framezoom";
  let rc = Glut.extensionSupported !extension in
  printf "extension %s is %s by your OpenGL.\n"  !extension (if rc then "SUPPORTED\n" else "NOT supported");
  if  rc then wrangleExtensionName !extension;

  let rc = Glut.extensionSupported "" in
  if  rc then failwith "test20  null string";

  printf "PASS: test20";
  ;;

let _ = main();;

