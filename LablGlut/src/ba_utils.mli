val float_ba_make :
  int -> (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t
val int_ba_make :
  int -> (int, Bigarray.int_elt, Bigarray.c_layout) Bigarray.Array1.t
val ubyte_ba_make :
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
val float_ba_of_array :
  float array ->
  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t
val int_ba_of_array :
  int array -> (int, Bigarray.int_elt, Bigarray.c_layout) Bigarray.Array1.t
val float_ba_of_array2 :
  float array array ->
  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array2.t
val int_ba_of_array2 :
  int array array ->
  (int, Bigarray.int_elt, Bigarray.c_layout) Bigarray.Array2.t
val ubyte_ba_of_array2 :
  int array array ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array2.t
val float_ba_of_array3 :
  float array array array ->
  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array3.t
val make_luminance_image :
  int ->
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array3.t
val make_rgb_image :
  int ->
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array3.t
val make_rgba_image :
  int ->
  int ->
  (int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array3.t
val flatten_ba2 :
  ('a, 'b, 'c) Bigarray.Array2.t -> ('a, 'b, 'c) Bigarray.Array1.t
val flatten_ba3 :
  ('a, 'b, 'c) Bigarray.Array3.t -> ('a, 'b, 'c) Bigarray.Array1.t
val flatten_image :
  ('a, 'b, 'c) Bigarray.Array3.t -> ('a, 'b, 'c) Bigarray.Array1.t
