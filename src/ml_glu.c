/* $Id: ml_glu.c,v 1.4 1998-01-21 09:12:36 garrigue Exp $ */

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

#define Nurb_val(struc) ((GLUnurbs *) Field(struc,1))
#define Quad_val(struc) ((GLUquadric *) Field(struc,1))
#define Tess_val(struc) ((GLUtesselator *) Field(struc,1))

#define ML_nurb(cname) \
value ml_##cname (value nurb) \
{ cname (Nurb_val(nurb)); return Val_unit; }
#define ML_tess(cname) \
value ml_##cname (value tess) \
{ cname (Tess_val(tess)); return Val_unit; }

#define ML_final(cname) \
static void ml_##cname (value struc) \
{ cname ((GLvoid *) Field(struc,1)); }

ML_final (gluDeleteNurbsRenderer)
ML_final (gluDeleteQuadric)
ML_final (gluDeleteTess)

/* Called from ML */

ML_nurb (gluBeginCurve)
ML_tess (gluBeginPolygon)
ML_nurb (gluBeginSurface)
ML_nurb (gluBeginTrim)

value ml_gluBuild1DMipmaps (value internal, value width,
			    value format, value data)
{
    GLenum error;

    error = gluBuild1DMipmaps (GL_TEXTURE_1D, GLenum_val(internal),
			       Int_val(width), GLenum_val(format),
			       Type_raw(data), Void_raw(data));
    if (error) ml_raise_gl(gluErrorString(error));
    return Val_unit;
}

value ml_gluBuild2DMipmaps (value internal, value width, value height,
			    value format, value data)
{
    GLint error;

    error = gluBuild2DMipmaps (GL_TEXTURE_2D, GLenum_val(internal),
			       Int_val(width), Int_val(height),
			       GLenum_val(format),
			       Type_raw(data), Void_raw(data));
    if (error) ml_raise_gl(gluErrorString(error));
    return Val_unit;
}

value ml_gluCylinder (value quad, value base, value top, value height,
		    value slices, value stacks)
{
    gluCylinder (Quad_val(quad), Double_val(base), Double_val(top),
		 Double_val(height), Int_val(slices), Int_val(stacks));
    return Val_unit;
}

value ml_gluCylinder_bc (value tup)
{
    ml_gluCylinder (Field(tup,0), Field(tup,1), Field(tup,2),
		    Field(tup,3), Field(tup,4), Field(tup,5));
}

value ml_gluDisk (value quad, value inner, value outer,
		  value slices, value loops)
{
    gluDisk (Quad_val(quad), Double_val(inner), Double_val(outer),
	     Int_val(slices), Int_val(loops));
    return Val_unit;
}


ML_nurb (gluEndCurve)
ML_tess (gluEndPolygon)
ML_nurb (gluEndSurface)
ML_nurb (gluEndTrim)

ML_GLenum_string (gluGetString)

value ml_gluLoadSamplingMatrices (value nurb, value model, value perspective,
				 value view)
{
    gluLoadSamplingMatrices (Nurb_val(nurb), Float_raw(model),
			     Float_raw(perspective), Int_raw(view));
    return Val_unit;
}

value ml_gluLookAt(value eye, value center, value up)  /* ML */
{
    gluLookAt (Double_val(Field(eye,0)), Double_val(Field(eye,1)),
	       Double_val(Field(eye,2)), Double_val(Field(center,0)),
	       Double_val(Field(center,1)), Double_val(Field(center,2)),
	       Double_val(Field(up,0)), Double_val(Field(up,1)),
	       Double_val(Field(up,2)));
    return Val_unit;
}

value ml_gluNewNurbsRenderer (void)
{
    value struc = alloc(2, Final_tag);
    Final_fun(struc) = ml_gluDeleteNurbsRenderer;
    Nurb_val(struc) = gluNewNurbsRenderer();
    return struc;
}

value ml_gluNewQuadric (void)
{
    value struc = alloc(2, Final_tag);
    Final_fun(struc) = ml_gluDeleteQuadric;
    Quad_val(struc) = gluNewQuadric();
    return struc;
}

value ml_gluNewTess (void)
{
    value struc = alloc(2, Final_tag);
    Final_fun(struc) = ml_gluDeleteTess;
    Tess_val(struc) = gluNewTess();
    return struc;
}

ML_double4(gluOrtho2D)

ML_double4 (gluPerspective)

value ml_gluSphere (value quad, value radius, value slices, value stacks)
{
    gluSphere (Quad_val(quad), Double_val(radius),
	       Int_val(slices), Int_val(stacks));
    return Val_unit;
}
