# visitors-cleanroom

A clean-room implementation of the `VisitorsRuntime` module from
[visitors](https://gitlab.inria.fr/fpottier/visitors), the OCaml PPX
deriver for generating visitor-pattern classes.

The upstream `visitors` package ships a PPX preprocessor (`visitors.ppx`)
and a small runtime library (`visitors.runtime`) whose sole module is
`VisitorsRuntime`. PPX-generated visitor classes inherit from base
classes in `VisitorsRuntime`. This project provides a
independently-written replacement for that runtime module so that it can
be distributed alongside compiled binaries without depending on the
upstream runtime's source code.

## Project layout

```
lib/
  visitorsRuntime.ml    -- clean-room implementation
  visitorsRuntime.mli   -- public interface (with design-contract docs)
  dune

bench/
  bench.ml              -- bechamel benchmarks + stack depth tests
  dune

test/
  test_visitors_runtime.ml  -- property-based tests: base class methods
  test_traversal.ml         -- property-based tests: PPX-generated visitor traversal
  test_types.ml             -- shared ADT definitions used by traversal tests
  types_ours/               -- compiles test_types.ml against our runtime
  types_theirs/             -- compiles test_types.ml against the upstream runtime
  upstream/                 -- thin wrapper exposing the upstream runtime as
                               Upstream_visitors_runtime to avoid name collisions
  dune
```

## Prerequisites

- OCaml 5.x (tested with 5.3.0)
- opam packages: `visitors`, `qcheck-core`, `qcheck-alcotest`, `alcotest`
- For benchmarks: `bechamel`

Install dependencies:

```sh
opam install visitors qcheck-core qcheck-alcotest alcotest bechamel
```

## Building

```sh
dune build
```

This builds the `visitorsRuntime` library under `lib/` and both test
executables.

## Running tests

```sh
dune test
```

This runs two test suites:

1. **VisitorsRuntime conformance** (68 tests) -- exercises every base
   class method (`iter`, `map`, `endo`, `reduce`, `mapreduce`, `iter2`,
   `map2`, `reduce2`, `mapreduce2`) and utility function directly,
   comparing our output against the upstream `visitors.runtime` on
   random inputs. Includes `visit_lazy_t` identity/forcing semantics,
   non-associative monoid fold-direction tests, `float` NaN edge
   cases, and `unit_monoid`.

2. **Visitor traversal conformance** (24 tests) -- defines several ADTs
   (recursive trees, mutually-recursive expression/statement types,
   records, enums), derives visitors via the `visitors` PPX against
   both runtimes, and verifies that full visitor traversals produce
   identical results. Includes a non-associative monoid test that
   catches fold-direction bugs.

All tests use [QCheck](https://github.com/c-cube/qcheck) for
property-based / randomized testing.

## Benchmarks

```sh
dune exec bench/bench.exe
```

Runs comparative benchmarks (via [bechamel](https://github.com/mirage/bechamel))
of our implementation against upstream on trees, expressions, and lists
of varying sizes. Also includes stack-depth conformance tests on 200k
element lists to verify that non-tail-recursive `visit_list` methods
behave identically to upstream.

## Using the library

To use this runtime in place of the upstream `visitors.runtime`, depend
on the `visitorsRuntime` library in your dune file:

```dune
(library
 (name my_lib)
 (libraries visitorsRuntime)
 (preprocess (pps visitors.ppx)))
```

The PPX-generated code references `VisitorsRuntime` by module name, and
dune will resolve it to this clean-room implementation.

## Implementation notes

The `.mli` file contains detailed documentation of the semantic
contracts that an implementation must satisfy. Key subtleties:

- **`visit_list` must use recursive self-calls** (`self#visit_list`),
  not `List.iter` / `List.map`. PPX-generated subclasses may override
  `visit_list`, and standard-library delegation would bypass those
  overrides.

- **`endo#visit_lazy_t` must eagerly force** the suspension and
  preserve physical identity (`==`) when the value is unchanged. A
  naive `lazy (f env (Lazy.force lz))` implementation is incorrect: it
  defers forcing and never preserves the original suspension.

- **`mapreduce#visit_list` must use a right fold**, processing the head
  then recursing on the tail then combining with `self#plus`. A left
  fold reverses the association order of `plus`, which produces
  different results for non-associative monoids.

- **`array_equal` asserts equal length** rather than returning `false`
  for mismatched lengths.
