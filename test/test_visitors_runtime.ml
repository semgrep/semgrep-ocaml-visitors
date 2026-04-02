(* Property-based tests comparing our clean-room VisitorsRuntime against
   the upstream visitors.runtime. *)

module Ours = VisitorsRuntime
module Theirs = Upstream_visitors_runtime

(* ------------------------------------------------------------------ *)
(* Generators                                                          *)
(* ------------------------------------------------------------------ *)

let int_gen = QCheck.int_small
let list_int_gen = QCheck.list_small QCheck.int_small
let array_int_gen = QCheck.map Array.of_list (QCheck.list_small QCheck.int_small)
let option_int_gen = QCheck.option QCheck.int_small
let result_int_gen =
  QCheck.map
    (fun (b, x) -> if b then Ok x else Error x)
    (QCheck.pair QCheck.bool QCheck.int_small)

(* ------------------------------------------------------------------ *)
(* Expose private methods by subclassing at concrete types.            *)
(* We fix the polymorphic type variables to concrete types to avoid    *)
(* unbound type variable errors.                                       *)
(* ------------------------------------------------------------------ *)

(* -- iter exposed (env=unit, a=int) -- *)
class ours_iter = object
  inherit [_] Ours.iter as super
  method list_ (f : unit -> int -> unit) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> unit) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> unit) xs = super#visit_array f () xs
  method result_ (f : unit -> int -> unit) (g : unit -> int -> unit) xs = super#visit_result f g () xs
  method ref_ (f : unit -> int -> unit) xs = super#visit_ref f () xs
  method lazy_ (f : unit -> int -> unit) xs = super#visit_lazy_t f () xs
end
class theirs_iter = object
  inherit [_] Theirs.iter as super
  method list_ (f : unit -> int -> unit) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> unit) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> unit) xs = super#visit_array f () xs
  method result_ (f : unit -> int -> unit) (g : unit -> int -> unit) xs = super#visit_result f g () xs
  method ref_ (f : unit -> int -> unit) xs = super#visit_ref f () xs
  method lazy_ (f : unit -> int -> unit) xs = super#visit_lazy_t f () xs
end

(* -- map exposed (env=unit, a=int, b=int) -- *)
class ours_map = object
  inherit [_] Ours.map as super
  method list_ (f : unit -> int -> int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> int) xs = super#visit_array f () xs
  method result_ (f : unit -> int -> int) (g : unit -> int -> int) xs = super#visit_result f g () xs
  method lazy_ (f : unit -> int -> int) xs = super#visit_lazy_t f () xs
  method int_ x = super#visit_int () x
  method bool_ x = super#visit_bool () x
  method string_ x = super#visit_string () x
end
class theirs_map = object
  inherit [_] Theirs.map as super
  method list_ (f : unit -> int -> int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> int) xs = super#visit_array f () xs
  method result_ (f : unit -> int -> int) (g : unit -> int -> int) xs = super#visit_result f g () xs
  method lazy_ (f : unit -> int -> int) xs = super#visit_lazy_t f () xs
  method int_ x = super#visit_int () x
  method bool_ x = super#visit_bool () x
  method string_ x = super#visit_string () x
end

(* -- endo exposed (env=unit, a=int) -- *)
class ours_endo = object
  inherit [_] Ours.endo as super
  method list_ (f : unit -> int -> int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int) xs = super#visit_option f () xs
  method ref_ (f : unit -> int -> int) xs = super#visit_ref f () xs
  method result_ (f : unit -> int -> int) (g : unit -> int -> int) xs = super#visit_result f g () xs
  method lazy_ (f : unit -> int -> int) xs = super#visit_lazy_t f () xs
  method array_ (f : unit -> int -> int) xs = super#visit_array f () xs
end
class theirs_endo = object
  inherit [_] Theirs.endo as super
  method list_ (f : unit -> int -> int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int) xs = super#visit_option f () xs
  method ref_ (f : unit -> int -> int) xs = super#visit_ref f () xs
  method result_ (f : unit -> int -> int) (g : unit -> int -> int) xs = super#visit_result f g () xs
  method lazy_ (f : unit -> int -> int) xs = super#visit_lazy_t f () xs
  method array_ (f : unit -> int -> int) xs = super#visit_array f () xs
end

(* -- reduce exposed (env=unit, a=int, s=int) -- *)
class ours_reduce = object
  inherit [_] Ours.reduce as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> int) xs = super#visit_array f () xs
  method result_ (f : unit -> int -> int) (g : unit -> int -> int) xs = super#visit_result f g () xs
  method lazy_ (f : unit -> int -> int) xs = super#visit_lazy_t f () xs
end
class theirs_reduce = object
  inherit [_] Theirs.reduce as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> int) xs = super#visit_array f () xs
  method result_ (f : unit -> int -> int) (g : unit -> int -> int) xs = super#visit_result f g () xs
  method lazy_ (f : unit -> int -> int) xs = super#visit_lazy_t f () xs
end

(* -- mapreduce exposed (env=unit, a=int, b=int, s=int) -- *)
class ours_mapreduce = object
  inherit [_] Ours.mapreduce as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int * int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int * int) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> int * int) xs = super#visit_array f () xs
  method lazy_ (f : unit -> int -> int * int) xs = super#visit_lazy_t f () xs
  method result_ (f : unit -> int -> int * int) (g : unit -> int -> int * int) xs = super#visit_result f g () xs
  method ref_ (f : unit -> int -> int * int) xs = super#visit_ref f () xs
end
class theirs_mapreduce = object
  inherit [_] Theirs.mapreduce as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int * int) xs = super#visit_list f () xs
  method option_ (f : unit -> int -> int * int) xs = super#visit_option f () xs
  method array_ (f : unit -> int -> int * int) xs = super#visit_array f () xs
  method lazy_ (f : unit -> int -> int * int) xs = super#visit_lazy_t f () xs
  method result_ (f : unit -> int -> int * int) (g : unit -> int -> int * int) xs = super#visit_result f g () xs
  method ref_ (f : unit -> int -> int * int) xs = super#visit_ref f () xs
