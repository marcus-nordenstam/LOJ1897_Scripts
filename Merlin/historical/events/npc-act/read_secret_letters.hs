; ----------------------------------------------------------------------------
; read_secret_letters.hs - the routine of checking one's own hiding-spots.
;
; An NPC with something to hide keeps private caches (see make_secret_cache.hs).
; Each window they SEARCH the caches they own and read whatever has been stashed
; there - covert letters dropped for them (a conspiracy proposal, a love note).
; The words become their own beliefs, exactly as a spoken message would: a
; conspiracy letter teaches the plot, so the recruited lover learns what they are
; being urged to do BECAUSE they read it, not by telepathy.
;
; PURE .hs over a cacheable role + one atomic op:
;   - (role ?cache (believes {@self hiding_spot ?cache})) binds each hiding-spot
;     @self made - a cacheable self-belief role (the persistent {@self hiding_spot
;     ?cache} relation seeds the candidate pool; no template, no cross-role join);
;   - (read-cache ?cache) reads every readable item stashed inside it. The op
;     walks the cache's own `contents` (the actor owns it, so it is theirs to
;     read) and is idempotent, so re-searching each window re-learns nothing.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour read_secret_letters
  (long-term-think)

  (roles
    (role @self (any_human @self))
    ; Each hiding-spot @self made and knows.
    (role ?cache (believes {@self hiding_spot ?cache})))

  (effects
    (read-cache ?cache)))
