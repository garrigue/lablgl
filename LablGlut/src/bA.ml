open Bigarray

let i32toi = Int32.to_int

let init1 m f kind = 
    let ba = Array1.create kind c_layout m in
    for i = 0 to m-1 do ba.{i} <- f i done;
    ba

let init2 m n f kind = 
    let ba = Array2.create kind c_layout m n in
    for i = 0 to m-1 do 
        for j = 0 to n-1 do 
            ba.{i,j} <- f i j
        done
    done;
    ba

let init3 m n p f kind = 
    let ba = Array3.create kind c_layout m n p in
    for i = 0 to m-1 do 
        for j = 0 to n-1 do 
            for k = 0 to p-1 do
                ba.{i,j,k} <- f i j k
            done
        done
    done;
    ba

(* map a big array to an array, using a function *)
let amap1 f ba =
    let m = Array1.dim ba in
    Array.init m (fun i -> f ba.{i}) 

let amap2 f ba =
    let m = Array2.dim1 ba in
    let n = Array2.dim2 ba in
    Array.init m (fun i -> Array.init n (fun j -> f ba.{i,j}))

let amap3 f ba = 
    let m = Array3.dim1 ba in
    let n = Array3.dim2 ba in
    let p = Array3.dim3 ba in
    Array.init m 
        (fun i -> Array.init n (fun j -> Array.init p (fun k -> f ba.{i,j,k})))

let amap = amap1

let iter1 f ba =
    let m = Array1.dim ba in
    for i = 0 to m-1 do 
        f i 
    done

let iter2 f ba =
    let m = Array2.dim1 ba in
    let n = Array2.dim2 ba in
    for i = 0 to m-1 do 
        for j = 0 to n-1 do
            f i j
        done
    done

let iter3 f ba =
    let m = Array3.dim1 ba in
    let n = Array3.dim2 ba in
    let p = Array3.dim3 ba in
    for i = 0 to m-1 do 
        for j = 0 to n-1 do
            for k = 0 to p-1 do
                f i j k
            done
        done
    done

let iter = iter1

let float_ba_make n = Array1.create float32 c_layout n
let float_ba1_make = float_ba_make
let float_ba2_make m n = Array2.create float32 c_layout m n
let float_ba3_make m n p = Array3.create float32 c_layout m n p
let float_ba_of_int_ba ia = 
    init1 (Array1.dim ia) (fun i -> float ia.{i}) float32
let float_ba_of_array a = init1 (Array.length a) (fun i -> a.(i)) float32

let int_ba_make n = Array1.create int c_layout n
let int_ba1_make = int_ba_make
let int_ba2_make m n = Array2.create int32 c_layout m n
let int_ba3_make m n p = Array3.create int32 c_layout m n p
let int_ba_of_int32_ba i32ba = 
    init1 (Array1.dim i32ba) (fun i -> Int32.to_int i32ba.{i}) int
let int_ba_of_array a = init1 (Array.length a) (fun i -> a.(i)) int

let ubyte_ba_make n = Array1.create int8_unsigned c_layout n
let ubyte_ba1_make = ubyte_ba_make
let ubyte_ba2_make m n = Array2.create int8_unsigned c_layout m n
let ubyte_ba3_make m n p = Array3.create int8_unsigned c_layout m n p

let int32_ba_make n = Array1.create int32 c_layout n
let int32_ba_of_int_array a = init1 (Array.length a) (fun i -> a.(i)) int32
let int_array_of_int32_ba ba = amap i32toi ba

let ubyte_ba_make n = Array1.create int8_unsigned c_layout n

let float_ba_of_array2 m = 
    init2 (Array.length m) (Array.length m.(0)) (fun i j -> m.(i).(j)) float32
                                                                                  
let int32_ba_of_array2 m =
    init2 (Array.length m) (Array.length m.(0)) (fun i j -> m.(i).(j)) int32

let ubyte_ba_of_array2 m = 
    init2 (Array.length m) (Array.length m.(0)) (fun i j -> m.(i).(j))
        int8_unsigned

let float_ba_of_array3 a =
    init3 (Array.length a) (Array.length a.(0)) (Array.length a.(0).(0))
        (fun i j k -> a.(i).(j).(k)) float32

let make_luminance_image w h = 
    Array3.create int8_unsigned c_layout h w 1

let make_rgb_image w h = 
    Array3.create int8_unsigned c_layout h w 3

let make_rgba_image w h = 
    Array3.create int8_unsigned c_layout h w 4

let flatten_ba2 ba =
    let n1 = Array2.dim1 ba in
    let n2 = Array2.dim2 ba in
    reshape_1 (genarray_of_array2 ba) (n1 * n2)

let flatten_ba3 ba =
    let n1 = Array3.dim1 ba in
    let n2 = Array3.dim2 ba in
    let n3 = Array3.dim3 ba in
    reshape_1 (genarray_of_array3 ba) (n1 * n2 * n3)

let flatten_image = flatten_ba3

