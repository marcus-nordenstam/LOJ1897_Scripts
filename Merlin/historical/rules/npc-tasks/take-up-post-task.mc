; ----------------------------------------------------------------------------
; take-up-post ?jk ?wp - the offered seeker goes to the workplace ?wp and takes the
; post (apply-for's success sub-task). Keyed on the job kind + the WORKPLACE building;
; the org's articles are the doc found AT the workplace (perceived on arrival). The
; chain concludes BOTTOM-UP: TAKE_POST stamps the world signal (job.salary), the
; outcome try's conclusive signal.
; ----------------------------------------------------------------------------

(npc-task {@self take-up-post ?jk ?wp}:?tup-rel
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

    (try
      ; The wage book, perceived at the workplace; the task resolves it and hands it to
      ; the dumb ENROL - no org/register resolution inside the act. Signing on happens in
      ; front of the man keeping it, never behind his back.
      (role ?reg [k employee-register] (spatial ?reg building ?wp))
      (role ?officer [k human] {?officer recruit-staff ?}
                               (spatial ?officer co-located @self))
      (when (and (>= (now-hour) 9)
                 (<= (now-hour) 16)
                 -{@self job.salary ?}))
      (effects (maintain-proposal {@self ENROL ?reg ?jk})))
    ; Signed on: read the level off the book and become the org's employee. The org is
    ; the one @self already believes keeps this workplace (the notice named it); the
    ; articles live on the company registry's stack, never at the workplace.
    (try
      (role ?org {?org workplace ?wp})
      (role ?reg [k employee-register] (spatial ?reg building ?wp))
      (when (table-match (attr ?reg writing) worker @self level ?lvl))
      (effects (employ-beliefs ?org ?wp ?jk ?lvl)))
    (try
      (role @self {@self job.salary ?})
      (effects
               (set-outcome ?tup-rel /succ)))))
