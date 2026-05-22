; ----------------------------------------------------------------------------
; public_orgs.hsc
;
; Public-good organisations founded at sim start, parallel to the founder
; NPCs. The hsim bootstrap pass reads this catalog and, for every org whose
; era_min has been reached, picks a building of the matching kind and a head
; NPC of the head_pos's class floor, founds the org via hsim_org_lifecycle,
; and hires the listed employees under it.
;
; Form:
;   (public_org <id>
;     (kind      <org-kind>)             ; an org sub-kind from Concepts.mon
;     (era_min   <year>)                 ; founded only when start_year >= this
;     (head_pos  <job-kind>)             ; the head / principal role
;     (employees <count> <role> ...))    ; count/role pairs hired under the head
;
; Org kinds MUST match Concepts.mon (org > gov|edu|com > ...); job kinds MUST
; match Concepts.mon (org_pos > job > ...) and occupations.hsc.
; ----------------------------------------------------------------------------

(public_org parish_church
  (kind      church)
  (era_min   1700)
  (head_pos  priest)
  (employees 2 clerk))

(public_org cottage_hospital
  (kind      hospital)
  (era_min   1700)
  (head_pos  physician)
  (employees 4 nurse))

(public_org post_office
  (kind      agency)
  (era_min   1700)
  (head_pos  clerk)
  (employees 3 clerk))

(public_org parish_school
  (kind      state_school)
  (era_min   1700)
  (head_pos  principal)
  (employees 4 teacher))

(public_org land_registry
  (kind      land_registry)
  (era_min   1700)
  (head_pos  clerk)
  (employees 2 clerk))

(public_org company_registry
  (kind      company_registry)
  (era_min   1840)
  (head_pos  clerk)
  (employees 2 clerk))
