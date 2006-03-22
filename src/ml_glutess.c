/* $Id: ml_glutess.c,v 1.6 2006-03-22 12:49:23 garrigue Exp $ */
/* Code contributed by Jon Harrop */

#include <stdio.h>
#include <stdlib.h>
#ifdef _WIN32
#include <wtypes.h>
#endif
#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#else
#include <GL/gl.h>
#include <GL/glu.h>
#endif
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include "gl_tags.h"
#include "glu_tags.h"
#include "ml_gl.h"
#include "ml_glu.h"

#ifndef GLU_VERSION_1_2
#define ML_fail(cname) \
CAMLprim value ml_##cname (value any) \
{ ml_raise_gl ("Function not available: "##cname); }
ML_fail (gluTesselate)
ML_fail (gluTesselateAndReturn)

#else

/* Apparently this is used under Windows, according to the Red Book. */
#ifndef CALLBACK
#define CALLBACK
#endif
#define AS_CB (GLvoid(CALLBACK *)())

static void CALLBACK errorCallback(GLenum error)
{
  ml_raise_gl((char*)gluErrorString(error));
}

typedef struct chunklist
{
  struct chunklist *next;
  int current;
  int size;
  GLdouble data[32][3];
} chunklist;

static chunklist *rootchunk=NULL;

static GLdouble *new_vertex(GLdouble x, GLdouble y, GLdouble z)
{
  GLdouble *vert;
  if (rootchunk == NULL || rootchunk->current >= rootchunk->size) {
    chunklist *tmp = rootchunk;
    rootchunk = (chunklist*)malloc(sizeof(chunklist));
    rootchunk->next = tmp;
    rootchunk->current = 0;
    rootchunk->size = 32;
  }
  vert = rootchunk->data[rootchunk->current++];
  vert[0] = x;
  vert[1] = y;
  vert[2] = z;
  return vert;
}

static void free_chunks()
{
  while (rootchunk != NULL) {
    chunklist *next = rootchunk->next;
    free(rootchunk);
    rootchunk = next;
  }
}

static void CALLBACK combineCallback(GLdouble coords[3],
			      GLdouble *vertex_data[4],
			      GLfloat weight[4],
			      GLdouble **data)
{
  *data = new_vertex(coords[0],coords[1],coords[2]);
}

/* prim is only valid during callbacks */
static value *prim;
static int kind = 0;

static void push_vert(value root, double x, double y, double z)
{
  CAMLparam1(root);
  CAMLlocal4(vert, xx, yy, zz);
  value cons;
  xx = copy_double(x); yy = copy_double(y); zz = copy_double(z);
  vert = alloc_tuple(3);
  Field(vert,0) = xx;
  Field(vert,1) = yy;
  Field(vert,2) = zz;
  cons = alloc_tuple(2);
  Field(cons, 0) = vert;
  Field(cons, 1) = Field(root,0);
  modify(&Field(root,0), cons);
  CAMLreturn0;
}

static void push_list()
{
  value cons = alloc_tuple(2);
  Field(cons,0) = Val_unit;
  Field(cons,1) = Field(*prim,kind);
  modify(&Field(*prim,kind), cons);
}

static void CALLBACK beginCallback(GLenum type)
{
  switch (type)
  {
  case GL_TRIANGLES      : kind = 0; break;
  case GL_TRIANGLE_FAN   : kind = 1; break;
  case GL_TRIANGLE_STRIP : kind = 2; break;
  default: {
    char msg[80];
    sprintf(msg, "Unknown primitive format %d in tesselation.\n", (int)type);
    ml_raise_gl(msg);
  }
  }
  push_list();
}

static void CALLBACK vertexCallback(void *vertex_data)
{
  GLdouble *verts=(GLdouble *)vertex_data;
  push_vert(Field(*prim,kind), verts[0], verts[1], verts[2]);
}

static void CALLBACK endCallback()
{
  kind = 0;
}

static GLUtesselator *tobj=NULL;


static void iniTesselator(value winding, value by_only, value tolerance)
{
  if (!tobj) {
    tobj=gluNewTess();
    if (!tobj) ml_raise_gl("Failed to initialise the GLU tesselator.");
  }
  gluTessNormal(tobj, 0.0, 0.0, 1.0);
  gluTessProperty(tobj, GLU_TESS_WINDING_RULE,
                  (winding != Val_unit ? GLUenum_val(Field(winding,0))
                   : GLU_TESS_WINDING_ODD));
  gluTessProperty(tobj, GLU_TESS_BOUNDARY_ONLY,
                  (by_only != Val_unit && Field(by_only,0) != Val_unit));
  gluTessProperty(tobj, GLU_TESS_TOLERANCE,
                  (tolerance != Val_unit ? Float_val(Field(by_only,0)) : 0));
}

static void runTesselator(value contours)
{
  CAMLparam1(contours);

  gluTessBeginPolygon(tobj, NULL);
  while (contours != Val_int(0)) {
    value contour=Field(contours, 0);
    gluTessBeginContour(tobj);
    while (contour != Val_int(0)) {
      value v=Field(contour, 0);
      GLdouble *r =
        new_vertex(Double_val(Field(v, 0)),
                   Double_val(Field(v, 1)),
                   Double_val(Field(v, 2)));
      gluTessVertex(tobj, r, (void *)r);
      contour = Field(contour, 1);
    }
    contours = Field(contours, 1);
    gluTessEndContour(tobj);
  }
  gluTessEndPolygon(tobj);

  gluDeleteTess(tobj);
  tobj = NULL;
  free_chunks();
  CAMLreturn0;
}

CAMLprim value ml_gluTesselateAndReturn(value winding, value tolerance,
                                        value contours)
{
  CAMLparam1(contours);
  CAMLlocal1(res);

  res = alloc_tuple(3);
  Field(res,0) = Field(res,1) = Field(res,2) = Val_unit;
  prim = &res;

  iniTesselator(winding, Val_unit, tolerance);
  gluTessCallback(tobj, GLU_TESS_BEGIN, AS_CB beginCallback);
  gluTessCallback(tobj, GLU_TESS_VERTEX, AS_CB vertexCallback);
  gluTessCallback(tobj, GLU_TESS_END, AS_CB endCallback);
  gluTessCallback(tobj, GLU_TESS_ERROR, AS_CB errorCallback);
  gluTessCallback(tobj, GLU_TESS_COMBINE, AS_CB combineCallback);

  runTesselator(contours);

  CAMLreturn (res);
}

CAMLprim value ml_gluTesselate (value winding, value by_only,
                                value tolerance, value contours)
{
  iniTesselator(winding, by_only, tolerance);

  gluTessCallback(tobj, GLU_TESS_BEGIN, AS_CB glBegin);
  gluTessCallback(tobj, GLU_TESS_VERTEX, AS_CB glVertex3dv);
  gluTessCallback(tobj, GLU_TESS_END, AS_CB glEnd);
  gluTessCallback(tobj, GLU_TESS_ERROR, AS_CB errorCallback);
  gluTessCallback(tobj, GLU_TESS_COMBINE, AS_CB combineCallback);

  runTesselator(contours);

  return Val_unit;
}

#endif
