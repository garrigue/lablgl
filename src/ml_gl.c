/* $Id: ml_gl.c,v 1.17 1998-01-23 03:23:17 garrigue Exp $ */

#include <GL/gl.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include "ml_raw.h"
#include "gl_tags.h"
#include "ml_gl.h"

/* #include <stdio.h> */

extern void invalid_argument (char *) Noreturn;
extern void raise_with_string (value tag, const char * msg) Noreturn;

void ml_raise_gl(const char *errmsg)
{
  static value * gl_exn = NULL;
  if (gl_exn == NULL)
      gl_exn = caml_named_value("glerror");
  raise_with_string(*gl_exn, errmsg);
}

GLenum GLenum_val(value tag)
{
    switch(tag)
    {
#include "gl_tags.c"
    }
    ml_raise_gl("Unknown tag");
}

extern mlsize_t string_length (value);

/* return the size in BITS of the described type */
int glSizeof (GLenum type)
{
    switch (type) {
    default:
	ml_raise_gl ("Unknown datatype");
    case GL_BITMAP: return 1;
    case GL_BYTE:
    case GL_UNSIGNED_BYTE: return sizeof(GLbyte) << 3;
    case GL_SHORT:
    case GL_UNSIGNED_SHORT: return sizeof(GLshort) << 3;
    case GL_INT:
    case GL_UNSIGNED_INT: return sizeof(GLint) << 3;
    case GL_FLOAT: return sizeof(GLfloat) << 3;
    case GL_DOUBLE: return sizeof(GLdouble) << 3;
    }
}

ML_GLenum_float_ (glAccum)
ML_GLenum_float_ (glAlphaFunc)

ML_GLenum (glBegin)

value ml_glBitmap (value width, value height, value orig, value move,
		   value data)  /* ML */
{
    if (Int_val(width) * Int_val(height) >
	Int_val(Size_raw(data)) * 8 * sizeof(value))
	ml_raise_gl ("GL.bitmap : unsufficient data");
    glBitmap (Int_val(width), Int_val(height),
	      Float_val(Field(orig,0)), Float_val(Field(orig,1)),
	      Float_val(Field(move,0)), Float_val(Field(move,1)),
	      Void_raw(data));
    return Val_unit;
}

ML_GLenum2(glBlendFunc)

value ml_glClipPlane(value plane, value equation)  /* ML */
{
    double eq[4];
    int i;

    for (i = 0; i < 4; i++)
	eq[i] = Double_val (Field(equation,i));
    glClipPlane (GL_CLIP_PLANE0 + Int_val(plane), eq);
    return Val_unit;
}

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
ML_float4 (glClearAccum)
ML_double4 (glClearColor)
ML_double (glClearDepth)
ML_float (glClearIndex)
ML_int (glClearStencil)
ML_double4 (glColor4d)
ML_int4 (glColorMask)
ML_GLenum2 (glColorMaterial)

value ml_glCopyPixels (value x, value y, value width, value height,
		       value type)
{
    glCopyPixels (Int_val(x), Int_val(y), Int_val(width), Int_val(height),
		  GLenum_val(type));
    return Val_unit;
}

ML_GLenum(glCullFace)

ML_GLenum (glDisable)
ML_GLenum (glDepthFunc)
ML_int (glDepthMask)
ML_double2 (glDepthRange)
ML_GLenum (glDrawBuffer)

value ml_glDrawPixels (value width, value height, value format, value data)
{
    glDrawPixels (Int_val(width), Int_val(height), GLenum_val(format),
		  Type_raw(data), Void_raw(data));
    return Val_unit;
}

ML_int(glEdgeFlag)
ML_GLenum (glEnable)
ML_void (glEnd)
ML_double (glEvalCoord1d)
ML_double2 (glEvalCoord2d)
ML_GLenum_int2_ (glEvalMesh1)
ML_GLenum_int4_ (glEvalMesh2)
ML_int (glEvalPoint1)
ML_int2 (glEvalPoint2)

