/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Robert Y. Lewis
-/

import ring_theory.witt_vector.structure_polynomial

/-!
# Witt vectors

In this file we define the type of `p`-typical Witt vectors and ring operations on it.
The ring axioms are verified in `ring_theory/witt_vector/basic.lean`.

For a fixed commutative ring `R` and prime `p`,
a Witt vector `x : π R` is an infinite sequence `β β R` of elements of `R`.
However, the ring operations `+` and `*` are not defined in the obvious component-wise way.
Instead, these operations are defined via certain polynomials
using the machinery in `structure_polynomial.lean`.
The `n`th value of the sum of two Witt vectors can depend on the `0`-th through `n`th values
of the summands. This effectively simulates a βcarryingβ operation.

## Main definitions

* `witt_vector p R`: the type of `p`-typical Witt vectors with coefficients in `R`.
* `witt_vector.coeff x n`: projects the `n`th value of the Witt vector `x`.

## Notation

We use notation `π R`, entered `\bbW`, for the Witt vectors over `R`.

## References

* [Hazewinkel, *Witt Vectors*][Haze09]

* [Commelin and Lewis, *Formalizing the Ring of Witt Vectors*][CL21]
-/

noncomputable theory

/-- `witt_vector p R` is the ring of `p`-typical Witt vectors over the commutative ring `R`,
where `p` is a prime number.

If `p` is invertible in `R`, this ring is isomorphic to `β β R` (the product of `β` copies of `R`).
If `R` is a ring of characteristic `p`, then `witt_vector p R` is a ring of characteristic `0`.
The canonical example is `witt_vector p (zmod p)`,
which is isomorphic to the `p`-adic integers `β€_[p]`. -/
structure witt_vector (p : β) (R : Type*) :=
mk [] :: (coeff : β β R)

variables {p : β}

/- We cannot make this `localized` notation, because the `p` on the RHS doesn't occur on the left
Hiding the `p` in the notation is very convenient, so we opt for repeating the `local notation`
in other files that use Witt vectors. -/
local notation `π` := witt_vector p -- type as `\bbW`

namespace witt_vector

variables (p) {R : Type*}

/-- Construct a Witt vector `mk p x : π R` from a sequence `x` of elements of `R`. -/
add_decl_doc witt_vector.mk

/--
`x.coeff n` is the `n`th coefficient of the Witt vector `x`.

This concept does not have a standard name in the literature.
-/
add_decl_doc witt_vector.coeff

@[ext] lemma ext {x y : π R} (h : β n, x.coeff n = y.coeff n) : x = y :=
begin
  cases x,
  cases y,
  simp only at h,
  simp [function.funext_iff, h]
end

lemma ext_iff {x y : π R} : x = y β β n, x.coeff n = y.coeff n :=
β¨Ξ» h n, by rw h, extβ©

lemma coeff_mk (x : β β R) :
  (mk p x).coeff = x := rfl

/- These instances are not needed for the rest of the development,
but it is interesting to establish early on that `witt_vector p` is a lawful functor. -/
instance : functor (witt_vector p) :=
{ map := Ξ» Ξ± Ξ² f v, mk p (f β v.coeff),
  map_const := Ξ» Ξ± Ξ² a v, mk p (Ξ» _, a) }

instance : is_lawful_functor (witt_vector p) :=
{ map_const_eq := Ξ» Ξ± Ξ², rfl,
  id_map := Ξ» Ξ± β¨v, _β©, rfl,
  comp_map := Ξ» Ξ± Ξ² Ξ³ f g v, rfl }

variables (p) [hp : fact p.prime] [comm_ring R]
include hp
open mv_polynomial

section ring_operations

/-- The polynomials used for defining the element `0` of the ring of Witt vectors. -/
def witt_zero : β β mv_polynomial (fin 0 Γ β) β€ :=
witt_structure_int p 0

/-- The polynomials used for defining the element `1` of the ring of Witt vectors. -/
def witt_one : β β mv_polynomial (fin 0 Γ β) β€ :=
witt_structure_int p 1

/-- The polynomials used for defining the addition of the ring of Witt vectors. -/
def witt_add : β β mv_polynomial (fin 2 Γ β) β€ :=
witt_structure_int p (X 0 + X 1)

/-- The polynomials used for describing the subtraction of the ring of Witt vectors. -/
def witt_sub : β β mv_polynomial (fin 2 Γ β) β€ :=
witt_structure_int p (X 0 - X 1)

/-- The polynomials used for defining the multiplication of the ring of Witt vectors. -/
def witt_mul : β β mv_polynomial (fin 2 Γ β) β€ :=
witt_structure_int p (X 0 * X 1)

/-- The polynomials used for defining the negation of the ring of Witt vectors. -/
def witt_neg : β β mv_polynomial (fin 1 Γ β) β€ :=
witt_structure_int p (-X 0)

variable {p}
omit hp

