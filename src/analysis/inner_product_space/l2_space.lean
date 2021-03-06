/-
Copyright (c) 2022 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth
-/
import analysis.inner_product_space.projection
import analysis.normed_space.lp_space

/-!
# Hilbert sum of a family of inner product spaces

Given a family `(G : ฮน โ Type*) [ฮ  i, inner_product_space ๐ (G i)]` of inner product spaces, this
file equips `lp G 2` with an inner product space structure, where `lp G 2` consists of those
dependent functions `f : ฮ  i, G i` for which `โ' i, โฅf iโฅ ^ 2`, the sum of the norms-squared, is
summable.  This construction is sometimes called the *Hilbert sum* of the family `G`.  By choosing
`G` to be `ฮน โ ๐`, the Hilbert space `โยฒ(ฮน, ๐)` may be seen as a special case of this construction.

## Main definitions

* `orthogonal_family.linear_isometry`: Given a Hilbert space `E`, a family `G` of inner product
  spaces and a family `V : ฮ  i, G i โโแตข[๐] E` of isometric embeddings of the `G i` into `E` with
  mutually-orthogonal images, there is an induced isometric embedding of the Hilbert sum of `G`
  into `E`.

* `orthogonal_family.linear_isometry_equiv`: Given a Hilbert space `E`, a family `G` of inner
  product spaces and a family `V : ฮ  i, G i โโแตข[๐] E` of isometric embeddings of the `G i` into `E`
  with mutually-orthogonal images whose span is dense in `E`, there is an induced isometric
  isomorphism of the Hilbert sum of `G` with `E`.

* `hilbert_basis`: We define a *Hilbert basis* of a Hilbert space `E` to be a structure whose single
  field `hilbert_basis.repr` is an isometric isomorphism of `E` with `โยฒ(ฮน, ๐)` (i.e., the Hilbert
  sum of `ฮน` copies of `๐`).  This parallels the definition of `basis`, in `linear_algebra.basis`,
  as an isomorphism of an `R`-module with `ฮน โโ R`.

* `hilbert_basis.has_coe_to_fun`: More conventionally a Hilbert basis is thought of as a family
  `ฮน โ E` of vectors in `E` satisfying certain properties (orthonormality, completeness).  We obtain
  this interpretation of a Hilbert basis `b` by defining `โb`, of type `ฮน โ E`, to be the image
  under `b.repr` of `lp.single 2 i (1:๐)`.  This parallels the definition `basis.has_coe_to_fun` in
  `linear_algebra.basis`.

* `hilbert_basis.mk`: Make a Hilbert basis of `E` from an orthonormal family `v : ฮน โ E` of vectors
  in `E` whose span is dense.  This parallels the definition `basis.mk` in `linear_algebra.basis`.

* `hilbert_basis.mk_of_orthogonal_eq_bot`: Make a Hilbert basis of `E` from an orthonormal family
  `v : ฮน โ E` of vectors in `E` whose span has trivial orthogonal complement.

## Main results

* `lp.inner_product_space`: Construction of the inner product space instance on the Hilbert sum
  `lp G 2`.  Note that from the file `analysis.normed_space.lp_space`, the space `lp G 2` already
  held a normed space instance (`lp.normed_space`), and if each `G i` is a Hilbert space (i.e.,
  complete), then `lp G 2` was already known to be complete (`lp.complete_space`).  So the work
  here is to define the inner product and show it is compatible.

* `orthogonal_family.range_linear_isometry`: Given a family `G` of inner product spaces and a family
  `V : ฮ  i, G i โโแตข[๐] E` of isometric embeddings of the `G i` into `E` with mutually-orthogonal
  images, the image of the embedding `orthogonal_family.linear_isometry` of the Hilbert sum of `G`
  into `E` is the closure of the span of the images of the `G i`.

* `hilbert_basis.repr_apply_apply`: Given a Hilbert basis `b` of `E`, the entry `b.repr x i` of
  `x`'s representation in `โยฒ(ฮน, ๐)` is the inner product `โชb i, xโซ`.

