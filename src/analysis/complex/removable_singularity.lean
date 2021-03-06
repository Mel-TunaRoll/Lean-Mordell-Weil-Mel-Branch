/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import analysis.calculus.fderiv_analytic
import analysis.asymptotics.specific_asymptotics
import analysis.complex.cauchy_integral

/-!
# Removable singularity theorem

In this file we prove Riemann's removable singularity theorem: if `f : β β E` is complex
differentiable in a punctured neighborhood of a point `c` and is bounded in a punctured neighborhood
of `c` (or, more generally, $f(z) - f(c)=o((z-c)^{-1})$), then it has a limit at `c` and the
function `function.update f c (lim (π[β ] c) f)` is complex differentiable in a neighborhood of `c`.
-/

open topological_space metric set filter asymptotics function
open_locale topological_space filter nnreal

universe u
variables {E : Type u} [normed_group E] [normed_space β E] [measurable_space E] [borel_space E]
  [second_countable_topology E] [complete_space E]

namespace complex

/-- **Removable singularity** theorem, weak version. If `f : β β E` is differentiable in a punctured
neighborhood of a point and is continuous at this point, then it is analytic at this point. -/
lemma analytic_at_of_differentiable_on_punctured_nhds_of_continuous_at {f : β β E} {c : β}
  (hd : βαΆ  z in π[β ] c, differentiable_at β f z) (hc : continuous_at f c) :
  analytic_at β f c :=
begin
  rcases (nhds_within_has_basis nhds_basis_closed_ball _).mem_iff.1 hd with β¨R, hR0, hRsβ©,
  lift R to ββ₯0 using hR0.le,
  replace hc : continuous_on f (closed_ball c R),
  { refine Ξ» z hz, continuous_at.continuous_within_at _,
    rcases eq_or_ne z c with rfl | hne,
    exacts [hc, (hRs β¨hz, hneβ©).continuous_at] },
  exact (has_fpower_series_on_ball_of_differentiable_off_countable (countable_singleton c) hc
    (Ξ» z hz, hRs (diff_subset_diff_left ball_subset_closed_ball hz)) hR0).analytic_at 
end

lemma differentiable_on_compl_singleton_and_continuous_at_iff {f : β β E} {s : set β} {c : β}
  (hs : s β π c) : differentiable_on β f (s \ {c}) β§ continuous_at f c β differentiable_on β f s :=
begin
  refine β¨_, Ξ» hd, β¨hd.mono (diff_subset _ _), (hd.differentiable_at hs).continuous_atβ©β©,
  rintro β¨hd, hcβ© x hx,
  rcases eq_or_ne x c with rfl | hne,
  { refine (analytic_at_of_differentiable_on_punctured_nhds_of_continuous_at _ hc)
      .differentiable_at.differentiable_within_at,
    refine eventually_nhds_within_iff.2 ((eventually_mem_nhds.2 hs).mono $ Ξ» z hz hzx, _),
    exact hd.differentiable_at (inter_mem hz (is_open_ne.mem_nhds hzx)) },
  { simpa only [differentiable_within_at, has_fderiv_within_at, hne.nhds_within_diff_singleton]
      using hd x β¨hx, hneβ© }
end

lemma differentiable_on_dslope {f : β β E} {s : set β} {c : β} (hc : s β π c) :
  differentiable_on β (dslope f c) s β differentiable_on β f s :=
β¨Ξ» h, h.of_dslope, Ξ» h, (differentiable_on_compl_singleton_and_continuous_at_iff hc).mp $
  β¨iff.mpr (differentiable_on_dslope_of_nmem $ Ξ» h, h.2 rfl) (h.mono $ diff_subset _ _),
    continuous_at_dslope_same.2 $ h.differentiable_at hcβ©β©

/-- **Removable singularity** theorem: if `s` is a neighborhood of `c : β`, a function `f : β β E`
is complex differentiable on `s \ {c}`, and $f(z) - f(c)=o((z-c)^{-1})$, then `f` redefined to be
equal to `lim (π[β ] c) f` at `c` is complex differentiable on `s`. -/
lemma differentiable_on_update_lim_of_is_o {f : β β E} {s : set β} {c : β}
  (hc : s β π c) (hd : differentiable_on β f (s \ {c}))
  (ho : is_o (Ξ» z, f z - f c) (Ξ» z, (z - c)β»ΒΉ) (π[β ] c)) :
  differentiable_on β (update f c (lim (π[β ] c) f)) s :=
