(* Shared type definitions for visitor traversal tests.
   This file is symlinked into types_ours/ and types_theirs/. *)

(* Simple enum *)
type color = Red | Green | Blue
[@@deriving
  visitors { variety = "iter"; name = "color_iter" },
  visitors { variety = "map"; name = "color_map" },
  visitors { variety = "reduce"; name = "color_reduce" }]

(* Recursive tree *)
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
[@@deriving
  visitors { variety = "iter"; name = "tree_iter" },
  visitors { variety = "map"; name = "tree_map" },
  visitors { variety = "endo"; name = "tree_endo" },
  visitors { variety = "reduce"; name = "tree_reduce" },
  visitors { variety = "mapreduce"; name = "tree_mapreduce" },
  visitors { variety = "iter2"; name = "tree_iter2" },
  visitors { variety = "map2"; name = "tree_map2" },
  visitors { variety = "reduce2"; name = "tree_reduce2" }]

(* Record type *)
type person = {
  name : string;
  age : int;
  hobbies : string list;
}
[@@deriving
  visitors { variety = "iter"; name = "person_iter" },
  visitors { variety = "map"; name = "person_map" },
  visitors { variety = "reduce"; name = "person_reduce" }]

(* Mutually recursive types *)
type expr =
  | Lit of int
  | Add of expr * expr
  | Neg of expr
  | Let of string * expr * expr
  | Var of string
  | IfZero of expr * expr * expr
  | Call of string * expr list

and stmt =
  | Assign of string * expr
  | Seq of stmt list
  | While of expr * stmt
  | Return of expr
[@@deriving
  visitors { variety = "iter"; name = "expr_iter" },
  visitors { variety = "map"; name = "expr_map" },
  visitors { variety = "endo"; name = "expr_endo" },
  visitors { variety = "reduce"; name = "expr_reduce" },
  visitors { variety = "mapreduce"; name = "expr_mapreduce" }]

(* Tuple type *)
type point = int * int * int
[@@deriving
  visitors { variety = "iter"; name = "point_iter" },
  visitors { variety = "map"; name = "point_map" },
  visitors { variety = "reduce"; name = "point_reduce" }]
