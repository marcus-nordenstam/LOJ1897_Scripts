; ----------------------------------------------------------------------------
; go-to-bed ?home - SLEEP in a bedroom of ?home. It requires that he stands inside ?home for as long
; as it runs, which enter-building achieves before go-to-bed is proposed and again if he is taken out. Inside, getting to a bedroom is enter-room-kind's,
; and he sleeps once it has brought him in; a home the search finds no bedroom in is slept in
; wherever he stands in it. Concludes with the SLEEP it proposed: a slept-off debt ends the drive
; that proposed the task, so the task states its outcome as it is withdrawn.
; ----------------------------------------------------------------------------

(define-func go-to-bed-in-bedroom (?home)
  (tolerate (spatial @self space)): ?here
  (cond (case (unsubstantial ?here) @false)
        (else (and (is-a ?here [k bedroom])
                   (spatial ?here unit ?home)))))

(task {@self go-to-bed ?home}:?go-to-bed
  (tar @excl [k unit] @object)
  (running-requirements (inside ?home))
  (cease (if {@self SLEEP /succ /caused_by ?go-to-bed}
             (then (set-outcome ?go-to-bed /succ))))
  (preemptive-or
    (try (role @self (or (and (go-to-bed-in-bedroom ?home)
                              (unsubstantial (any {@self enter-room-kind ? ? /caused_by ?go-to-bed})))
                         (substantial (any {@self enter-room-kind|find-room ? ? /fail /caused_by ?go-to-bed})))
           (effects (maintain-proposal {@self SLEEP}))))
    (try (effects (maintain-proposal {@self enter-room-kind [k bedroom] ?home})))))
