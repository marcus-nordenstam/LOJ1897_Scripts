; ----------------------------------------------------------------------------
; back ?org - the investment task: the clerk calls at his firm (the investment driver,
; business-think.mc, proposes it) and seals {@self backed-by ?org} there.
; ----------------------------------------------------------------------------

(task {@self back ?org}:?back
  (tar [k org] @object)
  (role ?wp {?org workplace ?wp}
    (and
      (try
        (when (not (spatial @self building ?wp)))
        (effects (maintain-proposal {@self go-to ?wp})))
      (try
        (when (spatial @self building ?wp))
        (effects
          (begin-belief {@self backed-by ?org})
          (set-outcome ?back /succ))))))
