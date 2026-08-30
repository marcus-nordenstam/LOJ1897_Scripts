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
; Throttled on @self's OWN status: he writes while unwed and still fancying
; someone (the @self role gates); once he betroths or weds he stops. He
; declares whether or not he yet knows she reciprocates.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think confess_by_letter
  (cooldown 1 m)
  (rng-stream marriages)

  (role @self (grown @self)
              (none {@self spouse ?})
              (none {@self fiancee ?})
              {@self fancy ?}
              ; @self signs the letter - bind his OWN name for the "Signed, .." line.
              {@self name ?author_name})
  ; The one @self is most drawn to, still single. @self declares whether or not he
  ; already knows she cares - the one who has LEARNED she is fancied is exactly who
  ; should now declare back, so this must NOT gate on {?target fancy @self}. Writing
  ; stops when @self betroths / weds (the @self role gates above).
  (role ?target (any_human ?target)
                (marriageable-age ?target)
                (none {?target spouse ?})
                (is-attracted-to @self ?target)
                ; APART: a co-present suitor uses the spoken confess_fancy. Role-side so a
                ; location write re-tests membership and the argmax ranks only apart targets.
                (not (spatial ?target co-located @self))
                ; @self must KNOW her name to write to her - bind it for the body's
                ; name value (no live object on the wire).
                {?target name ?target_name}
                (select (score (stance-band ?target attraction)) (policy argmax)))

  ; @self knows where she lives.
  (when (and (any {?target home ?target_home})
             (chance 0.4)))

  (utility want)

  (effects
    ; The confession + signature, authored in natlang: the body names her by the
    ; name @self believes ("I fancy ?target_name") and the "Signed, .." line becomes
    ; a (formulaic author ..) the reader resolves @i from (no C++ compose, no baked
    ; signature). Addressed to her, so her morning post read (read_post) adopts it.
    (post-letter [k courtship_letter]
                 (nl-written-msg "I fancy ?target_name. Signed, ?author_name")
                 ?target_home ?target)))
