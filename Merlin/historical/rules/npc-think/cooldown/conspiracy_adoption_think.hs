; ----------------------------------------------------------------------------
; conspiracy_adoption.hs - taking up a murder proposal learned from a letter.
;
; The read-side half of clear_marriage's INSTIGATED conspiracy. The cheater's
; covert letter carries the plot ((written-msg {@self urge {?paramour kill ?spouse}}));
; reading it (read_secret_letters -> the codec adopt seam) mints the urge
; belief {<instigator> urge <plot>} in the reader's OWN mind - a reportable-
; crime-free record of being asked. THIS rule is the decision to comply:
; the reader desires the instigator (attraction band >= 2) and is dark enough,
; so they take on the accomplice bond and the kill goal - both sourced to what
; they READ, never to a cross-mind mint. An intercepted letter means this
; rule never fires: the lover simply never learned of the plot.
;
; PURE .hs over composable ops:
;   - (role ?instigator (believes {?instigator urge @self {@self kill ?victim}:?plot-rel}))
;     - anyone this mind holds a kill-me-plot urge FROM, matched structurally by
;     the role cache's clause descent: membership wakes on the urge-belief write,
;     and ?victim + the whole ?plot-rel clause bind at the when-gate;
;   - the compliance gate: attraction band toward the instigator >= 2 plus a
;     psychopathy roll;
;   - effects mirror the struck cross-mind block, minted in @self's own mind:
;     the accomplice bond carries the plot clause as its AUX, and the kill
;     goal is /caused_by-pinned to the accomplice bond so rap sheets stay legible.
; begin-belief / begin-goal idempotency keeps re-reads from double-minting.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think conspiracy_adoption
  (cooldown 1 m)
  (rng-stream perpetration)

  (role @self )
  ; Anyone @self believes WANTS him to do the kill - the goal arrives only by reading
  ; the (msg_class urge) letter (its content is the instigator's goal clause), never
  ; by telepathy. The adopted belief is {<instigator> goal {<me> kill <victim>}}; the
  ; nested kill clause is the role's own membership criterion, and the {..}:?plot-rel
  ; capture + free ?victim bind at the when-gate.
  (role ?instigator (any_human ?instigator)
                    {?instigator goal {@self kill ?victim}:?plot-rel})

  ; It must be ANOTHER's goal (not my own kill goal), I must be willing: desire for the
  ; instigator (attraction band >= 2) plus the dark roll.
  (when (and (!= ?instigator @self)
             (>= (stance-band ?instigator attraction) 2)
             (chance (attr @self psychopathy))))

  (utility want)
  (effects
    ; My own side of the conspiracy: the bond embeds the plot as its AUX
    ; clause, and the goal is pinned to the bond.
    (begin-belief {@self accomplice ?instigator ?plot-rel}): ?accomplice-rel
    (begin-goal {@self kill ?victim /caused_by ?accomplice-rel})))
