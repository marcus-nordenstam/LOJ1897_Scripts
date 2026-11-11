; c13 crowd getting acquainted - in each of two homes far apart, eighteen under one roof who know one
; another only by name, every one of them wanting to get acquainted. The first home is presented (the
; bubble forms round its first man): each would hail the one most worth his while, many of them the
; same one, in the same minute. One man's hail stands on another at a time and the rest wait their
; turn (sync, tasks/hail-task.mc), so nobody is hailed by a crowd (audit-hailed-by-many) and no
; answer rule is cast once per caller past what a crowd can hold; and the hails are answered. The
; second is not: there is no hail, each tells the one he gets acquainted with about himself straight
; out, each at least once in the day. In both, whoever a man got acquainted with holds a fact about
; him he disclosed. Seeds state only; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242
  start 1700-01-19-06
  end 1700-01-19-22
  clock real
  fps 10
  presented crowd-first
  level "Theatres/demo_tech_level_v2.grs"
  startup c13-startup)

; The household is primed - everyone under the roof knows the others by name and that they live
; there - and everything that would take the cast out of the house or busy them elsewhere is
; inhibited: what is judged is a crowd getting acquainted.
(define-list gauntlet validate c13-validate deadline 20
  inhibit want-drink-driver feel-charitable-driver want-worship-driver want-eat-out-pub-driver
          want-eat-out-restaurant-driver want-provisions-driver gamble-urge-driver
          bored-gamble-driver plan-gathering-driver plan-impromptu-supper-driver
          want-attend-guest-driver want-read-mail-driver want-putter-driver)

(define-macro k-c13-crowd () 18)

; (c13-crowd ?home) - the crowd under ?home's roof, its first a man; returns him.
(define-func c13-crowd (?home)
  (make-human ?home [k lower] [k male]): ?c13-first
  (bind 1 ?c13-i)
  (repeat (- (k-c13-crowd) 1)
    (make-human ?home [k lower] (flip (eq (modulo ?c13-i 2) 0) [k male] [k female]))
    (bind (+ ?c13-i 1) ?c13-i))
  ?c13-first)

; (c13-seat-household ?home) - the first woman under ?home's roof is seated in its household, as the
; town's bring-up seats one: she holds its meal hours, so its supper hour is known and nobody spends
; the day asking for it.
(define-func c13-seat-household (?home)
  (for-each ?c13-w (env-entities [k human])
    (if (and (spatial ?c13-w unit ?home /env) (= (attr ?c13-w gender) [k female]))
        (then (found-household ?c13-w) (break)))))

(define-func c13-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (c13-crowd ?home): ?first
  (cast crowd-first ?first)
  (conversation-far-home ?home): ?far-home
  (c13-crowd ?far-home): ?first-u
  (cast crowd-first-u ?first-u)
  (initialize-minds)
  (conversation-household ?home)
  (conversation-household ?far-home)
  (c13-seat-household ?home)
  (c13-seat-household ?far-home))

; (c13-took-in-count ?home) - how many callers anyone under ?home's roof took in.
(define-func c13-took-in-count (?home)
  (bind 0 ?c13-took)
  (for-each ?c13-a (env-entities [k human])
    (if (spatial ?c13-a unit ?home /env)
        (then
          (for-each ?c13-b (env-entities [k human])
            (if (and (neq ?c13-a ?c13-b) (spatial ?c13-b unit ?home /env) (in-mind ?c13-a (took-in ?c13-b)))
                (then (bind (+ ?c13-took 1) ?c13-took)))))))
  ?c13-took)

; (c13-hails-started ?home) - how many hails anyone under ?home's roof began.
(define-func c13-hails-started (?home)
  (bind 0 ?c13-hails)
  (for-each ?c13-a (env-entities [k human])
    (if (spatial ?c13-a unit ?home /env)
        (then (bind (+ ?c13-hails (acts ?c13-a hail started)) ?c13-hails))))
  ?c13-hails)

; (c13-got-acquainted ?home) - how many get-acquainted anyone under ?home's roof concluded /succ.
(define-func c13-got-acquainted (?home)
  (bind 0 ?c13-got)
  (for-each ?c13-a (env-entities [k human])
    (if (spatial ?c13-a unit ?home /env)
        (then (bind (+ ?c13-got (acts ?c13-a get-acquainted succ)) ?c13-got))))
  ?c13-got)

; (c13-unacquainted-count ?home) - how many under ?home's roof concluded no get-acquainted /succ.
(define-func c13-unacquainted-count (?home)
  (bind 0 ?c13-none)
  (for-each ?c13-a (env-entities [k human])
    (if (and (spatial ?c13-a unit ?home /env) (= (acts ?c13-a get-acquainted succ) 0))
        (then (bind (+ ?c13-none 1) ?c13-none))))
  ?c13-none)

; (got-acquainted-with ?other) - in a mind: @self got acquainted with ?other.
(define-func got-acquainted-with (?other)
  (substantial (any {@self get-acquainted ?other /succ /ever})))

; (holds-disclosure-of ?other) - in a mind: @self holds a self-disclosable fact of ?other's.
(define-func holds-disclosure-of (?other)
  (substantial (any {?other (facet-labels self-disclosable) ?})))

; (c13-untold-count ?home) - how many under ?home's roof got acquainted with one who holds no fact
; about him.
(define-func c13-untold-count (?home)
  (bind 0 ?c13-untold)
  (for-each ?c13-a (env-entities [k human])
    (if (spatial ?c13-a unit ?home /env)
        (then
          (for-each ?c13-b (env-entities [k human])
            (if (and (neq ?c13-a ?c13-b) (spatial ?c13-b unit ?home /env)
                     (in-mind ?c13-a (got-acquainted-with ?c13-b))
                     (not (in-mind ?c13-b (holds-disclosure-of ?c13-a))))
                (then (bind (+ ?c13-untold 1) ?c13-untold)))))))
  ?c13-untold)

(define-func c13-validate ()
  (cast crowd-first): ?first
  (cast crowd-first-u): ?first-u
  (conversation-first-home): ?home
  (conversation-far-home ?home): ?far-home
  (expect (in-mind ?first (presented-lod)) "c13: the presented crowd's first man is not presented")
  (expect (in-mind ?first-u (unpresented-lod)) "c13: the far crowd's first man is presented")
  ; The presented crowd: the hails, taken in one at a time.
  (expect (> (c13-hails-started ?home) (k-c13-crowd)) "c13: fewer hails were begun than the crowd is many - no crowd got acquainted")
  (expect (> (c13-took-in-count ?home) (/ (k-c13-crowd) 2)) "c13: fewer than half the crowd's callers were taken in")
  (expect (> (c13-got-acquainted ?home) 0) "c13: nobody in the presented crowd got acquainted")
  (expect (= (c13-untold-count ?home) 0) "c13: one the presented crowd got acquainted with holds no fact about him")
  ; The unpresented crowd: no hails, every one of them acquainted with someone in the day, the same
  ; knowledge.
  (expect (= (c13-hails-started ?far-home) 0) "c13: the far crowd hailed - there is no hailing unpresented")
  (expect (= (c13-unacquainted-count ?far-home) 0) "c13: one of the far crowd got acquainted with nobody all day")
  (expect (= (c13-untold-count ?far-home) 0) "c13: one the far crowd got acquainted with holds no fact about him"))