value ml_glFog (value param) /* ML */
{
    float params[4];
    int i;

    switch (Field(param,0))
    {
    case MLTAG_mode:
	glFogi(GL_FOG_MODE, GLenum_val(Field(param,1)));
	break;
    case MLTAG_density:
	glFogf(GL_FOG_DENSITY, Float_val(Field(param,1)));
	break;
    case MLTAG_start:
	glFogf(GL_FOG_START, Float_val(Field(param,1)));
	break;
    case MLTAG_End:
	glFogf(GL_FOG_END, Float_val(Field(param,1)));
	break;
    case MLTAG_index:
	glFogf(GL_FOG_INDEX, Float_val(Field(param,1)));
	break;
    case MLTAG_color:
	for (i = 0; i < 4; i++) params[i] = Field(Field(param,1),i);
	glFogfv(GL_FOG_COLOR, params);
	break;
    }
    return Val_unit;
}

ML_void (glFlush)
ML_void (glFinish)
ML_GLenum (glFrontFace)
ML_double3x2 (glFrustum)

ML_GLenum_string (glGetString)

value ml_glHint (value target, value hint)
{
    GLenum targ;

    switch (target) {
    case MLTAG_fog:	targ = GL_FOG_HINT; break;
    case MLTAG_line_smooth:	targ = GL_LINE_SMOOTH_HINT; break;
    case MLTAG_perspective_correction:
	targ = GL_PERSPECTIVE_CORRECTION_HINT; break;
    case MLTAG_point_smooth:	targ = GL_POINT_SMOOTH_HINT; break;
    case MLTAG_polygon_smooth:	targ = GL_POLYGON_SMOOTH_HINT; break;
    }
    glHint (targ, GLenum_val(hint));
    return Val_unit;
}

ML_int (glIndexMask)
ML_double (glIndexd)
ML_void (glInitNames)
ML_GLenum_int (glIsEnabled)

value ml_glLight (value n, value param)  /* ML */
{
    float params[4];
    int i;

    if (Int_val(n) >= GL_MAX_LIGHTS) invalid_argument ("Gl.light");
    switch (Field(param,0))
    {
    case MLTAG_ambient:
    case MLTAG_diffuse:
    case MLTAG_specular:
    case MLTAG_position:
    case MLTAG_spot_direction:
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    default:
	params[0] = Float_val (Field(param, 1));
    }
    glLightfv (GL_LIGHT0 + Int_val(n), GLenum_val(Field(param,0)), params);
    return Val_unit;
}

value ml_glLightModel (value param)  /* ML */
{
    float params[4];
    int i;

    switch (Field(param,0))
    {
    case MLTAG_ambient:
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param,1),i));
	glLightModelfv (GL_LIGHT_MODEL_AMBIENT, params);
	break;
    case MLTAG_local_viewer:
	glLightModelf (GL_LIGHT_MODEL_LOCAL_VIEWER,
		       Float_val(Field(param,1)));
	break;
    case MLTAG_two_side:
	glLightModelf (GL_LIGHT_MODEL_TWO_SIDE,
		       Float_val(Field(param,1)));
	break;
    }
    return Val_unit;
}

ML_float (glLineWidth)
ML_int2 (glLineStipple)
ML_int (glLoadName)
ML_void (glLoadIdentity)

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

ML_GLenum (glLogicOp)

value ml_glMap1d (value target, value *u, value points)
{
    int uorder, ustride, i;
    double *dpoints;
    GLenum targ;

    switch (target) {
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
    }
    uorder = Wosize_val(points) / ustride;
    dpoints = calloc (uorder*ustride, sizeof(GLdouble));
    for (i = 0; i < uorder*ustride; i++)
	dpoints[i] = Double_val(Field(points,i));
    glMap1d (targ, Double_val(u[0]), Double_val(u[1]),
	     ustride, uorder, dpoints);
    free (dpoints);
    return Val_unit;
}

