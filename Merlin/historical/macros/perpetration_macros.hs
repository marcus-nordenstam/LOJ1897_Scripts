; ----------------------------------------------------------------------------
; perpetration_macros.hs - the EVENT-IZED perpetration terminal dispatch + terminal
; bodies, composed from atomic ops (the Phase 3(c) terminal decomposition).
;
; attempt_nonlethal.hs picks ONE standing goal whose terminal is event-ized (via
; (select-joint (over-goals ...) (table perpetration_terminals) ...)); this turns
; that winner into its act. Each terminal body is a .hs sequence of general atomic
; ops with the ontological labels/kinds as .hs literals - no term hardcoded in C++.
;
; Growing this as terminals move over: add the terminal's macro + a dispatch arm +
; a perpetration_terminals row + remove the goal's C++ skip in perpetration.cc.
; ----------------------------------------------------------------------------

; pay_off terminal (bribe goal): the mint-only shape - the band-5 act anchor
; {@self offer_bribe <victim>}, the driving pressure discharged (acting on the
; grievance releases it, so it does not re-deliberate the bribe monthly), the goal
; ended, and the crime-ledger row (task offer_bribe, goal bribe). No yields, no
; instrument, no cross-mind effect - a bribe is a private cash transfer.
(define-macro terminal-pay-off (?victim ?goal)
  (do
    (begin-belief {@self offer_bribe ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self bribe})
    (crime-ledger-append @self ?victim offer_bribe bribe @fail @fail)))

; harm_non_lethal terminal (hurt goal): the mint-only shape PLUS a non-lethal wound.
; The band-5 act anchor {@self beating <victim>} (beating is the hurt method), a
; bruise on the victim's torso (the eyewitnessable injury), the pressure discharged,
; the goal ended, the crime-ledger row (task beating, goal hurt). Bare-handed, so no
; instrument / stain. A hurt goal is a reactive-kill DISPLACED onto a weaker innocent
; (resolve-deliberation), so the driving pressure is the original grievance.
(define-macro terminal-harm-non-lethal (?victim ?goal)
  (do
    (begin-belief {@self beating ?victim})
    (yield-evidence @self ?victim torso bruise)
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self hurt})
    (crime-ledger-append @self ?victim beating hurt @fail @fail)))

; plant_evidence terminal (frame goal): mint-only PLUS the fabricated evidence
; planted ON the framed (innocent) party. The act anchor {@self plant_evidence
; <framed>}, a blood_stain on their torso (the planted proof survivors / authorities
; later act on), the pressure discharged, the goal ended, the crime-ledger row (task
; plant_evidence, goal frame).
(define-macro terminal-plant-evidence (?victim ?goal)
  (do
    (begin-belief {@self plant_evidence ?victim})
    (yield-evidence @self ?victim torso blood_stain)
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self frame})
    (crime-ledger-append @self ?victim plant_evidence frame @fail @fail)))

; silence_coerce terminal (coerce goal): the threat is EXECUTED. The act anchor {@self
; <method> <victim>} (the method is the leaf recorded), the pressure discharged, the
; goal ended, the ACTOR-side standing {@self extort <victim>} anchor established (the
; existing coercion refresh press-coercion re-presses + composes the demand note off
; it), the TARGET-side threat delivered (deliver-coercion-threat mints the victim's
; threat record + {actor extort @self} + exposure_risk pressure), and the ledger row.
; TWO methods share this terminal: blackmail needs LEVERAGE (a known liaison / a
; blackmailable act) - threaten_violence needs none, so a material-less coercer threatens.
; DEFERRED: the jilted-lover demand clause on the actor-side extort /aux (press-coercion
; composes its own demand note, so the terminal need not).
(define-macro coerce-blackmail (?victim ?goal)
  (do
    (begin-belief {@self blackmail ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self coerce})
    (if (not (believes {@self extort ?victim})) (begin-belief {@self extort ?victim}))
    (deliver-coercion-threat ?victim blackmail)
    (crime-ledger-append @self ?victim blackmail coerce @fail @fail)))

(define-macro coerce-threaten (?victim ?goal)
  (do
    (begin-belief {@self threaten_violence ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self coerce})
    (if (not (believes {@self extort ?victim})) (begin-belief {@self extort ?victim}))
    (deliver-coercion-threat ?victim threaten_violence)
    (crime-ledger-append @self ?victim threaten_violence coerce @fail @fail)))

(define-macro terminal-silence-coerce (?victim ?goal)
  (if (holds-coercion-material ?victim)
      (if (chance 0.42) (coerce-blackmail ?victim ?goal) (coerce-threaten ?victim ?goal))
      (coerce-threaten ?victim ?goal)))

; publish_secret terminal (expose goal): the secret MOVES from private to reputed. Gated
; on @self knowing a non-spousal liaison of the victim (nothing to denounce otherwise -
; no act, the goal stays standing). The act anchor {@self <method> <victim>}, the pressure
; discharged, the goal ended, any standing extort anchor ended (a published secret is
; spent leverage), the gossip cascade launched (publish-secret-about seeds the victim's
; own circle; the scandal-gossip amplifies village-wide), and the ledger row. TWO methods:
; anonymous_letter needs literacy (can-write); confront_publicly does not. DEFERRED (fold
; in later): the quoted {victim lover partner} speech content on the confront TELL, the
; anonymous letter physically posted to an authority (spouse / father), and the victim
; learning they were exposed - the essential publication (gossip + ledger) is here.
(define-macro expose-confront (?victim ?goal)
  (do
    (begin-belief {@self confront_publicly ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self expose})
    (if (believes {@self extort ?victim}) (end-belief @self extort ?victim))
    (publish-secret-about @self ?victim)
    (crime-ledger-append @self ?victim confront_publicly expose @fail @fail)))

(define-macro expose-anon (?victim ?goal)
  (do
    (begin-belief {@self anonymous_letter ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self expose})
    (if (believes {@self extort ?victim}) (end-belief @self extort ?victim))
    (publish-secret-about @self ?victim)
    (crime-ledger-append @self ?victim anonymous_letter expose @fail @fail)))

(define-macro terminal-publish-secret (?victim ?goal)
  (do
    (bind (known-nonspousal-liaison ?victim) ?partner)
    (if (is-entity ?partner)
        (if (and (can-write @self) (chance 0.4))
            (expose-anon ?victim ?goal)
            (expose-confront ?victim ?goal)))))

; Dispatch the select-joint winner (?terminal from the perpetration_terminals row)
; to its terminal body. ONE arm per event-ized terminal; the C++ generative loop
; still owns every terminal not listed here (and skips this goal, so no double-fire).
(define-macro resolve-perpetration-terminal (?terminal ?victim ?action ?goal)
  (if (= ?terminal pay_off)         (terminal-pay-off ?victim ?goal)
  (if (= ?terminal harm_non_lethal) (terminal-harm-non-lethal ?victim ?goal)
  (if (= ?terminal plant_evidence)  (terminal-plant-evidence ?victim ?goal)
  (if (= ?terminal silence_coerce)  (terminal-silence-coerce ?victim ?goal)
  (if (= ?terminal publish_secret)  (terminal-publish-secret ?victim ?goal)))))))
