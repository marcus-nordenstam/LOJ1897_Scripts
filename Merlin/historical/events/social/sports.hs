; ----------------------------------------------------------------------------
; Sports (Phase 7; moved here from Phase 6 - sport needs clubs, and clubs are
; founded by Phase 7's club_founding).
;
; Once a year every athletic / racing club holds its competition. The single
; sporting_event casts the club; the (hold-sporting-event ...) verb does the
; rest from the club's roster - a document walk the .hse role layer cannot
; express:
;   - every competitor gains a {participated_in <sport>} belief;
;   - one competitor is the victor and gains a {won <sport>} belief
;     (notable_victory, folded in - `won` feeds the prestige dimension);
;   - with a chance one bested competitor resents the victor and records the
;     {victor outdo bested} contest anchor (sporting_rivalry, folded in).
;
; The sport is read from the club's kind: a race_club runs horse_racing, a
; rugby_union plays rugby, a generic athletic club plays cricket.
;
; WHO competes is sport-scoped: horse_racing is ridden ONLY by professional
; jockeys - roster entries the club employs under the `job jockey` occupation
; (members attend the meet, they never ride; the verb tops the club's string
; of riders up to its headcount from the jobless lower-class male pool before
; each meet). Cricket / rugby are played by the male members themselves.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event sporting_event
  (nl         "a sporting club holds its annual competition")
  (kind [k _sporting_event])
  (schedule   (annually june))
  (band      afternoon)
  (rng-stream behaviour)

  (roles
    (role ?club_articles (template org_articles)
                         (org-kind-is-a ?self [k org club])))

  (effects
    (hold-sporting-event :articles ?club_articles)
    (log _sporting_event ?club_articles)))
