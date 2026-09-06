; ----------------------------------------------------------------------------
; worship (npc-think lane) - the churchgoing lane, B4 desire + case sub-goals
; (mirrors the drinking lane in crave_drink.hs). The service act lives in
; npc-act/worship.hs.
;
; ONE desire computes the pressure ONCE; the case rules read the worship goal and
; maintain the appropriate sub-goal, which INHERITS the worship drive (auto-/caused_by off
; the (goal ...) clause) and, as the live leaf, out-competes its parent (leaf-only):
;
;   want_worship (desire): PRESSURE = days since the last service, x politeness (respect
;     for convention), CAPPED as a LEISURE act (max ~40, below work / meals / sleep). It
;     rises daily and collapses the moment the NPC worships, so a devout man is drawn back
;     ~weekly while a secular one never clears a routine act. Holds {@self WORSHIP}.
;   AT a church (case A): {@self WORSHIP} has no active sub-goal, so it is the leaf and
;     promotes straight to worship_act (the service). No rule needed.
;   know a church (case B): worship_go holds {@self go ?church}.
;   know none  (case C): worship_find holds {@self find-building [k church]}.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")
(include "../../../macros/intensity-macros.mc")

; The DESIRE. A churchgoer (some politeness) who has not been to a service since the
; last representative day wants to attend. hsim simulates ONE representative day per
; monthly window, so this is the finest churchgoing cadence the pre-sim can carry - a
; weekday gate (e.g. Sunday-only) would fire only on the ~1 window a year whose
; representative day happens to land on that weekday, never converging. Worshipping
; resets days-since, so it re-arms each window. A HIGH utility (x politeness) so
; churchgoing wins the representative day's motor when the NPC is off work and reliably
; routes them to a church, instead of losing the pure pressure-vs-routine competition.
(npc-think want_worship
  ; Rhythmic drive: a 3-day cooldown re-checks the urge; the (days-since) + politeness
  ; fire-gate holds the standing worship desire while due. The MINTER owns un-minting:
  ; once worship_act resets days-since-last the (when) drops, ending
  ; {@self WORSHIP}. The act never ends the goal.
  (cooldown 3 d)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]})
  (when    (and (>= (days-since-last {@self WORSHIP /ever}) 3)
                (>= (attr @self politeness) 0.3)))
  (utility want (* (recency-ramp WORSHIP 3 21 500) (devotional-drive-tilt)))
  (effects
                 (begin-goal {@self WORSHIP}))
  (cease-effects (end-goal   {@self WORSHIP})))

; THE DEVOUT'S SUNDAY OBSERVANCE - the classifier-cast band split (ruling 8a). The SAME
; worship drive, but role-cast on the identity-grade `devoutness` classifier belief
; ({@self devoutness [k piety-band devout]}, minted + decayed by devoutness.hs): a devout
; NPC's churchgoing is an OBLIGATION (socially mandatory), not a passing want, so it outranks
; ordinary errands and leisure. The atheist is never cast; the lapsed churchgoer decays out of
; the classifier; the pretender fools observers exactly as before. Co-drives the ONE
; {@self WORSHIP} goal with want_worship - each rung ceases only its OWN source.
(npc-think sunday_observance
  (cooldown 3 d)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self devoutness [k piety-band devout]})
  (when    (>= (days-since-last {@self WORSHIP /ever}) 3))
  (utility obligation)
  (effects       (begin-goal {@self WORSHIP}))
  (cease-effects (end-goal   {@self WORSHIP})))
