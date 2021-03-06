/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash
-/
import topology.algebra.continuous_affine_map
import analysis.normed_space.add_torsor
import analysis.normed_space.affine_isometry
import analysis.normed_space.operator_norm

/-!
# Continuous affine maps between normed spaces.

This file develops the theory of continuous affine maps between affine spaces modelled on normed
spaces.

In the particular case that the affine spaces are just normed vector spaces `V`, `W`, we define a
norm on the space of continuous affine maps by defining the norm of `f : V βA[π] W` to be
`β₯fβ₯ = max β₯f 0β₯ β₯f.cont_linearβ₯`. This is chosen so that we have a linear isometry:
`(V βA[π] W) ββα΅’[π] W Γ (V βL[π] W)`.

The abstract picture is that for an affine space `P` modelled on a vector space `V`, together with
a vector space `W`, there is an exact sequence of `π`-modules: `0 β C β A β L β 0` where `C`, `A`
are the spaces of constant and affine maps `P β W` and `L` is the space of linear maps `V β W`.

Any choice of a base point in `P` corresponds to a splitting of this sequence so in particular if we
take `P = V`, using `0 : V` as the base point provides a splitting, and we prove this is an
isometric decomposition.

On the other hand, choosing a base point breaks the affine invariance so the norm fails to be
submultiplicative: for a composition of maps, we have only `β₯f.comp gβ₯ β€ β₯fβ₯ * β₯gβ₯ + β₯f 0β₯`.

## Main definitions:

 * `continuous_affine_map.cont_linear`
 * `continuous_affine_map.has_norm`
 * `continuous_affine_map.norm_comp_le`
 * `continuous_affine_map.to_const_prod_continuous_linear_map`

-/

namespace continuous_affine_map

variables {π R V W Wβ P Q Qβ : Type*}
variables [normed_group V] [metric_space P] [normed_add_torsor V P]
variables [normed_group W] [metric_space Q] [normed_add_torsor W Q]
variables [normed_group Wβ] [metric_space Qβ] [normed_add_torsor Wβ Qβ]
variables [normed_field R] [normed_space R V] [normed_space R W] [normed_space R Wβ]
variables [nondiscrete_normed_field π] [normed_space π V] [normed_space π W] [normed_space π Wβ]

include V W

/-- The linear map underlying a continuous affine map is continuous. -/
def cont_linear (f : P βA[R] Q) : V βL[R] W :=
{ to_fun := f.linear,
  cont   := by { rw affine_map.continuous_linear_iff, exact f.cont, },
  .. f.linear, }

@[simp] lemma coe_cont_linear (f : P βA[R] Q) :
  (f.cont_linear : V β W) = f.linear :=
rfl

@[simp] lemma coe_cont_linear_eq_linear (f : P βA[R] Q) :
  (f.cont_linear : V ββ[R] W) = (f : P βα΅[R] Q).linear :=
by { ext, refl, }

@[simp] lemma coe_mk_const_linear_eq_linear (f : P βα΅[R] Q) (h) :
  ((β¨f, hβ© : P βA[R] Q).cont_linear : V β W) = f.linear :=
rfl

lemma coe_linear_eq_coe_cont_linear (f : P βA[R] Q) :
  ((f : P βα΅[R] Q).linear : V β W) = (βf.cont_linear : V β W) :=
rfl

include Wβ

@[simp] lemma comp_cont_linear (f : P βA[R] Q) (g : Q βA[R] Qβ) :
  (g.comp f).cont_linear = g.cont_linear.comp f.cont_linear :=
rfl

omit Wβ

@[simp] lemma map_vadd (f : P βA[R] Q) (p : P) (v : V) :
  f (v +α΅₯ p) = f.cont_linear v +α΅₯ f p :=
f.map_vadd' p v

@[simp] lemma cont_linear_map_vsub (f : P βA[R] Q) (pβ pβ : P) :
  f.cont_linear (pβ -α΅₯ pβ) = f pβ -α΅₯ f pβ :=
f.to_affine_map.linear_map_vsub pβ pβ

