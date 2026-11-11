; give-up-turns - a man who holds a turn with no tell running and no line being said gives every
; turn up. A tell left while its SAY still runs releases nothing (speaking), so the line keeps the
; floor until it is said; this is who gives it up then, once no tell of his is left to.

(think give-up-turns
  (when (and (holds-turn ?) (none {@self SAY|tell ? ?})))
  (effects (turn-release ?)))
