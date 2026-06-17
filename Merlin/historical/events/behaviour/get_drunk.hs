; ----------------------------------------------------------------------------
; get_drunk - the general drinking event. Each month a share of adults who
; are not yet alcohol-dependent drink to excess. Who drinks is a multi-
; causal risk model: Risk = vulnerability x environment / protection.
;   vulnerability - low industriousness / low politeness (disinhibition),
;                   high volatility (reactive drinking), high withdrawal
;                   (self-medication), high enthusiasm (social drinking).
;   environment   - low wealth raises financial stress.
;   protection    - religious involvement and deep social ties lower
;                   the odds.
;
; Each factor sits at ~1.0 at the population median (Big Five attr ~0.5,
; derived situation aggregates ~50/100), so 0.014 is the median monthly
; chance. Each drinking episode also rolls (risk-dependence ?npc) for the
; slide into a standing craving; dependent NPCs are excluded here and
; cast by relapse.hse instead.
;
; Design note. The environment and protection factors are read from the
; aggregated situations cached by derive_prototypes once a year, not from
; raw (count-beliefs ...) tallies:
;   - The signal isn't "how many debts" but "how much financial stress"
;     - the wealth situation already weighs debts against assets.
;   - The signal isn't "how often did they attend church" but "how
;     religious is this NPC" - the piety situation captures that.
;   - The signal isn't "how many close friends" but "how socially
;     embedded" - the belonging situation captures that.
;
; The bounded form lets the engine decompose this chance into a cheap
; (chance ~0.20) pre-roll plus a residual conditional roll, short-
; circuiting ~80% of candidates before the risk-model tree evaluates.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event get_drunk
  (nl         "?npc drinks to excess")
  (kind [k _get_drunk])
  ; EMERGENT (Section 4.11): no (schedule) - fired by the per-NPC emergent pass.
  ; The per-NPC risk-model (chance) below IS the rate (monthly); the pass is the
  ; cadence. Co-presence + the "drank at a pub" memory move to a place-coupled
  ; pub affordance later; here only the venueless intoxication bump fires.
  (band      evening)
  (rng-stream behaviour)

  (roles
    (role ?npc (template old_human)
               (not (= (belief-target ?self craving) [k alcohol]))
               (chance
                 (* 0.014                                                  ; base monthly rate
                    (+ 0.55 (* 0.90 (- 1.0 (attr ?self industriousness)))) ; low industriousness
                    (+ 0.65 (* 0.70 (- 1.0 (attr ?self politeness))))      ; low politeness
                    (+ 0.70 (* 0.60 (attr ?self volatility)))              ; reactive drinking
                    (+ 0.70 (* 0.60 (attr ?self enthusiasm)))              ; social drinking
                    (+ 0.70 (* 0.60 (attr ?self withdrawal)))              ; self-medication
                    (- 1.5 (situation ?self wealth))                      ; low wealth -> stress
                    (- 1.5 (situation ?self piety))                       ; low piety -> less protection
                    (- 1.5 (situation ?self belonging))))))               ; low belonging -> less protection

  (effects
    (get-drunk ?npc)
    (risk-dependence ?npc)
    (log _get_drunk ?npc)))
