/* $Id: ml_glutess.c,v 1.1 2004-07-13 07:55:18 garrigue Exp $ */
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
{ ml_raise_gl ("Function not available"); }
ML_fail (gluTesselate)
ML_fail (gluTesselateAndReturn)

#else

/* Apparently this is used under Windows, according to the Red Book. */
#ifndef CALLBACK
#define CALLBACK
#endif

void CALLBACK errorCallback(GLenum error)
{
  ml_raise_gl((char*)gluErrorString(error));
}

typedef struct addrlist
{
  void *addr;
  struct addrlist *next;
} addrlist;

static addrlist *rootaddrlist=NULL;

static void *register_addr(addrlist **root, void *data)
{
  addrlist *newroot=malloc(sizeof(addrlist));
  newroot->addr = data;
  newroot->next = (*root);
  *(root) = newroot;
  return data;
}

static void CALLBACK combineCallback(GLdouble coords[3],
			      GLdouble *vertex_data[4],
			      GLfloat weight[4],
			      GLdouble **data)
{
  *data = (GLdouble *)register_addr(&rootaddrlist,
				    malloc(3*sizeof(GLdouble)));
  *(*data) = coords[0];
  *(*data+1) = coords[1];
  *(*data+2) = coords[2];
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
  printf("beginCallback\n");
  switch (type)
  {
  case GL_TRIANGLES      : kind = 0; break;
  case GL_TRIANGLE_FAN   : kind = 1; break;
  case GL_TRIANGLE_STRIP : kind = 2; break;
  default:
    fprintf(stderr, "Unknown primitive format %d in tesselation.\n", type);
    abort();
  }
  push_list();
  printf("done\n");
}

static void CALLBACK vertexCallback(void *vertex_data)
{
  printf("vertexCallback\n");
  GLdouble *verts=(GLdouble *)vertex_data;
  push_vert(Field(*prim,kind), verts[0], verts[1], verts[2]);
}

static void CALLBACK endCallback()
{
  printf("endCallback\n");
  kind = 0;
}

GLUtesselator *tobj=NULL;

static void free_addrlist(addrlist **root)
{
  while (*root)
    {
      addrlist *mem=*root;
      free(mem->addr);
      mem->addr = NULL;
      *root = (*root)->next;
      free(mem);
    }

  *root = NULL;
}

static void setProperties(value winding, value by_only, value tolerance)
{
  gluTessProperty(tobj, GLU_TESS_WINDING_RULE,
                  (winding != Val_unit ? GLUenum_val(Field(winding,0))
                   : GLU_TESS_WINDING_ODD));
  gluTessProperty(tobj, GLU_TESS_BOUNDARY_ONLY,
                  (by_only != Val_unit && Field(by_only,0) != Val_unit));
  gluTessProperty(tobj, GLU_TESS_TOLERANCE,
                  (tolerance != Val_unit ? Float_val(Field(by_only,0)) : 0));
}

CAMLprim value ml_gluTesselateAndReturn(value winding, value tolerance,
                                        value contours)
{
  CAMLparam1(contours);
  CAMLlocal1(res);
  int i;

  if (!tobj)
    {
      tobj=gluNewTess();

      if (!tobj) ml_raise_gl("Failed to initialise the GLU tesselator.");
    }

  res = alloc_tuple(3);
  Field(res,0) = Field(res,1) = Field(res,2) = Val_unit;
  prim = &res;

  gluTessNormal(tobj, 0.0, 0.0, 1.0);
  setProperties(winding, Val_unit, tolerance);
  gluTessCallback(tobj, GLU_TESS_BEGIN, (_GLUfuncptr)beginCallback);
  gluTessCallback(tobj, GLU_TESS_VERTEX, (_GLUfuncptr)vertexCallback);
  gluTessCallback(tobj, GLU_TESS_END, (_GLUfuncptr)endCallback);
  gluTessCallback(tobj, GLU_TESS_ERROR, (_GLUfuncptr)errorCallback);
  gluTessCallback(tobj, GLU_TESS_COMBINE, (_GLUfuncptr)combineCallback);

  printf("gluTessBeginPolygon\n");
  gluTessBeginPolygon(tobj, NULL);
  while (contours != Val_int(0))
    {
      printf("gluTessBeginContour\n");
      gluTessBeginContour(tobj);
      value contour=Field(contours, 0);
      while (contour != Val_int(0))
	{
	  value v=Field(contour, 0);
	  GLdouble *r=(GLdouble *)register_addr(&rootaddrlist,
						malloc(3*sizeof(GLdouble)));
	  r[0]=Float_val(Field(v, 0));
	  r[1]=Float_val(Field(v, 1));
	  r[2]=Float_val(Field(v, 2));

	  gluTessVertex(tobj, r, (void *)r);

	  contour = Field(contour, 1);
	}
      contours = Field(contours, 1);
      gluTessEndContour(tobj);
    }
  printf("gluTessEndPolygon\n");
  gluTessEndPolygon(tobj);
  gluDeleteTess(tobj);
  printf("finished\n");
  tobj = NULL;

  /* Delete all temporary data. */
  free_addrlist(&rootaddrlist);

  /* Return the ocaml data structure. */
  CAMLreturn (res);
}

CAMLprim value ml_gluTesselate (value winding, value by_only,
                                value tolerance, value contours)
{
  if (!tobj)
    {
      tobj=gluNewTess();

      if (!tobj) ml_raise_gl("Failed to initialise the GLU tesselator.");
    }

  gluTessNormal(tobj, 0.0, 0.0, 1.0);
  setProperties(winding, by_only, tolerance);
  gluTessCallback(tobj, GLU_TESS_BEGIN, (_GLUfuncptr)glBegin);
  gluTessCallback(tobj, GLU_TESS_VERTEX, (_GLUfuncptr)glVertex3dv);
  gluTessCallback(tobj, GLU_TESS_END, (_GLUfuncptr)glEnd);
  gluTessCallback(tobj, GLU_TESS_ERROR, (_GLUfuncptr)errorCallback);
  gluTessCallback(tobj, GLU_TESS_COMBINE, (_GLUfuncptr)combineCallback);

  gluTessBeginPolygon(tobj, NULL);
  while (contours != Val_int(0))
    {
      gluTessBeginContour(tobj);
      value contour=Field(contours, 0);
      while (contour != Val_int(0))
	{
	  value v=Field(contour, 0);
	  GLdouble *r=(GLdouble *)register_addr(&rootaddrlist,
						malloc(3*sizeof(GLdouble)));
	  r[0]=Float_val(Field(v, 0));
	  r[1]=Float_val(Field(v, 1));
	  r[2]=Float_val(Field(v, 2));

	  gluTessVertex(tobj, r, (void *)r);

	  contour = Field(contour, 1);
	}
      contours = Field(contours, 1);
      gluTessEndContour(tobj);
    }
  gluTessEndPolygon(tobj);
  gluDeleteTess(tobj);
  tobj=NULL;

  free_addrlist(&rootaddrlist);

  return Val_unit;
}

#endif
