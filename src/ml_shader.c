/* $Id: ml_shader.c,v 1.1 2010-03-11 08:30:02 garrigue Exp $ */
/* Code contributed by Florent Monnier */

#define GL_GLEXT_PROTOTYPES
#define CAML_NAME_SPACE

#ifdef _WIN32
#include <wtypes.h>
#endif
#include <string.h>
#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glext.h>
#else
#include <GL/gl.h>
#include <GL/glext.h>
#endif

#include <caml/misc.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/fail.h>

#include "gl_tags.h"
#include "ml_gl.h"


#ifdef _WIN32
#include <windows.h>

// if the PFNGL*PROC types are not defined in gl.h or glext.h add these lines:

#if 0
typedef GLuint (APIENTRYP PFNGLCREATESHADERPROC) (GLenum type);
typedef void (APIENTRYP PFNGLDELETESHADERPROC) (GLuint shader);
typedef GLboolean (APIENTRYP PFNGLISSHADERPROC) (GLuint shader);
typedef void (APIENTRYP PFNGLSHADERSOURCEPROC) (GLuint shader, GLsizei count, const GLchar* *string, const GLint *length);
typedef void (APIENTRYP PFNGLCOMPILESHADERPROC) (GLuint shader);
typedef void (APIENTRYP PFNGLGETSHADERIVPROC) (GLuint shader, GLenum pname, GLint *params);

typedef GLuint (APIENTRYP PFNGLCREATEPROGRAMPROC) (void);
typedef void (APIENTRYP PFNGLDELETEPROGRAMPROC) (GLuint program);
typedef GLboolean (APIENTRYP PFNGLISPROGRAMPROC) (GLuint program);
typedef void (APIENTRYP PFNGLUSEPROGRAMPROC) (GLuint program);
typedef void (APIENTRYP PFNGLATTACHSHADERPROC) (GLuint program, GLuint shader);
typedef void (APIENTRYP PFNGLDETACHSHADERPROC) (GLuint program, GLuint shader);
typedef void (APIENTRYP PFNGLLINKPROGRAMPROC) (GLuint program);
typedef void (APIENTRYP PFNGLGETPROGRAMIVPROC) (GLuint program, GLenum pname, GLint *params);

typedef void (APIENTRYP PFNGLGETPROGRAMINFOLOGPROC) (GLuint program, GLsizei bufSize, GLsizei *length, GLchar *infoLog);
typedef void (APIENTRYP PFNGLGETSHADERINFOLOGPROC) (GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *infoLog);
typedef GLint (APIENTRYP PFNGLGETUNIFORMLOCATIONPROC) (GLuint program, const GLchar *name);

