/* $Id: ml_gl.h,v 1.9 1998-01-13 11:07:15 garrigue Exp $ */

#ifndef _ml_gl_
#define _ml_gl_

void ml_raise_gl (char *errmsg) Noreturn;

#define Float_val(dbl) ((float) Double_val(dbl))
#define Addr_val(addr) ((void *) Field(addr,0))

#define ML_void(cname) \
value ml_##cname (value unit) \
{ cname (); return Val_unit; }

#define ML_string(cname) \
value ml_##cname (value s) \
{ cname (String_val(s)); return Val_unit; }

#define ML_GLenum(cname) \
value ml_##cname (value tag) \
{ cname (GLenum_val(tag)); return Val_unit; }
#define ML_GLenum2(cname) \
value ml_##cname (value tag1, value tag2) \
{ cname (GLenum_val(tag1), GLenum_val(tag2)); return Val_unit; }

#define ML_TKenum(cname) \
value ml_##cname (value tag) \
{ cname (TKenum_val(tag)); return Val_unit; }

#define ML_int(cname) \
value ml_##cname (value dbl) \
{ cname (Int_val(dbl)); return Val_unit; }
#define ML_int2(cname) \
value ml_##cname (value x, value y) \
{ cname (Int_val(x), Int_val(y)); return Val_unit; }
#define ML_int3(cname) \
value ml_##cname (value x, value y, value z) \
{ cname (Int_val(x), Int_val(y), Int_val(z)); \
  return Val_unit; }
#define ML_int4(cname) \
value ml_##cname (value x, value y, value z, value w) \
{ cname (Int_val(x), Int_val(y), Int_val(z), Int_val(w)); \
  return Val_unit; }

#define ML_float(cname) \
value ml_##cname (value dbl) \
{ cname (Float_val(dbl)); return Val_unit; }
#define ML_float2(cname) \
value ml_##cname (value x, value y) \
{ cname (Float_val(x), Float_val(y)); return Val_unit; }
#define ML_float3(cname) \
value ml_##cname (value x, value y, value z) \
{ cname (Float_val(x), Float_val(y), Float_val(z)); \
  return Val_unit; }

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
#define ML_double6(cname) \
value ml_##cname (value *argv, int argn) \
{ cname (Double_val(argv[0]), Double_val(argv[1]), Double_val(argv[2]), \
	 Double_val(argv[3]), Double_val(argv[4]), Double_val(argv[5])); \
  return Val_unit; }

#define ML_bool(cname) \
value ml_##cname (value bool) \
{ if (bool == Val_int(0)) cname(GL_FALSE); \
  else cname(GL_TRUE); \
  return Val_unit; }

#define ML_void_bool(cname) \
value ml_##cname (value unit) \
{ if (cname() == GL_TRUE) return Val_true; \
  else return Val_false; }

#define ML_int_bool(cname) \
value ml_##cname (value i) \
{ if (cname(Int_val(i)) == GL_TRUE) return Val_true; \
  else return Val_false; }

#define ML_string_bool(cname) \
value ml_##cname (value s) \
{ if (cname(String_val(s)) == GL_TRUE) return Val_true; \
  else return Val_false; }

#define ML_TKenum_bool(cname) \
value ml_##cname (value s) \
{ if (cname(TKenum_val(s)) == GL_TRUE) return Val_true; \
  else return Val_false; }

#define ML_void_int(cname) \
value ml_##cname (value unit) \
{ return Val_int (cname ()); }

#define ML_void_addr(cname) \
value ml_##cname (value unit) \
{ return Val_addr (cname ()); }

#define ML_int_int(cname) \
value ml_##cname (value i) \
{ return Val_int (cname (Int_val (i))); }

#define ML_addr(cname) \
value ml_##cname (void *addr) \
{ cname (Addr_val(addr)); return Val_unit; }

#define ML_addr_string(cname) \
value ml_##cname (void *addr) \
{ return copy_string (cname (Addr_val(addr))); }

#define ML_addr_int(cname) \
value ml_##cname (void *addr) \
{ return Val_int (cname (Addr_val(addr))); }

#define ML_addr_int_(cname) \
value ml_##cname (value addr, value n) \
{ cname (Addr_val(addr), Int_val(n)); return Val_unit; }

#define ML_addr_TOGLenum_(cname) \
value ml_##cname (value addr, value tag) \
{ cname (Addr_val(addr), TOGLenum_val(tag)); return Val_unit; }

#endif
