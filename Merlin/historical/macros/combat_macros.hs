; ----------------------------------------------------------------------------
; combat_macros.hs - the shared per-blow physics for the ATTACK-ACTION FAMILY
; (STRIKE / STAB / SLASH / SHOOT / BLUDGEON / STRANGLE / SMOTHER / PUNCH). Each
; attack action is one class; its body hardcodes that class's wound/site/consequence
; literals (yield-evidence reads them as literal atoms) and calls (strike-body ...)
; for the shared roll. blame lives on the `assault` TASK, never on these neutral blows.
; ----------------------------------------------------------------------------

; A whiffing attacker is easier to slip: a clean miss posts `whiffed` on the
; attacker (publicly observable), read by the flee roll as a recent-clumsiness bonus.
(define-macro whiff_ttl_cycles () 3)

; A sustained kill-assault finally tells: a LANDED-but-non-fatal kill blow succumbs
; with this per-blow probability (the bleed-out analogue the dead bleed columns modelled).
(define-macro blow_succumb_prob () 0.25)

; (strike-body ?hit_body ?graze_body): the shared blow. Pumps adrenaline, rolls the
; hit (@self's strength + dexterity - the intoxication penalty; all own-attr reads =
; blessed act physics), then dispatches: a solid HIT runs ?hit_body, a GRAZE ?graze_body,
; a clean MISS posts the whiff marker (publicly observable clumsiness the flee roll reads).
; ?hit_body / ?graze_body carry the class's wound literals + the consequence, passed by
; the action. Two fidelity terms the C++ blow had drop out here, deliberately: the
; defender's active dodge (a foe's dexterity is a cross-entity hidden-state read - batch-3
; attr clause; the fight's two-sidedness carries it, the foe strikes back) and the
; competence-band bonus (a think-side hand-in refinement - see fight_decomposition_plan).
(define-macro strike-body (?hit_body ?graze_body)
  (do
    (set-attr @self adrenaline 1)
    (clamp (+ 0.45
              (* 0.30 (- (attr @self strength) 0.5))
              (* 0.40 (- (attr @self dexterity) 0.5))
              (* -1.2 (attr @self intoxication)))
           0.02 0.98): ?p
    (rng-unit): ?u
    (if (< ?u ?p) (then ?hit_body)
     (else (if (< ?u (+ ?p 0.30)) (then ?graze_body)
      (else (pub-bb-post @self whiffed (whiff_ttl_cycles))))))))

; (kill-blow ?foe ?method): the fatal physics - the crime-ledger row (goal kill, task
; the specific verb), the objective violent death_cause on the corpse, then settle-death
; (world settlement + die - NO telepathy; witnesses learn via observation, absentees via
; the learn_of_death keystone). ?method is the striking verb literal.
(define-macro kill-blow (?foe ?method)
  (do
    (crime-ledger-append @self ?foe ?method kill @u @u)
    (record-corpse-death ?foe [k death_cause violence])
    (settle-death ?foe)))
