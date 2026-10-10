; ----------------------------------------------------------------------------
; money (think) - loose coins in hand go into the carrying cash, at the floor of the want
; band: a purchase or a bribe that counted them out outbids it for as long as it wants them.
; ----------------------------------------------------------------------------

(think pocket-coins
  (role ?cash {@self carrying-cash ?cash} (spatial @self can-reach ?cash)
    (role ?loose [k pile] {?loose content-kind [k coin]} (= (spatial ?loose held-by) @self)
      (declare-utility want fallback)
      (effects (maintain-proposal {@self PILE-TRANSFER ?loose ?cash})))))
