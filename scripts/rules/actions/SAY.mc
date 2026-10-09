; say - THE one speech act. Every think that wants to say something composes
; its wire message ((utterable-msg ...) / (utterable-qs ...)) and proposes
; {@self SAY ?msg ?audience}; this pure act says it aloud. A substantial
; ?audience is a DIRECTED say (the SAY memory's /aux is the listener - the
; per-listener untold dedup); an absent audience (_) is an open BROADCAST.
; Delivery is by earshot either way (in-earshot).
;
; The act-belief the head binds IS the utterance record - born at the install,
; ended here. (xaction ?xsay) hands the body that act's ABS twin, externalized at
; that birth, and deliver-speech hangs the sound off THAT - so the record the world
; carries is the pipeline's own.

(action {@self SAY ?msg ?audience}:?SAY
  (motor mouth)
  (unique)
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
  ; THE LENGTH IS THE WORDS: the seconds the rendered message takes to say when he is
  ; presented, and an instant when he is not - one second per utterance across a year of
  ; conversation is not a second worth moving every appointment in the town for.
  (duration (utterance-seconds @self ?msg ?audience))

  ; A presented say starts here, ONCE: the SOUND, which is the Merlin half and how
  ; anyone else hears this at all, and the VOICE - the words rendered, the visemes cut,
  ; the jaw driven, the subtitle put up. Effects run every frame while the audio plays
  ; and would say it again each time.
  (init
    (if (presented-lod)
        (then (deliver-speech ?xsay)
              (speak-aloud @self ?msg))))

  ; The unpresented say is its one tick: the sound, and done. An unpresented man is
  ; heard and not watched.
  (effects
    (if (unpresented-lod)
        (then (deliver-speech ?xsay)
              (set-outcome ?SAY /succ))))

  ; The handler's cleanup_func released the speech-state slot it claimed at install. That
  ; is a (cease ..): it must happen on EVERY end, and a slot leaked per interrupted
  ; utterance is a mouth that stops working after a few dozen conversations.
  (cease
    (if (presented-lod)
        (then (end-speech @self)))))