begin
  set F : β β E := Ξ» z, (z - c) β’ f z with hF,
  suffices : differentiable_on β F (s \ {c}) β§ continuous_at F c,
  { rw [differentiable_on_compl_singleton_and_continuous_at_iff hc, β differentiable_on_dslope hc,
      dslope_sub_smul] at this; try { apply_instance },
    have hc : tendsto f (π[β ] c) (π (deriv F c)),
      from continuous_at_update_same.mp (this.continuous_on.continuous_at hc),
    rwa hc.lim_eq },
  refine β¨(differentiable_on_id.sub_const _).smul hd, _β©,
  rw β continuous_within_at_compl_self,
  have H := ho.tendsto_inv_smul_nhds_zero,
  have H' : tendsto (Ξ» z, (z - c) β’ f c) (π[β ] c) (π (F c)),
    from (continuous_within_at_id.tendsto.sub tendsto_const_nhds).smul tendsto_const_nhds,
  simpa [β smul_add, continuous_within_at] using H.add H'
end

/-- **Removable singularity** theorem: if `s` is a punctured neighborhood of `c : β`, a function
`f : β β E` is complex differentiable on `s`, and $f(z) - f(c)=o((z-c)^{-1})$, then `f` redefined to
be equal to `lim (π[β ] c) f` at `c` is complex differentiable on `{c} βͺ s`. -/
lemma differentiable_on_update_lim_insert_of_is_o {f : β β E} {s : set β} {c : β}
  (hc : s β π[β ] c) (hd : differentiable_on β f s)
  (ho : is_o (Ξ» z, f z - f c) (Ξ» z, (z - c)β»ΒΉ) (π[β ] c)) :
  differentiable_on β (update f c (lim (π[β ] c) f)) (insert c s) :=
differentiable_on_update_lim_of_is_o (insert_mem_nhds_iff.2 hc)
  (hd.mono $ Ξ» z hz, hz.1.resolve_left hz.2) ho

/-- **Removable singularity** theorem: if `s` is a neighborhood of `c : β`, a function `f : β β E`
is complex differentiable and is bounded on `s \ {c}`, then `f` redefined to be equal to
`lim (π[β ] c) f` at `c` is complex differentiable on `s`. -/
lemma differentiable_on_update_lim_of_bdd_above {f : β β E} {s : set β} {c : β}
  (hc : s β π c) (hd : differentiable_on β f (s \ {c}))
  (hb : bdd_above (norm β f '' (s \ {c}))) :
  differentiable_on β (update f c (lim (π[β ] c) f)) s :=
differentiable_on_update_lim_of_is_o hc hd $ is_bounded_under.is_o_sub_self_inv $
  let β¨C, hCβ© := hb in β¨C + β₯f cβ₯, eventually_map.2 $ mem_nhds_within_iff_exists_mem_nhds_inter.2
    β¨s, hc, Ξ» z hz, norm_sub_le_of_le (hC $ mem_image_of_mem _ hz) le_rflβ©β©

/-- **Removable singularity** theorem: if a function `f : β β E` is complex differentiable on a
punctured neighborhood of `c` and $f(z) - f(c)=o((z-c)^{-1})$, then `f` has a limit at `c`. -/
lemma tendsto_lim_of_differentiable_on_punctured_nhds_of_is_o {f : β β E} {c : β}
  (hd : βαΆ  z in π[β ] c, differentiable_at β f z)
  (ho : is_o (Ξ» z, f z - f c) (Ξ» z, (z - c)β»ΒΉ) (π[β ] c)) :
  tendsto f (π[β ] c) (π $ lim (π[β ] c) f) :=
begin
  rw eventually_nhds_within_iff at hd,
  have : differentiable_on β f ({z | z β  c β differentiable_at β f z} \ {c}),
    from Ξ» z hz, (hz.1 hz.2).differentiable_within_at,
  have H := differentiable_on_update_lim_of_is_o hd this ho,
  exact continuous_at_update_same.1 (H.differentiable_at hd).continuous_at
end

/-- **Removable singularity** theorem: if a function `f : β β E` is complex differentiable and
bounded on a punctured neighborhood of `c`, then `f` has a limit at `c`. -/
lemma tendsto_lim_of_differentiable_on_punctured_nhds_of_bounded_under {f : β β E}
  {c : β} (hd : βαΆ  z in π[β ] c, differentiable_at β f z)
  (hb : is_bounded_under (β€) (π[β ] c) (Ξ» z, β₯f z - f cβ₯)) :
  tendsto f (π[β ] c) (π $ lim (π[β ] c) f) :=
tendsto_lim_of_differentiable_on_punctured_nhds_of_is_o hd hb.is_o_sub_self_inv

end complex
