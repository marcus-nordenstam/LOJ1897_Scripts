; ----------------------------------------------------------------------------
; life_aim_affinity.hs - the (life_aim, action) affinity table, as authored config.
;
; A (define-table ...): one record per (life_aim, action) pair with a signed
; weight - the LIFE_AIM_ALIGN modifier of the unified weight formula.
;   - Positive  -> the actor's life_aim AMPLIFIES the action (more likely)
;   - Negative  -> the life_aim SUPPRESSES the action (less likely)
;   - Absent    -> the pair is NEUTRAL; the consuming read defaults to 0
;
; Point-read on the actor's OWN life_aim crossed with a candidate action:
;   (select-record (table life_aim_affinity)
;     (bind weight ?w)
;     (when (and (= life_aim (any {@self life_aim ?}).target) (= action ?action)))
;     ...)
; with the consumer defaulting the bound weight to 0 when no record matches.
; life_aim itself is a per-NPC belief minted by the classify_life_aim event
; (classifiers/life_aim.hs); it is read @self-only (non-telepathic).
;
; life_aim sub-kinds (Concepts.mon life_aim): legacy_aim / wealth_aim /
; piety_aim / respectability_aim / autonomy_aim / power_aim / belonging_aim.
; Action atoms are the goal/task labels deliberation and perpetration mint
; (kill / coerce / expose / discredit / threaten / humiliate / frame / hurt /
; seduce / silence_witness / bribe / steal / defraud / urge / disinherit /
; atone / confess_in_person / confess_letter / forgive). Magnitudes here are
; starter values matched to the bonded_incident outcome table; tune as
; behaviour-distribution drift surfaces from mxlog.
; ----------------------------------------------------------------------------

(define-table life_aim_affinity
  (fields life_aim action weight)

  ; ---- wealth_aim ---------------------------------------------------------
  (record [k life_aim wealth_aim] defraud         0.4)
  (record [k life_aim wealth_aim] steal           0.4)
  (record [k life_aim wealth_aim] coerce          0.3)
  (record [k life_aim wealth_aim] bribe           0.3)
  (record [k life_aim wealth_aim] outdo           0.3)
  (record [k life_aim wealth_aim] atone          -0.2)
  (record [k life_aim wealth_aim] confess_letter -0.2)

  ; ---- power_aim ----------------------------------------------------------
  (record [k life_aim power_aim]   coerce          0.4)
  (record [k life_aim power_aim]   humiliate       0.3)
  (record [k life_aim power_aim]   threaten        0.3)
  (record [k life_aim power_aim]   bribe           0.3)
  (record [k life_aim power_aim]   outdo           0.3)
  (record [k life_aim power_aim]   silence_witness 0.3)
  (record [k life_aim power_aim]   frame           0.2)
  (record [k life_aim power_aim]   kill            0.2)
  (record [k life_aim power_aim]   forgive        -0.2)
  (record [k life_aim power_aim]   surrender      -0.4)

  ; ---- legacy_aim ---------------------------------------------------------
  (record [k life_aim legacy_aim]  urge            0.4)
  (record [k life_aim legacy_aim]  disinherit      0.4)
  (record [k life_aim legacy_aim]  silence_witness 0.3)
  (record [k life_aim legacy_aim]  bribe           0.2)
  (record [k life_aim legacy_aim]  expose         -0.2)
  (record [k life_aim legacy_aim]  confess_letter -0.3)
  (record [k life_aim legacy_aim]  confess_in_person -0.3)

  ; ---- respectability_aim -------------------------------------------------
  (record [k life_aim respectability_aim]  urge            0.4)
  (record [k life_aim respectability_aim]  disinherit      0.3)
  (record [k life_aim respectability_aim]  expose          0.3)
  (record [k life_aim respectability_aim]  report_crime    0.3)
  (record [k life_aim respectability_aim]  silence_witness 0.3)
  (record [k life_aim respectability_aim]  insult         -0.3)
  (record [k life_aim respectability_aim]  threaten       -0.3)
  (record [k life_aim respectability_aim]  defraud        -0.4)
  (record [k life_aim respectability_aim]  frame          -0.3)
  (record [k life_aim respectability_aim]  kill           -0.4)

  ; ---- piety_aim ----------------------------------------------------------
  (record [k life_aim piety_aim]   atone           0.4)
  (record [k life_aim piety_aim]   confess_in_person 0.4)
  (record [k life_aim piety_aim]   confess_letter  0.3)
  (record [k life_aim piety_aim]   forgive         0.4)
  (record [k life_aim piety_aim]   report_crime    0.2)
  (record [k life_aim piety_aim]   defraud        -0.4)
  (record [k life_aim piety_aim]   insult         -0.2)
  (record [k life_aim piety_aim]   frame          -0.4)
  (record [k life_aim piety_aim]   kill           -0.5)
  (record [k life_aim piety_aim]   seduce         -0.3)

  ; ---- autonomy_aim -------------------------------------------------------
  (record [k life_aim autonomy_aim]  flee          0.3)
  (record [k life_aim autonomy_aim]  withdraw      0.3)
  (record [k life_aim autonomy_aim]  surrender    -0.3)
  (record [k life_aim autonomy_aim]  plead        -0.3)
  (record [k life_aim autonomy_aim]  urge         -0.2)

  ; ---- belonging_aim ------------------------------------------------------
  (record [k life_aim belonging_aim]  forgive       0.4)
  (record [k life_aim belonging_aim]  atone         0.3)
  (record [k life_aim belonging_aim]  confess_in_person 0.3)
  (record [k life_aim belonging_aim]  plead         0.2)
  (record [k life_aim belonging_aim]  expose       -0.2)
  (record [k life_aim belonging_aim]  kill         -0.4)
  (record [k life_aim belonging_aim]  frame        -0.3)
  (record [k life_aim belonging_aim]  threaten     -0.3))
