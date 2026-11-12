; ----------------------------------------------------------------------------
; find-out ?fact - @self learns what he wonders, ?fact - a fact clause ({?home supper-hour ?}), or
; which one a ghost is - by whatever means he has. Asking: a man here (co-located) he takes to be
; able to tell him (could-know: the fact is about him, or he fits its author as the rulebook
; describes him, or he spoke of the ghost) and does not take not to know it
; is hailed; nobody is sought out to be asked. Once they talk he asks him (tasks/inquire-task.mc),
; the question his own next step, so nothing of his own outbids it. A man who turns the hail down
; is hailed again only once he is in no conversation (hailable), and "I don't know" rules him out;
; the next is sought; a man who turned it down only because he was busy owes him a hail of his own
; (reflexes/obligation-hail.mc). A hail that fails because he could not hear it (he slept, or had
; gone) is made again once he can. It is done when he knows it (found-out).
; Proposed by want-to-know (drivers/want-to-know-driver.mc). Like every pursuit carried on in
; talk it runs beside the conversation it asks in, which hosts it (category social).
; ----------------------------------------------------------------------------

(task {@self find-out ?fact}:?find-out
  (tar @pattern)
  (category social)
  (hosts reply enter-conversation)
  (lint-waive task-no-preparation)
  (success-cond (found-out ?fact))
  (role ?who {?who isa [k human]}
             (neq ?who @self)
             (spatial ?who co-located @self)
             (or (conversing-with ?who) (hailable ?who))
    (when (askable ?who ?fact))
    (preemptive-or
      (try
        (lod unpresented)
        (effects (maintain-proposal {@self inquire ?who (inquiry-of ?who ?fact)})))
      (try
        (lod presented)
        (when (conversing-with ?who))
        (effects (maintain-proposal {@self inquire ?who (inquiry-of ?who ?fact)})))
      (try
        (lod presented)
        (belief {@self hail ?who /fail /caused_by ?find-out}:?hail
          (when (hail-turned-down ?who ?hail))
          (effects (set-outcome ?find-out /fail))))
      (try
        (lod presented)
        (when (and (not (conversing-with ?who)) (hailable ?who)))
        (effects (maintain-proposal {@self hail ?who} /keep-trying-on-fail))))))
