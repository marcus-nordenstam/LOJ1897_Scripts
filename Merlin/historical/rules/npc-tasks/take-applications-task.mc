; ----------------------------------------------------------------------------
; take-applications ?stack - sort ?stack's docs via the GENERIC stack-browse: browse
; surfaces each doc into hand marked pending; this consumer KEEPS every application and
; marks the rest handled (browse re-files them at the bottom). Concludes when the browse
; round concludes. The office twin of take-my-letters.
; ----------------------------------------------------------------------------

(npc-task {@self take-applications ?stack}:?take-apps-rel
  (tar @excl stack)
  (and
    (try
      (role @self -{@self stack-browse ?stack /succ /caused_by ?take-apps-rel})
      (utility obligation)
      (effects (maintain-proposal {@self stack-browse ?stack})))
    (try
      (role ?doc [k application] (spatial ?doc held-by @self)
            (= (bb-read ?doc browse-status) pending)
            (= (bb-read ?stack browse-inflight) ?doc))
      (effects (bb-write ?doc browse-status kept)))
    (try
      (role ?doc [k document] (spatial ?doc held-by @self)
            (not (is-a ?doc [k application]))
            (= (bb-read ?doc browse-status) pending)
            (= (bb-read ?stack browse-inflight) ?doc))
      (effects (bb-write ?doc browse-status handled)))
    (try
      (role @self {@self stack-browse ?stack /succ /caused_by ?take-apps-rel})
      (effects (set-outcome ?take-apps-rel /succ)))))
