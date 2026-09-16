; say - THE one speech act. Every think that wants to say something composes
; its wire message ((utterable-msg ...) / (utterable-qs ...)) and proposes
; {@self SAY ?msg ?audience}; this pure act says it aloud. A substantial
; ?audience is a DIRECTED say (the SAY memory's /aux is the listener - the
; per-listener untold dedup); an absent audience (_) is an open BROADCAST.
; Delivery is by co-presence either way.
;
; The act-belief the head binds IS the utterance record - minted by the pipeline
; when the proposal won, ended here. (xaction ?xsay) hands the body that act's ABS
; twin, externalized by the pipeline at promotion, and deliver-speech hangs the
; sound off THAT - so the record the world carries is the pipeline's own.

(npc-action {@self SAY ?msg ?audience}:?say-rel
  (xaction ?xsay)
  (sub @msgAuthor human)   
  (tar @msg @excl @S) 
  ; OPTIONAL by declaration: an absent audience is a BROADCAST, which is a first-class
  ; SAY form (confide / expose / humiliate / the burial announcement all use it).
  (aux @msgAudience ?)
  (duration 0)
  (effects
    (deliver-speech ?xsay)
    (set-outcome ?say-rel /succ)))
