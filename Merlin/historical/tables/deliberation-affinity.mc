; ----------------------------------------------------------------------------
; deliberation_affinity.hs - the (pressure-kind, action) affinity table for the
; generative deliberate rule, as authored config.
;
; A (define-table ...): one record per (pressure-kind, action) pair with a base
; weight. deliberate.hs crosses the actor's standing pressures with these rows via
; (select-joint (over-pressures ...) (table deliberation_affinity) ...); the
; (deliberation-score ...) op gates a pair to weight 0 unless the pressure's kind
; matches the row's pressure-kind, then scales by intensity x trait/mood/justify/
; lethal/prize/crime-scale. Inaction (forgive / do_nothing) is NOT a row - it is the
; act-vs-floor branch in deliberate.hs, so it competes ONCE (not per-pressure).
;
; The suicide + strive outlets are handled by their own resolution (a witnessed-
; ideation despair gate / a practice-marker discharge), not a plain goal mint, so
; they are authored as dedicated branches - not rows here.
; ----------------------------------------------------------------------------

(define-table deliberation_affinity
  (fields pressure-kind action weight)

  ; ---- humiliation: a directed slight needing release ----------------------
  (record [k humiliation]        confront_privately  0.5)
  (record [k humiliation]        expose              0.4)
  (record [k humiliation]        withdraw            0.3)
  (record [k humiliation]        kill                0.02)
  (record [k humiliation]        humiliate           0.5)
  (record [k humiliation]        coerce              0.10)
  (record [k humiliation]        suicide             0.01)

  ; ---- injustice: morally indignant; broad release set ---------------------
  (record [k injustice]          confront_privately  0.5)
  (record [k injustice]          expose              0.5)
  (record [k injustice]          plead               0.3)
  (record [k injustice]          kill                0.02)
  (record [k injustice]          report_crime        0.5)

  ; ---- exposure-risk: standing secret may break ----------------------------
  (record [k exposure-risk]      silence_witness     0.4)
  (record [k exposure-risk]      flee                0.4)
  (record [k exposure-risk]      expose_first        0.3)
  (record [k exposure-risk]      confess_letter      0.2)
  (record [k exposure-risk]      bribe               0.4)
  (record [k exposure-risk]      kill                0.05)

  ; ---- attachment-loss: loss of a bonded other -----------------------------
  (record [k attachment-loss]    mourn               0.7)
  (record [k attachment-loss]    withdraw            0.5)
  (record [k attachment-loss]    replace             0.2)
  (record [k attachment-loss]    seduce              0.2)
  (record [k attachment-loss]    kill                0.03)
  (record [k attachment-loss]    coerce              0.20)
  (record [k attachment-loss]    suicide             0.03)

  ; ---- moral-violation: actor's own held norms breached --------------------
  (record [k moral-violation]    confess_letter      0.5)
  (record [k moral-violation]    confess_in_person   0.3)
  (record [k moral-violation]    surrender           0.2)
  (record [k moral-violation]    atone               0.4)
  (record [k moral-violation]    frame               0.2)

  ; ---- existential-threat: directed lethal danger --------------------------
  (record [k existential-threat] flee                0.8)
  (record [k existential-threat] plead               0.4)
  (record [k existential-threat] surrender           0.3)
  (record [k existential-threat] kill                0.02)

  ; ---- status-loss: prestige drop ------------------------------------------
  (record [k status-loss]        withdraw            0.4)
  (record [k status-loss]        confront_privately  0.3)
  (record [k status-loss]        flee                0.2)
  (record [k status-loss]        expose              0.4)
  (record [k status-loss]        kill                0.03)

  ; ---- autonomy-loss: capability constrained by another --------------------
  (record [k autonomy-loss]      flee                0.5)
  (record [k autonomy-loss]      confront_privately  0.4)
  (record [k autonomy-loss]      plead               0.3)

  ; ---- resource-scarcity: material lack ------------------------------------
  (record [k resource-scarcity]  plead               0.5)
  (record [k resource-scarcity]  steal               0.3)
  (record [k resource-scarcity]  withdraw            0.3)
  (record [k resource-scarcity]  report_crime        0.3)

  ; ---- obligation-strain: too many duties ----------------------------------
  (record [k obligation-strain]  withdraw            0.5)
  (record [k obligation-strain]  atone               0.3)
  (record [k obligation-strain]  flee                0.2)

  ; ---- rivalry-pressure: directed competition ------------------------------
  (record [k rivalry-pressure]   strive              0.6)
  (record [k rivalry-pressure]   humiliate           0.5)
  (record [k rivalry-pressure]   expose              0.4)
  (record [k rivalry-pressure]   kill                0.02))
