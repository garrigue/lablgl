
#ifdef _WIN32
#include <wtypes.h>
#endif
#include <string.h>
#include <caml/misc.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/config.h>
#ifdef __APPLE__
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "ml_gl.h"
#include "gl_tags.h"
#include "raw_tags.h"
#include "ml_raw.h"

CAMLprim value ml_glEdgeFlagPointer(value raw)
{
  glEdgeFlagPointer(0, Addr_raw(raw));
  return Val_unit;
}

CAMLprim value ml_glTexCoordPointer(value ml_size, value raw)
{
  int size = Int_val(ml_size);
  if (size < 1 || size > 4) {
    ml_raise_gl("glTexCoordPointer: invalid size");
  }

  glTexCoordPointer (size, GLenum_val(Kind_raw(raw)), 0, Void_raw(raw));
  return Val_unit;
}

CAMLprim value ml_glColorPointer(value ml_size, value raw)
{
  int size = Int_val(ml_size);

  if (size < 3 || size > 4) {
    ml_raise_gl("glColorPointer: invalid size");
  }

  glColorPointer (size, GLenum_val(Kind_raw(raw)), 0, Void_raw(raw));
  return Val_unit;
}

CAMLprim value ml_glIndexPointer(value raw)
{
  glIndexPointer (GLenum_val(Kind_raw(raw)), 0, Void_raw(raw));
  return Val_unit;
}

CAMLprim value ml_glNormalPointer(value raw)
{
  glNormalPointer (GLenum_val(Kind_raw(raw)), 0, Void_raw(raw));
  return Val_unit;
}

CAMLprim value ml_glVertexPointer(value ml_size, value raw)
{
  int size = Int_val(ml_size);
  if (size < 2 || size > 4) {
    ml_raise_gl("glVertexPointer: invalid size");
  }

  glVertexPointer (size, GLenum_val(Kind_raw(raw)), 0, Void_raw(raw));
  return Val_unit;
}

CAMLprim value ml_glEnableClientState(value kl)
{
   GLenum a;

   switch(kl) {
   case MLTAG_edge_flag: a = GL_EDGE_FLAG_ARRAY; break;
   case MLTAG_texture_coord: a = GL_TEXTURE_COORD_ARRAY; break;
   case MLTAG_color: a = GL_COLOR_ARRAY; break;
   case MLTAG_index: a = GL_INDEX_ARRAY; break;
   case MLTAG_normal: a = GL_NORMAL_ARRAY; break;
   case MLTAG_vertex: a = GL_VERTEX_ARRAY; break;
   default: ml_raise_gl("ml_glEnableClientState: invalid array");
   }
   glEnableClientState(a);
   return Val_unit;
}

CAMLprim value ml_glDisableClientState(value kl)
{
   GLenum a;

   switch(kl) {
   case MLTAG_edge_flag: a = GL_EDGE_FLAG_ARRAY; break;
   case MLTAG_texture_coord: a = GL_TEXTURE_COORD_ARRAY; break;
   case MLTAG_color: a = GL_COLOR_ARRAY; break;
   case MLTAG_index: a = GL_INDEX_ARRAY; break;
   case MLTAG_normal: a = GL_NORMAL_ARRAY; break;
   case MLTAG_vertex: a = GL_VERTEX_ARRAY; break;
   default: ml_raise_gl("ml_glDisableClientState: invalid array");
   }
   glDisableClientState(a);
   return Val_unit;
}

ML_1 (glArrayElement, Int_val);
ML_3 (glDrawArrays, GLenum_val, Int_val, Int_val);

CAMLprim value ml_glDrawElements(value mode, value count, value raw) 
{
  glDrawElements (GLenum_val(mode), Int_val(count),
                  GLenum_val(Kind_raw(raw)), Void_raw(raw));
  return Val_unit;
}
