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

(include "../../../definitions/roles.hs")

; club_founding CREATES the clubhouse venue (so it cannot itself be place-lane),
; and club_joining/resignation are roster acts.
; (Future: bind club_joining to the clubhouse the member is actually in - needs
; the affordance resolver to pass the venue's club context.)

; --- club_founding: an established adult founds a club with two members ------
(npc-think club_founding
  (cooldown 1 m)
  (rng-stream behaviour)

  ; Clubs are founded by a settled adult of some standing - an employed man over
  ; thirty. (The class-floor the plan names is carried by the `job.salary` gate: a man
  ; with a paid post is a man of standing.) The founder is the sole deliberator (@self).
  (role @self (old_human @self))
  (role ?job {@self job ?job}
             {?job salary ?})          ; threaded job.salary existence

  ; MAINTENANCE: the decision OWNS the found_club goal end to end. The (chance) is an
  ; ONSET roll - (latch-eval) rolls it at the fire and LOCKS it once holding, so the
  ; held re-check never re-rolls it (it re-rolls each month until it lands). (not member_of)
  ; is the CONTINUOUS gate: while he is still clubless the goal stands; the moment
  ; found-club-seq enrols him ({@self member_of}) it falls and the goal ends. The act never
  ; ends the goal.
  (when (and (>= (years-old @self) 30)
             (none {@self member_of ?})
             (latch-eval (chance 0.0033))))

  ; SPLIT (Item 5): the npc-action (club_found_errand.hs) takes the founder out to found it
  ; (found-club-seq acquires the clubhouse + enrols him). found_club_go routes; there is no
  ; dwell - the goal is minted here and leaf-promotes to the act once he is at the pub.
  (utility errand)
  (effects       (begin-goal {@self FOUND_CLUB}))
  (cease-effects (end-goal   {@self FOUND_CLUB})))

; --- club_joining: an adult joins an existing club --------------------------
;; Clubs gate on character and class: a scandalous or disreputable member is
;; blackballed; the matching pool is restricted to the candidate's class
;; band (a working man does not join a gentlemen's club). Permissive when the
;; cached belief is missing - a new adult appraised before december still
;; reads @fail and is not excluded by the (not (= ...)) form.
(npc-think club_joining
  (cooldown 1 m)
  (rng-stream behaviour)

  ; An adult who belongs to fewer than two clubs takes up another. SELF-POV
  ; (telepathy purge CAT-2): @self reads his OWN repute (belief-pure). The
  ; age + club-count + chance gates are non-belief ops -> (when).
  (role @self (old_human @self)
              (none {@self repute [k scandalous]})
              (none {@self repute [k disreputable]}))
  ; A KNOWN club (@self learned it at new_job_orientation). Belief-pure + cached:
  ; the omniscient org-kind-is-a doc read is gone. The founder is produced-restricted
  ; off {?club_org founder ?founder} in the role; the own-class match (below) reads
  ; it live in (when).
  (role ?club_org (known_org ?club_org)
                  [k org club]
                  {?club_org founder ?founder})   ; produced-restricted: ?founder off the club

  ; A man joins a club of his OWN class band. The club's tier is read as @self's
  ; OWN belief of the founder's class ((any {?founder class_situation}).target) - a
  ; positive match, so @self only joins a club whose founder he
  ; actually knows (an unfamiliar founder's class @fails the match). ?founder is
  ; produced off @self's {?club_org founder ?founder} belief (minted at orientation)
  ; in the ?club_org role. chance + age + club-count are non-belief gates in (when).
  ; MAINTENANCE: the decision OWNS the join_club goal end to end. (chance) is the ONSET
  ; roll - (latch-eval) rolls it at the fire and LOCKS it once holding (it re-rolls
  ; each month until it lands). (not member_of ?club_org) is the CONTINUOUS completion
  ; gate: while he is not yet on THIS club's roster the goal stands; the moment
  ; join_club_act enrols him (register-member mints {@self member_of ?club_org}) it falls
  ; and the goal ends. The act never ends the goal.
  (when (and (>= (years-old @self) 18)
             (< (count (every {@self member_of ?})) 2)
             (none {@self member_of ?club_org})
             (= (any {?founder class_situation}).target
                (any {@self class_situation}).target)
             (latch-eval (chance 0.005))))

  ; SPLIT (Item 5): the npc-think - the decision to join. Mints {@self goal {@self
  ; join_club <articles>}} (focus = the club's articles, {?club_org record}); the npc-action
  ; (club_join_errand.hs) sends the member to the clubhouse and registers him there.
  (utility errand)
  (effects (maintain-proposal {@self join_club (any {?club_org record}).target})))

; club_gathering RETIRED (place-and-time reframe, Section 4.8 P2b): club members
; are now drawn to the clubhouse by the band itinerary's SOCIAL lane (members
; route to building social_clubhouse), and the clubhouse's afforded rules
; (gossip / gamble / confide / court / outdo) fire among the co-present members
; via resolve_affordances - so a standalone monthly roster-walk that registered
; clubhouse co-presence is now redundant double-routing.

; --- club_resignation: an adult resigns from a club -------------------------
(npc-think club_resignation
  (cooldown 1 m)
  (rng-stream behaviour)

  ; The resigning member is the sole deliberator (@self).
  (role @self (old_human @self))

  ; MAINTENANCE: the decision OWNS the resign_club goal end to end. (chance) is the ONSET
  ; roll - (latch-eval) locks it once holding. (believes member_of) is the CONTINUOUS
  ; completion gate: while he still holds a membership the goal stands; the moment
  ; resign_club_act unregisters him (unregister-member ENDS {@self member_of}) it falls and
  ; the goal ends. The act never ends the goal.
  (when (and (any {@self member_of ?})
             (latch-eval (chance 0.004))))

  ; SPLIT (Item 5): the npc-think - the decision to resign. Mints {@self goal {@self
  ; resign_club}}; the npc-action (club_resign_errand.hs) sends the member to a clubhouse and
  ; unregisters him there (unregister-member resolves his own club).
  (utility errand)
  (effects (maintain-proposal {@self resign_club})))
