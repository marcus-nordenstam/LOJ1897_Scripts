; ----------------------------------------------------------------------------
; gathering - the occasion / ceremony keystone (occasion_ceremony_plan.md Item 2).
;
; An occasion is a per-mind Mental Object (Concepts.mon `occasion`), NOT an env
; entity. These two (npc-think) rules exercise the substrate:
;
;   plan_gathering        : the host's PLANNING decision. A small fraction of
;                           grown NPCs each month decide to throw a dinner party
;                           at home, ~3 months out. (plan-occasion ... formal)
;                           mints the host's occasion object (search-or-invent
;                           keyed on the constitutive {host, date} pair) +
;                           decorates it with the venue + hours + mints the
;                           {@self organize <occ>} appointment + posts a letter to
;                           every guest in the host's circle (Item 3). Each guest
;                           reads it at their next think (read_pending_invitations),
;                           reconstructs their OWN local occasion object, and holds
;                           the told copy of the host's own {<host> invite @self /aux <occ>}.
;
; Attendance itself is NOT here: a guest LEARNS the occasion by reading the host's
; invitation letter (ordinary mail - its two sentences are {<host> invite @self /aux
; <occ>} + {<occ> held_on <date>}), and the attend_think.hs drivers raise the attend
; task (and a principal's wed duty) in the month held_on lands. No appointment scan.
;
; Validation (hsim <msb> mind <First> <Last>): a host shows {@self organize
; <dinner_party>} with the occasion carrying host/venue/date/hours, then the attend
; task fires in the month the date lands.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; The host's planning decision (npc-think). ~2% of grown NPCs each month
; decide to host; the occasion is set ~3 months ahead, an evening affair.
(npc-think plan_gathering
  (cooldown 1 m)
  (rng-stream behaviour)
  (role @self (grown @self))
  (when (chance 0.02))
  (effects
    (plan-occasion @self [k dinner_party] (any {@self home ?}).target 3 19 23 formal)))

; An IMPROMPTU supper (the INFORMAL channel): unlike the planned dinner party, this
; reaches only whoever the host is physically WITH right now - the co-present set at
; his current location (invite_copresent), nobody from the wider circle. Set for the
; same month (0 months ahead), an evening affair at home.
(npc-think plan_impromptu_supper
  (cooldown 1 m)
  (rng-stream behaviour)
  (role @self (grown @self))
  (when (chance 0.015))
  (effects
    (plan-occasion @self [k dinner_party] (any {@self home ?}).target 0 18 22 informal)))

; Attendance is no scan: reading the invitation (ordinary mail) leaves @self holding
; {<host> invite @self /aux <occ>} + {<occ> held_on <date>}, and the attend_think.hs
; drivers raise the attend / wed tasks in the month held_on lands. No review pass.
