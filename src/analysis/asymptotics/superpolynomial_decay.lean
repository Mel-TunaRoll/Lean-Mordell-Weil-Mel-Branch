/-
Copyright (c) 2021 Devon Tuma. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Devon Tuma
-/
import analysis.normed_space.ordered
import analysis.asymptotics.asymptotics
import topology.algebra.ordered.liminf_limsup
import data.polynomial.eval

/-!
# Super-Polynomial Function Decay

This file defines a predicate `asymptotics.superpolynomial_decay f` for a function satisfying
  one of following equivalent definitions (The definition is in terms of the first condition):

* `x ^ n * f` tends to `ð 0` for all (or sufficiently large) naturals `n`
* `|x ^ n * f|` tends to `ð 0` for all naturals `n` (`superpolynomial_decay_iff_abs_tendsto_zero`)
* `|x ^ n * f|` is bounded for all naturals `n` (`superpolynomial_decay_iff_abs_is_bounded_under`)
* `f` is `o(x ^ c)` for all integers `c` (`superpolynomial_decay_iff_is_o`)
* `f` is `O(x ^ c)` for all integers `c` (`superpolynomial_decay_iff_is_O`)

These conditions are all equivalent to conditions in terms of polynomials, replacing `x ^ c` with
  `p(x)` or `p(x)â»Â¹` as appropriate, since asymptotically `p(x)` behaves like `X ^ p.nat_degree`.
These further equivalences are not proven in mathlib but would be good future projects.

The definition of superpolynomial decay for `f : Î± â Î²` is relative to a parameter `k : Î± â Î²`.
Super-polynomial decay then means `f x` decays faster than `(k x) ^ c` for all integers `c`.
Equivalently `f x` decays faster than `p.eval (k x)` for all polynomials `p : polynomial Î²`.
The definition is also relative to a filter `l : filter Î±` where the decay rate is compared.

When the map `k` is given by `n â¦ ân : â â â` this defines negligible functions:
https://en.wikipedia.org/wiki/Negligible_function

When the map `k` is given by `(râ,...,râ) â¦ râ*...*râ : ââ¿ â â` this is equivalent
  to the definition of rapidly decreasing functions given here:
https://ncatlab.org/nlab/show/rapidly+decreasing+function

# Main Theorems

* `superpolynomial_decay.polynomial_mul` says that if `f(x)` is negligible,
    then so is `p(x) * f(x)` for any polynomial `p`.
* `superpolynomial_decay_iff_zpow_tendsto_zero` gives an equivalence between definitions in terms
    of decaying faster than `k(x) ^ n` for all naturals `n` or `k(x) ^ c` for all integer `c`.
-/

namespace asymptotics

open_locale topological_space
open filter

/-- `f` has superpolynomial decay in parameter `k` along filter `l` if
  `k ^ n * f` tends to zero at `l` for all naturals `n` -/
def superpolynomial_decay {Î± Î² : Type*} [topological_space Î²] [comm_semiring Î²]
  (l : filter Î±) (k : Î± â Î²) (f : Î± â Î²) :=
â (n : â), tendsto (Î» (a : Î±), (k a) ^ n * f a) l (ð 0)

