; crime - one row per completed crime, written by (record-crime ..) at the perpetration commit.
; A row whose intent is kill is a murder: it signals the host's first-murder observer.
(chronicle crime
  (columns (perpetrator name) (victim name) (task label) (intent label)
           (anchor name) (instigator name) (gender kind))
  (kill-signal victim (when intent kill)))
