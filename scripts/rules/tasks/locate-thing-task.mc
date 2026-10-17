; ----------------------------------------------------------------------------
; locate-thing ?thing - come to know again where ?thing is, whose whereabouts the mind has lost. He searches
; the building he last saw it in with locate, which goes into it and wanders it; knowing its box or space
; again concludes it, and a search that shows it nowhere fails it. Preparation, as locate-person is.
; ----------------------------------------------------------------------------

(task {@self locate-thing ?thing}:?locate-thing
  (tar [k object] @object)
  (preparatory)
  (preemptive-or
    (try (role @self (or (substantial (tolerate (spatial ?thing bounds)))
                         (substantial (tolerate (spatial ?thing space))))
           (effects (set-outcome ?locate-thing /succ))))
    (try (role ?seen (spatial ?thing space /most-recent-memory)
                     -{@self locate ?thing (place-holding ?seen) /fail /caused_by ?locate-thing}
           (when (place-holding ?seen): ?place (substantial ?place))
           (effects (maintain-proposal {@self locate ?thing ?place}))))
    (try (effects (set-outcome ?locate-thing /fail)))))
