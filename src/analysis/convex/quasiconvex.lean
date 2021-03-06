/-
Copyright (c) 2021 YaÃ«l Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: YaÃ«l Dillies
-/
import analysis.convex.function

/-!
# Quasiconvex and quasiconcave functions

This file defines quasiconvexity, quasiconcavity and quasilinearity of functions, which are
generalizations of unimodality and monotonicity. Convexity implies quasiconvexity, concavity implies
quasiconcavity, and monotonicity implies quasilinearity.

## Main declarations

* `quasiconvex_on ð s f`: Quasiconvexity of the function `f` on the set `s` with scalars `ð`. This
  means that, for all `r`, `{x â s | f x â¤ r}` is `ð`-convex.
* `quasiconcave_on ð s f`: Quasiconcavity of the function `f` on the set `s` with scalars `ð`. This
  means that, for all `r`, `{x â s | r â¤ f x}` is `ð`-convex.
* `quasilinear_on ð s f`: Quasilinearity of the function `f` on the set `s` with scalars `ð`. This
  means that `f` is both quasiconvex and quasiconcave.

## TODO

Prove that a quasilinear function between two linear orders is either monotone or antitone. This is
not hard but quite a pain to go about as there are many cases to consider.

## References

* https://en.wikipedia.org/wiki/Quasiconvex_function
-/

open function set

variables {ð E F Î² : Type*}

section ordered_semiring
variables [ordered_semiring ð]

section add_comm_monoid
variables [add_comm_monoid E] [add_comm_monoid F]

section ordered_add_comm_monoid
variables (ð) [ordered_add_comm_monoid Î²] [has_scalar ð E] (s : set E) (f : E â Î²)

/-- A function is quasiconvex if all its sublevels are convex.
This means that, for all `r`, `{x â s | f x â¤ r}` is `ð`-convex. -/
def quasiconvex_on : Prop :=
â r, convex ð {x â s | f x â¤ r}

/-- A function is quasiconcave if all its superlevels are convex.
This means that, for all `r`, `{x â s | r â¤ f x}` is `ð`-convex. -/
def quasiconcave_on : Prop :=
â r, convex ð {x â s | r â¤ f x}

/-- A function is quasilinear if it is both quasiconvex and quasiconcave.
This means that, for all `r`,
the sets `{x â s | f x â¤ r}` and `{x â s | r â¤ f x}` are `ð`-convex. -/
def quasilinear_on : Prop :=
quasiconvex_on ð s f â§ quasiconcave_on ð s f

variables {ð s f}

lemma quasiconvex_on.dual (hf : quasiconvex_on ð s f) :
  @quasiconcave_on ð E (order_dual Î²) _ _ _ _ s f :=
hf

lemma quasiconcave_on.dual (hf : quasiconcave_on ð s f) :
  @quasiconvex_on ð E (order_dual Î²) _ _ _ _ s f :=
hf

lemma quasilinear_on.dual (hf : quasilinear_on ð s f) :
  @quasilinear_on ð E (order_dual Î²) _ _ _ _ s f :=
â¨hf.2, hf.1â©

lemma convex.quasiconvex_on_of_convex_le (hs : convex ð s) (h : â r, convex ð {x | f x â¤ r}) :
  quasiconvex_on ð s f :=
Î» r, hs.inter (h r)

lemma convex.quasiconcave_on_of_convex_ge (hs : convex ð s) (h : â r, convex ð {x | r â¤ f x}) :
  quasiconcave_on ð s f :=
@convex.quasiconvex_on_of_convex_le ð E (order_dual Î²) _ _ _ _ _ _ hs h

lemma quasiconvex_on.convex [is_directed Î² (â¤)] (hf : quasiconvex_on ð s f) : convex ð s :=
Î» x y hx hy a b ha hb hab,
  let â¨z, hxz, hyzâ© := exists_ge_ge (f x) (f y) in (hf _ â¨hx, hxzâ© â¨hy, hyzâ© ha hb hab).1

lemma quasiconcave_on.convex [is_directed Î² (swap (â¤))] (hf : quasiconcave_on ð s f) : convex ð s :=
hf.dual.convex

end ordered_add_comm_monoid

section linear_ordered_add_comm_monoid
variables [linear_ordered_add_comm_monoid Î²]

section has_scalar
variables [has_scalar ð E] {s : set E} {f g : E â Î²}

lemma quasiconvex_on.sup (hf : quasiconvex_on ð s f) (hg : quasiconvex_on ð s g) :
  quasiconvex_on ð s (f â g) :=
begin
  intro r,
  simp_rw [pi.sup_def, sup_le_iff, âset.sep_inter_sep],
  exact (hf r).inter (hg r),
end

lemma quasiconcave_on.inf (hf : quasiconcave_on ð s f) (hg : quasiconcave_on ð s g) :
  quasiconcave_on ð s (f â g) :=
hf.dual.sup hg

lemma quasiconvex_on_iff_le_max :
  quasiconvex_on ð s f â convex ð s â§
    â â¦x y : Eâ¦, x â s â y â s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â a + b = 1 â
      f (a â¢ x + b â¢ y) â¤ max (f x) (f y) :=