* `hilbert_basis.has_sum_repr`: Given a Hilbert basis `b` of `E`, a vector `x` in `E` can be
  expressed as the "infinite linear combination" `โ' i, b.repr x i โข b i` of the basis vectors
  `b i`, with coefficients given by the entries `b.repr x i` of `x`'s representation in `โยฒ(ฮน, ๐)`.

* `exists_hilbert_basis`: A Hilbert space admits a Hilbert basis.

## Keywords

Hilbert space, Hilbert sum, l2, Hilbert basis, unitary equivalence, isometric isomorphism
-/

open is_R_or_C submodule filter
open_locale big_operators nnreal ennreal classical complex_conjugate

noncomputable theory

variables {ฮน : Type*}
variables {๐ : Type*} [is_R_or_C ๐] {E : Type*} [inner_product_space ๐ E] [cplt : complete_space E]
variables {G : ฮน โ Type*} [ฮ  i, inner_product_space ๐ (G i)]
local notation `โช`x`, `y`โซ` := @inner ๐ _ _ x y

notation `โยฒ(` ฮน `,` ๐ `)` := lp (ฮป i : ฮน, ๐) 2

/-! ### Inner product space structure on `lp G 2` -/

namespace lp

lemma summable_inner (f g : lp G 2) : summable (ฮป i, โชf i, g iโซ) :=
begin
  -- Apply the Direct Comparison Test, comparing with โ' i, โฅf iโฅ * โฅg iโฅ (summable by Hรถlder)
  refine summable_of_norm_bounded (ฮป i, โฅf iโฅ * โฅg iโฅ) (lp.summable_mul _ f g) _,
  { rw real.is_conjugate_exponent_iff; norm_num },
  intros i,
  -- Then apply Cauchy-Schwarz pointwise
  exact norm_inner_le_norm _ _,
end

