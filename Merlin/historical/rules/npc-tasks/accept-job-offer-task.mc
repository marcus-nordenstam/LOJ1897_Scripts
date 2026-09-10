; ----------------------------------------------------------------------------
; accept-job-offer ?jk ?wp - the offered seeker goes to the workplace and takes the post
; up. apply-for's success sub-task, driven by the offer-letter he has read.
;
; OBSERVABLE, and that is the whole mechanism on the officer's side: a man keeping the
; hiring book reads the errand off the man standing in front of him, the way anyone reads
; a stranger's business from what he is plainly doing. No letter changes hands at the
; counter - the errand is legible, and the NAME is what @self must supply, because the
; officer has to find him in the book and a page records names.
;
; The order is the one a counter has always had: come to the right room, say who you are,
; and WAIT. There is no rung here that writes the book: the post is the officer's to give,
; so @self's part ends at standing in front of her having named himself. He learns which
; way it went from HER MOUTH - both outcome rungs read a belief she can only have put
; there by telling him - never by reading her book over her shoulder. His level he does
; read off the page, once, after: she has just written him onto it in front of him.
; ----------------------------------------------------------------------------

(npc-task {@self accept-job-offer ?jk ?wp}:?ajo-rel
  (obs)
  (tar job)
  (aux building|space)
  (and
    ; TO THE ROOM the notice named. ?wp is that place - imagined off the page until he
    ; finds it, and (go ..) owns the whole journey either way: the search while it is
    ; imagined, enter / WALK once it is a room he has seen. Nothing is toured here.
    (try
      (role @self (not (spatial @self space ?wp)))
      (utility errand)
      (effects (maintain-proposal {@self go ?wp})))

    ; ANNOUNCE YOURSELF. He is in the room with the man who keeps the book - recruit-staff
    ; is (obs), so @self knows which man that is by seeing him keep it. Speaking his own
    ; name is what turns him from a stranger into someone she can look up.
    (try
      (role ?officer [k human] {?officer recruit-staff ?}
                               (spatial ?officer co-located @self))
      (role @self {@self name ?myname})
      (utility errand (above go))
      (effects
        (utterable-msg {@i name ?myname}): ?msg
        (if ?msg
            (then (maintain-proposal {@self SAY ?msg ?officer})))))

    ; TAKEN ON. She has told him the seat is his. Only then does he read his level off the
    ; page she has just written him onto - the book in the room with them - and become the
    ; org's man. The vacancy he came on is spent: it was him.
    (try
      (role ?job {?job filled-by @self}
                 {?job org ?org})
      (role ?reg [k employee-register] (spatial ?reg co-located @self))
      (role @self (spatial @self building): ?bldg)
      (when (and (is-a ?job ?jk)
                 (table-match (attr ?reg writing) worker (name @self) level ?lvl)))
      (effects
        ; The offer is SPENT and the vacancy with it: he is the man in the seat now.
        (for-each ?orel (every {?job offered-to @self})
          (end-belief ?orel))
        (for-each ?vrel (every {? filled-by _})
          (bind ?vrel.subject ?vac)
          (if (and (is-a ?vac ?jk) {?vac org ?org})
              (then (end-belief ?vrel))))
        (employ-beliefs ?org ?bldg ?jk ?lvl ?reg)
        (set-outcome ?ajo-rel /succ)))

    ; TURNED AWAY. She has named the man who holds it - a seat of the kind he came for, at
    ; the org whose vacancy brought him. @self only ever learns that a post is another's by
    ; being told so, which is why holding that belief is the whole gate; and he cannot be
    ; the man in it, or the rung above would have concluded him first. The vacancy he came
    ; on is spent either way: it went to someone else.
    (try
      (role ?org {?org workplace ?wp})
      (role ?vac {?vac filled-by _}
                 {?vac org ?org})
      (role ?job {?job org ?org})
      ; A MAN holds it. His own vacancy belief reads {.. filled-by _} and must not pass
      ; for a refusal - nobody is not another man.
      (role ?holder [k human] {?job filled-by ?holder})
      (role @self -{@self job ?})
      (when (and (is-a ?job ?jk)
                 (!= ?holder @self)))
      (effects
        ; The offer is spent either way - it went to someone else - and so is the vacancy.
        (for-each ?orel (every {?vac offered-to @self})
          (end-belief ?orel))
        (end-belief {?vac filled-by _})
        (set-outcome ?ajo-rel /fail)))))
