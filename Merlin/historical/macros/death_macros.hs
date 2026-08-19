; ----------------------------------------------------------------------------
; death_macros.hs - death world-settlement + burial propagation.
;
; (settle-death ?dead) settles the WORLD when a person dies (natural death,
; suicide, kill - every terminal calls it): a vacated leadership post backfills,
; the roster entry drops, the estate + orgs + money pass to heirs, and (die)
; marks the corpse (condition attr + mind status). It does NOT propagate
; death KNOWLEDGE - that is pulled, never pushed: the learn_of_death keystone
; (npc-think) ends each mind's stale beliefs about the deceased the moment that
; mind LEARNS of the death by a real channel (perceiving the corpse, being told,
; reading it). Goal retirement is likewise distributed - each person-targeted
; lane owns a dead-twin gated on its own dead-belief (fight_concluded /
; kill_concluded / ...), never a central all-minds sweep. (die) runs LAST: the
; settlement ops read the dying person's own ties, and die ends the mind. The
; corpse is NOT destroyed here - burial's rite does that.
;
; (propagate-burial ?corpse): the graveside notification of the whole social
; circle that the corpse is interred, releasing their dead-and-unburied convey /
; bury filters. Must run BEFORE (destroy-entity ?corpse) - the walk reads the
; corpse's own tie beliefs. (A pull-model burial-knowledge lane is later work;
; kept here for now, scoped to the propagate-death purge.)
; ----------------------------------------------------------------------------

(define-macro settle-death (?dead)
  (do
    (promote-on-vacancy ?dead)
    (fire /worker ?dead)
    (inherit-orgs ?dead)
    (inherit-estate ?dead)
    (inherit-money ?dead)
    (die ?dead)))

(define-macro propagate-burial (?corpse)
  (for-each-present-tense-belief {?corpse mother|father|parent|sibling|half_sibling|brother|sister|child|grandmother|grandfather|grandparent|grandchild|aunt|uncle|niece|nephew|cousin|mother_in_law|father_in_law|parent_in_law|sister_in_law|brother_in_law|sibling_in_law|daughter_in_law|son_in_law|child_in_law|stepmother|stepfather|stepchild|spouse|fiancee|friend|lover|acquaintance|neighbour|enemy ?svr /their-mind}
    (begin-belief-in ?svr {?corpse internment [k buried]})))
