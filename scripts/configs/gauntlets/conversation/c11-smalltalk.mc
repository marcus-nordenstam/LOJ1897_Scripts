; c11 smalltalk - in each of two homes far apart, two lodgers under one roof who have both seen the
; day's weather. He counts her a friend and seeks her company with his news; she does not count him
; one. The first home is presented (the bubble forms round the lodger): in that talk she is ill at
; ease and makes her remark on the weather, and he answers it - with a remark of his own or by
; agreeing. The second is not: there is no talk, so nobody is ill at ease in one, and smalltalk,
; which only a talk has, never happens. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented lodger
  level "Theatres/demo_tech_level_v2.grs"
  startup c11-startup)

; The household is primed - everyone under the roof knows the others and that they live there - and
; everything that would take the cast out of the house, busy them elsewhere or open a talk beside the
; one judged (getting acquainted) is inhibited: what is judged is the talk.
(define-list gauntlet validate c11-validate deadline 3
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver get-acquainted-driver)

; (c11-lodgers ?home ?lodger ?cook) - the two under ?home's roof know each other and have seen the
; day's weather; he counts her a friend.
(define-func c11-lodgers (?home ?lodger ?cook)
  (conversation-household ?home)
  (spatial ?home town /env): ?town
  (conversation-see-weather ?lodger ?town)
  (conversation-see-weather ?cook ?town)
  (enter-mind ?lodger)
  (observe ?cook): ?c11-friend
  (begin-belief {@self friend ?c11-friend})
  (exit-mind))

(define-func c11-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?lodger
  (cast lodger ?lodger)
  (make-human ?home [k lower] [k female]): ?cook
  (cast cook ?cook)
  (conversation-far-home ?home): ?far-home
  (make-human ?far-home [k lower] [k male]): ?lodger-u
  (cast lodger-u ?lodger-u)
  (make-human ?far-home [k lower] [k female]): ?cook-u
  (cast cook-u ?cook-u)
  (initialize-minds)
  (c11-lodgers ?home ?lodger ?cook)
  (c11-lodgers ?far-home ?lodger-u ?cook-u))

(define-func c11-validate ()
  (cast lodger): ?lodger
  (cast cook): ?cook
  (cast lodger-u): ?lodger-u
  (cast cook-u): ?cook-u
  (expect (in-mind ?lodger (presented-lod)) "c11: the presented lodger is not presented")
  (expect (in-mind ?lodger-u (unpresented-lod)) "c11: the far lodger is presented")
  ; The presented pair: the talk, her unease in it, the smalltalk it calls for.
  (expect (> (acts ?lodger hail succ) 0) "c11: he never sought her company")
  (expect (> (+ (acts ?lodger smalltalk started) (acts ?cook smalltalk started)) 0) "c11: nobody made smalltalk")
  (expect (or (in-mind ?lodger (answered-smalltalk ?cook)) (in-mind ?cook (answered-smalltalk ?lodger)))
          "c11: no remark on the weather was answered")
  (expect (in-mind ?cook (unsubstantial (any {@self unease ?}))) "c11: she is still ill at ease")
  (expect (unsubstantial (conversation-of ?lodger)) "c11: he is still in a conversation")
  (expect (unsubstantial (conversation-of ?cook)) "c11: she is still in a conversation")
  ; The unpresented pair: no talk, so no smalltalk.
  (expect (= (+ (acts ?lodger-u hail started) (acts ?cook-u hail started)) 0) "c11: the far pair hailed - there is no hailing unpresented")
  (expect (= (+ (acts ?lodger-u smalltalk started) (acts ?cook-u smalltalk started)) 0) "c11: the far pair made smalltalk - smalltalk is only had in a talk"))
