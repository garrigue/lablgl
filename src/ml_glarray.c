
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
  switch (Kind_raw(raw)) {

  case MLTAG_bitmap:
    glEdgeFlagPointer(0, (void*) Byte_raw(raw));
    break;
  default:
    ml_raise_gl("glEdgeFlagPointer, type unsupported");
  }
  return Val_unit;
}

CAMLprim value ml_glTexCoordPointer(value ml_size, value raw)
{
  int size = Int_val(ml_size);
  if (size < 1 || size > 4) {
    ml_raise_gl("glTexCoordPointer: invalid size");
  }
  switch (Kind_raw(raw)) {

  case MLTAG_short:
    glTexCoordPointer(size, GL_SHORT, 0, (void*) Short_raw(raw));
    break;
  case MLTAG_int:
    glTexCoordPointer(size, GL_INT, 0, (void*) Int_raw(raw));
    break;
  case MLTAG_float:
    glTexCoordPointer(size, GL_FLOAT, 0, (void*) Float_raw(raw));
    break;
  case MLTAG_double:
    glTexCoordPointer(size, GL_DOUBLE, 0, (void*) Double_raw(raw));
    break;
  default:
    ml_raise_gl("glTexCoordPointer, type unsupported");
  }
  return Val_unit;
}

CAMLprim value ml_glColorPointer(value ml_size, value raw)
{
  int size = Int_val(ml_size);

  if (size < 3 || size > 4) {
    ml_raise_gl("glColorPointer: invalid size");
  }

  switch (Kind_raw(raw)) {

  case MLTAG_byte:
    glColorPointer(size, GL_BYTE, 0, (void*) Byte_raw(raw));
    break;
  case MLTAG_ubyte:
    glColorPointer(size, GL_UNSIGNED_BYTE, 0, (void*) Byte_raw(raw));
    break;
  case MLTAG_short:
    glColorPointer(size, GL_SHORT, 0, (void*) Short_raw(raw));
    break;
  case MLTAG_ushort:
    glColorPointer(size, GL_UNSIGNED_SHORT, 0, (void*) Short_raw(raw));
    break;
  case MLTAG_int:
    glColorPointer(size, GL_INT, 0, (void*) Int_raw(raw));
    break;
  case MLTAG_uint:
    glColorPointer(size, GL_UNSIGNED_INT, 0, (void*) Int_raw(raw));
    break;
  case MLTAG_float:
    glColorPointer(size, GL_FLOAT, 0, (void*) Float_raw(raw));
    break;
  case MLTAG_double:
    glColorPointer(size, GL_DOUBLE, 0, (void*) Double_raw(raw));
    break;
  default:
    ml_raise_gl("glColorPointer, type unsupported");
  }
  return Val_unit;
}

CAMLprim value ml_glIndexPointer(value raw)
{
  switch (Kind_raw(raw)) {

  case MLTAG_ubyte:
    glIndexPointer(GL_UNSIGNED_BYTE, 0, (void*) Byte_raw(raw));
    break;
  case MLTAG_short:
    glIndexPointer(GL_SHORT, 0, (void*) Short_raw(raw));
    break;
  case MLTAG_int:
    glIndexPointer(GL_INT, 0, (void*) Int_raw(raw));
    break;
  case MLTAG_float:
    glIndexPointer(GL_FLOAT, 0, (void*) Float_raw(raw));
    break;
  case MLTAG_double:
    glIndexPointer(GL_DOUBLE, 0, (void*) Double_raw(raw));
    break;
  default:
    ml_raise_gl("glIndexPointer, type unsupported");
  }
  return Val_unit;
}

CAMLprim value ml_glNormalPointer(value raw)
{
  switch (Kind_raw(raw)) {

  case MLTAG_byte:
    glNormalPointer(GL_BYTE, 0, (void*) Byte_raw(raw));
    break;
  case MLTAG_short:
    glNormalPointer(GL_SHORT, 0, (void*) Short_raw(raw));
    break;
  case MLTAG_int:
    glNormalPointer(GL_INT, 0, (void*) Int_raw(raw));
    break;
  case MLTAG_float:
    glNormalPointer(GL_FLOAT, 0, (void*) Float_raw(raw));
    break;
  case MLTAG_double:
    glNormalPointer(GL_DOUBLE, 0, (void*) Double_raw(raw));
    break;
  default:
    ml_raise_gl("glNormalPointer, type unsupported");
  }

  return Val_unit;
}

CAMLprim value ml_glVertexPointer(value ml_size, value raw)
{
  int size = Int_val(ml_size);
  if (size < 2 || size > 4) {
    ml_raise_gl("glVertexPointer: invalid size");
  }

  switch (Kind_raw(raw)) {

  case MLTAG_short:
    glVertexPointer(size, GL_SHORT, 0, (void*) Short_raw(raw));
    break;
  case MLTAG_int:
    glVertexPointer(size, GL_INT, 0, (void*) Int_raw(raw));
    break;
  case MLTAG_float:
    glVertexPointer(size, GL_FLOAT, 0, (void*) Float_raw(raw));
    break;
  case MLTAG_double:
    glVertexPointer(size, GL_DOUBLE, 0, (void*) Double_raw(raw));
    break;
  default:
    ml_raise_gl("glVertexPointer, type unsupported");
  }

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
  switch (Kind_raw(raw)) {

  case MLTAG_ubyte:
    glDrawElements(GLenum_val(mode), Int_val(count),
		   GL_UNSIGNED_BYTE, (void*) Byte_raw(raw));
    break;
  case MLTAG_ushort:
    glDrawElements(GLenum_val(mode), Int_val(count),
		   GL_UNSIGNED_SHORT, (void*) Short_raw(raw));
    break;
  case MLTAG_uint:
    glDrawElements(GLenum_val(mode), Int_val(count),
		   GL_UNSIGNED_INT, (void*) Int_raw(raw));
    break;
  default:
    ml_raise_gl("glDrawElements, type unsupported");
  }

  return Val_unit;
}