value ml_glMap2d (value target, value *u, value *v, value points)
{
    int vorder = Wosize_val(points);
    int i, j, k, uorder, ustride, vstride;
    double *dpoints;
    value row;
    GLenum targ;

    if (vorder == 0) invalid_argument("Gl.map2");
    switch (target) {
    case MLTAG_vertex_3:
	targ = GL_MAP2_VERTEX_3; ustride = 3; break;
    case MLTAG_vertex_4:
	targ = GL_MAP2_VERTEX_4; ustride = 4; break;
    case MLTAG_index:
	targ = GL_MAP2_INDEX; ustride = 1; break;
    case MLTAG_color_4:
	targ = GL_MAP2_COLOR_4; ustride = 4; break;
    case MLTAG_normal:
	targ = GL_MAP2_NORMAL; ustride = 3; break;
    case MLTAG_texture_coord_1:
	targ = GL_MAP2_TEXTURE_COORD_1; ustride = 1; break;
    case MLTAG_texture_coord_2:
	targ = GL_MAP2_TEXTURE_COORD_2; ustride = 2; break;
    case MLTAG_texture_coord_3:
	targ = GL_MAP2_TEXTURE_COORD_3; ustride = 3; break;
    case MLTAG_texture_coord_4:
	targ = GL_MAP2_TEXTURE_COORD_4; ustride = 4; break;
    }
    vstride = Wosize_val(Field(points,0));
    uorder = vstride / ustride;
    dpoints = calloc (vstride*vorder, sizeof(GLdouble));
    for (i = 0; i < vorder; i++) {
	row = Field(points,i);
	if (Wosize_val(row) != ustride * uorder) {
	    free (dpoints);
	    invalid_argument("Gl.map2");
	}
	for (j = 0; j < uorder*ustride; j++)
	    dpoints[i*vstride+j] = Double_val(Field(row,j));
    }
    glMap2d (targ, Double_val(u[0]), Double_val(u[1]), ustride, uorder,
	     Double_val(v[0]), Double_val(v[1]), vstride, vorder,
	     dpoints);
    free (dpoints);
    return Val_unit;
}

value ml_glMapGrid1d (value n, value *u)
{
    glMapGrid1d (Int_val(n), Double_val(u[0]), Double_val(u[1]));
    return Val_unit;
}

value ml_glMapGrid2d (value un, value *u, value vn, value *v)
{
    glMapGrid2d (Int_val(un), Double_val(u[0]), Double_val(u[1]),
		 Int_val(vn), Double_val(v[0]), Double_val(v[1]));
    return Val_unit;
}

