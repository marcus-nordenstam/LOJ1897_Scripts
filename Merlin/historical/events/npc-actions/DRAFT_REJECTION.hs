; ----------------------------------------------------------------------------
; draft_rejection - the dumb drafting act of the resolve_applications
; iteration: write ONE rejection letter for ?app's applicant, file it into the
; outgoing pile ?out, and destroy the answered application.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self DRAFT_REJECTION ?app ?out}
  (duration 10)
  (effects
    (read-doc-record [k application] ?app (applicant ?w))
    (if (substantial (home-of ?w))
      (then
        (create-entity [k rejection_letter] (qual location (building @self))): ?rl
        (set-attr ?rl addressee (attr ?w name))
        (set-attr ?rl address (home-of ?w))
        (push ?rl ?out)))
    (destroy-entity ?app)
    (set-outcome {@self DRAFT_REJECTION ?app ?out} succ)))
