; ----------------------------------------------------------------------------
; go-to-bed ?home - get to a bedroom of ?home and SLEEP there. A man who knows no bedroom
; in it locates one; a house the search finds none in is slept in wherever he stands in it.
; Concludes with the SLEEP it proposed: a slept-off debt ends the drive that proposed the task,
; so the task states its outcome as it is withdrawn.
; ----------------------------------------------------------------------------

(define-func go-to-bed-in-bedroom (?home)
  (tolerate (spatial @self space)): ?here
  (cond (case (unsubstantial ?here) @false)
        (else (and (is-a ?here [k bedroom])
                   (spatial ?here unit ?home)))))

(define-func go-to-bed-bedless (?home)
  (substantial (any {@self locate [k bedroom] ?home /fail})))

(task {@self go-to-bed ?home}:?go-to-bed
  (tar @excl [k unit] @object)
  (cease (if {@self SLEEP /succ /caused_by ?go-to-bed}
             (then (set-outcome ?go-to-bed /succ))))
  (and
    (try
      (role @self -{@self locate [k bedroom] ?home /fail}
        (when (not (spatial ?home room [k bedroom])))
        (effects (maintain-proposal {@self locate [k bedroom] ?home}))))
    (try
      (role ?room [k bedroom] (spatial ?room unit ?home)
                              (select (score (near @self ?room)) (policy roulette unknown-last))
        (when (not (go-to-bed-in-bedroom ?home)))
        (effects (maintain-proposal {@self go ?room}))))
    (try
      (when (and (go-to-bed-bedless ?home)
                 (not (spatial @self unit ?home))))
      (effects (maintain-proposal {@self go ?home})))
    (try
      (when (or (go-to-bed-in-bedroom ?home)
                (and (go-to-bed-bedless ?home)
                     (spatial @self unit ?home))))
      (effects (maintain-proposal {@self SLEEP})))))
