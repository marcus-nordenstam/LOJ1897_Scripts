; ----------------------------------------------------------------------------
; inquire ?partner ?qs - the INQUIRY dialogue task: @self asks ?partner the question ?qs because he
; needs the fact it searches, and waits for the reply. It succeeds when ?partner has replied to it
; - the fact, or "I don't know", which the hearing adopts as ?partner not knowing it
; (funcs/speech.mc). Proposed by the driver that needs the fact, once @self is talking with
; ?partner (ask-mealtimes, drivers/household-driver.mc).
; ----------------------------------------------------------------------------

(task {@self inquire ?partner ?qs}:?inquire
  (tar @excl [k human] @object)
  (aux ?)
  (and
    (try
      (role @self {@self SAY ?qs ?partner /succ /caused_by ?inquire}:?SAY
        (when (replied ?partner ?SAY))
        (effects (set-outcome ?inquire /succ))))
    (try
      (when (none {@self SAY ?qs ?partner /succ /caused_by ?inquire}))
      (effects (maintain-proposal {@self tell ?qs ?partner} /quit-trying-on-fail)))))
