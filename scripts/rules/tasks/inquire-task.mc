; ----------------------------------------------------------------------------
; inquire ?partner ?qs - the INQUIRY dialogue task: @self asks ?partner the question ?qs because he
; needs the fact it searches, and waits for the reply. Asked about what ?partner just said in their
; talk, the question answers that line (prompting-line), as a reply does. It succeeds when ?partner has replied to it
; - the fact, or "I don't know", which the hearing adopts as ?partner not knowing it
; (funcs/speech.mc). Proposed by the driver that needs the fact, once @self is talking with
; ?partner (ask-wonder, drivers/ask-wonder-driver.mc).
; ----------------------------------------------------------------------------

(task {@self inquire ?partner ?qs}:?inquire
  (belief-timeout 15 min)
  (category social (scope (talk-between ?partner)))
  (hosts reply enter-talk)
  (tar @excl [k human] @object)
  (aux ?)
  (and
    (try
      (belief {@self SAY ? ?partner /succ /caused_by ?inquire}:?SAY
        (when (replied ?partner ?SAY))
        (effects (set-outcome ?inquire /succ))))
    (try
      (when (and (none {@self SAY ? ?partner /succ /caused_by ?inquire})
                 (substantial (prompting-line ?partner ?qs))))
      (effects
        (bind (prompting-line ?partner ?qs) ?line)
        (bb-write-rec @self bbk-reply-to ?qs (/line ?line))
        (maintain-intent {@self intent {@self SAY ?qs ?partner}})))
    (try
      (when (and (none {@self SAY ? ?partner /succ /caused_by ?inquire})
                 (unsubstantial (prompting-line ?partner ?qs))))
      (effects (maintain-intent {@self intent {@self SAY ?qs ?partner}})))))
