; ----------------------------------------------------------------------------
; obligation-hail - a man who turns a hail down because he is busy - in another talk, or at
; something keener (decline-hail, drivers/answer-hail-driver.mc) - owes the man who hailed him a
; hail of his own once he is free (drivers/hail-obligation-driver.mc). Turned down weary of
; company, or rebuffed, he owes him nothing. Talking with him, by either man's hail, discharges it.
; ----------------------------------------------------------------------------

; (busy-refusal ?reason) - a refusal's reason says @self was busy: the act that outbid the hail, or
; the talk he was in - never weariness of company.
(define-func busy-refusal (?reason)
  (cond (case (is-clause ?reason) @true)
        (else (not (eq ?reason weary)))))

(reflex {@self turn-down ?hailer (formulaic ? refusal ?reason)}:?turn-down
  (when (and (busy-refusal ?reason)
             (none {@self obligation {@self hail ?hailer} ?hailer})))
  (effects (begin-belief {@self obligation {@self hail ?hailer} ?hailer /caused_by ?turn-down})))

(reflex {? participant @self}
  (role ?hailer {@self obligation {@self hail ?hailer} ?hailer}:?owed
    (when (conversing-with ?hailer))
    (effects (end-belief ?owed))))