/-- An auxiliary definition used in `witt_vector.eval`.
Evaluates a polynomial whose variables come from the disjoint union of `k` copies of `β`,
with a curried evaluation `x`.
This can be defined more generally but we use only a specific instance here. -/
def peval {k : β} (Ο : mv_polynomial (fin k Γ β) β€) (x : fin k β β β R) : R :=
aeval (function.uncurry x) Ο

/--
Let `Ο` be a family of polynomials, indexed by natural numbers, whose variables come from the
disjoint union of `k` copies of `β`, and let `xα΅’` be a Witt vector for `0 β€ i < k`.

`eval Ο x` evaluates `Ο` mapping the variable `X_(i, n)` to the `n`th coefficient of `xα΅’`.

Instantiating `Ο` with certain polynomials defined in `structure_polynomial.lean` establishes the
ring operations on `π R`. For example, `witt_vector.witt_add` is such a `Ο` with `k = 2`;
evaluating this at `(xβ, xβ)` gives us the sum of two Witt vectors `xβ + xβ`.
-/
def eval {k : β} (Ο : β β mv_polynomial (fin k Γ β) β€) (x : fin k β π R) : π R :=
mk p $ Ξ» n, peval (Ο n) $ Ξ» i, (x i).coeff

variables (R) [fact p.prime]

instance : has_zero (π R) :=
β¨eval (witt_zero p) ![]β©

instance : inhabited (π R) := β¨0β©

instance : has_one (π R) :=
β¨eval (witt_one p) ![]β©

instance : has_add (π R) :=
β¨Ξ» x y, eval (witt_add p) ![x, y]β©

instance : has_sub (π R) :=
β¨Ξ» x y, eval (witt_sub p) ![x, y]β©

instance : has_mul (π R) :=
β¨Ξ» x y, eval (witt_mul p) ![x, y]β©

instance : has_neg (π R) :=
β¨Ξ» x, eval (witt_neg p) ![x]β©

end ring_operations

section witt_structure_simplifications

@[simp] lemma witt_zero_eq_zero (n : β) : witt_zero p n = 0 :=
begin
  apply mv_polynomial.map_injective (int.cast_ring_hom β) int.cast_injective,
  simp only [witt_zero, witt_structure_rat, bindβ, aeval_zero',
    constant_coeff_X_in_terms_of_W, ring_hom.map_zero,
    alg_hom.map_zero, map_witt_structure_int],
end

@[simp] lemma witt_one_zero_eq_one : witt_one p 0 = 1 :=
begin
  apply mv_polynomial.map_injective (int.cast_ring_hom β) int.cast_injective,
  simp only [witt_one, witt_structure_rat, X_in_terms_of_W_zero, alg_hom.map_one,
    ring_hom.map_one, bindβ_X_right, map_witt_structure_int]
end

@[simp] lemma witt_one_pos_eq_zero (n : β) (hn : 0 < n) : witt_one p n = 0 :=
begin
  apply mv_polynomial.map_injective (int.cast_ring_hom β) int.cast_injective,
  simp only [witt_one, witt_structure_rat, ring_hom.map_zero, alg_hom.map_one,
    ring_hom.map_one, map_witt_structure_int],
  revert hn, apply nat.strong_induction_on n, clear n,
  intros n IH hn,
  rw X_in_terms_of_W_eq,
  simp only [alg_hom.map_mul, alg_hom.map_sub, alg_hom.map_sum, alg_hom.map_pow,
    bindβ_X_right, bindβ_C_right],
  rw [sub_mul, one_mul],
  rw [finset.sum_eq_single 0],
  { simp only [inv_of_eq_inv, one_mul, inv_powβ, tsub_zero, ring_hom.map_one, pow_zero],
    simp only [one_pow, one_mul, X_in_terms_of_W_zero, sub_self, bindβ_X_right] },
  { intros i hin hi0,
    rw [finset.mem_range] at hin,
    rw [IH _ hin (nat.pos_of_ne_zero hi0), zero_pow (pow_pos hp.1.pos _), mul_zero], },
  { rw finset.mem_range, intro, contradiction }
end

@[simp] lemma witt_add_zero : witt_add p 0 = X (0,0) + X (1,0) :=
begin
  apply mv_polynomial.map_injective (int.cast_ring_hom β) int.cast_injective,
  simp only [witt_add, witt_structure_rat, alg_hom.map_add, ring_hom.map_add,
    rename_X, X_in_terms_of_W_zero, map_X,
     witt_polynomial_zero, bindβ_X_right, map_witt_structure_int],
end

@[simp] lemma witt_sub_zero : witt_sub p 0 = X (0,0) - X (1,0) :=
begin
  apply mv_polynomial.map_injective (int.cast_ring_hom β) int.cast_injective,
  simp only [witt_sub, witt_structure_rat, alg_hom.map_sub, ring_hom.map_sub,
    rename_X, X_in_terms_of_W_zero, map_X,
     witt_polynomial_zero, bindβ_X_right, map_witt_structure_int],
