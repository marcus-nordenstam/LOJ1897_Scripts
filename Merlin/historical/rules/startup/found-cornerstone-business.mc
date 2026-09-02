; ----------------------------------------------------------------------------
; found_cornerstone_business (startup) - cold-start founding of the town's seed
; businesses (bank / solicitor / apothecary / pub / grocer).
;
; The business analogue of found_public_org: at cold-start each eligible adult
; founds a still-MISSING cornerstone business of their class and STOPS (one org
; per founder, so the round-based startup pass spreads founders across orgs). The
; cornerstone_businesses table (historical/tables/) lists what the town opens with
; + the founder's class floor per row. Once a kind exists the demand gate
; (any-org-of-kind) turns false for everyone else; the emergent homeostat
; (business.hs) founds the rest on demand thereafter.
;
; Replaces the C++ bootstrap_orgs cornerstone loop (retired): founding now runs
; through found-org-seq like every other org, so there is no C++ found_org/hire.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")

(npc-think found_cornerstone_business
  (startup)
  (rng-stream business)
  ; Serialize founding: one NPC reads the org registry, founds a still-missing
  ; cornerstone and appends its kind before the next reads it, so two founders
  ; can never both see count 0 for the same kind and double-found it.
  (lock-rule)

  ; CACHED self-gate filters. THE FOUNDING CAP: an NPC heads at most ONE
  ; non-household org - a man who has already founded (here or in found_public_org
  ; this same startup pass) holds a head-of-non-household-org job and drops out of
  ; the set the instant he founds. A salaried worker does not found either. (The
  ; household is separately capped by found_household's own throttle.)
  (role @self -{@self job.salary ?}
              -{@self job [k head-of-non-household-org]})

  ; Age, plus the DEMAND gate: a charter @self could actually take up must still be
  ; headless. Without the second test an adult who qualifies for nothing left re-fires a
  ; fruitless scan every startup round and the pass never quiesces.
  (when (and (>= (years-old @self) 25)
             (substantial (charter-for @self))))

  (effects
    ; TAKE UP a charter the town filed at seeding and nobody heads yet - premises,
    ; articles and staff book already exist, only the proprietor's seat is open. The
    ; emergent labour market staffs it from the unemployed over subsequent ticks.
    (for-each-row cornerstone_businesses [/kind ?k] [/head-pos ?hp] [/class-floor ?cf] [/headless-charter ?k]: ?art
      (if (and (substantial ?art)
               (class-at-least @self ?cf))
          (then (take-up-charter ?art ?hp)
              (break))))))
