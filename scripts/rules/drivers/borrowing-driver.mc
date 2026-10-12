; ----------------------------------------------------------------------------
; borrowing - once in a while an adult borrows from another adult whose home he knows: he
; calls on him there (tasks/seek-loan-task.mc). One creditor at a time; the roll is latched,
; and TAKE-LOAN's {@self owe ?creditor} drops that creditor from the cast.
; ----------------------------------------------------------------------------

; A home of ?creditor's that go-to can take @self to.
(define-func has-reachable-home (?creditor)
  (bind @false ?found)
  (for-each ?home (every {?creditor home ?})
    (if (go-reachable ?home.target)
        (then (bind @true ?found)
              (break))))
  ?found)

(driver borrowing
  (cooldown 1 m try-once)
  (rng-stream behaviour)
  (role @self {@self industriousness ?industriousness}
              {@self isa [k human], condition [k alive]}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (role ?creditor {?creditor isa [k human], condition [k alive]}
                    {?creditor age-band [k youth|young-adult|middle-aged|mature|elderly]}
                    {?creditor home ?}
                    (has-reachable-home ?creditor)
                    -{@self owe ?creditor}
                    (select (policy first-match))
      (when (latch-eval (chance (* 0.005 (- 1.5 ?industriousness)))))
      (declare-utility errand)
      (effects (maintain-proposal {@self seek-loan ?creditor})))))
