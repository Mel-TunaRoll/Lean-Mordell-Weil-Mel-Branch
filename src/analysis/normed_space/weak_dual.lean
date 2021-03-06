/-
Copyright (c) 2021 Kalle KytΓΆlΓ€. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kalle KytΓΆlΓ€
-/
import topology.algebra.module.weak_dual
import analysis.normed_space.dual
import analysis.normed_space.operator_norm

/-!
# Weak dual of normed space

Let `E` be a normed space over a field `π`. This file is concerned with properties of the weak-*
topology on the dual of `E`. By the dual, we mean either of the type synonyms
`normed_space.dual π E` or `weak_dual π E`, depending on whether it is viewed as equipped with its
usual operator norm topology or the weak-* topology.

It is shown that the canonical mapping `normed_space.dual π E β weak_dual π E` is continuous, and
as a consequence the weak-* topology is coarser than the topology obtained from the operator norm
(dual norm).

The file is a stub, some TODOs below.

## Main definitions

The main definitions concern the canonical mapping `dual π E β weak_dual π E`.

* `normed_space.dual.to_weak_dual` and `weak_dual.to_normed_dual`: Linear equivalences from
  `dual π E` to `weak_dual π E` and in the converse direction.
* `normed_space.dual.continuous_linear_map_to_weak_dual`: A continuous linear mapping from
  `dual π E` to `weak_dual π E` (same as `normed_space.dual.to_weak_dual` but different bundled
  data).

## Main results

The first main result concerns the comparison of the operator norm topology on `dual π E` and the
weak-* topology on (its type synonym) `weak_dual π E`:
* `dual_norm_topology_le_weak_dual_topology`: The weak-* topology on the dual of a normed space is
  coarser (not necessarily strictly) than the operator norm topology.

TODOs:
* Add that in finite dimensions, the weak-* topology and the dual norm topology coincide.
* Add that in infinite dimensions, the weak-* topology is strictly coarser than the dual norm
  topology.
* Add Banach-Alaoglu theorem (general version maybe in `topology.algebra.module.weak_dual`).
* Add metrizability of the dual unit ball (more generally bounded subsets) of `weak_dual π E`
  under the assumption of separability of `E`. Sequential Banach-Alaoglu theorem would then follow
  from the general one.

## Notations

No new notation is introduced.

## Implementation notes

Weak-* topology is defined generally in the file `topology.algebra.module.weak_dual`.

When `E` is a normed space, the duals `dual π E` and `weak_dual π E` are type synonyms with
different topology instances.

## References

* https://en.wikipedia.org/wiki/Weak_topology#Weak-*_topology

## Tags

weak-star, weak dual

-/

noncomputable theory
open filter
open_locale topological_space

section weak_star_topology_for_duals_of_normed_spaces
/-!
### Weak star topology on duals of normed spaces
In this section, we prove properties about the weak-* topology on duals of normed spaces.
We prove in particular that the canonical mapping `dual π E β weak_dual π E` is continuous,
i.e., that the weak-* topology is coarser (not necessarily strictly) than the topology given
by the dual-norm (i.e. the operator-norm).
-/

open normed_space

variables {π : Type*} [nondiscrete_normed_field π]
variables {E : Type*} [normed_group E] [normed_space π E]

/-- For normed spaces `E`, there is a canonical map `dual π E β weak_dual π E` (the "identity"
mapping). It is a linear equivalence. -/
def normed_space.dual.to_weak_dual : dual π E ββ[π] weak_dual π E :=
linear_equiv.refl π (E βL[π] π)

/-- For normed spaces `E`, there is a canonical map `weak_dual π E β dual π E` (the "identity"
mapping). It is a linear equivalence. Here it is implemented as the inverse of the linear
equivalence `normed_space.dual.to_weak_dual` in the other direction. -/
def weak_dual.to_normed_dual : weak_dual π E ββ[π] dual π E :=
normed_space.dual.to_weak_dual.symm

@[simp] lemma weak_dual.coe_to_fun_eq_normed_coe_to_fun (x' : dual π E) :
  (x'.to_weak_dual : E β π) = x' := rfl

namespace normed_space.dual

@[simp] lemma to_weak_dual_eq_iff (x' y' : dual π E) :
  x'.to_weak_dual = y'.to_weak_dual β x' = y' :=
to_weak_dual.injective.eq_iff

@[simp] lemma _root_.weak_dual.to_normed_dual_eq_iff (x' y' : weak_dual π E) :
  x'.to_normed_dual = y'.to_normed_dual β x' = y' :=
weak_dual.to_normed_dual.injective.eq_iff

theorem to_weak_dual_continuous :
  continuous (Ξ» (x' : dual π E), x'.to_weak_dual) :=
begin
  apply weak_dual.continuous_of_continuous_eval,
  intros z,
  exact (inclusion_in_double_dual π E z).continuous,
end

/-- For a normed space `E`, according to `to_weak_dual_continuous` the "identity mapping"
`dual π E β weak_dual π E` is continuous. This definition implements it as a continuous linear
map. -/
def continuous_linear_map_to_weak_dual : dual π E βL[π] weak_dual π E :=
{ cont := to_weak_dual_continuous, .. to_weak_dual, }

/-- The weak-star topology is coarser than the dual-norm topology. -/
theorem dual_norm_topology_le_weak_dual_topology :
  (by apply_instance : topological_space (dual π E)) β€
    (by apply_instance : topological_space (weak_dual π E)) :=
begin
  refine continuous.le_induced _,
  apply continuous_pi_iff.mpr,
  intros z,
  exact (inclusion_in_double_dual π E z).continuous,
end

end normed_space.dual

namespace weak_dual

lemma to_normed_dual.preimage_closed_unit_ball :
  (to_normed_dual β»ΒΉ' metric.closed_ball (0 : dual π E) 1) =
    {x' : weak_dual π E | β₯ x'.to_normed_dual β₯ β€ 1} :=
begin
  have eq : metric.closed_ball (0 : dual π E) 1 = {x' : dual π E | β₯ x' β₯ β€ 1},
  { ext x', simp only [dist_zero_right, metric.mem_closed_ball, set.mem_set_of_eq], },
  rw eq,
  exact set.preimage_set_of_eq,
end

variables (π)

/-- The polar set `polar π s` of `s : set E` seen as a subset of the dual of `E` with the
weak-star topology is `weak_dual.polar π s`. -/
def polar (s : set E) : set (weak_dual π E) := to_normed_dual β»ΒΉ' (polar π s)

end weak_dual

end weak_star_topology_for_duals_of_normed_spaces

section polar_sets_in_weak_dual

open metric set normed_space

variables {π : Type*} [nondiscrete_normed_field π]
variables {E : Type*} [normed_group E] [normed_space π E]

/-- The polar `polar π s` of a set `s : E` is a closed subset when the weak star topology
is used, i.e., when `polar π s` is interpreted as a subset of `weak_dual π E`. -/
lemma weak_dual.is_closed_polar (s : set E) : is_closed (weak_dual.polar π s) :=
begin
  rw [weak_dual.polar, polar_eq_Inter, preimage_Interβ],
  apply is_closed_bInter,
  intros z hz,
  rw set.preimage_set_of_eq,
  have eq : {x' : weak_dual π E | β₯weak_dual.to_normed_dual x' zβ₯ β€ 1}
    = (Ξ» (x' : weak_dual π E), β₯x' zβ₯)β»ΒΉ' (Iic 1) := by refl,
  rw eq,
  refine is_closed.preimage _ (is_closed_Iic),
  apply continuous.comp continuous_norm (weak_dual.eval_continuous _ _ z),
end

end polar_sets_in_weak_dual
