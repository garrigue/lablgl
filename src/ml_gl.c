/* $Id: ml_gl.c,v 1.4 1998-01-07 08:52:31 garrigue Exp $ */

#include <GL/gl.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include "variants.h"
#include "ml_gl.h"

extern void raise_with_string (value tag, char * msg) Noreturn;
static void raise_gl (char *errmsg) Noreturn;

static void raise_gl(char *errmsg)
{
  static value * gl_exn = NULL;
  if (gl_exn == NULL)
      gl_exn = caml_named_value("glerror");
  raise_with_string(*gl_exn, errmsg);
}

ML_double4(glClearColor)
ML_double4(glColor4d)

value ml_glClear(value bit_list)  /* ML */
{
    GLbitfield accu = 0;

    while (bit_list != Val_int(0)) {
	switch (Field (bit_list, 0)) {
	case MLTAG_color:
	    accu |= GL_COLOR_BUFFER_BIT; break;
	case MLTAG_depth:
	    accu |= GL_DEPTH_BUFFER_BIT; break;
	case MLTAG_accum:
	    accu |= GL_ACCUM_BUFFER_BIT; break;
	case MLTAG_stencil:
	    accu |= GL_STENCIL_BUFFER_BIT; break;
	}
	bit_list = Field (bit_list, 1);
    }
    glClear (accu);
    return Val_unit;
}

ML_void(glFlush)
ML_void(glFinish)

value ml_glRect(value p1, value p2)  /* ML */
{
    glRectd (Double_val (Field (p1, 0)),
	     Double_val (Field (p1, 1)),
	     Double_val (Field (p2, 0)),
	     Double_val (Field (p2, 1)));
    return Val_unit;
}

value ml_glVertex(value x, value y, value z, value w)  /* ML */
{
    if (z == Val_int(0)) glVertex2d (Double_val(x), Double_val(y));
    else if (w == Val_int(0))
	glVertex3d (Double_val(x), Double_val(y), Double_val(Field(z, 0)));
    else
	glVertex4d (Double_val(x), Double_val(y), Double_val(Field(z, 0)),
		    Double_val(Field(w, 0)));
    return Val_unit;
}

GLenum GLenum_val(value tag)
{
    switch(tag)
    {
#include "variants.c"
    }
    Assert(0);
    raise_gl("Unknown tag");
}

ML_GLenum(glBegin)
ML_void(glEnd)

ML_float(glPointSize)
ML_float(glLineWidth)

value ml_glLineStipple(value factor, value pattern)  /* ML */
{
    glLineStipple(Int_val(factor), Int_val(pattern));
    return Val_unit;
}

value ml_glPolygonMode(value face, value mode)  /* ML */
{
    glPolygonMode(GLenum_val(face), GLenum_val(mode));
    return Val_unit;
}

ML_GLenum(glFrontFace)
ML_GLenum(glCullFace)

ML_string(glPolygonStipple)

ML_bool(glEdgeFlag)
ML_double3(glNormal3d)

value ml_glMatrixMode(value mode)  /* ML */
{
    GLenum m;

    switch (mode)
    {
    case MLTAG_modelview:	m = GL_MODELVIEW;
    case MLTAG_projection:	m = GL_PROJECTION;
    case MLTAG_texture:	        m = GL_TEXTURE;
    }
    glMatrixMode (m);
    return Val_unit;
}

ML_void(glLoadIdentity)

value ml_glLoadMatrix(value m)  /* ML */
{
    GLdouble matrix[16];
    int i, j;

    for (i = 0; i < 4; i++)
	for (j = 0; j < 4; j++)
	    matrix[i*4+j] = Double_val (Field (Field (m, i), j));
    glLoadMatrixd (matrix);
    return Val_unit;
}

value ml_glMultMatrix(value m)  /* ML */
{
    GLdouble matrix[16];
    int i, j;

    for (i = 0; i < 4; i++)
	for (j = 0; j < 4; j++)
	    matrix[i*4+j] = Double_val (Field (Field (m, i), j));
    glMultMatrixd (matrix);
    return Val_unit;
}

ML_double3(glTranslated)
ML_double4(glRotated)
ML_double3(glScaled)

#include <GL/glu.h>

value ml_gluLookAt(value eye, value center, value up)  /* ML */
{
    gluLookAt (Double_val(Field(eye,0)), Double_val(Field(eye,1)),
	       Double_val(Field(eye,2)), Double_val(Field(center,0)),
	       Double_val(Field(center,1)), Double_val(Field(center,2)),
	       Double_val(Field(up,0)), Double_val(Field(up,1)),
	       Double_val(Field(up,2)));
    return Val_unit;
}

ML_double6(glFrustum)
ML_double4(gluPerspective)

ML_double6(glOrtho)
ML_double4(gluOrtho2D)

ML_int4(glViewport)
ML_double2(glDepthRange)

ML_void(glPushMatrix)
ML_void(glPopMatrix)

static const GLenum planes[6] =
{ GL_CLIP_PLANE0, GL_CLIP_PLANE1, GL_CLIP_PLANE2,
  GL_CLIP_PLANE3, GL_CLIP_PLANE4, GL_CLIP_PLANE5 };

value ml_glClipPlane(value plane, value equation)  /* ML */
{
    double eq[4];
    int i;

    for (i = 0; i < 4; i++)
	eq[i] = Double_val (Field(equation,i));
    glClipPlane (planes[Int_val(plane)], eq);
    return Val_unit;
}

ML_GLenum(glEnable)
ML_GLenum(glDisable)

ML_GLenum(glShadeModel)
