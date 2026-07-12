; ----------------------------------------------------------------------------
; wedding - the marriage SPLIT into npc-think + npc-act (occasion_ceremony_plan.md
; Item 4B / Item 5). The old single wedding event (which both decided AND made the
; marriage in one step) is replaced:
;
;   plan_wedding (HERE, npc-think): a betrothed man stages a WEDDING OCCASION at a
;       same-town church ~3 months out. Both bride and groom become principals of
;       it (each holds {@self organize <occ>}), so both are forced-attend (the
;       couple ALWAYS shows up); both guest circles are invited. No marriage yet.
;
;   attend_* (the attendance act, attend.hs): the couple + guests route to the
;       church and gather there on the day.
;
;   formalize-wedding (the attend COMPLETION, attend.hs): the marriage is MADE AT
;       THE CHURCH by whoever shows up - the first principal to arrive ends the
;       betrothal, begins the {spouse} bond on both sides, and propagates the
;       in-laws / family / guest-circle announcement (the old wedding's effects).
;
; Gated to fire ONCE per betrothal: a man who holds a fiancee, is not yet married,
; and is not already organizing a wedding. (organizing-occasion [k wedding]) is the
; idempotence guard - without it each window would stage a fresh occasion at a new
; date. Only the groom (unmarried_man) plans; the bride is wired in as co-principal.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think plan_wedding
  (sim-window-think)
  (rng-stream marriages)
  ; @self GATE: unmarried adult man (the template's male / 18+ / not-spouse filters
  ; apply to @self; its kind/alive existence checks are no-ops for @self and are
  ; skipped by the gate-builder). Only the groom plans; the bride is wired in as
  ; co-principal by plan-wedding.
  (role @self (unmarried_man @self))
  (when (and (believes {@self fiancee ?})
             (not (organizing-occasion [k wedding]))))
  (effects
    ; The venue is the groom's same-town church; ~3 months' banns lead, an
    ; 11-14h ceremony. plan-wedding stages the occasion (both principals
    ; forced-attend, both circles invited).
    (plan-wedding @self (target {@self fiancee})
                  (pick-location @self [k building church]) 3 11 14)
    ))
