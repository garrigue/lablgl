val version : string
type size = NO_SIZE | SHORT | LONG | LONG_LONG
and sign = NO_SIGN | SIGNED | UNSIGNED
and storage = NO_STORAGE | AUTO | STATIC | EXTERN | REGISTER
and base_type =
    NO_TYPE
  | VOID
  | CHAR of sign
  | INT of size * sign
  | BITFIELD of sign * expression
  | FLOAT of bool
  | DOUBLE of bool
  | PTR of base_type
  | ARRAY of base_type * expression
  | STRUCT of string * name_group list
  | UNION of string * name_group list
  | PROTO of proto
  | OLD_PROTO of old_proto
  | NAMED_TYPE of string
  | ENUM of string * enum_item list
  | CONST of base_type
  | VOLATILE of base_type
and name = string * base_type * attributes * expression
and name_group = base_type * storage * name list
and single_name = base_type * storage * name
and enum_item = string * expression
and proto = base_type * single_name list * bool
and old_proto = base_type * string list * bool
and definition =
    FUNDEF of single_name * body
  | OLDFUNDEF of single_name * name_group list * body
  | DECDEF of name_group
  | TYPEDEF of name_group
  | ONLYTYPEDEF of name_group
and file = definition list
and body = definition list * statement
and statement =
    NOP
  | COMPUTATION of expression
  | BLOCK of body
  | SEQUENCE of statement * statement
  | IF of expression * statement * statement
  | WHILE of expression * statement
  | DOWHILE of expression * statement
  | FOR of expression * expression * expression * statement
  | BREAK
  | CONTINUE
  | RETURN of expression
  | SWITCH of expression * statement
  | CASE of expression * statement
  | DEFAULT of statement
  | LABEL of string * statement
  | GOTO of string
and binary_operator =
    ADD
  | SUB
  | MUL
  | DIV
  | MOD
  | AND
  | OR
  | BAND
  | BOR
  | XOR
  | SHL
  | SHR
  | EQ
  | NE
  | LT
  | GT
  | LE
  | GE
  | ASSIGN
  | ADD_ASSIGN
  | SUB_ASSIGN
  | MUL_ASSIGN
  | DIV_ASSIGN
  | MOD_ASSIGN
  | BAND_ASSIGN
  | BOR_ASSIGN
  | XOR_ASSIGN
  | SHL_ASSIGN
  | SHR_ASSIGN
and unary_operator =
    MINUS
  | PLUS
  | NOT
  | BNOT
  | MEMOF
  | ADDROF
  | PREINCR
  | PREDECR
  | POSINCR
  | POSDECR
and expression =
    NOTHING
  | UNARY of unary_operator * expression
  | BINARY of binary_operator * expression * expression
  | QUESTION of expression * expression * expression
  | CAST of base_type * expression
  | CALL of expression * expression list
  | COMMA of expression list
  | CONSTANT of constant
  | VARIABLE of string
  | EXPR_SIZEOF of expression
  | TYPE_SIZEOF of base_type
  | INDEX of expression * expression
  | MEMBEROF of expression * string
  | MEMBEROFPTR of expression * string
  | GNU_BODY of body
and constant =
    CONST_INT of string
  | CONST_FLOAT of string
  | CONST_CHAR of string
  | CONST_STRING of string
  | CONST_COMPOUND of expression list
and attributes = attribute list
and attribute = NO_ATTR | ATTR_LIST of attribute list | ATTR_ID of string
