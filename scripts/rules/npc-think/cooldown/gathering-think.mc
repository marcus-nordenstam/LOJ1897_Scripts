; ----------------------------------------------------------------------------
; gathering - the occasion / ceremony keystone (occasion_ceremony_plan.md Item 2).
;
; These two rules only DECIDE. Everything the decision leads to - staging the occasion,
; penning and posting the invitations - is the plan-gathering TASK's work, because a
; think deliberates and a letter is a physical thing only an action may mint.
;
; The lead time rides on the act clause, so the two drivers propose two DIFFERENT acts
; that the one task serves: months out for the formal dinner party, this month for the
; impromptu supper. That lead is also what decides whether anyone is written to - see
; the invitation rung in plan-gathering-task.
;
; Attendance lives in attend_think. Its HOST rung (want_attend_host) gates on {@self
; organize <occ>}, which plan-gathering mints, so the host half works end to end. Its
; GUEST rung gates on {<host> invite @self <occ>}, which a guest can only come to hold
; by READING an invitation - and the invitation carries no form yet, so the guest half
; waits on that.
;
; Validation (hsim <msb> mind <First> <Last>): a host shows {@self organize
; <dinner-party>} with the occasion carrying host/venue/date/hours, then the attend
; task fires in the month the date lands.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; The host's planning decision (npc-think). ~2% of grown NPCs each month decide to
; throw a dinner party at home, set about three months ahead.
(npc-think plan_gathering
  (cooldown 1 m)
  (rng-stream behaviour)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (when (chance 0.02))
    (utility want)
    (effects (maintain-proposal {@self plan-gathering [k dinner-party] 3}))))

; An IMPROMPTU supper: the same staging, set for THIS month. Nobody is written to - the
; post could not arrive in time - so it reaches only whoever is already there. Reaching
; them is not wired: no co-presence op survives, and an occasion is a nameless abstract
; object that cannot ride a spoken wire either, so today the host stages a supper only
; he knows about.
(npc-think plan_impromptu_supper
  (cooldown 1 m)
  (rng-stream behaviour)
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
    (when (chance 0.015))
    (utility want)
    (effects (maintain-proposal {@self plan-gathering [k dinner-party] 0}))))

; ONE invitation per friend, while the day is far enough out for the post to arrive: a
; supper THIS month is not something you write to a man about, so a same-month occasion
; posts nothing and reaches only whoever is already there. A guest whose home @self
; cannot place gets no letter - there is nowhere to send it. The host's own
; {@self invite <guest> /aux <occ>} record, minted when the letter is posted, is what
; takes each friend off this list.
; ONE LETTER AT A TIME. The ?guest role admits every friend still uninvited, so without
; the lock the whole list is raised at once - and every one of them wants its own
; {@self CREATE-ENTITY [k invitation-letter]}, which is the SAME act for all of them.
; They would share one letter and all but one would wait for ever on a postlude that
; ran for somebody else. A man pens one invitation, posts it, and then writes the next.
; The lock rather than a (proposed ..) gate: a rule may not gate on the absence of the
; very thing it mints, or the promoted task fells its own proposal. The
; {@self invite ?guest ?occ} the task mints on success is what takes each friend off
; the role for good.
(npc-think want_invite_guest
  (lock)
  (role ?occ {@self organize ?occ}
             {?occ held-on ?}
    (role ?guest {@self friend ?guest}
                 {?guest home ?}
                 -{@self invite ?guest ?occ}
      (when (not (date-in-current-month (any {?occ held-on ?}).target)))
      (utility errand)
      (effects (maintain-proposal {@self invite-guest ?guest ?occ})))))
