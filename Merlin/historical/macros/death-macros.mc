; ----------------------------------------------------------------------------
; death_macros.hs - death world-settlement.
;
; (settle-death ?dead) settles the WORLD when a person dies (natural death,
; suicide, kill - every terminal calls it): a vacated leadership post backfills,
; the roster entry drops, and (die) marks the corpse (condition attr + mind
; status). The ESTATE is NOT settled here - a dead person effects nothing;
; inheritance is the LIVING heir's own act (the will-based lane: deliberate_will
; names the heir in life, settle_inheritance / INHERIT lets the named heir claim
; the deeds + founded orgs after they learn of the death). It does NOT propagate
; death KNOWLEDGE - that is pulled, never pushed: the learn_of_death keystone
; (npc-think) ends each mind's stale beliefs about the deceased the moment that
; mind LEARNS of the death by a real channel (perceiving the corpse, being told,
; reading it). Goal retirement is likewise distributed - each person-targeted
; lane owns a dead-twin gated on its own dead-belief (fight_concluded /
; kill_concluded / ...), never a central all-minds sweep. (die) runs LAST: the
; settlement ops read the dying person's own ties, and die ends the mind. The
; corpse is NOT destroyed here - burial's rite does that.
;
; ----------------------------------------------------------------------------

(define-macro settle-death (?dead)
  (do
    (set-attr ?dead condition [k dead])
    (die ?dead)))
