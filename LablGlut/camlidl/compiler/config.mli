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

(* $Id: config.mli,v 1.1 2003-10-28 18:52:30 ijtrotts Exp $ *)

(* Compile-time configuration *)

(* How to invoke the C preprocessor *)
val cpp: string

(* The C names for 64-bit signed and unsigned integers *)
val int64_type: string
val uint64_type: string
