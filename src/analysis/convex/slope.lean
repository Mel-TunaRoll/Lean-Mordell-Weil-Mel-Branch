/-
Copyright (c) 2021 Yury Kudriashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudriashov, Malo JaffrÃ©
-/
import analysis.convex.function

/-!
# Slopes of convex functions

This file relates convexity/concavity of functions in a linearly ordered field and the monotonicity
of their slopes.

The main use is to show convexity/concavity from monotonicity of the derivative.
-/

variables {ð : Type*} [linear_ordered_field ð] {s : set ð} {f : ð â ð}

/-- If `f : ð â ð` is convex, then for any three points `x < y < z` the slope of the secant line of
`f` on `[x, y]` is less than the slope of the secant line of `f` on `[x, z]`. -/
lemma convex_on.slope_mono_adjacent (hf : convex_on ð s f)
  {x y z : ð} (hx : x â s) (hz : z â s) (hxy : x < y) (hyz : y < z) :
  (f y - f x) / (y - x) â¤ (f z - f y) / (z - y) :=
begin
  have hxz := hxy.trans hyz,
  rw âsub_pos at hxy hxz hyz,
  suffices : f y / (y - x) + f y / (z - y) â¤ f x / (y - x) + f z / (z - y),
  { ring_nf at this â¢, linarith },
  set a := (z - y) / (z - x),
  set b := (y - x) / (z - x),
  have hy : a â¢ x + b â¢ z = y, by { field_simp, rw div_eq_iff; [ring, linarith] },
  have key, from
    hf.2 hx hz
      (show 0 â¤ a, by apply div_nonneg; linarith)
      (show 0 â¤ b, by apply div_nonneg; linarith)
      (show a + b = 1, by { field_simp, rw div_eq_iff; [ring, linarith] }),
  rw hy at key,
  replace key := mul_le_mul_of_nonneg_left key hxz.le,
  field_simp [hxy.ne', hyz.ne', hxz.ne', mul_comm (z - x) _] at key â¢,
  rw div_le_div_right,
  { linarith },
  { nlinarith }
end

/-- If `f : ð â ð` is concave, then for any three points `x < y < z` the slope of the secant line of
`f` on `[x, y]` is greater than the slope of the secant line of `f` on `[x, z]`. -/
lemma concave_on.slope_anti_adjacent (hf : concave_on ð s f) {x y z : ð} (hx : x â s)
  (hz : z â s) (hxy : x < y) (hyz : y < z) :
  (f z - f y) / (z - y) â¤ (f y - f x) / (y - x) :=
begin
  rw [âneg_le_neg_iff, âneg_sub_neg (f x), âneg_sub_neg (f y)],
  simp_rw [âpi.neg_apply, âneg_div, neg_sub],
  exact convex_on.slope_mono_adjacent hf.neg hx hz hxy hyz,
end

/-- If `f : ð â ð` is strictly convex, then for any three points `x < y < z` the slope of the
secant line of `f` on `[x, y]` is strictly less than the slope of the secant line of `f` on
`[x, z]`. -/
lemma strict_convex_on.slope_strict_mono_adjacent (hf : strict_convex_on ð s f)
  {x y z : ð} (hx : x â s) (hz : z â s) (hxy : x < y) (hyz : y < z) :
  (f y - f x) / (y - x) < (f z - f y) / (z - y) :=
begin
  have hxz := hxy.trans hyz,
  have hxz' := hxz.ne,
  rw âsub_pos at hxy hxz hyz,
  suffices : f y / (y - x) + f y / (z - y) < f x / (y - x) + f z / (z - y),
  { ring_nf at this â¢, linarith },
  set a := (z - y) / (z - x),
  set b := (y - x) / (z - x),
  have hy : a â¢ x + b â¢ z = y, by { field_simp, rw div_eq_iff; [ring, linarith] },
  have key, from
    hf.2 hx hz hxz' (div_pos hyz hxz) (div_pos hxy hxz)
      (show a + b = 1, by { field_simp, rw div_eq_iff; [ring, linarith] }),
  rw hy at key,
  replace key := mul_lt_mul_of_pos_left key hxz,
  field_simp [hxy.ne', hyz.ne', hxz.ne', mul_comm (z - x) _] at key â¢,
  rw div_lt_div_right,
  { linarith },
  { nlinarith }
end

/-- If `f : ð â ð` is strictly concave, then for any three points `x < y < z` the slope of the
secant line of `f` on `[x, y]` is strictly greater than the slope of the secant line of `f` on
`[x, z]`. -/
lemma strict_concave_on.slope_anti_adjacent (hf : strict_concave_on ð s f)
  {x y z : ð} (hx : x â s) (hz : z â s) (hxy : x < y) (hyz : y < z) :
  (f z - f y) / (z - y) < (f y - f x) / (y - x) :=
begin
  rw [âneg_lt_neg_iff, âneg_sub_neg (f x), âneg_sub_neg (f y)],
  simp_rw [âpi.neg_apply, âneg_div, neg_sub],
  exact strict_convex_on.slope_strict_mono_adjacent hf.neg hx hz hxy hyz,
end

/-- If for any three points `x < y < z`, the slope of the secant line of `f : ð â ð` on `[x, y]` is
less than the slope of the secant line of `f` on `[x, z]`, then `f` is convex. -/
lemma convex_on_of_slope_mono_adjacent (hs : convex ð s)
  (hf : â {x y z : ð}, x â s â z â s â x < y â y < z â
    (f y - f x) / (y - x) â¤ (f z - f y) / (z - y)) :
  convex_on ð s f :=
linear_order.convex_on_of_lt hs
begin
  assume x z hx hz hxz a b ha hb hab,
  let y := a * x + b * z,
  have hxy : x < y,
  { rw [â one_mul x, â hab, add_mul],
    exact add_lt_add_left ((mul_lt_mul_left hb).2 hxz) _ },
  have hyz : y < z,
  { rw [â one_mul z, â hab, add_mul],
    exact add_lt_add_right ((mul_lt_mul_left ha).2 hxz) _ },
  have : (f y - f x) * (z - y) â¤ (f z - f y) * (y - x),
    from (div_le_div_iff (sub_pos.2 hxy) (sub_pos.2 hyz)).1 (hf hx hz hxy hyz),
  have hxz : 0 < z - x, from sub_pos.2 (hxy.trans hyz),
  have ha : (z - y) / (z - x) = a,
  { rw [eq_comm, â sub_eq_iff_eq_add'] at hab,
    simp_rw [div_eq_iff hxz.ne', y, âhab], ring },
  have hb : (y - x) / (z - x) = b,
  { rw [eq_comm, â sub_eq_iff_eq_add] at hab,
    simp_rw [div_eq_iff hxz.ne', y, âhab], ring },
  rwa [sub_mul, sub_mul, sub_le_iff_le_add', â add_sub_assoc, le_sub_iff_add_le, â mul_add,
    sub_add_sub_cancel, â le_div_iff hxz, add_div, mul_div_assoc, mul_div_assoc, mul_comm (f x),
    mul_comm (f z), ha, hb] at this,
end

/-- If for any three points `x < y < z`, the slope of the secant line of `f : ð â ð` on `[x, y]` is
greater than the slope of the secant line of `f` on `[x, z]`, then `f` is concave. -/
lemma concave_on_of_slope_anti_adjacent (hs : convex ð s)
  (hf : â {x y z : ð}, x â s â z â s â x < y â y < z â
    (f z - f y) / (z - y) â¤ (f y - f x) / (y - x)) : concave_on ð s f :=
begin
  rw âneg_convex_on_iff,
  refine convex_on_of_slope_mono_adjacent hs (Î» x y z hx hz hxy hyz, _),
  rw âneg_le_neg_iff,
  simp_rw [âneg_div, neg_sub, pi.neg_apply, neg_sub_neg],
  exact hf hx hz hxy hyz,
end

/-- If for any three points `x < y < z`, the slope of the secant line of `f : ð â ð` on `[x, y]` is
strictly less than the slope of the secant line of `f` on `[x, z]`, then `f` is strictly convex. -/
lemma strict_convex_on_of_slope_strict_mono_adjacent (hs : convex ð s)
  (hf : â {x y z : ð}, x â s â z â s â x < y â y < z â
    (f y - f x) / (y - x) < (f z - f y) / (z - y)) :
  strict_convex_on ð s f :=
linear_order.strict_convex_on_of_lt hs
begin
  assume x z hx hz hxz a b ha hb hab,
  let y := a * x + b * z,
  have hxy : x < y,
  { rw [â one_mul x, â hab, add_mul],
    exact add_lt_add_left ((mul_lt_mul_left hb).2 hxz) _ },
  have hyz : y < z,
  { rw [â one_mul z, â hab, add_mul],
    exact add_lt_add_right ((mul_lt_mul_left ha).2 hxz) _ },
  have : (f y - f x) * (z - y) < (f z - f y) * (y - x),
    from (div_lt_div_iff (sub_pos.2 hxy) (sub_pos.2 hyz)).1 (hf hx hz hxy hyz),
  have hxz : 0 < z - x, from sub_pos.2 (hxy.trans hyz),
  have ha : (z - y) / (z - x) = a,
  { rw [eq_comm, â sub_eq_iff_eq_add'] at hab,
    simp_rw [div_eq_iff hxz.ne', y, âhab], ring },
  have hb : (y - x) / (z - x) = b,
  { rw [eq_comm, â sub_eq_iff_eq_add] at hab,
    simp_rw [div_eq_iff hxz.ne', y, âhab], ring },
  rwa [sub_mul, sub_mul, sub_lt_iff_lt_add', â add_sub_assoc, lt_sub_iff_add_lt, â mul_add,
    sub_add_sub_cancel, â lt_div_iff hxz, add_div, mul_div_assoc, mul_div_assoc, mul_comm (f x),
    mul_comm (f z), ha, hb] at this,
end

/-- If for any three points `x < y < z`, the slope of the secant line of `f : ð â ð` on `[x, y]` is
strictly greater than the slope of the secant line of `f` on `[x, z]`, then `f` is strictly concave.
-/
lemma strict_concave_on_of_slope_strict_anti_adjacent (hs : convex ð s)
  (hf : â {x y z : ð}, x â s â z â s â x < y â y < z â
    (f z - f y) / (z - y) < (f y - f x) / (y - x)) : strict_concave_on ð s f :=
begin
  rw âneg_strict_convex_on_iff,
  refine strict_convex_on_of_slope_strict_mono_adjacent hs (Î» x y z hx hz hxy hyz, _),
  rw âneg_lt_neg_iff,
  simp_rw [âneg_div, neg_sub, pi.neg_apply, neg_sub_neg],
  exact hf hx hz hxy hyz,
end

/-- A function `f : ð â ð` is convex iff for any three points `x < y < z` the slope of the secant
line of `f` on `[x, y]` is less than the slope of the secant line of `f` on `[x, z]`. -/
lemma convex_on_iff_slope_mono_adjacent :
  convex_on ð s f â convex ð s â§
    â â¦x y z : ðâ¦, x â s â z â s â x < y â y < z â
      (f y - f x) / (y - x) â¤ (f z - f y) / (z - y) :=
â¨Î» h, â¨h.1, Î» x y z, h.slope_mono_adjacentâ©, Î» h, convex_on_of_slope_mono_adjacent h.1 h.2â©

/-- A function `f : ð â ð` is concave iff for any three points `x < y < z` the slope of the secant
line of `f` on `[x, y]` is greater than the slope of the secant line of `f` on `[x, z]`. -/
lemma concave_on_iff_slope_anti_adjacent :
  concave_on ð s f â convex ð s â§
    â â¦x y z : ðâ¦, x â s â z â s â x < y â y < z â
      (f z - f y) / (z - y) â¤ (f y - f x) / (y - x) :=
â¨Î» h, â¨h.1, Î» x y z, h.slope_anti_adjacentâ©, Î» h, concave_on_of_slope_anti_adjacent h.1 h.2â©

/-- A function `f : ð â ð` is strictly convex iff for any three points `x < y < z` the slope of
the secant line of `f` on `[x, y]` is strictly less than the slope of the secant line of `f` on
`[x, z]`. -/
lemma strict_convex_on_iff_slope_strict_mono_adjacent :
  strict_convex_on ð s f â convex ð s â§
    â â¦x y z : ðâ¦, x â s â z â s â x < y â y < z â
      (f y - f x) / (y - x) < (f z - f y) / (z - y) :=
â¨Î» h, â¨h.1, Î» x y z, h.slope_strict_mono_adjacentâ©,
  Î» h, strict_convex_on_of_slope_strict_mono_adjacent h.1 h.2â©

/-- A function `f : ð â ð` is strictly concave iff for any three points `x < y < z` the slope of
the secant line of `f` on `[x, y]` is strictly greater than the slope of the secant line of `f` on
`[x, z]`. -/
lemma strict_concave_on_iff_slope_strict_anti_adjacent :
  strict_concave_on ð s f â convex ð s â§
    â â¦x y z : ðâ¦, x â s â z â s â x < y â y < z â
      (f z - f y) / (z - y) < (f y - f x) / (y - x) :=
â¨Î» h, â¨h.1, Î» x y z, h.slope_anti_adjacentâ©,
  Î» h, strict_concave_on_of_slope_strict_anti_adjacent h.1 h.2â©
