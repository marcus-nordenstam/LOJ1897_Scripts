; ----------------------------------------------------------------------------
; inquire ?partner ?qs - the INQUIRY dialogue task: @self asks ?partner the question ?qs because he
; needs the fact it searches, and waits for the reply. Asked about what ?partner just said in their
; talk, the question answers that line (prompting-line), as a reply does. It succeeds when ?partner has replied to it
; - the fact, or "I don't know", which the hearing adopts as ?partner not knowing it
; (funcs/speech.mc). Proposed by the driver that needs the fact, once @self is talking with
; ?partner (ask-wonder, drivers/ask-wonder-driver.mc).
; ----------------------------------------------------------------------------

(task {@self inquire ?partner ?qs}:?inquire
  (category social (scope (talk-between ?partner)))
  (hosts reply enter-conversation)
  (tar @excl [k human] @object)
  (aux ?)
  (and
    (try
      (belief {@self tell ?qs ?partner /succ /caused_by ?inquire}:?tell
              {@self SAY ? ?partner /succ /caused_by ?tell}:?SAY
        (when (replied ?partner ?SAY))
        (effects (set-outcome ?inquire /succ))))
    (try
      (role ?partner {?partner SAY ? @self /past}:?line
                     (eq ?line (prompting-line ?partner ?qs))
                     -{@self tell ?qs ?partner /succ /caused_by ?inquire}
        (effects (maintain-proposal {@self tell ?qs ?partner} /caused_by ?line /quit-trying-on-fail))))
    (try
      (when (and (none {@self tell ?qs ?partner /succ /caused_by ?inquire})
                 (unsubstantial (prompting-line ?partner ?qs))))
      (effects (maintain-proposal {@self tell ?qs ?partner} /quit-trying-on-fail)))))