value ml_glMaterial (value face, value param)  /* ML */
{
    float params[4];
    int i;

    switch (Field(param,0))
    {
    case MLTAG_shininess:
	params[0] = Float_val (Field(param, 1));
	break;
    case MLTAG_color_indexes:
	for (i = 0; i < 3; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    default:
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    }
    glMaterialfv (GLenum_val(face), GLenum_val(Field(param,0)), params);
    return Val_unit;
}

ML_GLenum (glMatrixMode)

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

ML_double3 (glNormal3d)

ML_float (glPassThrough)

value ml_glPixelMapfv (value map, value array)
{
    int mapsize = Wosize_val(array);
    GLfloat *values = calloc (mapsize, sizeof(GLfloat));
    int i;
    
    for (i = 0; i < mapsize; i++) values[i] = Float_val(Field(array,i));
    glPixelMapfv (GLenum_val(map), mapsize, values);
    return Val_unit;
}

ML_double3x2 (glOrtho)

value ml_glPixelStore (value param)
{
    glPixelStorei (GLenum_val (Field(param,0)), Int_val (Field(param,1)));
    return Val_unit;
}

value ml_glPixelTransfer (value param)
{
    GLenum pname = GLenum_val (Field(param,0));

    switch (pname) {
    case GL_MAP_COLOR:
    case GL_MAP_STENCIL:
    case GL_INDEX_SHIFT:
    case GL_INDEX_OFFSET:
	glPixelTransferi (pname, Int_val (Field(param,1)));
	break;
    default:
	glPixelTransferf (pname, Float_val (Field(param,1)));
    }
    return Val_unit;
}

ML_float2 (glPixelZoom)
ML_float (glPointSize)
ML_GLenum2 (glPolygonMode)
ML_string (glPolygonStipple)
ML_void (glPopAttrib)
ML_void (glPopMatrix)
ML_void (glPopName)

value ml_glPushAttrib (value list)
{
    GLbitfield mask;

    while (list != Val_int(0)) {
	switch (Field(list,0)) {
	case MLTAG_accum_buffer:mask |= GL_ACCUM_BUFFER_BIT; break;
	case MLTAG_color_buffer:mask |= GL_COLOR_BUFFER_BIT; break;
	case MLTAG_current:	mask |= GL_CURRENT_BIT; break;
	case MLTAG_depth_buffer:mask |= GL_DEPTH_BUFFER_BIT; break;
	case MLTAG_enable:	mask |= GL_ENABLE_BIT; break;
	case MLTAG_eval:	mask |= GL_EVAL_BIT; break;
	case MLTAG_fog:		mask |= GL_FOG_BIT; break;
	case MLTAG_hint:	mask |= GL_HINT_BIT; break;
	case MLTAG_lighting:	mask |= GL_LIGHTING_BIT; break;
	case MLTAG_line:	mask |= GL_LINE_BIT; break;
	case MLTAG_list:	mask |= GL_LIST_BIT; break;
	case MLTAG_pixel_mode:	mask |= GL_PIXEL_MODE_BIT; break;
	case MLTAG_point:	mask |= GL_POINT_BIT; break;
	case MLTAG_polygon:	mask |= GL_POLYGON_BIT; break;
	case MLTAG_polygon_stipple:mask |= GL_POLYGON_STIPPLE_BIT; break;
	case MLTAG_scissor:	mask |= GL_SCISSOR_BIT; break;
	case MLTAG_stencil_buffer:mask |= GL_STENCIL_BUFFER_BIT; break;
	case MLTAG_texture:	mask |= GL_TEXTURE_BIT; break;
	case MLTAG_transform:	mask |= GL_TRANSFORM_BIT; break;
	case MLTAG_viewport:	mask |= GL_VIEWPORT_BIT; break;
	}
	list = Field(list,1);
    }
    glPushAttrib (mask);
    return Val_unit;
}

ML_void (glPushMatrix)
ML_int (glPushName)

value ml_glRasterPos(value x, value y, value z, value w)  /* ML */
{
    if (z == Val_int(0)) glRasterPos2d (Double_val(x), Double_val(y));
    else if (w == Val_int(0))
	glRasterPos3d (Double_val(x), Double_val(y), Double_val(Field(z, 0)));
    else
	glRasterPos4d (Double_val(x), Double_val(y), Double_val(Field(z, 0)),
		    Double_val(Field(w, 0)));
    return Val_unit;
}

value ml_glReadBuffer (value buffer)
{
    if (Is_block(buffer)) {
	int n = Int_val (Field(buffer,1));
	if (n >= GL_AUX_BUFFERS)
	    ml_raise_gl ("Gl.read_buffer : no such auxiliary buffer");
	glReadBuffer (GL_AUX0 + n);
    }
    else glReadBuffer (GLenum_val(buffer));
    return Val_unit;
}

value ml_glReadPixels (value x, value y, value w, value h,
		       value f, value t)
{
    value pixels = Val_unit, data = Val_unit;
    int width = Int_val(w), height = Int_val(h);
    GLenum format = GLenum_val(f);
    GLenum type = GLenum_val(t);
    int formatsize, size;

    switch (format) {
    default:
	formatsize = 1; break;
    case GL_LUMINANCE_ALPHA:
	formatsize = 2; break;
    case GL_RGB:
	formatsize = 3; break;
    case GL_RGBA:
	formatsize = 4; break;
    }
    Begin_roots2 (pixels,data);
    size = (formatsize*glSizeof(type)-1)/8/sizeof(value) + 1;
    pixels = alloc_shr (size, Abstract_tag);
    data = alloc(3,0);
    Field(data,0) = t;
    Field(data,1) = size;
    Field(data,2) = pixels;
    glReadPixels (Int_val(x), Int_val(y), width, height, format, type,
		  (GLvoid *) pixels);
    End_roots ();
    return data;
}

ML_bc6 (ml_glReadPixels)

value ml_glRect(value p1, value p2)  /* ML */
{
    glRectd (Double_val (Field (p1, 0)),
	     Double_val (Field (p1, 1)),
	     Double_val (Field (p2, 0)),
	     Double_val (Field (p2, 1)));
    return Val_unit;
}

ML_GLenum_int (glRenderMode)
ML_double4 (glRotated)

ML_double3 (glScaled)
ML_int4 (glScissor)

value ml_glSelectBuffer (value raw)
{
    glSelectBuffer (Int_val (Field(raw,1)) / sizeof(GLuint),
		    (GLuint *) Field(raw,2));
    return Val_unit;
}

ML_GLenum (glShadeModel)
ML_GLenum_int2_ (glStencilFunc)
ML_int (glStencilMask)
ML_GLenum3 (glStencilOp)

ML_double (glTexCoord1d)
ML_double2 (glTexCoord2d)
ML_double3 (glTexCoord3d)
ML_double4 (glTexCoord4d)

value ml_glTexEnv (value param)
{
    value params = Field(param,1);
    GLfloat color[4];
    int i;

    switch (Field(param,0)) {
    case MLTAG_mode:
	glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GLenum_val(params));
	break;
    case MLTAG_color:
	for (i = 0; i < 4; i++) color[i] = Float_val(Field(params,i));
	glTexEnvfv (GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, color);
	break;
    }
    return Val_unit;
}

