; ----------------------------------------------------------------------------
; coerce ?victim - press a threat on the victim: reach him and SAY it aloud, a conditional he
; adopts and anyone in earshot hears - pay me by the deadline or I expose you:
; {@self threaten ?victim (consequence -{?victim pay @self /during <told> <deadline>}
; {@self expose ?victim} <deadline>)}. Said, @self holds the same threat as his commitment
; (thinks/cooldown/threat-think.mc carries it out or lets it lapse). The told time rides the
; running task, so the threat he holds names the window he spoke. The deed is recorded by
; method - blackmail when @self holds leverage, else threaten_violence.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(task {@self coerce ?victim}:?coerce
  (track-skill-level [k illicit])
  (tar [k human] @object)
  (aux ?)
  (construed-act coercion-act wrong-act)
  (facets reportable_crime)
  (and
    (try
      (role ?vhome {?victim home ?vhome}
        (when (and (not (spatial ?victim co-located @self))
                   (unknown (spatial ?victim space))))
        (effects (maintain-proposal {@self go-to ?vhome}))))
    (try
      (when (and (or (spatial ?victim co-located @self) (spatial ?victim space))
                 -{@self threaten ?victim ?}))
      (declare-utility always-pick)
      (effects
        (if (not (bb-any ?coerce told))
            (then (bb-write ?coerce told (time seconds))))
        (bind (bb-read ?coerce told) ?told)
        (bind (+ ?told (seconds (threat_grace_days) d)) ?deadline)
        (maintain-proposal
          {@self tell (utterable-msg []
                        {@self threaten ?victim
                          (consequence -{?victim pay @self /during ?told ?deadline} {@self expose ?victim} ?deadline)})
                      ?victim})))
    (try
      (when {@self tell ? ?victim /succ /caused_by ?coerce})
      (effects
        (bind (bb-read ?coerce told) ?told)
        (bind (+ ?told (seconds (threat_grace_days) d)) ?deadline)
        (begin-belief {@self threaten ?victim
                        (consequence -{?victim pay @self /during ?told ?deadline} {@self expose ?victim} ?deadline)})
        (if (or (any {?victim lover|HAVE-SEX-WITH ? /ever})
                (any {?victim threaten|commission|hired-by|kill ? /ever}))
            (then (record-crime @self ?victim blackmail coerce @u @u))
            (else (record-crime @self ?victim threaten_violence coerce @u @u)))
        (bb-clear ?coerce told)
        (set-outcome ?coerce /succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?coerce /fail)))))