â¨Î» hf, â¨hf.convex, Î» x y hx hy a b ha hb hab,
  (hf _ â¨hx, le_max_left _ _â© â¨hy, le_max_right _ _â© ha hb hab).2â©,
  Î» hf r x y hx hy a b ha hb hab,
  â¨hf.1 hx.1 hy.1 ha hb hab, (hf.2 hx.1 hy.1 ha hb hab).trans $ max_le hx.2 hy.2â©â©

lemma quasiconcave_on_iff_min_le :
  quasiconcave_on ð s f â convex ð s â§
    â â¦x y : Eâ¦, x â s â y â s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â a + b = 1 â
      min (f x) (f y) â¤ f (a â¢ x + b â¢ y) :=
@quasiconvex_on_iff_le_max ð E (order_dual Î²) _ _ _ _ _ _

lemma quasilinear_on_iff_mem_interval :
  quasilinear_on ð s f â convex ð s â§
    â â¦x y : Eâ¦, x â s â y â s â â â¦a b : ðâ¦, 0 â¤ a â 0 â¤ b â a + b = 1 â
      f (a â¢ x + b â¢ y) â interval (f x) (f y) :=
begin
  rw [quasilinear_on, quasiconvex_on_iff_le_max, quasiconcave_on_iff_min_le, and_and_and_comm,
    and_self],
  apply and_congr_right',
  simp_rw [âforall_and_distrib, interval, mem_Icc, and_comm],
end

lemma quasiconvex_on.convex_lt (hf : quasiconvex_on ð s f) (r : Î²) : convex ð {x â s | f x < r} :=
begin
  refine Î» x y hx hy a b ha hb hab, _,
  have h := hf _ â¨hx.1, le_max_left _ _â© â¨hy.1, le_max_right _ _â© ha hb hab,
  exact â¨h.1, h.2.trans_lt $ max_lt hx.2 hy.2â©,
end

lemma quasiconcave_on.convex_gt (hf : quasiconcave_on ð s f) (r : Î²) : convex ð {x â s | r < f x} :=
hf.dual.convex_lt r

end has_scalar

section ordered_smul
variables [has_scalar ð E] [module ð Î²] [ordered_smul ð Î²] {s : set E} {f : E â Î²}

lemma convex_on.quasiconvex_on (hf : convex_on ð s f) : quasiconvex_on ð s f :=
hf.convex_le

lemma concave_on.quasiconcave_on (hf : concave_on ð s f) : quasiconcave_on ð s f :=
hf.convex_ge

end ordered_smul
end linear_ordered_add_comm_monoid
end add_comm_monoid

section linear_ordered_add_comm_monoid
variables [linear_ordered_add_comm_monoid E] [ordered_add_comm_monoid Î²] [module ð E]
  [ordered_smul ð E] {s : set E} {f : E â Î²}

lemma monotone_on.quasiconvex_on (hf : monotone_on f s) (hs : convex ð s) : quasiconvex_on ð s f :=
hf.convex_le hs

lemma monotone_on.quasiconcave_on (hf : monotone_on f s) (hs : convex ð s) :
  quasiconcave_on ð s f :=
hf.convex_ge hs

lemma monotone_on.quasilinear_on (hf : monotone_on f s) (hs : convex ð s) : quasilinear_on ð s f :=
â¨hf.quasiconvex_on hs, hf.quasiconcave_on hsâ©

lemma antitone_on.quasiconvex_on (hf : antitone_on f s) (hs : convex ð s) : quasiconvex_on ð s f :=
hf.convex_le hs

lemma antitone_on.quasiconcave_on (hf : antitone_on f s) (hs : convex ð s) :
  quasiconcave_on ð s f :=
hf.convex_ge hs

lemma antitone_on.quasilinear_on (hf : antitone_on f s) (hs : convex ð s) : quasilinear_on ð s f :=
â¨hf.quasiconvex_on hs, hf.quasiconcave_on hsâ©

lemma monotone.quasiconvex_on (hf : monotone f) : quasiconvex_on ð univ f :=
(hf.monotone_on _).quasiconvex_on convex_univ

lemma monotone.quasiconcave_on (hf : monotone f) : quasiconcave_on ð univ f :=
(hf.monotone_on _).quasiconcave_on convex_univ

lemma monotone.quasilinear_on (hf : monotone f) : quasilinear_on ð univ f :=
â¨hf.quasiconvex_on, hf.quasiconcave_onâ©

lemma antitone.quasiconvex_on (hf : antitone f) : quasiconvex_on ð univ f :=
(hf.antitone_on _).quasiconvex_on convex_univ

lemma antitone.quasiconcave_on (hf : antitone f) : quasiconcave_on ð univ f :=
(hf.antitone_on _).quasiconcave_on convex_univ

lemma antitone.quasilinear_on (hf : antitone f) : quasilinear_on ð univ f :=
â¨hf.quasiconvex_on, hf.quasiconcave_onâ©

end linear_ordered_add_comm_monoid
end ordered_semiring
