; ----------------------------------------------------------------------------
; open-drawer driver - the first consumer of OPEN / CLOSE: a man at a drawer he has never
; opened opens it, and shuts one he opened and never shut. A whim, so any duty outbids it.
; The gates read what has SUCCEEDED, never the running act or the drawer's state, which
; the act itself changes under its own proposer; a drawer is known by the opening-status
; its sight teaches, whatever that status is.
; ----------------------------------------------------------------------------

(think want-open-drawer
  (role ?drawer {?drawer opening-status ?}
              (is-a ?drawer [k drawer])
              (spatial @self co-located ?drawer)
              -{@self OPEN ?drawer /ever /succ}
    (utility want)
    (effects (maintain-proposal {@self OPEN ?drawer}))))

(think want-close-drawer
  (role ?drawer {?drawer opening-status ?}
              (is-a ?drawer [k drawer])
              (spatial @self co-located ?drawer)
              {@self OPEN ?drawer /ever /succ}
              -{@self CLOSE ?drawer /ever /succ}
    (utility want)
    (effects (maintain-proposal {@self CLOSE ?drawer}))))
