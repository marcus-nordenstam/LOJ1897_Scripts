; ----------------------------------------------------------------------------
; kill - the killing task. The murder DRIVERS (crime-of-passion, betrayal-kill,
; covet-inheritance, rid-of-spouse, ambition, predation, conspiracy-adoption,
; clear_marriage) maintain-propose {@self kill ?victim} while their REASON (the
; grudge bond named on /caused_by) holds; the drive fades the moment the reason
; does, and drops when the victim dies. This task, once selected, is the METHOD
; DECIDER: a strong hand strangles, an armed one shoots, a rich one hires; a weak,
; unarmed, poor one has no means and proposes nothing. The chosen killing sub-task
; drives down to the physical blow (STRANGLE / SHOOT) or the hiring talk.
;
; No outcome twin: the drivers' maintain-conditions own the lifecycle (victim dead
; or reason gone -> the proposal drops), and the DEED's record is the killing
; action's own ended act-belief + its crime row - not this coordinator's. The pick
; only switches when the means change (a firearm acquired); maintain-proposing it
; retracts it automatically when this task drops.
; ----------------------------------------------------------------------------

(define-macro strangling_strength () 0.45)
(define-macro assassin_fee_coins () 80)

(task {@self kill ?victim}:?kill
  (tar [k human] @object)
  (construed-act harm-act) (theme violent-to) (contradicts life)
  (facets reportable_crime blackmailable)
  (try
    (when -{?victim condition [k dead]})
    (declare-utility survival)
    (effects
      (any {@self strength ?strength})
      (any {@self coin-pile.count ?coins=0})
      (cond
        (case (>= ?strength (strangling_strength))
              (maintain-proposal {@self strangle ?victim}))
        (case (spatial [k firearm] space)
              (maintain-proposal {@self shoot ?victim}))
        (case (>= ?coins (assassin_fee_coins))
              (maintain-proposal {@self hire-assassin ?victim}))))))
