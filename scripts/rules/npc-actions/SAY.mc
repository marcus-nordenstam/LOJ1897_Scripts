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
  (presentation
    (state telling)
    (proc-anim tell)
    (preroll 0.0) (in 0.1) (out 0.1))
  (xaction ?xsay)
  (sub @msgAuthor human)   
  (tar @msg @excl @S) 
  ; OPTIONAL by declaration: an absent audience is a BROADCAST, which is a first-class
  ; SAY form (confide / expose / humiliate / the burial announcement all use it).
  (aux @msgAudience ?)
  ; THE SCHEDULED LENGTH IS AN INSTANT, and the presented one is the audio. The isim
  ; handler computed the viseme total and wrote it into the act's run cap, succeeding when
  ; the sound finished; unpresented it used a flat second, because without the natlang
  ; pass there is no length to know and nothing to sync to. hsim has always said zero,
  ; and one second per utterance across a year of conversation is not a second worth
  ; moving every appointment in the town for - so the split waits, with WALK and WRITE,
  ; on a (duration ..) expression that can branch on the LOD (plan 2.3).
  (duration 0)

  ; The handler rejected an unsubstantial message and let the dispatcher roll the act
  ; back. A /fail here is that rejection.
  (init
    (if (unsubstantial ?msg)
        (then (set-outcome ?say-rel /fail))))

  (effects
    ; The SOUND is the Merlin half and runs at both LODs: it is how anyone else hears
    ; this at all, and it hangs off the pipeline's own externalized record.
    (deliver-speech ?xsay)
    ; The VOICE is the presented half - the words rendered, the visemes cut, the jaw
    ; driven, the subtitle put up. An unpresented man is heard and not watched.
    (if (presented-lod)
        (then (speak-aloud @self ?msg)))
    (set-outcome ?say-rel /succ))

  ; The handler's cleanup_func released the speech-state slot it claimed at install. That
  ; is a (cease ..): it must happen on EVERY end, and a slot leaked per interrupted
  ; utterance is a mouth that stops working after a few dozen conversations.
  (cease
    (if (presented-lod)
        (then (end-speech @self)))))
