; ----------------------------------------------------------------------------
; Clubs and societies (Phase 7; the join / resign / found cycle moved here
; from Phase 6 - club_joining and club_resignation need clubs to exist, and
; clubs are created only by club_founding).
;
; A club is an `org` (an athletic / race club) anchored on its
; articles_of_incorporation, exactly like a workplace - but its roster carries
; `member_of` beliefs rather than employment. The found-club-seq macro (founding.hs)
; founds it; the register-member / unregister-member verbs (hsim_org_lifecycle) own
; its roster.
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
  (long-term-think)
  (rng-stream behaviour)

  ; Clubs are founded by a settled adult of some standing - an employed man
  ; over thirty, not already in a club. (The class-floor the plan names is carried
  ; by the `employer` gate: a man with a post is a man of standing.) The founder
  ; is the sole deliberator (@self); age + chance are non-belief ops -> (when).
  (roles
    (role @self (template old_human)
                (believes {@self employer ?})
                (not (believes {@self member_of ?}))))

  (when (and (>= (years-old @self) 30)
             (chance 0.0033)))

  ; SPLIT (Item 5): the npc-think - the decision to found a club. Mints {@self
  ; goal {@self found_club}}; the npc-act (club_found_errand.hs) takes the founder
  ; out to found it (found-club-seq acquires the clubhouse + enrols him). A new club
  ; starts with just its founder; members trickle in via club_joining.
  (effects
    (begin-goal {@self found_club})))

; --- club_joining: an adult joins an existing club --------------------------
;; Clubs gate on character and class: a scandalous or disreputable member is
;; blackballed; the matching pool is restricted to the candidate's class
;; band (a working man does not join a gentlemen's club). Permissive when the
;; cached belief is missing - a new adult appraised before december still
;; reads @fail and is not excluded by the (not (= ...)) form.
(hsim-event club_joining
  (sim-window-start)
  (rng-stream behaviour)

  (roles
    ; An adult who belongs to fewer than two clubs takes up another. SELF-POV
    ; (telepathy purge CAT-2): @self reads his OWN repute (belief-pure). The
    ; age + club-count + chance gates are non-belief ops -> (when).
    (role @self (template old_human)
                (not (believes {@self repute [k scandalous]}))
                (not (believes {@self repute [k disreputable]})))
    ; A KNOWN club (@self learned it at new_job_orientation). Belief-pure + cached:
    ; the omniscient org-kind-is-a doc read is gone. The own-class match (below)
    ; binds the founder - a secondary var the per-candidate cache cannot - so it
    ; lives in (when), evaluated live per firing.
    (role ?club_org (template known_org)
                    (believes {?this isa [k org club]})))

  ; A man joins a club of his OWN class band. The club's tier is read as @self's
  ; view of the founder's class (3-arg (situation ... @self), banded in via
  ; believe_about) - a positive match, so @self only joins a club whose founder he
  ; actually knows (an unfamiliar founder's class @fails the match). Binds ?founder
  ; off @self's {?club_org founder ?founder} belief (minted at orientation).
  ; chance + age + club-count moved here from the @self role (non-belief gates).
  (when (and (chance 0.005)
             (>= (years-old @self) 18)
             (< (count-beliefs @self member_of) 2)
             (believes {?club_org founder ?founder})
             (= (target {?founder class_situation})
                (target {@self class_situation}))))

  ; SPLIT (Item 5): the npc-think - the decision to join. Mints {@self goal
  ; {@self join_club <articles>}}; the npc-act (club_join_errand.hs) sends the member
  ; to the clubhouse and registers him there. RE-TARGET: one standing join goal,
  ; replaced each fire (per-target idempotency would stack a distinct goal per
  ; club's articles; a blocking gate would deadlock on an unreachable club).
  ; Focus = the club's articles, recovered from @self's {?club_org record ?art} belief.
  (effects
    (end-goal {@self join_club})
    (begin-goal {@self join_club (target {?club_org record})})))

; club_gathering RETIRED (place-and-time reframe, Section 4.8 P2b): club members
; are now drawn to the clubhouse by the band itinerary's SOCIAL lane (members
; route to building social_clubhouse), and the clubhouse's afforded events
; (gossip / gamble / confide / court / outdo) fire among the co-present members
; via resolve_affordances - so a standalone monthly roster-walk that registered
; clubhouse co-presence is now redundant double-routing.

; --- club_resignation: an adult resigns from a club -------------------------
(hsim-event club_resignation
  (long-term-think)
  (rng-stream behaviour)

  ; The resigning member is the sole deliberator (@self); chance -> (when).
  (roles
    (role @self (template old_human)
                (believes {@self member_of ?})))

  (when (chance 0.004))

  ; SPLIT (Item 5): the npc-think - the decision to resign. Mints {@self goal
  ; {@self resign_club}}; the npc-act (club_resign_errand.hs) sends the member to
  ; a clubhouse and unregisters him there (unregister-member resolves his own club).
  (effects
    (begin-goal {@self resign_club})))
