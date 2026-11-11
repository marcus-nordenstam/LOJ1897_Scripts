; say - THE one speech act. Every think that wants to say something composes
; its message ((msg /utterable ...) / (qs /utterable ...)) and proposes
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
  ; THE LENGTH IS THE WORDS: the seconds the line takes to say as the world holds it - the words
  ; the sound and the subtitle carry - when he is presented, and never under a second for anyone,
  ; so no reply shares a second with what it answers.
  (duration (utterance-seconds ?xsay))

  ; A say starts here, ONCE: the SOUND, which is the Merlin half and how anyone else hears
  ; this at all, and when presented the VOICE - the words rendered, the visemes cut, the jaw
  ; driven, the subtitle put up. Effects run every frame while the audio plays and would say
  ; it again each time.
  ; Nobody is spoken to by two men at once: presented, tell held the turn this line takes before
  ; proposing it (turn-board, funcs/conversation.mc); unpresented there are no turns. The board can
  ; change between the two - its audience joins or leaves a talk - so it is expected, not checked.
  ; The player's lines take no turn and he has no mind to read the tell in.
  (init
    (deliver-speech ?xsay)
    (if (presented-lod)
        (then
          (if (is-npc)
              (then (expect (line-took-its-turn ?SAY ?audience)
                            "SAY: the line began without the turn it takes - its board changed since tell held it")))
          (speak-aloud @self ?msg))))

  ; The unpresented say is heard and not watched: its sound went out as it began, and is heard
  ; the second after, at the instant the line ends.
  (effects
    (if (unpresented-lod)
        (then (set-outcome ?SAY /succ))))

  ; The speech-state slot the handler claimed at install is released on EVERY end: a slot leaked
  ; per interrupted utterance is a mouth that stops working after a few dozen conversations.
  (cease
    (if (presented-lod)
        (then (end-speech @self)))))
