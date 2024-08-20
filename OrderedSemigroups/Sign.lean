import OrderedSemigroups.Basic

/-!
# Sign of element in Ordered Semigroup

This file defines what it means for an element of an ordered semigroup
to be positive, negative, or one. It also proves some basic facts about signs.
-/

section OrderedSemigroup
variable [OrderedSemigroup α]

def is_positive (a : α) := ∀x : α, a*x > x
def is_negative (a : α) := ∀x : α, a*x < x
def is_one (a : α) := ∀x : α, a*x = x

theorem pos_not_neg {a : α} (is_pos : is_positive a) : ¬is_negative a := by
  intro is_neg
  rw [is_positive, is_negative] at *
  exact (lt_self_iff_false (a * a)).mp (lt_trans (is_neg a) (is_pos a))

theorem pos_not_one {a : α} (is_pos : is_positive a) : ¬is_one a := by
  intro is_zer
  rw [is_positive, is_one] at *
  have is_pos := is_pos a
  simp [is_zer a] at is_pos

theorem neg_not_pos {a : α} (is_neg : is_negative a) : ¬is_positive a := by
  intro is_pos
  rw [is_positive, is_negative] at *
  exact (lt_self_iff_false a).mp (lt_trans (is_pos a) (is_neg a))

theorem neg_not_one {a : α} (is_neg : is_negative a) : ¬is_one a := by
  intro is_zer
  rw [is_negative, is_one] at *
  have is_neg := is_neg a
  simp [is_zer a] at is_neg

theorem one_not_pos {a : α} (is_zer : is_one a) : ¬is_positive a := by
  intro is_pos
  rw [is_positive, is_one] at *
  have is_pos := is_pos a
  rw [is_zer a] at is_pos
  exact (lt_self_iff_false a).mp is_pos

theorem one_not_neg {a : α} (is_zer : is_one a) : ¬is_negative a := by
  intro is_neg
  rw [is_negative, is_one] at *
  have is_neg := is_neg a
  rw [is_zer a] at is_neg
  exact (lt_self_iff_false a).mp is_neg

theorem pos_le_pos {a b : α} (pos : is_positive a) (h : a ≤ b) : is_positive b :=
  fun x ↦ lt_mul_of_lt_mul_right (pos x) h

theorem le_neg_neg {a b : α} (neg : is_negative a) (h : b ≤ a) : is_negative b :=
  fun x ↦ mul_lt_of_mul_lt_right (neg x) h

theorem pos_pow_pos {a : α} (pos : is_positive a) (n : ℕ+) : is_positive (a^n) := by
  intro x
  induction n using PNat.recOn with
  | p1 => simp [pos x]
  | hp n ih =>
    simp [ppow_succ']
    have : a * a^n * x > a^n * x := by simp [pos (a^n*x), mul_assoc]
    exact gt_trans this ih

theorem neg_pow_neg {a : α} (neg : is_negative a) (n : ℕ+) : is_negative (a^n) := by
  intro x
  induction n using PNat.recOn with
  | p1 => simp [neg x]
  | hp n ih =>
    simp [ppow_succ']
    have : a * a^n * x < a^n * x := by simp [neg (a^n*x), mul_assoc]
    exact gt_trans ih this

theorem one_pow_one {a : α} (one : is_one a) (n : ℕ+) : is_one (a^n) := by
  intro x
  induction n using PNat.recOn with
  | p1 => simp [one x]
  | hp n ih => simp [ppow_succ', mul_assoc, ih, one x]

def same_sign (a b : α) :=
  (is_positive a ∧ is_positive b) ∨
  (is_negative a ∧ is_negative b) ∨
  (is_one a ∧ is_one b)

end OrderedSemigroup

section LinearOrderedCancelSemigroup
variable [LinearOrderedCancelSemigroup α]

theorem pos_gt_one {a b : α} (one : is_one a) (h : a < b) : is_positive b :=
  fun x ↦ lt_of_eq_of_lt (id (Eq.symm (one x))) (mul_lt_mul_right' h x)

theorem neg_lt_one {a b : α} (one : is_one a) (h : b < a) : is_negative b :=
  fun x ↦ lt_of_lt_of_eq (mul_lt_mul_right' h x) (one x)

theorem neg_lt_pos {a b : α} (neg : is_negative a) (pos : is_positive b) : a < b :=
  lt_of_mul_lt_mul_right' (gt_trans (pos b) (neg b))

lemma pos_right_pos_forall {a b : α} (h : b * a > b) : is_positive a := by
  intro x
  have : b * a * x > b * x := mul_lt_mul_right' h x
  simpa [mul_assoc]

lemma neg_right_neg_forall {a b : α} (h : b * a < b) : is_negative a := by
  intro x
  have : b * a * x < b * x := mul_lt_mul_right' h x
  simpa [mul_assoc]

lemma one_right_one_forall {a b : α} (h : b * a = b) : is_one a := by
  intro x
  have : b * a * x = b * x := congrFun (congrArg HMul.hMul h) x
  simpa [mul_assoc]

/-- Every element of a LinearOrderedCancelSemigroup is either positive, negative, or one. -/
theorem pos_neg_or_one : ∀a : α, is_positive a ∨ is_negative a ∨ is_one a := by
  intro a
  rcases le_total (a*a) a with ha | ha
  <;> rcases LE.le.lt_or_eq ha with ha | ha
  · right; left; exact neg_right_neg_forall ha
  · right; right; exact one_right_one_forall ha
  · left; exact pos_right_pos_forall ha
  · right; right; exact one_right_one_forall ha.symm

theorem pow_pos_pos {a : α} (n : ℕ+) (positive : is_positive (a^n)) : is_positive a := by
  rcases pos_neg_or_one a with pos | neg | one
  · trivial
  · exact False.elim (neg_not_pos (neg_pow_neg neg n) positive)
  · exact False.elim (one_not_pos (one_pow_one one n) positive)

theorem pow_neg_neg {a : α} (n : ℕ+) (negative : is_negative (a^n)) : is_negative a := by
  rcases pos_neg_or_one a with pos | neg | one
  · exact False.elim (pos_not_neg (pos_pow_pos pos n) negative)
  · trivial
  · exact False.elim (one_not_neg (one_pow_one one n) negative)

theorem pos_le_pow_pos {a b : α} (pos : is_positive a) (n : ℕ+) (h : a ≤ b^n) : is_positive b :=
  pow_pos_pos n (pos_le_pos pos h)

theorem pow_le_neg_neg {a b : α} (neg : is_negative a) (n : ℕ+) (h : b^n ≤ a) : is_negative b :=
  pow_neg_neg n (le_neg_neg neg h)

end LinearOrderedCancelSemigroup