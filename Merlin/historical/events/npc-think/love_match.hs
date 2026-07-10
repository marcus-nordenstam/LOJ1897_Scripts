; ----------------------------------------------------------------------------
; love_match (npc-think) - affect-driven betrothal.
;
; A suitor who FANCIES someone (the one-sided attraction scalar -> the `fancy`
; verb-state belief, ignited by crush_forms and deepened by court) becomes
; betrothed to them: a love match. Class need NOT match (the romance that crosses
; class lines); the hard requirement is MUTUAL fancy. This runs ALONGSIDE the
; class-parity `betrothal` (the arranged path): fancied pairs pair here, everyone
; else there. That coexistence IS the bond/affect split - a marriage bond forms
; from love here, or from family/class fit there.
;
; A mental change (the fiancee bond), so npc-think. RELATIONAL: the proposal is
; keyed on the standing mutual `fancy`, not co-presence - a mutually-smitten pair
; rarely coincides physically by chance, so (like all courtship FORMATION) the
; co-present gate is dropped (the settled reversion). Re-uses the _betrothal
; kind/log so the existing wedding event consumes the couple unchanged. Fired by
; the per-NPC emergent pass MONTHLY; the per-suitor (chance) gives the courtship
; duration before the mutually-fancied pair commit (a tuning knob).
;
; The fancy gate is (is-attracted-to @self ?beloved) - the band-ladder believes
; (attraction at least the `fancy` band, an EXPLICIT verb-state belief read). The
; believer (@self) is the enumerated outer role; ?beloved is the attracted target.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour love_match
  (long-term-think)
  (rng-stream marriages)

  (roles
    ; @self the suitor: an unmarried, un-betrothed adult who is not socially shut
    ; out. The per-suitor (chance) gate has moved to (when ...) (role-belief purity).
    (role @self (any_human @self)
                (adult-age @self)
                (not (believes {@self fiancee ?}))
                (not (believes {@self spouse ?}))
                (not (believes {@self repute [k scandalous]}))
                ;; Fallen-woman gate, class-modulated (late-Victorian model): the
                ;; respectable classes shut her out of courtship entirely, but
                ;; working-class communities are pragmatic - a lower-class fall may
                ;; still wed (the beloved role completes the pair check).
                (or (not (believes {@self prototype fallen_woman}))
                    (believes {@self class_situation [k lower]})))
    ;; SELF-POV (telepathy purge CAT-3): @self judges the beloved from his OWN
    ;; knowledge - her marital state / lover / fallen mark as HE knows them (banded
    ;; in via gossip/believe_about; permissive on the unknown), her repute as HE
    ;; sees it (3-arg situation), and crucially her RECIPROCAL fancy as SHE TOLD
    ;; HIM (confess_fancy minted {?beloved fancy @self} in his mind). No mind peek.
    (role ?beloved (any_human ?beloved)
                  (not (= ?beloved @self))
                  (adult-age ?beloved)
                  (not (believes {?beloved fiancee ?}))
                  (not (believes {?beloved spouse ?}))
                  (not (believes {?beloved repute [k scandalous]}))
                  ;; Pair half of the fallen-woman gate: a fallen party (either
                  ;; side) weds only when BOTH sides are lower class.
                  (or (not (believes {?beloved prototype fallen_woman}))
                      (and (believes {?beloved class_situation [k lower]})
                           (believes {@self    class_situation [k lower]})))
                  (or (not (believes {@self prototype fallen_woman}))
                      (believes {?beloved class_situation [k lower]}))
                  ; the heart of it: @self is attracted to this person (attraction
                  ; at least the `fancy` band, the explicit band-ladder belief) ...
                  (is-attracted-to @self ?beloved)
                  ; ... and MUTUAL fancy - she fancies him BACK, and SAID SO. A love
                  ; match is a meeting of two hearts: court builds her fancy toward
                  ; him, confess_fancy carries her admission into his mind, and only
                  ; once he KNOWS she reciprocates do they betroth. A one-sided crush
                  ; does NOT marry here - it routes to the arranged betrothal /
                  ; advantageous_match path or goes nowhere.
                  (believes {?beloved fancy @self})
                  ; lover fidelity: a party holding a standing `lover` bond
                  ; love-matches ONLY that lover (the widowed affair-partners
                  ; finally marrying), never a third party over them. `lover` is
                  ; mutual, so "@self holds ?beloved as lover" answers both sides.
                  (or (not (believes {@self lover ?}))
                      (believes {@self lover ?beloved}))
                  (or (not (believes {?beloved lover ?}))
                      (believes {@self lover ?beloved}))
                  ; no marrying blood kin (consanguinity backstop) ...
                  (not (blood-kin @self ?beloved))
                  ; ... opposite-sex: @self's belief that the beloved's PERCEIVED
                  ; gender differs from his own (gender is visible-on-sight, so this
                  ; dynamic-target belief is object-cacheable; drops same-sex passes).
                  (not (believes {?beloved gender (target {@self gender})}))
                  (age-peers @self ?beloved)))

  ;; Live un-betrothed re-check: the role filters are alpha-indexed and go stale
  ;; within the window, so re-check at firing - now from @self's OWN beliefs
  ;; (his own engagement, and what he knows of hers). A same-window double-betroth
  ;; race is left to a future public-blackboard claim, never a mind peek.
  ;; (chance 0.3) moved here from the @self role (role-belief purity); FIRST so it
  ;; short-circuits cheaply. It is the per-suitor courtship-duration knob.
  (when (and (chance 0.3)
             (not (believes {@self fiancee ?}))
             (not (believes {?beloved fiancee ?}))))

  (effects
    ; Symmetric fiancee bond + mutual profile sync - identical to betrothal, so
    ; the existing wedding event consumes the couple (it recovers the groom from
    ; the bride's fiancee belief regardless of which side initiated).
    (begin-belief {@self fiancee ?beloved})
    (begin-belief ?beloved {?beloved fiancee @self})
    (believe-about @self    ?beloved)
    (believe-about ?beloved @self)
    ))
