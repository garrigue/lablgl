/* $Id: ml_gl.h,v 1.15 1998-01-23 13:30:20 garrigue Exp $ */

#ifndef _ml_gl_
#define _ml_gl_

#include "ml_raw.h"

void ml_raise_gl (const char *errmsg) Noreturn;

#define Float_val(dbl) ((GLfloat) Double_val(dbl))
#define Addr_val(addr) ((GLvoid *) addr)
#define Val_addr(addr) ((value) addr)
#define Type_raw(raw) (GLenum_val(Kind_raw(raw)))
#define Type_void_raw(raw) Type_raw(raw), Void_raw(raw)

#define ML_0(cname) \
value ml_##cname (value unit) \
{ cname (); return Val_unit; }
#define ML_1(cname, conv1) \
value ml_##cname (value arg1) \
{ cname (conv1(arg1)); return Val_unit; }
#define ML_2(cname, conv1, conv2) \
value ml_##cname (value arg1, value arg2) \
{ cname (conv1(arg1), conv2(arg2)); return Val_unit; }
#define ML_3(cname, conv1, conv2, conv3) \
value ml_##cname (value arg1, value arg2, value arg3) \
{ cname (conv1(arg1), conv2(arg2), conv3(arg3)); return Val_unit; }
#define ML_4(cname, conv1, conv2, conv3, conv4) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4) \
{ cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4)); \
  return Val_unit; }
#define ML_5(cname, conv1, conv2, conv3, conv4, conv5) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5) \
{ cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), conv5(arg5)); \
  return Val_unit; }
#define ML_6(cname, conv1, conv2, conv3, conv4, conv5, conv6) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5, \
		  value arg6) \
{ cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), conv5(arg5), \
	 conv6(arg6)); \
  return Val_unit; }
#define ML_7(cname, conv1, conv2, conv3, conv4, conv5, conv6, conv7) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5, \
		  value arg6, value arg7) \
{ cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), conv5(arg5), \
	 conv6(arg6), conv7(arg7)); \
  return Val_unit; }
#define ML_8(cname, conv1, conv2, conv3, conv4, conv5, conv6, conv7, conv8) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5, \
		  value arg6, value arg7, value arg8) \
{ cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), conv5(arg5), \
	 conv6(arg6), conv7(arg7), conv8(arg8)); \
  return Val_unit; }

#define ML_1_(cname, conv1, conv) \
value ml_##cname (value arg1) \
{ return conv (cname (conv1(arg1))); }
#define ML_2_(cname, conv1, conv2, conv) \
value ml_##cname (value arg1, value arg2) \
{ return conv (cname (conv1(arg1), conv2(arg2))); }
#define ML_3_(cname, conv1, conv2, conv3, conv) \
value ml_##cname (value arg1, value arg2, value arg3) \
{ return conv (cname (conv1(arg1), conv2(arg2), conv3(arg3))); }
#define ML_4_(cname, conv1, conv2, conv3, conv4, conv) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4) \
{ return conv (cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4))); }
#define ML_5_(cname, conv1, conv2, conv3, conv4, conv5, conv) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5) \
{ return conv (cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), \
		      conv5(arg5))); }
#define ML_6_(cname, conv1, conv2, conv3, conv4, conv5, conv6, conv) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5, \
		  value arg6) \
{ return conv (cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), \
		      conv5(arg5), conv6(arg6))); }
#define ML_7_(cname, conv1, conv2, conv3, conv4, conv5, conv6, conv7, conv) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5, \
		  value arg6, value arg7) \
{ return conv (cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), \
		      conv5(arg5), conv6(arg6), conv7(arg7))); }
#define ML_8_(cname, conv1, conv2, conv3, conv4, conv5, conv6, conv7, conv8, \
	     conv) \
value ml_##cname (value arg1, value arg2, value arg3, value arg4, value arg5, \
		  value arg6, value arg7, value arg8) \
{ return conv (cname (conv1(arg1), conv2(arg2), conv3(arg3), conv4(arg4), \
		      conv5(arg5), conv6(arg6), conv7(arg7), conv8(arg8))); }

