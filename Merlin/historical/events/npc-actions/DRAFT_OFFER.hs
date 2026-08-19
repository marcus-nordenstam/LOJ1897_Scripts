; ----------------------------------------------------------------------------
; draft_offer - the dumb drafting act of the resolve_applications iteration:
; write ONE offer letter for ?app's applicant, file it into the outgoing pile
; ?out, and destroy the answered application. WHICH application gets the offer
; is the proposing think's decision, never this act's.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self DRAFT_OFFER ?app ?out}
  (duration 15)
  (effects
    (read-doc-record [k application] ?app (applicant ?w))
    (if (substantial (home-of ?w))
      (then
        (create-entity [k offer_letter] (qual location (spatial @self building))): ?ol
        (set-attr ?ol addressee (attr ?w name))
        (set-attr ?ol address (home-of ?w))
        (check (attr ?ol address))
        (debug-print "DRAFT_OFFER w=?w")
        (push ?ol ?out)))
    (destroy-entity ?app)
    (set-outcome {@self DRAFT_OFFER ?app ?out} succ)))
