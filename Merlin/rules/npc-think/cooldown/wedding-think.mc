; ----------------------------------------------------------------------------
; wedding - the marriage SPLIT into npc-think + npc-action (occasion_ceremony_plan.md
; Item 4B / Item 5), authored across two lanes:
;
;   plan_wedding (HERE, npc-think): a betrothed man stages a WEDDING OCCASION at a
;       same-town church ~3 months out. Both bride and groom become principals of
;       it (each holds {@self organize <occ>}), so both are forced-attend (the
;       couple ALWAYS shows up); both guest circles are invited. No marriage yet.
;
;   attend_* (the attendance TASK, attend_think.hs): the couple + guests route to
;       the church (enter) and gather there through the window (dwell).
;
;   attend_vow / vow_realized / spouse_reciprocate (attend_think.hs): the marriage
;       is MADE AT THE CHURCH by whoever shows up - the vow is a say_to ("you are
;       my spouse"); hearers adopt it, the speaker's own beliefs are think
;       effects, reciprocation marries the bride back, and (formalize-marriage)
;       runs the kin residue (rivalry settle + in-laws + family).
;
; Gated to fire ONCE per betrothal: a man who holds a fiancee, is not yet married,
; and is not already organizing a wedding. (organizing-occasion [k wedding]) is the
; idempotence guard - without it each window would stage a fresh occasion at a new
; date. Only the groom (unmarried_man) plans; the bride is wired in as co-principal.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think plan_wedding
  (cooldown 1 m)
  (rng-stream marriages)
  ; @self GATE: unmarried adult man (the template's male / 18+ / not-spouse filters
  ; apply to @self; its kind/alive existence checks are no-ops for @self and are
  ; skipped by the gate-builder). Only the groom plans; the bride is wired in as
  ; co-principal by plan-wedding.
  (role @self (unmarried_man @self)
              {@self fiancee ?fiancee})   ; existence cached, ?fiancee binds at fire
  ; The venue is a same-town church the groom KNOWS; nearest preferred, weighted.
  ; No known church -> no fire (the goal waits).
  (role ?church [k building church] (select (score (near @self ?church)) (policy roulette)))
  (when (none (organizing-occasion [k wedding])))
  (effects
    ; ~3 months' banns lead, an 11-14h ceremony. plan-wedding stages the occasion
    ; (both principals forced-attend, both circles invited).
    ; TELEPATHY - this staged the occasion in both principals' and every guest's mind.
    ; Wants re-authoring as the groom minting his OWN occasion + posting invitations.
    ; Commented out pending that redesign.
    ; (plan-wedding @self ?fiancee ?church 3 11 14)
    ))
