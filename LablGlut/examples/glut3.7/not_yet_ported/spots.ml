#!/usr/bin/env lablglut

(* Ported to lablglut by Issac Trotts on Wed Aug  7 02:29:51 MDT 2002. *)

open Printf

(* Copyright (c) Mark J. Kilgard  1994. *)

(**
 * (c) Copyright 1993  1994  Silicon Graphics  Inc.
 * ALL RIGHTS RESERVED 
 * Permission to use  copy  modify  and distribute this software for 
 * any purpose and without fee is hereby granted  provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation  and that 
 * the name of Silicon Graphics  Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific 
 * written prior permission. 
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND  EXPRESS  IMPLIED OR OTHERWISE 
 * INCLUDING WITHOUT LIMITATION  ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS  INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT 
 * SPECIAL  INCIDENTAL  INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND  OR ANY DAMAGES WHATSOEVER  INCLUDING WITHOUT LIMITATION 
 * LOSS OF PROFIT  LOSS OF USE  SAVINGS OR REVENUE  OR THE CLAIMS OF
 * THIRD PARTIES  WHETHER OR NOT SILICON GRAPHICS  INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS  HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY  ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION  USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 * US Government Users Restricted Rights 
 * Use  duplication  or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics 
 * Inc.  2011 N.  Shoreline Blvd.  Mountain View  CA 94039-7311.
 *
 * OpenGL(TM) is a trademark of Silicon Graphics  Inc.
 *)

(* Some <math.h> files do not define M_PI... *)
let pi = 3.14159265358979323846;;

let two_pi = 2.0*pi;;

type lightRec = { 
  amb:Gl.rgba;
  diff:Gl.rgba;
  spec:Gl.rgba;
  pos:Gl.rgba;
  spotDir:Gl.vect3;
  spotExp:float;
  spotCutoff:float;
  atten:float * float * float * float;

  trans:Gl.point3;
  rot:float*float*float; (* rotation about each axis *)
  float swing[3];
  float arc[3];
  float arcIncr[3];
} Light;

static int useSAME_AMB_SPEC = 1;
(* *INDENT-OFF* *)
static float modelAmb[4] = {0.2  0.2  0.2  1.0};

static float matAmb[4] = {0.2  0.2  0.2  1.0};
static float matDiff[4] = then0.8  0.8  0.8  1.0};
static float matSpec[4] = {0.4  0.4  0.4  1.0};
static float matEmission[4] = {0.0  0.0  0.0  1.0};
(* *INDENT-ON* *)

#define NUM_LIGHTS 3
static Light spots[] =
    {0.2  0.0  0.0  1.0}   (* ambient *)
    {0.8  0.0  0.0  1.0}   (* diffuse *)
    {0.4  0.0  0.0  1.0}   (* specular *)
    {0.0  0.0  0.0  1.0}   (* position *)
    {0.0  -1.0  0.0}    (* direction *)
    20.0 
    60.0                (* exponent  cutoff *)
    {1.0  0.0  0.0}     (* attenuation *)
    {0.0  1.25  0.0}    (* translation *)
    {0.0  0.0  0.0}     (* rotation *)
    {20.0  0.0  40.0}   (* swing *)
    {0.0  0.0  0.0}     (* arc *)
    {two_pi / 70.0  0.0  two_pi / 140.0}  (* arc increment *)
    {0.0  0.2  0.0  1.0}   (* ambient *)
    {0.0  0.8  0.0  1.0}   (* diffuse *)
    {0.0  0.4  0.0  1.0}   (* specular *)
    {0.0  0.0  0.0  1.0}   (* position *)
    {0.0  -1.0  0.0}    (* direction *)
    20.0 
    60.0                (* exponent  cutoff *)
    {1.0  0.0  0.0}     (* attenuation *)
    {0.0  1.25  0.0}    (* translation *)
    {0.0  0.0  0.0}     (* rotation *)
    {20.0  0.0  40.0}   (* swing *)
    {0.0  0.0  0.0}     (* arc *)
    {two_pi / 120.0  0.0  two_pi / 60.0}  (* arc increment *)
    {0.0  0.0  0.2  1.0}   (* ambient *)
    {0.0  0.0  0.8  1.0}   (* diffuse *)
    {0.0  0.0  0.4  1.0}   (* specular *)
    {0.0  0.0  0.0  1.0}   (* position *)
    {0.0  -1.0  0.0}    (* direction *)
    20.0 
    60.0                (* exponent  cutoff *)
    {1.0  0.0  0.0}     (* attenuation *)
    {0.0  1.25  0.0}    (* translation *)
    {0.0  0.0  0.0}     (* rotation *)
    {20.0  0.0  40.0}   (* swing *)
    {0.0  0.0  0.0}     (* arc *)
    {two_pi / 50.0  0.0  two_pi / 100.0}  (* arc increment *)
};