@[simp] lemma const_cont_linear (q : Q) : (const R P q).cont_linear = 0 := rfl

lemma cont_linear_eq_zero_iff_exists_const (f : P βA[R] Q) :
  f.cont_linear = 0 β β q, f = const R P q :=
begin
  have hβ : f.cont_linear = 0 β (f : P βα΅[R] Q).linear = 0,
  { refine β¨Ξ» h, _, Ξ» h, _β©;
    ext,
    { rw [β coe_cont_linear_eq_linear, h], refl, },
    { rw [β coe_linear_eq_coe_cont_linear, h], refl, }, },
  have hβ : β (q : Q), f = const R P q β (f : P βα΅[R] Q) = affine_map.const R P q,
  { intros q,
    refine β¨Ξ» h, _, Ξ» h, _β©;
    ext,
    { rw h, refl, },
    { rw [β coe_to_affine_map, h], refl, }, },
  simp_rw [hβ, hβ],
  exact (f : P βα΅[R] Q).linear_eq_zero_iff_exists_const,
end

@[simp] lemma to_affine_map_cont_linear (f : V βL[R] W) :
  f.to_continuous_affine_map.cont_linear = f :=
by { ext, refl, }

@[simp] lemma zero_cont_linear :
  (0 : P βA[R] W).cont_linear = 0 :=
rfl

@[simp] lemma add_cont_linear (f g : P βA[R] W) :
  (f + g).cont_linear = f.cont_linear + g.cont_linear :=
rfl

@[simp] lemma sub_cont_linear (f g : P βA[R] W) :
  (f - g).cont_linear = f.cont_linear - g.cont_linear :=
rfl

@[simp] lemma neg_cont_linear (f : P βA[R] W) :
  (-f).cont_linear = -f.cont_linear :=
rfl

@[simp] lemma smul_cont_linear (t : R) (f : P βA[R] W) :
  (t β’ f).cont_linear = t β’ f.cont_linear :=
rfl

lemma decomp (f : V βA[R] W) :
  (f : V β W) = f.cont_linear + function.const V (f 0) :=
begin
  rcases f with β¨f, hβ©,
  rw [coe_mk_const_linear_eq_linear, coe_mk, f.decomp, pi.add_apply, linear_map.map_zero, zero_add],
end

section normed_space_structure

variables (f : V βA[π] W)

/-- Note that unlike the operator norm for linear maps, this norm is _not_ submultiplicative:
we do _not_ necessarily have `β₯f.comp gβ₯ β€ β₯fβ₯ * β₯gβ₯`. See `norm_comp_le` for what we can say. -/
noncomputable instance has_norm : has_norm (V βA[π] W) := β¨Ξ» f, max β₯f 0β₯ β₯f.cont_linearβ₯β©

lemma norm_def : β₯fβ₯ = (max β₯f 0β₯ β₯f.cont_linearβ₯) := rfl

lemma norm_cont_linear_le : β₯f.cont_linearβ₯ β€ β₯fβ₯ := le_max_right _ _

lemma norm_image_zero_le : β₯f 0β₯ β€ β₯fβ₯ := le_max_left _ _

@[simp] lemma norm_eq (h : f 0 = 0) : β₯fβ₯ = β₯f.cont_linearβ₯ :=
calc β₯fβ₯ = (max β₯f 0β₯ β₯f.cont_linearβ₯) : by rw norm_def
    ... = (max 0 β₯f.cont_linearβ₯) : by rw [h, norm_zero]
    ... = β₯f.cont_linearβ₯ : max_eq_right (norm_nonneg _)

