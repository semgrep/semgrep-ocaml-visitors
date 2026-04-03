(* Copyright (C) 2026 Semgrep Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * LICENSE for more details.
 *)

(** Clean-room implementation of the VisitorsRuntime module.

    This interface is generated from the upstream visitors runtime
    ({!i vendor/visitors/runtime/VisitorsRuntime.ml}) to guarantee
    type-level compatibility.  Any implementation that satisfies this
    interface can serve as a drop-in replacement. *)

(** {1 Utility functions} *)

val array_equal : ('a -> 'b -> bool) -> 'a array -> 'b array -> bool
(** [array_equal eq a1 a2] tests whether [a1] and [a2] have pairwise equal
    elements according to [eq].

    {b Precondition:} The two arrays must have equal length.
    @raise Assert_failure if [Array.length a1 <> Array.length a2]. *)

exception StructuralMismatch
(** Raised by arity-2 visitors when two structures do not have matching shapes. *)

val fail : unit -> 'a
(** [fail ()] raises {!StructuralMismatch}. *)

val wrap : ('a -> 'b) -> 'a -> bool
(** [wrap f x] calls [f x] and returns [true] if it completes normally,
    or [false] if {!StructuralMismatch} is raised. *)

val wrap2 : ('a -> 'b -> 'c) -> 'a -> 'b -> bool
(** [wrap2 f x y] calls [f x y] and returns [true] if it completes normally,
    or [false] if {!StructuralMismatch} is raised. *)

(** {1 Monoid classes} *)

(** Virtual base class for monoids.  Inherited by {!reduce},
    {!mapreduce}, {!reduce2}, and {!mapreduce2}.  Subclasses must
    supply concrete [plus] and [zero]. *)
class virtual ['s] monoid :
  object
    method private virtual plus : 's -> 's -> 's
    method private virtual zero : 's
  end

(** Concrete monoid over [int] with [plus = (+)] and [zero = 0]. *)
class ['a] addition_monoid :
  object
    constraint 'a = int
    method private plus : 'a -> 'a -> 'a
    method private zero : 'a
  end

(** Concrete monoid over [unit] with [plus = fun () () -> ()] and
    [zero = ()]. *)
class ['a] unit_monoid :
  object
    constraint 'a = unit
    method private plus : 'a -> 'a -> 'a
    method private zero : 'a
  end

(** {1 Arity-1 visitor classes} *)

(** Side-effecting traversal.  [visit_list] uses a recursive self-call
    (not [List.iter]) so subclasses can override list traversal behavior. *)
class ['self] iter :
  object
    method private visit_array :
      'env 'a. ('env -> 'a -> unit) -> 'env -> 'a array -> unit
    method private visit_bool : 'env. 'env -> bool -> unit
    method private visit_bytes : 'env. 'env -> bytes -> unit
    method private visit_char : 'env. 'env -> char -> unit
    method private visit_float : 'env. 'env -> float -> unit
    method private visit_int : 'env. 'env -> int -> unit
    method private visit_int32 : 'env. 'env -> int32 -> unit
    method private visit_int64 : 'env. 'env -> int64 -> unit
    method private visit_lazy_t :
      'env 'a. ('env -> 'a -> unit) -> 'env -> 'a Lazy.t -> unit
    method private visit_list :
      'env 'a. ('env -> 'a -> unit) -> 'env -> 'a list -> unit
    method private visit_nativeint : 'env. 'env -> nativeint -> unit
    method private visit_option :
      'env 'a. ('env -> 'a -> unit) -> 'env -> 'a option -> unit
    method private visit_ref :
      'env 'a. ('env -> 'a -> unit) -> 'env -> 'a ref -> unit
    method private visit_result :
      'env 'a 'e.
        ('env -> 'a -> unit) ->
        ('env -> 'e -> unit) -> 'env -> ('a, 'e) result -> unit
    method private visit_string : 'env. 'env -> string -> unit
    method private visit_unit : 'env. 'env -> unit -> unit
  end

(** Structure-transforming traversal (input and output types may differ).
    [visit_list] uses a recursive self-call (not [List.map]) so subclasses
    can override list traversal behavior. *)
class ['self] map :
  object
    method private visit_array :
      'env 'a 'b. ('env -> 'a -> 'b) -> 'env -> 'a array -> 'b array
    method private visit_bool : 'env. 'env -> bool -> bool
    method private visit_bytes : 'env. 'env -> bytes -> bytes
    method private visit_char : 'env. 'env -> char -> char
    method private visit_float : 'env. 'env -> float -> float
    method private visit_int : 'env. 'env -> int -> int
    method private visit_int32 : 'env. 'env -> int32 -> int32
    method private visit_int64 : 'env. 'env -> int64 -> int64
    method private visit_lazy_t :
      'env 'a 'b. ('env -> 'a -> 'b) -> 'env -> 'a Lazy.t -> 'b Lazy.t
    method private visit_list :
      'env 'a 'b. ('env -> 'a -> 'b) -> 'env -> 'a list -> 'b list
    method private visit_nativeint : 'env. 'env -> nativeint -> nativeint
    method private visit_option :
      'env 'a 'b. ('env -> 'a -> 'b) -> 'env -> 'a option -> 'b option
    method private visit_ref :
      'env 'a 'b. ('env -> 'a -> 'b) -> 'env -> 'a ref -> 'b ref
    method private visit_result :
      'env 'a 'b 'e 'f.
        ('env -> 'a -> 'b) ->
        ('env -> 'e -> 'f) -> 'env -> ('a, 'e) result -> ('b, 'f) result
    method private visit_string : 'env. 'env -> string -> string
    method private visit_unit : 'env. 'env -> unit -> unit
  end

(** Like {!map} but input and output types are identical, and physical
    identity ([==]) is preserved when the transformation returns a
    physically equal value.  [visit_lazy_t] eagerly forces the suspension. *)
class ['self] endo :
  object
    method private visit_array :
      'env 'a. ('env -> 'a -> 'a) -> 'env -> 'a array -> 'a array
    method private visit_bool : 'env. 'env -> bool -> bool
    method private visit_bytes : 'env. 'env -> bytes -> bytes
    method private visit_char : 'env. 'env -> char -> char
    method private visit_float : 'env. 'env -> float -> float
    method private visit_int : 'env. 'env -> int -> int
    method private visit_int32 : 'env. 'env -> int32 -> int32
    method private visit_int64 : 'env. 'env -> int64 -> int64
    method private visit_lazy_t :
      'env 'a. ('env -> 'a -> 'a) -> 'env -> 'a Lazy.t -> 'a Lazy.t
    method private visit_list :
      'env 'a. ('env -> 'a -> 'a) -> 'env -> 'a list -> 'a list
    method private visit_nativeint : 'env. 'env -> nativeint -> nativeint
    method private visit_option :
      'env 'a. ('env -> 'a -> 'a) -> 'env -> 'a option -> 'a option
    method private visit_ref :
      'env 'a. ('env -> 'a -> 'a) -> 'env -> 'a ref -> 'a ref
    method private visit_result :
      'env 'a 'e.
        ('env -> 'a -> 'a) ->
        ('env -> 'e -> 'e) -> 'env -> ('a, 'e) result -> ('a, 'e) result
    method private visit_string : 'env. 'env -> string -> string
    method private visit_unit : 'env. 'env -> unit -> unit
  end

(** Traversal that accumulates a monoidal summary.  Subclasses must
    provide [zero] and [plus].  [visit_list] uses a right fold;
    [visit_array] uses a left fold. *)
class virtual ['b] reduce :
  object ('b)
    constraint 'b = < .. >
    method private list_fold_left :
      'env 'a. ('env -> 'a -> 's) -> 'env -> 's -> 'a list -> 's
    method private virtual plus : 's -> 's -> 's
    method private visit_array :
      'env 'a. ('env -> 'a -> 's) -> 'env -> 'a array -> 's
    method private visit_bool : 'env. 'env -> bool -> 's
    method private visit_bytes : 'env. 'env -> bytes -> 's
    method private visit_char : 'env. 'env -> char -> 's
    method private visit_float : 'env. 'env -> float -> 's
    method private visit_int : 'env. 'env -> int -> 's
    method private visit_int32 : 'env. 'env -> int32 -> 's
    method private visit_int64 : 'env. 'env -> int64 -> 's
    method private visit_lazy_t :
      'env 'a. ('env -> 'a -> 's) -> 'env -> 'a Lazy.t -> 's
    method private visit_list :
      'env 'a. ('env -> 'a -> 's) -> 'env -> 'a list -> 's
    method private visit_nativeint : 'env. 'env -> nativeint -> 's
    method private visit_option :
      'env 'a. ('env -> 'a -> 's) -> 'env -> 'a option -> 's
    method private visit_ref :
      'env 'a. ('env -> 'a -> 's) -> 'env -> 'a ref -> 's
    method private visit_result :
      'env 'a 'e.
        ('env -> 'a -> 's) ->
        ('env -> 'e -> 's) -> 'env -> ('a, 'e) result -> 's
    method private visit_string : 'env. 'env -> string -> 's
    method private visit_unit : 'env. 'env -> unit -> 's
    method private virtual zero : 's
  end

(** Simultaneous transform and monoidal accumulation.  Each [visit_*]
    method returns [(transformed_value, summary)].  [visit_list] uses
    a right fold. *)
class virtual ['c] mapreduce :
  object ('c)
    constraint 'c = < .. >
    method private virtual plus : 's -> 's -> 's
    method private visit_array :
      'env 'a 'b.
        ('env -> 'a -> 'b * 's) -> 'env -> 'a array -> 'b array * 's
    method private visit_bool : 'env. 'env -> bool -> bool * 's
    method private visit_bytes : 'env. 'env -> bytes -> bytes * 's
    method private visit_char : 'env. 'env -> char -> char * 's
    method private visit_float : 'env. 'env -> float -> float * 's
    method private visit_int : 'env. 'env -> int -> int * 's
    method private visit_int32 : 'env. 'env -> int32 -> int32 * 's
    method private visit_int64 : 'env. 'env -> int64 -> int64 * 's
    method private visit_lazy_t :
      'env 'a 'b.
        ('env -> 'a -> 'b * 's) -> 'env -> 'a Lazy.t -> 'b Lazy.t * 's
    method private visit_list :
      'env 'a 'b. ('env -> 'a -> 'b * 's) -> 'env -> 'a list -> 'b list * 's
    method private visit_nativeint :
      'env. 'env -> nativeint -> nativeint * 's
    method private visit_option :
      'env 'a_0 'a_1.
        ('env -> 'a_0 -> 'a_1 * 's) ->
        'env -> 'a_0 option -> 'a_1 option * 's
    method private visit_ref :
      'env 'a_0 'a_1.
        ('env -> 'a_0 -> 'a_1 * 's) -> 'env -> 'a_0 ref -> 'a_1 ref * 's
    method private visit_result :
      'env 'a_0 'a_1 'b_0 'b_1.
        ('env -> 'a_0 -> 'a_1 * 's) ->
        ('env -> 'b_0 -> 'b_1 * 's) ->
        'env -> ('a_0, 'b_0) result -> ('a_1, 'b_1) result * 's
    method private visit_string : 'env. 'env -> string -> string * 's
    method private visit_unit : 'env. 'env -> unit -> unit * 's
    method private virtual zero : 's
  end

(** Empty class, a placeholder for user-defined fold visitors. *)
class ['self] fold : object  end

(** {1 Arity-2 visitor classes}

    Arity-2 visitors traverse two structures simultaneously.  They raise
    {!StructuralMismatch} when the two structures have incompatible shapes. *)

(** Side-effecting simultaneous traversal.  Raises {!StructuralMismatch}
    on shape mismatch.  Scalar types are compared with [<>]. *)
class ['self] iter2 :
  object
    method private visit_array :
      'env 'a 'b.
        ('env -> 'a -> 'b -> unit) -> 'env -> 'a array -> 'b array -> unit
    method private visit_bool : 'env. 'env -> bool -> bool -> unit
    method private visit_bytes : 'env. 'env -> bytes -> bytes -> unit
    method private visit_char : 'env. 'env -> char -> char -> unit
    method private visit_float : 'env. 'env -> float -> float -> unit
    method private visit_int : 'env. 'env -> int -> int -> unit
    method private visit_int32 : 'env. 'env -> int32 -> int32 -> unit
    method private visit_int64 : 'env. 'env -> int64 -> int64 -> unit
    method private visit_lazy_t :
      'env 'a 'b.
        ('env -> 'a -> 'b -> unit) -> 'env -> 'a Lazy.t -> 'b Lazy.t -> unit
    method private visit_list :
      'env 'a 'b.
        ('env -> 'a -> 'b -> unit) -> 'env -> 'a list -> 'b list -> unit
    method private visit_nativeint :
      'env. 'env -> nativeint -> nativeint -> unit
    method private visit_option :
      'env 'a 'b.
        ('env -> 'a -> 'b -> unit) -> 'env -> 'a option -> 'b option -> unit
    method private visit_ref :
      'env 'a 'b.
        ('env -> 'a -> 'b -> unit) -> 'env -> 'a ref -> 'b ref -> unit
    method private visit_result :
      'env 'a 'b 'e 'f.
        ('env -> 'a -> 'b -> unit) ->
        ('env -> 'e -> 'f -> unit) ->
        'env -> ('a, 'e) result -> ('b, 'f) result -> unit
    method private visit_string : 'env. 'env -> string -> string -> unit
    method private visit_unit : 'env. 'env -> unit -> unit -> unit
  end

(** Structure-transforming simultaneous traversal.  Raises
    {!StructuralMismatch} on shape mismatch. *)
class ['self] map2 :
  object
    method private visit_array :
      'env 'a 'b 'c.
        ('env -> 'a -> 'b -> 'c) -> 'env -> 'a array -> 'b array -> 'c array
    method private visit_bool : 'env. 'env -> bool -> bool -> bool
    method private visit_bytes : 'env. 'env -> bytes -> bytes -> bytes
    method private visit_char : 'env. 'env -> char -> char -> char
    method private visit_float : 'env. 'env -> float -> float -> float
    method private visit_int : 'env. 'env -> int -> int -> int
    method private visit_int32 : 'env. 'env -> int32 -> int32 -> int32
    method private visit_int64 : 'env. 'env -> int64 -> int64 -> int64
    method private visit_lazy_t :
      'env 'a 'b 'c.
        ('env -> 'a -> 'b -> 'c) ->
        'env -> 'a Lazy.t -> 'b Lazy.t -> 'c Lazy.t
    method private visit_list :
      'env 'a 'b 'c.
        ('env -> 'a -> 'b -> 'c) -> 'env -> 'a list -> 'b list -> 'c list
    method private visit_nativeint :
      'env. 'env -> nativeint -> nativeint -> nativeint
    method private visit_option :
      'env 'a 'b 'c.
        ('env -> 'a -> 'b -> 'c) ->
        'env -> 'a option -> 'b option -> 'c option
    method private visit_ref :
      'env 'a 'b 'c.
        ('env -> 'a -> 'b -> 'c) -> 'env -> 'a ref -> 'b ref -> 'c ref
    method private visit_result :
      'env 'a 'b 'c 'e 'f 'g.
        ('env -> 'a -> 'b -> 'c) ->
        ('env -> 'e -> 'f -> 'g) ->
        'env -> ('a, 'e) result -> ('b, 'f) result -> ('c, 'g) result
    method private visit_string : 'env. 'env -> string -> string -> string
    method private visit_unit : 'env. 'env -> unit -> unit -> unit
  end

(** Monoidal reduction over two structures simultaneously. *)
class virtual ['c] reduce2 :
  object ('c)
    constraint 'c = < .. >
    method private virtual plus : 's -> 's -> 's
    method private visit_array :
      'env 'a 'b.
        ('env -> 'a -> 'b -> 's) -> 'env -> 'a array -> 'b array -> 's
    method private visit_bool : 'env. 'env -> bool -> bool -> 's
    method private visit_bytes : 'env. 'env -> bytes -> bytes -> 's
    method private visit_char : 'env. 'env -> char -> char -> 's
    method private visit_float : 'env. 'env -> float -> float -> 's
    method private visit_int : 'env. 'env -> int -> int -> 's
    method private visit_int32 : 'env. 'env -> int32 -> int32 -> 's
    method private visit_int64 : 'env. 'env -> int64 -> int64 -> 's
    method private visit_lazy_t :
      'env 'a 'b.
        ('env -> 'a -> 'b -> 's) -> 'env -> 'a Lazy.t -> 'b Lazy.t -> 's
    method private visit_list :
      'env 'a 'b.
        ('env -> 'a -> 'b -> 's) -> 'env -> 'a list -> 'b list -> 's
    method private visit_nativeint :
      'env. 'env -> nativeint -> nativeint -> 's
    method private visit_option :
      'env 'a 'b.
        ('env -> 'a -> 'b -> 's) -> 'env -> 'a option -> 'b option -> 's
    method private visit_ref :
      'env 'a 'b. ('env -> 'a -> 'b -> 's) -> 'env -> 'a ref -> 'b ref -> 's
    method private visit_result :
      'env 'a 'b 'e 'f.
        ('env -> 'a -> 'b -> 's) ->
        ('env -> 'e -> 'f -> 's) ->
        'env -> ('a, 'e) result -> ('b, 'f) result -> 's
    method private visit_string : 'env. 'env -> string -> string -> 's
    method private visit_unit : 'env. 'env -> unit -> unit -> 's
    method private virtual zero : 's
  end

(** Simultaneous transform and monoidal accumulation over two structures.
    [visit_list] uses a right fold. *)
class virtual ['self] mapreduce2 :
  object
    method private virtual plus : 's -> 's -> 's
    method private visit_array :
      'env 'a 'b 'c.
        ('env -> 'a -> 'b -> 'c * 's) ->
        'env -> 'a array -> 'b array -> 'c array * 's
    method private visit_bool : 'env. 'env -> bool -> bool -> bool * 's
    method private visit_bytes : 'env. 'env -> bytes -> bytes -> bytes * 's
    method private visit_char : 'env. 'env -> char -> char -> char * 's
    method private visit_float : 'env. 'env -> float -> float -> float * 's
    method private visit_int : 'env. 'env -> int -> int -> int * 's
    method private visit_int32 : 'env. 'env -> int32 -> int32 -> int32 * 's
    method private visit_int64 : 'env. 'env -> int64 -> int64 -> int64 * 's
    method private visit_lazy_t :
      'env 'a 'b 'c.
        ('env -> 'a -> 'b -> 'c * 's) ->
        'env -> 'a Lazy.t -> 'b Lazy.t -> 'c Lazy.t * 's
    method private visit_list :
      'env 'a_0 'a_1 'a_2.
        ('env -> 'a_0 -> 'a_1 -> 'a_2 * 's) ->
        'env -> 'a_0 list -> 'a_1 list -> 'a_2 list * 's
    method private visit_nativeint :
      'env. 'env -> nativeint -> nativeint -> nativeint * 's
    method private visit_option :
      'env 'a_0 'a_1 'a_2.
        ('env -> 'a_0 -> 'a_1 -> 'a_2 * 's) ->
        'env -> 'a_0 option -> 'a_1 option -> 'a_2 option * 's
    method private visit_ref :
      'env 'a_0 'a_1 'a_2.
        ('env -> 'a_0 -> 'a_1 -> 'a_2 * 's) ->
        'env -> 'a_0 ref -> 'a_1 ref -> 'a_2 ref * 's
    method private visit_result :
      'env 'a_0 'a_1 'a_2 'b_0 'b_1 'b_2.
        ('env -> 'a_0 -> 'a_1 -> 'a_2 * 's) ->
        ('env -> 'b_0 -> 'b_1 -> 'b_2 * 's) ->
        'env ->
        ('a_0, 'b_0) result ->
        ('a_1, 'b_1) result -> ('a_2, 'b_2) result * 's
    method private visit_string :
      'env. 'env -> string -> string -> string * 's
    method private visit_unit : 'env. 'env -> unit -> unit -> unit * 's
    method private virtual zero : 's
  end

(** Empty class, the arity-2 counterpart of {!fold}. *)
class ['self] fold2 : object  end
