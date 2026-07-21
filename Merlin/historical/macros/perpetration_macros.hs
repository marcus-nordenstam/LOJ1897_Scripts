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
    (if (not (believes {@self extort ?victim})) (then (begin-belief {@self extort ?victim})))
    (deliver-coercion-threat ?victim blackmail)
    (crime-ledger-append @self ?victim blackmail coerce @fail @fail)))

(define-macro coerce-threaten (?victim ?goal)
  (do
    (begin-belief {@self threaten_violence ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self coerce})
    (if (not (believes {@self extort ?victim})) (then (begin-belief {@self extort ?victim})))
    (deliver-coercion-threat ?victim threaten_violence)
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
    (begin-belief {@self confront_publicly ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self expose})
    (if (believes {@self extort ?victim}) (then (end-belief @self extort ?victim)))
    (publish-secret-about @self ?victim)
    (crime-ledger-append @self ?victim confront_publicly expose @fail @fail)))

(define-macro expose-anon (?victim ?goal)
  (do
    (begin-belief {@self anonymous_letter ?victim})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self expose})
    (if (believes {@self extort ?victim}) (then (end-belief @self extort ?victim)))
    (publish-secret-about @self ?victim)
    (crime-ledger-append @self ?victim anonymous_letter expose @fail @fail)))

(define-macro terminal-publish-secret (?victim ?goal)
  (do
    (bind (known-nonspousal-liaison ?victim) ?partner)
    (if (is-entity ?partner)
        (then (if (and (can-write @self) (chance 0.4))
            (then (expose-anon ?victim ?goal))
            (else (expose-confront ?victim ?goal)))))))

; consummate terminal (seduce goal): the deliberated seduction lands. Period-norm
; gates first (opposite-sex + non-kin, mirroring every romance genesis - a seduce goal
; targets a pressure focus, which could be anyone; without the gates the consummation
; minted same-sex / sibling `lover` bonds the marriage pipeline then consumed). On a
; pass: the seduction act anchor, the pressure discharged, the goal ended, reciprocal
; `lover` + punctual HAVE_SEX_WITH records on both minds, and - for a seduced UNMARRIED
; woman - the lifelong {@self prototype fallen_woman} ruin (shuts her out of respectable
; courtship). Blocked (same-sex / kin): the goal just ends, the impulse spent. NOT a
; crime with a victim in the moral sense, but a crime-ledger row records the act.
(define-macro terminal-consummate (?victim ?goal)
  (if (and (not (= (attr @self gender) (attr ?victim gender)))
           (not (blood-kin @self ?victim)))
      (then
        (begin-belief {@self seduction ?victim})
        (bind (driving-pressure-of-goal ?goal) ?pressure)
        (discharge-pressure ?pressure 0.75)
        (end-goal {@self seduce})
        (begin-belief {@self lover ?victim})
        (begin-ended-belief {@self HAVE_SEX_WITH ?victim})
        (begin-belief ?victim {?victim lover @self})
        (begin-ended-belief ?victim {?victim HAVE_SEX_WITH @self})
        (if (and (= (attr ?victim gender) [k female])
                 (not (believes {?victim spouse ?})))
            (then (begin-belief ?victim {?victim prototype [k fallen_woman]})))
        (crime-ledger-append @self ?victim seduction seduce @fail @fail))
      (else (end-goal {@self seduce}))))

