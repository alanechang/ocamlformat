val foo :
  ('k : immediate64) 'cmp.
     (module S
        with type Id_and_repr.t = 'k
         and type Id_and_repr.comparator_witness = 'cmp )
  -> 'k Jane_symbol.Map.t
  -> ('k, Sockaddr.t, 'cmp) Map.t

type ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
  :
  value

type t_value : value

type t_imm : immediate

type t_imm64 : immediate64

type t_float64 : float64

type t_any : any

type t_void : void

(***************************************)
(* Test 1: annotation on type variable *)

let x : int as ('a : value) = 5

let x : int as ('a : immediate) = 5

let x : int as ('a : any) = 5

let x : int as ('a : float64) = 5

let x : (int as ('a : immediate)) list as ('b : value) = [3; 4; 5]

let x : int list as ('a : immediate) = [3; 4; 5]

(****************************************)
(* Test 2: Annotation on type parameter *)

type ('a : immediate) t2_imm

type (_ : immediate) t2_imm'

type t1 = int t2_imm

type t2 = bool t2_imm

type ('a : float64) t2_float64

type (_ : float64) t2_float64'

type t3 = float# t2_float64

module M1 : sig
  type ('a : immediate) t
end = struct
  type (_ : immediate) t
end

module M2 : sig
  type (_ : immediate) t
end = struct
  type ('a : immediate) t
end

type t = string t2_imm

let f : 'a t2_imm -> 'a t2_imm = fun x -> x

let f : ('a : immediate) t2_imm -> ('a : value) t2_imm = fun x -> x

let f : ('a : value) t2_imm -> ('a : value) t2_imm = fun x -> x

let f : ('a : immediate). 'a t2_imm -> 'a t2_imm = fun x -> x

let f : ('a : value). 'a t2_imm -> 'a t2_imm = fun x -> x

type 'a t = 'a t2_imm

type ('a : value) t = 'a t2_imm

type ('a : immediate) t = 'a t2_imm

let f : (_ : value) t2_imm -> unit = fun _ -> ()

let g : (_ : immediate) t2_imm -> unit = fun _ -> ()

let f : (_ : immediate) -> unit = fun _ -> ()

let g : (_ : value) -> unit = fun _ -> ()

let f : (_ : immediate) -> (_ : value) = fun _ -> assert false

let g : (_ : value) -> (_ : immediate) = fun _ -> assert false

(********************************************)
(* Test 3: Annotation on types in functions *)

let f : ('a : any) -> 'a = fun x -> x

let f : ('a : any). 'a -> 'a = fun x -> x

let f : ('a : float64). 'a -> 'a = fun x -> x

(********************************************)
(* Test 4: Annotation on record field types *)

type r = {field: ('a : immediate). 'a -> 'a}

let f {field} = field 5

type rf = {fieldf: ('a : float64). 'a -> 'a}

let f {fieldf} = fieldf (Stdlib__Float_u.of_float 3.14)

let f {field} = field "hello"

let r = {field= (fun x -> x)}

let r = {field= Fun.id}

let r = {field= (fun (type a : immediate) (x : a) -> x)}

let r = {field= (fun (type a : value) (x : a) -> x)}

type r_value = {field: 'a. 'a -> 'a}

let r = {field= (fun (type a : immediate) (x : a) -> x)}

(* CR layouts v1.5: that's a pretty awful error message *)

type ('a : immediate) t_imm

type s = {f: ('a : value). 'a -> 'a u}

and 'a u = 'a t_imm

(* CR layouts v1.5: the location on that message is wrong. But it's hard to
   improve, because it comes from re-checking typedtree, where we don't have
   locations any more. I conjecture the same location problem exists when
   constraints aren't satisfied. *)

(********************)
(* Test 5: newtypes *)

let f (type a : value) (x : a) = x

let f (type a : immediate) (x : a) = x

let f (type a : float64) (x : a) = x

let f (type a : any) (x : a) = x

(****************************************)
(* Test 6: abstract universal variables *)

let f : type (a : value). a -> a = fun x -> x

let f : type (a : immediate). a -> a = fun x -> x

let f : type (a : float64). a -> a = fun x -> x

let f : type (a : any). a -> a = fun x -> x

(**************************************************)
(* Test 7: Defaulting universal variable to value *)

module type S = sig
  val f : 'a. 'a t2_imm -> 'a t2_imm
end

let f : 'a. 'a t2_imm -> 'a t2_imm = fun x -> x

(********************************************)
(* Test 8: Annotation on universal variable *)

module type S = sig
  val f : ('a : value). 'a t2_imm -> 'a t2_imm
end

module type S = sig
  val f : 'a t2_imm -> 'a t2_imm

  val g : ('a : immediate). 'a t2_imm -> 'a t2_imm
end

module type S = sig
  val f : 'a t2_float64 -> 'a t2_float64

  val g : ('a : float64). 'a t2_float64 -> 'a t2_float64
end

(************************************************************)
(* Test 9: Annotation on universal in polymorphic parameter *)

let f (x : ('a : immediate). 'a -> 'a) = x "string"

(**************************************)
(* Test 10: Parsing & pretty-printing *)

let f (type a : immediate) (x : a) = x

let f (type a : immediate) (x : a) = x

let f (type a : value) (x : a) = x

let o =
  object
    method m : type (a : immediate). a -> a = fun x -> x
  end

let f : type (a : immediate). a -> a = fun x -> x

let f x =
  let local_ g (type a : immediate) (x : a) = x in
  g x [@nontail]

let f x y (type a : immediate) (z : a) = z

let f x y (type a : immediate) (z : a) = z

external f : ('a : immediate). 'a -> 'a = "%identity"

type (_ : any) t2_any

exception E : ('a : immediate) ('b : any). 'b t2_any * 'a list -> exn

let f (x : ('a : immediate). 'a -> 'a) = (x 3, x true)

type _ a = Mk : [> ] * ('a : immediate) -> int a

module type S = sig
  type _ a = Mk : [> ] * ('a : immediate) -> int a

  val f_imm : ('a : immediate) ('b : value). 'a -> 'a

  val f_val : ('a : value). 'a -> 'a

  type (_ : value) g = MkG : ('a : immediate). 'a g

  type t = int as (_ : immediate)
end

let f_imm : ('a : immediate). 'a -> 'a = fun x -> x

let f_val : ('a : value). 'a -> 'a = fun x -> f_imm x

type (_ : value) g = MkG : ('a : immediate). 'a g

type t = int as (_ : immediate)

type t = (('a : value), ('b : value)) t2

type ('a, 'b) t = ('a : value) * ('b : value)

class c : object
  method m : ('a : immediate). 'a -> 'a

  val f : ('a : immediate) -> 'a
end =
  object
    method m : type (a : immediate). a -> a = fun x -> x

    val f = fun (x : ('a : immediate)) -> x
  end

type _ g = MkG : ('a : immediate) ('b : void). 'a -> 'b g

type ('a : void) t3 = ..

type _ t3 += MkG : ('a : immediate) 'b. 'a -> 'b t3

let f_gadt : ('a : value). 'a -> 'a g -> 'a = fun x MkG -> f_imm x

(* comments *)
val foo :
  ((* comment 1 *) 'k (* comment 2 *) : (* comment 3 *) immediate64
  (* comment 4 *)) (* comment 5 *)
  'cmp.
     (module S
        with type Id_and_repr.t = 'k
         and type Id_and_repr.comparator_witness = 'cmp )
  -> 'k Jane_symbol.Map.t
  -> ('k, Sockaddr.t, 'cmp) Map.t

type a =
  b (* comment 0 *)
  as
  ((* comment 1 *)
  'k
  (* comment 2 *)
  :
  (* comment 3 *)
  immediate64
  (* comment 4 *))
(* comment 5 *)

let f (type a : immediate) x = x

let f
    (type (a : immediate) b c d e f g h i j k l m n o p q r s t u v w x y z)
    x =
  x

let f (type (a : immediate) b) x = x

let f (type a (b : immediate)) x = x

let f (type (a : immediate) (b : immediate)) x = x
