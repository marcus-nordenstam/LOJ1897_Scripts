; ----------------------------------------------------------------------------
; go-to-bed ?home - get to a bedroom of ?home and SLEEP there. Getting there is enter-room's
; with his concrete home; a home the search finds no bedroom in is slept in wherever he stands
; in it. Concludes with the SLEEP it proposed: a slept-off debt ends the drive that proposed the
; task, so the task states its outcome as it is withdrawn.
; ----------------------------------------------------------------------------

(define-func go-to-bed-in-bedroom (?home)
  (tolerate (spatial @self space)): ?here
  (cond (case (unsubstantial ?here) @false)
        (else (and (is-a ?here [k bedroom])
                   (spatial ?here unit ?home)))))

(task {@self go-to-bed ?home}:?go-to-bed
  (tar @excl [k unit] @object)
  (cease (if {@self SLEEP /succ /caused_by ?go-to-bed}
             (then (set-outcome ?go-to-bed /succ))))
  (preemptive-or
    (try (role @self (or (go-to-bed-in-bedroom ?home)
                         (and {@self enter-room ?home [k bedroom] /fail /caused_by ?go-to-bed}
                              (spatial @self unit ?home)))
           (effects (maintain-proposal {@self SLEEP}))))
    (try (role @self {@self enter-room ?home [k bedroom] /fail /caused_by ?go-to-bed}
           (effects (maintain-proposal {@self enter ?home}))))
    (try (when @true)
         (effects (maintain-proposal {@self enter-room ?home [k bedroom]})))))