; transfer_property terminal (steal goal): the thief is AT the scene (burgle.hs
; walked them there; ?task = opportunist_theft at a residence, embezzle at their
; own workplace). The wronged party is the premises' titled owner (whose house
; this is = village-public knowledge). The act anchor + discharge + end-goal,
; then the thief works the rooms and TAKES the first loose, visible valuable -
; possession flips (the owner's standing {loot location <room>} belief is now
; provably stale, which the attended-whereabouts verify discovers) - and a stow
; goal carries it home to the cache (stow.hs, the generic put lane). The loot's
; leaf kind rides the ledger anchor ("stole: jewelry_box"); an empty-handed
; break-in still ledgers (the intrusion happened). Ends with the defenders'
; chance to stir (burglary-confrontation).
(define-macro terminal-steal (?scene ?task ?owner ?goal)
  (do
    (begin-belief {@self ?task ?owner})
    (bind (driving-pressure-of-goal ?goal) ?pressure)
    (discharge-pressure ?pressure 0.75)
    (end-goal {@self steal})
    ; No hidden test on the loot: items are never hidden - a cached valuable
    ; sits in a hidden SUB-SPACE whose own contents index this rooms-only
    ; walk never reads.
    (for-each ?room (attr-values ?scene parts [k interior_space room])
      (for-each ?item (attr-values ?room contents)
        (if (and (no-goal {@self stow})
                 (has-facet ?item valuable))
            (then
              (take-item ?item)
              (begin-goal {@self stow ?item})
              (crime-ledger-append @self ?owner ?task steal (kind ?item) @fail)))))
    (if (no-goal {@self stow})
        (then (crime-ledger-append @self ?owner ?task steal @fail @fail)))
    (burglary-confrontation @self ?scene)))

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
    (bind (known-nonspousal-liaison @self) ?partner)
    ; The kin ladder in ONE ground-alt read; (target {..}) op-binds (@fail when
    ; the actor has no living close kin) - a plain pattern-bind would leave the
    ; var unbound on a miss and error downstream.
    (bind (target {@self father|mother|fiancee|spouse|sibling ?}) ?kin)
    (if (and (is-entity ?partner) (is-entity ?kin)
             (alive ?kin) (not (= ?kin ?partner)))
        (then
          (begin-belief {@self confession_letter ?kin})
          (bind (home-of ?kin) ?kin_home)
          (if (is-entity ?kin_home)
              (then (spawn-letter [k confession_letter]
                            (written-msg {@self lover ?partner})
                            ?kin_home)))))
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
          (begin-belief {@self public_humiliation ?victim})
          (begin-belief ?victim {@self public_humiliation ?victim})
          (bind (driving-pressure-of-goal ?goal) ?pressure)
          (discharge-pressure ?pressure 0.75)
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
    ; the discovered loss is minted {?loot stolen_from @self} (prop=subject,
    ; @self=the wronged discoverer), so bind the loot off the FREE subject.
    ; The discovered loss lives as {?loot stolen_from @self} (loot=subject); the
    ; subject-enumeration (for-each-belief) binds ?loot off the FREE subject (a
    ; plain free-subject (bind) does not thread into scope). One report per party.
    (for-each-belief {?loot stolen_from @self}
      (do
        (if (and (can-write @self)
                 (not (believes {@self report_to_police (if (is-entity ?victim) (then ?victim) (else ?loot))})))
            (then
              (begin-belief {@self report_to_police (if (is-entity ?victim) (then ?victim) (else ?loot))})
              (bind (find-building [k police_station]) ?station)
              (if (alive ?victim)
                  (then
                    (begin-belief {@self suspect ?victim})
                    (if (is-entity ?station)
                        (then (spawn-letter [k crime_report_letter]
                                      (written-msg {@self suspect ?victim}) ?station))))
                  (else (if (is-entity ?station)
                      (then (spawn-letter [k crime_report_letter]
                                    (written-msg {?loot stolen_from @self}) ?station)))))))
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
; when none) - the threat mirror of goal-focus. Minted by strike-blow on a
; non-fatal blow; ended when the fight resolves.
(define-macro threat-focus ()
  (target {@self under_attack ?}))

; The rival for ?beloved AS THE DELIBERATOR KNOWS IT: the beloved's spouse,
; else their lover, else the beloved themselves - every read from the
; deliberator's own beliefs (evidence-mediated, no mind-entering). The caller
; must exclude @self (a beloved married to the deliberator names @self here).
(define-macro crave-rival (?beloved)
  (if (is-entity (target {?beloved spouse ?}))
      (then (target {?beloved spouse ?}))
      (else (if (is-entity (target {?beloved lover ?}))
          (then (target {?beloved lover ?}))
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
