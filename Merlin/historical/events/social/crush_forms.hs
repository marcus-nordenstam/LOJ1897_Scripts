; ----------------------------------------------------------------------------
; crush_forms (PR-A-9, 2026-05-28).
;
; A romantic-openness NPC develops a directed infatuation toward someone
; they encounter through shared haunts. Mints {actor infatuation victim}
; in the actor's mind - read downstream by appraise_obsession (the
; emotion-driven deliberation branch) and by opportunity events that
; gate on standing infatuation. The attachment_pursuit pressure family
; (planned) will eventually consume the infatuation belief to amplify
; specific deliberation branches.
;
; Substrate-rooted: no chance-primary pick. Actor gates on (openness x
; enthusiasm x compassion) trait product (people open to new feeling,
; outgoing, and warm) AND no current infatuation / lover / spouse
; (single people develop crushes; the already-attached don't refresh).
; Victim binds via personally-knows (you develop a crush on someone you
; have actually met) plus an age-band check. The activity-lanes co-presence
; sweep seeds the acquaintance ties this reads - strangers who keep crossing
; paths at a venue become acquaintances first, then crush material (a one-
; cycle lag). This replaced the old frequents-overlap haunt proxy when the
; static frequents seed was retired (activity-lanes L8).
;
; Schedule: monthly. The infatuation belief, once minted, persists
; through normal belief decay until a romantic event (betrothal /
; advantageous_match / crush_lapses-PLANNED) supersedes it. No
; transient_marker cooldown - a person can carry only one infatuation
; per @excl on the verb-state, so re-mint just refreshes the same
; belief (mx_begin_belief's @excl handling).
;
; Wait - infatuation in States.mon (line 94) is NOT declared @excl.
; That's intentional: an NPC may carry interest in multiple targets
; over time. The cooldown is implicit in the not-already-infatuated
; gate - a person with a held infatuation skips the event.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event crush_forms
  (nl       "?actor forms a crush on ?victim")
  (kind     _crush_forms)
  (schedule (monthly))
  (band      afternoon)
  (rng-stream incidents)

  (roles
    ; NB: inline role filters use the EXPLICIT role var (?actor / ?victim), not
    ; ?self. A `?self` in an inline filter that also references the OTHER role
    ; (the age-gap below) mis-compiles and silently drops the trailing chance
    ; residue (hse engine quirk found 2026-06-06) - so the gate would never fire.
    (role ?actor  (template any_human)
                  (>= (years-old ?actor) 14)
                  (<= (years-old ?actor) 50)
                  ; infatuation retired:
                  ; directed attraction is the one-sided attraction stance SCALAR
                  ; (fancy/desire/crave verb-states). The passive standing-pass
                  ; mate-value driver is too gated to fire in the small-town repro
                  ; (opposite-sex AND non-kin AND adult AND centrality>3 at once ->
                  ; ~0 eligible), so THIS event is the active igniter: a
                  ; romantically-open single not already deep in a crush nudges
                  ; attraction toward a known, age-appropriate, opposite-sex person
                  ; (effects below). The standing pass then maintains/deepens it for
                  ; believe_about'd contacts; repeated fires push fancy -> desire.
                  (not (believes ?actor {@self desire ?}))
                  (not (believes ?actor {@self lover ?}))
                  (not (believes ?actor {@self spouse ?}))
                  (chance (* 0.30
                             (attr ?actor openness)
                             (attr ?actor enthusiasm)
                             (attr ?actor compassion))))
    (role ?victim (template any_human)
                  (not (= ?victim ?actor))
                  (>= (years-old ?victim) 14)
                  (<= (years-old ?victim) 60)
                  (personally-knows ?actor ?victim)
                  ; No incestuous crush: exclude blood relatives (reliable kin
                  ; cross-pair BITSET, not a two-bound believes). Without this a
                  ; near-age opposite-sex sibling/cousin is crush-eligible and
                  ; would feed fancy -> love_match (kin-marriage).
                  (not (kin ?actor ?victim))
                  ; Opposite-sex (the period-default hetero majority; attr reads,
                  ; not a two-bound believes, so it gates reliably). Same-sex /
                  ; bi pulls are left to the orientation-correct standing-pass
                  ; driver (orient_admits).
                  (not (= (attr ?victim gender) (attr ?actor gender)))
                  (<= (- (years-old ?actor) (years-old ?victim))  10)
                  (>= (- (years-old ?actor) (years-old ?victim)) -10)
                  (chance 0.20)))

  (effects
    ; Feed the one-sided attraction scalar:
    ; a crush is a strong directed pull. 0.5 crosses the `fancy` band (0.20) in
    ; one fire and sustains ~a year against the sleep decay (0.938); repeated
    ; fires deepen toward `desire` (0.60). The `fancy` verb-state belief is what
    ; courtship (betrothal / advantageous_match) now reads.
    (nudge-stance ?actor ?victim attraction 0.5)
    (log _crush_forms ?actor)))
