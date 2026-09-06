; ----------------------------------------------------------------------------
; affair (npc-think) - CHARACTER-driven infidelity (the serial-cheater pathway).
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
; run_generative_obsession (crime_of_passion.hs) reads a jealous spouse whose partner
; holds a third-party `lover` and routes blame -> kill; it is also the surveillance /
; discovery surface (pry_think, affair_rendezvous).
;
; A mental change (a reciprocal lover bond), so npc-think. RELATIONAL: gated on
; marriage + personally-knows, no physical co-presence - the paramour is a known
; third party (a colleague, the boss, a fellow club-goer), bound by the social tie.
; Per-NPC emergent MONTHLY. The paramour (?lover) is a known, age-appropriate,
; opposite-sex non-relative who is NOT the actor's own spouse. `lover` is an
; inclusive_bond, so minting it on a married person is well-formed (no @excl
; collision, no exclusive-bond betray cascade).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think affair
  (cooldown 1 m)
  (rng-stream incidents)

  ;; @self - a married adult, not already mid-affair. The disposition-to-stray
  ;; gate (the chance product over openness x enthusiasm x impropriety) is a
  ;; non-belief filter and lives in the (when ...) clause below.
  (role @self
              {@self age-band [k young-adult|middle-aged|mature|elderly]}
              {@self spouse ?}
              -{@self lover ?}
              {@self age-band ?peer_band})
  (role ?lover {?lover isa [k human], condition [k alive]}
               {?lover age-band [k young-adult|middle-aged|mature|elderly]}
               ; the paramour must NOT be @self's own spouse (a third party).
               -{@self spouse ?lover}
               ; the affair ignites with a known third party (social tie).
               {@self friend|acquaintance|spouse|lover|mother|father|sibling|child|talk-to ?lover /ever}
               ; @self's band within ?lover's perceived age-span (+/-1). Bound in
               ; the @self role: an inline (any {@self age-band}).target does not
               ; resolve against the plural age-span belief.
               {?lover age-span ?peer_band}
               ; opposite-sex: @self's belief that ?lover's PERCEIVED gender differs
               ; from his own (visible-on-sight -> cacheable), and non-kin.
               -{?lover gender (any {@self gender}).target}
               (none {@self mother|father|parent|sibling|half-sibling|child|cousin|grandparent|grandchild|aunt|uncle|niece|nephew ?lover}))

  ;; The disposition-to-stray, rolled once per NPC per month: the character tail
  ;; (infidelity-disposition) released by callousness (the empathy brake off),
  ;; scaled by the master antisocial throttle. NO marital / decorum read - a serial
  ;; cheater strays from character, not deficit.
  ; No @self-lover re-check: the engine re-consults the cached self-gate PER
  ; CANDIDATE fire (write-reconciled), so the first paramour minted this tick
  ; empties the gate and stops the rest - one new affair per spouse per tick.
  (when (chance (* (crime-scale) 0.2
                   (infidelity-disposition @self)
                   (callousness @self))))

  (utility want)

  (effects
    ; Reciprocal lover bond + mutual profile sync (mirrors lovers.hs's shape so
    ; downstream consumers - betrayal detection, the romantic-rival derive - see a
    ; fully-wired pair). @self's spouse will read {@self lover ?lover} in the
    ; obsession pass and route blame.
    (begin-belief {@self lover ?lover})
    ; The reciprocal bond lands in the LOVER's own mind (so the lover knows of the
    ; affair, and their own spouse's obsession pass can read {?lover lover @self}).
    (begin-belief ?lover {?lover lover @self})
    ; Ground the pull in the stance substrate ON BOTH SIDES - a lover bond is
    ; constructed on physical attraction, so both hold at least the `fancy` band
    ; (0.4 clears the 0.24 band-entry threshold). Without the reciprocal nudge a
    ; paramour could "be a lover" while fancying nobody, which broke love_match's
    ; ability to marry the pair once both were free.
    (nudge-stance ?lover attraction 0.4)
    ; TELEPATHY - a rule cannot move ANOTHER mind's stance. Restore this as the other
    ; party's own reflex on the act. Commented out pending that redesign.
    ; (nudge-stance ?lover @self attraction 0.4)
    ; @self discloses their friend-tier profile to the lover (the SAY they hear and
    ; adopt); @self's knowledge of the lover pre-exists. Friend-tier, so @self does
    ; not reveal their OTHER lovers (that is intimate-tier, above this band).
    (every {@self (disclosure-tier-labels friend) ?}): ?facts
    (if ?facts
        (then (begin-proposal {@self SAY (utterable-msg ?facts) ?lover})))
    ))