/* Use with care: needs the argument index */
#define Ignore(x)
#define Split(x,f,g) f(x), g(x) Ignore
#define Split3(x,f,g,h) f(x), g(x), h(x) Ignore
#define Pair(x,f,g) f(Field(x,0)), g(Field(x,1)) Ignore
#define Triple(x,f,g,h) f(Field(x,0)), g(Field(x,1)), h(Field(x,2)) Ignore

#define ML_void(cname) \
value ml_##cname (value unit) \
{ cname (); return Val_unit; }

#define ML_string(cname) \
value ml_##cname (value s) \
{ cname (String_val(s)); return Val_unit; }

#define ML_GLenum(cname) \
value ml_##cname (value tag) \
{ cname (GLenum_val(tag)); return Val_unit; }
#define ML_GLenum_int(cname) \
value ml_##cname (value tag) \
{ return Val_int (cname (GLenum_val(tag))); }
#define ML_GLenum_string(cname) \
value ml_##cname (value tag) \
{ return copy_string (cname (GLenum_val(tag))); }
#define ML_GLenum2(cname) \
value ml_##cname (value tag1, value tag2) \
{ cname (GLenum_val(tag1), GLenum_val(tag2)); return Val_unit; }
#define ML_GLenum3(cname) \
value ml_##cname (value tag1, value tag2, value tag3) \
{ cname (GLenum_val(tag1), GLenum_val(tag2), GLenum_val(tag3)); \
  return Val_unit; }
#define ML_GLenum_float_(cname) \
value ml_##cname (value tag1, value x) \
{ cname (GLenum_val(tag1), Float_val(x)); return Val_unit; }
#define ML_GLenum_int2_(cname) \
value ml_##cname (value tag1, value i1, value i2) \
{ cname (GLenum_val(tag1), Int_val(i1), Int_val(i2)); return Val_unit; }
#define ML_GLenum_int4_(cname) \
value ml_##cname (value tag1, value i1, value i2, value i3, value i4) \
{ cname (GLenum_val(tag1), Int_val(i1), Int_val(i2), Int_val(i3), \
	 Int_val(i4)); return Val_unit; }

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
#define ML_float4(cname) \
value ml_##cname (value x, value y, value z, value w) \
{ cname (Float_val(x), Float_val(y), Float_val(z), Float_val(w)); \
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
#define ML_double3x2(cname) \
value ml_##cname (value *arg1, value *arg2, value *arg3) \
{ cname (Double_val(arg1[0]), Double_val(arg1[1]), Double_val(arg2[0]), \
	 Double_val(arg2[1]), Double_val(arg3[0]), Double_val(arg3[1])); \
  return Val_unit; }

#define ML_int_int(cname) \
value ml_##cname (value i) \
{ return Val_int (cname (Int_val(i))); }

#define ML_void_int(cname) \
value ml_##cname (value unit) \
{ return Val_int (cname ()); }

#define ML_void_addr(cname) \
value ml_##cname (value unit) \
{ return Val_addr (cname ()); }

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

#define ML_bc6(cname) \
value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5]); }

#define ML_bc7(cname) \
value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6]); }

#define ML_bc8(cname) \
value cname##_bc (value *argv, int argn) \
{ return cname(argv[0],argv[1],argv[2],argv[3],argv[4],argv[5],argv[6], \
	       argv[7]); }

#if !defined(GL_DOUBLE) && defined(GL_DOUBLE_EXT)
#define GL_DOUBLE GL_DOUBLE_EXT
#endif
#if !defined(GL_TEXTURE_PRIORITY) && defined(GL_TEXTURE_PRIORITY_EXT)
#define GL_TEXTURE_PRIORITY GL_TEXTURE_PRIORITY_EXT
#endif
#if !defined(GL_PROXY_TEXTURE_1D) && defined(GL_PROXY_TEXTURE_1D_EXT)
#define GL_PROXY_TEXTURE_1D GL_PROXY_TEXTURE_1D_EXT
#endif
#if !defined(GL_PROXY_TEXTURE_2D) && defined(GL_PROXY_TEXTURE_2D_EXT)
#define GL_PROXY_TEXTURE_2D GL_PROXY_TEXTURE_2D_EXT
#endif

#endif
