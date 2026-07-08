; ----------------------------------------------------------------------------
; cohabitant_cache_discovery.hs (WS2.8) - stumbling on someone else's cache.
;
; A hiding-spot cache is a physical space in a shared home (a child of a
; bedroom / study - see make_secret_cache). The people who LIVE there - the
; spouse, grown children, resident staff - occasionally find it: a loose
; floorboard underfoot, a book that sits wrong on the shelf. Discovery is the
; slow leak in every covert-affair conduct: the cached correspondence is read
; the moment the cache is found, and the reader's own beliefs (the affair, the
; plot) follow from the letters via the ordinary read/adopt seam - never by
; telepathy.
;
; PURE .hs over composable ops:
;   - the home binds from @self's own {@self home ?} belief; its rooms and
;     their hiding-spot children walk via the `parts` child hierarchy
;     ((attr-values .. parts [k ..]) - the spaces-as-hierarchy rule);
;   - (not (believes {@self hiding_spot ?cache})) skips caches @self already
;     knows - their own, and any they found before;
;   - the monthly find chance is small and scales with openness (the curious
;     poke about); a household of two or three searchers finds a cache in a
;     few years, which is the drama pacing the affair arc wants;
;   - on discovery: {@self hiding_spot ?cache} - the finder KNOWS the spot
;     now, so read_secret_letters' routine puts it under standing
;     surveillance (they re-check it every window, like any spot they know) -
;     and (read-cache ?cache) reads everything currently stashed inside.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour cohabitant_cache_discovery
  (long-term-think)
  (rng-stream incidents)

  (roles
    (role @self (template any_human)))

  ; Only home-holders can stumble about their own home.
  (when (bind {@self home ?home}))

  (effects
    (for-each ?room (attr-values ?home parts [k interior_space room])
      (for-each ?cache (attr-values ?room parts [k interior_space hiding_spot])
        (if (and (not (believes {@self hiding_spot ?cache}))
                 (chance (* 0.006 (+ 1.0 (attr @self openness)))))
            (do
              (begin-belief {@self hiding_spot ?cache})
              (read-cache ?cache)))))))
