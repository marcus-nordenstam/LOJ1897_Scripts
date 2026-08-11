; ----------------------------------------------------------------------------
; putter - the monthly home round AND its chores. Where `explore` DISCOVERS
; unperceived rooms (env-attr driven), putter RE-CHECKS the rooms @self already
; KNOWS ({home room room} beliefs), so perception refreshes what is inside them.
; The daily/regular chores fold into this ONE round: puttering into a room that
; holds a mail stack, @self reads the mail there and then - no separate lagging
; read_mail lane, and co-presence is free (you are already standing in the room).
;
;   want_putter  : monthly, at home -> begin a putter round.
;   putter_go    : walk to a known room not yet visited THIS round (tracked by
;                  /caused_by ?putter; first-match walks them one at a time).
;   putter_scan  : CHORE - puttered into a room whose mail stack I have not
;                  scanned this round -> scan it (lift my addressed letters).
;   putter_read  : CHORE - holding a letter -> read it (the read act drops it).
;   putter_done  : every known room re-visited AND no letter still in hand -> end.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think want_putter
  (lock-rule)
  (cooldown 1 m)
  (role ?home {@self home ?home})
  (when (in-building ?home))
  (utility 40)
  (effects (begin-proposal {@self putter ?home})))

(npc-think putter_go
  (task {@self putter ?home}:?putter)
  (role ?room {?home room ?room}
        (none {@self go ?room /past /caused_by ?putter})
        (select (policy first-match)))
  (utility 41)
  (effects (maintain-proposal {@self go ?room})))

; CHORE - mail: puttered into a room whose mail stack I know and have NOT scanned
; this round -> scan it (the action lifts every letter addressed to @self into hand).
(npc-think putter_scan
  (task {@self putter ?home}:?putter)
  (role ?stack [k mail_stack] {?stack location ?room})
  (when (and (in-room ?room)
             (none {@self scan_mail ?stack /past /caused_by ?putter})))
  (utility 42)
  (effects (maintain-proposal {@self scan_mail ?stack})))

; CHORE - hiding-spot caches: for each cache in the room @self is puttering in,
; either DISCOVER it (if @self does not know it) or RE-CHECK it (if @self does).
; Discovery is the curious stumbling on a covert affair's cache (a loose floorboard,
; a book that sits wrong) - a spouse / grown child / resident staff. Re-check is the
; owner's routine surveillance of their OWN hiding-spot. Both read what is stashed
; (idempotent - re-learns nothing already read), and the reader's beliefs follow
; from the letters via the read/adopt seam - never telepathy, and never a sweep of
; caches @self is not standing at (folds cohabitant_cache_discovery + read_secret_letters).
(npc-think putter_cache
  (task {@self putter ?home})
  (role ?room {?home room ?room})
  (when (in-room ?room))
  (effects
    (for-each ?cache (attr-values ?room parts [k interior_space hiding_spot])
      (if (none {@self hiding_spot ?cache})
          (then                                       ; UNKNOWN: chance to stumble on it
            (if (chance (* 0.006 (+ 1.0 (attr @self openness))))
                (then
                  (begin-belief {@self hiding_spot (internalize ?cache)})
                  (read-cache ?cache))))
          (else (read-cache ?cache))))))            ; KNOWN: routine re-check

; CHORE - read: holding a letter -> read it (the read act ingests the writing and
; sets the letter down). Higher utility than the walk, so a puttered-in room's mail
; is finished before moving on.
(npc-think putter_read
  (task {@self putter ?home})
  (role ?h {@self hand ?h})
  (role ?ltr [k letter] {?h control ?ltr})
  (utility 43)
  (effects (maintain-proposal {@self read ?ltr})))

(npc-think putter_done
  (task {@self putter ?home}:?putter)
  (when (and (>= (count (every {@self go ? /past /caused_by ?putter}))
                 (count (every {?home room ?})))
             (none {@self hand.control [k letter]})))
  (effects (set-outcome ?putter succ)))
