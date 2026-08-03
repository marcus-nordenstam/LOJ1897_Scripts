; ----------------------------------------------------------------------------
; confess_by_letter (npc-think) - the POSTED half of grounding reciprocal
; courtship. confess_fancy declares in person, but a suitor and a SPECIFIC
; beloved rarely share a room, so a spoken confession almost never gets its
; chance. This is how it travels the rest of the time: @self writes the beloved a
; courtship_letter carrying his own regard ({@self fancy ?target}); the morning
; post (read_pending_mail) delivers it to her home, she reads it and comes to know
; she is fancied - exactly the belief the spoken confession would have planted,
; through the same read path every letter uses. No telepathy, no co-presence.
;
; Throttled on @self's OWN belief: he writes while he does not yet know she
; reciprocates ({?target fancy @self}) - once her own letter (or spoken word)
; tells him she cares, the declaration is made and he stops.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think confess_by_letter
  (cooldown 1 m)
  (rng-stream marriages)

  (role @self (grown @self)
              (not (believes {@self spouse ?}))
              (not (believes {@self fiancee ?}))
              (believes {@self fancy ?}))
  ; The one @self is most drawn to, still single. @self declares whether or not he
  ; already knows she cares - the one who has LEARNED she is fancied is exactly who
  ; should now declare back, so this must NOT gate on {?target fancy @self}. Writing
  ; stops when @self betroths / weds (the @self role gates above).
  (role ?target (any_human ?target)
                (marriageable-age ?target)
                (not (believes {?target spouse ?}))
                (is-attracted-to @self ?target)
                (select (score (stance-band ?target attraction)) (policy argmax)))

  ; Post it when they are APART (a co-present suitor uses the spoken confess_fancy)
  ; and @self knows where she lives.
  (when (and (not (co-present @self ?target))
             (is-entity (home-of ?target))
             (chance 0.4)))

  (effects
    (spawn-letter [k courtship_letter]
                  (written-msg {@self fancy ?target} signed)
                  (home-of ?target))))
