/* $Id: ml_gl.c,v 1.1 1997-12-26 02:50:28 garrigue Exp $ */

#include <GL/gl.h>
#include <caml/mlvalues.h>
#include "variants.h"

value ml_glClearColor(value red, value green, value blue, value alpha)   /* ML */
{
    glClearColor(Double_val(red), Double_val(green),
		 Double_val(blue), Double_val(alpha));
    return Val_unit;
}

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

#define ML_simple(cname) \
value ml_##cname (value unit) \
{ cname(); return Val_unit; }

ML_simple(glFlush)
ML_simple(glFinish)

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
