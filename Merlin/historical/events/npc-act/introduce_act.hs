; ----------------------------------------------------------------------------
; introduce (npc-think). @self introduces themselves - name, then job and
; nationality - to each CO-PRESENT STRANGER: someone @self perceives sharing
; their room (a per-mind {?x location <my room>} belief, minted on sight, so no
; telepathy) whom @self does not yet personally know. Hearing the introduction
; files @self as the stranger's acquaintance (and the reverse, when they answer),
; so the (not (personally-knows ...)) filter EXCLUDES them next window - the
; acquaintance tie IS the dedup, no told-check needed. The facts are stranger-tier
; (name / job / nationality: said to anyone), so no disclosure gate applies.
; Replaces the telepathic believe_about profile-copy + seed_venue_acquaintance.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think introduce
  (sim-window-think)
  (rng-stream behaviour)

  (role @self (any_human @self))
  ; A co-present, not-yet-known person. The location JOIN binds @self's own current
  ; room off {@self location ?loc}, then the candidate must be perceived in that
  ; same room ({?stranger location ?loc} in @self's OWN mind) and NOT already known.
  (role ?stranger (any_human ?stranger)
    (believes {@self location ?loc})
    (believes {?stranger location ?loc})
    (not (personally-knows @self ?stranger)))

  ; Sociability gate: an extraverted NPC strikes up an introduction more readily.
  (when (chance (* 0.5 (+ 0.4 (attr @self enthusiasm)))))

  (act-effects
    ; Direct self-introduction. Each fact is guarded on being held (an unemployed
    ; NPC has no job belief), and told directly - no selector, no tier gate.
    (if (bind {@self name ?myname})
        (tell-to ?stranger {@self name ?myname}))
    (if (bind {@self job ?myjob})
        (tell-to ?stranger {@self job ?myjob}))
    (if (bind {@self nationality ?nat})
        (tell-to ?stranger {@self nationality ?nat}))))
