/* $Id: ml_gl.h,v 1.1 1998-01-05 06:32:46 garrigue Exp $ */

#ifundef _ml_gl_
#define _ml_gl_

#define ML_void(cname) \
value ml_##cname (value unit) \
{ cname (); return Val_unit; }

#define ML_string(cname) \
value ml_##cname (value s) \
{ cname (String_val(s)); return Val_unit; }

#define ML_float(cname) \
value ml_##cname (value dbl) \
{ cname ((float) Double_val(dbl)); return Val_unit; }

#define ML_double(cname) \
value ml_##cname (value dbl) \
{ cname (Double_val(dbl)); return Val_unit; }
#define ML_double2(cname) \
value ml_##cname (value x, value y) \
{ cname (Double_val(x), Double_val(y)); return Val_unit; }
#define ML_double3(cname) \
value ml_##cname (value x, value y, value z) \
{ cname (Double_val(x), Double_val(y), Double_val(z)); \
  return Val_unit; }
#define ML_double4(cname) \
value ml_##cname (value x, value y, value z, value w) \
{ cname (Double_val(x), Double_val(y), Double_val(z), Double_val(w)); \
  return Val_unit; }

#define ML_enum(cname) \
value ml_##cname (value tag) \
{ cname (ml_glTag(tag)); return Val_unit; }

#define ML_bool(cname) \
value ml_##cname (value bool) \
{ if (bool == Val_int(0)) cname(GL_FALSE); \
  else cname(GL_TRUE); \
  return Val_unit; }

#endif
