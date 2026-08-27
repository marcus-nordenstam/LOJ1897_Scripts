; ----------------------------------------------------------------------------
; attend (task lane) - occasion attendance is a TASK, not an action: attending
; changes nothing in the environment by itself. The physical work routes through
; the SHARED actions - enter (relocation), dwell (staying through the window),
; say_to (the wedding vow is a speech act). Every rung reads the occasion
; straight off its own {@self attend ?occ} goal pattern - nothing is re-derived.
;
;   attend_go     : in the window, not at the venue -> propose enter.
;   attend_stay   : in the window, at the venue -> propose dwell. The stay IS
;                   the attendance: co-presence at the venue is the observable
;                   every other attendee - and the detective trail - reads.
;   attend_vow    : wedding principal at the church, unmarried -> propose the
;                   vow: say_to the betrothed "you are my spouse". The party
;                   HEARS and adopts; no fiat cross-mind writes.
;   vow_realized  : the vow was SPOKEN ({@self SAY ...} memory) -> the speaker's
;                   OWN marriage beliefs (end fiancee, begin spouse) + the
;                   director-channel kin residue (formalize-marriage: rivalry
;                   settle, in-laws, family - the propagate-death class).
;   spouse_reciprocate : anyone who LEARNS {?p spouse @self} while betrothed to
;                   ?p marries back in their own mind - the bride at the altar
;                   (she heard the vow), or later by gossip.
;   attend_host_review : the host, late in his own occasion, closes his
;                   {@self invite <guest>} records. Who came he has SEEN (perception
;                   covers attendance); a no-show grievance construal off the
;                   un-seen invitees is future work (docs/future_work.md).
;
; SEPARATION OF CONCERNS: (when ...) gates TIMING - the {?occ hours ?start ?end}
; capture feeds (attend-in-window ?start ?end), so the day's work / rest / leisure
; lanes own the rest of the day. (utility ...) decides DESIRABILITY - MAX for a
; principal, warmth-scaled for a guest, 0 for the bedridden.
; ----------------------------------------------------------------------------

; Attendance timing + desirability, folded out of the retired C++ attend-* ops into
; .hs over the general shift-window macros (time_macros.hs) + the occasion's own
; {?occ hours <start> <end>} belief. All content-free: prep-lead / utility tiers
; are authored HERE, the window arithmetic is the same in-work-hours work shifts use.
(define-macro attend-prep-lead     () 3)       ; hours before start an attendee sets out
(define-macro attend-host-utility  () 10000)   ; a principal always attends his own occasion
(define-macro attend-crasher-utility () 5000)  ; a kill-driven crasher: above work, below host
(define-macro attend-guest-base    () 85)      ; beats the work lane (80) for the willing guest

; In the occasion's window once the prep-lead has opened (start - lead .. end).
(define-macro attend-in-window (?start ?end)
  (in-work-hours (- ?start (attend-prep-lead)) ?end))

; Minutes from now until the occasion's end hour (wraps to tomorrow if already past).
(define-macro attend-minutes-left (?end)
  (minutes-until-shift-end ?end))

; A guest's base willingness scaled by warmth toward the host: hostile 0.6x .. warm 1.4x.
(define-macro attend-guest-scaled (?occ)
  (* (attend-guest-base)
     (+ 1.0 (* 0.2 (stance-band (any {?occ host ?}).target warmth)))))

; Attendance desirability: 0 bedridden, MAX for the host, a floor for a kill-driven
; crasher, else the warmth-scaled guest base.
(define-macro attend-utility (?occ)
  (if (any {@self physical_mobility [k bedridden]}) (then 0)
    (else (if (any {@self organize ?occ}) (then (attend-host-utility))
      (else (if (any {@self goal {@self kill ?}})
          (then (max (attend-crasher-utility) (attend-guest-scaled ?occ)))
        (else (attend-guest-scaled ?occ))))))))

(npc-think attend_go
  (goal {@self attend ?occ})
  (when (and (any {?occ venue ?}).target: ?venue
             (any {?occ hours ?start ?end})
             (attend-in-window ?start ?end)
             (not (spatial @self building ?venue))))
  (utility (* 10 (attend-utility ?occ)))
  (effects (debug-print "TRACE-ATTENDGO venue=?venue occ=?occ")
           (maintain-proposal {@self enter ?venue})))

(npc-think attend_stay
  (goal {@self attend ?occ})
  (when (and (any {?occ venue ?}).target: ?venue
             (any {?occ hours ?start ?end})
             (attend-in-window ?start ?end)
             (spatial @self building ?venue)))
  (utility (* 10 (attend-utility ?occ)))
  (effects
    (debug-print "ATTEND_STAY @self occ=?occ venue=?venue")
    (maintain-proposal {@self DWELL ?venue (+ (now-hour) 1)})))

; The marriage is made at the church by whoever shows up: the VOW is a say_to
; (speech is the one physical act here). The goal's [k wedding]:?occ kind-cast
; binds AND narrows in one - only a wedding occasion reaches the (when). The
; SAY-memory dedup stops a re-vow; the second principal fails not-married once
; reciprocation lands, and the dedup covers the same-window gap before it.
(npc-think attend_vow
  (goal {@self attend [k wedding]:?occ})
  (role @self {@self fiancee ?betrothed})
  (when (and (any {@self organize ?occ})
             (not (is-married @self))
             (none {@self SAY (msg {@self spouse ?betrothed}) ?betrothed})
             (any {?occ venue ?}).target: ?venue
             (any {?occ hours ?start ?end})
             (attend-in-window ?start ?end)
             (spatial @self building ?venue)))
  (utility (* 10 (+ (attend-utility ?occ) 10)))
  (effects (maintain-proposal {@self SAY (utterable-msg {@self spouse ?betrothed}) ?betrothed})))

; The vow was SPOKEN. Saying it IS believing it - the say channel mints the
; spoken {@self spouse ?betrothed} in the speaker's own mind and in every
; hearer's (no duplicate mint here). What the vow does NOT say still closes:
; the betrothal ends, and the director-channel kin residue runs (rivalry
; settle + in-laws + family - the propagate-death class).
(npc-think vow_realized
  (role ?betrothed {@self fiancee ?betrothed}
                   {@self spouse ?betrothed})
  (effects
    (end-belief {@self fiancee ?betrothed})
    (formalize-marriage ?betrothed)))

; Reciprocal marriage: learning {?p spouse @self} while betrothed to ?p marries
; @self back in their own mind - the bride hears the vow at the altar; an absent
; bride learns by gossip and marries then. (The heard fact's subject is ?p, so
; her OWN {@self spouse ?p} is an inference of hers, not a copy of the say.)
(npc-think spouse_reciprocate
  (role @self (not {@self spouse ?}))
  (role ?p {@self fiancee ?p}
           {?p spouse @self})
  (effects
    (end-belief {@self fiancee ?p})
    (begin-belief {@self spouse ?p})))

(npc-think attend_host_review
  (goal {@self attend ?occ})
  (when (and (any {@self organize ?occ})
             (any {?occ venue ?}).target: ?venue
             (spatial @self building ?venue)
             (any {?occ hours ?start ?end})
             (attend-in-window ?start ?end)
             (<= (attend-minutes-left ?end) 45)))
  (effects
    ; Bound-aux constraint: only THIS occasion's invite rows walk (bound =
    ; constraint, free = producer).
    (for-each ?belief-rel (every {@self invite ? ?occ})
        (end-belief ?belief-rel))))
