; ----------------------------------------------------------------------------
; found_public_org (startup) - desire-driven founding of the town's public orgs.
;
; Same model as business_founding, applied to public institutions: each eligible
; adult, at cold-start, founds a still-NEEDED public org of their class. The
; public_orgs config table (historical/tables/) lists what the town needs + the
; founder's class floor per row. For each row: if the org is still needed (none
; founded yet) AND @self meets its class floor, @self founds it and STOPS - one
; org per founder, so the round-based startup pass spreads founders across orgs.
; When every needed org exists (or @self qualifies for none), the event no-ops.
;
; Round-based: the FIRST eligible adult founds each org; once it exists the demand
; gate (any-org-of-kind) turns false for everyone else. Replaces the C++
; bootstrap_orgs public-good block (retired).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event found_public_org
  (startup)
  (nl         "@self founds a public institution")
  (rng-stream business)

  (roles
    (role @self (template any_human)
                (>= (years-old @self) 25)))

  (effects
    (for-each-table-record public_orgs
        (kind ?k) (head_pos ?hp) (employee_count ?ec) (employee_role ?er) (class_floor ?cf)
      (if (and (not (any-org-of-kind ?k)) (class-at-least @self ?cf))
          (do (found-org :kind ?k :founder @self
                         :head-role ?hp :staff-role ?er :staff-count ?ec)
              (break))))))
