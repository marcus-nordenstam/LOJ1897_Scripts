; ----------------------------------------------------------------------------
; A document's ENVELOPE: what is written on it about itself - the name it is signed with (its
; /author, an alias on a forged letter), whom it is addressed to (its /addressee) and the date it was
; written (its /dated, which WRITE stamps). A letter is said by these (things.mon: its anchors), so
; reader and writer both hold them, learnt the one way: the reader reading it (READ), the writer
; writing it (thinks/know-own-writing-think.mc).
; ----------------------------------------------------------------------------

; (pen ?sentence) - ?sentence as @self's hand puts it on paper or on a thing: dated today and in his
; handwriting - the hand's kind and the aspects it is written with. WRITE and SCRIBBLE pen alike.
(define-func pen (?sentence)
  (set-msg-rider (set-msg-rider ?sentence dated (time date)) handwriting
    (attr @self handwriting)
    (attr @self hand-slant) (attr @self hand-weight)
    (attr @self hand-letter-spacing) (attr @self hand-line-spacing)
    (attr @self hand-regularity)))

; (learn-envelope ?doc ?msg ?date) - @self takes ?doc to be signed, addressed and dated as ?msg's
; riders say, and written on ?date. An unsigned or unaddressed document teaches neither.
(define-func learn-envelope (?doc ?msg ?date)
  (bind (msg-rider ?msg author) ?signed)
  (if (substantial ?signed)
      (then
        (o [k human] {@o name ?signed}): ?author
        (begin-belief {?doc author ?author})))
  (bind (msg-rider ?msg addressee) ?to)
  (if (substantial ?to)
      (then (begin-belief {?doc addressee ?to})))
  (if (substantial ?date)
      (then (begin-belief {?doc write-date ?date}))))
