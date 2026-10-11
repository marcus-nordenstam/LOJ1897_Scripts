; ----------------------------------------------------------------------------
; want-read-mail - the daily home post: at home, sweep the home mail once a day
; (tasks/read-mail-task.mc). A shortcut driver: it prepares the round - a home whose
; mail-stack @self does not know is searched first (locate) - and the task assumes the stack.
; The bout ends when the read-mail it maintains concludes, and the cooldown's expiry re-arms
; it a day later. The recruit officer's workplace post is the staffing duty's.
; ----------------------------------------------------------------------------

(driver want-read-mail
  (cooldown 1 d try-until-succ)
  (declare-utility errand)
  (and
    (try
      (role ?home {@self home ?home}
        (role ?stk [k mail-stack] (within-place ?stk ?home) (select (policy first-match))
          (role @self (spatial @self unit ?home)
            (when (>= (days-since-last {@self read-mail ?home /succ}) 1))
            (effects (maintain-proposal {@self read-mail ?home}))))))
    (try
      (role ?home {@self home ?home}
        (no-role [k mail-stack] (within-place ?norole ?home))
        (role @self (spatial @self unit ?home)
                    -{@self locate [k mail-stack] ?home /fail}
          (effects (maintain-proposal {@self locate [k mail-stack] ?home})))))))
