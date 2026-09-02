; ----------------------------------------------------------------------------
; confess_fancy (npc-think) - the deliberation that grounds reciprocal courtship
; WITHOUT telepathy.
;
; THE PROBLEM: a love match needs MUTUAL fancy, but a suitor cannot read his
; beloved's heart. THE FIX: whoever fancies someone TELLS THEM - when they are
; together. This think casts the pair, composes the message and
; PROPOSES the confession; the shared say_to act says it directly to ?target,
; and perception delivers {@self fancy ?target} into ?target's
; mind, sourced to the spoken {@self SAY ...}. Now each suitor reads the OTHER
; side's fancy from his OWN belief (love_match / court / lovers gate on (believes
; {?beloved fancy @self})) - never a cross-mind read.
;
; PRIVATE by co-presence: ?target shares @self's location (the co-location role filter) - a confession needs
; the two together (and only carries to them and whoever else is in the room).
;
; `fancy` only forms opposite-sex (the crush_forms gate), so no gender filter is
; needed.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think confess_fancy
  (cooldown 1 m)
  (rng-stream marriages)

  ; @self fancies someone and is free to court (cheap @self pre-gate; the
  ; specific pair is the ?target stance gate below).
  ; grown = marriageable-age; @self's own isa/condition (from any_human) are
  ; no-ops for the deliberating self, so drop them from the cached self-gate.
  (role @self (grown @self)
              -{@self spouse ?}
              {@self fancy ?})
  ; ?target is the specific person @self is attracted to (attraction at least
  ; the `fancy` band - the same gate court / love_match read).
  (role ?target (any_human ?target)
                (marriageable-age ?target)
                (is-attracted-to @self ?target)
                (spatial ?target co-located @self))

  (utility want)

  (effects
    (nl-utterable-msg "I fancy you"): ?msg
    (maintain-proposal {@self SAY ?msg ?target})))