value ml_glTexGen (value coord, value param)
{
    value params = Field(param,1);
    GLdouble point[4];
    int i;

    if (Field(param,0) == MLTAG_mode)
	glTexGeni (GLenum_val(coord), GL_TEXTURE_GEN_MODE, GLenum_val(params));
    else {
	for (i = 0; i < 4; i++) point[i] = Double_val(Field(params,i));
	glTexGendv (GLenum_val(coord), GLenum_val(Field(param,0)), point);
    }
    return Val_unit;
}

value ml_glTexImage1D (value proxy, value level, value internal,
		       value width, value border, value format, value data)
{
    glTexImage1D (proxy == Val_int(1)
		  ? GL_PROXY_TEXTURE_1D : GL_TEXTURE_1D,
		  Int_val(level), Int_val(internal), Int_val(width),
		  Int_val(border), GLenum_val(format),
		  Type_raw(data), Void_raw(data));
    return Val_unit;
}

ML_bc7 (ml_glTexImage1D)

value ml_glTexImage2D (value proxy, value level, value internal,
		       value width, value height, value border,
		       value format, value data)
{
    /* printf("p=%x,l=%d,i=%d,w=%d,h=%d,b=%d,f=%x,t=%x,d=%x\n", */
    glTexImage2D (proxy == Val_int(1)
		  ? GL_PROXY_TEXTURE_2D : GL_TEXTURE_2D,
		  Int_val(level), Int_val(internal), Int_val(width),
		  Int_val(height), Int_val(border), GLenum_val(format),
		  Type_raw(data), Void_raw(data));
    /*  flush(stdout); */
    return Val_unit;
}

ML_bc8 (ml_glTexImage2D)

value ml_glTexParameter (value target, value param)
{
    GLenum targ = GLenum_val(target);
    GLenum pname = GLenum_val(Field(param,0));
    value params = Field(param,1);
    GLfloat color[4];
    int i;

    switch (pname) {
    case GL_TEXTURE_BORDER_COLOR:
	for (i = 0; i < 4; i++) color[i] = Float_val(Field(params,i));
	glTexParameterfv (targ, pname, color);
	break;
    case GL_TEXTURE_PRIORITY:
	glTexParameterf (targ, pname, Float_val(params));
	break;
    default:
	glTexParameteri (targ, pname, GLenum_val(params));
	break;
    }
    return Val_unit;
}
    
ML_double3 (glTranslated)

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

ML_int4 (glViewport)


/* List functions */

ML_int_int (glIsList)
ML_int2 (glDeleteLists)
ML_int_int (glGenLists)

value ml_glNewList (value glist, value mode)  /* ML */
{
    glNewList (Int_val (glist), GLenum_val (mode));
    return Val_unit;
}

ML_void (glEndList)
ML_int (glCallList)
ML_int (glListBase)

value ml_glCallLists (value indexes)  /* ML */
{
    int len,i;
    int * table;

    switch (Field(indexes,0)) {
    case MLTAG_byte:
	glCallLists (string_length(Field(indexes,1)),
		     GL_UNSIGNED_BYTE,
		     String_val(Field(indexes,1)));
	break;
    case MLTAG_int:
	len = Wosize_val (indexes);
	table = calloc (len, sizeof (GLint));
	for (i = 0; i < len; i++) table[i] = Int_val (Field(indexes,i));
	glCallLists (len, GL_INT, table);
	free (table);
	break;
    }
    return Val_unit;
}
