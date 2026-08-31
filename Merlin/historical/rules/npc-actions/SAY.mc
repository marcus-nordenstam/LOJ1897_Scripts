; say_to - THE one speech act. Every think that wants to say something composes
; its wire message ((utterable-msg ...) / (utterable-qs ...)) and proposes
; {@self SAY ?msg ?audience}; this pure act says it aloud. A substantial
; ?audience is a DIRECTED say (the SAY memory's /aux is the listener - the
; per-listener untold dedup); an absent audience (_) is an open BROADCAST.
; Delivery is by co-presence either way.

(npc-action {@self SAY ?msg ?audience}:?say-rel
  (sub @msgAuthor human)   
  (tar @msg @excl @S) 
  (aux @msgAudience human)
  (duration 0)
  (effects
    (if ?audience
        (then (tell-to ?audience ?msg))
        (else (tell ?msg)))
    (set-outcome ?say-rel /succ)))
