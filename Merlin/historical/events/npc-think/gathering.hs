; ----------------------------------------------------------------------------
; gathering - the occasion / ceremony keystone (occasion_ceremony_plan.md Item 2).
;
; An occasion is a per-mind Mental Object (Concepts.mon `occasion`), NOT an env
; entity. These two window-start (npc-think) events exercise the substrate:
;
;   plan_gathering        : the host's PLANNING decision. A small fraction of
;                           grown NPCs each month decide to throw a dinner party
;                           at home, ~3 months out. (plan-occasion ... formal)
;                           mints the host's occasion object (search-or-invent
;                           keyed on the constitutive {host, date} pair) +
;                           decorates it with the venue + hours + mints the
;                           {@self organize <occ>} appointment + posts a letter to
;                           every guest in the host's circle (Item 3). Each guest
;                           reads it at the next window (read_pending_invitations),
;                           reconstructs their OWN local occasion object, and holds
;                           {@self invite <occ> /aux <host>}.
;
;   review_appointments   : the per-window appointment scan EVERY grown NPC runs.
;                           It closes appointments whose date has passed and emits
;                           an attend goal {@self goal {@self attend <occ>}} for
;                           any occasion due this window. (The attendance ACT that
;                           drains that goal arrives with Item 4; for now the goal
;                           is the queryable proof the pipeline works.)
;
; Validation (hsim <msb> mind <First> <Last>): a host shows {@self organize
; <dinner_party>} with the occasion carrying host/venue/date/hours, then an
; {@self goal {@self attend <dinner_party>}} in the month the date lands, and the
; organize/attend memories close once the date has passed.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; The host's planning decision (npc-think). ~2% of grown NPCs per simulated
; window decide to host; the occasion is set ~3 months ahead, an evening affair.
(hsim-npc-behaviour plan_gathering
  (long-term-think)
  (rng-stream behaviour)
  (roles
    (role @self (template grown)))
  (when (chance 0.02))
  (effects
    (plan-occasion @self [k dinner_party] (target {@self home ?}) 3 19 23 formal)))

; An IMPROMPTU supper (the INFORMAL channel): unlike the planned dinner party, this
; reaches only whoever the host is physically WITH right now - the co-present set at
; his current location (invite_copresent), nobody from the wider circle. Set for the
; same window (0 months ahead), an evening affair at home.
(hsim-npc-behaviour plan_impromptu_supper
  (long-term-think)
  (rng-stream behaviour)
  (roles
    (role @self (template grown)))
  (when (chance 0.015))
  (effects
    (plan-occasion @self [k dinner_party] (target {@self home ?}) 0 18 22 informal)))

; The per-window appointment review (npc-think): expire past appointments + emit
; an attend goal for any occasion due this window. Runs for every grown NPC.
(hsim-npc-behaviour review_appointments
  (long-term-think)
  (roles
    (role @self (template grown)))
  (effects
    (review-appointments @self attend)))
