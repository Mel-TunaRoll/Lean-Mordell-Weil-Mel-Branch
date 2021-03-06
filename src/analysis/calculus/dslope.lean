/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import analysis.calculus.deriv
import linear_algebra.affine_space.slope

/-!
# Slope of a differentiable function

Given a function `f : ๐ โ E` from a nondiscrete normed field to a normed space over this field,
`dslope f a b` is defined as `slope f a b = (b - a)โปยน โข (f b - f a)` for `a โ  b` and as `deriv f a`
for `a = b`.

In this file we define `dslope` and prove some basic lemmas about its continuity and
differentiability.
-/

open_locale classical topological_space filter
open function set filter

variables {๐ E : Type*} [nondiscrete_normed_field ๐] [normed_group E] [normed_space ๐ E]

/-- `dslope f a b` is defined as `slope f a b = (b - a)โปยน โข (f b - f a)` for `a โ  b` and
`deriv f a` for `a = b`. -/
noncomputable def dslope (f : ๐ โ E) (a : ๐) : ๐ โ E := update (slope f a) a (deriv f a)

@[simp] lemma dslope_same (f : ๐ โ E) (a : ๐) : dslope f a a = deriv f a := update_same _ _ _

variables {f : ๐ โ E} {a b : ๐} {s : set ๐}

lemma dslope_of_ne (f : ๐ โ E) (h : b โ  a) : dslope f a b = slope f a b :=
update_noteq h _ _

lemma eq_on_dslope_slope (f : ๐ โ E) (a : ๐) : eq_on (dslope f a) (slope f a) {a}แถ :=
ฮป b, dslope_of_ne f

lemma dslope_eventually_eq_slope_of_ne (f : ๐ โ E) (h : b โ  a) : dslope f a =แถ [๐ b] slope f a :=
(eq_on_dslope_slope f a).eventually_eq_of_mem (is_open_ne.mem_nhds h)

lemma dslope_eventually_eq_slope_punctured_nhds (f : ๐ โ E) : dslope f a =แถ [๐[โ ] a] slope f a :=
(eq_on_dslope_slope f a).eventually_eq_of_mem self_mem_nhds_within

@[simp] lemma sub_smul_dslope (f : ๐ โ E) (a b : ๐) : (b - a) โข dslope f a b = f b - f a :=
by rcases eq_or_ne b a with rfl | hne; simp [dslope_of_ne, *]

lemma dslope_sub_smul_of_ne (f : ๐ โ E) (h : b โ  a) : dslope (ฮป x, (x - a) โข f x) a b = f b :=
by rw [dslope_of_ne _ h, slope_sub_smul _ h.symm]

lemma eq_on_dslope_sub_smul (f : ๐ โ E) (a : ๐) : eq_on (dslope (ฮป x, (x - a) โข f x) a) f {a}แถ :=
ฮป b, dslope_sub_smul_of_ne f

lemma dslope_sub_smul [decidable_eq ๐] (f : ๐ โ E) (a : ๐) :
  dslope (ฮป x, (x - a) โข f x) a = update f a (deriv (ฮป x, (x - a) โข f x) a) :=
eq_update_iff.2 โจdslope_same _ _, eq_on_dslope_sub_smul f aโฉ

@[simp] lemma continuous_at_dslope_same : continuous_at (dslope f a) a โ differentiable_at ๐ f a :=
by simp only [dslope, continuous_at_update_same, โ has_deriv_at_deriv_iff,
  has_deriv_at_iff_tendsto_slope]

lemma continuous_within_at.of_dslope (h : continuous_within_at (dslope f a) s b) :
  continuous_within_at f s b :=
have continuous_within_at (ฮป x, (x - a) โข dslope f a x + f a) s b,
  from ((continuous_within_at_id.sub continuous_within_at_const).smul h).add
    continuous_within_at_const,
by simpa only [sub_smul_dslope, sub_add_cancel] using this

lemma continuous_at.of_dslope (h : continuous_at (dslope f a) b) : continuous_at f b :=
(continuous_within_at_univ _ _).1 h.continuous_within_at.of_dslope

lemma continuous_on.of_dslope (h : continuous_on (dslope f a) s) : continuous_on f s :=
ฮป x hx, (h x hx).of_dslope

lemma continuous_within_at_dslope_of_ne (h : b โ  a) :
  continuous_within_at (dslope f a) s b โ continuous_within_at f s b :=
begin
  refine โจcontinuous_within_at.of_dslope, ฮป hc, _โฉ,
  simp only [dslope, continuous_within_at_update_of_ne h],
  exact ((continuous_within_at_id.sub continuous_within_at_const).invโ
      (sub_ne_zero.2 h)).smul (hc.sub continuous_within_at_const)
end

lemma continuous_at_dslope_of_ne (h : b โ  a) : continuous_at (dslope f a) b โ continuous_at f b :=
by simp only [โ continuous_within_at_univ, continuous_within_at_dslope_of_ne h]

lemma continuous_on_dslope (h : s โ ๐ a) :
  continuous_on (dslope f a) s โ continuous_on f s โง differentiable_at ๐ f a :=
begin
  refine โจฮป hc, โจhc.of_dslope, continuous_at_dslope_same.1 $ hc.continuous_at hโฉ, _โฉ,
  rintro โจhc, hdโฉ x hx,
  rcases eq_or_ne x a with rfl | hne,
  exacts [(continuous_at_dslope_same.2 hd).continuous_within_at,
    (continuous_within_at_dslope_of_ne hne).2 (hc x hx)]
end

lemma differentiable_within_at.of_dslope (h : differentiable_within_at ๐ (dslope f a) s b) :
  differentiable_within_at ๐ f s b :=
by simpa only [id, sub_smul_dslope f a, sub_add_cancel]
  using ((differentiable_within_at_id.sub_const a).smul h).add_const (f a)

lemma differentiable_at.of_dslope (h : differentiable_at ๐ (dslope f a) b) :
  differentiable_at ๐ f b :=
differentiable_within_at_univ.1 h.differentiable_within_at.of_dslope

lemma differentiable_on.of_dslope (h : differentiable_on ๐ (dslope f a) s) :
  differentiable_on ๐ f s :=
ฮป x hx, (h x hx).of_dslope

lemma differentiable_within_at_dslope_of_ne (h : b โ  a) :
  differentiable_within_at ๐ (dslope f a) s b โ differentiable_within_at ๐ f s b :=
begin
  refine โจdifferentiable_within_at.of_dslope, ฮป hd, _โฉ,
  refine (((differentiable_within_at_id.sub_const a).inv
    (sub_ne_zero.2 h)).smul (hd.sub_const (f a))).congr_of_eventually_eq _ (dslope_of_ne _ h),
  refine (eq_on_dslope_slope _ _).eventually_eq_of_mem _,
  exact mem_nhds_within_of_mem_nhds (is_open_ne.mem_nhds h)
end

lemma differentiable_on_dslope_of_nmem (h : a โ s) :
  differentiable_on ๐ (dslope f a) s โ differentiable_on ๐ f s :=
forall_congr $ ฮป x, forall_congr $ ฮป hx, differentiable_within_at_dslope_of_ne $
  ne_of_mem_of_not_mem hx h

lemma differentiable_at_dslope_of_ne (h : b โ  a) :
  differentiable_at ๐ (dslope f a) b โ differentiable_at ๐ f b :=
by simp only [โ differentiable_within_at_univ,
  differentiable_within_at_dslope_of_ne h]
