; ----------------------------------------------------------------------------
; flee_foe (npc-think) - the victim's FLIGHT response (runtime-blame model). The
; sibling of fight_defence: a victim who witnesses a violent act against themselves
; may RUN instead of fighting back. Keyed on the same witnessed violent act (matched by
; (theme-labels violent_to)), gated on the inverse disposition - a timid, volatile,
; compassionate victim flees where a callous brute swings.
;
; The flight is a run for home: breaking co-presence interrupts the assault (the current
; blow needs the parties together), so a pursuer must re-close before the next blow. This
; is the compact flee - the probabilistic escape-roll + the scream-for-help / cry-alarm
; sub-lanes are a deferred refinement (see fight_decomposition_plan section 4).
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think flee_foe
  (cooldown 1 m)

  (role ?foe {?foe (theme-labels violent_to) @self}:?witnessed-rel
             (not {?foe condition [k dead]}))

  ; The fearful flight: timidity = high volatility + low sadism + high compassion, the
  ; mirror of fight_defence's combat resolve, so most victims lean one way or the other.
  (when (chance (clamp (+ (attr @self volatility)
                          (- 1.0 (attr @self sadism))
                          (attr @self compassion))
                       0.05 0.95)))

  (utility survival always-pick)

  (effects
    ; Run for home - a known refuge; if @self has none, no flight (they stand and take it).
    (if (any {@self home ?myhome})
        (then (maintain-proposal {@self go ?myhome})))))
