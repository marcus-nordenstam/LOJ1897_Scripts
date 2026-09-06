; ----------------------------------------------------------------------------
; make_secret_cache (npc-think) - DELIBERATION half: an NPC with something to
; hide (a covert lover, a standing stow goal) and no cache yet resolves to
; fashion a private hiding spot at home. It only PROPOSES the make_cache act -
; the host-quality tier walk and the env writes (create the cache, stamp owner,
; record it) live in the pure make_cache_act.hs, since a think must not mutate
; the world.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-think make_secret_cache
  (cooldown 1 m)

  ; No cache yet - a CACHED self-gate; an owner of one skips the think forever.
  (role @self -{@self hiding-spot ?})
  ; The home is a CACHED role and the proposal's target; a bedroom must exist so
  ; make_cache's guaranteed floorboard fallback lands.
  (role ?building {@self home ?building}
                  (spatial ?building room [k bedroom]))

  ; Something to hide: a covert lover or a standing stow goal.
  (when (or {@self lover ?}
            {@self goal {@self stow}}))

  (utility want)
  (effects (maintain-proposal {@self MAKE-CACHE ?building})))
