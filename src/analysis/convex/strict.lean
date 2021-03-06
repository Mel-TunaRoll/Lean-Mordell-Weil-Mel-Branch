/-
Copyright (c) 2021 YaΓ«l Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: YaΓ«l Dillies
-/
import analysis.convex.basic
import topology.algebra.mul_action
import topology.algebra.ordered.basic

/-!
# Strictly convex sets

This file defines strictly convex sets.

A set is strictly convex if the open segment between any two distinct points lies in its interior.

## TODO

Define strictly convex spaces.
-/

open set
open_locale convex pointwise

variables {π E F Ξ² : Type*}

open function set
open_locale convex

section ordered_semiring
variables [ordered_semiring π] [topological_space E] [topological_space F]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F]

section has_scalar
variables (π) [has_scalar π E] [has_scalar π F] (s : set E)

/-- A set is strictly convex if the open segment between any two distinct points lies is in its
interior. This basically means "convex and not flat on the boundary". -/
def strict_convex : Prop :=
s.pairwise $ Ξ» x y, β β¦a b : πβ¦, 0 < a β 0 < b β a + b = 1 β a β’ x + b β’ y β interior s

variables {π s} {x y : E}

lemma strict_convex_iff_open_segment_subset :
  strict_convex π s β s.pairwise (Ξ» x y, open_segment π x y β interior s) :=
forallβ_congr $ Ξ» x hx y hy hxy, (open_segment_subset_iff π).symm

lemma strict_convex.open_segment_subset (hs : strict_convex π s) (hx : x β s) (hy : y β s)
  (h : x β  y) :
  open_segment π x y β interior s :=
strict_convex_iff_open_segment_subset.1 hs hx hy h

lemma strict_convex_empty : strict_convex π (β : set E) := pairwise_empty _

lemma strict_convex_univ : strict_convex π (univ : set E) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  rw interior_univ,
  exact mem_univ _,
end

protected lemma strict_convex.inter {t : set E} (hs : strict_convex π s) (ht : strict_convex π t) :
  strict_convex π (s β© t) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  rw interior_inter,
  exact β¨hs hx.1 hy.1 hxy ha hb hab, ht hx.2 hy.2 hxy ha hb habβ©,
end

lemma directed.strict_convex_Union {ΞΉ : Sort*} {s : ΞΉ β set E} (hdir : directed (β) s)
  (hs : β β¦i : ΞΉβ¦, strict_convex π (s i)) :
  strict_convex π (β i, s i) :=
begin
  rintro x hx y hy hxy a b ha hb hab,
  rw mem_Union at hx hy,
  obtain β¨i, hxβ© := hx,
  obtain β¨j, hyβ© := hy,
  obtain β¨k, hik, hjkβ© := hdir i j,
  exact interior_mono (subset_Union s k) (hs (hik hx) (hjk hy) hxy ha hb hab),
end

lemma directed_on.strict_convex_sUnion {S : set (set E)} (hdir : directed_on (β) S)
  (hS : β s β S, strict_convex π s) :
  strict_convex π (ββ S) :=
begin
  rw sUnion_eq_Union,
  exact (directed_on_iff_directed.1 hdir).strict_convex_Union (Ξ» s, hS _ s.2),
end

end has_scalar

section module
variables [module π E] [module π F] {s : set E}

protected lemma strict_convex.convex (hs : strict_convex π s) : convex π s :=
convex_iff_pairwise_pos.2 $ Ξ» x hx y hy hxy a b ha hb hab, interior_subset $ hs hx hy hxy ha hb hab

/-- An open convex set is strictly convex. -/
protected lemma convex.strict_convex (h : is_open s) (hs : convex π s) : strict_convex π s :=
Ξ» x hx y hy _ a b ha hb hab, h.interior_eq.symm βΈ hs hx hy ha.le hb.le hab

lemma is_open.strict_convex_iff (h : is_open s) : strict_convex π s β convex π s :=
β¨strict_convex.convex, convex.strict_convex hβ©

