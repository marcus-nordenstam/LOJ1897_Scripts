; c11 smalltalk - two lodgers under one roof who have both seen the day's weather. He counts her a
; friend and seeks her company with his news; she does not count him one, so in that talk she is
; ill at ease and makes her remark on the weather, and he answers it - with a remark of his own or
; by agreeing. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c11-startup)

(define-list gauntlet validate c11-validate)

(define-func c11-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?lodger
  (cast lodger ?lodger)
  (make-human ?home [k lower] [k female]): ?cook
  (cast cook ?cook)
  (initialize-minds)
  (spatial ?home town /env): ?town
  (conversation-see-weather ?lodger ?town)
  (conversation-see-weather ?cook ?town)
  (enter-mind ?lodger)
  (observe ?cook): ?c11-friend
  (begin-belief {@self friend ?c11-friend})
  (exit-mind))

(define-func c11-validate ()
  (cast lodger): ?lodger
  (cast cook): ?cook
  (expect (> (acts ?lodger hail succ) 0) "c11: he never sought her company")
  (expect (> (+ (acts ?lodger smalltalk started) (acts ?cook smalltalk started)) 0) "c11: nobody made smalltalk")
  (expect (or (in-mind ?lodger (answered-smalltalk ?cook)) (in-mind ?cook (answered-smalltalk ?lodger)))
          "c11: no remark on the weather was answered")
  (expect (in-mind ?cook (unsubstantial (any {@self unease ?}))) "c11: she is still ill at ease")
  (expect (unsubstantial (conversation-of ?lodger)) "c11: he is still in a conversation")
  (expect (unsubstantial (conversation-of ?cook)) "c11: she is still in a conversation"))
