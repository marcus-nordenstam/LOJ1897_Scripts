; ----------------------------------------------------------------------------
; club_sports.hs - which sport a club competes in, per org kind. Read by the
; club organiser's annual meet (rules/npc-act/hold-meet.hs) via
;   (table-match club_sports org-kind ?club_kind sport ?sport)
; an EXACT key match on the club's org kind (the kind it was founded with,
; read off its articles). Author one row per foundable club kind - the club
; founding lane (rules/npc-act/club_found_errand.hs) rolls race-club /
; athletic-club, so those are the rows that matter; add a row when a new club
; kind becomes foundable (a kind with no row simply holds no contest).
;
; WHO competes and WHO wins is decided in hold-meet.hs from OBSERVABLE state
; (roster co-presence + assertiveness), not from this table: the table carries
; only the sport label, which is pure authored content.
; ----------------------------------------------------------------------------

(define-table club_sports
  (fields org-kind sport)
  (record [k org race-club]     [k sport horse-racing])
  (record [k org athletic-club] [k sport cricket]))