typedef void (APIENTRYP PFNGLUNIFORM1IPROC) (GLint location, GLint v0);
typedef void (APIENTRYP PFNGLUNIFORM2IPROC) (GLint location, GLint v0, GLint v1);
typedef void (APIENTRYP PFNGLUNIFORM3IPROC) (GLint location, GLint v0, GLint v1, GLint v2);
typedef void (APIENTRYP PFNGLUNIFORM4IPROC) (GLint location, GLint v0, GLint v1, GLint v2, GLint v3);
typedef void (APIENTRYP PFNGLUNIFORM1IVPROC) (GLint location, GLsizei count, const GLint *value);
typedef void (APIENTRYP PFNGLUNIFORM2IVPROC) (GLint location, GLsizei count, const GLint *value);
typedef void (APIENTRYP PFNGLUNIFORM3IVPROC) (GLint location, GLsizei count, const GLint *value);
typedef void (APIENTRYP PFNGLUNIFORM4IVPROC) (GLint location, GLsizei count, const GLint *value);
typedef void (APIENTRYP PFNGLUNIFORM1FPROC) (GLint location, GLfloat v0);
typedef void (APIENTRYP PFNGLUNIFORM2FPROC) (GLint location, GLfloat v0, GLfloat v1);
typedef void (APIENTRYP PFNGLUNIFORM3FPROC) (GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
typedef void (APIENTRYP PFNGLUNIFORM4FPROC) (GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);
typedef void (APIENTRYP PFNGLUNIFORM1FVPROC) (GLint location, GLsizei count, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORM2FVPROC) (GLint location, GLsizei count, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORM3FVPROC) (GLint location, GLsizei count, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORM4FVPROC) (GLint location, GLsizei count, const GLfloat *value);

typedef void (APIENTRYP PFNGLUNIFORMMATRIX2FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORMMATRIX3FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORMMATRIX4FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

typedef void (APIENTRYP PFNGLUNIFORMMATRIX2X3FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORMMATRIX3X2FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORMMATRIX2X4FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORMMATRIX4X2FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORMMATRIX3X4FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
typedef void (APIENTRYP PFNGLUNIFORMMATRIX4X3FVPROC) (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

typedef GLint (APIENTRYP PFNGLGETATTRIBLOCATIONPROC) (GLuint program, const GLchar *name);

typedef void (APIENTRYP PFNGLVERTEXATTRIB1SPROC) (GLuint index, GLshort x);
typedef void (APIENTRYP PFNGLVERTEXATTRIB1DPROC) (GLuint index, GLdouble x);
typedef void (APIENTRYP PFNGLVERTEXATTRIB2SPROC) (GLuint index, GLshort x, GLshort y);
typedef void (APIENTRYP PFNGLVERTEXATTRIB2DPROC) (GLuint index, GLdouble x, GLdouble y);
typedef void (APIENTRYP PFNGLVERTEXATTRIB3SPROC) (GLuint index, GLshort x, GLshort y, GLshort z);
typedef void (APIENTRYP PFNGLVERTEXATTRIB3DPROC) (GLuint index, GLdouble x, GLdouble y, GLdouble z);
typedef void (APIENTRYP PFNGLVERTEXATTRIB4SPROC) (GLuint index, GLshort x, GLshort y, GLshort z, GLshort w);
typedef void (APIENTRYP PFNGLVERTEXATTRIB4DPROC) (GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w);

typedef void (APIENTRYP PFNGLBINDATTRIBLOCATIONPROC) (GLuint program, GLuint index, const GLchar *name);
#endif


#define LOAD_FUNC(func, f_type) \
    static f_type func = NULL; \
    static unsigned int func##_is_loaded = 0; \
    if (!func##_is_loaded) { \
        func = (f_type) wglGetProcAddress(#func); \
        if (func == NULL) caml_failwith("Unable to load " #func); \
        else func##_is_loaded = 1; \
    }

#else
#define LOAD_FUNC(func, f_type)
#endif
/* end of ifdef _WIN32 */



/* GLSL Shaders */

#ifdef GL_VERSION_2_0

/* wrap as abstract */
//define Val_shader_object(v) ((value)(v))
//define Shader_object_val(v) ((GLuint)(v))

//define Val_shader_program(v) ((value)(v))
//define Shader_program_val(v) ((GLuint)(v))

/* wrap as ints */
#define Val_shader_object Val_long
#define Shader_object_val Long_val

#define Val_shader_program Val_long
#define Shader_program_val Long_val


CAMLprim value ml_glcreateshader( value shaderType )
{
    GLuint s = 0;
    LOAD_FUNC(glCreateShader, PFNGLCREATESHADERPROC)
    switch (shaderType) {
    case MLTAG_vertex_shader: s = glCreateShader(GL_VERTEX_SHADER); break;
    case MLTAG_fragment_shader: s = glCreateShader(GL_FRAGMENT_SHADER); break;
    default: caml_failwith("glShader.create");
    }
    if (s == 0) caml_failwith("glShader.create");
    return Val_shader_object(s);
}

CAMLprim value ml_gldeleteshader( value shader )
{
    LOAD_FUNC(glDeleteShader, PFNGLDELETESHADERPROC)
    glDeleteShader( Shader_object_val(shader) );
    return Val_unit;
}

CAMLprim value ml_glisshader( value shader )
{
    LOAD_FUNC(glIsShader, PFNGLISSHADERPROC)
    return (glIsShader( Shader_object_val(shader) ) == GL_TRUE ? Val_true : Val_false);
}

CAMLprim value ml_glshadersource( value shader, value str )
{
    const char * vp = String_val(str);
    LOAD_FUNC(glShaderSource, PFNGLSHADERSOURCEPROC)
    glShaderSource(Shader_object_val(shader), 1, &vp, NULL);
    return Val_unit;
}

CAMLprim value ml_glcompileshader( value shader )
{
    LOAD_FUNC(glCompileShader, PFNGLCOMPILESHADERPROC)
    glCompileShader( Shader_object_val(shader) );
    return Val_unit;
}

CAMLprim value ml_glcreateprogram( value unit )
{
    LOAD_FUNC(glCreateProgram, PFNGLCREATEPROGRAMPROC)
    GLuint p = glCreateProgram();
    if (p == 0) caml_failwith("glShader.create_program");
    return Val_shader_program(p);
}

CAMLprim value ml_gldeleteprogram( value program )
{
    LOAD_FUNC(glDeleteProgram, PFNGLDELETEPROGRAMPROC)
    glDeleteProgram( Shader_program_val(program) );
    return Val_unit;
}

CAMLprim value ml_glattachshader( value program, value shader )
{
    LOAD_FUNC(glAttachShader, PFNGLATTACHSHADERPROC)
    glAttachShader( Shader_program_val(program), Shader_object_val(shader) );
    return Val_unit;
}

CAMLprim value ml_gldetachshader( value program, value shader )
{
    LOAD_FUNC(glDetachShader, PFNGLDETACHSHADERPROC)
    glDetachShader( Shader_program_val(program), Shader_object_val(shader) );
    return Val_unit;
}

CAMLprim value ml_gllinkprogram( value program )
{
    LOAD_FUNC(glLinkProgram, PFNGLLINKPROGRAMPROC)
    glLinkProgram( Shader_program_val(program) );
    return Val_unit;
}

CAMLprim value ml_gluseprogram( value program )
{
    LOAD_FUNC(glUseProgram, PFNGLUSEPROGRAMPROC)
    glUseProgram( Shader_program_val(program) );
    return Val_unit;
}
CAMLprim value ml_glunuseprogram( value unit )
{
    /* desactivate */
    LOAD_FUNC(glUseProgram, PFNGLUSEPROGRAMPROC)
    glUseProgram(0);
    return Val_unit;
}

CAMLprim value ml_glgetshadercompilestatus( value shader )
{
    GLint error;
    LOAD_FUNC(glGetShaderiv, PFNGLGETSHADERIVPROC)
    glGetShaderiv( Shader_object_val(shader), GL_COMPILE_STATUS, &error);
    if (error == GL_TRUE) return Val_true;
    else return Val_false;
}

CAMLprim value ml_glgetshadercompilestatus_exn( value shader )
{
    GLint error;
    LOAD_FUNC(glGetShaderiv, PFNGLGETSHADERIVPROC)
    glGetShaderiv( Shader_object_val(shader), GL_COMPILE_STATUS, &error);
    if (error != GL_TRUE)
        caml_failwith("Shader compile status: error");
    return Val_unit;
}

CAMLprim value ml_glgetuniformlocation( value program, value name )
{
    LOAD_FUNC(glGetUniformLocation, PFNGLGETUNIFORMLOCATIONPROC)
    return Val_int( glGetUniformLocation( Shader_program_val(program), String_val(name) ));
}

#else
CAMLprim value ml_glcreateshader( value shaderType )
{
    caml_failwith("glCreateShader function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gldeleteshader( value shader )
{
    caml_failwith("glDeleteShader function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glisshader( value shader )
{
    caml_failwith("glIsShader function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glshadersource( value shader, value str )
{
    caml_failwith("glShaderSource function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glcompileshader( value shader )
{
    caml_failwith("glCompileShader function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glcreateprogram( value unit )
{
    caml_failwith("glCreateProgram function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gldeleteprogram( value program )
{
    caml_failwith("glDeleteProgram function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glattachshader( value program, value shader )
{
    caml_failwith("glAttachShader function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gldetachshader( value program, value shader )
{
    caml_failwith("glDetachShader function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gllinkprogram( value program )
{
    caml_failwith("glLinkProgram function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluseprogram( value program )
{
    caml_failwith("glUseProgram function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glunuseprogram( value unit )
{
    caml_failwith("glUseProgram function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glgetuniformlocation( value program, value name )
{
    caml_failwith("glGetUniformLocation function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
#endif


#ifdef GL_VERSION_2_0

CAMLprim value ml_gluniform1f( value location, value v0) {
    LOAD_FUNC(glUniform1f, PFNGLUNIFORM1FPROC)
    glUniform1f( Int_val(location), Double_val(v0));
    return Val_unit;
}

CAMLprim value ml_gluniform2f( value location, value v0, value v1) {
    LOAD_FUNC(glUniform2f, PFNGLUNIFORM2FPROC)
    glUniform2f( Int_val(location), Double_val(v0), Double_val(v1));
    return Val_unit;
}

CAMLprim value ml_gluniform3f( value location, value v0, value v1, value v2) {
    LOAD_FUNC(glUniform3f, PFNGLUNIFORM3FPROC)
    glUniform3f( Int_val(location), Double_val(v0), Double_val(v1), Double_val(v2));
    return Val_unit;
}

CAMLprim value ml_gluniform4f( value location, value v0, value v1, value v2, value v3) {
    LOAD_FUNC(glUniform4f, PFNGLUNIFORM4FPROC)
    glUniform4f( Int_val(location), Double_val(v0), Double_val(v1), Double_val(v2), Double_val(v3));
    return Val_unit;
}

CAMLprim value ml_gluniform1i( value location, value v0) {
    LOAD_FUNC(glUniform1i, PFNGLUNIFORM1IPROC)
    glUniform1i( Int_val(location), Int_val(v0));
    return Val_unit;
}

CAMLprim value ml_gluniform2i( value location, value v0, value v1) {
    LOAD_FUNC(glUniform2i, PFNGLUNIFORM2IPROC)
    glUniform2i( Int_val(location), Int_val(v0), Int_val(v1));
    return Val_unit;
}

CAMLprim value ml_gluniform3i( value location, value v0, value v1, value v2) {
    LOAD_FUNC(glUniform3i, PFNGLUNIFORM3IPROC)
    glUniform3i( Int_val(location), Int_val(v0), Int_val(v1), Int_val(v2));
    return Val_unit;
}

CAMLprim value ml_gluniform4i( value location, value v0, value v1, value v2, value v3) {
    LOAD_FUNC(glUniform4i, PFNGLUNIFORM4IPROC)
    glUniform4i( Int_val(location), Int_val(v0), Int_val(v1), Int_val(v2), Int_val(v3));
    return Val_unit;
}

#else

CAMLprim value ml_gluniform1f( value location, value v0) {
    caml_failwith("glUniform1f function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform2f( value location, value v0, value v1) {
    caml_failwith("glUniform2f function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform3f( value location, value v0, value v1, value v2) {
    caml_failwith("glUniform3f function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform4f( value location, value v0, value v1, value v2, value v3) {
    caml_failwith("glUniform4f function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform1i( value location, value v0) {
    caml_failwith("glUniform1i function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform2i( value location, value v0, value v1) {
    caml_failwith("glUniform2i function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform3i( value location, value v0, value v1, value v2) {
    caml_failwith("glUniform3i function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform4i( value location, value v0, value v1, value v2, value v3) {
    caml_failwith("glUniform4i function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}

#endif


#ifdef GL_VERSION_2_0

CAMLprim value ml_gluniform1fv( value location, value vars )
{
    int i, len = Wosize_val(vars) / Double_wosize;
    GLfloat val[len];
    for (i=0; i<len; i++) {
        val[i] = Double_field(vars, i);
    }
    LOAD_FUNC(glUniform1fv, PFNGLUNIFORM1FVPROC)
    glUniform1fv( Int_val(location), len, val );
    return Val_unit;
}
CAMLprim value ml_gluniform2fv( value location, value ml_count, value vars )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(vars) / Double_wosize;
    GLfloat val[len];
    if (len != (2 * count)) caml_failwith("GlShader.uniform2fv: the array size should be a multiple of 2");
    for (i=0; i<len; i++) {
        val[i] = Double_field(vars, i);
    }
    LOAD_FUNC(glUniform2fv, PFNGLUNIFORM2FVPROC)
    glUniform2fv( Int_val(location), count, val );
    return Val_unit;
}
CAMLprim value ml_gluniform3fv( value location, value ml_count, value vars )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(vars) / Double_wosize;
    GLfloat val[len];
    if (len != (3 * count)) caml_failwith("GlShader.uniform3fv: the array size should be a multiple of 3");
    for (i=0; i<len; i++) {
        val[i] = Double_field(vars, i);
    }
    LOAD_FUNC(glUniform3fv, PFNGLUNIFORM3FVPROC)
    glUniform3fv( Int_val(location), count, val );
    return Val_unit;
}
CAMLprim value ml_gluniform4fv( value location, value ml_count, value vars )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(vars) / Double_wosize;
    GLfloat val[len];
    if (len != (4 * count)) caml_failwith("GlShader.uniform4fv: the array size should be a multiple of 4");
    for (i=0; i<len; i++) {
        val[i] = Double_field(vars, i);
    }
    LOAD_FUNC(glUniform4fv, PFNGLUNIFORM4FVPROC)
    glUniform4fv( Int_val(location), count, val );
    return Val_unit;
}



CAMLprim value ml_gluniform1iv( value location, value vars )
{
    int i, len = Wosize_val(vars);
    GLint val[len];
    for (i=0; i<len; i++) {
        val[i] = Long_val(Field(vars, i));
    }
    LOAD_FUNC(glUniform1iv, PFNGLUNIFORM1IVPROC)
    glUniform1iv( Int_val(location), len, val );
    return Val_unit;
}
CAMLprim value ml_gluniform2iv( value location, value ml_count, value vars )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(vars);
    GLint val[len];
    if (len != (2 * count)) caml_failwith("GlShader.uniform2iv: the array size should be a multiple of 2");
    for (i=0; i<len; i++) {
        val[i] = Long_val(Field(vars, i));
    }
    LOAD_FUNC(glUniform2iv, PFNGLUNIFORM2IVPROC)
    glUniform2iv( Int_val(location), count, val );
    return Val_unit;
}
CAMLprim value ml_gluniform3iv( value location, value ml_count, value vars )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(vars);
    GLint val[len];
    if (len != (3 * count)) caml_failwith("GlShader.uniform3iv: the array size should be a multiple of 3");
    for (i=0; i<len; i++) {
        val[i] = Long_val(Field(vars, i));
    }
    LOAD_FUNC(glUniform3iv, PFNGLUNIFORM3IVPROC)
    glUniform3iv( Int_val(location), count, val );
    return Val_unit;
}
CAMLprim value ml_gluniform4iv( value location, value ml_count, value vars )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(vars);
    GLint val[len];
    if (len != (4 * count)) caml_failwith("GlShader.uniform4iv: the array size should be a multiple of 4");
    for (i=0; i<len; i++) {
        val[i] = Long_val(Field(vars, i));
    }
    LOAD_FUNC(glUniform4iv, PFNGLUNIFORM4IVPROC)
    glUniform4iv( Int_val(location), count, val );
    return Val_unit;
}

#else

CAMLprim value ml_gluniform1fv( value location, value vars ) {
    caml_failwith("glUniform1fv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform2fv( value location, value ml_count, value vars )
    caml_failwith("glUniform2fv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform3fv( value location, value ml_count, value vars )
    caml_failwith("glUniform3fv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform4fv( value location, value ml_count, value vars )
    caml_failwith("glUniform4fv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}

CAMLprim value ml_gluniform1iv( value location, value vars ) {
    caml_failwith("glUniform1iv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform2iv( value location, value ml_count, value vars )
    caml_failwith("glUniform2iv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform3iv( value location, value ml_count, value vars )
    caml_failwith("glUniform3iv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniform4iv( value location, value ml_count, value vars )
    caml_failwith("glUniform4iv function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
}
#endif



#ifdef GL_VERSION_2_1

/* with a single matrix */

CAMLprim value ml_gluniformmatrix2f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[4];
    int len = Wosize_val(mat) / Double_wosize;
    if (len != 4) caml_failwith("GlShader.uniform_matrix2f: array should contain 4 floats");
    val[0] = Double_field(mat, 0);
    val[1] = Double_field(mat, 1);
    val[2] = Double_field(mat, 2);
    val[3] = Double_field(mat, 3);
    LOAD_FUNC(glUniformMatrix2fv, PFNGLUNIFORMMATRIX2FVPROC)
    glUniformMatrix2fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix3f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[9];
    int i, len;
    len = Wosize_val(mat) / Double_wosize;
    if (len != 9) caml_failwith("GlShader.uniform_matrix3f: array should contain 9 floats");
    for (i=0; i<9; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix3fv, PFNGLUNIFORMMATRIX3FVPROC)
    glUniformMatrix3fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix4f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[16];
    int i, len;
    len = Wosize_val(mat) / Double_wosize;
    if (len != 16) caml_failwith("GlShader.uniform_matrix4f: array should contain 16 floats");
    for (i=0; i<16; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix4fv, PFNGLUNIFORMMATRIX4FVPROC)
    glUniformMatrix4fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix2x3f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[6];
    int i, len;
    LOAD_FUNC(glUniformMatrix2x3fv, PFNGLUNIFORMMATRIX2X3FVPROC)
    len = Wosize_val(mat) / Double_wosize;
    if (len != 6) caml_failwith("GlShader.uniform_matrix2x3f: array should contain 6 floats");
    for (i=0; i<6; i++) {
        val[i] = Double_field(mat, i);
    }
    glUniformMatrix2x3fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix3x2f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[6];
    int i, len;
    len = Wosize_val(mat) / Double_wosize;
    if (len != 6) caml_failwith("GlShader.uniform_matrix3x2f: array should contain 6 floats");
    for (i=0; i<6; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix3x2fv, PFNGLUNIFORMMATRIX3X2FVPROC)
    glUniformMatrix3x2fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix2x4f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[8];
    int i, len;
    len = Wosize_val(mat) / Double_wosize;
    if (len != 8) caml_failwith("GlShader.uniform_matrix2x4f: array should contain 8 floats");
    for (i=0; i<8; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix2x4fv, PFNGLUNIFORMMATRIX2X4FVPROC)
    glUniformMatrix2x4fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix4x2f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[8];
    int i, len;
    len = Wosize_val(mat) / Double_wosize;
    if (len != 8) caml_failwith("GlShader.uniform_matrix4x2f: array should contain 8 floats");
    for (i=0; i<8; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix4x2fv, PFNGLUNIFORMMATRIX4X2FVPROC)
    glUniformMatrix4x2fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix3x4f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[12];
    int i, len;
    len = Wosize_val(mat) / Double_wosize;
    if (len != 12) caml_failwith("GlShader.uniform_matrix3x4f: array should contain 12 floats");
    for (i=0; i<12; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix3x4fv, PFNGLUNIFORMMATRIX3X4FVPROC)
    glUniformMatrix3x4fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix4x3f(
        value location,
        value transpose,
        value mat )
{
    GLfloat val[12];
    int i, len;
    len = Wosize_val(mat) / Double_wosize;
    if (len != 12) caml_failwith("GlShader.uniform_matrix4x3f: array should contain 12 floats");
    for (i=0; i<12; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix4x3fv, PFNGLUNIFORMMATRIX4X3FVPROC)
    glUniformMatrix4x3fv(
        Int_val(location),
        1,
        Bool_val(transpose),
        val );
    return Val_unit;
}

/* with multiple matrices */

CAMLprim value ml_gluniformmatrix2fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (4 * count)) caml_failwith("GlShader.uniform_matrix2fv: the array size should be a multiple of 4");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix2fv, PFNGLUNIFORMMATRIX2FVPROC)
    glUniformMatrix2fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix3fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (9 * count)) caml_failwith("GlShader.uniform_matrix3fv: the array size should be a multiple of 9");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix3fv, PFNGLUNIFORMMATRIX3FVPROC)
    glUniformMatrix3fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix4fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (16 * count)) caml_failwith("GlShader.uniform_matrix4fv: the array size should be a multiple of 16");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix4fv, PFNGLUNIFORMMATRIX4FVPROC)
    glUniformMatrix4fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix2x3fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    LOAD_FUNC(glUniformMatrix2x3fv, PFNGLUNIFORMMATRIX2X3FVPROC)
    if (len != (6 * count)) caml_failwith("GlShader.uniform_matrix2x3fv: the array size should be a multiple of 6");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    glUniformMatrix2x3fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix3x2fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (6 * count)) caml_failwith("GlShader.uniform_matrix3x2fv: the array size should be a multiple of 6");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix3x2fv, PFNGLUNIFORMMATRIX3X2FVPROC)
    glUniformMatrix3x2fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix2x4fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (8 * count)) caml_failwith("GlShader.uniform_matrix2x4fv: the array size should be a multiple of 8");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix2x4fv, PFNGLUNIFORMMATRIX2X4FVPROC)
    glUniformMatrix2x4fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix4x2fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (8 * count)) caml_failwith("GlShader.uniform_matrix4x2fv: the array size should be a multiple of 8");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix4x2fv, PFNGLUNIFORMMATRIX4X2FVPROC)
    glUniformMatrix4x2fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix3x4fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (12 * count)) caml_failwith("GlShader.uniform_matrix3x4fv: the array size should be a multiple of 12");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix3x4fv, PFNGLUNIFORMMATRIX3X4FVPROC)
    glUniformMatrix3x4fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix4x3fv(
        value location,
        value ml_count,
        value transpose,
        value mat )
{
    int count = Int_val(ml_count);
    int i, len = Wosize_val(mat) / Double_wosize;
    GLfloat val[len];
    if (len != (12 * count)) caml_failwith("GlShader.uniform_matrix4x3fv: the array size should be a multiple of 12");
    for (i=0; i<len; i++) {
        val[i] = Double_field(mat, i);
    }
    LOAD_FUNC(glUniformMatrix4x3fv, PFNGLUNIFORMMATRIX4X3FVPROC)
    glUniformMatrix4x3fv(
        Int_val(location),
        count,
        Bool_val(transpose),
        val );
    return Val_unit;
}

#else
CAMLprim value ml_gluniformmatrix2f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix2fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix3f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix3fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix4f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix4fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix2x3f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix2x3fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix3x2f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix3x2fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix2x4f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix2x4fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix4x2f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix4x2fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix3x4f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix3x4fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix4x3f( value location, value transpose, value mat ) {
    caml_failwith("glUniformMatrix4x3fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}

CAMLprim value ml_gluniformmatrix2fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix2fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix3fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix3fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix4fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix4fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix2x3fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix2x3fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix3x2fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix3x2fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix2x4fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix2x4fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix4x2fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix4x2fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix3x4fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix3x4fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
CAMLprim value ml_gluniformmatrix4x3fv( value location, value count, value transpose, value mat ) {
    caml_failwith("glUniformMatrix4x3fv function is available only if the OpenGL version is 2.1 or greater");
    return Val_unit;
}
#endif



CAMLprim value ml_glgetattriblocation( value program, value name )
{
#ifdef GL_VERSION_2_0
    LOAD_FUNC(glGetAttribLocation, PFNGLGETATTRIBLOCATIONPROC)
    GLint attr_loc = glGetAttribLocation( Shader_program_val(program), String_val(name) );
    return Val_int(attr_loc);
#else
    caml_failwith("glGetAttribLocation function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
#endif
}


CAMLprim value ml_glbindattriblocation( value program, value index, value name )
{
#ifdef GL_VERSION_2_0
    LOAD_FUNC(glBindAttribLocation, PFNGLBINDATTRIBLOCATIONPROC)
    glBindAttribLocation( Shader_program_val(program),  Int_val(index), String_val(name) );
    return Val_unit;
#else
    caml_failwith("glBindAttribLocation function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
#endif
}




#ifdef GL_VERSION_2_0


CAMLprim value ml_glgetprogram_attached_shaders( value program )
{
    GLint params;
    LOAD_FUNC(glGetProgramiv, PFNGLGETPROGRAMIVPROC)
    glGetProgramiv( Shader_program_val(program), GL_ATTACHED_SHADERS, &params );
    return Val_int(params);
}
CAMLprim value ml_glgetprogram_active_uniforms( value program )
{
    GLint params;
    LOAD_FUNC(glGetProgramiv, PFNGLGETPROGRAMIVPROC)
    glGetProgramiv( Shader_program_val(program), GL_ACTIVE_UNIFORMS, &params );
    return Val_int(params);
}
CAMLprim value ml_glgetprogram_active_attributes( value program )
{
    GLint params;
    LOAD_FUNC(glGetProgramiv, PFNGLGETPROGRAMIVPROC)
    glGetProgramiv( Shader_program_val(program), GL_ACTIVE_ATTRIBUTES, &params );
    return Val_int(params);
}
CAMLprim value ml_glgetprogram_validate_status( value program )
{
    GLint params;
    LOAD_FUNC(glGetProgramiv, PFNGLGETPROGRAMIVPROC)
    glGetProgramiv( Shader_program_val(program), GL_VALIDATE_STATUS, &params );
    if (params == GL_TRUE) return Val_true;
    else return Val_false;
}
CAMLprim value ml_glgetprogram_link_status( value program )
{
    GLint params;
    LOAD_FUNC(glGetProgramiv, PFNGLGETPROGRAMIVPROC)
    glGetProgramiv( Shader_program_val(program), GL_LINK_STATUS, &params );
    if (params == GL_TRUE) return Val_true;
    else return Val_false;
}
CAMLprim value ml_glgetprogram_delete_status( value program )
{
    GLint params;
    LOAD_FUNC(glGetProgramiv, PFNGLGETPROGRAMIVPROC)
    glGetProgramiv( Shader_program_val(program), GL_DELETE_STATUS, &params );
    if (params == GL_TRUE) return Val_true;
    else return Val_false;
}

#else
CAMLprim value ml_glgetprogram_attached_shaders( value program ) {
    caml_failwith("get_program_attached_shaders: function available only for GL versions 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glgetprogram_active_uniforms( value program ) {
    caml_failwith("get_program_active_uniforms: function available only for GL versions 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glgetprogram_active_attributes( value program ) {
    caml_failwith("get_program_active_attributes: function available only for GL versions 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glgetprogram_validate_status( value program ) {
    caml_failwith("get_program_validate_status: function available only for GL versions 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glgetprogram_link_status( value program ) {
    caml_failwith("get_program_link_status: function available only for GL versions 2.0 or greater");
    return Val_unit;
}
CAMLprim value ml_glgetprogram_delete_status( value program ) {
    caml_failwith("get_program_delete_status: function available only for GL versions 2.0 or greater");
    return Val_unit;
}
#endif




#ifdef GL_VERSION_2_0
CAMLprim value ml_glvertexattrib1s(value index, value v0) {
    LOAD_FUNC(glVertexAttrib1s, PFNGLVERTEXATTRIB1SPROC)
    glVertexAttrib1s(Int_val(index), Int_val(v0));
    return Val_unit;
}
CAMLprim value ml_glvertexattrib1d(value index, value v0) {
    LOAD_FUNC(glVertexAttrib1d, PFNGLVERTEXATTRIB1DPROC)
    glVertexAttrib1d(Int_val(index), Double_val(v0));
    return Val_unit;
}

CAMLprim value ml_glvertexattrib2s(value index, value v0, value v1) {
    LOAD_FUNC(glVertexAttrib2s, PFNGLVERTEXATTRIB2SPROC)
    glVertexAttrib2s(Int_val(index), Int_val(v0), Int_val(v1));
    return Val_unit;
}
CAMLprim value ml_glvertexattrib2d(value index, value v0, value v1) {
    LOAD_FUNC(glVertexAttrib2d, PFNGLVERTEXATTRIB2DPROC)
    glVertexAttrib2d(Int_val(index), Double_val(v0), Double_val(v1));
    return Val_unit;
}

CAMLprim value ml_glvertexattrib3s(value index, value v0, value v1, value v2) {
    LOAD_FUNC(glVertexAttrib3s, PFNGLVERTEXATTRIB3SPROC)
    glVertexAttrib3s(Int_val(index), Int_val(v0), Int_val(v1), Int_val(v2));
    return Val_unit;
}
CAMLprim value ml_glvertexattrib3d(value index, value v0, value v1, value v2) {
    LOAD_FUNC(glVertexAttrib3d, PFNGLVERTEXATTRIB3DPROC)
    glVertexAttrib3d(Int_val(index), Double_val(v0), Double_val(v1), Double_val(v2));
    return Val_unit;
}

CAMLprim value ml_glvertexattrib4s(value index, value v0, value v1, value v2, value v3) {
    LOAD_FUNC(glVertexAttrib4s, PFNGLVERTEXATTRIB4SPROC)
    glVertexAttrib4s(Int_val(index), Int_val(v0), Int_val(v1), Int_val(v2), Int_val(v3));
    return Val_unit;
}
CAMLprim value ml_glvertexattrib4d(value index, value v0, value v1, value v2, value v3) {
    LOAD_FUNC(glVertexAttrib4d, PFNGLVERTEXATTRIB4DPROC)
    glVertexAttrib4d(Int_val(index), Double_val(v0), Double_val(v1), Double_val(v2), Double_val(v3));
    return Val_unit;
}
#else

CAMLprim value ml_glvertexattrib1s(value index, value v0) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }
CAMLprim value ml_glvertexattrib1d(value index, value v0) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }
CAMLprim value ml_glvertexattrib2s(value index, value v0, value v1) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }
CAMLprim value ml_glvertexattrib2d(value index, value v0, value v1) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }
CAMLprim value ml_glvertexattrib3s(value index, value v0, value v1, value v2) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }
CAMLprim value ml_glvertexattrib3d(value index, value v0, value v1, value v2) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }
CAMLprim value ml_glvertexattrib4s(value index, value v0, value v1, value v2, value v3) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }
CAMLprim value ml_glvertexattrib4d(value index, value v0, value v1, value v2, value v3) {
    caml_failwith("glVertexAttrib function is available only if the OpenGL version is 2.0 or greater");
    return Val_unit; }

#endif



CAMLprim value ml_glgetshaderinfolog(value shader)
{
#ifdef GL_VERSION_2_0
    int infologLength = 0;
    int charsWritten  = 0;

    LOAD_FUNC(glGetShaderiv, PFNGLGETSHADERIVPROC)
    glGetShaderiv(Shader_object_val(shader), GL_INFO_LOG_LENGTH, &infologLength);

    if (infologLength > 0)
    {
        LOAD_FUNC(glGetShaderInfoLog, PFNGLGETSHADERINFOLOGPROC)
        value infoLog = caml_alloc_string(infologLength);
        glGetShaderInfoLog(Shader_object_val(shader), infologLength, &charsWritten, Bytes_val(infoLog));
        return infoLog;
    } else {
        return caml_copy_string("");
    }
#else
    caml_failwith("glGetShaderInfoLog is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
#endif
}

CAMLprim value ml_glgetprograminfolog(value program)
{
#ifdef GL_VERSION_2_0
    int infologLength = 0;
    int charsWritten  = 0;

    LOAD_FUNC(glGetProgramiv, PFNGLGETPROGRAMIVPROC)
    glGetProgramiv( Shader_program_val(program), GL_INFO_LOG_LENGTH, &infologLength);

    if (infologLength > 0)
    {
        LOAD_FUNC(glGetProgramInfoLog, PFNGLGETPROGRAMINFOLOGPROC)
        value infoLog = caml_alloc_string(infologLength);
        glGetProgramInfoLog(Shader_program_val(program), infologLength, &charsWritten, Bytes_val(infoLog));
        return infoLog;
    } else {
        return caml_copy_string("");
    }
#else
    caml_failwith("glGetProgramInfoLog is available only if the OpenGL version is 2.0 or greater");
    return Val_unit;
#endif
}

