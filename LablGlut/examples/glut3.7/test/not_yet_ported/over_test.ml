#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Sun Aug 11 14:56:22 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

#include <stdlib.h>
#include <stdio.h>
#include <GL/Glut..h>

int on = 0;
int independent = 0;
int main_w  hidden_w  s1  s2;
float x = 0  y = 0;

void
overlay_display(void)
  printf("overlay_display: damaged=%d\n"  Glut.layerGet(Glut.OVERLAY_DAMAGED));
  if (on) then
    Glut.useLayer(Glut.OVERLAY);
    GlClear.clear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_POLYGON);
    glVertex2f(.2 + x  .2 + y);
    glVertex2f(.5 + x  .5 + y);
    glVertex2f(.2 + x  .5 + y);
    glEnd();
    Gl.flush();
  ;;

void
display(void)
  printf("normal_display: damaged=%d\n"  Glut.layerGet(Glut.NORMAL_DAMAGED));
  Glut.useLayer(Glut.NORMAL);
  GlClear.clear(GL_COLOR_BUFFER_BIT);
  glColor3f(1.0  0.0  0.0);
  glBegin(GL_POLYGON);
  glVertex2f(.2  .28);
  glVertex2f(.5  .58);
  glVertex2f(.2  .58);
  glEnd();

  if ( not independent) then
    overlay_display();
  } else {
    printf("not calling overlay_display\n");
  ;;

void
hidden_display(void)
  printf("hidden_display: this should not be called ever\n");
  ;;

void
reshape(int w  int h)
  Glut.useLayer(Glut.NORMAL);
  glViewport(0  0  w  h);

  if (on) then
    Glut.useLayer(Glut.OVERLAY);
    glViewport(0  0  w  h);
    printf("w=%d  h=%d\n"  w  h);
  ;;

void
special(int c  int w  int h)
  printf("special %d  w=%d h=%d\n"  c  w  h);
  if (on) then
    match c with
    | Glut.KEY_LEFT ->
      x -= 0.1;
      break;
    | Glut.KEY_RIGHT ->
      x += 0.1;
      break;
    | Glut.KEY_UP ->
      y += 0.1;
      break;
    | Glut.KEY_DOWN ->
      y -= 0.1;
      break;
    Glut.postOverlayRedisplay();
  ;;

void
key(unsigned char c  int w  int h)
  int transP;

  printf("c=%d  w=%d h=%d\n"  c  w  h);
  match c with
  | 'e' ->
    Glut.establishOverlay();
    independent = 0;
    transP = Glut.layerGet(Glut.TRANSPARENT_INDEX);
    GlClear.clearIndex(transP);
    Glut.setColor((transP + 1) % 2  1.0  1.0  0.0);
    glIndexi((transP + 1) % 2);
    on = 1;
    break;
  | 'r' ->
    Glut.removeOverlay();
    on = 0;
    break;
  | 'm' ->
    if (Glut.layerGet(Glut.HAS_OVERLAY)) then
      int pixel;
      GLfloat red  green  blue;

      transP = Glut.layerGet(Glut.TRANSPARENT_INDEX);
      pixel = (transP + 1) % 2;
      red = Glut.getColor(pixel  Glut.RED) + 0.2;
      if (red > 1.0)
        red = red - 1.0;
      green = Glut.getColor(pixel  Glut.GREEN) - 0.1;
      if (green > 1.0)
        green = green - 1.0;
      blue = Glut.getColor(pixel  Glut.BLUE) + 0.1;
      if (blue > 1.0)
        blue = blue - 1.0;
      Glut.setColor(pixel  red  green  blue);
    break;
  | 'h' ->
    Glut.setWindow(hidden_w);
    Glut.hideWindow();
    Glut.setWindow(s2);
    Glut.hideWindow();
    break;
  | 's' ->
    Glut.setWindow(hidden_w);
    Glut.showWindow();
    Glut.setWindow(s2);
    Glut.showWindow();
    break;
  | 'H' ->
    Glut.hideOverlay();
    break;
  | 'S' ->
    Glut.showOverlay();
    break;
  | 'D' ->
    Glut.destroyWindow(main_w);
    exit(0);
    break;
  | ' ' ->
    printf("overlay possible: %d\n"  Glut.layerGet(Glut.OVERLAY_POSSIBLE));
    printf("layer in  use: %d\n"  Glut.layerGet(Glut.LAYER_IN_USE));
    printf("has overlay: %d\n"  Glut.layerGet(Glut.HAS_OVERLAY));
    printf("transparent index: %d\n"  Glut.layerGet(Glut.TRANSPARENT_INDEX));
    break;
  ;;

(* ARGSUSED1 *)
void
key2(unsigned char c  int w  int h)
  int transP;

  printf("c=%d\n"  c);
  match c with
  | 'g' ->
    Glut.reshapeWindow(
      Glut.get(Glut.WINDOW_WIDTH) + 2  Glut.get(Glut.WINDOW_HEIGHT) + 2);
    break;
  | 's' ->
    Glut.reshapeWindow(
      Glut.get(Glut.WINDOW_WIDTH) - 2  Glut.get(Glut.WINDOW_HEIGHT) - 2);
    break;
  | 'u' ->
    Glut.popWindow();
    break;
  | 'd' ->
    Glut.pushWindow();
    break;
  | 'e' ->
    Glut.establishOverlay();
    transP = Glut.layerGet(Glut.TRANSPARENT_INDEX);
    GlClear.clearIndex(transP);
    Glut.setColor((transP + 1) % 2  0.0  0.25  0.0);
    glIndexi((transP + 1) % 2);
    break;
  | 'c' ->
    if (Glut.layerGet(Glut.HAS_OVERLAY)) then
      Glut.useLayer(Glut.OVERLAY);
      Glut.copyColormap(main_w);
    break;
  | 'r' ->
    Glut.removeOverlay();
    break;
  | ' ' ->
    printf("overlay possible: %d\n"  Glut.layerGet(Glut.OVERLAY_POSSIBLE));
    printf("layer in  use: %d\n"  Glut.layerGet(Glut.LAYER_IN_USE));
    printf("has overlay: %d\n"  Glut.layerGet(Glut.HAS_OVERLAY));
    printf("transparent index: %d\n"  Glut.layerGet(Glut.TRANSPARENT_INDEX));
    break;
  ;;

void
vis(int state)
  if (state = Glut.VISIBLE)
    printf("visible %d\n"  Glut.getWindow());
  else
    printf("NOT visible %d\n"  Glut.getWindow());
  ;;

void
entry(int state)
  if (state = Glut.LEFT)
    printf("LEFT %d\n"  Glut.getWindow());
  else
    printf("entered %d\n"  Glut.getWindow());
  ;;

void
motion(int x  int y)
  printf("motion x=%x y=%d\n"  x  y);
  ;;

void
mouse(int b  int s  int x  int y)
  printf("b=%d  s=%d  x=%d y=%d\n"  b  s  x  y);
  ;;

void
display2(void)
  Glut.useLayer(Glut.NORMAL);
  GlClear.clear(GL_COLOR_BUFFER_BIT);
  Gl.flush();

  if (Glut.layerGet(Glut.HAS_OVERLAY)) then
    Glut.useLayer(Glut.OVERLAY);
    GlClear.clear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_POLYGON);
    glVertex2f(.2  .28);
    glVertex2f(.5  .58);
    glVertex2f(.2  .58);
    glEnd();
    Gl.flush();
  ;;

