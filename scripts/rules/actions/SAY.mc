; say - THE one speech act. Whatever wants something said composes its message
; ((msg /utterable ...) / (qs /utterable ...)) into an intent to say it, and the say
; driver (drivers/say-driver.mc), the one rule that proposes {@self SAY ?msg ?audience},
; pursues it; this pure act says it aloud. A substantial
; ?audience is a DIRECTED say (the SAY memory's /aux is the listener - the
; per-listener untold dedup); an absent audience (_) is an open BROADCAST.
;
; The act-belief the head binds IS the utterance record - born at the install,
; ended here. (xaction ?xsay) hands the body that act's ABS twin, externalized at
; that birth: the record the world carries is the pipeline's own.
;
; A LINE IS SAID WHEN IT HAS BEEN SAID TO ITS END. Everything that follows from it happens
; then, at once and in one place (line-said, funcs/speech.mc): whoever it is for hears it, it is
; logged in the talk it went into, and its speaker knows what he has told and to whom. A line
; that does not reach its end was not said.

(action {@self SAY ?msg ?audience}:?SAY
  (belief-timeout 1 min)
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

  ; A say starts here, ONCE, when presented: the VOICE - the words rendered, the visemes cut, the
  ; jaw driven, the subtitle put up. Effects run every frame while the audio plays and would say
  ; it again each time.
  ; Nobody is spoken to by two men at once: presented, his intent's driver held the turn this line
  ; takes before proposing it (turn-board, funcs/talk.mc), and a line to a man or a talk always
  ; takes one; unpresented there are no turns. The board can change between the two - its audience
  ; leaves the talk - so it is expected, not checked. The player's lines take no turn and he has no
  ; mind to read the intent in.
  (init
    (if (presented-lod)
        (then
          (if (is-npc)
              (then (expect (my-turn ?audience)
                            "SAY: the line began without the turn it takes - its board changed since its driver held it")))
          (speak-aloud @self ?msg))))

  ; The unpresented say is heard and not watched: it is said the second after it began, at the
  ; instant the line ends.
  (effects
    (if (unpresented-lod)
        (then (set-outcome ?SAY /succ))))

  ; The speech-state slot the handler claimed at install is released on EVERY end: a slot leaked
  ; per interrupted utterance is a mouth that stops working after a few dozen talks.
  (cease
    (if (succeeded ?SAY)
        (then (line-said ?xsay ?SAY ?audience)))
    (if (presented-lod)
        (then (end-speech @self)))))
