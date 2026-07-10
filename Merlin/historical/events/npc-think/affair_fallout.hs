; ----------------------------------------------------------------------------
; affair_fallout.hs - broad, NON-lethal betrayal fallout (homicide_motive_realism
; pattern-4 + divorce). The counterpart to betrayal_kill.hs: where that pass is
; the murderous tail, this is what happens to EVERYONE else who is betrayed -
; the great majority who react without violence.
;
; PURE .hs (no C++ generator):
;   - ?partner is a spouse or lover the actor believes keeps a third-party
;     lover (the same discovery shape as betrayal_kill.hs - the actor's OWN
;     beliefs, no mind peek); (interloper-of ?partner) resolves the interloper;
;   - the monthly discovery chance (0.12) surfaces a standing affair over
;     time, not instantly;
;   - SUPPRESS-EXPOSE-ON-KILL: an actor who already holds a kill goal on
;     either corner of the triangle keeps the secret - no public fallout, no
;     divorce - exposing the affair would advertise the motive;
;   - (appraise-betrayal) mints anger@partner + contempt@interloper + a
;     humiliation PRESSURE; the pressure feeds the ordinary deliberation table
;     (humiliation -> confront_privately / expose / humiliate / withdraw), so
;     the betrayed spouse confronts / exposes / shames the cheat on later
;     ticks. No kill goal is minted here;
;   - DIVORCE: a betrayed HUSBAND (never a wife - the period gives her no such
;     remedy) may put the marriage away at 0.35 x decorum (an unknown decorum
;     reads 0.5): both spouse bonds end, and the {husband divorce wife}
;     act-record lands in BOTH minds (gossipable - the town learns whom he put
;     away; the repudiation_act reactions mint her shame / grief / status_loss);
;   - THE FALLEN WOMAN: a divorced wife is marked for life - {@self prototype
;     fallen_woman} in her mind and {wife prototype fallen_woman} in his (the
;     gossip channel carries her disgrace; betrothal / love_match exclude her).
;     She is cast out of the marital home (a live parent's roof, else a
;     rowhouse; failing all she stays on in disgrace - expel-divorced-wife) and
;     turned out of any reputation-based post (dismiss-from-service).
;
; Once a spouse divorces, the bond is gone, so they are no longer a
; betrayed-spouse candidate. To A/B, rename / remove this file (runtime-loaded).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour affair_fallout
  (long-term-think)
  (rng-stream incidents)

  (role @self (any_human @self))
  ; The unfaithful partner: a spouse or lover of the actor's (the interloper
  ; is resolved in (effects) - a cross-role read, not a role filter).
  (role ?partner (any_human ?partner)
    (believes {@self spouse|lover ?partner})
    (pick-first-matching-role))

  ; The affair surfaces some months, not every one (probabilistic discovery).
  (when (and (alive ?partner)
             (chance 0.12)))

  (effects
    ; Resolve the interloper in @self's own beliefs; @fail = no known affair.
    (bind (interloper-of ?partner) ?interloper)
    (if (and (is-entity ?interloper)
             (no-goal {@self kill ?partner})
             (no-goal {@self kill ?interloper}))
        (do
          ; The betrayal appraisal: anger / contempt / humiliation pressure -
          ; deliberation turns it into the non-lethal release set later.
          (appraise-betrayal ?partner ?interloper)
          ; Divorce: the husband's remedy alone; the proper / high-decorum are
          ; likeliest to cut the tie.
          (if (and (believes {@self spouse ?partner})
                   (believes {@self gender [k male]})
                   (chance (* 0.35 (target-or @self decorum 0.5))))
              (do
                (end-belief @self spouse ?partner)
                (begin-belief {@self divorce ?partner})
                ; Mutual: end her reciprocal bond and land the repudiation
                ; act-record in her mind too.
                (end-belief ?partner spouse @self)
                (begin-belief ?partner {@self divorce ?partner})
                ; The fallen woman: marked in her mind AND his, expelled from
                ; the marital roof, dismissed from reputable service.
                (if (believes {?partner gender [k female]})
                    (do
                      (begin-belief ?partner {?partner prototype [k fallen_woman]})
                      (begin-belief {?partner prototype [k fallen_woman]})
                      (expel-divorced-wife ?partner)
                      (dismiss-from-service ?partner)))))))))