variables {Î± Î² : Type*} {l : filter Î±} {k : Î± â Î²} {f g g' : Î± â Î²}

section comm_semiring

variables [topological_space Î²] [comm_semiring Î²]

lemma superpolynomial_decay.congr' (hf : superpolynomial_decay l k f)
  (hfg : f =á¶ [l] g) : superpolynomial_decay l k g :=
Î» z, (hf z).congr' (eventually_eq.mul (eventually_eq.refl l _) hfg)

lemma superpolynomial_decay.congr (hf : superpolynomial_decay l k f)
  (hfg : â x, f x = g x) : superpolynomial_decay l k g :=
Î» z, (hf z).congr (Î» x, congr_arg (Î» a, k x ^ z * a) $ hfg x)

@[simp]
lemma superpolynomial_decay_zero (l : filter Î±) (k : Î± â Î²) :
  superpolynomial_decay l k 0 :=
Î» z, by simpa only [pi.zero_apply, mul_zero] using tendsto_const_nhds

lemma superpolynomial_decay.add [has_continuous_add Î²] (hf : superpolynomial_decay l k f)
  (hg : superpolynomial_decay l k g) : superpolynomial_decay l k (f + g) :=
Î» z, by simpa only [mul_add, add_zero, pi.add_apply] using (hf z).add (hg z)

lemma superpolynomial_decay.mul [has_continuous_mul Î²] (hf : superpolynomial_decay l k f)
  (hg : superpolynomial_decay l k g) : superpolynomial_decay l k (f * g) :=
Î» z, by simpa only [mul_assoc, one_mul, mul_zero, pow_zero] using (hf z).mul (hg 0)

lemma superpolynomial_decay.mul_const [has_continuous_mul Î²] (hf : superpolynomial_decay l k f)
  (c : Î²) : superpolynomial_decay l k (Î» n, f n * c) :=
Î» z, by simpa only [âmul_assoc, zero_mul] using tendsto.mul_const c (hf z)

lemma superpolynomial_decay.const_mul [has_continuous_mul Î²] (hf : superpolynomial_decay l k f)
  (c : Î²) : superpolynomial_decay l k (Î» n, c * f n) :=
(hf.mul_const c).congr (Î» _, mul_comm _ _)

lemma superpolynomial_decay.param_mul (hf : superpolynomial_decay l k f) :
  superpolynomial_decay l k (k * f) :=
Î» z, tendsto_nhds.2 (Î» s hs hs0, l.sets_of_superset ((tendsto_nhds.1 (hf $ z + 1)) s hs hs0)
  (Î» x hx, by simpa only [set.mem_preimage, pi.mul_apply, â mul_assoc, â pow_succ'] using hx))

lemma superpolynomial_decay.mul_param (hf : superpolynomial_decay l k f) :
  superpolynomial_decay l k (f * k) :=
(hf.param_mul).congr (Î» _, mul_comm _ _)

lemma superpolynomial_decay.param_pow_mul (hf : superpolynomial_decay l k f)
  (n : â) : superpolynomial_decay l k (k ^ n * f) :=
begin
  induction n with n hn,
  { simpa only [one_mul, pow_zero] using hf },
  { simpa only [pow_succ, mul_assoc] using hn.param_mul }
end

lemma superpolynomial_decay.mul_param_pow (hf : superpolynomial_decay l k f)
  (n : â) : superpolynomial_decay l k (f * k ^ n) :=
(hf.param_pow_mul n).congr (Î» _, mul_comm _ _)

lemma superpolynomial_decay.polynomial_mul [has_continuous_add Î²] [has_continuous_mul Î²]
  (hf : superpolynomial_decay l k f) (p : polynomial Î²) :
  superpolynomial_decay l k (Î» x, (p.eval $ k x) * f x) :=
polynomial.induction_on' p (Î» p q hp hq, by simpa [add_mul] using hp.add hq)
  (Î» n c, by simpa [mul_assoc] using (hf.param_pow_mul n).const_mul c)

lemma superpolynomial_decay.mul_polynomial [has_continuous_add Î²] [has_continuous_mul Î²]
  (hf : superpolynomial_decay l k f) (p : polynomial Î²) :
  superpolynomial_decay l k (Î» x, f x * (p.eval $ k x)) :=
(hf.polynomial_mul p).congr (Î» _, mul_comm _ _)

end comm_semiring

section ordered_comm_semiring

variables [topological_space Î²] [ordered_comm_semiring Î²] [order_topology Î²]

lemma superpolynomial_decay.trans_eventually_le (hk : 0 â¤á¶ [l] k)
  (hg : superpolynomial_decay l k g) (hg' : superpolynomial_decay l k g')
  (hfg : g â¤á¶ [l] f) (hfg' : f â¤á¶ [l] g') : superpolynomial_decay l k f :=
Î» z, tendsto_of_tendsto_of_tendsto_of_le_of_le' (hg z) (hg' z)
  (hfg.mp (hk.mono $ Î» x hx hx', mul_le_mul_of_nonneg_left hx' (pow_nonneg hx z)))
  (hfg'.mp (hk.mono $ Î» x hx hx', mul_le_mul_of_nonneg_left hx' (pow_nonneg hx z)))

end ordered_comm_semiring

section linear_ordered_comm_ring

variables [topological_space Î²] [linear_ordered_comm_ring Î²] [order_topology Î²]

variables (l k f)

lemma superpolynomial_decay_iff_abs_tendsto_zero :
  superpolynomial_decay l k f â â (n : â), tendsto (Î» (a : Î±), |(k a) ^ n * f a|) l (ð 0) :=
â¨Î» h z, (tendsto_zero_iff_abs_tendsto_zero _).1 (h z),
  Î» h z, (tendsto_zero_iff_abs_tendsto_zero _).2 (h z)â©

lemma superpolynomial_decay_iff_superpolynomial_decay_abs :
  superpolynomial_decay l k f â superpolynomial_decay l (Î» a, |k a|) (Î» a, |f a|) :=
(superpolynomial_decay_iff_abs_tendsto_zero l k f).trans (by simp [superpolynomial_decay, abs_mul])

variables {l k f}

lemma superpolynomial_decay.trans_eventually_abs_le (hf : superpolynomial_decay l k f)
  (hfg : abs â g â¤á¶ [l] abs â f) : superpolynomial_decay l k g :=
begin
  rw superpolynomial_decay_iff_abs_tendsto_zero at hf â¢,
  refine Î» z, tendsto_of_tendsto_of_tendsto_of_le_of_le' (tendsto_const_nhds) (hf z)
    (eventually_of_forall $ Î» x, abs_nonneg _) (hfg.mono $ Î» x hx, _),
  calc |k x ^ z * g x| = |k x ^ z| * |g x| : abs_mul (k x ^ z) (g x)
    ... â¤ |k x ^ z| * |f x| : mul_le_mul le_rfl hx (abs_nonneg _) (abs_nonneg _)
    ... = |k x ^ z * f x| : (abs_mul (k x ^ z) (f x)).symm,
end

lemma superpolynomial_decay.trans_abs_le (hf : superpolynomial_decay l k f)
  (hfg : â x, |g x| â¤ |f x|) : superpolynomial_decay l k g :=
hf.trans_eventually_abs_le (eventually_of_forall hfg)

end linear_ordered_comm_ring

section field

variables [topological_space Î²] [field Î²] (l k f)

lemma superpolynomial_decay_mul_const_iff [has_continuous_mul Î²] {c : Î²} (hc0 : c â  0) :
  superpolynomial_decay l k (Î» n, f n * c) â superpolynomial_decay l k f :=
â¨Î» h, (h.mul_const câ»Â¹).congr (Î» x, by simp [mul_assoc, mul_inv_cancel hc0]), Î» h, h.mul_const câ©

lemma superpolynomial_decay_const_mul_iff [has_continuous_mul Î²] {c : Î²} (hc0 : c â  0) :
  superpolynomial_decay l k (Î» n, c * f n) â superpolynomial_decay l k f :=
â¨Î» h, (h.const_mul câ»Â¹).congr (Î» x, by simp [â mul_assoc, inv_mul_cancel hc0]), Î» h, h.const_mul câ©

variables {l k f}

end field

section linear_ordered_field

variables [topological_space Î²] [linear_ordered_field Î²] [order_topology Î²]

variable (f)

lemma superpolynomial_decay_iff_abs_is_bounded_under (hk : tendsto k l at_top) :
  superpolynomial_decay l k f â â (z : â), is_bounded_under (â¤) l (Î» (a : Î±), |(k a) ^ z * f a|) :=
begin
  refine â¨Î» h z, tendsto.is_bounded_under_le (tendsto.abs (h z)),
    Î» h, (superpolynomial_decay_iff_abs_tendsto_zero l k f).2 (Î» z, _)â©,
  obtain â¨m, hmâ© := h (z + 1),
  have h1 : tendsto (Î» (a : Î±), (0 : Î²)) l (ð 0) := tendsto_const_nhds,
  have h2 : tendsto (Î» (a : Î±), |(k a)â»Â¹| * m) l (ð 0) := (zero_mul m) â¸ tendsto.mul_const m
    ((tendsto_zero_iff_abs_tendsto_zero _).1 hk.inv_tendsto_at_top),
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' h1 h2
    (eventually_of_forall (Î» x, abs_nonneg _)) ((eventually_map.1 hm).mp _),
  refine ((eventually_ne_of_tendsto_at_top hk 0).mono $ Î» x hk0 hx, _),
  refine le_trans (le_of_eq _) (mul_le_mul_of_nonneg_left hx $ abs_nonneg (k x)â»Â¹),
  rw [â abs_mul, â mul_assoc, pow_succ, â mul_assoc, inv_mul_cancel hk0, one_mul],
end

lemma superpolynomial_decay_iff_zpow_tendsto_zero (hk : tendsto k l at_top) :
  superpolynomial_decay l k f â â (z : â¤), tendsto (Î» (a : Î±), (k a) ^ z * f a) l (ð 0) :=
begin
  refine â¨Î» h z, _, Î» h n, by simpa only [zpow_coe_nat] using h (n : â¤)â©,
  by_cases hz : 0 â¤ z,
  { lift z to â using hz,
    simpa using h z },
  { have : tendsto (Î» a, (k a) ^ z) l (ð 0) :=
      tendsto.comp (tendsto_zpow_at_top_zero (not_le.1 hz)) hk,
    have h : tendsto f l (ð 0) := by simpa using h 0,
    exact (zero_mul (0 : Î²)) â¸ this.mul h },
end

variable {f}

lemma superpolynomial_decay.param_zpow_mul (hk : tendsto k l at_top)
  (hf : superpolynomial_decay l k f) (z : â¤) : superpolynomial_decay l k (Î» a, k a ^ z * f a) :=
begin
  rw superpolynomial_decay_iff_zpow_tendsto_zero _ hk at hf â¢,
  refine Î» z', (hf $ z' + z).congr' ((eventually_ne_of_tendsto_at_top hk 0).mono (Î» x hx, _)),
  simp [zpow_addâ hx, mul_assoc, pi.mul_apply],
end

lemma superpolynomial_decay.mul_param_zpow (hk : tendsto k l at_top)
  (hf : superpolynomial_decay l k f) (z : â¤) : superpolynomial_decay l k (Î» a, f a * k a ^ z) :=
(hf.param_zpow_mul hk z).congr (Î» _, mul_comm _ _)

lemma superpolynomial_decay.inv_param_mul (hk : tendsto k l at_top)
  (hf : superpolynomial_decay l k f) : superpolynomial_decay l k (kâ»Â¹ * f) :=
by simpa using (hf.param_zpow_mul hk (-1))

lemma superpolynomial_decay.param_inv_mul (hk : tendsto k l at_top)
  (hf : superpolynomial_decay l k f) : superpolynomial_decay l k (f * kâ»Â¹) :=
(hf.inv_param_mul hk).congr (Î» _, mul_comm _ _)

variable (f)

lemma superpolynomial_decay_param_mul_iff (hk : tendsto k l at_top) :
  superpolynomial_decay l k (k * f) â superpolynomial_decay l k f :=
â¨Î» h, (h.inv_param_mul hk).congr' ((eventually_ne_of_tendsto_at_top hk 0).mono
  (Î» x hx, by simp [â mul_assoc, inv_mul_cancel hx])), Î» h, h.param_mulâ©

lemma superpolynomial_decay_mul_param_iff (hk : tendsto k l at_top) :
  superpolynomial_decay l k (f * k) â superpolynomial_decay l k f :=
by simpa [mul_comm k] using superpolynomial_decay_param_mul_iff f hk

lemma superpolynomial_decay_param_pow_mul_iff (hk : tendsto k l at_top) (n : â) :
  superpolynomial_decay l k (k ^ n * f) â superpolynomial_decay l k f :=
begin
  induction n with n hn,
  { simp },
  { simpa [pow_succ, â mul_comm k, mul_assoc,
      superpolynomial_decay_param_mul_iff (k ^ n * f) hk] using hn }
end

lemma superpolynomial_decay_mul_param_pow_iff (hk : tendsto k l at_top) (n : â) :
  superpolynomial_decay l k (f * k ^ n) â superpolynomial_decay l k f :=
by simpa [mul_comm f] using superpolynomial_decay_param_pow_mul_iff f hk n

variable {f}

end linear_ordered_field

section normed_linear_ordered_field

variable [normed_linear_ordered_field Î²]

variables (l k f)

lemma superpolynomial_decay_iff_norm_tendsto_zero :
  superpolynomial_decay l k f â â (n : â), tendsto (Î» (a : Î±), â¥(k a) ^ n * f aâ¥) l (ð 0) :=
â¨Î» h z, tendsto_zero_iff_norm_tendsto_zero.1 (h z),
  Î» h z, tendsto_zero_iff_norm_tendsto_zero.2 (h z)â©

lemma superpolynomial_decay_iff_superpolynomial_decay_norm :
  superpolynomial_decay l k f â superpolynomial_decay l (Î» a, â¥k aâ¥) (Î» a, â¥f aâ¥) :=
(superpolynomial_decay_iff_norm_tendsto_zero l k f).trans (by simp [superpolynomial_decay])

variables {l k}

variable [order_topology Î²]

lemma superpolynomial_decay_iff_is_O (hk : tendsto k l at_top) :
  superpolynomial_decay l k f â â (z : â¤), is_O f (Î» (a : Î±), (k a) ^ z) l :=
begin
  refine (superpolynomial_decay_iff_zpow_tendsto_zero f hk).trans _,
  have hk0 : âá¶  x in l, k x â  0 := eventually_ne_of_tendsto_at_top hk 0,
  refine â¨Î» h z, _, Î» h z, _â©,
  { refine is_O_of_div_tendsto_nhds (hk0.mono (Î» x hx hxz, absurd (zpow_eq_zero hxz) hx)) 0 _,
    have : (Î» (a : Î±), k a ^ z)â»Â¹ = (Î» (a : Î±), k a ^ (- z)) := funext (Î» x, by simp),
    rw [div_eq_mul_inv, mul_comm f, this],
    exact h (-z) },
  { suffices : is_O (Î» (a : Î±), k a ^ z * f a) (Î» (a : Î±), (k a)â»Â¹) l,
    from is_O.trans_tendsto this hk.inv_tendsto_at_top,
    refine ((is_O_refl (Î» a, (k a) ^ z) l).mul (h (- (z + 1)))).trans
      (is_O.of_bound 1 $ hk0.mono (Î» a ha0, _)),
    simp only [one_mul, neg_add z 1, zpow_addâ ha0, â mul_assoc, zpow_negâ,
      mul_inv_cancel (zpow_ne_zero z ha0), zpow_one] }
end

lemma superpolynomial_decay_iff_is_o (hk : tendsto k l at_top) :
  superpolynomial_decay l k f â â (z : â¤), is_o f (Î» (a : Î±), (k a) ^ z) l :=
begin
  refine â¨Î» h z, _, Î» h, (superpolynomial_decay_iff_is_O f hk).2 (Î» z, (h z).is_O)â©,
  have hk0 : âá¶  x in l, k x â  0 := eventually_ne_of_tendsto_at_top hk 0,
  have : is_o (Î» (x : Î±), (1 : Î²)) k l := is_o_of_tendsto'
    (hk0.mono (Î» x hkx hkx', absurd hkx' hkx)) (by simpa using hk.inv_tendsto_at_top),
  have : is_o f (Î» (x : Î±), k x * k x ^ (z - 1)) l,
  by simpa using this.mul_is_O (((superpolynomial_decay_iff_is_O f hk).1 h) $ z - 1),
  refine this.trans_is_O (is_O.of_bound 1 (hk0.mono $ Î» x hkx, le_of_eq _)),
  rw [one_mul, zpow_sub_oneâ hkx, mul_comm (k x), mul_assoc, inv_mul_cancel hkx, mul_one],
end

variable {f}

end normed_linear_ordered_field

end asymptotics
