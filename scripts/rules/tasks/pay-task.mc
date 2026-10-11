; ----------------------------------------------------------------------------
; pay ?payee - count out what was demanded and hand it over in person. Witnessed (obs): the
; payee who sees it paid holds it, which is what lapses the threat that demanded it.
; ----------------------------------------------------------------------------

(include "../../macros/acquisition-macros.mc")

(task {@self pay ?payee}:?pay
  (tar [k human] @object)
  (obs)
  (and
    (try
      (role ?counted [k pile] {?counted content-kind [k coin]} (= (spatial ?counted held-by) @self)
        (effects (maintain-proposal {@self give ?counted ?payee}))))
    (try
      (role ?cash {@self carrying-cash ?cash} {?cash count ?cash-count}
        (no-role [k pile] {?norole content-kind [k coin]} (= (spatial ?norole held-by) @self))
        (when (and (>= ?cash-count (blackmail_coins))
                   (empty (spatial (spatial @self right-hand) grip))))
        (effects (maintain-proposal {@self PILE-SPLIT ?cash (blackmail_coins)}))))
    (try
      (when {@self give ? ?payee /succ /caused_by ?pay})
      (effects (set-outcome ?pay /succ)))
    (try
      (when (not (alive ?payee)))
      (effects (set-outcome ?pay /fail)))))
