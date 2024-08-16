import OrderedSemigroups.Defs

/-!
# Exponentiation Theorems

This file proves basic facts about exponentiation and how it interacts
with the ordering on a semigroup.

-/

universe u

variable {α : Type u}

@[simp]
lemma add_sub_eq (x y : ℕ+) : x + y - y = x := by
  apply PNat.eq
  simp [PNat.sub_coe, PNat.lt_add_left y x]

section Semigroup'
variable [Semigroup' α]

theorem nppow_eq_pow (n : ℕ+) (x : α) : Semigroup'.nppow n x = x ^ n := rfl

@[simp]
theorem ppow_one (x : α) : x ^ (1 : ℕ+) = x := Semigroup'.nppow_one x

theorem ppow_succ (n : ℕ+) (x : α) : x ^ (n + 1) = x ^ n * x := Semigroup'.nppow_succ n x

theorem ppow_comm (n : ℕ+) (x : α) : x^n * x = x * x^n := by
  induction n using PNat.recOn with
  | p1 => simp
  | hp n ih =>
    simp [ppow_succ, ih, mul_assoc]

theorem ppow_succ' (n : ℕ+) (x : α) : x ^ (n + 1) = x * x^n := by
  rw [ppow_succ, ppow_comm]

theorem split_first_and_last_factor_of_product [Semigroup' α] {a b : α} {n : ℕ+} :
  (a*b)^(n+1) = a*(b*a)^n*b := by
  induction n using PNat.recOn with
  | p1 => simp [ppow_succ, mul_assoc]
  | hp n ih =>
    calc
      (a * b)^(n + 1 + 1) = (a*b)^(n+1) * (a*b) := by rw [ppow_succ]
      _                   = a * (b*a)^n * b * (a*b) := by simp [ih]
      _                   = a * ((b*a)^n * (b*a)) * b := by simp [mul_assoc]
      _                   = a * (b*a)^(n+1) * b := by rw [←ppow_succ]

end Semigroup'

section OrderedSemigroup
variable [OrderedSemigroup α]

theorem le_pow {a b : α} (h : a ≤ b) (n : ℕ+) : a^n ≤ b^n := by
  induction n using PNat.recOn with
  | p1 =>
    simp
    assumption
  | hp n ih =>
    simp [ppow_succ]
    exact mul_le_mul' ih h

theorem middle_swap {a b c d : α} (h : a ≤ b) : c * a * d ≤ c * b * d := by
  have : a * d ≤ b * d := OrderedSemigroup.mul_le_mul_right a b h d
  have : c * (a * d) ≤ c * (b * d) := OrderedSemigroup.mul_le_mul_left (a*d) (b*d) this c
  simp [mul_assoc]
  trivial

theorem comm_factor_le {a b : α} (h : a*b ≤ b*a) (n : ℕ+) : a^n * b^n ≤ (a*b)^n := by
  induction n using PNat.recOn with
  | p1 => simp
  | hp n ih =>
    calc
      a^(n+1) * b^(n+1) = a * (a^n * b^n) * b := by simp [ppow_succ, ppow_comm, mul_assoc]
      _                 ≤ a * (a * b)^n * b := middle_swap ih
      _                 ≤ a * (b * a)^n * b := middle_swap (le_pow h n)
      _                 = (a * b)^(n+1) := by rw [←split_first_and_last_factor_of_product]

theorem comm_swap_le [OrderedSemigroup α] {a b : α} (h : a*b ≤ b*a) (n : ℕ+) : (a*b)^n ≤ (b*a)^n := le_pow h n

theorem comm_dist_le [OrderedSemigroup α] {a b : α} (h : a*b ≤ b*a) (n : ℕ+) : (b*a)^n ≤ b^n * a^n := by
  induction n using PNat.recOn with
  | p1 => simp
  | hp n ih =>
    calc
      (b*a)^(n+1) = b * (a*b)^n * a := by rw [split_first_and_last_factor_of_product]
      _           ≤ b * (b*a)^n * a := middle_swap (le_pow h n)
      _           ≤ b * (b^n * a^n) * a := middle_swap ih
      _           = (b * b^n) * (a^n * a) := by simp [mul_assoc]
      _           = b^(n+1) * a^(n+1) := by simp [ppow_succ, ←ppow_succ']

end OrderedSemigroup
