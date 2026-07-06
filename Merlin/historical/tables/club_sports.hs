; ----------------------------------------------------------------------------
; club_sports.hs - which sport a club competes in, per org kind, and whether
; the contest is ridden/played by ENGAGED professionals (a kind-valued
; hire_role + a target string size) or by the members themselves (hire_role
; none). Consumed by (hold-sporting-events /sports club_sports ...).
; FIRST is-a MATCH WINS: author specific org kinds above the generic
; [k org club] fallback.
; ----------------------------------------------------------------------------

(define-table club_sports
  (fields org_kind sport hire_role hire_count)
  (record [k org race_club]   [k sport horse_racing] [k jockey] 4)
  (record [k org rugby_union] [k sport rugby]        none       0)
  (record [k org club]        [k sport cricket]      none       0))
