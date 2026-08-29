; ----------------------------------------------------------------------------
; found_public_org (startup) - desire-driven founding of the town's public orgs.
;
; Same model as business_founding, applied to public institutions: each eligible
; adult, at cold-start, founds a still-NEEDED public org of their class. The
; public_orgs config table (historical/tables/) lists what the town needs + the
; founder's class floor per row. For each row: if the org is still needed (none
; founded yet) AND @self meets its class floor, @self founds it and STOPS - one
; org per founder, so the round-based startup pass spreads founders across orgs.
; When every needed org exists (or @self qualifies for none), the rule no-ops.
;
; Round-based: the FIRST eligible adult founds each org; once it exists the demand
; gate (any-org-of-kind) turns false for everyone else. Replaces the C++
; bootstrap_orgs public-good block (retired).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-think found_public_org
  (startup)
  (rng-stream business)
  ; Serialize founding: one NPC reads the org registry, founds a still-needed
  ; org and appends its kind before the next reads it, so two founders can never
  ; both see count 0 for the same kind and double-found it.
  (lock-rule)

  ; CACHED self-gate filters. THE FOUNDING CAP: an NPC heads at most ONE
  ; non-household org - a man who has already founded (here or in
  ; found_cornerstone_business this same startup pass) holds a
  ; head_of_non_household_org job and drops out of the set the instant he founds.
  ; A salaried worker does not found either. (The household is separately capped
  ; by found_household's own throttle.)
  (role @self (not {@self job.salary ?})
              (not {@self job [k head_of_non_household_org]}))

  ; age gate stays live (non-belief op read).
  (when (>= (years-old @self) 25))

  (effects
    ; Found the org with its HEAD only; the emergent labour market (employment.hs
    ; `hiring` -> hire_errand -> hire-matched) staffs it from the unemployed over
    ; subsequent ticks. employee_count / employee_role are no longer read here.
    (for-each-row public_orgs
        (kind ?k) (head_pos ?hp) (class_floor ?cf)
      (if (and (= (count-orgs-isa ?k) 0)
               (class-at-least @self ?cf))
          (then (found-org-seq ?k ?hp)
              (break))))))
