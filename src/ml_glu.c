/* $Id: ml_glu.c,v 1.3 1998-01-19 06:57:09 garrigue Exp $ */

#include <GL/gl.h>
#include <GL/glu.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include "gl_tags.h"
#include "glu_tags.h"
#include "ml_gl.h"

static GLenum GLUenum_val(value tag)
{
    switch(tag)
    {
#include "glu_tags.c"
    }
    ml_raise_gl ("Unknown GLU tag");
}

/* Does not register the structure with Caml !
static value Val_addr (void *addr)
{
    value wrapper;
    if (!addr) ml_raise_gl ("Bad address");
    wrapper = alloc(1,No_scan_tag);
    Field(wrapper,0) = (value) addr;
    return wrapper;
}
*/

/* Called from ML */

ML_addr (gluBeginCurve)
ML_addr (gluBeginPolygon)
ML_addr (gluBeginSurface)
ML_addr (gluBeginTrim)


value ml_gluLookAt(value eye, value center, value up)  /* ML */
{
    gluLookAt (Double_val(Field(eye,0)), Double_val(Field(eye,1)),
	       Double_val(Field(eye,2)), Double_val(Field(center,0)),
	       Double_val(Field(center,1)), Double_val(Field(center,2)),
	       Double_val(Field(up,0)), Double_val(Field(up,1)),
	       Double_val(Field(up,2)));
    return Val_unit;
}

ML_void_addr (gluNewNurbsRenderer)
ML_void_addr (gluNewQuadric)
ML_void_addr (gluNewTess)

ML_double4(gluOrtho2D)

ML_double4 (gluPerspective)

value ml_gluSphere (value quad, value radius, value slices, value stacks)
{
    gluSphere (Addr_val(quad), Double_val(radius),
	       Int_val(slices), Int_val(stacks));
    return Val_unit;
}

value ml_gluCylinder (value quad, value base, value top, value height,
		    value slices, value stacks)
{
    gluCylinder (Addr_val(quad), Double_val(base), Double_val(top),
		 Double_val(height), Int_val(slices), Int_val(stacks));
    return Val_unit;
}

value ml_gluCylinder_bc (value tup)
{
    ml_gluCylinder (Field(tup,0), Field(tup,1), Field(tup,2),
		    Field(tup,3), Field(tup,4), Field(tup,5));
}
