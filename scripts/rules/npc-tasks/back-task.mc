; ----------------------------------------------------------------------------
; back - the investment task: approach the firm, then seal the backing.
;
; The decision (business_think.mc `investment`) mints {@self goal {@self back <org>}};
; promotion makes the `back` task RUN. The shared role binds ?wp, the org's workplace.
;
;   OUTSIDE the firm -> route there (maintain the go proposal).
;   AT the firm      -> seal {@self backed-by <org>} and conclude the task; the
;                       decision's maintenance then retires the goal.
; ----------------------------------------------------------------------------

(npc-task {@self back ?org}
  (tar [k org] @object)
  (role ?wp {?org workplace ?wp}
    (and
      (try
        (when (not (spatial @self building ?wp)))
        (effects (maintain-proposal {@self go ?wp})))
      (try
        (when (spatial @self building ?wp))
        (effects
          (begin-belief {@self backed-by ?org})
          (set-outcome {@self back ?org} /succ))))))
