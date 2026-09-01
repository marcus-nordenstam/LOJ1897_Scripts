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

(include "../../definitions/roles.mc")

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
  ; head-of-non-household-org job and drops out of the set the instant he founds.
  ; A salaried worker does not found either. (The household is separately capped
  ; by found_household's own throttle.)
  (role @self -{@self job.salary ?}
              -{@self job [k head-of-non-household-org]})

  ; Age, plus the DEMAND gate: a charter @self could actually take up must still be
  ; headless. Without the second test an adult who qualifies for nothing left re-fires a
  ; fruitless scan every startup round and the pass never quiesces.
  (when (and (>= (years-old @self) 25)
             (substantial (charter-for @self))))

  (effects
    ; TAKE UP a charter the town filed at seeding and nobody heads yet. The org already
    ; exists on paper - premises, articles, staff book - so founding it is stepping into
    ; its open head seat. The emergent labour market (employment.hs `hiring` ->
    ; hire_errand -> hire-matched) staffs it from the unemployed over subsequent ticks.
    (for-each-row public_orgs
        [/kind ?k] [/head-pos ?hp] [/class-floor ?cf]
      [/headless-charter ?k]: ?art
      (if (and (substantial ?art)
               (class-at-least @self ?cf))
          (then (take-up-charter ?art ?hp)
              (break))))))
