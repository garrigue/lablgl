/* $Id: ml_raw.h,v 1.2 1998-01-21 09:12:37 garrigue Exp $ */

#ifndef _ml_raw_
#define _ml_raw_

#define Kind_raw(raw) (Field(raw,0))
#define Size_raw(raw) (Field(raw,1))
#define Addr_raw(raw) (Field(raw,2))
#define Static_raw(raw) (Field(raw,3))

#define Void_raw(raw) ((void *) Addr_raw(raw))
#define Byte_raw(raw) ((char *) Addr_raw(raw))
#define Short_raw(raw) ((short *) Addr_raw(raw))
#define Int_raw(raw) ((int *) Addr_raw(raw))
#define Long_raw(raw) ((long *) Addr_raw(raw))
#define Float_raw(raw) ((float *) Addr_raw(raw))
#define Double_raw(raw) ((double *) Addr_raw(raw))

#endif
