/* $Id: ml_gl.c,v 1.2 1998-01-05 06:32:45 garrigue Exp $ */

#include <GL/gl.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include "variants.h"
#include "ml_gl.h"

static void raise_gl (char *errmsg) Noreturn;

static void raise_gl(char *errmsg)
{
  static value * gl_exn = NULL;
  if (gl_exn == NULL)
    gl_exn = caml_named_value("glerror");
  raise_with_string(*gl_exn, errmsg);
}

ML_double4(glClearColor)

value ml_glClear(value bit_list)  /* ML */
{
    GLbitfield accu;

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

GLenum ml_glTag(value tag)
{
    switch(tag)
    {
#include "variants.c"
    }
    Assert(0);
    raise_gl("Unknown tag");
}

value ml_glBegin(value mode)  /* ML */
{
    glBegin (ml_glTag (mode));
    return Val_unit;
}

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
    glPolygonMode(ml_glTag(face), ml_glTag(mode));
    return Val_unit;
}

ML_enum(glFrontFace)
ML_enum(glCullFace)

ML_string(glPolygonStipple)

ML_bool(glEdgeFlag)
ML_double3(glNormal)
