(* c2ml -- Partially convert a C-based GLUT/OpenGL demo to OCaml.
**
 * ijt notes:
 * - It would be a good idea to have preprocessing phase to include the needed
 *   OpenGL typedefs and a postprocessing phase to pipe everything through
 *   camlp4, tidying up the output.
**
** Project:	FrontC
** New File:	c2ml.ml
** Original File:	cprint.ml
** Version:	2.1e
** Date:	9.1.99
** Changes by:  Issac Trotts
** Author:	Hugues Cassé
**
**	1.0		2.22.99	Hugues Cassé	First version.
**	2.0		3.18.99	Hugues Cassé	Compatible with Frontc 2.1, use of CAML
**									pretty printer.
**	2.1		3.22.99	Hugues Cassé	More efficient custom pretty printer used.
**	2.1a	4.12.99	Hugues Cassé	Correctly handle:
**									char *m, *m, *p; m + (n - p)
**	2.1b	4.15.99	Hugues Cassé	x + (y + z) stays x + (y + z) for
**									keeping computation order.
**	2.1c	7.23.99	Hugues Cassé	Improvement of case and default display.
**	2.1d	8.25.99	Hugues Cassé	Rebuild escape sequences in string and
**									characters.
**	2.1e	9.1.99	Hugues Cassé	Fix, recognize and correctly display '\0'.
**      ??      10.20.03 Issac Trotts   Convert parse tree to OCaml
*)

open Cabs
let version = 
"c2ml 10.20.03 original code (rewrite.ml) by Hugues Cassé, changes by 
Issac Trotts" 

(*
** FrontC Pretty printer
*)
let out = ref stdout
let width = ref 80
let tab = ref 8
let max_indent = ref 60

let line = ref ""
let line_len = ref 0
let current = ref ""
let current_len = ref 0
let spaces = ref 0
let follow = ref 0
let roll = ref 0


let print_tab size =
	for i = 1 to size / 8 do
		output_char !out '\t'
	done;
	for i  = 1 to size mod 8 do
		output_char !out ' '
	done

let flush _ =
	if !line <> "" then begin
		print_tab (!spaces + !follow);
		output_string !out !line;
		line := "";
		line_len := 0
	end

let commit _ =
	if !current <> "" then begin
		if !line = "" then begin
			line := !current;
			line_len := !current_len
		end else begin
			line := (!line ^ " " ^ !current);
			line_len := !line_len + 1 + !current_len
		end;
		current := "";
		current_len := 0
	end

let new_line _ =
	commit ();
	if !line <> "" then begin
		flush ();
		output_char !out '\n'
	end;
	follow := 0

let force_new_line _ =
	commit ();
	flush ();
	output_char !out '\n';
	follow := 0

let indent _ =
	new_line ();
	spaces := !spaces + !tab;
	if !spaces >= !max_indent then begin
		spaces := !tab;
		roll := !roll + 1
	end
	
let unindent _ =
	new_line ();
	spaces := !spaces - !tab;
	if (!spaces <= 0) && (!roll > 0) then begin
		spaces := ((!max_indent - 1) / !tab) * !tab;
		roll := !roll - 1
	end
			
let space _ = commit ()

let print str =
	current := !current ^ str;
	current_len := !current_len + (String.length str);
	if (!spaces + !follow + !line_len + 1 + !current_len) > !width
	then begin
		if !line_len = 0 then commit ();
		flush ();
		output_char !out '\n';
		if !follow = 0 then follow := !tab
	end 

let fixme () = print "/* FIXME */";;

(*
** Useful primitives
*)

let print_with_seps sep nl fct lst =
	let _ = List.fold_left
		(fun com elt ->
			if com then begin
				print sep;
				if nl then new_line () else space ()
			end else ();
			fct elt;
			true)
		false
		lst in
	()
	
let print_commas = print_with_seps ",";;
let print_bars = print_with_seps "|";;
let print_semis = print_with_seps ";";;

let escape_string str =
	let lng = String.length str in
	let conv value = String.make 1 (Char.chr (value + 
			(if value < 10 then (Char.code '0') else (Char.code 'a' - 10)))) in
	let rec build idx =
		if idx >= lng then ""
		else
			let sub = String.sub str idx 1 in
			let res = match sub with
				"\n" -> "\\n"
				| "\"" -> "\\\""
				| "'" -> "\\'"
				| "\r" -> "\\r"
				| "\t" -> "\\t"
				| "\b" -> "\\b"
				| "\000" -> "\\0"
				| _ -> if sub = (Char.escaped (String.get sub 0))
					then sub
					else let code = Char.code (String.get sub 0) in
						"\\"
						^ (conv (code / 64))
						^ (conv ((code mod 64) / 8))
						^ (conv (code mod 8)) in
			res ^ (build (idx + 1)) in
	build 0	
	

