(include "../../../definitions/roles.hs")

(npc-think affair_consummate
  (role @self (adult @self)
              (believes {@self lover ?paramour})
              (not (believes {@self spouse ?paramour})))
  (role ?paramour (any_human ?paramour)
                  (co-present @self ?paramour))
  (utility 12.0)
  (effects (maintain-proposal {@self HAVE_SEX_WITH ?paramour})))
