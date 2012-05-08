
/* convenient macro to allocate double fields in tuples */
#define Store_tuple_double_val(t,i,d)			\
  do {							\
    Field(t,i) = caml_alloc(Double_wosize, Double_tag);	\
    Store_double_val(Field(t,i),d);			\
  } while(0)


/* 1 parameter setter, with constant pname */

#define SET_1_ENUM(cname,pname,conv1)					\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    GLenum p = GLenum_val(arg2);					\
    gl##cname(conv1(arg1),GL_##pname,&p);				\
    return Val_unit;							\
  }


#define SET_1_INT(cname,pname,conv1)					\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    GLint p = Int_val(arg2);						\
    gl##cname(conv1(arg1),GL_##pname,&p);				\
    return Val_unit;							\
  }

#define SET_1_4F(cname,pname,conv1)					\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    float p[4];								\
    int i;								\
    for (i = 0; i < 4; i++) p[i] = Double_val(Field(arg2,i));		\
    gl##cname(conv1(arg1),GL_##pname,p);				\
    return Val_unit;							\
  }

/* 2 parameters setter, with constant pname */

#define SET_2_ENUM(cname,pname,conv1,conv2)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2,	\
				     value arg3) {		\
    GLenum p = GLenum_val(arg3);				\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,&p);		\
    return Val_unit;						\
  }

#define SET_2_INT(cname,pname,conv1,conv2)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2,	\
				    value arg3) {		\
    GLint p = Int_val(arg3);					\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,&p);		\
    return Val_unit;						\
  }

#define SET_2_4F(cname,pname,conv1,conv2)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2,	\
				   value arg3) {		\
    float p[4];							\
    int i;							\
    for (i = 0; i < 4; i++) p[i] = Double_val(Field(arg3,i));	\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,p);		\
    return Val_unit;						\
  }



/* zero parameter getters, with constant pname */

#define GET_UNIT_ENUM(cname,pname)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    GLint p;						\
    gl##cname(GL_##pname,&p);				\
    return Val_GLenum((GLenum)p);			\
  }

#define GET_UNIT_4F(cname,pname)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    float p[4];						\
    value ret = caml_alloc_tuple(4);			\
    gl##cname(GL_##pname,p);				\
    Store_tuple_double_val(ret,0,p[0]);			\
    Store_tuple_double_val(ret,1,p[1]);			\
    Store_tuple_double_val(ret,2,p[2]);			\
    Store_tuple_double_val(ret,3,p[3]);			\
    return ret;						\
  }

#define GET_UNIT_3F(cname,pname)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    float p[3];						\
    value ret = caml_alloc_tuple(3);			\
    gl##cname(GL_##pname,p);				\
    ret = caml_alloc_tuple(3);				\
    Store_tuple_double_val(ret,0,p[0]);			\
    Store_tuple_double_val(ret,1,p[1]);			\
    Store_tuple_double_val(ret,2,p[2]);			\
    return ret;						\
  }

#define GET_UNIT_F(cname,pname)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    float p;						\
    value ret = caml_alloc(Double_wosize,Double_tag);	\
    gl##cname(GL_##pname,&p);				\
    Store_double_val(ret,(double)p);			\
    return ret;						\
  }

#define GET_UNIT_B(cname,pname)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    GLboolean b;					\
    gl##cname(GL_##pname,&b);				\
    return Val_bool(b);					\
  }


/* 1 parameter getter, with constant pname */

#define GET_1_ENUM(cname,pname,conv1)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    GLint p;						\
    gl##cname(conv1(arg1),GL_##pname,&p);		\
    return Val_GLenum((GLenum)p);			\
  }

#define GET_1_4F(cname,pname,conv1)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    float p[4];						\
    value ret = caml_alloc_tuple(4);			\
    gl##cname(conv1(arg1),GL_##pname,p);		\
    Store_tuple_double_val(ret,0,p[0]);			\
    Store_tuple_double_val(ret,1,p[1]);			\
    Store_tuple_double_val(ret,2,p[2]);			\
    Store_tuple_double_val(ret,3,p[3]);			\
    return ret;						\
  }

#define GET_1_3F(cname,pname,conv1)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    float p[3];						\
    value ret = caml_alloc_tuple(3);			\
    gl##cname(conv1(arg1),GL_##pname,p);		\
    ret = caml_alloc_tuple(3);				\
    Store_tuple_double_val(ret,0,p[0]);			\
    Store_tuple_double_val(ret,1,p[1]);			\
    Store_tuple_double_val(ret,2,p[2]);			\
    return ret;						\
  }

#define GET_1_F(cname,pname,conv1)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    float p;						\
    value ret = caml_alloc(Double_wosize,Double_tag);	\
    gl##cname(conv1(arg1),GL_##pname,&p);		\
    Store_double_val(ret,(double)p);			\
    return ret;						\
  }

#define GET_1_B(cname,pname,conv1)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    GLboolean b;					\
    gl##cname(conv1(arg1),GL_##pname,&b);		\
    return Val_bool(b);					\
  }

#define GET_1_I(cname,pname,conv1)			\
  CAMLprim value ml_gl##cname##_##pname(value arg1) {	\
    GLint i;						\
    gl##cname(conv1(arg1),GL_##pname,&i);		\
    return Val_int(i);					\
  }


/* 2 parameters getter, with constant pname */

#define GET_2_ENUM(cname,pname,conv1,conv2)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    GLint p;								\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,&p);			\
    return Val_GLenum((GLenum)p);					\
  }

#define GET_2_4F(cname,pname,conv1,conv2)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    float p[4];								\
    value ret = caml_alloc_tuple(4);					\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,p);			\
    Store_tuple_double_val(ret,0,p[0]);					\
    Store_tuple_double_val(ret,1,p[1]);					\
    Store_tuple_double_val(ret,2,p[2]);					\
    Store_tuple_double_val(ret,3,p[3]);					\
    return ret;								\
  }

#define GET_2_3F(cname,pname,conv1,conv2)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    float p[3];								\
    value ret = caml_alloc_tuple(3);					\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,p);			\
    ret = caml_alloc_tuple(3);						\
    Store_tuple_double_val(ret,0,p[0]);					\
    Store_tuple_double_val(ret,1,p[1]);					\
    Store_tuple_double_val(ret,2,p[2]);					\
    return ret;								\
  }

#define GET_2_F(cname,pname,conv1,conv2)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    float p;								\
    value ret = caml_alloc(Double_wosize,Double_tag);			\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,&p);			\
    Store_double_val(ret,(double)p);					\
    return ret;								\
  }

#define GET_2_B(cname,pname,conv1,conv2)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    GLboolean b;							\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,&b);			\
    return Val_bool(b);							\
  }

#define GET_2_I(cname,pname,conv1,conv2)				\
  CAMLprim value ml_gl##cname##_##pname(value arg1, value arg2) {	\
    GLint i;								\
    gl##cname(conv1(arg1),conv2(arg2),GL_##pname,&i);			\
    return Val_int(i);							\
  }
