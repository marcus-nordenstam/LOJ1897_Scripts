; ----------------------------------------------------------------------------
; love-match - affect-driven betrothal: a suitor who fancies someone who fancies him back
; resolves to wed them, across class lines, keyed on the standing mutual fancy rather than
; co-presence. The per-suitor chance is the courtship's length. Its intent is pursued like
; betrothal's (thinks/hot/wed-think.mc).
; ----------------------------------------------------------------------------


(intender love-match
  (cooldown 1 m try-once)
  (rng-stream marriages)

  ; @self the suitor: an unmarried, un-betrothed adult who is not socially shut
  ; out. The per-suitor (chance) gate lives in (when ...) (role-belief purity).
  (role @self
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              {@self age-band ?peer_band}
              -{@self spouse ?}
              -{@self repute [k scandalous]}
              ;; Fallen-woman gate, class-modulated (late-Victorian model): the
              ;; respectable classes shut her out of courtship entirely, but
              ;; working-class communities are pragmatic - a lower-class fall may
              ;; still wed (the beloved role completes the pair check).
              (or -{@self prototype fallen-woman}
                  {@self class-situation [k lower]})
    ;; SELF-POV (telepathy purge CAT-3): @self judges the beloved from his OWN
    ;; knowledge - her marital state / lover / fallen mark as HE knows them (banded
    ;; in via gossip/believe_about; permissive on the unknown), her repute as HE
    ;; sees it (3-arg situation), and crucially her RECIPROCAL fancy as SHE TOLD
    ;; HIM (confess-fancy minted {?beloved fancy @self} in his mind). No mind peek.
    (role ?beloved {?beloved isa [k human], condition [k alive]}
                  {?beloved age-band [k young-adult|middle-aged|mature|elderly]}
                  (or -{?beloved fiancee ?} {?beloved fiancee @self})
                  (or -{@self fiancee ?} {@self fiancee ?beloved})
                  -{?beloved spouse ?}
                  -{?beloved repute [k scandalous]}
                  ;; Pair half of the fallen-woman gate: a fallen party (either
                  ;; side) weds only when BOTH sides are lower class.
                  (or -{?beloved prototype fallen-woman}
                      (and {?beloved class-situation [k lower]}
                           {@self    class-situation [k lower]}))
                  (or -{@self prototype fallen-woman}
                      {?beloved class-situation [k lower]})
                  ; the heart of it: @self is attracted to this person (attraction
                  ; at least the `fancy` band, the explicit band-ladder belief) ...
                  {@self fancy|desire|crave ?beloved}:?fancy
                  ; ... and MUTUAL fancy - she fancies him BACK, and SAID SO. A love
                  ; match is a meeting of two hearts: court builds her fancy toward
                  ; him, confess-fancy carries her admission into his mind, and only
                  ; once he KNOWS she reciprocates do they betroth. A one-sided crush
                  ; does NOT marry here - it routes to the arranged betrothal /
                  ; advantageous-match path or goes nowhere.
                  {?beloved fancy @self}
                  ; lover fidelity: a party holding a standing `lover` bond
                  ; love-matches ONLY that lover (the widowed affair-partners
                  ; finally marrying), never a third party over them. `lover` is
                  ; mutual, so "@self holds ?beloved as lover" answers both sides.
                  (or -{@self lover ?}
                      {@self lover ?beloved})
                  (or -{?beloved lover ?}
                      {@self lover ?beloved})
                  ; no marrying blood kin (consanguinity backstop) ...
                  (none {@self (kin-labels) ?beloved})
                  ; ... opposite-sex: @self's belief that the beloved's PERCEIVED
                  ; gender differs from his own (gender is visible-on-sight, so this
                  ; dynamic-target belief is object-cacheable; drops same-sex passes).
                  -{?beloved gender (any {@self gender}).target}
                  {?beloved age-span ?peer_band}

      ;; Live un-betrothed re-check: the role filters are alpha-indexed and go stale
      ;; within the window, so re-check at firing - now from @self's OWN beliefs
      ;; (his own engagement, and what he knows of hers). A same-window double-betroth
      ;; race is left to a future public-blackboard claim, never a mind peek.
      ;; (chance 0.3) is the per-suitor courtship-duration knob; a non-role gate
      ;; (role-belief purity keeps it out of the role filters).
      (when (latch-eval (chance 0.3)))

      (declare-utility want)
      (effects (maintain-intent {@self intent {@self wed ?beloved}} /caused_by ?fancy)))))
