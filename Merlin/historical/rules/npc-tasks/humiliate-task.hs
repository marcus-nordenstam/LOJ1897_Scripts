; ----------------------------------------------------------------------------
; humiliate ?victim - a public put-down. @self reaches the victim and SAYs the slight
; aloud as an open BROADCAST: the victim AND everyone in the room hear it through the real
; auditory channel, so the victim's own degrade construals fire off the PERCEIVED record
; (NO fiat cross-mind write, no principals-only incident anchor). The ended {@self
; humiliate ?victim} belief IS the deed memory; the crime-ledger row records it. A dead
; victim -> abandon.
;
; INTERIM content: the SAY carries the class-tagged {@self public_humiliation ?victim}
; fact (what the victim perceives and construes). The quoted barb-content ladder (the
; actual words) is the deferred follow-up that replaces this with a (tell-to) barb fact.
; ----------------------------------------------------------------------------

(npc-task {@self humiliate ?victim}:?humiliate-rel
  (tar human)
  (construed_act degrade_act wrong_act)
  (and
    (try
      (when (and (alive ?victim)
                 (not (spatial ?victim co-located @self))
                 (spatial ?victim space): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (alive ?victim)
                 (not (spatial ?victim co-located @self))
                 (unknown (spatial ?victim space))
                 (any {?victim home ?}).target: ?vhome))
      (effects (maintain-proposal {@self go ?vhome})))
    (try
      (when (and (alive ?victim)
                 (spatial ?victim co-located @self)
                 (none {@self SAY ? /succ /caused_by ?humiliate-rel})))
      (utility errand always-pick)
      (effects (maintain-proposal
                 {@self SAY (utterable-msg {@self public_humiliation ?victim}) _})))
    (try
      (when (any {@self SAY ? /succ /caused_by ?humiliate-rel}))
      (effects
        (crime-ledger-append @self ?victim public_humiliation humiliate @u @u)
        (set-outcome ?humiliate-rel succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?humiliate-rel fail)))))
