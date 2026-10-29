; say - THE one speech act. Every think that wants to say something composes
; its wire message ((msg /utterable ...) / (qs /utterable ...)) and proposes
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
  ; A line once begun is said to its end: nothing outbids it on the mouth.
  (uninterruptable)
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
  ; presented, and never under a second for anyone, so no reply shares a second with what it
  ; answers.
  (duration (utterance-seconds @self ?msg ?audience))

  ; A presented say starts here, ONCE: the SOUND, which is the Merlin half and how
  ; anyone else hears this at all, and the VOICE - the words rendered, the visemes cut,
  ; the jaw driven, the subtitle put up. Effects run every frame while the audio plays
  ; and would say it again each time.
  ; Nobody is spoken to by two men at once: tell marked the listener his before proposing this
  ; (claim-addressees, funcs/conversation.mc), and a claim lost to another man was decided
  ; before anything started.
  (init
    (check (holds-address ?audience))
    (if (presented-lod)
        (then (deliver-speech ?xsay)
              (speak-aloud @self ?msg))))

  ; The unpresented say is its one tick: the sound, and done. An unpresented man is
  ; heard and not watched.
  (effects
    (if (unpresented-lod)
        (then (deliver-speech ?xsay)
              (set-outcome ?SAY /succ))))

  ; The floor and the marks tell claimed are the line's until it is said, and its tell's while
  ; that runs; the line releases them when it outlived its tell, and its mark on its audience
  ; unless the tell now running addresses the same audience. The speech-state
  ; slot the handler claimed at install is released with them. That is a (cease ..): it must
  ; happen on EVERY end, and a slot leaked per interrupted utterance is a mouth that stops
  ; working after a few dozen conversations.
  (cease
    (cond (case (none {@self tell ? ?})
            (release-floor)
            (release-addressees ?audience))
          (case (none {@self tell ? ?audience})
            (release-mark ?audience)))
    (if (presented-lod)
        (then (end-speech @self)))))
