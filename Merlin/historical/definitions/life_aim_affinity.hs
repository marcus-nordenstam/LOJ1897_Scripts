; ----------------------------------------------------------------------------
; life_aim_affinity.hsc - PR-A-3.
;
; The LIFE_AIM_ALIGN data driving the unified weight formula's life_aim
; modifier. Each (life-aim-affinity ...) row says "an actor with this
; life_aim modifies the weight of this action by this signed amount."
;   - Positive  -> the actor's life_aim AMPLIFIES the action (more likely)
;   - Negative  -> the life_aim SUPPRESSES the action (less likely)
;   - Absent    -> the life_aim is NEUTRAL on the action (returns 0)
;
; Read by `(life-aim-aligns ?actor <action-label>)` in hse_engine.cc:
; deliberation branch synthesis, perpetration method selection, and the
; planned bonded_incident / public_incident outcome tables all consult
; it. life_aim itself is derived per-NPC by classify_life_aim in
; hsim_derive.cc.
;
; life_aim sub-kinds (Concepts.mon life_aim): legacy_aim / wealth_aim /
; piety_aim / respectability_aim / autonomy_aim / power_aim /
; belonging_aim. Action atoms are the goal/task labels deliberation and
; perpetration mint (kill / coerce / expose / discredit / threaten /
; humiliate / frame / hurt / seduce / silence_witness / bribe / steal /
; defraud / urge / disinherit / atone / confess_in_person /
; confess_letter / forgive). Magnitudes here are starter values matched
; to the bonded_incident outcome table; tune as
; behaviour-distribution drift surfaces from mxlog.
;
; Format:  (life-aim-affinity <life-aim-kind> <action> <signed-weight>)
; ----------------------------------------------------------------------------

; ---- wealth_aim ---------------------------------------------------------
(life-aim-affinity wealth_aim defraud         0.4)
(life-aim-affinity wealth_aim steal           0.4)
(life-aim-affinity wealth_aim coerce          0.3)
(life-aim-affinity wealth_aim bribe           0.3)
(life-aim-affinity wealth_aim outdo           0.3)
(life-aim-affinity wealth_aim atone          -0.2)
(life-aim-affinity wealth_aim confess_letter -0.2)

; ---- power_aim ----------------------------------------------------------
(life-aim-affinity power_aim   coerce         0.4)
(life-aim-affinity power_aim   humiliate      0.3)
(life-aim-affinity power_aim   threaten       0.3)
(life-aim-affinity power_aim   bribe          0.3)
(life-aim-affinity power_aim   outdo          0.3)
(life-aim-affinity power_aim   silence_witness 0.3)
(life-aim-affinity power_aim   frame          0.2)
(life-aim-affinity power_aim   kill           0.2)
(life-aim-affinity power_aim   forgive       -0.2)
(life-aim-affinity power_aim   surrender     -0.4)

; ---- legacy_aim ---------------------------------------------------------
(life-aim-affinity legacy_aim  urge           0.4)
(life-aim-affinity legacy_aim  disinherit     0.4)
(life-aim-affinity legacy_aim  silence_witness 0.3)
(life-aim-affinity legacy_aim  bribe          0.2)
(life-aim-affinity legacy_aim  expose        -0.2)
(life-aim-affinity legacy_aim  confess_letter -0.3)
(life-aim-affinity legacy_aim  confess_in_person -0.3)

; ---- respectability_aim -------------------------------------------------
(life-aim-affinity respectability_aim  urge           0.4)
(life-aim-affinity respectability_aim  disinherit     0.3)
(life-aim-affinity respectability_aim  expose         0.3)
(life-aim-affinity respectability_aim  report_crime   0.3)
(life-aim-affinity respectability_aim  silence_witness 0.3)
(life-aim-affinity respectability_aim  insult        -0.3)
(life-aim-affinity respectability_aim  threaten      -0.3)
(life-aim-affinity respectability_aim  assault       -0.4)
(life-aim-affinity respectability_aim  defraud       -0.4)
(life-aim-affinity respectability_aim  frame         -0.3)
(life-aim-affinity respectability_aim  kill          -0.4)

; ---- piety_aim ----------------------------------------------------------
(life-aim-affinity piety_aim   atone          0.4)
(life-aim-affinity piety_aim   confess_in_person 0.4)
(life-aim-affinity piety_aim   confess_letter 0.3)
(life-aim-affinity piety_aim   forgive        0.4)
(life-aim-affinity piety_aim   report_crime   0.2)
(life-aim-affinity piety_aim   defraud       -0.4)
(life-aim-affinity piety_aim   insult        -0.2)
(life-aim-affinity piety_aim   frame         -0.4)
(life-aim-affinity piety_aim   kill          -0.5)
(life-aim-affinity piety_aim   seduce        -0.3)

; ---- autonomy_aim -------------------------------------------------------
(life-aim-affinity autonomy_aim  flee          0.3)
(life-aim-affinity autonomy_aim  withdraw      0.3)
(life-aim-affinity autonomy_aim  surrender    -0.3)
(life-aim-affinity autonomy_aim  plead        -0.3)
(life-aim-affinity autonomy_aim  urge         -0.2)

; ---- belonging_aim ------------------------------------------------------
(life-aim-affinity belonging_aim  forgive       0.4)
(life-aim-affinity belonging_aim  atone         0.3)
(life-aim-affinity belonging_aim  confess_in_person 0.3)
(life-aim-affinity belonging_aim  plead         0.2)
(life-aim-affinity belonging_aim  expose       -0.2)
(life-aim-affinity belonging_aim  kill         -0.4)
(life-aim-affinity belonging_aim  frame        -0.3)
(life-aim-affinity belonging_aim  threaten     -0.3)
