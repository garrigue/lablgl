/* $Id: ml_glu.c,v 1.7 1998-01-23 03:23:19 garrigue Exp $ */

#include <GL/gl.h>
#include <GL/glu.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
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

#ifdef GLU_VERSION_1_2

#define Nurb_val(struc) ((GLUnurbs *) Field(struc,1))
#define Quad_val(struc) ((GLUquadric *) Field(struc,1))
#define Tess_val(struc) ((GLUtesselator *) Field(struc,1))

#else /* GLU_VERSION_1_1 */

#define Nurb_val(struc) ((GLUnurbsObj *) Field(struc,1))
#define Quad_val(struc) ((GLUquadricObj *) Field(struc,1))
#define Tess_val(struc) ((GLUtriangulatorObj *) Field(struc,1))

#endif /* GLU_VERSION_1_1 */


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

ML_bc6 (ml_gluCylinder)

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

value ml_gluNextContour (value tess, value type)
{
    gluNextContour (Tess_val(tess), GLUenum_val(type));
    return Val_unit;
}

#define Fsize_raw(raw) (Int_val(Size_raw(raw))/sizeof(GLfloat))

value ml_gluNurbsCurve (value nurb, value knots, value control,
			value order, value type)
{
    GLenum targ;
    int ustride;

    switch (type) {
    case MLTAG_vertex_3:
	targ = GL_MAP1_VERTEX_3; ustride = 3; break;
    case MLTAG_vertex_4:
	targ = GL_MAP1_VERTEX_4; ustride = 4; break;
    case MLTAG_index:
	targ = GL_MAP1_INDEX; ustride = 1; break;
    case MLTAG_color_4:
	targ = GL_MAP1_COLOR_4; ustride = 4; break;
    case MLTAG_normal:
	targ = GL_MAP1_NORMAL; ustride = 3; break;
    case MLTAG_texture_coord_1:
	targ = GL_MAP1_TEXTURE_COORD_1; ustride = 1; break;
    case MLTAG_texture_coord_2:
	targ = GL_MAP1_TEXTURE_COORD_2; ustride = 2; break;
    case MLTAG_texture_coord_3:
	targ = GL_MAP1_TEXTURE_COORD_3; ustride = 3; break;
    case MLTAG_texture_coord_4:
	targ = GL_MAP1_TEXTURE_COORD_4; ustride = 4; break;
    case MLTAG_trim_2:
	targ = GLU_MAP1_TRIM_2; ustride = 2; break;
    case MLTAG_trim_3:
	targ = GLU_MAP1_TRIM_3; ustride = 3; break;
    }
    gluNurbsCurve (Nurb_val(nurb), Fsize_raw(knots), Float_raw(knots),
		   ustride, Float_raw(control), Int_val(order), targ);
    return Val_unit;
}

value ml_gluNurbsProperty (value nurb, value prop)
{
    GLfloat val;
    GLenum property = GLUenum_val (Field(prop,0));

    switch (property) {
    case GLU_SAMPLING_METHOD:
    case GLU_DISPLAY_MODE:
	val = GLUenum_val (Field(prop,1));
	break;
    case GLU_PARAMETRIC_TOLERANCE:
	val = Float_val (Field(prop,1));
	break;
    default:
	val = Int_val (Field(prop,1));
	break;
    }
    gluNurbsProperty (Nurb_val(nurb), property, val);
    return Val_unit;
}

value ml_gluNurbsSurface (value nurb, value sKnots, value tKnots,
			  value tStride, value control, value sOrder,
			  value tOrder, value tag)
{
    GLenum type;
    GLint sStride;

    switch (tag) {
    case MLTAG_vertex_3:
	type = GL_MAP2_VERTEX_3; sStride = 3; break;
    case MLTAG_vertex_4:
	type = GL_MAP2_VERTEX_4; sStride = 4; break;
    case MLTAG_index:
	type = GL_MAP2_INDEX; sStride = 1; break;
    case MLTAG_color_4:
	type = GL_MAP2_COLOR_4; sStride = 4; break;
    case MLTAG_normal:
	type = GL_MAP2_NORMAL; sStride = 3; break;
    case MLTAG_texture_coord_1:
	type = GL_MAP2_TEXTURE_COORD_1; sStride = 1; break;
    case MLTAG_texture_coord_2:
	type = GL_MAP2_TEXTURE_COORD_2; sStride = 2; break;
    case MLTAG_texture_coord_3:
	type = GL_MAP2_TEXTURE_COORD_3; sStride = 3; break;
    case MLTAG_texture_coord_4:
	type = GL_MAP2_TEXTURE_COORD_4; sStride = 4; break;
    }
    gluNurbsSurface (Nurb_val(nurb), Fsize_raw(sKnots), Float_raw(sKnots),
		     Fsize_raw(tKnots), Float_raw(tKnots), sStride,
		     Int_val(tStride), Float_raw(control),
		     Int_val(sOrder), Int_val(tOrder), type);
    return Val_unit;
}

ML_bc8 (ml_gluNurbsSurface)

ML_double4(gluOrtho2D)

value ml_gluPartialDisk (value quad, value inner, value outer, value slices,
			 value loops, value start, value sweep)
{
    gluPartialDisk (Quad_val(quad), Double_val(inner), Double_val(outer),
		    Int_val(slices), Int_val(loops), Double_val(start),
		    Double_val(sweep));
    return Val_unit;
}

ML_bc7 (ml_gluPartialDisk)

ML_double4 (gluPerspective)

value ml_gluPickMatrix (value x, value y, value delX, value delY)
{
    GLint viewport[4];

    glGetIntegerv (GL_VIEWPORT, viewport);
    gluPickMatrix (Double_val(x), Double_val(y), Double_val(delX),
		   Double_val(delY), viewport);
    return Val_unit;
}

value ml_gluProject (value object)
{
    GLdouble model[16];
    GLdouble proj[16];
    GLint viewport[4];
    value win = Val_unit, winX = Val_unit, winY = Val_unit, winZ = Val_unit;

    glGetDoublev (GL_MODELVIEW_MATRIX, model);
    glGetDoublev (GL_PROJECTION_MATRIX, proj);
    glGetIntegerv (GL_VIEWPORT, viewport);
    Begin_roots4 (win,winX,winY,winZ);
    winX = alloc (Double_wosize, Double_tag);
    winY = alloc (Double_wosize, Double_tag);
    winZ = alloc (Double_wosize, Double_tag);
    win = alloc_tuple (3);
    Field(win,0) = winX;
    Field(win,1) = winY;
    Field(win,2) = winZ;
    gluProject (Field(object,0), Field(object,1), Field(object,2),
		model, proj, viewport,
		(double *) winX, (double *) winY, (double *) winZ);
    End_roots ();
    return win;
}

value ml_gluSphere (value quad, value radius, value slices, value stacks)
{
    gluSphere (Quad_val(quad), Double_val(radius),
	       Int_val(slices), Int_val(stacks));
    return Val_unit;
}
