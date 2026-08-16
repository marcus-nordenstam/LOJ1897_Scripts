; ----------------------------------------------------------------------------
; make_secret_cache (npc-think) - DELIBERATION half: an NPC with something to
; hide (a covert lover, a standing stow goal) and no cache yet resolves to
; fashion a private hiding spot at home. It only PROPOSES the make_cache act -
; the host-quality tier walk and the env writes (create the cache, stamp owner,
; record it) live in the pure make_cache_act.hs, since a think must not mutate
; the world.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think make_secret_cache
  (cooldown 1 m)

  ; No cache yet - a CACHED self-gate; an owner of one skips the think forever.
  (role @self (not {@self hiding_spot ?}))
  ; The home is a CACHED role and the proposal's target; a bedroom must exist so
  ; make_cache's guaranteed floorboard fallback lands.
  (role ?building {@self home ?building}
                  (room [k bedroom] ?building))

  ; Something to hide: a covert lover or a standing stow goal.
  (when (or (any {@self lover ?} (out int))
            (has-goal {@self stow})))

  (utility 20)
  (effects (maintain-proposal {@self MAKE_CACHE ?building})))
