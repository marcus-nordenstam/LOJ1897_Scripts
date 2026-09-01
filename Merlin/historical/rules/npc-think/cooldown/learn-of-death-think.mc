; ----------------------------------------------------------------------------
; learn_of_death (npc-think) - the KEYSTONE of the no-telepathy death chain.
;
; Knowledge is PULLED, never pushed. propagate-death's kin-notification sweep is
; PURGED (it minted {dead condition dead} into every relative's mind by a
; /their-mind director walk - the telepathy batch-3 ruling 4 targets). Instead,
; each mind learns of a death only through a REAL channel - perceiving the corpse
; (condition is (per obs)(hsim-percept), so a co-present witness internalizes
; {?x condition dead} on sight), being told, or reading it. Every channel mints
; the same {?x condition [k dead]}, so this rung is channel-agnostic.
;
; It owns the BELIEFS consequence ONLY: for every person @self now believes dead,
; end @self's stale PRESENT-TENSE beliefs about them (their job, whereabouts,
; membership, ...) - the ended beliefs stay as episodic /past history - EXCLUDING
; the standing body-state (condition dead + internment
; - the dead-and-unburied pair that drives the convey / bury duty lanes). A
; STANDING INVARIANT, not fire-once: hearsay arriving years later flips within a
; month (the sim's native resolution). end-beliefs-about is idempotent - an
; already-cleaned picture is a no-op walk - so re-firing is cheap. Goal retirement
; is NOT here: each person-targeted lane owns its own dead-twin (fight_concluded /
; kill_concluded / ...), so post-mortem DUTY goals (convey / bury / attend) survive.
;
; Consequence, accepted as the model: an absentee (never perceived the corpse,
; never told) keeps stale beliefs - a modeled fact about them, not a leak. The
; kin-death-awareness that propagate-death pushed telepathically now travels by
; witness-chains until Phase B's news lane lands.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think learn_of_death
  (cooldown 1 m)

  ; Enumerating role: every person @self believes dead, however @self learned it.
  (role ?x {?x condition [k dead]})

  (effects
    (end-beliefs-about ?x [/exclude condition|internment] /reason died)))
