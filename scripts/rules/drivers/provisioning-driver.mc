; ----------------------------------------------------------------------------
; provisioning (think) - keeping the household LARDER stocked. The
; larder is THE KITCHEN (every inhabited home has one - world-gen aborts
; otherwise), and ONE cook per household owns the errand.
;
; THE ERRAND: want-provisions sends the cook to the shop he knows sells provisions, never a
; generic one (tasks/provision-task.mc); provision-rearm carries the basket home to the
; kitchen (tasks/carry-home-task.mc).
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")
(include "../../macros/collection-macros.mc")

; ---- the pressure: the kitchen larder is low --------------------------------
; The kitchen resolves from the cook's own spatial index of the home. He buys at the shop he
; knows sells provisions (tasks/provision-task.mc); knowing none, he does not provision.

(driver want-provisions
  (role ?shop {@self provisions-shop ?shop}
    (role ?home {@self household-cook ?home}
                (spatial ?home room [k kitchen]): ?kitchen
      (when (< (believed-pile-count ?kitchen [k food]) (larder_low_water)))
      (declare-utility duty)
      (effects (maintain-proposal {@self provision ?shop})))))

; ---- the delivery drive ------------------------------------------------------
; Laden with food: carry it home to the kitchen (tasks/carry-home-task.mc). 900 on the road
; outbids the provision pull the moment the basket is in hand; 1000 once standing in the
; kitchen - the put-down takes a minute and nobody beds down still holding the shopping.

(driver provision-rearm
  (role ?home {@self home ?home}
              (spatial ?home room [k kitchen]): ?kitchen
    (when (substantial (held-ware @self [k food])))
    (declare-utility duty (flip (spatial @self space ?kitchen) 1000 900))
    (effects (maintain-proposal {@self carry-home [k food] ?kitchen} /quit-trying-on-fail))))
