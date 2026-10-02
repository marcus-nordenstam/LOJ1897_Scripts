; ----------------------------------------------------------------------------
; humiliate ?victim - a public put-down. @self tells the victim the slight to his face:
; the victim AND everyone in the room hear it through the real auditory channel, so the victim's own degrade construals fire off the PERCEIVED record
; (NO fiat cross-mind write, no principals-only incident anchor). The ended {@self
; humiliate ?victim} belief IS the deed memory; the crime row records it. A dead
; victim -> abandon.
;
; INTERIM content: the SAY carries the class-tagged {@self public-humiliation ?victim}
; fact (what the victim perceives and construes). The quoted barb-content ladder (the
; actual words) is the deferred follow-up that replaces this with a (tell-to) barb fact.
; ----------------------------------------------------------------------------

(task {@self humiliate ?victim}:?humiliate
  (tar [k human] @object)
  (construed-act degrade-act wrong-act)
  (and
    (try
      (role ?vhome {?victim home ?vhome}
        (when (and (alive ?victim)
                   (not (spatial ?victim co-located @self))
                   (unknown (spatial ?victim space))))
        (effects (maintain-proposal {@self go ?vhome}))))
    (try
      (when (and (alive ?victim)
                 (or (spatial ?victim co-located @self) (spatial ?victim space))
                 -{@self tell ? ?victim /succ /caused_by ?humiliate}))
      (declare-utility errand always-pick)
      (effects (maintain-proposal
                 {@self tell (utterable-msg {@self public-humiliation ?victim}) ?victim})))
    (try
      (when {@self tell ? ?victim /succ /caused_by ?humiliate})
      (effects
        (record-crime @self ?victim public-humiliation humiliate @u @u)
        (set-outcome ?humiliate /succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?humiliate /fail)))))
