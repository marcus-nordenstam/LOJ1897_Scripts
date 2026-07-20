; ----------------------------------------------------------------------------
; conspiracy_adoption.hs - taking up a murder proposal learned from a letter.
;
; The read-side half of clear_marriage's INSTIGATED conspiracy. The cheater's
; covert letter carries the plot ((written-msg {@self urge {?paramour kill ?spouse}}));
; reading it (read_secret_letters -> the codec adopt seam) mints the urge
; belief {<instigator> urge <plot>} in the reader's OWN mind - a reportable-
; crime-free record of being asked. THIS event is the decision to comply:
; the reader desires the instigator (attraction band >= 2) and is dark enough,
; so they take on the accomplice bond and the kill goal - both sourced to what
; they READ, never to a cross-mind mint. An intercepted letter means this
; event never fires: the lover simply never learned of the plot.
;
; PURE .hs over composable ops:
;   - (role ?instigator (believes {?instigator urge ?})) - anyone this mind
;     holds an urge belief FROM (candidate-subject belief filter);
;   - (bind {?instigator urge ?plot}) binds the plot clause; the clause-field
;     ops ((clause-subject/label/target ?plot)) decompose it: the plot must
;     name @self as the doer and carry a kill;
;   - the compliance gate mirrors the shape clear_marriage previously applied
;     telepathically: attraction band toward the instigator >= 2 plus a
;     psychopathy roll;
;   - effects mirror the struck cross-mind block, minted in @self's own mind:
;     the accomplice bond carries the plot clause as its AUX, and the kill
;     goal is /cause-pinned to the accomplice bond so rap sheets stay legible.
; begin-belief / begin-goal idempotency keeps re-reads from double-minting.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think conspiracy_adoption
  (schedule cooldown 1 m)
  (rng-stream perpetration)

  (role @self )
  ; Anyone @self believes has urged something - the belief arrives only by
  ; reading the letter (or hearing the words), never by telepathy.
  (role ?instigator (any_human ?instigator)
        (believes {?instigator urge ?}))

  ; The plot must ask ME to kill someone, and I must be willing: desire for
  ; the instigator (attraction band >= 2) plus the dark roll - the same
  ; compliance shape clear_marriage previously applied cross-mind.
  (when (and (bind {?instigator urge ?plot})
             (= (clause-label ?plot) kill)
             (= (clause-subject ?plot) @self)
             (>= (stance-band ?instigator attraction) 2)
             (chance (attr @self psychopathy))))

  (effects
    (bind (clause-target ?plot) ?victim)
    ; My own side of the conspiracy: the bond embeds the plot as its AUX
    ; clause, and the goal is pinned to the bond.
    (begin-belief {@self accomplice ?instigator ?plot})
    (begin-goal {@self kill ?victim} /cause {@self accomplice ?instigator})))
