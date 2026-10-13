; ----------------------------------------------------------------------------
; take-applications ?stack - the office post round: the recruiting officer lifts the next
; unread application off ?stack into his hand. He does not read it here - recruit-staff reads
; the form in hand. A form already read is spent: one in his hand is destroyed before the next
; is lifted, one met on the pile is destroyed as he goes round. A man has two hands, so the
; round brings in one form; recruit-staff sends him back for the next once it is read.
; ----------------------------------------------------------------------------

(task {@self take-applications ?stack}:?take-applications
  (aspect labour)
  (tar @excl [k stack] @object)
  (and
    (try
      (role ?spent [k application] (spatial ?spent held-by @self)
                                   {@self READ ?spent /succ}
        (effects (maintain-proposal {@self DESTROY-ENTITY ?spent}))))
    (try
      (no-role [k application] (spatial ?norole held-by @self) {@self READ ?norole /succ})
      (role @self -{@self stack-browse ?stack ? /succ /caused_by ?take-applications}
        (effects
          (maintain-proposal
            {@self stack-browse ?stack
              '(if (is-a .?item [k application])
                   (then (if -{@self READ .?item /succ}
                             (then (bb-write .?stack-browse keep @true))
                             (else (maintain-proposal {@self DESTROY-ENTITY .?item})))))}))))
    (try
      (role @self {@self stack-browse ?stack ? /succ /caused_by ?take-applications}
        (effects (set-outcome ?take-applications /succ))))))
