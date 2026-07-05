; ----------------------------------------------------------------------------
; deliberation_affinity.hs - the (pressure-kind, action) affinity table for the
; generative deliberate event, as authored config.
;
; A (define-table ...): one record per (pressure_kind, action) pair with a base
; weight. deliberate.hs crosses the actor's standing pressures with these rows via
; (select-joint (over-pressures ...) (table deliberation_affinity) ...); the
; (deliberation-score ...) op gates a pair to weight 0 unless the pressure's kind
; matches the row's pressure_kind, then scales by intensity x trait/mood/justify/
; lethal/prize/crime-scale. Inaction (forgive / do_nothing) is NOT a row - it is the
; act-vs-floor branch in deliberate.hs, so it competes ONCE (not per-pressure).
;
; The suicide + strive outlets are handled by their own resolution (a witnessed-
; ideation despair gate / a practice-marker discharge), not a plain goal mint, so
; they are authored as dedicated branches - not rows here.
; ----------------------------------------------------------------------------

(define-table deliberation_affinity
  (fields pressure_kind action weight)

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

  ; ---- exposure_risk: standing secret may break ----------------------------
  (record [k exposure_risk]      silence_witness     0.4)
  (record [k exposure_risk]      flee                0.4)
  (record [k exposure_risk]      expose_first        0.3)
  (record [k exposure_risk]      confess_letter      0.2)
  (record [k exposure_risk]      bribe               0.4)
  (record [k exposure_risk]      kill                0.05)

  ; ---- attachment_loss: loss of a bonded other -----------------------------
  (record [k attachment_loss]    mourn               0.7)
  (record [k attachment_loss]    withdraw            0.5)
  (record [k attachment_loss]    replace             0.2)
  (record [k attachment_loss]    seduce              0.2)
  (record [k attachment_loss]    kill                0.03)
  (record [k attachment_loss]    coerce              0.20)
  (record [k attachment_loss]    suicide             0.03)

  ; ---- moral_violation: actor's own held norms breached --------------------
  (record [k moral_violation]    confess_letter      0.5)
  (record [k moral_violation]    confess_in_person   0.3)
  (record [k moral_violation]    surrender           0.2)
  (record [k moral_violation]    atone               0.4)
  (record [k moral_violation]    frame               0.2)

  ; ---- existential_threat: directed lethal danger --------------------------
  (record [k existential_threat] flee                0.8)
  (record [k existential_threat] plead               0.4)
  (record [k existential_threat] surrender           0.3)
  (record [k existential_threat] kill                0.02)

  ; ---- status_loss: prestige drop ------------------------------------------
  (record [k status_loss]        withdraw            0.4)
  (record [k status_loss]        confront_privately  0.3)
  (record [k status_loss]        flee                0.2)
  (record [k status_loss]        expose              0.4)
  (record [k status_loss]        kill                0.03)

  ; ---- autonomy_loss: capability constrained by another --------------------
  (record [k autonomy_loss]      flee                0.5)
  (record [k autonomy_loss]      confront_privately  0.4)
  (record [k autonomy_loss]      plead               0.3)

  ; ---- resource_scarcity: material lack ------------------------------------
  (record [k resource_scarcity]  plead               0.5)
  (record [k resource_scarcity]  steal               0.3)
  (record [k resource_scarcity]  withdraw            0.3)
  (record [k resource_scarcity]  report_crime        0.3)

  ; ---- obligation_strain: too many duties ----------------------------------
  (record [k obligation_strain]  withdraw            0.5)
  (record [k obligation_strain]  atone               0.3)
  (record [k obligation_strain]  flee                0.2)

  ; ---- rivalry_pressure: directed competition ------------------------------
  (record [k rivalry_pressure]   strive              0.6)
  (record [k rivalry_pressure]   humiliate           0.5)
  (record [k rivalry_pressure]   expose              0.4)
  (record [k rivalry_pressure]   kill                0.02))
