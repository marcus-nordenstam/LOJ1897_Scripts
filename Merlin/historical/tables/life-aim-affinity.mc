; ----------------------------------------------------------------------------
; life-aim-affinity.hs - the (life-aim, action) affinity table, as authored config.
;
; One record per (life-aim, action) pair with a signed weight - the
; LIFE_AIM_ALIGN modifier of the unified weight formula.
;   - Positive  -> the actor's life-aim AMPLIFIES the action (more likely)
;   - Negative  -> the life-aim SUPPRESSES the action (less likely)
;   - Absent    -> the pair is NEUTRAL; the consuming read defaults to 0
;
; Read by the annual structural-pressure derivation (hsim_derive.cc,
; life_aim_affinity_lookup) through the generic table API, and available to
; rules as a point-read on the actor's OWN life-aim crossed with a candidate
; action:
;   (select-row (table life_aim_affinity)
;     (bind weight ?w)
;     (when (and (= life-aim (any {@self life-aim ?}).target) (= action ?action)))
;     ...)
; with the consumer defaulting the bound weight to 0 when no record matches.
; life-aim itself is a per-NPC belief minted by the classify_life_aim rule
; (classifiers/life-aim.hs); it is read @self-only (non-telepathic).
;
; life-aim sub-kinds (Concepts.mon life-aim): legacy-aim / wealth-aim /
; piety-aim / respectability-aim / autonomy-aim / power-aim / belonging-aim.
; Action atoms are the goal/task labels deliberation and perpetration mint
; (kill / coerce / expose / discredit / threaten / humiliate / frame / hurt /
; seduce / silence_witness / bribe / steal / defraud / urge / disinherit /
; atone / confess_in_person / confess_letter / forgive). Magnitudes here are
; starter values matched to the bonded_incident outcome table; tune as
; behaviour-distribution drift surfaces from mxlog.
; ----------------------------------------------------------------------------

(define-table life_aim_affinity
  (fields life-aim action weight)

  ; ---- wealth-aim ---------------------------------------------------------
  (record [k life-aim wealth-aim] defraud         0.4)
  (record [k life-aim wealth-aim] steal           0.4)
  (record [k life-aim wealth-aim] coerce          0.3)
  (record [k life-aim wealth-aim] bribe           0.3)
  (record [k life-aim wealth-aim] outdo           0.3)
  (record [k life-aim wealth-aim] atone          -0.2)
  (record [k life-aim wealth-aim] confess_letter -0.2)

  ; ---- power-aim ----------------------------------------------------------
  (record [k life-aim power-aim]   coerce          0.4)
  (record [k life-aim power-aim]   humiliate       0.3)
  (record [k life-aim power-aim]   threaten        0.3)
  (record [k life-aim power-aim]   bribe           0.3)
  (record [k life-aim power-aim]   outdo           0.3)
  (record [k life-aim power-aim]   silence_witness 0.3)
  (record [k life-aim power-aim]   frame           0.2)
  (record [k life-aim power-aim]   kill            0.2)
  (record [k life-aim power-aim]   forgive        -0.2)
  (record [k life-aim power-aim]   surrender      -0.4)

  ; ---- legacy-aim ---------------------------------------------------------
  (record [k life-aim legacy-aim]  urge            0.4)
  (record [k life-aim legacy-aim]  disinherit      0.4)
  (record [k life-aim legacy-aim]  silence_witness 0.3)
  (record [k life-aim legacy-aim]  bribe           0.2)
  (record [k life-aim legacy-aim]  expose         -0.2)
  (record [k life-aim legacy-aim]  confess_letter -0.3)
  (record [k life-aim legacy-aim]  confess_in_person -0.3)

  ; ---- respectability-aim -------------------------------------------------
  (record [k life-aim respectability-aim]  urge            0.4)
  (record [k life-aim respectability-aim]  disinherit      0.3)
  (record [k life-aim respectability-aim]  expose          0.3)
  (record [k life-aim respectability-aim]  report_crime    0.3)
  (record [k life-aim respectability-aim]  silence_witness 0.3)
  (record [k life-aim respectability-aim]  insult         -0.3)
  (record [k life-aim respectability-aim]  threaten       -0.3)
  (record [k life-aim respectability-aim]  defraud        -0.4)
  (record [k life-aim respectability-aim]  frame          -0.3)
  (record [k life-aim respectability-aim]  kill           -0.4)

  ; ---- piety-aim ----------------------------------------------------------
  (record [k life-aim piety-aim]   atone           0.4)
  (record [k life-aim piety-aim]   confess_in_person 0.4)
  (record [k life-aim piety-aim]   confess_letter  0.3)
  (record [k life-aim piety-aim]   forgive         0.4)
  (record [k life-aim piety-aim]   report_crime    0.2)
  (record [k life-aim piety-aim]   defraud        -0.4)
  (record [k life-aim piety-aim]   insult         -0.2)
  (record [k life-aim piety-aim]   frame          -0.4)
  (record [k life-aim piety-aim]   kill           -0.5)
  (record [k life-aim piety-aim]   seduce         -0.3)

  ; ---- autonomy-aim -------------------------------------------------------
  (record [k life-aim autonomy-aim]  flee          0.3)
  (record [k life-aim autonomy-aim]  withdraw      0.3)
  (record [k life-aim autonomy-aim]  surrender    -0.3)
  (record [k life-aim autonomy-aim]  plead        -0.3)
  (record [k life-aim autonomy-aim]  urge         -0.2)

  ; ---- belonging-aim ------------------------------------------------------
  (record [k life-aim belonging-aim]  forgive       0.4)
  (record [k life-aim belonging-aim]  atone         0.3)
  (record [k life-aim belonging-aim]  confess_in_person 0.3)
  (record [k life-aim belonging-aim]  plead         0.2)
  (record [k life-aim belonging-aim]  expose       -0.2)
  (record [k life-aim belonging-aim]  kill         -0.4)
  (record [k life-aim belonging-aim]  frame        -0.3)
  (record [k life-aim belonging-aim]  threaten     -0.3))
