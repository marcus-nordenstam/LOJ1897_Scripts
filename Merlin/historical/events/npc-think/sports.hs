; ----------------------------------------------------------------------------
; Sports (Phase 7; moved here from Phase 6 - sport needs clubs, and clubs are
; founded by Phase 7's club_founding).
;
; Once a year every athletic / racing club holds its competition. This is a
; ZERO-ROLE scheduled world sweep: a club is an org-document, not an NPC, so it
; is not cast as a role (the engine no longer enumerates a ?var role-0). The
; (hold-sporting-events) verb self-enumerates every club's articles and runs each
; club's contest from its roster - a document walk the .hse role layer cannot
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

(hsim-event sporting_event
  (schedule   (annually june))
  (rng-stream behaviour)

  (effects
    (hold-sporting-events
      /sports                 club_sports
      /jockey-age-min         (jockey_hire_age_min)
      /jockey-age-max         (jockey_hire_age_max)
      /trained-victory-weight (trained_victory_weight)
      /training-window-days   (training_window_days)
      /hire-position          apprentice)
    ))
