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
    (begin-ended-belief {@self offer_bribe ?victim})
    (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
    (end-goal {@self bribe})
    (crime-ledger-append @self ?victim offer_bribe bribe @fail @fail)))

; harm_non_lethal terminal (hurt goal): the mint-only shape PLUS a non-lethal wound.
; The band-5 act anchor {@self beat <victim>} (beat is the hurt method), a
; bruise on the victim's torso (the eyewitnessable injury), the pressure discharged,
; the goal ended, the crime-ledger row (task beat, goal hurt). Bare-handed, so no
; instrument / stain. A hurt goal is a reactive-kill DISPLACED onto a weaker innocent
; (resolve-deliberation), so the driving pressure is the original grievance.
(define-macro terminal-harm-non-lethal (?victim ?goal)
  (do
    (begin-ended-belief {@self beat ?victim})
    (yield-evidence @self ?victim torso bruise)
    (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
    (end-goal {@self hurt})
    (crime-ledger-append @self ?victim beat hurt @fail @fail)))

; plant_evidence terminal (frame goal): mint-only PLUS the fabricated evidence
; planted ON the framed (innocent) party. The act anchor {@self plant_evidence
; <framed>}, a blood_stain on their torso (the planted proof survivors / authorities
; later act on), the pressure discharged, the goal ended, the crime-ledger row (task
; plant_evidence, goal frame).
(define-macro terminal-plant-evidence (?victim ?goal)
  (do
    (begin-ended-belief {@self plant_evidence ?victim})
    (yield-evidence @self ?victim torso blood_stain)
    (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
    (end-goal {@self frame})
    (crime-ledger-append @self ?victim plant_evidence frame @fail @fail)))

; silence_coerce terminal (coerce goal): the threat is EXECUTED. The act anchor {@self
; <method> <victim>} (the method is the leaf recorded), the pressure discharged, the
; goal ended, the ACTOR-side standing {@self extort <victim>} anchor established (the
; existing coercion refresh press-coercion re-presses + composes the demand note off
; it), and the TARGET-side threat LANDED in the victim's mind (the {@self extort
; <victim>} anchor + the punctual threat act-record - his own coercion_pressure event
; then mints the exposure_risk pressure off the anchor), and the ledger row.
; TWO methods share this terminal: blackmail needs LEVERAGE (a known liaison / a
; blackmailable act) - threaten_violence needs none, so a material-less coercer threatens.
; DEFERRED: the jilted-lover demand clause on the actor-side extort /aux (press-coercion
; composes its own demand note, so the terminal need not).
(define-macro coerce-blackmail (?victim ?goal)
  (do
    (begin-ended-belief {@self blackmail ?victim})
    (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
    (end-goal {@self coerce})
    (if (none {@self extort ?victim}) (then (begin-belief {@self extort ?victim})))
    ; Land the threat in the victim's mind (his act, perceived): the standing extort
    ; anchor + the punctual threat act-record. The victim's OWN coercion_pressure event
    ; mints the exposure_risk pressure off that anchor - no C++ generator.
    (begin-belief ?victim {@self extort ?victim})
    (begin-ended-belief ?victim {@self blackmail ?victim})
    (crime-ledger-append @self ?victim blackmail coerce @fail @fail)))

(define-macro coerce-threaten (?victim ?goal)
  (do
    (begin-ended-belief {@self threaten_violence ?victim})
    (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
    (end-goal {@self coerce})
    (if (none {@self extort ?victim}) (then (begin-belief {@self extort ?victim})))
    (begin-belief ?victim {@self extort ?victim})
    (begin-ended-belief ?victim {@self threaten_violence ?victim})
    (crime-ledger-append @self ?victim threaten_violence coerce @fail @fail)))

(define-macro terminal-silence-coerce (?victim ?goal)
  (if (holds-coercion-material ?victim)
      (then (if (chance 0.42) (then (coerce-blackmail ?victim ?goal)) (else (coerce-threaten ?victim ?goal))))
      (else (coerce-threaten ?victim ?goal))))

; publish_secret terminal (expose goal): the secret MOVES from private to reputed. Gated
; on @self knowing a non-spousal liaison of the victim (nothing to denounce otherwise -
; no act, the goal stays standing). The act anchor {@self <method> <victim>}, the pressure
; discharged, the goal ended, any standing extort anchor ended (a published secret is
; spent leverage), the gossip cascade launched (publish-secret-about seeds the victim's
; own circle; the scandal-gossip amplifies village-wide), and the ledger row. TWO methods:
; anonymous_letter needs literacy (can-write); confront_publicly does not. DEFERRED (fold
; in later): the quoted {victim lover partner} speech content on the confront SAY, the
; anonymous letter physically posted to an authority (spouse / father), and the victim
; learning they were exposed - the essential publication (gossip + ledger) is here.
(define-macro expose-confront (?victim ?goal)
  (do
    (begin-ended-belief {@self confront_publicly ?victim})
    (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
    (end-goal {@self expose})
    (if (any {@self extort ?victim} (out int)) (then (end-belief {@self extort ?victim})))
    (publish-secret-about @self ?victim)
    (crime-ledger-append @self ?victim confront_publicly expose @fail @fail)))

(define-macro expose-anon (?victim ?goal)
  (do
    (begin-ended-belief {@self anonymous_letter ?victim})
    (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
    (end-goal {@self expose})
    (if (any {@self extort ?victim} (out int)) (then (end-belief {@self extort ?victim})))
    (publish-secret-about @self ?victim)
    (crime-ledger-append @self ?victim anonymous_letter expose @fail @fail)))

(define-macro terminal-publish-secret (?victim ?goal)
  (if (is-entity (known-nonspousal-liaison ?victim))
      (then (if (and (can-write @self) (chance 0.4))
          (then (expose-anon ?victim ?goal))
          (else (expose-confront ?victim ?goal))))))

; consummate terminal (seduce goal): the deliberated seduction lands. Period-norm
; gates first (opposite-sex + non-kin, mirroring every romance genesis - a seduce goal
; targets a pressure focus, which could be anyone; without the gates the consummation
; minted same-sex / sibling `lover` bonds the marriage pipeline then consumed). On a
; pass: the seduce act anchor, the pressure discharged, the goal ended, reciprocal
; `lover` + punctual HAVE_SEX_WITH records on both minds, and - for a seduced UNMARRIED
; woman - the lifelong {@self prototype fallen_woman} ruin (shuts her out of respectable
; courtship). Blocked (same-sex / kin): the goal just ends, the impulse spent. NOT a
; crime with a victim in the moral sense, but a crime-ledger row records the act.
(define-macro terminal-consummate (?victim ?goal)
  (if (and (none {?victim gender (any {@self gender}).target})
           (not (blood-kin @self ?victim)))
      (then
        (begin-ended-belief {@self seduce ?victim})
        (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
        (end-goal {@self seduce})
        (begin-belief {@self lover ?victim})
        (begin-ended-belief {@self HAVE_SEX_WITH ?victim})
        (begin-belief ?victim {?victim lover @self})
        (begin-ended-belief ?victim {?victim HAVE_SEX_WITH @self})
        (if (and (any {?victim gender [k female]} (out int))
                 (none {?victim spouse ?}))
            (then (begin-belief ?victim {?victim prototype [k fallen_woman]})))
        (crime-ledger-append @self ?victim seduce seduce @fail @fail))
      (else (end-goal {@self seduce}))))

; confess_secret terminal (confess_letter goal): the actor reveals their OWN
; liaison to their nearest kin - scandal without murder; the leak also kills any
; standing blackmail leverage (the coercion refresh pass sees the secret is out).
; NOT a crime - no ledger row. The kin is the first living close relation on the
; father > mother > fiancee > spouse > sibling ladder (the belief ground-alts read
; them in one pattern); the confessed partner must be a real third party. The
; confession is WRITTEN (letter mandate): the confession_letter spawns at the
; kin's home (author = @i, the confessor), and the kin learns the lover fact when
; they read it from their home mail pile (read_pending_mail, drained each window) -
; no fiat cross-mind write. Nothing confessable / no kin -> the goal still ends
; (the impulse passed).
(define-macro terminal-confess (?goal)
  (do
    ; The kin ladder is ONE ground-alt read. Both reads are optional, so they are
    ; guarded inline BEFORE the must-produce (bind ...)s: the ops are deterministic,
    ; so each guarded re-bind reads the value the guard just proved.
    (if (and (is-entity (known-nonspousal-liaison @self))
             (is-entity (any {@self father|mother|fiancee|spouse|sibling ?}).target))
        (then
          (known-nonspousal-liaison @self): ?partner
          (any {@self father|mother|fiancee|spouse|sibling ?}).target: ?kin
          ; No separate confession-record belief: the ended confess_letter goal IS the
          ; actor-side record (act/state doctrine), and {@self confession_letter <kin>}
          ; put a human in the label's doc-kind target slot (ontology reject).
          (if (and (alive ?kin) (not (= ?kin ?partner)))
              (then
                (if (is-entity (home-of ?kin))
                    (then
                      (home-of ?kin): ?kin_home
                      (spawn-letter [k confession_letter]
                                    (nl_written_msg "I have taken ?partner as a lover")
                                    ?kin_home)))))))
    (end-goal {@self confess_letter})))

; public_slight terminal (humiliate goal): the deliberated public put-down. The
; slight is a two-sided act record minted by the GENERAL cross-mind write - the
; actor's own anchor plus the victim's copy (whose degrade_act construals fire
; shame / status_loss / humiliation on their next appraisal) - and
; (witness-copresence) seeds any bystanders (no-op when the pair is not
; co-present). Then discharge, the ledger row, end-goal. A dead / self /
; kind-valued focus just ends the goal.
; DELTA vs the old C++: the quoted BARB content (the hsim_barbs ladder) is not
; carried - the anchor records the slight without the words - and with no barb
; scan there is no wordless-fail path (the impotence ratchet retires with it).
; Porting the barb ladder to .hs content macros is the follow-up that restores
; the words (as a (tell-to ?victim <barb fact>)).
(define-macro terminal-humiliate (?victim ?goal)
  (do
    (if (and (is-entity ?victim) (alive ?victim))
        (then
          (begin-ended-belief {@self public_humiliation ?victim})
          (begin-ended-belief ?victim {@self public_humiliation ?victim})
          (discharge-pressure (caused-by ?goal {@self pressure ?}) 0.75)
          (crime-ledger-append @self ?victim public_humiliation humiliate @fail @fail)))
    (end-goal {@self humiliate})))

; file_report terminal (report_crime goal): the lawful channel - NOT a crime,
; NO ledger row. The report needs a concrete self-wrong the victim actually
; REMEMBERS: their own {@self stolen_from ?loot} discovery record (the theft-
; discovery channel mints it; mere poverty or a witnessed brawl never files -
; the old reportable_crime facet gate reduced to exactly the theft family in
; practice, and stolen_from is its only surviving self-subject record). One
; report per wronged party ({@self report_to_police <target>} is the dedupe
; anchor), literacy required, and the crime_report_letter lands at the police
; station: the suspect sentence when the goal names a live culprit, else the
; loss itself. The goal ends regardless (the impulse passed).
(define-macro terminal-report (?victim ?goal)
  (do
    ; The discovered loss lives as {?loot stolen_from @self} (loot=subject); the
    ; subject-enumeration (for-each-present-tense-belief) binds ?loot off the FREE subject (a
    ; plain free-subject (bind) does not thread into scope). One report per party.
    (for-each ?lb (every {? stolen_from @self})
      (do
        ?lb.subject: ?loot
        (if (and (can-write @self)
                 (none {@self report_to_police (if (is-entity ?victim) (then ?victim) (else ?loot)) /ever}))
            (then
              (begin-ended-belief {@self report_to_police (if (is-entity ?victim) (then ?victim) (else ?loot))})
              (if (alive ?victim)
                  (then (begin-belief {@self suspect ?victim})))
              ; The station is optional (a town without one still remembers the
              ; report): guard inline, then the must-produce bind re-reads the
              ; same first-scan building.
              (if (is-entity (find-building [k police_station]))
                  (then
                    (find-building [k police_station]): ?station
                    (if (alive ?victim)
                        (then (spawn-letter [k crime_report_letter]
                                      (nl_written_msg "I suspect ?victim") ?station))
                        (else (spawn-letter [k crime_report_letter]
                                      (nl_written_msg "?loot was stolen from me") ?station)))))))
        (break)))
    (end-goal {@self report_crime})))

; Dispatch the select-joint winner (?terminal from the perpetration_terminals row)
; to its terminal body. ONE arm per event-ized terminal. Every terminal is .hs
; now - the C++ generative loop is retired (step 6).
(define-macro resolve-perpetration-terminal (?terminal ?victim ?action ?goal)
  (if (= ?terminal pay_off)         (then (terminal-pay-off ?victim ?goal))
  (else (if (= ?terminal harm_non_lethal) (then (terminal-harm-non-lethal ?victim ?goal))
  (else (if (= ?terminal plant_evidence)  (then (terminal-plant-evidence ?victim ?goal))
  (else (if (= ?terminal silence_coerce)  (then (terminal-silence-coerce ?victim ?goal))
  (else (if (= ?terminal publish_secret)  (then (terminal-publish-secret ?victim ?goal))
  (else (if (= ?terminal consummate)      (then (terminal-consummate ?victim ?goal))
  (else (if (= ?terminal confess_secret)  (then (terminal-confess ?goal))
  (else (if (= ?terminal public_slight)   (then (terminal-humiliate ?victim ?goal))
  (else (if (= ?terminal file_report)     (then (terminal-report ?victim ?goal))))))))))))))))))))

; The foe of the deliberator's first {@self under_attack <foe>} state (@fail
; when none) - the threat mirror of the focus bound off an {@self <action>} goal. Minted by strike-blow on a
; non-fatal blow; ended when the fight resolves.
(define-macro threat-focus ()
  (any {@self under_attack ?}).target)

; The rival for ?beloved AS THE DELIBERATOR KNOWS IT: the beloved's spouse,
; else their lover, else the beloved themselves - every read from the
; deliberator's own beliefs (evidence-mediated, no mind-entering). The caller
; must exclude @self (a beloved married to the deliberator names @self here).
(define-macro crave-rival (?beloved)
  (if (is-entity (any {?beloved spouse ?}).target)
      (then (any {?beloved spouse ?}).target)
      (else (if (is-entity (any {?beloved lover ?}).target)
          (then (any {?beloved lover ?}).target)
          (else ?beloved)))))

; The actor's own recent OVERT-method murder victim whose corpse is still in
; its pre-burial window (@fail when none) - the taunt substrate. The label
; set IS the content: every kill method whose corpse cannot pass as an
; accident (the staged methods - poison / freeze / drown / push_from_height /
; death_trap - are excluded: taunting a death that reads natural would blow
; the cover). Keep in step with the (method ...) rows in perpetration.hs.
(define-macro covert-kill-corpse ()
  (own-act-corpse @self
    stab slash decapitate beat_to_death bludgeon strangle garrotte smother
    hang neck_snap shoot bomb immolate arson cook_alive unleash_animal
    unleash_insect uriah_gambit))
