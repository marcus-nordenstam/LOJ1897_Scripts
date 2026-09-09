; ----------------------------------------------------------------------------
; collect-applications ?wp - the recruiting officer's OFFICE post: fetch the job
; applications that have arrived in ?wp's incoming mail-stack. If @self does not know
; where that stack is, the sibling try LOCATEs it (wandering ?wp; its /fail is the
; "no stack here" record the give-up try reads); once known, the sequence walks to its
; room and lifts the applications via take-applications. Concluded once the stack is
; swept this round. This is the work-side twin of read-mail (the HOME post): the home
; task keeps letters addressed to ME, this one keeps every application, whoever it names.
; ----------------------------------------------------------------------------

(npc-task {@self collect-applications ?wp}:?ca-rel
  ; OBSERVABLE: the office round is done in the open, so anyone in the room reads it off
  ; him - which is how an applicant tells WHO the recruiting officer is, the way you tell
  ; the bartender by the bartending. The param is the WORKPLACE, a real building: a task
  ; can only be published to onlookers if its fields externalize, and an ORG cannot.
  (obs)
  (tar @excl structure)
  (and
    (sequence
      (utility obligation)

      (stage
        (role ?stk [k mail-stack] (spatial ?stk building ?wp))
        (effects
          (if (not (spatial ?stk co-located @self))
              (then (maintain-proposal {@self WALK (spatial ?stk space)})))))

      (stage
        (effects (maintain-proposal {@self take-applications ?stk})))

      (stage
        (effects (set-outcome ?ca-rel /succ))))

    (try
      (role @self -{@self locate [k mail-stack] ?wp /succ}
                 -{@self locate [k mail-stack] ?wp /fail})
      (utility obligation)
      (effects (maintain-proposal {@self locate [k mail-stack] ?wp})))

    (try
      (role @self {@self locate [k mail-stack] ?wp /fail})
      (effects (set-outcome ?ca-rel /fail)))))
