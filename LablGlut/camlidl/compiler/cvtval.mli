(***********************************************************************)
(*                                                                     *)
(*                              CamlIDL                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1999 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0                *)
(*                                                                     *)
(***********************************************************************)

(* $Id: cvtval.mli,v 1.1 2003-10-28 18:52:31 ijtrotts Exp $ *)

(* Conversion of values between ML and C *)

open Idltypes

val ml_to_c :
  out_channel -> bool -> Prefix.t -> idltype -> string -> string -> unit
val c_to_ml :
  out_channel -> Prefix.t -> idltype -> string -> string -> unit
val allocate_output_space :
  out_channel -> Prefix.t -> string -> idltype -> unit
