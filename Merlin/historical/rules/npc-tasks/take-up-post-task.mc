; ----------------------------------------------------------------------------
; take-up-post ?jk ?wp - the offered seeker goes to the workplace ?wp and takes the
; post (apply-for's success sub-task). Keyed on the job kind + the WORKPLACE building;
; the org's articles are the doc found AT the workplace (perceived on arrival). The
; chain concludes BOTTOM-UP: TAKE_POST stamps the world signal (job.salary), the
; outcome try's conclusive signal. If the post has gone to another man the officer SAYS
; so, and hearing it is what ends the errand /fail.
; ----------------------------------------------------------------------------

(npc-task {@self take-up-post ?jk ?wp}:?tup-rel
  ; OBSERVABLE: presenting yourself for a post is done in the open. The officer reads it
  ; off the man standing in front of him - that is the applicant's half of the handshake,
  ; the way the officer's recruiting is his.
  (obs)
  (tar job)
  (aux building)
  (and
    (try
      (when (not (spatial @self building ?wp)))
      (effects (maintain-proposal {@self enter ?wp})))
    ; FIND THE MAN, not the room. You take a post from whoever keeps the book, and you know
    ; which man that is by SEEING him keep it: recruit-staff is (obs) and runs his whole
    ; shift, so passing through his room teaches {?officer recruit-staff ?}. No name needed -
    ; the same way you find the bartender in a bar you have never drunk in.
    ;
    ; SEEK: inside the workplace, nobody yet seen recruiting -> tour it. The room-walk does
    ; the perceiving, so searching and seeing are the same act.
    (try
      (role @self (spatial @self building ?wp))
      (when (and -{@self job.salary ?}
                 -{? recruit-staff ?}))
      (effects (maintain-proposal {@self wander ?wp})))

    ; APPROACH: seen him, but he is in another room -> go to him.
    (try
      (role ?officer [k human] {?officer recruit-staff ?})
      (role @self (spatial @self building ?wp))
      (when -{@self job.salary ?})
      (effects
        (if (not (spatial ?officer co-located @self))
            (then (maintain-proposal {@self WALK (spatial ?officer space)})))))

    ; PRESENT AND WAIT. There is no rung here that writes the book: the post is the
    ; officer's to give, so @self's part ends at standing in front of him where he can see
    ; what he came for. He is taken on, or he is not - and the outcome rungs below read the
    ; answer off the book, the same way anyone else would.
    ; Signed on: read the level off the book and become the org's employee. The org is
    ; the one @self already believes keeps this workplace (the notice named it); the
    ; articles live on the company registry's stack, never at the workplace.
    (try
      (role ?org {?org workplace ?wp})
      (role ?reg [k employee-register] (spatial ?reg building ?wp))
      (when (table-match (attr ?reg writing) worker @self level ?lvl))
      (effects (employ-beliefs ?org ?wp ?jk ?lvl ?reg)))
    (try
      (role @self {@self job.salary ?})
      (effects
               (set-outcome ?tup-rel /succ)))

    ; TURNED AWAY: the officer has told @self the post is taken, and @self is not the man
    ; in it. There is nothing left to stand about for. @self only ever learns that a post
    ; is filled by being told so, which is why hearing it is the whole gate.
    (try
      (role @self -{@self job.salary ?})
      (role ?org {?org workplace ?wp})
      (role ?job {?job org ?org}
                  {?job filled-by ?}
                  -{?job filled-by @self})
      (when (is-a ?job ?jk))
      (effects
               (set-outcome ?tup-rel /fail)))))
