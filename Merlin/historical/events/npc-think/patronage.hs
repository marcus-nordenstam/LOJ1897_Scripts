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

(include "../../definitions/roles.hs")

(hsim-event patronage
  (sim-window-start)
  (nl         "@self takes ?protege under their wing")
  (rng-stream business)

  (roles
    ;; @self the patron, a man of standing: exemplary character + high prestige
    ;; (the senior-or-above class signal). prestige is a numeric dimension on the
    ;; 0..1 scale; a >= 0.65 floor selects the senior + org_head tier. The chance
    ;; on the @self role is rolled once per patron per window.
    (role @self (template old_human)
                (>= (years-old @self) 35)
                (= (situation @self repute) [k exemplary])
                (>= (situation @self prestige) 0.65)
                (chance 0.005))
    ;; A protege one or more class steps below the patron, of sound character
    ;; (not scandalous), without an existing backer.
    (role ?protege (template old_human)
                   (not (= ?protege @self))
                   (>= (years-old ?protege) 18)
                   (<= (years-old ?protege) 55)
                   (not (= (situation ?protege repute) [k scandalous]))
                   (not (believes ?protege {@self backed_by ?}))
                   (or (and (= (situation @self     class_situation) [k upper])
                            (= (situation ?protege  class_situation) [k middle]))
                       (and (= (situation @self     class_situation) [k upper])
                            (= (situation ?protege  class_situation) [k lower]))
                       (and (= (situation @self     class_situation) [k middle])
                            (= (situation ?protege  class_situation) [k lower])))))

  ;; Live exclusivity re-check (see betrothal.hs): the protege's "not already
  ;; backed" filter is alpha-indexed, so within one window several patrons can
  ;; back the same protege before the first backed_by commits. The when_gate is
  ;; live per firing; once the protege is backed this window it fails + backtracks.
  (when (not (believes ?protege {@self backed_by ?})))

  (effects
    (begin-belief ?protege backed_by @self)
    (log _patronage ?protege)))