noncomputable instance : normed_group (V βA[π] W) :=
normed_group.of_core _
{ norm_eq_zero_iff := Ξ» f,
    begin
      rw norm_def,
      refine β¨Ξ» hβ, _, by { rintros rfl, simp, }β©,
      rcases max_eq_iff.mp hβ with β¨hβ, hββ© | β¨hβ, hββ©;
      rw hβ at hβ,
      { rw [norm_le_zero_iff, cont_linear_eq_zero_iff_exists_const] at hβ,
        obtain β¨q, rflβ© := hβ,
        simp only [function.const_apply, coe_const, norm_eq_zero] at hβ,
        rw hβ,
        refl, },
      { rw [norm_eq_zero_iff', cont_linear_eq_zero_iff_exists_const] at hβ,
        obtain β¨q, rflβ© := hβ,
        simp only [function.const_apply, coe_const, norm_le_zero_iff] at hβ,
        rw hβ,
        refl, },
    end,
  triangle := Ξ» f g,
    begin
      simp only [norm_def, pi.add_apply, add_cont_linear, coe_add, max_le_iff],
      exact β¨(norm_add_le _ _).trans (add_le_add (le_max_left _ _) (le_max_left _ _)),
             (norm_add_le _ _).trans (add_le_add (le_max_right _ _) (le_max_right _ _))β©,
    end,
  norm_neg := Ξ» f, by simp [norm_def], }

noncomputable instance : normed_space π (V βA[π] W) :=
{ norm_smul_le := Ξ» t f, by simp only [norm_def, smul_cont_linear, coe_smul, pi.smul_apply,
    norm_smul, β mul_max_of_nonneg _ _ (norm_nonneg t)], }

lemma norm_comp_le (g : Wβ βA[π] V) :
  β₯f.comp gβ₯ β€ β₯fβ₯ * β₯gβ₯ + β₯f 0β₯ :=
begin
  rw [norm_def, max_le_iff],
  split,
  { calc β₯f.comp g 0β₯ = β₯f (g 0)β₯ : by simp
                 ... = β₯f.cont_linear (g 0) + f 0β₯ : by { rw f.decomp, simp, }
                 ... β€ β₯f.cont_linearβ₯ * β₯g 0β₯ + β₯f 0β₯ :
                          (norm_add_le _ _).trans (add_le_add_right (f.cont_linear.le_op_norm _) _)
                 ... β€ β₯fβ₯ * β₯gβ₯ + β₯f 0β₯ :
                          add_le_add_right (mul_le_mul f.norm_cont_linear_le g.norm_image_zero_le
                          (norm_nonneg _) (norm_nonneg _)) _, },
  { calc β₯(f.comp g).cont_linearβ₯ β€ β₯f.cont_linearβ₯ * β₯g.cont_linearβ₯ :
                                      (g.comp_cont_linear f).symm βΈ f.cont_linear.op_norm_comp_le _
                             ... β€ β₯fβ₯ * β₯gβ₯ :
                                      mul_le_mul f.norm_cont_linear_le g.norm_cont_linear_le
                                      (norm_nonneg _) (norm_nonneg _)
                             ... β€ β₯fβ₯ * β₯gβ₯ + β₯f 0β₯ :
                                      by { rw le_add_iff_nonneg_right, apply norm_nonneg, }, },
end

variables (π V W)

/-- The space of affine maps between two normed spaces is linearly isometric to the product of the
codomain with the space of linear maps, by taking the value of the affine map at `(0 : V)` and the
linear part. -/
noncomputable def to_const_prod_continuous_linear_map : (V βA[π] W) ββα΅’[π] W Γ (V βL[π] W) :=
{ to_fun    := Ξ» f, β¨f 0, f.cont_linearβ©,
  inv_fun   := Ξ» p, p.2.to_continuous_affine_map + const π V p.1,
  left_inv  := Ξ» f, by { ext, rw f.decomp, simp, },
  right_inv := by { rintros β¨v, fβ©, ext; simp, },
  map_add'  := by simp,
  map_smul' := by simp,
  norm_map' := Ξ» f, by simp [prod.norm_def, norm_def], }

@[simp] lemma to_const_prod_continuous_linear_map_fst (f : V βA[π] W) :
  (to_const_prod_continuous_linear_map π V W f).fst = f 0 :=
rfl

@[simp] lemma to_const_prod_continuous_linear_map_snd (f : V βA[π] W) :
  (to_const_prod_continuous_linear_map π V W f).snd = f.cont_linear :=
rfl

end normed_space_structure

end continuous_affine_map