void
dial(int dial  int value)
  printf("dial %d %d (%d)\n"  dial  value  Glut.getWindow());
  ;;

void
box(int button  int state)
  printf("box %d %d (%d)\n"  button  state  Glut.getWindow());
  ;;

void
main_menu(int option)
  match option with
  | 1 ->
    if (Glut.layerGet(Glut.HAS_OVERLAY)) then
      independent = 1;
      Glut.overlayDisplayFunc(overlay_display);
    break;
  | 2 ->
    if (Glut.layerGet(Glut.HAS_OVERLAY)) then
      independent = 0;
      Glut.overlayDisplayFunc(NULL);
    break;
  | 666 ->
    exit(0);
    break;
  ;;

void
s2_menu(int option)
  int transP;

  match option with
  | 1 ->
    Glut.removeOverlay();
    break;
  | 2 ->
    Glut.establishOverlay();
    transP = Glut.layerGet(Glut.TRANSPARENT_INDEX);
    GlClear.clearIndex(transP);
    Glut.setColor((transP + 1) % 2  0.0  0.25  0.0);
    glIndexi((transP + 1) % 2);
    break;
  | 666 ->
    exit(0);
    break;
  ;;

int
main(int argc  char **argv)
  Glut.init( land argc  argv);

  Glut.initDisplayMode(Glut.RGB);
  Glut.initWindowSize(210  210);

  main_w = Glut.createWindow("overlay test");
  Glut.displayFunc(display);
  Glut.reshapeFunc(reshape);
  GlClear.clearColor(1.0  0.0  1.0  1.0);

  Glut.keyboardFunc(key);
  Glut.visibilityFunc(vis);
  Glut.entryFunc(entry);
  Glut.specialFunc(special);

  Glut.motionFunc(motion);
  Glut.mouseFunc(mouse);

  Glut.createMenu(main_menu);
  Glut.addMenuEntry("Dual display callbacks"  1);
  Glut.addMenuEntry("Single display callbacks"  2);
  Glut.addMenuEntry("Quit"  666);
  Glut.attachMenu(Glut.RIGHT_BUTTON);

  hidden_w = Glut.createSubWindow(main_w  10  10  100  90);
  (* hidden_w is completely obscured by its own s1 subwindow.
     While display  entry and visibility callbacks are 
     registered  they will never be called. *)
  Glut.displayFunc(hidden_display);
  Glut.entryFunc(entry);
  Glut.visibilityFunc(vis);

  s1 = Glut.createSubWindow(hidden_w  0  0  100  90);
  GlClear.clearColor(0.0  0.0  1.0  1.0);
  Glut.displayFunc(display2);
#if 0
  Glut.keyboardFunc(key2);
#endif
  Glut.visibilityFunc(vis);
  Glut.entryFunc(entry);

  s2 = Glut.createSubWindow(main_w  35  35  100  90);
  GlClear.clearColor(0.5  0.0  0.5  1.0);
  Glut.displayFunc(display2);
#if 1
  Glut.keyboardFunc(key2);
#endif
  Glut.visibilityFunc(vis);
  Glut.entryFunc(entry);

#if 1
  Glut.createMenu(s2_menu);
  Glut.addMenuEntry("Remove overlay"  1);
  Glut.addMenuEntry("Establish overlay"  2);
  Glut.addMenuEntry("Quit"  666);
  Glut.attachMenu(Glut.RIGHT_BUTTON);
#endif

  Glut.initDisplayMode(Glut.INDEX);

#if 1
  Glut.setWindow(main_w);
  Glut.dialsFunc(dial);
  Glut.buttonBoxFunc(box);
#endif

  Glut.mainLoop();
  return 0;             (* ANSI C requires main to return int. *)
let _ = main();;
