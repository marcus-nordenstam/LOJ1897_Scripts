; A man with nothing to hide from the law defers to a law officer: he answers him what a law-abiding
; man answers the police (the defers-to bond's police closeness), for as long as that holds.
(think defer-to-law
  (role ?officer {?officer job [k law-officer]}
    (when (not (evading-law)))
    (effects (maintain-belief {@self defers-to ?officer}))))