end

(* -- mapreduce with non-associative monoid (subtraction) -- *)
class ours_mapreduce_sub = object
  inherit [_] Ours.mapreduce as super
  method private zero = 0
  method private plus a b = a - b
  method list_ (f : unit -> int -> int * int) xs = super#visit_list f () xs
end
class theirs_mapreduce_sub = object
  inherit [_] Theirs.mapreduce as super
  method private zero = 0
  method private plus a b = a - b
  method list_ (f : unit -> int -> int * int) xs = super#visit_list f () xs
end

(* -- iter2 exposed (env=unit, a=int, b=int) -- *)
class ours_iter2 = object
  inherit [_] Ours.iter2 as super
  method list_ (f : unit -> int -> int -> unit) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> unit) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> unit) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> unit) (g : unit -> int -> int -> unit) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> unit) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> unit) xs ys = super#visit_lazy_t f () xs ys
  method int_ x y = super#visit_int () x y
  method float_ x y = super#visit_float () x y
end
class theirs_iter2 = object
  inherit [_] Theirs.iter2 as super
  method list_ (f : unit -> int -> int -> unit) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> unit) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> unit) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> unit) (g : unit -> int -> int -> unit) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> unit) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> unit) xs ys = super#visit_lazy_t f () xs ys
  method int_ x y = super#visit_int () x y
  method float_ x y = super#visit_float () x y
end

(* -- map2 exposed (env=unit, a=int, b=int, c=int) -- *)
class ours_map2 = object
  inherit [_] Ours.map2 as super
  method list_ (f : unit -> int -> int -> int) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> int) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> int) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> int) (g : unit -> int -> int -> int) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> int) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> int) xs ys = super#visit_lazy_t f () xs ys
  method int_ x y = super#visit_int () x y
end
class theirs_map2 = object
  inherit [_] Theirs.map2 as super
  method list_ (f : unit -> int -> int -> int) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> int) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> int) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> int) (g : unit -> int -> int -> int) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> int) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> int) xs ys = super#visit_lazy_t f () xs ys
  method int_ x y = super#visit_int () x y
end

(* -- reduce2 exposed (env=unit, a=int, b=int, s=int) -- *)
class ours_reduce2 = object
  inherit [_] Ours.reduce2 as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int -> int) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> int) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> int) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> int) (g : unit -> int -> int -> int) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> int) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> int) xs ys = super#visit_lazy_t f () xs ys
end
class theirs_reduce2 = object
  inherit [_] Theirs.reduce2 as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int -> int) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> int) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> int) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> int) (g : unit -> int -> int -> int) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> int) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> int) xs ys = super#visit_lazy_t f () xs ys
end

(* -- mapreduce2 exposed (env=unit, a=int, b=int, c=int, s=int) -- *)
class ours_mapreduce2 = object
  inherit [_] Ours.mapreduce2 as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int -> int * int) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> int * int) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> int * int) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> int * int) (g : unit -> int -> int -> int * int) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> int * int) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> int * int) xs ys = super#visit_lazy_t f () xs ys
end
class theirs_mapreduce2 = object
  inherit [_] Theirs.mapreduce2 as super
  method private zero = 0
  method private plus = ( + )
  method list_ (f : unit -> int -> int -> int * int) xs ys = super#visit_list f () xs ys
  method option_ (f : unit -> int -> int -> int * int) xs ys = super#visit_option f () xs ys
  method array_ (f : unit -> int -> int -> int * int) xs ys = super#visit_array f () xs ys
  method result_ (f : unit -> int -> int -> int * int) (g : unit -> int -> int -> int * int) xs ys = super#visit_result f g () xs ys
  method ref_ (f : unit -> int -> int -> int * int) xs ys = super#visit_ref f () xs ys
  method lazy_ (f : unit -> int -> int -> int * int) xs ys = super#visit_lazy_t f () xs ys
end

(* -- mapreduce2 with non-associative monoid -- *)
class ours_mapreduce2_sub = object
  inherit [_] Ours.mapreduce2 as super
  method private zero = 0
  method private plus a b = a - b
  method list_ (f : unit -> int -> int -> int * int) xs ys = super#visit_list f () xs ys
end
class theirs_mapreduce2_sub = object
  inherit [_] Theirs.mapreduce2 as super
  method private zero = 0
  method private plus a b = a - b
  method list_ (f : unit -> int -> int -> int * int) xs ys = super#visit_list f () xs ys
end

(* ------------------------------------------------------------------ *)
(* Helpers for catching StructuralMismatch from either implementation  *)
(* ------------------------------------------------------------------ *)

let catch_ours f =
  try `Ok (f ()) with Ours.StructuralMismatch -> `Mismatch

let catch_theirs f =
  try `Ok (f ()) with Theirs.StructuralMismatch -> `Mismatch

let catch_ours_unit f =
  try f (); `Ok with Ours.StructuralMismatch -> `Mismatch

let catch_theirs_unit f =
  try f (); `Ok with Theirs.StructuralMismatch -> `Mismatch

(* ------------------------------------------------------------------ *)
(* Tests                                                               *)
(* ------------------------------------------------------------------ *)

(* -- array_equal -- *)
let test_array_equal =
  QCheck.Test.make ~name:"array_equal agrees"
    ~count:500
    (QCheck.map (fun xs ->
       let a = Array.of_list xs in
       let b = Array.map (fun x -> x) a in
       (a, b))
       (QCheck.list_small QCheck.int_small))
    (fun (a1, a2) ->
       Ours.array_equal ( = ) a1 a2
       = Theirs.array_equal ( = ) a1 a2)

