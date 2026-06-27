; ----------------------------------------------------------------------------
; confess_fancy (npc-think) - the directed disclosure that grounds reciprocal
; courtship WITHOUT telepathy.
;
; THE PROBLEM: a love match needs MUTUAL fancy, but a suitor cannot read his
; beloved's heart by peeking into her mind. THE FIX (the user's design): whoever
; fancies someone LETS THEM KNOW. @self tells ?target that he/she fancies them -
; minting {@self fancy ?target} into ?target's OWN mind (confess-fancy ->
; relay_fact). Now each suitor reads the OTHER side's fancy from his OWN belief:
; love_match / court / lovers gate on (believes {?beloved fancy @self}) - a fact
; the beloved put there by confessing - never a cross-mind read.
;
; Symmetric (either party confesses the moment they fancy), so mutual fancy is
; legible from EITHER suitor's POV. `fancy` only ever forms opposite-sex (the
; crush_forms gate), so no gender filter is needed here.
;
; A mental change in the LISTENER (she now knows he fancies her), so npc-think.
; RELATIONAL, keyed on the standing `fancy` stance (not co-presence) like the rest
; of the courtship cluster. Fired by the per-NPC emergent pass MONTHLY; no chance -
; the disclosure is reliable, and relay_fact dedupes (and re-asserts if the copy
; decayed), so re-firing each window simply keeps it fresh while the fancy stands.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(hsim-event confess_fancy
  (sim-window-start)
  (rng-stream marriages)

  (roles
    ; @self fancies someone and is free to court (the cheap @self-role pre-gate;
    ; the specific pair is the ?target stance gate below).
    (role @self (template any_human)
                (marriageable-age @self)
                (not (believes {@self spouse ?}))
                (believes {@self fancy ?}))
    ; ?target is the specific person @self is attracted to (attraction at least
    ; the `fancy` band, the explicit band-ladder belief - the same gate court /
    ; love_match read).
    (role ?target (template any_human)
                  (not (= ?target @self))
                  (marriageable-age ?target)
                  (is-attracted-to @self ?target)))

  (effects
    ; Mint {@self fancy ?target} into ?target's mind - she/he now KNOWS.
    (confess-fancy ?target)))
