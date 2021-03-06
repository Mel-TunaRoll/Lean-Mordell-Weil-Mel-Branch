/-
Copyright (c) 2022 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Patrick Massot
-/
import topology.basic
/-!
# Neighborhoods of a set

In this file we define the filter `ğË¢ s` or `nhds_set s` consisting of all neighborhoods of a set
`s`.

## Main Properties

There are a couple different notions equivalent to `s â ğË¢ t`:
* `s â interior t` using `subset_interior_iff_mem_nhds_set`
* `â (x : Î±), x â t â s â ğ x` using `mem_nhds_set_iff_forall`
* `â U : set Î±, is_open U â§ t â U â§ U â s` using `mem_nhds_set_iff_exists`

Furthermore, we have the following results:
* `monotone_nhds_set`: `ğË¢` is monotone
* In Tâ-spaces, `ğË¢`is strictly monotone and hence injective:
  `strict_mono_nhds_set`/`injective_nhds_set`. These results are in `topology.separation`.
-/

open set filter
open_locale topological_space

variables {Î± : Type*} [topological_space Î±] {s t sâ sâ tâ tâ : set Î±} {x : Î±}

/-- The filter of neighborhoods of a set in a topological space. -/
def nhds_set (s : set Î±) : filter Î± :=
Sup (nhds '' s)

localized "notation `ğË¢` := nhds_set" in topological_space

lemma mem_nhds_set_iff_forall : s â ğË¢ t â â (x : Î±), x â t â s â ğ x :=
by simp_rw [nhds_set, filter.mem_Sup, ball_image_iff]

lemma subset_interior_iff_mem_nhds_set : s â interior t â t â ğË¢ s :=
by simp_rw [mem_nhds_set_iff_forall, subset_interior_iff_nhds]

lemma mem_nhds_set_iff_exists : s â ğË¢ t â â U : set Î±, is_open U â§ t â U â§ U â s :=
by { rw [â subset_interior_iff_mem_nhds_set, subset_interior_iff] }

lemma is_open.mem_nhds_set (hU : is_open s) : s â ğË¢ t â t â s :=
by rw [â subset_interior_iff_mem_nhds_set, interior_eq_iff_open.mpr hU]

@[simp] lemma nhds_set_singleton : ğË¢ {x} = ğ x :=
by { ext,
     rw [â subset_interior_iff_mem_nhds_set, â mem_interior_iff_mem_nhds, singleton_subset_iff] }

lemma mem_nhds_set_interior : s â ğË¢ (interior s) :=
subset_interior_iff_mem_nhds_set.mp subset.rfl

lemma mem_nhds_set_empty : s â ğË¢ (â : set Î±) :=
subset_interior_iff_mem_nhds_set.mp $ empty_subset _

@[simp] lemma nhds_set_empty : ğË¢ (â : set Î±) = â¥ :=
by { ext, simp [mem_nhds_set_empty] }

@[simp] lemma nhds_set_univ : ğË¢ (univ : set Î±) = â¤ :=
by { ext, rw [â subset_interior_iff_mem_nhds_set, univ_subset_iff, interior_eq_univ, mem_top] }

lemma monotone_nhds_set : monotone (ğË¢ : set Î± â filter Î±) :=
by { intros s t hst O, simp_rw [â subset_interior_iff_mem_nhds_set], exact subset.trans hst }

lemma union_mem_nhds_set (hâ : sâ â ğË¢ tâ) (hâ : sâ â ğË¢ tâ) : sâ âª sâ â ğË¢ (tâ âª tâ) :=
begin
  rw [â subset_interior_iff_mem_nhds_set] at *,
  exact union_subset
    (hâ.trans $ interior_mono $ subset_union_left _ _)
    (hâ.trans $ interior_mono $ subset_union_right _ _)
end
