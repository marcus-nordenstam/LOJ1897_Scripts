; ----------------------------------------------------------------------------
; resolve_applications ?out - the recruit officer's verdict round over the applications he
; holds, ONE at a time: the first held application gets an offer drafted, every later one a
; rejection; each drafting act files its verdict letter into ?out and destroys the answered
; application, so the held set shrinks to empty and the round concludes. The iteration and
; the offer-vs-reject decision live here; the drafting acts are dumb paperwork.
;
; and: the offer / reject tries are complementary on whether an offer was drafted this
; round (/caused_by ?rt-rel); done fires once no applications remain in hand.
; ----------------------------------------------------------------------------

(npc-task {@self resolve_applications ?out}:?rt-rel
  (tar @excl stack)
  (and
    (try
      (role ?app [k application] (spatial @self hold)
            (select (policy first-match)))
      (when (none {@self DRAFT_OFFER ? ? /succ /caused_by ?rt-rel}))
      (utility fallback)
      (effects (debug-print "RSV_OFFER") (maintain-proposal {@self DRAFT_OFFER ?app ?out})))
    (try
      (role ?app [k application] (spatial @self hold)
            (select (policy first-match)))
      (when (any {@self DRAFT_OFFER ? ? /succ /caused_by ?rt-rel} (out exists-bool)))
      (utility (above DRAFT_OFFER))
      (effects (debug-print "RSV_REJECT") (maintain-proposal {@self DRAFT_REJECTION ?app ?out})))
    (try
      (when (empty (spatial @self hold [k application])))
      (effects (debug-print "RSV_DONE") (set-outcome ?rt-rel succ)))))