(* 
** Base Type Printing
*)
let get_sign si = "";;
(*
	match si with
	NO_SIGN -> ""
	| SIGNED -> "signed "
	| UNSIGNED -> "unsigned "
        *)

let get_size siz = "";;
(*
	match siz with
	NO_SIZE -> ""
	| SHORT -> "short "
	| LONG -> "long "
	| LONG_LONG -> "long long "
*)

let rec print_base_type typ =
	match typ with
	NO_TYPE -> ()
	| VOID -> print "unit"
	| CHAR sign -> print "char"
	| INT (size, sign) -> print "int"
	| BITFIELD (sign, _) -> print "int"
	| FLOAT size -> print "float"
	| DOUBLE size -> print "float"
	| NAMED_TYPE id -> print id
	| ENUM (id, items) -> print_enum id items
	| STRUCT (id, flds) -> print_fields id flds ";"
	| UNION (id, flds) -> print_fields id flds "|"
	| PROTO (typ, _, _) -> print_base_type typ
	| OLD_PROTO (typ, _, _) -> print_base_type typ
	| PTR typ -> print_base_type typ
	| ARRAY (typ, _) -> print_base_type typ
	| CONST typ -> print_base_type typ
	| VOLATILE typ -> print_base_type typ
	
and print_fields id (flds : name_group list) (sep:string) =
	print id;
	if flds = []
		then ()
		else begin
			print " {";
			indent ();
			List.iter
				(fun fld -> print_name_group fld; print sep; new_line ())
				flds;
			unindent ();
			print "}"
		end

and print_enum id items =
	print ("type " ^ id ^ " = ");
	if items = []
		then ()
		else begin
			indent ();
			print_bars
				true
				(fun (id, exp) -> print id;
					if exp = NOTHING then ()
					else begin
						space ();
						print "= ";
						print_expression exp 1
					end)
				items;
			unindent ();
			print ";;";
		end


(*
** Declaration Printing 
*)
and get_base_type typ =
	match typ with
	PTR typ -> get_base_type typ
	| CONST typ -> get_base_type typ
	| VOLATILE typ -> get_base_type typ
	| ARRAY (typ, _) -> get_base_type typ
	| _ -> typ
	
and print_pointer typ =
	match typ with
	PTR typ -> print_pointer typ; print "(* pointer *)"
	| CONST typ -> print_pointer typ; print " (* const *) "
	| VOLATILE typ -> print_pointer typ; print " (* volatile *) "
	| ARRAY (typ, _) -> print_pointer typ
	| _ -> ()

and print_array typ =
	match typ with
	ARRAY (typ, dim) ->
		print_array typ; 
		print "[|";
		print_expression dim 0;
		print "|]"
	| _ -> ()