end

@[simp] lemma witt_mul_zero : witt_mul p 0 = X (0,0) * X (1,0) :=
begin
  apply mv_polynomial.map_injective (int.cast_ring_hom β) int.cast_injective,
  simp only [witt_mul, witt_structure_rat, rename_X, X_in_terms_of_W_zero, map_X,
    witt_polynomial_zero, ring_hom.map_mul,
    bindβ_X_right, alg_hom.map_mul, map_witt_structure_int]
end

@[simp] lemma witt_neg_zero : witt_neg p 0 = - X (0,0) :=
begin
  apply mv_polynomial.map_injective (int.cast_ring_hom β) int.cast_injective,
  simp only [witt_neg, witt_structure_rat, rename_X, X_in_terms_of_W_zero, map_X,
    witt_polynomial_zero, ring_hom.map_neg,
   alg_hom.map_neg, bindβ_X_right, map_witt_structure_int]
end

@[simp] lemma constant_coeff_witt_add (n : β) :
  constant_coeff (witt_add p n) = 0 :=
begin
  apply constant_coeff_witt_structure_int p _ _ n,
  simp only [add_zero, ring_hom.map_add, constant_coeff_X],
end

@[simp] lemma constant_coeff_witt_sub (n : β) :
  constant_coeff (witt_sub p n) = 0 :=
begin
  apply constant_coeff_witt_structure_int p _ _ n,
  simp only [sub_zero, ring_hom.map_sub, constant_coeff_X],
end

@[simp] lemma constant_coeff_witt_mul (n : β) :
  constant_coeff (witt_mul p n) = 0 :=
begin
  apply constant_coeff_witt_structure_int p _ _ n,
  simp only [mul_zero, ring_hom.map_mul, constant_coeff_X],
end

@[simp] lemma constant_coeff_witt_neg (n : β) :
  constant_coeff (witt_neg p n) = 0 :=
begin
  apply constant_coeff_witt_structure_int p _ _ n,
  simp only [neg_zero, ring_hom.map_neg, constant_coeff_X],
end

end witt_structure_simplifications

section coeff

variables (p R)

@[simp] lemma zero_coeff (n : β) : (0 : π R).coeff n = 0 :=
show (aeval _ (witt_zero p n) : R) = 0,
by simp only [witt_zero_eq_zero, alg_hom.map_zero]

@[simp] lemma one_coeff_zero : (1 : π R).coeff 0 = 1 :=
show (aeval _ (witt_one p 0) : R) = 1,
by simp only [witt_one_zero_eq_one, alg_hom.map_one]

@[simp] lemma one_coeff_eq_of_pos (n : β) (hn : 0 < n) : coeff (1 : π R) n = 0 :=
show (aeval _ (witt_one p n) : R) = 0,
by simp only [hn, witt_one_pos_eq_zero, alg_hom.map_zero]

variables {p R}

omit hp
@[simp]
lemma v2_coeff {p' R'} (x y : witt_vector p' R') (i : fin 2) :
  (![x, y] i).coeff = ![x.coeff, y.coeff] i :=
by fin_cases i; simp
include hp

lemma add_coeff (x y : π R) (n : β) :
  (x + y).coeff n = peval (witt_add p n) ![x.coeff, y.coeff] :=
by simp [(+), eval]

lemma sub_coeff (x y : π R) (n : β) :
  (x - y).coeff n = peval (witt_sub p n) ![x.coeff, y.coeff] :=
by simp [has_sub.sub, eval]

lemma mul_coeff (x y : π R) (n : β) :
  (x * y).coeff n = peval (witt_mul p n) ![x.coeff, y.coeff] :=
by simp [(*), eval]

lemma neg_coeff (x : π R) (n : β) :
  (-x).coeff n = peval (witt_neg p n) ![x.coeff] :=
by simp [has_neg.neg, eval, matrix.cons_fin_one]

lemma add_coeff_zero (x y : π R) : (x + y).coeff 0 = x.coeff 0 + y.coeff 0 :=
by simp [add_coeff, peval]

lemma mul_coeff_zero (x y : π R) : (x * y).coeff 0 = x.coeff 0 * y.coeff 0 :=
by simp [mul_coeff, peval]

end coeff

lemma witt_add_vars (n : β) :
  (witt_add p n).vars β finset.univ.product (finset.range (n + 1)) :=
witt_structure_int_vars _ _ _

lemma witt_sub_vars (n : β) :
  (witt_sub p n).vars β finset.univ.product (finset.range (n + 1)) :=
witt_structure_int_vars _ _ _

lemma witt_mul_vars (n : β) :
  (witt_mul p n).vars β finset.univ.product (finset.range (n + 1)) :=
witt_structure_int_vars _ _ _

lemma witt_neg_vars (n : β) :
  (witt_neg p n).vars β finset.univ.product (finset.range (n + 1)) :=
witt_structure_int_vars _ _ _

end witt_vector
