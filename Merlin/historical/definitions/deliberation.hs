; ----------------------------------------------------------------------------
; deliberation.hsc - Phase 10 Phase D Pivot A (2026-05-24).
;
; The affinity table for the generative-deliberation event (deliberate.hse).
; One row per (pressure-kind, action) pair plus always-included floor rows.
;
; Format:
;   (affinity <pressure-kind-atom> <action-atom> <weight-number>)
;     The cast actor's standing pressure of <pressure-kind> contributes a
;     branch toward <action> with this base weight, multiplied by the
;     pressure intensity and the disinhibition factor (1 - inhibition/100).
;
;   (floor <action-atom> <weight-number>)
;     Always-included branch with this absolute weight, regardless of any
;     standing pressure. Keeps the modal NPC with little pressure load
;     anchored to forgive / do_nothing.
;
; Action atoms are free-form - the engine logs `deliberate: <actor> ->
; <action>` to the narrative. A follow-up PR wires action atoms to nested
; goal-belief minting (`{actor goal {actor <action> <focus>}}`).
;
; Pressure kinds must match the (pressure) block of Concepts.mon.
; ----------------------------------------------------------------------------

; ---- humiliation: a directed slight needing release ------------------------
(affinity humiliation         confront_privately   0.5)
(affinity humiliation         expose               0.4)
(affinity humiliation         withdraw             0.3)
(affinity humiliation         kill                 0.02)
; PR-3d 2026-05-25 - new goal labels.
(affinity humiliation         humiliate            0.5)
(affinity humiliation         discredit            0.4)
; jilt_blackmail_reputation_plan Phase B + S (see the attachment_loss rows).
(affinity humiliation         coerce               0.10)
(affinity humiliation         suicide              0.01)

; ---- injustice: morally indignant; broad release set -----------------------
(affinity injustice           confront_privately   0.5)
(affinity injustice           expose               0.5)
(affinity injustice           plead                0.3)
(affinity injustice           kill                 0.02)
(affinity injustice           discredit            0.4)

; ---- exposure_risk: standing secret may break --------------------------------
(affinity exposure_risk       silence_witness      0.4)
(affinity exposure_risk       flee                 0.4)
(affinity exposure_risk       expose_first         0.3)
(affinity exposure_risk       confess_letter       0.2)
(affinity exposure_risk       bribe                0.4)
; Cover-up / murder-to-silence: kill the witness (the exposure_risk focus is the
; patient who could expose the actor - they need not have wronged the actor).
; A tail weight so it stays rare; Part A pins the exposure_risk pressure as the
; goal's /cause, so the rap-sheet reads "kill <witness> <- exposure_risk".
(affinity exposure_risk       kill                 0.05)

; ---- attachment_loss: loss of a bonded other ---------------------------------
(affinity attachment_loss     mourn                0.7)
(affinity attachment_loss     withdraw             0.5)
(affinity attachment_loss     replace              0.2)
(affinity attachment_loss     seduce               0.2)   ; rebound
; PR-A-6 2026-05-28 - the rare-but-load-bearing jealous-spouse path.
; betrayed lovers do sometimes escalate to the kill goal; the affinity
; weight is intentionally low so it stays a tail outcome, not a default.
(affinity attachment_loss     kill                 0.03)
; jilt_blackmail_reputation_plan Phase B - the jilted lover's coercion
; branch ("marry me or I show your letters to your father"). The demand
; is derived at the silence_coerce terminal from the lost relationship.
; Kill affinities stay untouched: blackmail must out-compete murder for
; the jilted party (the jilted party is L'Angelier, not the killer).
(affinity attachment_loss     coerce               0.20)
; Phase S - the self-destruction tail. The engine gates this branch HARD
; (despair mood x low-resilience traits) before anything fires; the
; weight only makes it reachable. A deliberated-but-not-chosen pick
; mints the witnessed suicidal-ideation belief (the valet testimony).
(affinity attachment_loss     suicide              0.03)

; ---- moral_violation: actor's own held norms breached ------------------------
(affinity moral_violation     confess_letter       0.5)
(affinity moral_violation     confess_in_person    0.3)
(affinity moral_violation     surrender            0.2)
(affinity moral_violation     atone                0.4)
(affinity moral_violation     frame                0.2)   ; deflection

; ---- existential_threat: directed lethal danger ------------------------------
(affinity existential_threat  flee                 0.8)
(affinity existential_threat  plead                0.4)
(affinity existential_threat  surrender            0.3)
; WS3 (homicide_motive_realism_plan.md): existential_threat was the kill
; MONOCULTURE driver - 0.04 was 2x every other pressure's kill-affinity AND it is
; the most-minted pressure (assault -> existential_threat is strong). Flattened to
; 0.02, parity with humiliation / injustice / rivalry, so no single pressure
; dominates the kill-motive mix. Fear still resolves overwhelmingly to flee (0.8).
(affinity existential_threat  kill                 0.02)

; ---- status_loss: prestige drop --------------------------------------------
(affinity status_loss         withdraw             0.4)
(affinity status_loss         confront_privately   0.3)
(affinity status_loss         flee                 0.2)
; PR-A-6 2026-05-28 - structural-pressure consumers (PR-A-4 mints
; status_loss from parental + class-interloper / replacement-threat
; triangulations).
(affinity status_loss         discredit            0.4)
(affinity status_loss         expose               0.4)
(affinity status_loss         kill                 0.03)

; ---- autonomy_loss: capability constrained by another ----------------------
(affinity autonomy_loss       flee                 0.5)
(affinity autonomy_loss       confront_privately   0.4)
(affinity autonomy_loss       plead                0.3)

; ---- resource_scarcity: material lack --------------------------------------
(affinity resource_scarcity   plead                0.5)
(affinity resource_scarcity   steal                0.3)
(affinity resource_scarcity   withdraw             0.3)

; ---- obligation_strain: too many duties --------------------------------------
(affinity obligation_strain   withdraw             0.5)
(affinity obligation_strain   atone                0.3)
(affinity obligation_strain   flee                 0.2)

; ---- rivalry_pressure: directed competition ----------------------------------
(affinity rivalry_pressure    confront_privately   0.4)
(affinity rivalry_pressure    expose               0.4)
(affinity rivalry_pressure    kill                 0.02)
(affinity rivalry_pressure    discredit            0.5)
(affinity rivalry_pressure    humiliate            0.3)

; ---- floor branches: always considered, absolute weights -------------------
(floor    forgive             0.15)
(floor    do_nothing          0.40)
