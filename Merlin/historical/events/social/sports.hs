; ----------------------------------------------------------------------------
; Sports (Phase 7; moved here from Phase 6 - sport needs clubs, and clubs are
; founded by Phase 7's club_founding).
;
; Once a year every athletic / racing club holds its competition. The single
; sporting_event casts the club; the (hold-sporting-event ...) verb does the
; rest from the club's roster - a document walk the .hse role layer cannot
; express:
;   - every alive roster member gains a {participated_in <sport>} belief;
;   - one member is the victor and gains a {won <sport>} belief
;     (notable_victory, folded in - `won` feeds the prestige dimension);
;   - with a chance the victor and one bested member fall into a mutual
;     `enemy` rivalry (sporting_rivalry, folded in).
;
; The sport is read from the club's kind: a race_club runs horse_racing, a
; rugby_union plays rugby, a generic athletic club plays cricket.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event sporting_event
  (nl         "a sporting club holds its annual competition")
  (kind       _sporting_event)
  (schedule   (annually june))
  (rng-stream behaviour)

  (roles
    (role ?club_articles (template org_articles)
                         (org-kind-is-a ?self club)))

  (effects
    (hold-sporting-event :articles ?club_articles)
    (log _sporting_event ?club_articles)))
