; ----------------------------------------------------------------------------
; club_sports.hs - which sport a club competes in, per org kind. Read by the
; club organiser's annual meet (events/npc-act/hold_meet.hs) via
;   (lookup club_sports org_kind ?club_kind sport)
; an EXACT key match on the club's org kind (the kind it was founded with,
; read off its articles). Author one row per foundable club kind - the club
; founding lane (events/npc-act/club_found_errand.hs) rolls race_club /
; athletic_club, so those are the rows that matter; add a row when a new club
; kind becomes foundable (a kind with no row simply holds no contest).
;
; WHO competes and WHO wins is decided in hold_meet.hs from OBSERVABLE state
; (roster co-presence + assertiveness), not from this table: the table carries
; only the sport label, which is pure authored content.
; ----------------------------------------------------------------------------

(define-table club_sports
  (fields org_kind sport)
  (record [k org race_club]     [k sport horse_racing])
  (record [k org athletic_club] [k sport cricket]))
