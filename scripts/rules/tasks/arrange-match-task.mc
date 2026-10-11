; ----------------------------------------------------------------------------
; arrange-match ?daughter ?groom - the father tells his daughter she is betrothed to the man he
; chose and that he will disinherit her unless she weds him within the grace he gives:
; {@self threaten ?daughter (consequence -{?daughter wed ?groom /during <told> <deadline>}
; {@self disinherit ?daughter} <deadline>)}; then he tells the groom. Both told, he holds the
; threat as his commitment (thinks/cooldown/threat-think.mc). The told time rides the running
; task, so the threat he holds names the window he spoke.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self arrange-match ?daughter ?groom}:?arrange-match
  (tar [k human] @object)
  (aux [k human] @object)
  (and
    (try
      (when -{@self tell ? ?daughter /succ /caused_by ?arrange-match})
      (effects
        (if (not (bb-any ?arrange-match told))
            (then (bb-write ?arrange-match told (time seconds))))
        (bind (bb-read ?arrange-match told) ?told)
        (bind (+ ?told (seconds (arranged_match_grace_days) d)) ?deadline)
        (maintain-proposal
          {@self tell (utterable-msg []
                        {@self threaten ?daughter
                          (consequence -{?daughter wed ?groom /during ?told ?deadline} {@self disinherit ?daughter} ?deadline)}
                        {?groom fiancee ?daughter})
                      ?daughter})))
    (try
      (when (and {@self tell ? ?daughter /succ /caused_by ?arrange-match}
                 -{@self tell ? ?groom /succ /caused_by ?arrange-match}))
      (effects (maintain-proposal {@self tell (utterable-msg [] {?daughter fiancee ?groom}) ?groom})))
    (try
      (when (and {@self tell ? ?daughter /succ /caused_by ?arrange-match}
                 {@self tell ? ?groom /succ /caused_by ?arrange-match}))
      (effects
        (bind (bb-read ?arrange-match told) ?told)
        (bind (+ ?told (seconds (arranged_match_grace_days) d)) ?deadline)
        (begin-belief {@self threaten ?daughter
                        (consequence -{?daughter wed ?groom /during ?told ?deadline} {@self disinherit ?daughter} ?deadline)})
        (bb-clear ?arrange-match told)
        (set-outcome ?arrange-match /succ)))))
