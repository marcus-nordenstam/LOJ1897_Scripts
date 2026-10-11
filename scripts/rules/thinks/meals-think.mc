; ---- notice the larder -----------------------------------------------------
; A home, hungry resident who believes there is NO food OBSERVES their own
; kitchen (the larder room), surfacing its contents into belief. Without this
; only the cook - who stocks and frequents the kitchen - knows the food is there;
; the rest of the family believes an empty larder, skips the family table, and
; starves beside a full kitchen. Per-mind honest (you check your own kitchen when
; hungry at home) and un-gated by food belief (LEARNING whether food is there is
; the whole point). Self-limiting: once the food is seen the count is > 0 and this
; stops firing until the larder is eaten down again; a truly empty kitchen keeps
; reading 0 and the resident falls through to the meal-less chains, as it should.
(think notice-larder
  (role @self {@self satiety [k hungry|famished]}
    (role ?home {@self home ?home}
                (spatial @self unit ?home)
                (spatial ?home room [k kitchen]): ?kitchen   ; a resident who does not know their kitchen just skips
      (when (= (believed-home-food-count ?home) 0))
      (effects
        (observe ?kitchen)))))
