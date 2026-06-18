; ----------------------------------------------------------------------------
; Clubs and societies (Phase 7; the join / resign / found cycle moved here
; from Phase 6 - club_joining and club_resignation need clubs to exist, and
; clubs are created only by club_founding).
;
; A club is an `org` (an athletic / race club) anchored on its
; articles_of_incorporation, exactly like a workplace - but its roster carries
; `member_of` beliefs rather than employment. The found-org / register-member /
; unregister-member verbs (hsim_org_lifecycle) own that roster.
;
; Clubs may form from the sim start (1700) - no era gate - so club premises and
; their co-present membership exist throughout. join and resign run
; unconstrained once clubs exist.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

; EMERGENT (Section 4.11): the three club events are fired by the per-NPC
; emergent pass (no (schedule)). club_founding CREATES the clubhouse venue (so it
; cannot itself be place-lane), and club_joining/resignation are roster acts; all
; three fire MONTHLY now, so each (chance) is /12 to hold the annual volume.
; (Future: bind club_joining to the clubhouse the member is actually in - needs
; the affordance resolver to pass the venue's club context.)

; --- club_founding: an established adult founds a club with two members ------
(hsim-event club_founding
  (nl         "?founder founds a club")
  (rng-stream behaviour)

  (roles
    ; Clubs are founded by a settled adult of some standing - an employed man
    ; over thirty, not already in a club. (The class-floor the plan names is
    ; carried by the `employer` gate here: a man with a post is a man of
    ; standing.)
    (role ?founder (template old_human)
                   (>= (years-old ?this) 30)
                   (believes ?this {@self employer ?})
                   (not (believes ?this {@self member_of ?}))
                   (chance 0.0033)))

  ; SPLIT (Item 5): the npc-think - the decision to found a club. Mints {?founder
  ; goal {?founder found_club}}; the npc-act (club_found_errand.hs) takes the founder
  ; out to found it (found-org spawns the clubhouse + enrols him). The two founding
  ; members the old event seeded are dropped - members now trickle in via
  ; club_joining, so a new club simply starts with its founder.
  (effects
    (goal ?founder found_club)))

; --- club_joining: an adult joins an existing club --------------------------
;; Clubs gate on character and class: a scandalous or disreputable member is
;; blackballed; the matching pool is restricted to the candidate's class
;; band (a working man does not join a gentlemen's club). Permissive when the
;; cached belief is missing - a new adult appraised before december still
;; reads @fail and is not excluded by the (not (= ...)) form.
(hsim-event club_joining
  (nl         "?member joins a club")
  (rng-stream behaviour)

  (roles
    ; An adult who belongs to fewer than two clubs takes up another.
    (role ?member (template old_human)
                  (>= (years-old ?this) 18)
                  (< (count-beliefs ?this member_of) 2)
                  (not (= (situation ?this repute) [k scandalous]))
                  (not (= (situation ?this repute) [k disreputable]))
                  (chance 0.005))
    (role ?club_articles (template org_articles)
                         (org-kind-is-a ?this [k org club])
                         (= (situation (org-founder ?this) class_situation)
                            (situation ?member class_situation))))

  ; SPLIT (Item 5): the npc-think - the decision to join. Mints {?member goal
  ; {?member join_club ?club_articles}}; the npc-act (club_join_errand.hs) sends the
  ; member to the clubhouse and registers him there. (goal) is idempotent.
  (effects
    (goal ?member join_club ?club_articles)))

; club_gathering RETIRED (place-and-time reframe, Section 4.8 P2b): club members
; are now drawn to the clubhouse by the band itinerary's SOCIAL lane (members
; route to building social_clubhouse), and the clubhouse's afforded events
; (gossip / gamble / confide / court / outdo) fire among the co-present members
; via resolve_affordances - so a standalone monthly roster-walk that registered
; clubhouse co-presence is now redundant double-routing.

; --- club_resignation: an adult resigns from a club -------------------------
(hsim-event club_resignation
  (nl         "?member resigns from a club")
  (rng-stream behaviour)

  (roles
    (role ?member (template old_human)
                  (believes ?this {@self member_of ?})
                  (chance 0.004)))

  ; SPLIT (Item 5): the npc-think - the decision to resign. Mints {?member goal
  ; {?member resign_club}}; the npc-act (club_resign_errand.hs) sends the member to
  ; a clubhouse and unregisters him there (unregister-member resolves his own club).
  (effects
    (goal ?member resign_club)))