lemma strict_convex_singleton (c : E) : strict_convex π ({c} : set E) := pairwise_singleton _ _

lemma set.subsingleton.strict_convex (hs : s.subsingleton) : strict_convex π s := hs.pairwise _

lemma strict_convex.linear_image (hs : strict_convex π s) (f : E ββ[π] F) (hf : is_open_map f) :
  strict_convex π (f '' s) :=
begin
  rintro _ β¨x, hx, rflβ© _ β¨y, hy, rflβ© hxy a b ha hb hab,
  exact hf.image_interior_subset _
    β¨a β’ x + b β’ y, hs hx hy (ne_of_apply_ne _ hxy) ha hb hab,
    by rw [f.map_add, f.map_smul, f.map_smul]β©,
end

lemma strict_convex.is_linear_image (hs : strict_convex π s) {f : E β F} (h : is_linear_map π f)
  (hf : is_open_map f) :
  strict_convex π (f '' s) :=
hs.linear_image (h.mk' f) hf

lemma strict_convex.linear_preimage {s : set F} (hs : strict_convex π s) (f : E ββ[π] F)
  (hf : continuous f) (hfinj : injective f) :
  strict_convex π (s.preimage f) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  refine preimage_interior_subset_interior_preimage hf _,
  rw [mem_preimage, f.map_add, f.map_smul, f.map_smul],
  exact hs hx hy (hfinj.ne hxy) ha hb hab,
end

lemma strict_convex.is_linear_preimage {s : set F} (hs : strict_convex π s) {f : E β F}
  (h : is_linear_map π f) (hf : continuous f) (hfinj : injective f) :
  strict_convex π (s.preimage f) :=
hs.linear_preimage (h.mk' f) hf hfinj

section linear_ordered_cancel_add_comm_monoid
variables [topological_space Ξ²] [linear_ordered_cancel_add_comm_monoid Ξ²] [order_topology Ξ²]
  [module π Ξ²] [ordered_smul π Ξ²]

lemma strict_convex_Iic (r : Ξ²) : strict_convex π (Iic r) :=
begin
  rintro x (hx : x β€ r) y (hy : y β€ r) hxy a b ha hb hab,
  refine (subset_interior_iff_subset_of_open is_open_Iio).2 Iio_subset_Iic_self _,
  rw βconvex.combo_self hab r,
  obtain rfl | hx := hx.eq_or_lt,
  { exact add_lt_add_left (smul_lt_smul_of_pos (hy.lt_of_ne hxy.symm) hb) _ },
  obtain rfl | hy := hy.eq_or_lt,
  { exact add_lt_add_right (smul_lt_smul_of_pos hx ha) _ },
  { exact add_lt_add (smul_lt_smul_of_pos hx ha) (smul_lt_smul_of_pos hy hb) }
end

lemma strict_convex_Ici (r : Ξ²) : strict_convex π (Ici r) :=
@strict_convex_Iic π (order_dual Ξ²) _ _ _ _ _ _ r

lemma strict_convex_Icc (r s : Ξ²) : strict_convex π (Icc r s) :=
(strict_convex_Ici r).inter $ strict_convex_Iic s

lemma strict_convex_Iio (r : Ξ²) : strict_convex π (Iio r) :=
(convex_Iio r).strict_convex is_open_Iio

lemma strict_convex_Ioi (r : Ξ²) : strict_convex π (Ioi r) :=
(convex_Ioi r).strict_convex is_open_Ioi

lemma strict_convex_Ioo (r s : Ξ²) : strict_convex π (Ioo r s) :=
(strict_convex_Ioi r).inter $ strict_convex_Iio s

lemma strict_convex_Ico (r s : Ξ²) : strict_convex π (Ico r s) :=
(strict_convex_Ici r).inter $ strict_convex_Iio s

lemma strict_convex_Ioc (r s : Ξ²) : strict_convex π (Ioc r s) :=
(strict_convex_Ioi r).inter $ strict_convex_Iic s

lemma strict_convex_interval (r s : Ξ²) : strict_convex π (interval r s) :=
strict_convex_Icc _ _

end linear_ordered_cancel_add_comm_monoid
end module
end add_comm_monoid

section add_cancel_comm_monoid
variables [add_cancel_comm_monoid E] [has_continuous_add E] [module π E] {s : set E}

/-- The translation of a strict_convex set is also strict_convex. -/
lemma strict_convex.preimage_add_right (hs : strict_convex π s) (z : E) :
  strict_convex π ((Ξ» x, z + x) β»ΒΉ' s) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  refine preimage_interior_subset_interior_preimage (continuous_add_left _) _,
  have h := hs hx hy ((add_right_injective _).ne hxy) ha hb hab,
  rwa [smul_add, smul_add, add_add_add_comm, βadd_smul, hab, one_smul] at h,
end

/-- The translation of a strict_convex set is also strict_convex. -/
lemma strict_convex.preimage_add_left (hs : strict_convex π s) (z : E) :
  strict_convex π ((Ξ» x, x + z) β»ΒΉ' s) :=
by simpa only [add_comm] using hs.preimage_add_right z

end add_cancel_comm_monoid

section add_comm_group
variables [add_comm_group E] [module π E] {s t : set E}

lemma strict_convex.add_left [has_continuous_add E] (hs : strict_convex π s) (z : E) :
  strict_convex π ((Ξ» x, z + x) '' s) :=
begin
  rintro _ β¨x, hx, rflβ© _ β¨y, hy, rflβ© hxy a b ha hb hab,
  refine (is_open_map_add_left _).image_interior_subset _ _,
  refine β¨a β’ x + b β’ y, hs hx hy (ne_of_apply_ne _ hxy) ha hb hab, _β©,
  rw [smul_add, smul_add, add_add_add_comm, βadd_smul, hab, one_smul],
end

lemma strict_convex.add_right [has_continuous_add E] (hs : strict_convex π s) (z : E) :
  strict_convex π ((Ξ» x, x + z) '' s) :=
by simpa only [add_comm] using hs.add_left z

lemma strict_convex.add [has_continuous_add E] {t : set E} (hs : strict_convex π s)
  (ht : strict_convex π t) :
  strict_convex π (s + t) :=
begin
  rintro _ β¨v, w, hv, hw, rflβ© _ β¨x, y, hx, hy, rflβ© h a b ha hb hab,
  rw [smul_add, smul_add, add_add_add_comm],
  obtain rfl | hvx := eq_or_ne v x,
  { rw convex.combo_self hab,
    suffices : v + (a β’ w + b β’ y) β interior ({v} + t),
    { exact interior_mono (add_subset_add (singleton_subset_iff.2 hv) (subset.refl _)) this },
    rw singleton_add,
    exact (is_open_map_add_left _).image_interior_subset _
      (mem_image_of_mem _ $ ht hw hy (ne_of_apply_ne _ h) ha hb hab) },
  obtain rfl | hwy := eq_or_ne w y,
  { rw convex.combo_self hab,
    suffices : a β’ v + b β’ x + w β interior (s + {w}),
    { exact interior_mono (add_subset_add (subset.refl _) (singleton_subset_iff.2 hw)) this },
    rw add_singleton,
    exact (is_open_map_add_right _).image_interior_subset _
      (mem_image_of_mem _ $ hs hv hx hvx ha hb hab) },
  exact subset_interior_add (add_mem_add (hs hv hx hvx ha hb hab) $ ht hw hy hwy ha hb hab),
end

end add_comm_group
end ordered_semiring

section ordered_comm_semiring
variables [ordered_comm_semiring π] [topological_space π] [topological_space E]

section add_comm_group
variables [add_comm_group E] [module π E] [no_zero_smul_divisors π E] [has_continuous_smul π E]
  {s : set E}

lemma strict_convex.preimage_smul (hs : strict_convex π s) (c : π) :
  strict_convex π ((Ξ» z, c β’ z) β»ΒΉ' s) :=
begin
  classical,
  obtain rfl | hc := eq_or_ne c 0,
  { simp_rw [zero_smul, preimage_const],
    split_ifs,
    { exact strict_convex_univ },
    { exact strict_convex_empty } },
  refine hs.linear_preimage (linear_map.lsmul _ _ c) _ (smul_right_injective E hc),
  unfold linear_map.lsmul linear_map.mkβ linear_map.mkβ' linear_map.mkβ'ββ,
  exact continuous_const.smul continuous_id,
end

end add_comm_group
end ordered_comm_semiring

section ordered_ring
variables [ordered_ring π] [topological_space E] [topological_space F]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module π E] [module π F] {s : set E} {x y : E}

lemma strict_convex.eq_of_open_segment_subset_frontier [nontrivial π] [densely_ordered π]
  (hs : strict_convex π s) (hx : x β s) (hy : y β s) (h : open_segment π x y β frontier s) :
  x = y :=
begin
  obtain β¨a, haβ, haββ© := densely_ordered.dense (0 : π) 1 zero_lt_one,
  classical,
  by_contra hxy,
  exact (h β¨a, 1 - a, haβ, sub_pos_of_lt haβ, add_sub_cancel'_right _ _, rflβ©).2
    (hs hx hy hxy haβ (sub_pos_of_lt haβ) $ add_sub_cancel'_right _ _),
end

lemma strict_convex.add_smul_mem (hs : strict_convex π s) (hx : x β s) (hxy : x + y β s)
  (hy : y β  0) {t : π} (htβ : 0 < t) (htβ : t < 1) :
  x + t β’ y β interior s :=
begin
  have h : x + t β’ y = (1 - t) β’ x + t β’ (x + y),
  { rw [smul_add, βadd_assoc, βadd_smul, sub_add_cancel, one_smul] },
  rw h,
  refine hs hx hxy (Ξ» h, hy $ add_left_cancel _) (sub_pos_of_lt htβ) htβ (sub_add_cancel _ _),
  exact x,
  rw [βh, add_zero],
end

lemma strict_convex.smul_mem_of_zero_mem (hs : strict_convex π s) (zero_mem : (0 : E) β s)
  (hx : x β s) (hxβ : x β  0) {t : π} (htβ : 0 < t) (htβ : t < 1) :
  t β’ x β interior s :=
by simpa using hs.add_smul_mem zero_mem (by simpa using hx) hxβ htβ htβ

lemma strict_convex.add_smul_sub_mem (h : strict_convex π s) (hx : x β s) (hy : y β s) (hxy : x β  y)
  {t : π} (htβ : 0 < t) (htβ : t < 1) : x + t β’ (y - x) β interior s :=
begin
  apply h.open_segment_subset hx hy hxy,
  rw open_segment_eq_image',
  exact mem_image_of_mem _ β¨htβ, htββ©,
end

/-- The preimage of a strict_convex set under an affine map is strict_convex. -/
lemma strict_convex.affine_preimage {s : set F} (hs : strict_convex π s) {f : E βα΅[π] F}
  (hf : continuous f) (hfinj : injective f) :
  strict_convex π (f β»ΒΉ' s) :=
begin
  intros x hx y hy hxy a b ha hb hab,
  refine preimage_interior_subset_interior_preimage hf _,
  rw [mem_preimage, convex.combo_affine_apply hab],
  exact hs hx hy (hfinj.ne hxy) ha hb hab,
end

/-- The image of a strict_convex set under an affine map is strict_convex. -/
lemma strict_convex.affine_image (hs : strict_convex π s) {f : E βα΅[π] F} (hf : is_open_map f) :
  strict_convex π (f '' s) :=
begin
  rintro _ β¨x, hx, rflβ© _ β¨y, hy, rflβ© hxy a b ha hb hab,
  exact hf.image_interior_subset _ β¨a β’ x + b β’ y, β¨hs hx hy (ne_of_apply_ne _ hxy) ha hb hab,
    convex.combo_affine_apply habβ©β©,
end

lemma strict_convex.neg [topological_add_group E] (hs : strict_convex π s) :
  strict_convex π ((Ξ» z, -z) '' s) :=
hs.is_linear_image is_linear_map.is_linear_map_neg (homeomorph.neg E).is_open_map

lemma strict_convex.neg_preimage [topological_add_group E] (hs : strict_convex π s) :
  strict_convex π ((Ξ» z, -z) β»ΒΉ' s) :=
hs.is_linear_preimage is_linear_map.is_linear_map_neg continuous_id.neg neg_injective

end add_comm_group
end ordered_ring

section linear_ordered_field
variables [linear_ordered_field π] [topological_space E]

section add_comm_group
variables [add_comm_group E] [add_comm_group F] [module π E] [module π F] {s : set E} {x : E}

lemma strict_convex.smul [topological_space π] [has_continuous_smul π E] (hs : strict_convex π s)
  (c : π) :
  strict_convex π (c β’ s) :=
begin
  obtain rfl | hc := eq_or_ne c 0,
  { exact (subsingleton_zero_smul_set _).strict_convex },
  { exact hs.linear_image (linear_map.lsmul _ _ c) (is_open_map_smulβ hc) }
end

lemma strict_convex.affinity [topological_space π] [has_continuous_add E] [has_continuous_smul π E]
  (hs : strict_convex π s) (z : E) (c : π) :
  strict_convex π ((Ξ» x, z + c β’ x) '' s) :=
begin
  have h := (hs.smul c).add_left z,
  rwa [βimage_smul, image_image] at h,
end

/-- Alternative definition of set strict_convexity, using division. -/
lemma strict_convex_iff_div :
  strict_convex π s β s.pairwise
    (Ξ» x y, β β¦a b : πβ¦, 0 < a β 0 < b β (a / (a + b)) β’ x + (b / (a + b)) β’ y β interior s) :=
β¨Ξ» h x hx y hy hxy a b ha hb, begin
  apply h hx hy hxy (div_pos ha $ add_pos ha hb) (div_pos hb $ add_pos ha hb),
  rw βadd_div,
  exact div_self (add_pos ha hb).ne',
end, Ξ» h x hx y hy hxy a b ha hb hab, by convert h hx hy hxy ha hb; rw [hab, div_one] β©

lemma strict_convex.mem_smul_of_zero_mem (hs : strict_convex π s) (zero_mem : (0 : E) β s)
  (hx : x β s) (hxβ : x β  0) {t : π} (ht : 1 < t) :
  x β t β’ interior s :=
begin
  rw mem_smul_set_iff_inv_smul_memβ (zero_lt_one.trans ht).ne',
  exact hs.smul_mem_of_zero_mem zero_mem hx hxβ (inv_pos.2 $ zero_lt_one.trans ht)  (inv_lt_one ht),
end

end add_comm_group
end linear_ordered_field

/-!
#### Convex sets in an ordered space

Relates `convex` and `set.ord_connected`.
-/

section
variables [topological_space E]

/-- A set in a linear ordered field is strictly convex if and only if it is convex. -/
@[simp] lemma strict_convex_iff_convex [linear_ordered_field π] [topological_space π]
  [order_topology π] {s : set π} :
  strict_convex π s β convex π s :=
begin
  refine β¨strict_convex.convex, Ξ» hs, strict_convex_iff_open_segment_subset.2 (Ξ» x hx y hy hxy, _)β©,
  obtain h | h := hxy.lt_or_lt,
  { refine (open_segment_subset_Ioo h).trans _,
    rw βinterior_Icc,
    exact interior_mono (Icc_subset_segment.trans $ hs.segment_subset hx hy) },
  { rw open_segment_symm,
    refine (open_segment_subset_Ioo h).trans _,
    rw βinterior_Icc,
    exact interior_mono (Icc_subset_segment.trans $ hs.segment_subset hy hx) }
end

lemma strict_convex_iff_ord_connected [linear_ordered_field π] [topological_space π]
  [order_topology π] {s : set π} :
  strict_convex π s β s.ord_connected :=
strict_convex_iff_convex.trans convex_iff_ord_connected

alias strict_convex_iff_ord_connected β strict_convex.ord_connected _

end
