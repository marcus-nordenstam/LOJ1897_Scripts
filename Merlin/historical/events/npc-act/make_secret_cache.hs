; ----------------------------------------------------------------------------
; make_secret_cache.hs - an NPC with something to hide fashions a secret cache.
;
; When an NPC has REASON to send / receive secret letters (here: a covert lover),
; they carve out a private hiding spot in their home. A hiding-spot is a small
; INTERIOR SUB-SPACE (a hidden `part` of a room, not a loose prop): a loose
; floorboard in the bedroom. It is THEIRS (create-entity stamps owner = @self,
; the "you make it, you own it" rule), so only they search it.
;
; PURE .hs:
;   - home IS the building, so {@self home ?building} gives it directly, and
;     {?building room [k bedroom]:?bedroom} binds a bedroom they know of;
;   - (create-entity [k floorboard_cache] (qual parent ?bedroom) (bind ?cache))
;     makes the cache-space as a CHILD of the bedroom (a sub-space, not contents);
;   - {@self hiding_spot ?cache} records it - the durable (/rsn, since hiding_spot
;     is a DEFINED relation) self-knowledge that both gates this act (made at most
;     one cache) and seeds the search routine's role.
;
; Host variety (book_cache in a book, jewelry_box_lining in a jewelry box,
; painting_cache behind a painting, an existing secret_chamber) rides on the same
; (create-entity ... (qual parent <host>)) once those hosts are furnished; the
; floorboard is the always-available default.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event make_secret_cache
  (long-term-think)

  (roles
    (role @self (template any_human)))

  ; A covert lover is the reason; no cache yet; bind the home + a bedroom in it
  ; (the pattern-binds thread along the (and) spine and GATE - no home or bedroom
  ; => no cache).
  (when (and (believes {@self lover ?})
             (not (believes {@self hiding_spot ?}))
             (bind {@self home ?building})
             (bind {?building room [k bedroom]:?bedroom})))

  (effects
    (create-entity [k floorboard_cache] (qual parent ?bedroom) (bind ?cache))
    (begin-belief {@self hiding_spot ?cache})))
