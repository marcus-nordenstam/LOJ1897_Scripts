; ----------------------------------------------------------------------------
; provisioning (think) - keeping the household LARDER stocked. The
; larder is THE KITCHEN (every inhabited home has one - world-gen aborts
; otherwise), and ONE cook per household owns the errand.
;
; THE COOK: any grown resident may claim the role; the home's PUBLIC bb `cook`
; marker is the synchronization (the buy-home `claimed` pattern) - the first
; claimant posts it, every later would-be claimant sees it and defers. The
; sitting cook re-posts the marker each cycle, so the ttl only clears a DEAD
; (or emigrated) cook and the household re-elects.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; ---- the cook election (public-bb synchronized, one per household) ----------
; Priority ladder: hired cook > wife > (oldest) daughter > husband/father >
; bachelor alone. Encoded as per-mind defer-gates, ties within a tier resolved
; first-come by the bb marker:
;   hired  - holds the cook job; claims outright.
;   woman  - any grown woman of the house, UNLESS her living mother shares the
;            home (the senior woman outranks her: wife > daughter in one gate)
;            or she is upper-class (her household hires its cook).
;   man    - only with no living spouse (his wife owns the kitchen) and no
;            believed daughter under his roof; covers widower and bachelor.
; Known approximations: "oldest" daughter is first-come among sisters, and a
; late-hired cook does not usurp a sitting family cook (first claim sticks).

(think claim-cook-hired
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
                           {@self job [k cook]}
              -{@self household-cook ?}
    (role ?home {@self home ?home}
      (when (bb-public-none ?home cook))
      (effects
        (bb-public-maintain ?home cook @self (cook_marker_ttl_cycles))
        (begin-belief {@self household-cook ?home})))))

(think claim-cook-woman
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
                           {@self gender [k female]}
              -{@self household-cook ?}
              -{@self class-situation [k upper]}
    (role ?home {@self home ?home}
      (no-role [k human] {@self mother ?norole} {?norole home ?home})
      (when (bb-public-none ?home cook))
      (effects
        (bb-public-maintain ?home cook @self (cook_marker_ttl_cycles))
        (begin-belief {@self household-cook ?home})))))

(think claim-cook-man
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
                           {@self gender [k male]}
              -{@self household-cook ?}
              -{@self spouse ?}
              -{@self class-situation [k upper]}
    (role ?home {@self home ?home}
      (no-role [k human] {@self child ?norole} {?norole gender [k female]} {?norole home ?home})
      (when (bb-public-none ?home cook))
      (effects
        (bb-public-maintain ?home cook @self (cook_marker_ttl_cycles))
        (begin-belief {@self household-cook ?home})))))

(think renew-cook
  (role ?home {@self household-cook ?home}
    (effects (bb-public-maintain ?home cook @self (cook_marker_ttl_cycles)))))
