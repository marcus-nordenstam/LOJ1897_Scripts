; ----------------------------------------------------------------------------
; dismiss ?w - the boss lets a worker go in person, at the workplace (SACK), where the sacked
; man's grudge toward him is seeded.
; ----------------------------------------------------------------------------

(task {@self dismiss ?w}:?dismiss
  (tar [k human] @object)
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
            (role ?reg {?org employee-register ?reg}
              (effects (maintain-proposal {@self SACK ?w ?reg})))))))
    (try
      (when {@self SACK ?w ? /succ /caused_by ?dismiss})
      (effects (set-outcome ?dismiss /succ)))))
