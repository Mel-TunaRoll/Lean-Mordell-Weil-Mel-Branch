/-
Copyright (c) 2020 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov
-/
import analysis.normed_space.basic

/-!
# Extended norm

In this file we define a structure `enorm π V` representing an extended norm (i.e., a norm that can
take the value `β`) on a vector space `V` over a normed field `π`. We do not use `class` for
an `enorm` because the same space can have more than one extended norm. For example, the space of
measurable functions `f : Ξ± β β` has a family of `L_p` extended norms.

We prove some basic inequalities, then define

* `emetric_space` structure on `V` corresponding to `e : enorm π V`;
* the subspace of vectors with finite norm, called `e.finite_subspace`;
* a `normed_space` structure on this space.

The last definition is an instance because the type involves `e`.

## Implementation notes

We do not define extended normed groups. They can be added to the chain once someone will need them.

## Tags

normed space, extended norm
-/

noncomputable theory
local attribute [instance, priority 1001] classical.prop_decidable
open_locale ennreal

/-- Extended norm on a vector space. As in the case of normed spaces, we require only
`β₯c β’ xβ₯ β€ β₯cβ₯ * β₯xβ₯` in the definition, then prove an equality in `map_smul`. -/
structure enorm (π : Type*) (V : Type*) [normed_field π] [add_comm_group V] [module π V] :=
(to_fun : V β ββ₯0β)
(eq_zero' : β x, to_fun x = 0 β x = 0)
(map_add_le' : β x y : V, to_fun (x + y) β€ to_fun x + to_fun y)
(map_smul_le' : β (c : π) (x : V), to_fun (c β’ x) β€ nnnorm c * to_fun x)

namespace enorm

variables {π : Type*} {V : Type*} [normed_field π] [add_comm_group V] [module π V]
  (e : enorm π V)

instance : has_coe_to_fun (enorm π V) (Ξ» _, V β ββ₯0β) := β¨enorm.to_funβ©

lemma coe_fn_injective : function.injective (coe_fn : enorm π V β (V β ββ₯0β)) :=
Ξ» eβ eβ h, by cases eβ; cases eβ; congr; exact h

@[ext] lemma ext {eβ eβ : enorm π V} (h : β x, eβ x = eβ x) : eβ = eβ :=
coe_fn_injective $ funext h

lemma ext_iff {eβ eβ : enorm π V} : eβ = eβ β β x, eβ x = eβ x :=
β¨Ξ» h x, h βΈ rfl, extβ©

@[simp, norm_cast] lemma coe_inj {eβ eβ : enorm π V} : (eβ : V β ββ₯0β) = eβ β eβ = eβ :=
coe_fn_injective.eq_iff

@[simp] lemma map_smul (c : π) (x : V) : e (c β’ x) = nnnorm c * e x :=
le_antisymm (e.map_smul_le' c x) $
begin
  by_cases hc : c = 0, { simp [hc] },
  calc (nnnorm c : ββ₯0β) * e x = nnnorm c * e (cβ»ΒΉ β’ c β’ x) : by rw [inv_smul_smulβ hc]
  ... β€ nnnorm c * (nnnorm (cβ»ΒΉ) * e (c β’ x)) : _
  ... = e (c β’ x) : _,
  { exact ennreal.mul_le_mul le_rfl (e.map_smul_le' _ _) },
  { rw [β mul_assoc, normed_field.nnnorm_inv, ennreal.coe_inv,
     ennreal.mul_inv_cancel _ ennreal.coe_ne_top, one_mul]; simp [hc] }
end

@[simp] lemma map_zero : e 0 = 0 :=
by { rw [β zero_smul π (0:V), e.map_smul], norm_num }

@[simp] lemma eq_zero_iff {x : V} : e x = 0 β x = 0 :=
β¨e.eq_zero' x, Ξ» h, h.symm βΈ e.map_zeroβ©

@[simp] lemma map_neg (x : V) : e (-x) = e x :=
calc e (-x) = nnnorm (-1:π) * e x : by rw [β map_smul, neg_one_smul]
        ... = e x                 : by simp

lemma map_sub_rev (x y : V) : e (x - y) = e (y - x) :=
by rw [β neg_sub, e.map_neg]

lemma map_add_le (x y : V) : e (x + y) β€ e x + e y := e.map_add_le' x y

lemma map_sub_le (x y : V) : e (x - y) β€ e x + e y :=
calc e (x - y) = e (x + -y)   : by rw sub_eq_add_neg
           ... β€ e x + e (-y) : e.map_add_le x (-y)
           ... = e x + e y    : by rw [e.map_neg]

instance : partial_order (enorm π V) :=
{ le := Ξ» eβ eβ, β x, eβ x β€ eβ x,
  le_refl := Ξ» e x, le_rfl,
  le_trans := Ξ» eβ eβ eβ hββ hββ x, le_trans (hββ x) (hββ x),
  le_antisymm := Ξ» eβ eβ hββ hββ, ext $ Ξ» x, le_antisymm (hββ x) (hββ x) }

/-- The `enorm` sending each non-zero vector to infinity. -/
noncomputable instance : has_top (enorm π V) :=
β¨{ to_fun := Ξ» x, if x = 0 then 0 else β€,
   eq_zero' := Ξ» x, by { split_ifs; simp [*] },
   map_add_le' := Ξ» x y,
     begin
       split_ifs with hxy hx hy hy hx hy hy; try { simp [*] },
       simpa [hx, hy] using hxy
     end,
   map_smul_le' := Ξ» c x,
     begin
       split_ifs with hcx hx hx; simp only [smul_eq_zero, not_or_distrib] at hcx,
       { simp only [mul_zero, le_refl] },
       { have : c = 0, by tauto,
         simp [this] },
       { tauto },
       { simp [hcx.1] }
     end }β©

noncomputable instance : inhabited (enorm π V) := β¨β€β©

lemma top_map {x : V} (hx : x β  0) : (β€ : enorm π V) x = β€ := if_neg hx

noncomputable instance : order_top (enorm π V) :=
{ top := β€,
  le_top := Ξ» e x, if h : x = 0 then by simp [h] else by simp [top_map h] }

noncomputable instance : semilattice_sup (enorm π V) :=
{ le := (β€),
  lt := (<),
  sup := Ξ» eβ eβ,
  { to_fun := Ξ» x, max (eβ x) (eβ x),
    eq_zero' := Ξ» x h, eβ.eq_zero_iff.1 (ennreal.max_eq_zero_iff.1 h).1,
    map_add_le' := Ξ» x y, max_le
      (le_trans (eβ.map_add_le _ _) $ add_le_add (le_max_left _ _) (le_max_left _ _))
      (le_trans (eβ.map_add_le _ _) $ add_le_add (le_max_right _ _) (le_max_right _ _)),
    map_smul_le' := Ξ» c x, le_of_eq $ by simp only [map_smul, ennreal.mul_max] },
  le_sup_left := Ξ» eβ eβ x, le_max_left _ _,
  le_sup_right := Ξ» eβ eβ x, le_max_right _ _,
  sup_le := Ξ» eβ eβ eβ hβ hβ x, max_le (hβ x) (hβ x),
  .. enorm.partial_order }

@[simp, norm_cast] lemma coe_max (eβ eβ : enorm π V) : β(eβ β eβ) = Ξ» x, max (eβ x) (eβ x) := rfl

@[norm_cast]
lemma max_map (eβ eβ : enorm π V) (x : V) : (eβ β eβ) x = max (eβ x) (eβ x) := rfl

/-- Structure of an `emetric_space` defined by an extended norm. -/
def emetric_space : emetric_space V :=
{ edist := Ξ» x y, e (x - y),
  edist_self := Ξ» x, by simp,
  eq_of_edist_eq_zero := Ξ» x y, by simp [sub_eq_zero],
  edist_comm := e.map_sub_rev,
  edist_triangle := Ξ» x y z,
    calc e (x - z) = e ((x - y) + (y - z)) : by rw [sub_add_sub_cancel]
               ... β€ e (x - y) + e (y - z) : e.map_add_le (x - y) (y - z) }

/-- The subspace of vectors with finite enorm. -/
def finite_subspace : subspace π V :=
{ carrier   := {x | e x < β€},
  zero_mem' := by simp,
  add_mem'  := Ξ» x y hx hy, lt_of_le_of_lt (e.map_add_le x y) (ennreal.add_lt_top.2 β¨hx, hyβ©),
  smul_mem' := Ξ» c x (hx : _ < _),
    calc e (c β’ x) = nnnorm c * e x : e.map_smul c x
               ... < β€              : ennreal.mul_lt_top ennreal.coe_ne_top hx.ne }

/-- Metric space structure on `e.finite_subspace`. We use `emetric_space.to_metric_space_of_dist`
to ensure that this definition agrees with `e.emetric_space`. -/
instance : metric_space e.finite_subspace :=
begin
  letI := e.emetric_space,
  refine emetric_space.to_metric_space_of_dist _ (Ξ» x y, _) (Ξ» x y, rfl),
  change e (x - y) β  β€,
  exact ne_top_of_le_ne_top (ennreal.add_lt_top.2 β¨x.2, y.2β©).ne (e.map_sub_le x y)
end

lemma finite_dist_eq (x y : e.finite_subspace) : dist x y = (e (x - y)).to_real := rfl

lemma finite_edist_eq (x y : e.finite_subspace) : edist x y = e (x - y) := rfl

/-- Normed group instance on `e.finite_subspace`. -/
instance : normed_group e.finite_subspace :=
{ norm := Ξ» x, (e x).to_real,
  dist_eq := Ξ» x y, rfl }

lemma finite_norm_eq (x : e.finite_subspace) : β₯xβ₯ = (e x).to_real := rfl

/-- Normed space instance on `e.finite_subspace`. -/
instance : normed_space π e.finite_subspace :=
{ norm_smul_le := Ξ» c x, le_of_eq $ by simp [finite_norm_eq, ennreal.to_real_mul] }

end enorm