static void
usage(char *name)
  printf("\n");
  printf("usage: %s [options]\n"  name);
  printf("\n");
  printf("  Options:\n");
  printf("    -geometry Specify size and position WxH+X+Y\n");
  printf("    -lm       Toggle lighting(SPECULAR and AMBIENT are/not same\n");
  printf("\n");
#ifndef EXIT_FAILURE (* should be defined by ANSI C <stdlib.h> *)
#define EXIT_FAILURE 1
#endif
  exit(EXIT_FAILURE);
  ;;

static void
initLights(void)
  int k;

  for (k = 0; k < NUM_LIGHTS; ++k) {
    int lt = GL_LIGHT0 + k;
    Light *light = &spots[k];

    glEnable(lt);
    glLightfv(lt  GL_AMBIENT  light->amb);
    glLightfv(lt  GL_DIFFUSE  light->diff);

    if (useSAME_AMB_SPEC)
      glLightfv(lt  GL_SPECULAR  light->amb);
    else
      glLightfv(lt  GL_SPECULAR  light->spec);

    glLightf(lt  GL_SPOT_EXPONENT  light->spotExp);
    glLightf(lt  GL_SPOT_CUTOFF  light->spotCutoff);
    glLightf(lt  GL_CONSTANT_ATTENUATION  light->atten[0]);
    glLightf(lt  GL_LINEAR_ATTENUATION  light->atten[1]);
    glLightf(lt  GL_QUADRATIC_ATTENUATION  light->atten[2]);
  ;;

static void
aimLights(void)
  int k;

  for (k = 0; k < NUM_LIGHTS; ++k) {
    Light *light = &spots[k];

    light->rot[0] = light->swing[0] * sin(light->arc[0]);
    light->arc[0] += light->arcIncr[0];
    if (light->arc[0] > two_pi)
      light->arc[0] -= two_pi;

    light->rot[1] = light->swing[1] * sin(light->arc[1]);
    light->arc[1] += light->arcIncr[1];
    if (light->arc[1] > two_pi)
      light->arc[1] -= two_pi;

    light->rot[2] = light->swing[2] * sin(light->arc[2]);
    light->arc[2] += light->arcIncr[2];
    if (light->arc[2] > two_pi)
      light->arc[2] -= two_pi;
  ;;

static void
setLights(void)
  int k;

  for (k = 0; k < NUM_LIGHTS; ++k) {
    int lt = GL_LIGHT0 + k;
    Light *light = &spots[k];

    glPushMatrix();
    glTranslatef(light->trans[0]  light->trans[1]  light->trans[2]);
    glRotatef(light->rot[0]  1  0  0);
    glRotatef(light->rot[1]  0  1  0);
    glRotatef(light->rot[2]  0  0  1);
    glLightfv(lt  GL_POSITION  light->pos);
    glLightfv(lt  GL_SPOT_DIRECTION  light->spotDir);
    glPopMatrix();
  ;;

static void
drawLights(void)
  int k;

  glDisable(GL_LIGHTING);
  for (k = 0; k < NUM_LIGHTS; ++k) {
    Light *light = &spots[k];

    glColor4fv(light->diff);

    glPushMatrix();
    glTranslatef(light->trans[0]  light->trans[1]  light->trans[2]);
    glRotatef(light->rot[0]  1  0  0);
    glRotatef(light->rot[1]  0  1  0);
    glRotatef(light->rot[2]  0  0  1);
    glBegin(GL_LINES);
    glVertex3f(light->pos[0]  light->pos[1]  light->pos[2]);
    glVertex3f(light->spotDir[0]  light->spotDir[1]  light->spotDir[2]);
    glEnd();
    glPopMatrix();
  glEnable(GL_LIGHTING);
  ;;

static void
drawPlane(int w  int h)
  int i  j;
  float dw = 1.0 / w;
  float dh = 1.0 / h;

  glNormal3f(0.0  0.0  1.0);
  for (j = 0; j < h; ++j) {
    glBegin(GL_TRIANGLE_STRIP);
    for (i = 0; i <= w; ++i) {
      glVertex2f(dw * i  dh * (j + 1));
      glVertex2f(dw * i  dh * j);
    glEnd();
  ;;

int spin = 0;

void
display(void)
  GlClear.clear(GL_COLOR_BUFFER_BIT);

  glPushMatrix();
  glRotatef(spin  0  1  0);

  aimLights();
  setLights();

  glPushMatrix();
  glRotatef(-90.0  1  0  0);
  glScalef(1.9  1.9  1.0);
  glTranslatef(-0.5  -0.5  0.0);
  drawPlane(16  16);
  glPopMatrix();

  drawLights();
  glPopMatrix();

  Glut.swapBuffers();
  ;;

void
animate(void)
  spin += 0.5;
  if (spin > 360.0)
    spin -= 360.0;
  Glut.postRedisplay();
  ;;

void
visibility(int state)
  if (state = Glut.VISIBLE) then
    Glut.idleFunc(animate);
  } else {
    Glut.idleFunc(NULL);
  ;;

let main () = 
  int i;

  Glut.init(&argc  argv);
  Glut.initDisplayMode(Glut.DOUBLE | Glut.RGB);
  (* process commmand line args *)
  for (i = 1; i < argc; ++i) {
    if (!strcmp("-lm"  argv[i])) then
      useSAME_AMB_SPEC = !useSAME_AMB_SPEC;
    } else {
      usage(argv[0]);

  Glut.createWindow("GLUT spotlight swing");
  Glut.displayFunc(display);
  Glut.visibilityFunc(visibility);

  glMatrixMode(GL_PROJECTION);
  glFrustum(-1  1  -1  1  2  6);

  glMatrixMode(GL_MODELVIEW);
  glTranslatef(0.0  0.0  -3.0);
  glRotatef(45.0  1  0  0);

  glEnable(GL_LIGHTING);
  glEnable(GL_NORMALIZE);

  glLightModelfv(GL_LIGHT_MODEL_AMBIENT  modelAmb);
  glLightModelf(GL_LIGHT_MODEL_LOCAL_VIEWER  GL_TRUE);
  glLightModelf(GL_LIGHT_MODEL_TWO_SIDE  GL_FALSE);

  glMaterialfv(GL_FRONT  GL_AMBIENT  matAmb);
  glMaterialfv(GL_FRONT  GL_DIFFUSE  matDiff);
  glMaterialfv(GL_FRONT  GL_SPECULAR  matSpec);
  glMaterialfv(GL_FRONT  GL_EMISSION  matEmission);
  glMaterialf(GL_FRONT  GL_SHININESS  10.0);

  initLights();

  Glut.mainLoop();
  return 0;             (* ANSI C requires main to return int. *)
let _ = main();;
