/* $Id: ml_gl.c,v 1.24 2000-04-18 00:24:06 garrigue Exp $ */

#include <strings.h>
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

struct record {
    value key; 
    GLenum data;
};

static struct record input_table[] = {
#include "gl_tags.c"
};

static struct record *tag_table = NULL;

#define TABLE_SIZE (TAG_NUMBER*2+1)

value ml_gl_make_table (value unit)
{
    int i;
    unsigned int hash;

    tag_table = stat_alloc (TABLE_SIZE * sizeof(struct record));
    bzero ((char *) tag_table, TABLE_SIZE * sizeof(struct record));
    for (i = 0; i < TAG_NUMBER; i++) {
	hash = (unsigned long) input_table[i].key % TABLE_SIZE;
	while (tag_table[hash].key != 0) {
	    hash ++;
	    if (hash == TABLE_SIZE) hash = 0;
	}
	tag_table[hash].key = input_table[i].key;
	tag_table[hash].data = input_table[i].data;
    }
    return Val_unit;
}

GLenum GLenum_val(value tag)
{
    unsigned int hash = (unsigned long) tag % TABLE_SIZE;

    if (!tag_table) ml_gl_make_table (Val_unit);
    while (tag_table[hash].key != tag) {
	if (tag_table[hash].key == 0) ml_raise_gl ("Unknown tag");
	hash++;
	if (hash == TABLE_SIZE) hash = 0;
    }
    return tag_table[hash].data;
}

/*
GLenum GLenum_val(value tag)
{
    switch(tag)
    {
#include "gl_tags.c"
    }
    ml_raise_gl("Unknown tag");
}
*/

extern mlsize_t string_length (value);

ML_2 (glAccum, GLenum_val, Float_val)
ML_2 (glAlphaFunc, GLenum_val, Float_val)

ML_1 (glBegin, GLenum_val)

ML_5 (glBitmap, Int_val, Int_val, Pair(arg3,Float_val,Float_val),
      Pair(arg4,Float_val,Float_val), Void_raw)

ML_2 (glBlendFunc, GLenum_val, GLenum_val)

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
ML_4 (glClearAccum, Float_val, Float_val, Float_val, Float_val)
ML_4 (glClearColor, Double_val, Double_val, Double_val, Double_val)
ML_1 (glClearDepth, Double_val)
ML_1 (glClearIndex, Float_val)
ML_1 (glClearStencil, Int_val)
ML_4 (glColor4d, Double_val, Double_val, Double_val, Double_val)
ML_4 (glColorMask, Int_val, Int_val, Int_val, Int_val)
ML_2 (glColorMaterial, GLenum_val, GLenum_val)
ML_5 (glCopyPixels, Int_val, Int_val, Int_val, Int_val, GLenum_val)
ML_1 (glCullFace, GLenum_val)

ML_1 (glDisable, GLenum_val)
ML_1 (glDepthFunc, GLenum_val)
ML_1 (glDepthMask, Int_val)
ML_2 (glDepthRange, Double_val, Double_val)
ML_1 (glDrawBuffer, GLenum_val)
ML_4 (glDrawPixels, Int_val, Int_val, GLenum_val, Type_void_raw)

ML_1 (glEdgeFlag, Int_val)
ML_1 (glEnable, GLenum_val)
ML_0 (glEnd)
ML_1 (glEvalCoord1d, Double_val)
ML_2 (glEvalCoord2d, Double_val, Double_val)
ML_3 (glEvalMesh1, GLenum_val, Int_val, Int_val)
ML_5 (glEvalMesh2, GLenum_val, Int_val, Int_val, Int_val, Int_val)
ML_1 (glEvalPoint1, Int_val)
ML_2 (glEvalPoint2, Int_val, Int_val)

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

ML_0 (glFlush)
ML_0 (glFinish)
ML_1 (glFrontFace, GLenum_val)
ML_3 (glFrustum, Pair(arg1,Double_val,Double_val),
      Pair(arg2,Double_val,Double_val), Pair(arg3,Double_val,Double_val))

ML_1_ (glGetString, GLenum_val, copy_string)

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

ML_1 (glIndexMask, Int_val)
ML_1 (glIndexd, Double_val)
ML_0 (glInitNames)
ML_1_ (glIsEnabled, GLenum_val, Val_int)

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
	for (i = 0; i < 4; i++)
	    params[i] = Float_val (Field(Field(param, 1), i));
	break;
    case MLTAG_spot_direction:
	for (i = 0; i < 3; i++)
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
	glLightModeli (GL_LIGHT_MODEL_TWO_SIDE,
		       Int_val(Field(param,1)));
	break;
    }
    return Val_unit;
}

