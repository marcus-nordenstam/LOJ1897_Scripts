; ----------------------------------------------------------------------------
; relapse - the drinking event for NPCs who have formed a standing craving
; for drink (the {@self craving alcohol} drive). A craving does not decay -
; reform resists it, never erases it - so a dependent drinker relapses
; often. The chance is high and modulated: distress (withdrawal) and weak
; restraint (low industriousness) drive relapse; religious involvement and
; deep social embedding resist it but never to zero - the lifelong battle.
; Onset into dependence happens in get_drunk.hse via (risk-dependence ?npc);
; this event carries it forward.
;
; Design note. The protective factors read the piety and belonging
; situations cached by derive_prototypes, not raw (count-beliefs attend)
; / (count-beliefs close_to) tallies - the signal is "how religious /
; socially-embedded is this NPC" not "how many of each individual event
; have been logged." Bounded factors let the engine's (chance ...)
; decomposition engage; worst-case product is ~0.92 so the pre-roll
; trims only a small fraction (relapse has a high base rate by design)
; but the math is exact, and the slow-path warning is gone.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event relapse
  (nl         "?npc relapses into drink")
  (kind       _relapse)
  (schedule   (monthly))
  (rng-stream behaviour)

  (roles
    (role ?npc (template old_human)
               (= (belief-target ?self craving) alcohol)
               (chance
                 (* 0.30                                                  ; base monthly relapse
                    (+ 0.60 (* 0.80 (attr ?self withdrawal)))              ; distress drives relapse
                    (+ 0.70 (* 0.60 (- 1.0 (attr ?self industriousness)))) ; weak restraint
                    (- 1.3 (* 0.6 (situation ?self piety)))                ; piety resists
                    (- 1.3 (* 0.6 (situation ?self belonging))))))) ; belonging resists

  (effects
    (get-drunk ?npc)
    (log _relapse ?npc)))
