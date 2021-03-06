/-
Copyright (c) 2021 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux
-/
import analysis.normed_space.operator_norm
import topology.metric_space.baire
import topology.algebra.module.basic
/-!
# The Banach-Steinhaus theorem: Uniform Boundedness Principle

Herein we prove the Banach-Steinhaus theorem: any collection of bounded linear maps
from a Banach space into a normed space which is pointwise bounded is uniformly bounded.

## TODO

For now, we only prove the standard version by appeal to the Baire category theorem.
Much more general versions exist (in particular, for maps from barrelled spaces to locally
convex spaces), but these are not yet in `mathlib`.
-/

open set

variables
{E F ð ðâ : Type*}
[semi_normed_group E] [semi_normed_group F]
[nondiscrete_normed_field ð] [nondiscrete_normed_field ðâ]
[normed_space ð E] [normed_space ðâ F]
{Ïââ : ð â+* ðâ} [ring_hom_isometric Ïââ]


/-- This is the standard Banach-Steinhaus theorem, or Uniform Boundedness Principle.
If a family of continuous linear maps from a Banach space into a normed space is pointwise
bounded, then the norms of these linear maps are uniformly bounded. -/
theorem banach_steinhaus {Î¹ : Type*} [complete_space E] {g : Î¹ â E âSL[Ïââ] F}
  (h : â x, â C, â i, â¥g i xâ¥ â¤ C) :
  â C', â i, â¥g iâ¥ â¤ C' :=
