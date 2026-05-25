# -----------------------------------------------------------------------------
# PressureDischarge.mc - Phase 9.6.
#
# The audible output of the appraisal system in dialogue (distillation §11.5).
# When a witness holds a high-salience pressure belief AND has warmth toward
# the asker AND the topic is adjacent to the pressured belief, the witness
# volunteers a TELL_FACT that discloses the pressure. This is the single
# largest perceived player payoff per line of authoring per the spec:
# pressure-loaded NPCs spontaneously reveal what is burdening them once
# warmth crosses a threshold.
#
# v1 simplifications (each lands its own follow-up):
# - High-salience filter is approximate: any ongoing pressure belief counts.
#   Future work adds an explicit salience > threshold gate.
# - Warmth gate is permissive: the witness volunteers to anyone they don't
#   actively dislike. Neutral / unknown asker is fine; only an explicit
#   `hate` self-belief about the asker blocks the volunteer. Pressure
#   under load leaks unless the asker is unsafe - that asymmetry matches
#   the corpus, where confessions land with the half-stranger inspector
#   far more often than with the trusted-but-judgmental in-law. A full
#   warmth-band / bond / love model lands when that derivation is wired
#   through to .mc-readable form.
# - Topic adjacency is not checked. v1 fires whenever the witness is asked
#   ANYTHING by an asker they don't dislike - the volunteer is unconditional
#   disclosure. The dialogue session's last-salient-noun (Phase 9.5) is the
#   natural handle for adjacency once the session has settled.
# - "Volunteered-preface" decoration (distillation §3.4 / §4.5) is a TODO;
#   the witness's voluntered line currently surfaces as a plain TELL.
# -----------------------------------------------------------------------------

# Volunteer a held pressure belief to any asker the witness does not actively
# dislike. Higher abs_util than the regular tell_answer so the volunteer wins
# the action-pipeline competition in turns where both could fire. The
# (msg ?pressure_belief) shape carries the pressure content; receiving minds
# pattern-match on the pressure label to dispatch their reaction.
rule pressure-discharge-volunteer
{@self /pres pressure ?kind}: ?pressure_belief
{@self tell_about ?subject ?asker}: ?tell_anchor
(none {@self /pres hate ?asker})
(none {@self /succ TELL (msg ?pressure_belief) ?asker})
    ->
(maintain_goal {@self TELL (msg ?pressure_belief) ?asker} (des abs_util 2)): ?volunteer
(add_causes ?volunteer ?tell_anchor)
(forget_on_cease).
