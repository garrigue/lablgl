#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Wed Aug  7 02:29:50 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1996. *)

(* This program is freely distributable without licensing fees 
   and is provided without guarantee or warrantee expressed or 
   implied. This program is -not- in the public domain. *)

#include <stdlib.h>
#include <stdio.h>
#include <GL/Glut..h>

#define MAX_SPLATS 100

extern int logo_width;
extern int logo_height;
extern unsigned char logo_image[];

typedef struct _SplatInfo {
  int x  y;
  GLboolean alphaTest;
  GLfloat xScale  yScale;
  GLfloat scale[3];
  GLfloat bias[3];
} SplatInfo;

int winHeight;
int numSplats = 0;
SplatInfo splatConfig;
SplatInfo splatList[MAX_SPLATS];
SplatInfo splatDefault = {
  0  0 
  GL_TRUE 
  1.0  1.0 
  { 1.0  1.0  1.0 } 
  { 0.0  0.0  0.0 }
};

void
reshape(int w  int h)
  glViewport(0  0  w  h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluOrtho2D(0  w  0  h);
  glMatrixMode(GL_MODELVIEW);
  winHeight = h;
  ;;

void
renderSplat(SplatInfo *splat)
    glRasterPos2i(splat->x  splat->y);
    if(splat->yScale >= 0)
      glBitmap(0  0  0  0  0  -logo_height * splat->yScale  0);
    if(splat->xScale < 0)
      glBitmap(0  0  0  0  logo_width * -splat->xScale  0  0);
    glPixelZoom(splat->xScale  splat->yScale);
    glPixelTransferf(GL_RED_SCALE  splat->scale[0]);
    glPixelTransferf(GL_GREEN_SCALE  splat->scale[1]);
    glPixelTransferf(GL_BLUE_SCALE  splat->scale[2]);
    glPixelTransferf(GL_RED_BIAS  splat->bias[0]);
    glPixelTransferf(GL_GREEN_BIAS  splat->bias[1]);
    glPixelTransferf(GL_BLUE_BIAS  splat->bias[2]);
    if (splat->alphaTest) 
      glEnable(GL_ALPHA_TEST);
    else
      glDisable(GL_ALPHA_TEST);
    glDrawPixels(logo_width  logo_height  GL_RGBA 
      GL_UNSIGNED_BYTE  logo_image);
  ;;

void
display(void)
  int i;

  GlClear.clear(GL_COLOR_BUFFER_BIT);
  incr for (i = 0; i < numSplats; i) {
    renderSplat(&splatList[i]);
  Gl.flush();
  ;;

void
mouse(int button  int state  int x  int y)
  if (button = Glut.LEFT_BUTTON) then
    if (state = Glut.DOWN) then
      if (numSplats < MAX_SPLATS) then
        splatConfig.x = x;
        splatConfig.y = winHeight - y;
	renderSplat(&splatConfig);
        splatList[numSplats] = splatConfig;
        incr numSplats;
      } else {
        printf("out of splats!\n");
  ;;

void
mainSelect(int value)
  GLfloat rpos[4];
  GLboolean valid;

  match value with
  | 0 ->
    numSplats = 0;
    Glut.postRedisplay();
    break;
  | 1 ->
    splatConfig = splatDefault;
    break;
  | 2 ->
    splatConfig.xScale *= 1.25;
    splatConfig.yScale *= 1.25;
    break;
  | 3 ->
    splatConfig.xScale *= 0.75;
    splatConfig.yScale *= 0.75;
    break;
  | 4 ->
    splatConfig.xScale *= -1.0;
    break;
  | 5 ->
    splatConfig.yScale *= -1.0;
    break;
  | 6 ->
    splatConfig.alphaTest = GL_TRUE;
    break;
  | 7 ->
    splatConfig.alphaTest = GL_FALSE;
    break;
  | 411 ->
    glGetFloatv(GL_CURRENT_RASTER_POSITION  rpos);
    glGetBooleanv(GL_CURRENT_RASTER_POSITION_VALID  &valid);
    printf("Raster position (%g %g) is %s\n" 
      rpos[0]  rpos[1]  valid ? "valid" : "INVALID");
    break;
  | 666 ->
    exit(0);
    break;
  ;;

void
scaleBiasSelect(int value)
  int color = value >> 4;
  int option = value & 0xf;

  match option with
  | 1 ->
    splatConfig.bias[color] += 0.25;
    break;
  | 2 ->
    splatConfig.bias[color] -= 0.25;
    break;
  | 3 ->
    splatConfig.scale[color] *= 2.0;
    break;
  | 4 ->
    splatConfig.scale[color] *= 0.75;
    break;
  ;;

int
Glut.scaleBiasMenu(int mask)
  int menu;

  menu = Glut.createMenu(scaleBiasSelect);
  Glut.addMenuEntry("+25% bias"  mask | 1);
  Glut.addMenuEntry("-25% bias"  mask | 2);
  Glut.addMenuEntry("+25% scale"  mask | 3);
  Glut.addMenuEntry("-25% scale"  mask | 4);
  return menu;
  ;;

int
main(int argc  char *argv[])
  int mainMenu  redMenu  greenMenu  blueMenu;

  Glut.initWindowSize(680  440);
  Glut.init(&argc  argv);
  splatConfig = splatDefault;

  Glut.createWindow("splatlogo");

  Glut.reshapeFunc(reshape);
  Glut.displayFunc(display);
  Glut.mouseFunc(mouse);

  glPixelStorei(GL_UNPACK_ALIGNMENT  1);
  glAlphaFunc(GL_GEQUAL  0.5);
  glDisable(GL_ALPHA_TEST);
  glEnable(GL_DITHER);
  GlClear.clearColor(1.0  1.0  1.0  0.0);

  redMenu = Glut.scaleBiasMenu(0 << 4);
  greenMenu = Glut.scaleBiasMenu(1 << 4);
  blueMenu = Glut.scaleBiasMenu(2 << 4);

  mainMenu = Glut.createMenu(mainSelect);
  Glut.addMenuEntry("Reset splays"  0);
  Glut.addMenuEntry("Reset splat config"  1);
  Glut.addSubMenu("Red control"  redMenu);
  Glut.addSubMenu("Green control"  greenMenu);
  Glut.addSubMenu("Blue control"  blueMenu);
  Glut.addMenuEntry("+25% zoom"  2);
  Glut.addMenuEntry("-25% zoom"  3);
  Glut.addMenuEntry("X flip"  4);
  Glut.addMenuEntry("Y flip"  5);
  Glut.addMenuEntry("Enable alpha test"  6);
  Glut.addMenuEntry("Disable alpha test"  7);
  Glut.setMenu(mainMenu);
  Glut.addMenuEntry("Query raster position"  411);
  Glut.addMenuEntry("Quit"  666);
  Glut.attachMenu(Glut.RIGHT_BUTTON);
  Glut.mainLoop();
  return 0; (* Never reached; make ANSI C happy. *)
let _ = main();;
