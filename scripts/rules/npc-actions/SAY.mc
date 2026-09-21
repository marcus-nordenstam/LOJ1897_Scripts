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
  (motor mouth)
  (presentation
    (state telling)
    (proc-anim tell)
    (preroll 0.0) (in 0.1) (out 0.1))
  (xaction ?xsay)
  (sub @msgAuthor [k human] @object)   
  (tar @msg @excl @pattern) 
  ; OPTIONAL by declaration: an absent audience is a BROADCAST, which is a first-class
  ; SAY form (confide / expose / humiliate / the burial announcement all use it).
  (aux @msgAudience ?)
  ; THE SCHEDULED LENGTH IS AN INSTANT, and the presented one is the AUDIO: the seconds
  ; the rendered words take to say, cut from the visemes, so the act ends when the sound
  ; does and the cap commits the /succ. hsim has always said zero, and one second per
  ; utterance across a year of conversation is not a second worth moving every
  ; appointment in the town for.
  (duration
    (cond (case (presented-lod) (speech-seconds @self ?msg))
          (else 0)))

  ; A /fail here rejects the install, as the handler's rejection of an unsubstantial
  ; message did. A presented say starts here, ONCE: the SOUND, which is the Merlin half
  ; and how anyone else hears this at all, hung off the pipeline's own externalized
  ; record; and the VOICE - the words rendered, the visemes cut, the jaw driven, the
  ; subtitle put up. Effects run every frame while the audio plays and would say it
  ; again each time.
  (init
    (cond
      (case (unsubstantial ?msg) (set-outcome ?say-rel /fail))
      (case (presented-lod)
        (deliver-speech ?xsay)
        (speak-aloud @self ?msg))))

  ; The unpresented say is its one tick: the sound, and done. An unpresented man is
  ; heard and not watched.
  (effects
    (if (unpresented-lod)
        (then (deliver-speech ?xsay)
              (set-outcome ?say-rel /succ))))

  ; The handler's cleanup_func released the speech-state slot it claimed at install. That
  ; is a (cease ..): it must happen on EVERY end, and a slot leaked per interrupted
  ; utterance is a mouth that stops working after a few dozen conversations.
  (cease
    (if (presented-lod)
        (then (end-speech @self)))))