let test_array_equal_different =
  QCheck.Test.make ~name:"array_equal agrees (different values, same length)"
    ~count:500
    (QCheck.map (fun (xs, ys) ->
       let n = min (List.length xs) (List.length ys) in
       let a = Array.of_list (List.filteri (fun i _ -> i < n) xs) in
       let b = Array.of_list (List.filteri (fun i _ -> i < n) ys) in
       (a, b))
       (QCheck.pair
          (QCheck.list_small QCheck.int_small)
          (QCheck.list_small QCheck.int_small)))
    (fun (a1, a2) ->
       Ours.array_equal ( = ) a1 a2
       = Theirs.array_equal ( = ) a1 a2)

(* -- fail -- *)
let test_fail =
  QCheck.Test.make ~name:"fail raises StructuralMismatch"
    ~count:1
    QCheck.unit
    (fun () ->
       let ours = (try ignore (Ours.fail ()); false with Ours.StructuralMismatch -> true) in
       let theirs = (try ignore (Theirs.fail ()); false with Theirs.StructuralMismatch -> true) in
       ours && theirs)

(* -- wrap -- *)
let test_wrap =
  QCheck.Test.make ~name:"wrap agrees"
    ~count:200
    QCheck.bool
    (fun b ->
       let f () = if b then () else raise Ours.StructuralMismatch in
       let g () = if b then () else raise Theirs.StructuralMismatch in
       Ours.wrap f () = Theirs.wrap g ())

let test_wrap2 =
  QCheck.Test.make ~name:"wrap2 agrees"
    ~count:200
    (QCheck.pair QCheck.bool int_gen)
    (fun (b, x) ->
       let f () y = if b then y else raise Ours.StructuralMismatch in
       let g () y = if b then y else raise Theirs.StructuralMismatch in
       Ours.wrap2 f () x = Theirs.wrap2 g () x)

(* -- iter -- *)
let test_iter_list =
  QCheck.Test.make ~name:"iter#visit_list side effects agree"
    ~count:500
    list_int_gen
    (fun xs ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       (new ours_iter)#list_ (fun () x -> ours_acc := x :: !ours_acc) xs;
       (new theirs_iter)#list_ (fun () x -> theirs_acc := x :: !theirs_acc) xs;
       !ours_acc = !theirs_acc)

let test_iter_option =
  QCheck.Test.make ~name:"iter#visit_option side effects agree"
    ~count:500
    option_int_gen
    (fun opt ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       (new ours_iter)#option_ (fun () x -> ours_acc := x :: !ours_acc) opt;
       (new theirs_iter)#option_ (fun () x -> theirs_acc := x :: !theirs_acc) opt;
       !ours_acc = !theirs_acc)

let test_iter_array =
  QCheck.Test.make ~name:"iter#visit_array side effects agree"
    ~count:500
    array_int_gen
    (fun arr ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       (new ours_iter)#array_ (fun () x -> ours_acc := x :: !ours_acc) arr;
       (new theirs_iter)#array_ (fun () x -> theirs_acc := x :: !theirs_acc) arr;
       !ours_acc = !theirs_acc)

let test_iter_result =
  QCheck.Test.make ~name:"iter#visit_result side effects agree"
    ~count:500
    result_int_gen
    (fun r ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       let f () x = ours_acc := (`Ok x) :: !ours_acc in
       let g () x = ours_acc := (`Err x) :: !ours_acc in
       let f' () x = theirs_acc := (`Ok x) :: !theirs_acc in
       let g' () x = theirs_acc := (`Err x) :: !theirs_acc in
       (new ours_iter)#result_ f g r;
       (new theirs_iter)#result_ f' g' r;
       !ours_acc = !theirs_acc)

