(* This files proves some general Lemmas about the real numbers that are
usefull when considering computability. *)

From mathcomp Require Import ssreflect ssrnat ssrbool ssrfun.
From mf Require Import all_mf.
Require Import Reals Psatz.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.
Local Open Scope R_scope.
  
Section accumulation.
  Definition acc P x := forall eps, eps > 0 -> exists y, P y /\ Rabs (y - x) < eps.

  Lemma cond_eq_P P x y:
    acc P 0 -> (forall z, P z -> Rabs (x - y) <= Rabs z) -> x = y.
  Proof.
    move => acc prp; apply cond_eq => eps epsg0.
    have [z [pz ineq]]:= acc eps epsg0.
    apply /Rle_lt_trans; first by apply (prp z).
    by rewrite Rminus_0_r in ineq.
  Qed.

  Lemma cond_leq x y: (forall eps, 0 < eps -> x <= y + eps) -> x <= y.
  Proof.
    move => prp.
    apply/Rnot_lt_le => xg0.
    suff: x = y by lra.
    apply/cond_eq => eps eg0.
    by have := prp (eps/2); split_Rabs; lra.
  Qed.


  Definition acc_f_zero_plus T (f: T -> R) := forall eps, eps > 0 -> exists t, 0 < f t < eps.

  Lemma acc_f_acc T (f: T -> R):
    acc_f_zero_plus f <-> acc (fun x => codom (F2MF f) x /\ x > 0) 0.
  Proof.
    split => acc eps epsg0; have := acc eps epsg0.
    - move => [t [g0 leps]]; exists (f t); split.
      + by split; try lra; exists t.
      by rewrite /R_dist Rminus_0_r Rabs_pos_eq; lra.
    move => [y [[[t <-] neq]]]; rewrite /R_dist Rminus_0_r => ineq.
    exists t; split => //.
    by rewrite -[f t]Rabs_pos_eq; lra.
  Qed.

  Lemma cond_eq_f T (f: T -> R) x y:
    acc_f_zero_plus f -> (forall z, 0 < f z -> R_dist x y <= f z) -> x = y.
  Proof.
    move => accu prp.
    apply cond_eq => eps epsg0.
    have [t [g0 ineq]]:= accu eps epsg0.
    by apply/ Rle_lt_trans; first by apply /prp /g0.
  Qed.

  Lemma pwr2gtz m: exists n, (2^n > m)%nat.
  Proof.
    elim: m => [ | m [n /leP ih]]; first by exists 0%nat; apply /leP => /=; lia.
    by exists n.+1; apply /leP => /=; lia.
  Qed.
End accumulation.

Section tpmn.
  Lemma tpmnP n m: reflect (/2^n <= /2^m) (m <= n)%nat.
  Proof.
    case E: (m <= n)%nat.
    - apply/ReflectT/Rinv_le_contravar/Rle_pow/leP/E; try lra.
      by apply/pow_lt; lra.
    apply/ReflectF/Rlt_not_le/Rinv_lt_contravar/Rlt_pow/leP; try lra.
    - apply/Rmult_lt_0_compat; apply/pow_lt; try lra.
    by rewrite ltnNge E.
  Qed.

  Lemma tpmn_half n: / 2 ^ n = / 2 ^ n.+1 + / 2 ^ n.+1.
  Proof. by have pos:= pow_lt 2 n; rewrite /= Rinv_mult_distr; lra. Qed.

  Lemma tpmn_pos n: 0 <= /2^n.
  Proof. by apply/Rlt_le/Rinv_0_lt_compat/pow_lt; lra. Qed.

  Lemma tpmn_lt n: 0 < /2^n.
  Proof. apply/Rinv_0_lt_compat/pow_lt; lra. Qed.
  
  Lemma accf_tpmn: acc_f_zero_plus (fun n => /2^n).
  Proof.
    move => r rgt0; pose z := Z.to_nat (up (1/r)).
    have [n /leP nprp]:= pwr2gtz z; have g0: 0 < 2^n by apply pow_lt; lra.
    exists n; split; first by apply /Rinv_0_lt_compat /pow_lt; lra.
    rewrite -[r]Rinv_involutive; try lra.
    apply Rinv_lt_contravar; first by rewrite Rmult_comm; apply Rdiv_lt_0_compat;  try lra.
    apply /Rlt_trans; first by have:= (archimed (1 / r)).1 => ineq; rewrite -[/r]Rmult_1_l; apply ineq.
    case E: (up (1/r)) => [ | p | p] //; have pos:= (Pos2Z.pos_is_pos p); last first.
    - by apply /(@Rlt_le_trans _ (IZR 0)); [apply IZR_lt; lia | apply Rlt_le].
    rewrite -[Z.pos _]Z2Nat.id; try lia; rewrite -E -/z -INR_IZR_INZ.
    have ->: 2 = INR 2 by trivial.
    by rewrite -pow_INR; apply lt_INR => /=; lia.
  Qed.

  Lemma dns0_tpmn: forall eps, 0 < eps -> exists n, /2^n < eps.
  Proof. by move => eps /accf_tpmn [n []]; exists n. Qed.
End tpmn.