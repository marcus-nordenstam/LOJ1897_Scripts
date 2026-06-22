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
; The fancy gate is (stance-at-least ?suitor ?beloved fancy) - the reliable
; cross-pair BITSET predicate. The believer (?suitor) is the enumerated outer
; role; ?beloved is intersected with the suitor's fancied targets.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event love_match
  (sim-window-start)
  (nl         "@self and ?beloved marry for love")
  (rng-stream marriages)

  (roles
    ; @self the suitor: an unmarried, un-betrothed adult who is not socially shut
    ; out. The chance on the @self role is rolled once per suitor per window.
    (role @self (template any_human)
                (>= (years-old @self) 18)
                (not (believes {@self fiancee ?}))
                (not (believes {@self spouse ?}))
                (not (= (situation @self repute) [k scandalous]))
                ;; Fallen-woman gate, class-modulated (late-Victorian model): the
                ;; respectable classes shut her out of courtship entirely, but
                ;; working-class communities are pragmatic - a lower-class fall may
                ;; still wed (the beloved role completes the pair check).
                (or (not (believes {@self prototype fallen_woman}))
                    (= (situation @self class_situation) [k lower]))
                (chance 0.3))
    (role ?beloved (template any_human)
                  (not (= ?beloved @self))
                  (>= (years-old ?beloved) 18)
                  (not (believes ?beloved {@self fiancee ?}))
                  (not (believes ?beloved {@self spouse ?}))
                  (not (= (situation ?beloved repute) [k scandalous]))
                  ;; Pair half of the fallen-woman gate: a fallen party (either
                  ;; side) weds only when BOTH sides are lower class.
                  (or (not (believes ?beloved {@self prototype fallen_woman}))
                      (and (= (situation ?beloved class_situation) [k lower])
                           (= (situation @self    class_situation) [k lower])))
                  (or (not (believes {@self prototype fallen_woman}))
                      (= (situation ?beloved class_situation) [k lower]))
                  ; the heart of it: @self fancies this person (cross-pair bitset,
                  ; @self the outer believer) ...
                  (stance-at-least @self ?beloved fancy)
                  ; ... and MUTUAL fancy - she fancies him BACK. A love match is a
                  ; meeting of two hearts: court builds her fancy toward him, and
                  ; only once she reciprocates do they betroth. A one-sided crush
                  ; does NOT marry here - it routes to the arranged betrothal /
                  ; advantageous_match path or goes nowhere.
                  (believes ?beloved {?beloved fancy @self})
                  ; lover fidelity: a party holding a standing `lover` bond
                  ; love-matches ONLY that lover (the widowed affair-partners
                  ; finally marrying), never a third party over them. `lover` is
                  ; mutual, so "@self holds ?beloved as lover" answers both sides.
                  (or (not (believes {@self lover ?}))
                      (believes {@self lover ?beloved}))
                  (or (not (believes ?beloved {@self lover ?}))
                      (believes {@self lover ?beloved}))
                  ; no marrying blood kin (consanguinity backstop) ...
                  (not (kin @self ?beloved))
                  ; ... opposite-sex (drops any same-sex standing-pass fancy).
                  (not (= (attr ?beloved gender) (attr @self gender)))
                  (<= (- (years-old @self) (years-old ?beloved))  15)
                  (>= (- (years-old @self) (years-old ?beloved)) -15)))

  ;; Live un-betrothed re-check (see betrothal.hs): the role filters are
  ;; alpha-indexed and go stale within the window, so re-check at firing.
  (when (and (not (believes    {@self fiancee ?}))
             (not (believes ?beloved {@self fiancee ?}))))

  (effects
    ; Symmetric fiancee bond + mutual profile sync - identical to betrothal, so
    ; the existing wedding event consumes the couple (it recovers the groom from
    ; the bride's fiancee belief regardless of which side initiated).
    (begin-belief @self    fiancee ?beloved)
    (begin-belief ?beloved fiancee @self)
    (believe-about @self    ?beloved)
    (believe-about ?beloved @self)
    (log _betrothal @self)))