(* -- map -- *)
let test_map_list =
  QCheck.Test.make ~name:"map#visit_list agrees"
    ~count:500
    list_int_gen
    (fun xs ->
       (new ours_map)#list_ (fun () x -> x + 1) xs
       = (new theirs_map)#list_ (fun () x -> x + 1) xs)

let test_map_option =
  QCheck.Test.make ~name:"map#visit_option agrees"
    ~count:500
    option_int_gen
    (fun opt ->
       (new ours_map)#option_ (fun () x -> x * 2) opt
       = (new theirs_map)#option_ (fun () x -> x * 2) opt)

let test_map_array =
  QCheck.Test.make ~name:"map#visit_array agrees"
    ~count:500
    array_int_gen
    (fun arr ->
       (new ours_map)#array_ (fun () x -> x + 10) arr
       = (new theirs_map)#array_ (fun () x -> x + 10) arr)

let test_map_result =
  QCheck.Test.make ~name:"map#visit_result agrees"
    ~count:500
    result_int_gen
    (fun r ->
       (new ours_map)#result_ (fun () x -> x + 1) (fun () x -> x - 1) r
       = (new theirs_map)#result_ (fun () x -> x + 1) (fun () x -> x - 1) r)

let test_map_int =
  QCheck.Test.make ~name:"map#visit_int agrees"
    ~count:500
    int_gen
    (fun x ->
       (new ours_map)#int_ x = (new theirs_map)#int_ x)

let test_map_bool =
  QCheck.Test.make ~name:"map#visit_bool agrees"
    ~count:50
    QCheck.bool
    (fun x ->
       (new ours_map)#bool_ x = (new theirs_map)#bool_ x)

(* -- endo -- *)
let test_endo_identity_list =
  QCheck.Test.make ~name:"endo#visit_list preserves identity when no change"
    ~count:500
    list_int_gen
    (fun xs ->
       let identity () x = x in
       let o_res = (new ours_endo)#list_ identity xs in
       let t_res = (new theirs_endo)#list_ identity xs in
       (o_res == xs) = (t_res == xs))

let test_endo_change_list =
  QCheck.Test.make ~name:"endo#visit_list changes value correctly"
    ~count:500
    list_int_gen
    (fun xs ->
       (new ours_endo)#list_ (fun () x -> x + 1) xs
       = (new theirs_endo)#list_ (fun () x -> x + 1) xs)

let test_endo_identity_option =
  QCheck.Test.make ~name:"endo#visit_option preserves identity when no change"
    ~count:500
    option_int_gen
    (fun opt ->
       let identity () x = x in
       let o_res = (new ours_endo)#option_ identity opt in
       let t_res = (new theirs_endo)#option_ identity opt in
       (o_res == opt) = (t_res == opt))

let test_endo_identity_result =
  QCheck.Test.make ~name:"endo#visit_result preserves identity when no change"
    ~count:500
    result_int_gen
    (fun r ->
       let identity () x = x in
       let o_res = (new ours_endo)#result_ identity identity r in
       let t_res = (new theirs_endo)#result_ identity identity r in
       (o_res == r) = (t_res == r))

(* -- reduce -- *)
let test_reduce_list =
  QCheck.Test.make ~name:"reduce#visit_list agrees (sum)"
    ~count:500
    list_int_gen
    (fun xs ->
       (new ours_reduce)#list_ (fun () x -> x) xs
       = (new theirs_reduce)#list_ (fun () x -> x) xs)

let test_reduce_option =
  QCheck.Test.make ~name:"reduce#visit_option agrees"
    ~count:500
    option_int_gen
    (fun opt ->
       (new ours_reduce)#option_ (fun () x -> x) opt
       = (new theirs_reduce)#option_ (fun () x -> x) opt)

let test_reduce_array =
  QCheck.Test.make ~name:"reduce#visit_array agrees (sum)"
    ~count:500
    array_int_gen
    (fun arr ->
       (new ours_reduce)#array_ (fun () x -> x) arr
       = (new theirs_reduce)#array_ (fun () x -> x) arr)

let test_reduce_result =
  QCheck.Test.make ~name:"reduce#visit_result agrees"
    ~count:500
    result_int_gen
    (fun r ->
       (new ours_reduce)#result_ (fun () x -> x) (fun () x -> x) r
       = (new theirs_reduce)#result_ (fun () x -> x) (fun () x -> x) r)

(* -- mapreduce -- *)
let test_mapreduce_list =
  QCheck.Test.make ~name:"mapreduce#visit_list agrees"
    ~count:500
    list_int_gen
    (fun xs ->
       (new ours_mapreduce)#list_ (fun () x -> (x + 1, x)) xs
       = (new theirs_mapreduce)#list_ (fun () x -> (x + 1, x)) xs)

let test_mapreduce_option =
  QCheck.Test.make ~name:"mapreduce#visit_option agrees"
    ~count:500
    option_int_gen
    (fun opt ->
       (new ours_mapreduce)#option_ (fun () x -> (x * 2, x)) opt
       = (new theirs_mapreduce)#option_ (fun () x -> (x * 2, x)) opt)

let test_mapreduce_array =
  QCheck.Test.make ~name:"mapreduce#visit_array agrees"
    ~count:500
    array_int_gen
    (fun arr ->
       (new ours_mapreduce)#array_ (fun () x -> (x + 1, x)) arr
       = (new theirs_mapreduce)#array_ (fun () x -> (x + 1, x)) arr)

(* -- iter2 -- *)
let test_iter2_list =
  QCheck.Test.make ~name:"iter2#visit_list agrees"
    ~count:500
    (QCheck.pair list_int_gen list_int_gen)
    (fun (xs, ys) ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       let or_ = catch_ours_unit (fun () ->
         (new ours_iter2)#list_ (fun () a b -> ours_acc := (a, b) :: !ours_acc) xs ys) in
       let tr_ = catch_theirs_unit (fun () ->
         (new theirs_iter2)#list_ (fun () a b -> theirs_acc := (a, b) :: !theirs_acc) xs ys) in
       or_ = tr_ && !ours_acc = !theirs_acc)

let test_iter2_int_mismatch =
  QCheck.Test.make ~name:"iter2#visit_int mismatch agrees"
    ~count:500
    (QCheck.pair int_gen int_gen)
    (fun (a, b) ->
       let or_ = catch_ours_unit (fun () -> (new ours_iter2)#int_ a b) in
       let tr_ = catch_theirs_unit (fun () -> (new theirs_iter2)#int_ a b) in
       or_ = tr_)

let test_iter2_array =
  QCheck.Test.make ~name:"iter2#visit_array agrees"
    ~count:500
    (QCheck.pair array_int_gen array_int_gen)
    (fun (a1, a2) ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       let or_ = catch_ours_unit (fun () ->
         (new ours_iter2)#array_ (fun () a b -> ours_acc := (a, b) :: !ours_acc) a1 a2) in
       let tr_ = catch_theirs_unit (fun () ->
         (new theirs_iter2)#array_ (fun () a b -> theirs_acc := (a, b) :: !theirs_acc) a1 a2) in
       or_ = tr_ && !ours_acc = !theirs_acc)

(* -- map2 -- *)
let test_map2_list =
  QCheck.Test.make ~name:"map2#visit_list agrees"
    ~count:500
    (QCheck.pair list_int_gen list_int_gen)
    (fun (xs, ys) ->
       catch_ours (fun () -> (new ours_map2)#list_ (fun () a b -> a + b) xs ys)
       = catch_theirs (fun () -> (new theirs_map2)#list_ (fun () a b -> a + b) xs ys))

let test_map2_option =
  QCheck.Test.make ~name:"map2#visit_option agrees"
    ~count:500
    (QCheck.pair option_int_gen option_int_gen)
    (fun (a, b) ->
       catch_ours (fun () -> (new ours_map2)#option_ (fun () x y -> x + y) a b)
       = catch_theirs (fun () -> (new theirs_map2)#option_ (fun () x y -> x + y) a b))

let test_map2_int =
  QCheck.Test.make ~name:"map2#visit_int agrees"
    ~count:500
    (QCheck.pair int_gen int_gen)
    (fun (a, b) ->
       catch_ours (fun () -> (new ours_map2)#int_ a b)
       = catch_theirs (fun () -> (new theirs_map2)#int_ a b))

let test_map2_array =
  QCheck.Test.make ~name:"map2#visit_array agrees"
    ~count:500
    (QCheck.pair array_int_gen array_int_gen)
    (fun (a1, a2) ->
       catch_ours (fun () -> (new ours_map2)#array_ (fun () a b -> a + b) a1 a2)
       = catch_theirs (fun () -> (new theirs_map2)#array_ (fun () a b -> a + b) a1 a2))

(* -- reduce2 -- *)
let test_reduce2_list =
  QCheck.Test.make ~name:"reduce2#visit_list agrees"
    ~count:500
    (QCheck.pair list_int_gen list_int_gen)
    (fun (xs, ys) ->
       catch_ours (fun () -> (new ours_reduce2)#list_ (fun () a b -> a + b) xs ys)
       = catch_theirs (fun () -> (new theirs_reduce2)#list_ (fun () a b -> a + b) xs ys))

let test_reduce2_option =
  QCheck.Test.make ~name:"reduce2#visit_option agrees"
    ~count:500
    (QCheck.pair option_int_gen option_int_gen)
    (fun (a, b) ->
       catch_ours (fun () -> (new ours_reduce2)#option_ (fun () x y -> x + y) a b)
       = catch_theirs (fun () -> (new theirs_reduce2)#option_ (fun () x y -> x + y) a b))

(* -- mapreduce2 -- *)
let test_mapreduce2_list =
  QCheck.Test.make ~name:"mapreduce2#visit_list agrees"
    ~count:500
    (QCheck.pair list_int_gen list_int_gen)
    (fun (xs, ys) ->
       catch_ours (fun () ->
         (new ours_mapreduce2)#list_ (fun () a b -> (a + b, a * b)) xs ys)
       = catch_theirs (fun () ->
         (new theirs_mapreduce2)#list_ (fun () a b -> (a + b, a * b)) xs ys))

let test_mapreduce2_option =
  QCheck.Test.make ~name:"mapreduce2#visit_option agrees"
    ~count:500
    (QCheck.pair option_int_gen option_int_gen)
    (fun (a, b) ->
       catch_ours (fun () ->
         (new ours_mapreduce2)#option_ (fun () x y -> (x + y, x * y)) a b)
       = catch_theirs (fun () ->
         (new theirs_mapreduce2)#option_ (fun () x y -> (x + y, x * y)) a b))

(* -- lazy_t generators -- *)
let lazy_int_gen = QCheck.map (fun x -> lazy x) QCheck.int_small

(* -- iter lazy -- *)
let test_iter_lazy =
  QCheck.Test.make ~name:"iter#visit_lazy_t agrees"
    ~count:500
    lazy_int_gen
    (fun lz ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       (new ours_iter)#lazy_ (fun () x -> ours_acc := x :: !ours_acc) lz;
       (new theirs_iter)#lazy_ (fun () x -> theirs_acc := x :: !theirs_acc) lz;
       !ours_acc = !theirs_acc)

(* -- map lazy -- *)
let test_map_lazy =
  QCheck.Test.make ~name:"map#visit_lazy_t agrees"
    ~count:500
    lazy_int_gen
    (fun lz ->
       let o_res = (new ours_map)#lazy_ (fun () x -> x + 1) lz in
       let t_res = (new theirs_map)#lazy_ (fun () x -> x + 1) lz in
       Lazy.force o_res = Lazy.force t_res)

let test_map_lazy_deferred =
  QCheck.Test.make ~name:"map#visit_lazy_t defers forcing"
    ~count:1
    QCheck.unit
    (fun () ->
       let forced_o = ref false in
       let forced_t = ref false in
       let lz_o = lazy (forced_o := true; 42) in
       let lz_t = lazy (forced_t := true; 42) in
       let _o_res = (new ours_map)#lazy_ (fun () x -> x) lz_o in
       let _t_res = (new theirs_map)#lazy_ (fun () x -> x) lz_t in
       !forced_o = !forced_t)

(* -- endo lazy: identity preservation -- *)
let test_endo_lazy_identity =
  QCheck.Test.make ~name:"endo#visit_lazy_t preserves identity when unchanged"
    ~count:500
    lazy_int_gen
    (fun lz ->
       (* Force first so identity is physically the forced value *)
       ignore (Lazy.force lz);
       let o_res = (new ours_endo)#lazy_ (fun () x -> x) lz in
       let t_res = (new theirs_endo)#lazy_ (fun () x -> x) lz in
       (o_res == lz) = (t_res == lz))

let test_endo_lazy_change =
  QCheck.Test.make ~name:"endo#visit_lazy_t correct value when changed"
    ~count:500
    lazy_int_gen
    (fun lz ->
       let o_res = (new ours_endo)#lazy_ (fun () x -> x + 1) lz in
       let t_res = (new theirs_endo)#lazy_ (fun () x -> x + 1) lz in
       Lazy.force o_res = Lazy.force t_res)

let test_endo_lazy_forces_eagerly =
  QCheck.Test.make ~name:"endo#visit_lazy_t forces eagerly"
    ~count:1
    QCheck.unit
    (fun () ->
       let forced_o = ref false in
       let forced_t = ref false in
       let lz_o = lazy (forced_o := true; 42) in
       let lz_t = lazy (forced_t := true; 42) in
       let _o_res = (new ours_endo)#lazy_ (fun () x -> x) lz_o in
       let _t_res = (new theirs_endo)#lazy_ (fun () x -> x) lz_t in
       !forced_o = !forced_t)

(* -- endo array identity -- *)
let test_endo_array_identity =
  QCheck.Test.make ~name:"endo#visit_array preserves identity when no change"
    ~count:500
    array_int_gen
    (fun arr ->
       let o_res = (new ours_endo)#array_ (fun () x -> x) arr in
       let t_res = (new theirs_endo)#array_ (fun () x -> x) arr in
       (o_res == arr) = (t_res == arr))

let test_endo_array_change =
  QCheck.Test.make ~name:"endo#visit_array correct value when changed"
    ~count:500
    array_int_gen
    (fun arr ->
       (new ours_endo)#array_ (fun () x -> x + 1) arr
       = (new theirs_endo)#array_ (fun () x -> x + 1) arr)

(* -- reduce lazy -- *)
let test_reduce_lazy =
  QCheck.Test.make ~name:"reduce#visit_lazy_t agrees"
    ~count:500
    lazy_int_gen
    (fun lz ->
       (new ours_reduce)#lazy_ (fun () x -> x) lz
       = (new theirs_reduce)#lazy_ (fun () x -> x) lz)

(* -- mapreduce lazy -- *)
let test_mapreduce_lazy =
  QCheck.Test.make ~name:"mapreduce#visit_lazy_t agrees"
    ~count:500
    lazy_int_gen
    (fun lz ->
       let (ol, os) = (new ours_mapreduce)#lazy_ (fun () x -> (x + 1, x)) lz in
       let (tl, ts) = (new theirs_mapreduce)#lazy_ (fun () x -> (x + 1, x)) lz in
       Lazy.force ol = Lazy.force tl && os = ts)

(* -- mapreduce with non-associative monoid to test fold direction -- *)
let test_mapreduce_list_nonassoc =
  QCheck.Test.make ~name:"mapreduce#visit_list non-assoc monoid agrees"
    ~count:500
    list_int_gen
    (fun xs ->
       (new ours_mapreduce_sub)#list_ (fun () x -> (x, x)) xs
       = (new theirs_mapreduce_sub)#list_ (fun () x -> (x, x)) xs)

(* -- mapreduce result, ref -- *)
let test_mapreduce_result =
  QCheck.Test.make ~name:"mapreduce#visit_result agrees"
    ~count:500
    result_int_gen
    (fun r ->
       (new ours_mapreduce)#result_ (fun () x -> (x + 1, x)) (fun () x -> (x - 1, x)) r
       = (new theirs_mapreduce)#result_ (fun () x -> (x + 1, x)) (fun () x -> (x - 1, x)) r)

let test_mapreduce_ref =
  QCheck.Test.make ~name:"mapreduce#visit_ref agrees"
    ~count:500
    int_gen
    (fun x ->
       let ro = ref x in
       let rt = ref x in
       let (o_ref, os) = (new ours_mapreduce)#ref_ (fun () v -> (v + 1, v)) ro in
       let (t_ref, ts) = (new theirs_mapreduce)#ref_ (fun () v -> (v + 1, v)) rt in
       !o_ref = !t_ref && os = ts)

(* -- iter2: result, ref, lazy, float NaN -- *)
let test_iter2_result =
  QCheck.Test.make ~name:"iter2#visit_result agrees"
    ~count:500
    (QCheck.pair result_int_gen result_int_gen)
    (fun (r1, r2) ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       let or_ = catch_ours_unit (fun () ->
         (new ours_iter2)#result_
           (fun () a b -> ours_acc := (`Ok (a, b)) :: !ours_acc)
           (fun () a b -> ours_acc := (`Err (a, b)) :: !ours_acc)
           r1 r2) in
       let tr_ = catch_theirs_unit (fun () ->
         (new theirs_iter2)#result_
           (fun () a b -> theirs_acc := (`Ok (a, b)) :: !theirs_acc)
           (fun () a b -> theirs_acc := (`Err (a, b)) :: !theirs_acc)
           r1 r2) in
       or_ = tr_ && !ours_acc = !theirs_acc)

let test_iter2_ref =
  QCheck.Test.make ~name:"iter2#visit_ref agrees"
    ~count:500
    (QCheck.pair int_gen int_gen)
    (fun (a, b) ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       (new ours_iter2)#ref_ (fun () x y -> ours_acc := (x, y) :: !ours_acc) (ref a) (ref b);
       (new theirs_iter2)#ref_ (fun () x y -> theirs_acc := (x, y) :: !theirs_acc) (ref a) (ref b);
       !ours_acc = !theirs_acc)

let test_iter2_lazy =
  QCheck.Test.make ~name:"iter2#visit_lazy_t agrees"
    ~count:500
    (QCheck.pair lazy_int_gen lazy_int_gen)
    (fun (lz1, lz2) ->
       let ours_acc = ref [] in
       let theirs_acc = ref [] in
       (new ours_iter2)#lazy_ (fun () a b -> ours_acc := (a, b) :: !ours_acc) lz1 lz2;
       (new theirs_iter2)#lazy_ (fun () a b -> theirs_acc := (a, b) :: !theirs_acc) lz1 lz2;
       !ours_acc = !theirs_acc)

let test_iter2_float_nan =
  QCheck.Test.make ~name:"iter2#visit_float nan agrees (both mismatch)"
    ~count:1
    QCheck.unit
    (fun () ->
       let or_ = catch_ours_unit (fun () -> (new ours_iter2)#float_ nan nan) in
       let tr_ = catch_theirs_unit (fun () -> (new theirs_iter2)#float_ nan nan) in
       or_ = tr_)

(* -- map2: result, ref, lazy -- *)
let test_map2_result =
  QCheck.Test.make ~name:"map2#visit_result agrees"
    ~count:500
    (QCheck.pair result_int_gen result_int_gen)
    (fun (r1, r2) ->
       catch_ours (fun () ->
         (new ours_map2)#result_ (fun () a b -> a + b) (fun () a b -> a * b) r1 r2)
       = catch_theirs (fun () ->
         (new theirs_map2)#result_ (fun () a b -> a + b) (fun () a b -> a * b) r1 r2))

let test_map2_ref =
  QCheck.Test.make ~name:"map2#visit_ref agrees"
    ~count:500
    (QCheck.pair int_gen int_gen)
    (fun (a, b) ->
       let o_res = (new ours_map2)#ref_ (fun () x y -> x + y) (ref a) (ref b) in
       let t_res = (new theirs_map2)#ref_ (fun () x y -> x + y) (ref a) (ref b) in
       !o_res = !t_res)

let test_map2_lazy =
  QCheck.Test.make ~name:"map2#visit_lazy_t agrees"
    ~count:500
    (QCheck.pair lazy_int_gen lazy_int_gen)
    (fun (lz1, lz2) ->
       let o_res = (new ours_map2)#lazy_ (fun () a b -> a + b) lz1 lz2 in
       let t_res = (new theirs_map2)#lazy_ (fun () a b -> a + b) lz1 lz2 in
       Lazy.force o_res = Lazy.force t_res)

(* -- reduce2: array, result, ref, lazy -- *)
let test_reduce2_array =
  QCheck.Test.make ~name:"reduce2#visit_array agrees"
    ~count:500
    (QCheck.pair array_int_gen array_int_gen)
    (fun (a1, a2) ->
       catch_ours (fun () -> (new ours_reduce2)#array_ (fun () a b -> a + b) a1 a2)
       = catch_theirs (fun () -> (new theirs_reduce2)#array_ (fun () a b -> a + b) a1 a2))

let test_reduce2_result =
  QCheck.Test.make ~name:"reduce2#visit_result agrees"
    ~count:500
    (QCheck.pair result_int_gen result_int_gen)
    (fun (r1, r2) ->
       catch_ours (fun () ->
         (new ours_reduce2)#result_ (fun () a b -> a + b) (fun () a b -> a * b) r1 r2)
       = catch_theirs (fun () ->
         (new theirs_reduce2)#result_ (fun () a b -> a + b) (fun () a b -> a * b) r1 r2))

let test_reduce2_ref =
  QCheck.Test.make ~name:"reduce2#visit_ref agrees"
    ~count:500
    (QCheck.pair int_gen int_gen)
    (fun (a, b) ->
       (new ours_reduce2)#ref_ (fun () x y -> x + y) (ref a) (ref b)
       = (new theirs_reduce2)#ref_ (fun () x y -> x + y) (ref a) (ref b))

let test_reduce2_lazy =
  QCheck.Test.make ~name:"reduce2#visit_lazy_t agrees"
    ~count:500
    (QCheck.pair lazy_int_gen lazy_int_gen)
    (fun (lz1, lz2) ->
       (new ours_reduce2)#lazy_ (fun () a b -> a + b) lz1 lz2
       = (new theirs_reduce2)#lazy_ (fun () a b -> a + b) lz1 lz2)

(* -- mapreduce2: array, result, ref, lazy, non-assoc -- *)
let test_mapreduce2_array =
  QCheck.Test.make ~name:"mapreduce2#visit_array agrees"
    ~count:500
    (QCheck.pair array_int_gen array_int_gen)
    (fun (a1, a2) ->
       catch_ours (fun () ->
         (new ours_mapreduce2)#array_ (fun () a b -> (a + b, a * b)) a1 a2)
       = catch_theirs (fun () ->
         (new theirs_mapreduce2)#array_ (fun () a b -> (a + b, a * b)) a1 a2))

let test_mapreduce2_result =
  QCheck.Test.make ~name:"mapreduce2#visit_result agrees"
    ~count:500
    (QCheck.pair result_int_gen result_int_gen)
    (fun (r1, r2) ->
       catch_ours (fun () ->
         (new ours_mapreduce2)#result_
           (fun () a b -> (a + b, a * b))
           (fun () a b -> (a - b, a + b)) r1 r2)
       = catch_theirs (fun () ->
         (new theirs_mapreduce2)#result_
           (fun () a b -> (a + b, a * b))
           (fun () a b -> (a - b, a + b)) r1 r2))

let test_mapreduce2_ref =
  QCheck.Test.make ~name:"mapreduce2#visit_ref agrees"
    ~count:500
    (QCheck.pair int_gen int_gen)
    (fun (a, b) ->
       let (o_ref, os) = (new ours_mapreduce2)#ref_ (fun () x y -> (x + y, x * y)) (ref a) (ref b) in
       let (t_ref, ts) = (new theirs_mapreduce2)#ref_ (fun () x y -> (x + y, x * y)) (ref a) (ref b) in
       !o_ref = !t_ref && os = ts)

let test_mapreduce2_lazy =
  QCheck.Test.make ~name:"mapreduce2#visit_lazy_t agrees"
    ~count:500
    (QCheck.pair lazy_int_gen lazy_int_gen)
    (fun (lz1, lz2) ->
       let (ol, os) = (new ours_mapreduce2)#lazy_ (fun () a b -> (a + b, a * b)) lz1 lz2 in
       let (tl, ts) = (new theirs_mapreduce2)#lazy_ (fun () a b -> (a + b, a * b)) lz1 lz2 in
       Lazy.force ol = Lazy.force tl && os = ts)

let test_mapreduce2_list_nonassoc =
  QCheck.Test.make ~name:"mapreduce2#visit_list non-assoc monoid agrees"
    ~count:500
    (QCheck.pair list_int_gen list_int_gen)
    (fun (xs, ys) ->
       catch_ours (fun () ->
         (new ours_mapreduce2_sub)#list_ (fun () a b -> (a + b, a * b)) xs ys)
       = catch_theirs (fun () ->
         (new theirs_mapreduce2_sub)#list_ (fun () a b -> (a + b, a * b)) xs ys))

(* -- unit_monoid -- *)
let test_unit_monoid =
  QCheck.Test.make ~name:"unit_monoid agrees"
    ~count:1
    QCheck.unit
    (fun () ->
       let module O = struct
         class t = object
           inherit [unit] Ours.unit_monoid
           method plus' (a : unit) (b : unit) : unit = ignore a; ignore b; ()
           method zero' : unit = ()
         end
       end in
       let module T = struct
         class t = object
           inherit [unit] Theirs.unit_monoid
           method plus' (a : unit) (b : unit) : unit = ignore a; ignore b; ()
           method zero' : unit = ()
         end
       end in
       let o = new O.t in
       let t = new T.t in
       o#plus' () () = t#plus' () () && o#zero' = t#zero')

(* -- monoids -- *)
let test_addition_monoid =
  QCheck.Test.make ~name:"addition_monoid agrees"
    ~count:500
    (QCheck.pair int_gen int_gen)
    (fun (a, b) ->
       let module O = struct
         class t = object
           inherit [int] Ours.addition_monoid
           method plus' x y = x + y
           method zero' = 0
         end
       end in
       let module T = struct
         class t = object
           inherit [int] Theirs.addition_monoid
           method plus' x y = x + y
           method zero' = 0
         end
       end in
       let o = new O.t in
       let t = new T.t in
       o#plus' a b = t#plus' a b && o#zero' = t#zero')

(* ------------------------------------------------------------------ *)
(* Run all tests                                                       *)
(* ------------------------------------------------------------------ *)

let () =
  let open Alcotest in
  run "VisitorsRuntime conformance" [
    "array_equal", [
      QCheck_alcotest.to_alcotest test_array_equal;
      QCheck_alcotest.to_alcotest test_array_equal_different;
    ];
    "fail/wrap", [
      QCheck_alcotest.to_alcotest test_fail;
      QCheck_alcotest.to_alcotest test_wrap;
      QCheck_alcotest.to_alcotest test_wrap2;
    ];
    "iter", [
      QCheck_alcotest.to_alcotest test_iter_list;
      QCheck_alcotest.to_alcotest test_iter_option;
      QCheck_alcotest.to_alcotest test_iter_array;
      QCheck_alcotest.to_alcotest test_iter_result;
      QCheck_alcotest.to_alcotest test_iter_lazy;
    ];
    "map", [
      QCheck_alcotest.to_alcotest test_map_list;
      QCheck_alcotest.to_alcotest test_map_option;
      QCheck_alcotest.to_alcotest test_map_array;
      QCheck_alcotest.to_alcotest test_map_result;
      QCheck_alcotest.to_alcotest test_map_int;
      QCheck_alcotest.to_alcotest test_map_bool;
      QCheck_alcotest.to_alcotest test_map_lazy;
      QCheck_alcotest.to_alcotest test_map_lazy_deferred;
    ];
    "endo", [
      QCheck_alcotest.to_alcotest test_endo_identity_list;
      QCheck_alcotest.to_alcotest test_endo_change_list;
      QCheck_alcotest.to_alcotest test_endo_identity_option;
      QCheck_alcotest.to_alcotest test_endo_identity_result;
      QCheck_alcotest.to_alcotest test_endo_lazy_identity;
      QCheck_alcotest.to_alcotest test_endo_lazy_change;
      QCheck_alcotest.to_alcotest test_endo_lazy_forces_eagerly;
      QCheck_alcotest.to_alcotest test_endo_array_identity;
      QCheck_alcotest.to_alcotest test_endo_array_change;
    ];
    "reduce", [
      QCheck_alcotest.to_alcotest test_reduce_list;
      QCheck_alcotest.to_alcotest test_reduce_option;
      QCheck_alcotest.to_alcotest test_reduce_array;
      QCheck_alcotest.to_alcotest test_reduce_result;
      QCheck_alcotest.to_alcotest test_reduce_lazy;
    ];
    "mapreduce", [
      QCheck_alcotest.to_alcotest test_mapreduce_list;
      QCheck_alcotest.to_alcotest test_mapreduce_option;
      QCheck_alcotest.to_alcotest test_mapreduce_array;
      QCheck_alcotest.to_alcotest test_mapreduce_lazy;
      QCheck_alcotest.to_alcotest test_mapreduce_list_nonassoc;
      QCheck_alcotest.to_alcotest test_mapreduce_result;
      QCheck_alcotest.to_alcotest test_mapreduce_ref;
    ];
    "iter2", [
      QCheck_alcotest.to_alcotest test_iter2_list;
      QCheck_alcotest.to_alcotest test_iter2_int_mismatch;
      QCheck_alcotest.to_alcotest test_iter2_array;
      QCheck_alcotest.to_alcotest test_iter2_result;
      QCheck_alcotest.to_alcotest test_iter2_ref;
      QCheck_alcotest.to_alcotest test_iter2_lazy;
      QCheck_alcotest.to_alcotest test_iter2_float_nan;
    ];
    "map2", [
      QCheck_alcotest.to_alcotest test_map2_list;
      QCheck_alcotest.to_alcotest test_map2_option;
      QCheck_alcotest.to_alcotest test_map2_int;
      QCheck_alcotest.to_alcotest test_map2_array;
      QCheck_alcotest.to_alcotest test_map2_result;
      QCheck_alcotest.to_alcotest test_map2_ref;
      QCheck_alcotest.to_alcotest test_map2_lazy;
    ];
    "reduce2", [
      QCheck_alcotest.to_alcotest test_reduce2_list;
      QCheck_alcotest.to_alcotest test_reduce2_option;
      QCheck_alcotest.to_alcotest test_reduce2_array;
      QCheck_alcotest.to_alcotest test_reduce2_result;
      QCheck_alcotest.to_alcotest test_reduce2_ref;
      QCheck_alcotest.to_alcotest test_reduce2_lazy;
    ];
    "mapreduce2", [
      QCheck_alcotest.to_alcotest test_mapreduce2_list;
      QCheck_alcotest.to_alcotest test_mapreduce2_option;
      QCheck_alcotest.to_alcotest test_mapreduce2_array;
      QCheck_alcotest.to_alcotest test_mapreduce2_result;
      QCheck_alcotest.to_alcotest test_mapreduce2_ref;
      QCheck_alcotest.to_alcotest test_mapreduce2_lazy;
      QCheck_alcotest.to_alcotest test_mapreduce2_list_nonassoc;
    ];
    "monoids", [
      QCheck_alcotest.to_alcotest test_addition_monoid;
      QCheck_alcotest.to_alcotest test_unit_monoid;
    ];
  ]
