; ----------------------------------------------------------------------------
; confess_fancy (npc-think) - the deliberation that grounds reciprocal courtship
; WITHOUT telepathy.
;
; THE PROBLEM: a love match needs MUTUAL fancy, but a suitor cannot read his
; beloved's heart. THE FIX: whoever fancies someone TELLS THEM - when they are
; together. This think casts the pair and PROPOSES the confession; the pure
; confess_fancy_act.hs does (tell-to ?target {@self fancy ?target}), saying it
; directly to ?target, and perception delivers {@self fancy ?target} into ?target's
; mind, sourced to the spoken {@self SAY ...}. Now each suitor reads the OTHER
; side's fancy from his OWN belief (love_match / court / lovers gate on (believes
; {?beloved fancy @self})) - never a cross-mind read.
;
; PRIVATE by co-presence: gated on (co-present @self ?target) - a confession needs
; the two together (and only carries to them and whoever else is in the room).
;
; `fancy` only forms opposite-sex (the crush_forms gate), so no gender filter is
; needed.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think confess_fancy
  (schedule cooldown 1 m)
  (rng-stream marriages)

  ; @self fancies someone and is free to court (cheap @self pre-gate; the
  ; specific pair is the ?target stance gate below).
  ; grown = marriageable-age; @self's own isa/condition (from any_human) are
  ; no-ops for the deliberating self, so drop them from the cached self-gate.
  (role @self (grown @self)
              (not (believes {@self spouse ?}))
              (believes {@self fancy ?}))
  ; ?target is the specific person @self is attracted to (attraction at least
  ; the `fancy` band - the same gate court / love_match read).
  (role ?target (any_human ?target)
                (marriageable-age ?target)
                (is-attracted-to @self ?target)
                (co-present @self))

  (utility 22)

  (effects
    (propose {@self confess_fancy ?target})))
