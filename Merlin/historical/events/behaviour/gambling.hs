; ----------------------------------------------------------------------------
; gambling - a behaviour seed event. Each year a few adults take to (or sink
; deeper into) gambling: the (gamble ...) effect bumps their `gambling_addiction`
; attr (0..1, capped at morbid), exactly as get_drunk bumps `intoxication`. The
; F3.5 sobriety and wealth classifiers read the attr GRADED - a deeper addiction
; is more intemperate and loses more money. No once-per-NPC gate: re-firing is
; how the addiction DEEPENS (the effect's cap bounds it). Low industriousness
; (a want of self-discipline) raises the annual chance.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event gambling
  (nl         "?npc takes to gambling")
  (kind       _gambling)
  (schedule   (annually march))
  (band      evening)
  (rng-stream behaviour)

  (roles
    ; Low industriousness (a want of self-discipline) takes to gambling more.
    ; Mean-1.0 factor - the base rate is the average annual chance.
    (role ?npc (template old_human)
               (chance (* 0.006 (+ 0.6 (* 0.8 (- 1.0 (attr ?self industriousness))))))))

  (effects
    (gamble ?npc)
    (log _gambling ?npc)))
