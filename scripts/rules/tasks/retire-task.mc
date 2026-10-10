; ----------------------------------------------------------------------------
; retire - give notice in person, at the workplace (QUIT-WORK).
; ----------------------------------------------------------------------------

(task {@self retire}:?retire
  (and
    (try
      (role ?job {@self job ?job}
        (role ?org {?job org ?org}
          (role ?wp {?org workplace ?wp}
                    (not (spatial @self building ?wp))
            (effects (maintain-proposal {@self go-to ?wp}))))))
    (try
      (role ?job {@self job ?job}
        (role ?org {?job org ?org}
          (role ?wp {?org workplace ?wp}
                    (spatial @self building ?wp)
            (effects (maintain-proposal {@self QUIT-WORK}))))))
    (try
      (when {@self QUIT-WORK /succ /caused_by ?retire})
      (effects (set-outcome ?retire /succ)))))
