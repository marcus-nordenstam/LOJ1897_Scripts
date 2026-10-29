; ----------------------------------------------------------------------------
; affair-driver (think) - CHARACTER-driven infidelity (the serial-cheater pathway).
;
; A married NPC takes up with a known third party. The straying is a DISPOSITION,
; not a response to an unhappy marriage: narcissistic supply-hunger + psychopathic
; thrill / low empathy + volatile impulsivity (infidelity-disposition), released by
; callousness (the empathy brake off). Satisfaction-INDEPENDENT - no read of the
; marriage - so a "chaos is baseline" cheater strays whatever their home life, and
; the low-empathy brake makes them a SERIAL offender. The covert secrecy is the
; draw, not a deterrent.
;
; The affair is the betrayal-detector's INPUT, not itself a crime:
; run_generative_obsession (crime-of-passion.mc) reads a jealous spouse whose partner
; holds a third-party `lover` and routes blame -> kill; it is also the surveillance /
; discovery surface (pry_think, affair_rendezvous).
;
; A mental change (a reciprocal lover bond), so think. RELATIONAL: gated on
; marriage + personally-knows, no physical co-presence - the paramour is a known
; third party (a colleague, the boss, a fellow club-goer), bound by the social tie.
; Per-NPC emergent MONTHLY. The paramour (?lover) is a known, age-appropriate,
; opposite-sex non-relative who is NOT the actor's own spouse. `lover` is an
; inclusive_bond, so minting it on a married person is well-formed (no @excl
; collision, no exclusive-bond betray cascade).
; ----------------------------------------------------------------------------


(driver affair-driver
  (cooldown 1 m try-once)
  (rng-stream incidents)

  ;; @self - a married adult, not already mid-affair. The disposition-to-stray
  ;; gate (the chance product over openness x enthusiasm x impropriety) is a
  ;; non-belief filter and lives in the (when ...) clause below.
  (role @self {@self compassion ?compassion}
              {@self infidelity-disposition ?infidelity-disposition}
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              {@self spouse ?}
              -{@self lover ?}
              {@self age-band ?peer_band}
    (role ?lover {?lover isa [k human], condition [k alive]}
                 {?lover age-band [k young-adult|middle-aged|mature|elderly]}
                 ; the paramour must NOT be @self's own spouse (a third party).
                 -{@self spouse ?lover}
                 ; the affair ignites with a known third party (social tie).
                 {@self (closeness-labels acquaintance) ?lover /ever}
                 ; @self's band within ?lover's perceived age-span (+/-1). Bound in
                 ; the @self role: an inline (any {@self age-band}).target does not
                 ; resolve against the plural age-span belief.
                 {?lover age-span ?peer_band}
                 ; opposite-sex: @self's belief that ?lover's PERCEIVED gender differs
                 ; from his own (visible-on-sight -> cacheable), and non-kin.
                 -{?lover gender (any {@self gender}).target}
                 (none {@self (kin-labels) ?lover})

      ;; The disposition-to-stray, rolled once per NPC per month: the character tail
      ;; (infidelity-disposition) released by callousness (the empathy brake off),
      ;; scaled by the master antisocial throttle. NO marital / decorum read - a serial
      ;; cheater strays from character, not deficit.
      ; No @self-lover re-check: the engine re-consults the cached self-gate PER
      ; CANDIDATE fire (write-reconciled), so the first paramour minted this tick
      ; empties the gate and stops the rest - one new affair per spouse per tick.
      (when (latch-eval (chance (* (crime-scale) 0.2
                       ?infidelity-disposition
                       (- 1.0 ?compassion)))))

      (declare-utility want)

      (effects (maintain-proposal {@self take-lover ?lover})))))
