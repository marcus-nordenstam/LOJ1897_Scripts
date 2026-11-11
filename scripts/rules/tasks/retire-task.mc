; ----------------------------------------------------------------------------
; retire - give notice in person, at the workplace (QUIT-WORK), naming the firm's employee-register
; when he knows it, so his line on it is struck. Once notice is given he holds no job.
; ----------------------------------------------------------------------------

(task {@self retire}:?retire
  (and
    (try
      (role ?job {@self job ?job}
        (role ?org {?job org ?org}
          (role ?wp {?org workplace ?wp}
                    (not (within-space @self ?wp))
            (effects (maintain-proposal {@self enter-room ?wp}))))))
    (try
      (role ?job {@self job ?job}
        (role ?org {?job org ?org}
          (role ?wp {?org workplace ?wp}
                    (within-space @self ?wp)
            (role ?reg {?org employee-register ?reg}
              (effects (maintain-proposal {@self QUIT-WORK ?reg})))))))
    (try
      (role ?job {@self job ?job}
        (role ?org {?job org ?org}
                   (none {?org employee-register ?})
          (role ?wp {?org workplace ?wp}
                    (within-space @self ?wp)
            (effects (maintain-proposal {@self QUIT-WORK _}))))))
    (try
      (belief {@self QUIT-WORK ? /succ /caused_by ?retire}
        (effects
          (end-belief (every {@self job ?}))
          (set-outcome ?retire /succ))))))