ML_1 (glLineWidth, Float_val)
ML_2 (glLineStipple, Int_val, Int_val)
ML_1 (glLoadName, Int_val)
ML_0 (glLoadIdentity)
ML_1 (glLoadMatrixd, Double_raw)
ML_1 (glLogicOp, GLenum_val)

value ml_glMap1d (value target, value *u, value order, value raw)
{
    int ustride, i;
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
    glMap1d (targ, Double_val(u[0]), Double_val(u[1]),
	     ustride, Int_val(order), Double_raw(raw));
    return Val_unit;
}

value ml_glMap2d (value target, value u, value uorder,
		  value v, value vorder, value raw)
{
    int ustride;
    GLenum targ;

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
    glMap2d (targ, Double_val(Field(u,0)), Double_val(Field(u,1)), ustride,
	     Int_val(uorder), Double_val(Field(v,0)), Double_val(Field(v,1)),
	     Int_val(uorder)*ustride, Int_val(vorder), Double_raw(raw));
    return Val_unit;
}

ML_bc6 (ml_glMap2d)

ML_2 (glMapGrid1d, Int_val, Pair(arg2,Double_val,Double_val))
ML_4 (glMapGrid2d, Int_val, Pair(arg2,Double_val,Double_val),
      Int_val, Pair(arg4,Double_val,Double_val))

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

ML_1 (glMatrixMode, GLenum_val)
ML_1 (glMultMatrixd, Double_raw)

ML_3 (glNormal3d, Double_val, Double_val, Double_val)

ML_1 (glPassThrough, Float_val)

value ml_glPixelMapfv (value map, value raw)
{
    glPixelMapfv (GLenum_val(map), Int_val(Size_raw(raw))/sizeof(GLfloat),
		  Float_raw(raw));
    return Val_unit;
}

ML_3 (glOrtho, Pair(arg1,Double_val,Double_val),
      Pair(arg2,Double_val,Double_val), Pair(arg3,Double_val,Double_val))

ML_1 (glPixelStorei, Pair(arg1,GLenum_val,Int_val))

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

ML_2 (glPixelZoom, Float_val, Float_val)
ML_1 (glPointSize, Float_val)
ML_2 (glPolygonMode, GLenum_val, GLenum_val)
ML_1 (glPolygonStipple, (unsigned char *)Byte_raw)
ML_0 (glPopAttrib)
ML_0 (glPopMatrix)
ML_0 (glPopName)

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

ML_0 (glPushMatrix)
ML_1 (glPushName, Int_val)

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

ML_6 (glReadPixels, Int_val, Int_val, Int_val, Int_val, GLenum_val,
      Type_void_raw)
ML_bc6 (ml_glReadPixels)
ML_2 (glRectd, Pair(arg1,Double_val,Double_val),
      Pair(arg2,Double_val,Double_val))
ML_1_ (glRenderMode, GLenum_val, Val_int)
ML_4 (glRotated, Double_val, Double_val, Double_val, Double_val)
ML_3 (glScaled, Double_val, Double_val, Double_val)

ML_4 (glScissor, Int_val, Int_val, Int_val, Int_val)
ML_1 (glSelectBuffer, Type_void_raw)
ML_1 (glShadeModel, GLenum_val)
ML_3 (glStencilFunc, GLenum_val, Int_val, Int_val)
ML_1 (glStencilMask, Int_val)
ML_3 (glStencilOp, GLenum_val, GLenum_val, GLenum_val)

ML_1 (glTexCoord1d, Double_val)
ML_2 (glTexCoord2d, Double_val, Double_val)
ML_3 (glTexCoord3d, Double_val, Double_val, Double_val)
ML_4 (glTexCoord4d, Double_val, Double_val, Double_val, Double_val)

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
    
ML_3 (glTranslated, Double_val, Double_val, Double_val)

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

ML_4 (glViewport, Int_val, Int_val, Int_val, Int_val)


/* List functions */

ML_1_ (glIsList, Int_val, Val_int)
ML_2 (glDeleteLists, Int_val, Int_val)
ML_1_ (glGenLists, Int_val, Val_int)
ML_2 (glNewList, Int_val, GLenum_val)
ML_0 (glEndList)
ML_1 (glCallList, Int_val)
ML_1 (glListBase, Int_val)

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
