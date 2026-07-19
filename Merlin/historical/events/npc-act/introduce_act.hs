; ----------------------------------------------------------------------------
; introduce (npc-think). @self introduces themselves to each CO-PRESENT STRANGER:
; someone @self perceives sharing their room (a per-mind {?x location <my room>}
; belief, minted on sight, so no telepathy) whom @self does not yet personally know.
; @self SAYS every stranger-tier fact they hold about themselves - name / job /
; nationality / class, whatever the ontology annotates (disclosure stranger),
; sourced from @self's OWN beliefs via (disclosure-tier-labels stranger). Hearing the
; introduction files @self as the stranger's acquaintance (and the reverse, when
; they answer), so the (not (personally-knows ...)) filter EXCLUDES them next
; window - the acquaintance tie IS the dedup, no told-check needed. The facts are
; stranger-tier (said to anyone), so no disclosure gate applies. Replaces the
; telepathic believe_about profile-copy + seed_venue_acquaintance.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think introduce
  (sim-window-think)
  (rng-stream behaviour)

  (role @self )
  ; A co-present, not-yet-known person: sourced OBJECTIVELY from @self's current room
  ; (env contents), each candidate passively perceived, then filtered to those NOT
  ; already personally known.
  (role ?stranger (any_human ?stranger) (co-present @self) (not (personally-knows @self ?stranger)))

  ; Sociability gate: an extraverted NPC strikes up an introduction more readily.
  (when (chance (* 0.5 (+ 0.4 (attr @self enthusiasm)))))

  (act-effects
    ; Walk @self's OWN stranger-tier self-beliefs (the ontology (disclosure stranger)
    ; band: name / job / nationality / class / ...) and tell each to the stranger.
    ; An unheld fact (an unemployed NPC has no job belief) simply is not walked.
    (for-each-belief ?fact {@self (disclosure-tier-labels stranger) ?}
      (tell-to ?stranger ?fact))))
