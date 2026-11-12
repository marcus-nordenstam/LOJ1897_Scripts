; ----------------------------------------------------------------------------
; scribble ?thing ?sentence - THE one action that writes ON a thing rather than in it: pen ?sentence
; onto ?thing's scribbles, appending to whatever is scribbled there already - a name in the front of
; a book, a child's on his toy, a seller's crossed out and the buyer's under it. A document's own
; content is WRITE's. Its proposer hands it the thing and the sentence.
; ----------------------------------------------------------------------------

(action {@self SCRIBBLE ?thing ?sentence}:?SCRIBBLE
  (track-skill-level [k literacy])
  (motor right-hand)
  (obs)
  (tar @excl)
  (aux @msg @excl)
  (duration (seconds 1 min))
  (presentation
    (preroll 0.0) (in 0.4) (out 0.4))
  (effects
    (check (spatial @self can-reach ?thing /env))
    (pen ?sentence): ?penned
    (set-writing ?thing
                 (cond (case (nothing (attr ?thing scribbles)) ?penned)
                       (else (add-func-arg (attr ?thing scribbles) ?penned)))
                 scribbles)
    (set-outcome ?SCRIBBLE /succ)))