begin
  /- sequence of subsets consisting of those `x : E` with norms `â¥g i xâ¥` bounded by `n` -/
  let e : â â set E := Î» n, (â i : Î¹, { x : E | â¥g i xâ¥ â¤ n }),
  /- each of these sets is closed -/
  have hc : â n : â, is_closed (e n), from Î» i, is_closed_Inter (Î» i,
    is_closed_le (continuous.norm (g i).cont) continuous_const),
  /- the union is the entire space; this is where we use `h` -/
  have hU : (â n : â, e n) = univ,
  { refine eq_univ_of_forall (Î» x, _),
    cases h x with C hC,
    obtain â¨m, hmâ© := exists_nat_ge C,
    exact â¨e m, mem_range_self m, mem_Inter.mpr (Î» i, le_trans (hC i) hm)â© },
  /- apply the Baire category theorem to conclude that for some `m : â`, `e m` contains some `x` -/
  rcases nonempty_interior_of_Union_of_closed hc hU with â¨m, x, hxâ©,
  rcases metric.is_open_iff.mp is_open_interior x hx with â¨Îµ, Îµ_pos, hÎµâ©,
  obtain â¨k, hkâ© := normed_field.exists_one_lt_norm ð,
  /- show all elements in the ball have norm bounded by `m` after applying any `g i` -/
  have real_norm_le : â z : E, z â metric.ball x Îµ â â i : Î¹, â¥g i zâ¥ â¤ m,
  { intros z hz i,
    replace hz := mem_Inter.mp (interior_Inter_subset _ (hÎµ hz)) i,
    apply interior_subset hz },
  have Îµk_pos : 0 < Îµ / â¥kâ¥ := div_pos Îµ_pos (zero_lt_one.trans hk),
  refine â¨(m + m : â) / (Îµ / â¥kâ¥), Î» i, continuous_linear_map.op_norm_le_of_shell Îµ_pos _ hk _â©,
  { exact div_nonneg (nat.cast_nonneg _) Îµk_pos.le },
  intros y le_y y_lt,
  calc â¥g i yâ¥
      = â¥g i (y + x) - g i xâ¥   : by rw [continuous_linear_map.map_add, add_sub_cancel]
  ... â¤ â¥g i (y + x)â¥ + â¥g i xâ¥ : norm_sub_le _ _
  ... â¤ m + m : add_le_add (real_norm_le (y + x) (by rwa [add_comm, add_mem_ball_iff_norm]) i)
          (real_norm_le x (metric.mem_ball_self Îµ_pos) i)
  ... = (m + m : â) : (m.cast_add m).symm
  ... â¤ (m + m : â) * (â¥yâ¥ / (Îµ / â¥kâ¥))
      : le_mul_of_one_le_right (nat.cast_nonneg _)
          ((one_le_div $ div_pos Îµ_pos (zero_lt_one.trans hk)).2 le_y)
  ... = (m + m : â) / (Îµ / â¥kâ¥) * â¥yâ¥ : (mul_comm_div' _ _ _).symm,
end

open_locale ennreal
open ennreal

/-- This version of Banach-Steinhaus is stated in terms of suprema of `ââ¥â¬â¥â : ââ¥0â`
for convenience. -/
theorem banach_steinhaus_supr_nnnorm {Î¹ : Type*} [complete_space E] {g : Î¹ â E âSL[Ïââ] F}
  (h : â x, (â¨ i, ââ¥g i xâ¥â) < â) :
  (â¨ i, ââ¥g iâ¥â) < â :=
begin
  have h' : â x : E, â C : â, â i : Î¹, â¥g i xâ¥ â¤ C,
  { intro x,
    rcases lt_iff_exists_coe.mp (h x) with â¨p, hpâ, _â©,
    refine â¨p, (Î» i, _)â©,
    exact_mod_cast
    calc (â¥g i xâ¥â : ââ¥0â) â¤ â¨ j,  â¥g j xâ¥â : le_supr _ i
      ...                  = p              : hpâ },
  cases banach_steinhaus h' with C' hC',
  refine (supr_le $ Î» i, _).trans_lt (@coe_lt_top C'.to_nnreal),
  rw ânorm_to_nnreal,
  exact coe_mono (real.to_nnreal_le_to_nnreal $ hC' i),
end

open_locale topological_space
open filter

/-- Given a *sequence* of continuous linear maps which converges pointwise and for which the
domain is complete, the Banach-Steinhaus theorem is used to guarantee that the limit map
is a *continuous* linear map as well. -/
def continuous_linear_map_of_tendsto [complete_space E] [t2_space F]
  (g : â â E âSL[Ïââ] F) {f : E â F} (h : tendsto (Î» n x, g n x) at_top (ð f)) :
  E âSL[Ïââ] F :=
{ to_fun := f,
  map_add' := (linear_map_of_tendsto _ _ h).map_add',
  map_smul' := (linear_map_of_tendsto _ _ h).map_smul',
  cont :=
    begin
      /- show that the maps are pointwise bounded and apply `banach_steinhaus`-/
      have h_point_bdd : â x : E, â C : â, â n : â, â¥g n xâ¥ â¤ C,
      { intro x,
        rcases cauchy_seq_bdd (tendsto_pi_nhds.mp h x).cauchy_seq with â¨C, C_pos, hCâ©,
        refine â¨C + â¥g 0 xâ¥, (Î» n, _)â©,
        simp_rw dist_eq_norm at hC,
        calc â¥g n xâ¥ â¤ â¥g 0 xâ¥ + â¥g n x - g 0 xâ¥ : norm_le_insert' _ _
          ...        â¤ C + â¥g 0 xâ¥               : by linarith [hC n 0] },
      cases banach_steinhaus h_point_bdd with C' hC',
      /- show the uniform bound from `banach_steinhaus` is a norm bound of the limit map
         by allowing "an `Îµ` of room." -/
      refine linear_map.continuous_of_bound (linear_map_of_tendsto _ _ h) C'
        (Î» x, le_of_forall_pos_lt_add (Î» Îµ Îµ_pos, _)),
      cases metric.tendsto_at_top.mp (tendsto_pi_nhds.mp h x) Îµ Îµ_pos with n hn,
      have lt_Îµ : â¥g n x - f xâ¥ < Îµ, by {rw âdist_eq_norm, exact hn n (le_refl n)},
      calc â¥f xâ¥ â¤ â¥g n xâ¥ + â¥g n x - f xâ¥ : norm_le_insert _ _
        ...      < â¥g nâ¥ * â¥xâ¥ + Îµ        : by linarith [lt_Îµ, (g n).le_op_norm x]
        ...      â¤ C' * â¥xâ¥ + Îµ           : by nlinarith [hC' n, norm_nonneg x],
    end }
