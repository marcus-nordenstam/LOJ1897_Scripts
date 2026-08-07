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
;                   {@self invited} records. Who came he has SEEN (perception
;                   covers attendance); a no-show grievance construal off the
;                   un-seen invitees is future work (docs/future_work.md).
;
; SEPARATION OF CONCERNS: (when ...) gates TIMING - (attend-in-window ?occ)
; reads the occasion's own `hours` belief, so the day's work / rest / leisure
; lanes own the rest of the day. (utility ...) decides DESIRABILITY - MAX for a
; principal, warmth-scaled for a guest, 0 for the bedridden.
; ----------------------------------------------------------------------------

(npc-think attend_go
  (goal {@self attend ?occ})
  (when (and (believes {?occ venue ?venue})
             (attend-in-window ?occ)
             (not (in-building ?venue))))
  (utility (attend-utility ?occ))
  (effects (debug-print "TRACE-ATTENDGO venue=?venue occ=?occ")
           (maintain-proposal {@self enter ?venue})))

(npc-think attend_stay
  (goal {@self attend ?occ})
  (when (and (believes {?occ venue ?venue})
             (attend-in-window ?occ)
             (in-building ?venue)))
  (utility (attend-utility ?occ))
  (effects
    (debug-print "ATTEND_STAY @self occ=?occ venue=?venue")
    (maintain-proposal {@self dwell ?venue (dwell-quantum-min)})))

; The marriage is made at the church by whoever shows up: the VOW is a say_to
; (speech is the one physical act here). The goal's [k wedding]:?occ kind-cast
; binds AND narrows in one - only a wedding occasion reaches the (when). The
; SAY-memory dedup stops a re-vow; the second principal fails not-married once
; reciprocation lands, and the dedup covers the same-window gap before it.
(npc-think attend_vow
  (goal {@self attend [k wedding]:?occ})
  (role @self (believes {@self fiancee ?betrothed}))
  (when (and (believes {@self organize ?occ})
             (not (is-married @self))
             (not (believes {@self SAY (msg {@self spouse ?betrothed}) ?betrothed}))
             (believes {?occ venue ?venue})
             (attend-in-window ?occ)
             (in-building ?venue)))
  (utility (+ (attend-utility ?occ) 10))
  (effects (maintain-proposal {@self say_to (utterable-msg {@self spouse ?betrothed}) ?betrothed})))

; The vow was SPOKEN. Saying it IS believing it - the say channel mints the
; spoken {@self spouse ?betrothed} in the speaker's own mind and in every
; hearer's (no duplicate mint here). What the vow does NOT say still closes:
; the betrothal ends, and the director-channel kin residue runs (rivalry
; settle + in-laws + family - the propagate-death class).
(npc-think vow_realized
  (role ?betrothed (believes {@self fiancee ?betrothed})
                   (believes {@self spouse ?betrothed}))
  (effects
    (end-belief {@self fiancee ?betrothed})
    (formalize-marriage ?betrothed)))

; Reciprocal marriage: learning {?p spouse @self} while betrothed to ?p marries
; @self back in their own mind - the bride hears the vow at the altar; an absent
; bride learns by gossip and marries then. (The heard fact's subject is ?p, so
; her OWN {@self spouse ?p} is an inference of hers, not a copy of the say.)
(npc-think spouse_reciprocate
  (role @self (not (believes {@self spouse ?})))
  (role ?p (believes {@self fiancee ?p})
           (believes {?p spouse @self}))
  (effects
    (end-belief {@self fiancee ?p})
    (begin-belief {@self spouse ?p})))

(npc-think attend_host_review
  (goal {@self attend ?occ})
  (when (and (believes {@self organize ?occ})
             (believes {?occ venue ?venue})
             (in-building ?venue)
             (attend-in-window ?occ)
             (<= (attend-minutes-left ?occ) 45)))
  (effects
    ; Bound-aux constraint: only THIS occasion's invited rows walk (bound =
    ; constraint, free = producer).
    (for-each-belief ?belief {@self invited ?guest ?occ}
        (end-belief ?belief))))
