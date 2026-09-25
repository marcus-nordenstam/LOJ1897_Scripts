; record-crime - the one place a crime row is spelled. <anchor> is what the act touched and
; <instigator> who commissioned it (@u for neither); the gender is the perpetrator's as it stands.
(define-func record-crime (?perp ?victim ?task ?goal ?anchor ?instigator)
  (write-chronicle crime perpetrator ?perp victim ?victim task ?task goal ?goal
                   anchor ?anchor instigator ?instigator gender (attr ?perp gender)))