instance : inner_product_space ๐ (lp G 2) :=
{ inner := ฮป f g, โ' i, โชf i, g iโซ,
  norm_sq_eq_inner := ฮป f, begin
    calc โฅfโฅ ^ 2 = โฅfโฅ ^ (2:โโฅ0โ).to_real : by norm_cast
    ... = โ' i, โฅf iโฅ ^ (2:โโฅ0โ).to_real : lp.norm_rpow_eq_tsum _ f
    ... = โ' i, โฅf iโฅ ^ 2 : by norm_cast
    ... = โ' i, re โชf i, f iโซ : by simp only [norm_sq_eq_inner]
    ... = re (โ' i, โชf i, f iโซ) : (is_R_or_C.re_clm.map_tsum _).symm
    ... = _ : by congr,
    { norm_num },
    { exact summable_inner f f },
  end,
  conj_sym := ฮป f g, begin
    calc conj _ = conj โ' i, โชg i, f iโซ : by congr
    ... = โ' i, conj โชg i, f iโซ : is_R_or_C.conj_cle.map_tsum
    ... = โ' i, โชf i, g iโซ : by simp only [inner_conj_sym]
    ... = _ : by congr,
  end,
  add_left := ฮป fโ fโ g, begin
    calc _ = โ' i, โช(fโ + fโ) i, g iโซ : _
    ... = โ' i, (โชfโ i, g iโซ + โชfโ i, g iโซ) :
          by simp only [inner_add_left, pi.add_apply, coe_fn_add]
    ... = (โ' i, โชfโ i, g iโซ) + โ' i, โชfโ i, g iโซ : tsum_add _ _
    ... = _ : by congr,
    { congr, },
    { exact summable_inner fโ g },
    { exact summable_inner fโ g }
  end,
  smul_left := ฮป f g c, begin
    calc _ = โ' i, โชc โข f i, g iโซ : _
    ... = โ' i, conj c * โชf i, g iโซ : by simp only [inner_smul_left]
    ... = conj c * โ' i, โชf i, g iโซ : tsum_mul_left
    ... = _ : _,
    { simp only [coe_fn_smul, pi.smul_apply] },
    { congr },
  end,
  .. lp.normed_space }

lemma inner_eq_tsum (f g : lp G 2) : โชf, gโซ = โ' i, โชf i, g iโซ := rfl

lemma has_sum_inner (f g : lp G 2) : has_sum (ฮป i, โชf i, g iโซ) โชf, gโซ :=
(summable_inner f g).has_sum

lemma inner_single_left (i : ฮน) (a : G i) (f : lp G 2) : โชlp.single 2 i a, fโซ = โชa, f iโซ :=
begin
  refine (has_sum_inner (lp.single 2 i a) f).unique _,
  convert has_sum_ite_eq i โชa, f iโซ,
  ext j,
  rw lp.single_apply,
  split_ifs,
  { subst h },
  { simp }
end

lemma inner_single_right (i : ฮน) (a : G i) (f : lp G 2) : โชf, lp.single 2 i aโซ = โชf i, aโซ :=
by simpa [inner_conj_sym] using congr_arg conj (inner_single_left i a f)

end lp

/-! ### Identification of a general Hilbert space `E` with a Hilbert sum -/

namespace orthogonal_family
variables {V : ฮ  i, G i โโแตข[๐] E} (hV : orthogonal_family ๐ V)

include cplt hV

protected lemma summable_of_lp (f : lp G 2) : summable (ฮป i, V i (f i)) :=
begin
  rw hV.summable_iff_norm_sq_summable,
  convert (lp.mem_โp f).summable _,
  { norm_cast },
  { norm_num }
end

/-- A mutually orthogonal family of subspaces of `E` induce a linear isometry from `lp 2` of the
subspaces into `E`. -/
protected def linear_isometry : lp G 2 โโแตข[๐] E :=
{ to_fun := ฮป f, โ' i, V i (f i),
  map_add' := ฮป f g, by simp only [tsum_add (hV.summable_of_lp f) (hV.summable_of_lp g),
    lp.coe_fn_add, pi.add_apply, linear_isometry.map_add],
  map_smul' := ฮป c f, by simpa only [linear_isometry.map_smul, pi.smul_apply, lp.coe_fn_smul]
    using tsum_const_smul (hV.summable_of_lp f),
  norm_map' := ฮป f, begin
    classical, -- needed for lattice instance on `finset ฮน`, for `filter.at_top_ne_bot`
    have H : 0 < (2:โโฅ0โ).to_real := by norm_num,
    suffices : โฅโ' (i : ฮน), V i (f i)โฅ ^ ((2:โโฅ0โ).to_real) = โฅfโฅ ^ ((2:โโฅ0โ).to_real),
    { exact real.rpow_left_inj_on H.ne' (norm_nonneg _) (norm_nonneg _) this },
    refine tendsto_nhds_unique  _ (lp.has_sum_norm H f),
    convert (hV.summable_of_lp f).has_sum.norm.rpow_const (or.inr H.le),
    ext s,
    exact_mod_cast (hV.norm_sum f s).symm,
  end }

protected lemma linear_isometry_apply (f : lp G 2) :
  hV.linear_isometry f = โ' i, V i (f i) :=
rfl

protected lemma has_sum_linear_isometry (f : lp G 2) :
  has_sum (ฮป i, V i (f i)) (hV.linear_isometry f) :=
(hV.summable_of_lp f).has_sum

@[simp] protected lemma linear_isometry_apply_single {i : ฮน} (x : G i) :
  hV.linear_isometry (lp.single 2 i x) = V i x :=
begin
  rw [hV.linear_isometry_apply, โ tsum_ite_eq i (V i x)],
  congr,
  ext j,
  rw [lp.single_apply],
  split_ifs,
  { subst h },
  { simp }
end

@[simp] protected lemma linear_isometry_apply_dfinsupp_sum_single (Wโ : ฮ โ (i : ฮน), G i) :
  hV.linear_isometry (Wโ.sum (lp.single 2)) = Wโ.sum (ฮป i, V i) :=
begin
  have : hV.linear_isometry (โ i in Wโ.support, lp.single 2 i (Wโ i))
    = โ i in Wโ.support, hV.linear_isometry (lp.single 2 i (Wโ i)),
  { exact hV.linear_isometry.to_linear_map.map_sum },
  simp [dfinsupp.sum, this] {contextual := tt},
end

/-- The canonical linear isometry from the `lp 2` of a mutually orthogonal family of subspaces of
`E` into E, has range the closure of the span of the subspaces. -/
protected lemma range_linear_isometry [ฮ  i, complete_space (G i)] :
  hV.linear_isometry.to_linear_map.range = (โจ i, (V i).to_linear_map.range).topological_closure :=
begin
  classical,
  refine le_antisymm _ _,
  { rintros x โจf, rflโฉ,
    refine mem_closure_of_tendsto (hV.has_sum_linear_isometry f) (eventually_of_forall _),
    intros s,
    refine sum_mem (supr (ฮป i, (V i).to_linear_map.range)) _,
    intros i hi,
    refine mem_supr_of_mem i _,
    exact linear_map.mem_range_self _ (f i) },
  { apply topological_closure_minimal,
    { refine supr_le _,
      rintros i x โจx, rflโฉ,
      use lp.single 2 i x,
      convert hV.linear_isometry_apply_single _ },
    exact hV.linear_isometry.isometry.uniform_inducing.is_complete_range.is_closed }
end

/-- A mutually orthogonal family of complete subspaces of `E`, whose range is dense in `E`, induces
a isometric isomorphism from E to `lp 2` of the subspaces.

Note that this goes in the opposite direction from `orthogonal_family.linear_isometry`. -/
noncomputable def linear_isometry_equiv [ฮ  i, complete_space (G i)]
  (hV' : (โจ i, (V i).to_linear_map.range).topological_closure = โค) :
  E โโแตข[๐] lp G 2 :=
linear_isometry_equiv.symm $
linear_isometry_equiv.of_surjective
hV.linear_isometry
begin
  refine linear_map.range_eq_top.mp _,
  rw โ hV',
  rw hV.range_linear_isometry,
end

/-- In the canonical isometric isomorphism `E โโแตข[๐] lp G 2` induced by an orthogonal family `G`,
a vector `w : lp G 2` is the image of the infinite sum of the associated elements in `E`. -/
protected lemma linear_isometry_equiv_symm_apply [ฮ  i, complete_space (G i)]
  (hV' : (โจ i, (V i).to_linear_map.range).topological_closure = โค) (w : lp G 2) :
  (hV.linear_isometry_equiv hV').symm w = โ' i, V i (w i) :=
by simp [orthogonal_family.linear_isometry_equiv, orthogonal_family.linear_isometry_apply]

/-- In the canonical isometric isomorphism `E โโแตข[๐] lp G 2` induced by an orthogonal family `G`,
a vector `w : lp G 2` is the image of the infinite sum of the associated elements in `E`, and this
sum indeed converges. -/
protected lemma has_sum_linear_isometry_equiv_symm [ฮ  i, complete_space (G i)]
  (hV' : (โจ i, (V i).to_linear_map.range).topological_closure = โค) (w : lp G 2) :
  has_sum (ฮป i, V i (w i)) ((hV.linear_isometry_equiv hV').symm w) :=
by simp [orthogonal_family.linear_isometry_equiv, orthogonal_family.has_sum_linear_isometry]

/-- In the canonical isometric isomorphism `E โโแตข[๐] lp G 2` induced by an `ฮน`-indexed orthogonal
family `G`, an "elementary basis vector" in `lp G 2` supported at `i : ฮน` is the image of the
associated element in `E`. -/
@[simp] protected lemma linear_isometry_equiv_symm_apply_single [ฮ  i, complete_space (G i)]
  (hV' : (โจ i, (V i).to_linear_map.range).topological_closure = โค) {i : ฮน} (x : G i) :
  (hV.linear_isometry_equiv hV').symm (lp.single 2 i x) = V i x :=
by simp [orthogonal_family.linear_isometry_equiv, orthogonal_family.linear_isometry_apply_single]

/-- In the canonical isometric isomorphism `E โโแตข[๐] lp G 2` induced by an `ฮน`-indexed orthogonal
family `G`, a finitely-supported vector in `lp G 2` is the image of the associated finite sum of
elements of `E`. -/
@[simp] protected lemma linear_isometry_equiv_symm_apply_dfinsupp_sum_single
  [ฮ  i, complete_space (G i)]
  (hV' : (โจ i, (V i).to_linear_map.range).topological_closure = โค) (Wโ : ฮ โ (i : ฮน), G i) :
  (hV.linear_isometry_equiv hV').symm (Wโ.sum (lp.single 2)) = (Wโ.sum (ฮป i, V i)) :=
by simp [orthogonal_family.linear_isometry_equiv,
  orthogonal_family.linear_isometry_apply_dfinsupp_sum_single]

/-- In the canonical isometric isomorphism `E โโแตข[๐] lp G 2` induced by an `ฮน`-indexed orthogonal
family `G`, a finitely-supported vector in `lp G 2` is the image of the associated finite sum of
elements of `E`. -/
@[simp] protected lemma linear_isometry_equiv_apply_dfinsupp_sum_single
  [ฮ  i, complete_space (G i)]
  (hV' : (โจ i, (V i).to_linear_map.range).topological_closure = โค) (Wโ : ฮ โ (i : ฮน), G i) :
  (hV.linear_isometry_equiv hV' (Wโ.sum (ฮป i, V i)) : ฮ  i, G i) = Wโ :=
begin
  rw โ hV.linear_isometry_equiv_symm_apply_dfinsupp_sum_single hV',
  rw linear_isometry_equiv.apply_symm_apply,
  ext i,
  simp [dfinsupp.sum, lp.single_apply] {contextual := tt},
end

end orthogonal_family

/-! ### Hilbert bases -/

section
variables (ฮน) (๐) (E)

/-- A Hilbert basis on `ฮน` for an inner product space `E` is an identification of `E` with the `lp`
space `โยฒ(ฮน, ๐)`. -/
structure hilbert_basis := of_repr :: (repr : E โโแตข[๐] โยฒ(ฮน, ๐))

end

namespace hilbert_basis

instance {ฮน : Type*} : inhabited (hilbert_basis ฮน ๐ โยฒ(ฮน, ๐)) :=
โจof_repr (linear_isometry_equiv.refl ๐ _)โฉ

/-- `b i` is the `i`th basis vector. -/
instance : has_coe_to_fun (hilbert_basis ฮน ๐ E) (ฮป _, ฮน โ E) :=
{ coe := ฮป b i, b.repr.symm (lp.single 2 i (1:๐)) }

@[simp] protected lemma repr_symm_single (b : hilbert_basis ฮน ๐ E) (i : ฮน) :
  b.repr.symm (lp.single 2 i (1:๐)) = b i :=
rfl

@[simp] protected lemma repr_self (b : hilbert_basis ฮน ๐ E) (i : ฮน) :
  b.repr (b i) = lp.single 2 i (1:๐) :=
by rw [โ b.repr_symm_single, linear_isometry_equiv.apply_symm_apply]

protected lemma repr_apply_apply (b : hilbert_basis ฮน ๐ E) (v : E) (i : ฮน) :
  b.repr v i = โชb i, vโซ :=
begin
  rw [โ b.repr.inner_map_map (b i) v, b.repr_self, lp.inner_single_left],
  simp,
end

@[simp] protected lemma orthonormal (b : hilbert_basis ฮน ๐ E) : orthonormal ๐ b :=
begin
  rw orthonormal_iff_ite,
  intros i j,
  rw [โ b.repr.inner_map_map (b i) (b j), b.repr_self, b.repr_self, lp.inner_single_left,
    lp.single_apply],
  simp,
end

protected lemma has_sum_repr_symm (b : hilbert_basis ฮน ๐ E) (f : โยฒ(ฮน, ๐)) :
  has_sum (ฮป i, f i โข b i) (b.repr.symm f) :=
begin
  suffices H : (ฮป (i : ฮน), f i โข b i) =
    (ฮป (b_1 : ฮน), (b.repr.symm.to_continuous_linear_equiv) ((ฮป (i : ฮน), lp.single 2 i (f i)) b_1)),
  { rw H,
    have : has_sum (ฮป (i : ฮน), lp.single 2 i (f i)) f := lp.has_sum_single ennreal.two_ne_top f,
    exact (โ(b.repr.symm.to_continuous_linear_equiv) : โยฒ(ฮน, ๐) โL[๐] E).has_sum this },
  ext i,
  apply b.repr.injective,
  have : lp.single 2 i (f i * 1) = f i โข lp.single 2 i 1 := lp.single_smul 2 i (1:๐) (f i),
  rw mul_one at this,
  rw [linear_isometry_equiv.map_smul, b.repr_self, โ this,
    linear_isometry_equiv.coe_to_continuous_linear_equiv],
  exact (b.repr.apply_symm_apply (lp.single 2 i (f i))).symm,
end

protected lemma has_sum_repr (b : hilbert_basis ฮน ๐ E) (x : E) :
  has_sum (ฮป i, b.repr x i โข b i) x :=
by simpa using b.has_sum_repr_symm (b.repr x)

@[simp] protected lemma dense_span (b : hilbert_basis ฮน ๐ E) :
  (span ๐ (set.range b)).topological_closure = โค :=
begin
  classical,
  rw eq_top_iff,
  rintros x -,
  refine mem_closure_of_tendsto (b.has_sum_repr x) (eventually_of_forall _),
  intros s,
  simp only [set_like.mem_coe],
  refine sum_mem _ _,
  rintros i -,
  refine smul_mem _ _ _,
  exact subset_span โจi, rflโฉ
end

variables {v : ฮน โ E} (hv : orthonormal ๐ v)
include hv cplt

/-- An orthonormal family of vectors whose span is dense in the whole module is a Hilbert basis. -/
protected def mk (hsp : (span ๐ (set.range v)).topological_closure = โค) :
  hilbert_basis ฮน ๐ E :=
hilbert_basis.of_repr $
hv.orthogonal_family.linear_isometry_equiv
begin
  convert hsp,
  simp [โ linear_map.span_singleton_eq_range, โ submodule.span_Union],
end

@[simp] protected lemma coe_mk (hsp : (span ๐ (set.range v)).topological_closure = โค) :
  โ(hilbert_basis.mk hv hsp) = v :=
begin
  ext i,
  show (hilbert_basis.mk hv hsp).repr.symm _ = v i,
  simp [hilbert_basis.mk]
end

/-- An orthonormal family of vectors whose span has trivial orthogonal complement is a Hilbert
basis. -/
protected def mk_of_orthogonal_eq_bot (hsp : (span ๐ (set.range v))แฎ = โฅ) : hilbert_basis ฮน ๐ E :=
hilbert_basis.mk hv
(by rw [โ orthogonal_orthogonal_eq_closure, orthogonal_eq_top_iff, hsp])

@[simp] protected lemma coe_of_orthogonal_eq_bot_mk (hsp : (span ๐ (set.range v))แฎ = โฅ) :
  โ(hilbert_basis.mk_of_orthogonal_eq_bot hv hsp) = v :=
hilbert_basis.coe_mk hv _

omit hv

/-- A Hilbert space admits a Hilbert basis extending a given orthonormal subset. -/
lemma _root_.orthonormal.exists_hilbert_basis_extension
  {s : set E} (hs : orthonormal ๐ (coe : s โ E)) :
  โ (w : set E) (b : hilbert_basis w ๐ E), s โ w โง โb = (coe : w โ E) :=
let โจw, hws, hw_ortho, hw_maxโฉ := exists_maximal_orthonormal hs in
โจ w,
  hilbert_basis.mk_of_orthogonal_eq_bot hw_ortho
    (by simpa [maximal_orthonormal_iff_orthogonal_complement_eq_bot hw_ortho] using hw_max),
  hws,
  hilbert_basis.coe_of_orthogonal_eq_bot_mk _ _ โฉ

variables (๐ E)

/-- A Hilbert space admits a Hilbert basis. -/
lemma _root_.exists_hilbert_basis :
  โ (w : set E) (b : hilbert_basis w ๐ E), โb = (coe : w โ E) :=
let โจw, hw, hw', hw''โฉ := (orthonormal_empty ๐ E).exists_hilbert_basis_extension in โจw, hw, hw''โฉ

end hilbert_basis
