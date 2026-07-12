; ----------------------------------------------------------------------------
; patronage (npc-think). A man of standing - high prestige, exemplary reputation
; - takes a lower-class connection under his wing. The effect is a `backed_by`
; belief on the protege, which business_founding (business.hs) gates on as a
; means-branch the next january.
;
; Differs from `investment` in direction: investment is candidate-led (a worthy
; clerk seeks a backer), patronage is patron-led (an established man chooses to
; elevate someone). A mental change (the patron's backing commitment), so
; npc-think; its only effect is the belief - there is no roster / document /
; money movement that would need a located commit, so unlike club-join or hiring
; it stays a pure think (relational). Fired by the per-NPC emergent pass MONTHLY,
; so the per-patron (chance) is /12 (0.06 -> 0.005) to hold the old annual
; once-a-year notable-act rate.
;
; class_situation values today are upper / middle / lower; the (or ...) below
; encodes the valid one-rung-or-more downward sponsorships - an upper patron can
; elevate a middle or lower protege, a middle one a lower protege. Same-class is
; excluded - patronage is a class-bridging act by definition. The repute / class
; comparisons are kind-valued, so they are written [k ...] (a bare atom silently
; never matches a kind mint).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think patronage
  (sim-window-think)
  (rng-stream business)

  ;; @self the patron, a man of standing: exemplary character (belief-pure here).
  ;; The age / prestige floors and the per-patron (chance) roll are non-belief
  ;; gates and now live in the (when ...) clause below.
  (role @self (old_human @self)
              (believes {@self repute [k exemplary]}))
  ;; A protege one or more class steps below the patron, of sound character
  ;; (not scandalous), without an existing backer. The patron judges the
  ;; protege from his OWN view (3-arg (situation ?protege <dim> @self), banded
  ;; in via believe_about) - he can only elevate a connection he actually KNOWS:
  ;; the class match @fails (no firing) for a stranger, while the repute gate is
  ;; permissive on the unknown (only a KNOWN-scandalous protege is excluded).
  ;; (Not already backed - read from the PATRON's OWN knowledge ({backed_by} is
  ;; banded in via believe_about), no mind peek; permissive on the unknown.)
  (role ?protege (old_human ?protege)
                 (not (= ?protege @self))
                 ;; A working-age adult, elevatable into a trade - a belief-pure
                 ;; perceived age-band predicate, so it stays a role filter.
                 (working-age ?protege)
                 (not (believes {?protege repute [k scandalous]}))
                 (not (believes {?protege backed_by ?}))
                 (or (and (believes {@self    class_situation [k upper]})
                          (believes {?protege class_situation [k middle]}))
                     (and (believes {@self    class_situation [k upper]})
                          (believes {?protege class_situation [k lower]}))
                     (and (believes {@self    class_situation [k middle]})
                          (believes {?protege class_situation [k lower]}))))

  ;; Non-belief gates moved out of the @self role: the per-patron (chance) roll
  ;; (first, cheap, short-circuits) and the patron's age / prestige floors.
  (when (and (chance 0.005)
             (>= (years-old @self) 35)
             (>= (target {@self prestige}) 0.65)))

  ;; The old live exclusivity re-check read the protege's OWN backed_by belief
  ;; (telepathy) to catch a same-window double-back. Removed: the patron now gates
  ;; only on his OWN knowledge of who is backed (the role filter above). A rare
  ;; same-window double-back by two patrons is left for a future public-blackboard
  ;; claim (the sanctioned synchronized-group mechanism), never a mind peek.

  (effects
    ; The protege learns of the backing in THEIR own mind ({me backed_by patron}).
    (begin-belief ?protege {?protege backed_by @self})
    ))
