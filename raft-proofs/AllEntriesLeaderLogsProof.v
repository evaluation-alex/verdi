Require Import List.
Require Import Omega.

Require Import VerdiTactics.
Require Import Util.
Require Import Net.

Require Import Raft.
Require Import RaftRefinementInterface.

Require Import UpdateLemmas.
Local Arguments update {_} {_} {_} _ _ _ _ : simpl never.

Require Import CommonTheorems.

Require Import AppendEntriesRequestLeaderLogsInterface.
Require Import OneLeaderLogPerTermInterface.
Require Import LeaderLogsSortedInterface.
Require Import RefinedLogMatchingLemmasInterface.

Require Import AllEntriesLeaderLogsInterface.

Section AllEntriesLeaderLogs.

  Context {orig_base_params : BaseParams}.
  Context {one_node_params : OneNodeParams orig_base_params}.
  Context {raft_params : RaftParams orig_base_params}.

  Context {rri : raft_refinement_interface}.
  Context {aerlli : append_entries_leaderLogs_interface}.
  Context {ollpti : one_leaderLog_per_term_interface}.
  Context {llsi : leaderLogs_sorted_interface}.
  Context {rlmli : refined_log_matching_lemmas_interface}.

  Lemma leader_without_missing_entry_invariant :
    forall net,
      refined_raft_intermediate_reachable net ->
      leader_without_missing_entry net.
  Admitted.

  Lemma appendEntriesRequest_exists_leaderLog_invariant :
    forall net,
      refined_raft_intermediate_reachable net ->
      appendEntriesRequest_exists_leaderLog net.
  Admitted.

  Lemma appendEntriesRequest_leaderLog_not_in_invariant :
    forall net,
      refined_raft_intermediate_reachable net ->
      appendEntriesRequest_leaderLog_not_in net.
  Proof.
    unfold appendEntriesRequest_leaderLog_not_in.
    intros.
    find_copy_apply_lem_hyp append_entries_leaderLogs_invariant.
    unfold append_entries_leaderLogs in *.
    pose proof entries_sorted_nw_invariant net $(auto)$ p _ _ _ _ _ _ $(auto)$ $(auto)$ $(eauto)$.
    match goal with
    | [ H : In _ (nwPackets _), H' : forall _, _ |- _ ] =>
      copy_eapply H' H
    end; eauto.
    break_exists. break_and.
    pose proof one_leaderLog_per_term_invariant _ $(eauto)$ (pSrc p) x _ _  _ $(eauto)$ $(eauto)$.
    break_and. subst.
    intro.
    match goal with
    | [ H : ~ In _ _ |- _ ] => apply H
    end.
    apply in_or_app. right.
    find_copy_apply_lem_hyp leaderLogs_sorted_invariant; auto.
    find_copy_eapply_lem_hyp maxIndex_is_max; eauto.
    intuition.
    - break_and. subst. omega.
    - break_exists. intuition. subst.
      unfold Prefix_sane in *. intuition.
      + eapply prefix_contiguous; eauto.
        pose proof entries_contiguous_nw_invariant _ $(eauto)$ p _ _ _ _ _ _ $(auto)$ $(eauto)$.
        eapply contiguous_app ; eauto.
      + omega.
    - subst. auto.
  Qed.

  Lemma appendEntries_leader_invariant :
    forall net,
      refined_raft_intermediate_reachable net ->
      appendEntries_leader net.
  Admitted.

  Lemma leaderLogs_leader_invariant :
    forall net,
      refined_raft_intermediate_reachable net ->
      leaderLogs_leader net.
  Admitted.

  Instance aelli :  all_entries_leader_logs_interface.
  Proof.
    split.
    intros.
    red.
    intuition.
    - auto using leader_without_missing_entry_invariant.
    - auto using appendEntriesRequest_exists_leaderLog_invariant.
    - auto using appendEntriesRequest_leaderLog_not_in_invariant.
    - auto using appendEntries_leader_invariant.
    - auto using leaderLogs_leader_invariant.
  Qed.
End AllEntriesLeaderLogs.
