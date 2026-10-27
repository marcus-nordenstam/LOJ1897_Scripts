; ----------------------------------------------------------------------------
; flirted-at (reflex) - a flirt said to @self draws her a little toward the one who made it, unless
; she dislikes him: repeated, it grows into the fancy courtship and lovers build on. The flirt is the
; cause of the stance it moves.
; ----------------------------------------------------------------------------

(reflex {?speaker SAY (formulaic ~[/msg-class flirtation] flirt ?) @self /ever}:?SAY
  (when (and (neq ?speaker @self) (none {@self dislike|detest ?speaker})))
  (effects (nudge-stance ?speaker attraction 0.05 ?SAY)))
