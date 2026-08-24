; ----------------------------------------------------------------------------
; inheritance - the will-based estate lane (replaces the C++ pick_heir /
; inherit_estate settlement).
;
;   deliberate_will   : once a year an adult re-picks the single heir they wish
;                       to name and (re)writes their will. It is a CHOICE from
;                       the testator's OWN family knowledge - no omniscient age
;                       law - so heirship is settled in LIFE, in the mind, and
;                       recorded in a document that outlives the mind.
;   settle_inheritance : when a living NPC learns a person has died AND that
;                       person's will names @self as heir, @self proposes to
;                       INHERIT. Heir resolution at death is just "read the will":
;                       no death-time kin walk, no cross-mind read.
;
; Shares the learn_of_death trigger ({?dead condition [k dead]}, minted by any
; real channel). The estate itself is claimed by the INHERIT act; a heir-less
; estate simply stays deeded to the dead until a later administrator lane lands.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The preferred heir: a living relative the testator knows, ranked spouse >
; child > sibling (a choice, not a primogeniture age-law - within a tier the
; select's first witness binds one). No candidate -> no proposal -> no will.
(npc-think deliberate_will
  (cooldown 1 m)
  (role @self (adult @self))
  (role ?heir (any_human ?heir)
    {@self spouse|child|sibling ?heir}
    (select (score (+ (* 4 (count (every {@self spouse  ?heir})))
                      (* 2 (count (every {@self child   ?heir})))
                      (count       (every {@self sibling ?heir}))))))
  (when (in-month december))
  (utility duty)
  (effects (maintain-proposal {@self WRITE_WILL ?heir})))

; The named heir acts on discovery. ?dead is anyone @self believes dead; ?will
; fans the will register, and the (when) keeps only ?dead's will when it names
; @self. INHERIT consumes the will, so the proposal withdraws once probate runs.
(npc-think settle_inheritance
  (cooldown 1 m)
  (role ?dead (believes {?dead condition [k dead]}))
  (role ?will [k will])
  (when (and (read-doc-record [k will] ?will (testator ?t) (heir ?h))
             (= ?t ?dead)
             (= ?h @self)))
  (utility duty)
  (effects (maintain-proposal {@self INHERIT ?dead})))
