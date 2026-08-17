; ----------------------------------------------------------------------------
; resolve_applications ?out - the recruit officer's verdict round over the
; applications he holds, ONE at a time: the first held application gets an
; offer drafted, every later one a rejection; each drafting act files its
; verdict letter into ?out and destroys the answered application, so the held
; set shrinks to empty and the round concludes. The iteration and the
; offer-vs-reject decision live HERE; the drafting acts are dumb paperwork.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; No offer drafted this round yet -> the first held application is the hire.
(npc-think resolve_applications_offer
  (task {@self resolve_applications ?out}:?rt)
  (role ?app [k application] (spatial @self hold)
        (select (policy first-match)))
  (when (none {@self DRAFT_OFFER ? ? /succ /caused_by ?rt}))
  (utility fallback)
  (effects (debug-print "RSV_OFFER") (maintain-proposal {@self DRAFT_OFFER ?app ?out})))

; Offer already drafted -> every remaining held application is a rejection.
(npc-think resolve_applications_reject
  (task {@self resolve_applications ?out}:?rt)
  (role ?app [k application] (spatial @self hold)
        (select (policy first-match)))
  (when (any {@self DRAFT_OFFER ? ? /succ /caused_by ?rt} (out int)))
  (utility (above DRAFT_OFFER))
  (effects (debug-print "RSV_REJECT") (maintain-proposal {@self DRAFT_REJECTION ?app ?out})))

; Hands empty of applications -> the round is concluded.
(npc-think resolve_applications_done
  (task {@self resolve_applications ?out}:?rt)
  (when (empty (spatial @self hold [k application])))
  (effects (debug-print "RSV_DONE") (set-outcome ?rt succ)))
