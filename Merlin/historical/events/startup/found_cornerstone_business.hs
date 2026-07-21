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

(include "../../definitions/roles.hs")

(npc-think found_cornerstone_business
  (startup)
  (rng-stream business)

  ; The not-already-employed gate is a CACHED self-gate filter: `employer` is
  ; exclusive, so a man who has already founded (here or in found_public_org this
  ; same startup pass) drops out of the set the instant he founds - each round
  ; skips the grown employed set at zero cost.
  (role @self 
              (not (believes {@self employer ?})))

  ; age gate stays live (non-belief op read).
  (when (>= (years-old @self) 25))

  (effects
    ; Found the business with its HEAD only (the proprietor); the emergent labour
    ; market staffs it from the unemployed over subsequent ticks.
    (for-each-table-record cornerstone_businesses
        (kind ?k) (head_pos ?hp) (class_floor ?cf)
      (if (and (not (any-org-of-kind ?k)) (class-at-least @self ?cf))
          (do (found-org-seq ?k ?hp)
              (break))))))
