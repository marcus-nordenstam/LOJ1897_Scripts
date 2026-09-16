; ----------------------------------------------------------------------------
; back - the investment task: approach the firm, then seal the backing.
;
; The decision (business_think.hs `investment`) mints {@self goal {@self back <org>}};
; promotion makes the `back` task RUN. The shared role binds ?wp, the org's workplace.
;
;   OUTSIDE the firm -> route there (maintain the enter proposal).
;   AT the firm      -> seal {@self backed-by <org>} and conclude the task; the
;                       decision's maintenance then retires the goal.
; ----------------------------------------------------------------------------

(npc-task {@self back ?org}
  (tar org)
  (role ?wp {?org workplace ?wp})
  (and
    (try
      (when (not (spatial @self building ?wp)))
      (effects (maintain-proposal {@self enter ?wp})))
    (try
      (when (spatial @self building ?wp))
      (effects
        (begin-belief {@self backed-by ?org})
        (set-outcome {@self back ?org} /succ)))))
