; ----------------------------------------------------------------------------
; voice.mc - the register a speaker takes toward the one she speaks to and the one she speaks
; about, reasoned in her own mind as she says the line and carried on it as its [/reg-des ..]
; rider. How she sounds whatever she means - her personality, her mood - is not reasoned and is
; not here: the language layer reads that off her own self.
; ----------------------------------------------------------------------------

(define-macro class-deference () 1)
(define-macro owed-deference () 1)
(define-macro closeness-familiarity () 2)
(define-macro formal-deference () 1)
(define-macro deferential-deference () 2)
(define-macro mild-warmth-band () 1.0)
(define-macro strong-warmth-band () 2.0)

; (voice-line ?msg ?audience) - ?msg as @self says it to ?audience. A broadcast takes no register
; toward a listener; a line to a conversation is said as formally as its most deferential party
; asks, and as nobody's friend.
(define-func voice-line (?msg ?audience)
  (bind (line-subject ?msg) ?subject)
  (cond
    (case (not (is-object ?audience))
      (with-register ?msg (affect-toward ?subject)))
    (case (is-a ?audience [k conversation])
      (with-register ?msg
        (formality-of (conversation-deference ?audience))
        (affect-toward ?subject)))
    (else
      (with-register ?msg
        (dread-tone ?audience)
        (warmth-toward ?audience)
        (formality-of (deference-toward ?audience))
        (bond-to ?audience)
        (affect-toward ?subject)))))

; (line-subject ?msg) - the first one besides @self a sentence of ?msg is about, or @nothing.
(define-func line-subject (?msg)
  (bind @nothing ?subject)
  (for-each ?sentence (msg-content ?msg)
    (if (is-relation ?sentence)
        (then
          (bind ?sentence.subject ?about)
          (if (and (is-object ?about) (neq ?about @self))
              (then (bind ?about ?subject) (break))))))
  ?subject)

(define-func class-rank (?person)
  (cond
    (case {?person class-situation [k upper]} 2)
    (case {?person class-situation [k middle]} 1)
    (case {?person class-situation [k lower]} 0)
    (else -1)))

; (deference-toward ?person) - how far @self defers to ?person: the classes he stands above her,
; and her debt to him, less the familiarity a friend or a closer bond allows.
(define-func deference-toward (?person)
  (bind (class-rank @self) ?own)
  (bind (class-rank ?person) ?theirs)
  (+ (flip (and (>= ?own 0) (>= ?theirs 0)) (* (class-deference) (- ?theirs ?own)) 0)
     (+ (flip (any {@self owe ?person}) (owed-deference) 0)
        (flip (closeness ?person friend+) (- 0 (closeness-familiarity)) 0))))

(define-func conversation-deference (?talk)
  (bind @nothing ?most)
  (for-each ?party (parties-of ?talk)
    (if (neq ?party @self)
        (then
          (bind (deference-toward ?party) ?deference)
          (bind (flip (unsubstantial ?most) ?deference (max ?most ?deference)) ?most))))
  (flip (unsubstantial ?most) 0 ?most))

(define-func formality-of (?deference)
  (cond
    (case (>= ?deference (deferential-deference)) deferential)
    (case (>= ?deference (formal-deference)) formal)
    (case (<= ?deference (- 0 (deferential-deference))) intimate)
    (case (<= ?deference (- 0 (formal-deference))) familiar)
    (else @nothing)))

(define-func warmth-toward (?person)
  (bind (stance-band ?person warmth) ?band)
  (cond
    (case (any {@self love ?person}) fond)
    (case (>= ?band (strong-warmth-band)) fond)
    (case (>= ?band (mild-warmth-band)) warm)
    (case (<= ?band (- 0.0 (strong-warmth-band))) hostile)
    (case (<= ?band (- 0.0 (mild-warmth-band))) cool)
    (case (any {@self emotion [k anger] ?person}) cool)
    (else @nothing)))

; (dreads ?person) - the durable dread of him, or the fright of the moment.
(define-func dreads (?person)
  (or (> (stance-band ?person dread) 0.0) (substantial (any {@self emotion [k fear] ?person}))))

(define-func dread-tone (?person)
  (flip (dreads ?person) anxious_fear @nothing))

(define-func bond-to (?person)
  (cond
    (case (closeness ?person close_friend+) close)
    (case (closeness ?person friend+) friend)
    (else @nothing)))

(define-func affect-toward (?subject)
  (cond
    (case (unsubstantial ?subject) @nothing)
    (case (any {@self love ?subject}) loves)
    (case (> (stance-band ?subject warmth) 0.0) likes)
    (case (< (stance-band ?subject warmth) 0.0) dislikes)
    (case (dreads ?subject) fears)
    (case (any {@self emotion [k anger] ?subject}) resents)
    (else @nothing)))