and print_type (fct : unit -> unit) (typ : base_type ) =
	let base = get_base_type typ in
	match base with
	BITFIELD (_, exp) -> fct (); print " : "; print_expression exp 1
	| PROTO (typ', pars, ell) ->
		print_type
			(fun _ ->
				if base <> typ then print "(";
				print_pointer typ;
				fct ();
				print_array typ;
				if base <> typ then print ")";
				print " ";
				print_params pars ell;
				print " ")
			typ'
	| OLD_PROTO (typ', pars, ell) ->
		print_type
			(fun _ ->
				if base <> typ then print "(";
				print_pointer typ;
				fct ();
				print_array typ;
				if base <> typ then print ")";
				print "(";
				print_old_params pars ell;
				print ")")
			typ'
	| _ -> print_pointer typ; fct (); print_array typ

and print_onlytype typ =
	print_base_type typ;
	print_type (fun _ -> ()) typ

and print_name ((id, typ, attr, exp) : name) =
	print_type (fun _ -> print id) typ;
	print_attributes attr;
	if exp <> NOTHING then begin
		space ();
		print "= ";
		print_expression exp 1
	end else ()

and get_storage sto =
	match sto with
	NO_STORAGE -> ""
	| AUTO -> "(* auto *)"
	| STATIC -> "(* static *)"
	| EXTERN -> "(* extern *)"
	| REGISTER -> "(* register *)"

and print_name_group (typ, sto, names) =
	if sto <> NO_STORAGE then begin
		print (get_storage sto);
		space ()
	end;
	print_base_type typ;
	space ();
	print_commas false print_name names

and print_single_name (typ, sto, name) =
	if sto <> NO_STORAGE then begin
		print (get_storage sto);
		space ()
	end;
	print_base_type typ;
	space ();
	print_name name

and print_params (pars : single_name list) (ell : bool) =
	print_with_seps " " false print_single_name pars;
	if ell then print (if pars = [] then "..." else ", ...") else ()

and print_old_params pars ell =
	print_with_seps " " false (fun id -> print id) pars;
	if ell then print (if pars = [] then "..." else ", ...") else ()


(*
** Expression printing
**		Priorities
**		16	varaibles
**		15	. -> [] call()
**		14  ++, -- (post)
**		13	++ -- (pre) ~ ! - + & *(cast)
**		12	* / %
**		11	+ -
**		10	<< >>
**		9	< <= > >=
**		8	== !=
**		7	&
**		6	^
**		5	|
**		4	&&
**		3	||
**		2	? :
**		1	= ?=
**		0	,				
*)
and get_operator exp =
	match exp with
	NOTHING -> ("", 16)
	| UNARY (op, _) ->
		(match op with
		MINUS -> ("-", 13)
		| PLUS -> ("+", 13)
		| NOT -> (" not ", 13)
		| BNOT -> (" lnot ", 13)
		| MEMOF -> ("*", 13)
		| ADDROF -> ("(* & *)", 13)
		| PREINCR -> ("++", 13)
		| PREDECR -> ("--", 13)
		| POSINCR -> ("++", 14)
		| POSDECR -> ("--", 14))
	| BINARY (op, _, _) ->
		(match op with
		  MUL -> ("*.", 12)
		| DIV -> ("/.", 12)
		| MOD -> (" mod ", 12)
		| ADD -> ("+.", 11)
		| SUB -> ("-.", 11)
		| SHL -> (" lsl ", 10)
		| SHR -> (" lsr ", 10)
		| LT -> ("<", 9)
		| LE -> ("<=", 9)
		| GT -> (">", 9)
		| GE -> (">=", 9)
		| EQ -> ("=", 8)
		| NE -> ("<>", 8)
		| BAND -> (" land ", 7)
		| XOR -> (" lxor ", 6)
		| BOR -> (" lor ", 5)
		| AND -> ("&&", 4)
		| OR -> ("||", 3)
		| ASSIGN -> ("=", 1)
		| ADD_ASSIGN -> ("+=", 1)
		| SUB_ASSIGN -> ("-=", 1)
		| MUL_ASSIGN -> ("*=", 1)
		| DIV_ASSIGN -> ("/=", 1)
		| MOD_ASSIGN -> ("%=", 1)
		| BAND_ASSIGN -> ("&=", 1)
		| BOR_ASSIGN -> ("|=", 1)
		| XOR_ASSIGN -> ("^=", 1)
		| SHL_ASSIGN -> ("<<=", 1)
		| SHR_ASSIGN -> (">>=", 1))
	| QUESTION _ -> ("", 2)
	| CAST _ -> ("", 13)
	| CALL _ -> ("", 15)
	| COMMA _ -> ("", 0)
	| CONSTANT _ -> ("", 16)
	| VARIABLE name -> ("", 16)
	| EXPR_SIZEOF exp -> ("", 16)
	| TYPE_SIZEOF typ -> ("", 16)
	| INDEX (exp, idx) -> ("", 15)
	| MEMBEROF (exp, fld) -> ("", 15)
	| MEMBEROFPTR (exp, fld) -> ("", 15)
	| GNU_BODY _ -> ("", 17)

and print_comma_exps exps =
	print_semis false (fun exp -> print_expression exp 1) exps

and print_space_exps exps using_parens =
    if using_parens then
        List.iter
            (fun elt -> 
                print "(";
                print_expression elt 1;
                print ") ")
        exps
    else
	print_with_seps " " false (fun exp -> print_expression exp 1) exps
 
and print_expression (exp : expression) (lvl : int) =
	let (txt, lvl') = get_operator exp in
	let _ = if lvl > lvl' then print "(" else () in
	let _ = match exp with
		NOTHING -> ()
		| UNARY (op, exp') ->
				(match op with
				POSINCR | POSDECR ->
					print_expression exp' lvl';
					print txt
				| _ ->
					print txt;
					print_expression exp' lvl')
		| BINARY (op, exp1, exp2) ->
			(*if (op = SUB) && (lvl <= lvl') then print "(";*)
			print_expression exp1 lvl';
			space ();
			print txt;
			space ();
			(*print_expression exp2 (if op = SUB then (lvl' + 1) else lvl');*)
			print_expression exp2 (lvl' + 1)
			(*if (op = SUB) && (lvl <= lvl') then print ")"*)
		| QUESTION (exp1, exp2, exp3) ->
                        print "if ";
			print_expression exp1 2;
			space ();
			print "then ";
			print_expression exp2 2;
			space ();
			print "else ";
			print_expression exp3 2;
		| CAST (typ, exp) ->
			print "(";
			print_onlytype typ;
			print ")";
			print_expression exp 15
		| CALL (exp, args) ->
			print_expression exp 16;
                        (match args with 
                          [] -> print "()";
                        | _ -> 
                            print " ";
                            print_space_exps args true)
			(* print " " *)
		| COMMA exps ->
			print_comma_exps exps
		| CONSTANT cst ->
				(match cst with
					CONST_INT i -> print i
					| CONST_FLOAT r -> print r
					| CONST_CHAR c -> print ("'" ^ (escape_string c) ^ "'")
					| CONST_STRING s -> print ("\"" ^ (escape_string s) ^ "\"")
					| CONST_COMPOUND exps ->
						print "[| ";
						print_comma_exps exps;
						print " |]")
		| VARIABLE name ->
                        let mysub str a b = 
                            try String.sub str a b with _ -> ""
                        in
                        print (
                            if mysub name 0 3 = "GL_" ||
                               mysub name 0 4 = "GLU_" ||
                               mysub name 0 5 = "GLUT_" 
                            then
                                String.lowercase name
                            else if name = "NULL" then 
                                "None"
                            else
                                name
                            )
		| EXPR_SIZEOF exp ->
			print "sizeof(";
			print_expression exp 0;
			print ")"
		| TYPE_SIZEOF typ ->
			print "sizeof(";
			print_onlytype typ;
			print ")"
		| INDEX (exp, idx) ->
			print_expression exp 16;
			print ".(";
			print_expression idx 0;
			print ")"
		| MEMBEROF (exp, fld) ->
			print_expression exp 16;
			print ("." ^ fld)
		| MEMBEROFPTR (exp, fld) ->
			print_expression exp 16;
			print ("." ^ fld)
		| GNU_BODY (decs, stat) ->
			print "(";
			print_statement (BLOCK (decs, stat));
			print ")" in
	if lvl > lvl' then print ")" else ()


(*
** Statement printing
*)
and print_statement stat =
	match stat with
	NOP ->
		print ";";
		new_line ()
	| COMPUTATION exp ->
		print_expression exp 0;
		print ";";
		new_line ()
	| BLOCK (defs, stat) ->
		new_line ();
		print "(";
		indent ();
		print_defs defs;
		if stat <> NOP then print_statement stat else ();
		unindent ();
		print ");";
		new_line ();
	| SEQUENCE (s1, s2) ->
		print_statement s1;
		print_statement s2;
	| IF (exp, s1, s2) ->
		print "if ";
		print_expression exp 0;
		print " then ";
		print_substatement s1;
		if s2 = NOP
			then ()
			else begin
				print " else ";
				print_substatement s2;
			end
	| WHILE (exp, stat) ->
		print "while ";
		print_expression exp 0;
		print " do ";
		print_substatement stat;
		print "done;";
                new_line();
	| DOWHILE (exp, stat) ->
                print "let dowhile_aux () ="; 
		print_substatement stat;
                print "in";
                print "dowhile_aux();";
                print "while ";
		print_expression exp 0;
                print "do dowhile_aux() done;";
		new_line ();
	| FOR (exp1, exp2, exp3, stat) ->
		print "for ";
		print_expression exp1 0;
		print ";";
		space ();
		print_expression exp2 0;
		print ";";
		space ();
		print_expression exp3 0;
		print " do ";
		print_substatement stat;
		print "done;";
                new_line();
	| BREAK ->
		print "(* break; *)"; new_line ()
	| CONTINUE ->
		print "continue;"; new_line ()
	| RETURN exp ->
		print "(* return *)";
		if exp = NOTHING
			then ()
			else begin
				print " ";
				print_expression exp 1
			end;
		print ";";
		new_line ()
	| SWITCH (exp, stat) ->
		print "match ";
		print_expression exp 0;
		print " with ";
		print_substatement stat
	| CASE (exp, stat) ->
		unindent ();
		print "| ";
		print_expression exp 1;
		print " -> ";
		indent ();
		print_substatement stat
	| DEFAULT stat ->
		unindent ();
		print "| _ -> ";
		indent ();
		print_substatement stat
	| LABEL (name, stat) ->
		print (name ^ ":");
		space ();
		print_substatement stat
	| GOTO name ->
		print ("goto " ^ name ^ ";");
		new_line ()

and print_substatement stat =
	match stat with
	IF _
	| SEQUENCE _
	| DOWHILE _ ->
		new_line ();
		print "(";
		indent ();
		print_statement stat;
		unindent ();
		print ");";
		new_line ();
	| BLOCK _ ->
		print_statement stat
	| _ ->
		indent ();
		print_statement stat;
		unindent ()


(*
** GCC Attributes
*)
and print_attributes attrs =
	List.iter
		(fun attr ->
			space ();
			print "__attribute__ ";
			print_attribute attr)
		attrs

and print_attribute attr = ()
(*
	match attr with
	NO_ATTR -> ()
	| ATTR_LIST lst ->
		print "(";
		print_commas false print_attribute lst;
		print ")"
	| ATTR_ID id -> print id
*)


(*
** Declaration printing
*)
and print_defs defs =
	let prev = ref false in
	List.iter
		(fun def ->
			(match def with
			DECDEF _ -> prev := false
			| _ ->
				if not !prev then force_new_line ();
				prev := true);
			print_def def)
		defs

and id_of_single_name sname = 
    let (_, _, name) = sname in
    let (str,_,_,_) = name in
    str

and print_def def =
	match def with
	
	FUNDEF (proto, body) ->
                let (typ,sto,name) = proto in
                let (id, typ, attr, exp) = name in
                print ("let "^id^" ");
                (match typ with 
                  PROTO (return_type, arglist, _) -> 
                    let hd = List.hd arglist in
                    if id_of_single_name hd = "" then print "()" else
                        List.iter (*fixme (use print_with_seps or smth) *)
                            (fun arg -> 
                                print (id_of_single_name arg);
                                print " "; 
                            )
                            arglist;
                | _ -> failwith "Bad function type.");
                print " = ";
		let (decs, stat) = body in print_statement (BLOCK (decs, stat));
                print ";;";
		force_new_line ();
		
	| OLDFUNDEF (proto, decs, body) ->
		print_single_name proto;
		force_new_line ();
		List.iter
			(fun dec -> print_name_group dec; print ";"; new_line ())
			decs;
		let (decs, stat) = body in print_statement (BLOCK (decs, stat));
		force_new_line ();
		
	| DECDEF names ->
                let get_varname (varname,_,_,_) = varname in
                let get_expr (_,_,_,expr) = expr in
                let (typ, sto, names2) = names in
                if List.length names2 = 1 then 
                    let name2 = List.hd names2 in
                    print ("let "^(get_varname name2)^" = ");
                    print_expression (get_expr name2) 1;
                else 
                    print_name_group names; (* punt *)
		print " in";
		new_line ()
			
	| TYPEDEF names ->
                (* type newname = oldname; *)
		print "type ";
                let typ, sto, names2 = names in
                print_commas false print_name names2;
                space ();
                print "=";
                space ();
                print_base_type typ;
		print ";";
		new_line ();
		force_new_line ()

	| ONLYTYPEDEF names ->
		print_name_group names;
		print ";";
		new_line ();
		force_new_line ()
		

(*  print abstrac_syntax -> ()
**		Pretty printing the given abstract syntax program.
*)
let print (result : out_channel) (defs : file) =
	out := result;
	print_defs defs

let set_tab t = tab := t
let set_width w = width := w








(* Useful Data *)
(* let version = "Rewrite V2.0 3.22.99 Hugues Cassé" *)
let version = "C2ml V1.0 10.20.03, adapted by Issac Trotts from 
    Hugues Casse's original program Rewrite."
let help = version ^ "\n"
	^ "rewrite [-V] [-P] [-t tab] [-w width] [-p preprocessor] <file list> [-o <output file>]"


(* Output management *)
let out = ref stdout
let close_me = ref false

let close_output _ =
	flush !out;
	if !close_me then close_out !out else ();
	close_me := false
let set_output filename =
	close_output ();
	(try out := open_out filename (*; prerr_string (filename ^ " opened\n.")*)
	with (Sys_error msg) ->
		output_string stderr ("Error while opening output: " ^ msg); exit 1);
	close_me := true
	

(* File Management *)
let files = ref []

let add_file filename =
	files := List.append !files [filename]

let print_top_comments filename = 
    let file = open_in filename in 
    let is_space c = c = ' ' || c = '\t' || c = '\n' || c = '\r' in
    let rec skip_space() =
        let c = input_char file in 
        if is_space c then skip_space() else c
    in
    let rec eat_comments() = 
        let c = skip_space() in
        let d = input_char file in 
        if c = '/' && d = '/' then (    (* // style *)
            print_string "(*";
            let rec munch_more () = 
                let c = input_char file in 
                if c = '\r' || c = '\n' then 
                    () (* stop *)
                else (
                    print_char c;
                    munch_more()
                )
            in
            munch_more();
            print_string " *)";
        )
        else if c = '/' && d = '*' then (  (* /* blah blah */ style *)
            print_string "(*";
            let rec eat_rest_of_comment () = 
                let c = input_char file in
                if c = '*' then 
                    let d = input_char file in
                    if d = '/' then 
                        () (* this comment is done *)
                    else (
                        print_char c;
                        print_char d;
                        eat_rest_of_comment()
                    );
                else (
                    print_char c;
                    eat_rest_of_comment()
                )
            in
            eat_rest_of_comment();
            print_string "*)\n";
            eat_comments();
        )
        else
            () (* stop *)
    in
    (try eat_comments() with _ -> ());
    close_in file;;

(*
** Argument definition
*)
let preproc = ref ""
let verbose = ref false
let arg_def =
[
	"-V", Arg.Unit (fun _ -> print_endline help), "Informations";
	"-v", Arg.Set verbose, "Verbose mode";
	"-o", Arg.String set_output, "Output file";
	"-t", Arg.Int set_tab, "Identation step";
	"-w", Arg.Int set_width, "Page width";
	"-p", Arg.String (fun id -> preproc := id), "Preprocessor command.";
	"-P", Arg.Unit (fun _ -> preproc := "gcc -E %i -o %o"), "Use \"gcc -E %i -o %o\" as preprocessor.";
        "-topcomments", 
            Arg.String (fun filename -> print_top_comments filename), 
            "Print the comments at the beginning of the C file."
]


(* Starter *)
exception PreprocessingError
let preprocess inname outname =
	let rec replace str =
		try let idx = String.index str '%' in
			(if idx > 0 then String.sub str 0 idx else "")
			^ (match String.get str (idx + 1) with
				'i' -> inname
				| 'o' -> outname
				| '%' -> "%"
				| _ -> "")
			^ (if (idx + 2) >= (String.length str)
				then ""
				else replace
					(String.sub str (idx + 2) ((String.length str) - idx - 2))) 
		with Not_found -> str in
	let com = replace !preproc in
	let _ = if !verbose
		then prerr_string ("Executing \"" ^ com ^ "\"\n")
		else () in
	if (Sys.command com) = 0 
		then ()
		else raise PreprocessingError
	
let process filename =
        print_string "
open Lablglut
open Printf
open Bigarray
        ";
        let parse file =
                let _ = if !verbose then prerr_string "Parsing...\n" else () in
                Frontc.parse_file file stderr in
        let _ = if !verbose
                then prerr_string ("Processing " ^ filename ^ "...\n")
                else () in
        match (
                if !preproc = ""
                then parse filename
                else
                        let tmp = Filename.temp_file "rewrite" ".i" in
                        try
                                preprocess filename tmp;
                                let res = parse tmp in
                                Sys.remove tmp;
                                res
                        with PreprocessingError ->
                                begin
                                        prerr_string
                                                ("Error while preprocessing " ^ filename ^ "\n");
                                        Frontc.PARSING_ERROR
                                end) with
        Frontc.PARSING_ERROR -> ()
        | Frontc.PARSING_OK defs ->
                output_string !out ("(* Generated by " ^ version ^ " *)\n");
                if !verbose then prerr_string "Rewriting...\n";
                print !out defs

let rec process_files files =
	List.iter process files

let _ =
	Arg.parse arg_def add_file help;
	process_files !files;
	close_output ()
