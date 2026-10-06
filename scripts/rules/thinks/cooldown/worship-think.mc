; ----------------------------------------------------------------------------
; worship (think) - the churchgoing aspect, B4 desire + case sub-goals
; (mirrors the drinking aspect in crave_drink.mc). The service act lives in
; npc-act/worship.mc.
;
; ONE desire computes the pressure ONCE; the case rules read the worship goal and
; maintain the appropriate sub-goal, which INHERITS the worship drive (auto-/caused_by off
; the (goal ...) clause) and, as the live leaf, out-competes its parent (leaf-only):
;
;   want-worship (desire): PRESSURE = days since the last service, x politeness (respect
;     for convention), CAPPED as a LEISURE act (max ~40, below work / meals / sleep). It
;     rises daily and collapses the moment the NPC worships, so a devout man is drawn back
;     ~weekly while a secular one never clears a routine act. Holds {@self WORSHIP}.
;   AT a church (case A): {@self WORSHIP} has no active sub-goal, so it is the leaf and
;     promotes straight to worship_act (the service). No rule needed.
;   know a church (case B): worship-go holds {@self go ?church}.
;   know none  (case C): worship-find holds {@self find-building [k church-building]}.
; ----------------------------------------------------------------------------

(include "../../../macros/intensity-macros.mc")

; The DESIRE. A churchgoer (some politeness) who has not been to a service since the
; last representative day wants to attend. hsim simulates ONE representative day per
; monthly window, so this is the finest churchgoing cadence the pre-sim can carry - a
; weekday gate (e.g. Sunday-only) would fire only on the ~1 window a year whose
; representative day happens to land on that weekday, never converging. Worshipping
; resets days-since, so it re-arms each window. A HIGH utility (x politeness) so
; churchgoing wins the representative day's motor when the NPC is off work and reliably
; routes them to a church, instead of losing the pure pressure-vs-routine competition.
(think want-worship
  ; Rhythmic drive: a 3-day cooldown re-checks the urge; the (days-since) + politeness
  ; fire-gate holds the standing worship desire while due. The MINTER owns un-minting:
  ; once worship_act resets days-since-last the (when) drops, ending
  ; {@self WORSHIP}. The act never ends the goal.
  (cooldown 3 d try-until-succ)
  (role @self {@self politeness ?politeness}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (when    (and (>= (days-since-last {@self WORSHIP /succ /ever}) 3)
                  (>= ?politeness 0.3)))
    (declare-utility want (* (* 500.0 (clamp (/ (- (days-since-last-float {@self WORSHIP /succ /ever}) 3.0)
                                         (- 21.0 3.0))
                                      0.0 1.0)) (clamp (+ 1.0 (delib-ctr ?politeness (k-drive-trait-swing))) 0.0 2.0)))
    (effects
                   (begin-goal {@self WORSHIP}))
    (when-unsupported-effects (set-outcome {@self goal {@self WORSHIP}} /succ))))

; THE DEVOUT'S SUNDAY OBSERVANCE - the classifier-cast band split (ruling 8a). The SAME
; worship drive, but role-cast on the identity-grade `devoutness` classifier belief
; ({@self devoutness [k devout]}, minted + decayed by classify-self-devoutness.mc): a devout
; NPC's churchgoing is an OBLIGATION (socially mandatory), not a passing want, so it outranks
; ordinary errands and leisure. The atheist is never cast; the lapsed churchgoer decays out of
; the classifier; the pretender fools observers exactly as before. Co-drives the ONE
; {@self WORSHIP} goal with want-worship - each rung ceases only its OWN source.
(think sunday-observance
  (cooldown 3 d try-until-succ)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self devoutness [k devout]}
    (when    (>= (days-since-last {@self WORSHIP /succ /ever}) 3))
    (declare-utility obligation)
    (effects       (begin-goal {@self WORSHIP}))
    (when-unsupported-effects (set-outcome {@self goal {@self WORSHIP}} /succ))))
