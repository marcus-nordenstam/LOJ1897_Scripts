; ----------------------------------------------------------------------------
; wed_at_founding (startup) - the founder generation arrives already married.
;
; make-founder-household mints a man and a woman into each residence but does NOT
; wed them: a marriage is a belief each spouse holds about the other, and at
; populate no mind has been self-perceived yet, so a human cannot yet be the
; target of another mind's belief - the field lands @fail. This rung runs at
; cold-start instead, once minds are live, and each spouse mints their OWN half.
; Nobody writes into anybody else's mind.
;
; The pair is found by CO-PRESENCE, not by a world-gen handle: the two of them are
; alone in their house, so the only co-located adult of the other sex is the one
; they were minted beside. That is also why the rule is harmless once the town is
; running - by then everyone is married, and the -{@self spouse ?} gate is shut.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-think wed_at_founding
  (startup)
  (rng-stream marriages)

  (role @self {@self isa [k human], condition [k alive]}
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              -{@self spouse ?})

  ; The other adult under this roof, of the other sex and likewise unwed. A
  ; founder household holds exactly two people, so this is unambiguous.
  (role ?match {?match isa [k human], condition [k alive]}
               (spatial ?match co-located @self)
               -{?match gender (any {@self gender}).target}
               -{@self spouse ?match})

  (utility duty)

  (effects
    (begin-belief {@self spouse ?match})))
