; ----------------------------------------------------------------------------
; confess_fancy (npc-act) - the directed disclosure that grounds reciprocal
; courtship WITHOUT telepathy.
;
; THE PROBLEM: a love match needs MUTUAL fancy, but a suitor cannot read his
; beloved's heart. THE FIX: whoever fancies someone TELLS THEM - when they are
; together. (tell-to ?target {@self fancy ?target}) says it directly to ?target;
; perception delivers {@self fancy ?target} into ?target's mind, sourced to the
; spoken {@self SAY ...}. Now each suitor reads the OTHER side's fancy from his
; OWN belief (love_match / court / lovers gate on (believes {?beloved fancy @self}))
; - never a cross-mind read.
;
; PRIVATE by co-presence: gated on (co-present @self ?target) - a confession needs
; the two together (and only carries to them and whoever else is in the room). The
; co-presence gate is also REQUIRED for correctness of a directed tell: the
; speaker's per-listener "told" memory must only be stamped when the addressee
; could actually hear, else the selector would think it was said and never re-say
; it. (tell-to dedupes per-listener and re-asserts on decay, so re-firing while
; together keeps it fresh.)
;
; An ACT (tell-to), so npc-act. `fancy` only forms opposite-sex (the crush_forms
; gate), so no gender filter is needed.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-npc-behaviour confess_fancy
  (long-term-think)
  (rng-stream marriages)

  (roles
    ; @self fancies someone and is free to court (cheap @self pre-gate; the
    ; specific pair is the ?target stance gate below).
    (role @self (template any_human)
                (marriageable-age @self)
                (not (believes {@self spouse ?}))
                (believes {@self fancy ?}))
    ; ?target is the specific person @self is attracted to (attraction at least
    ; the `fancy` band - the same gate court / love_match read).
    (role ?target (template any_human)
                  (not (= ?target @self))
                  (marriageable-age ?target)
                  (is-attracted-to @self ?target)))

  ; The confession only happens when they are actually TOGETHER (no telepathy; also
  ; keeps the per-listener untold record honest).
  (when (co-present @self ?target))

  (effects
    ; Say it to ?target's face: she/he now KNOWS @self fancies them.
    (tell-to ?target {@self fancy ?target})))
