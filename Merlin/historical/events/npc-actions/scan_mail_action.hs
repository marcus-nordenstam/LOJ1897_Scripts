; ----------------------------------------------------------------------------
; scan_mail (npc-action) - the dumb hands act the read_mail task proposes: lift
; every letter addressed to @self out of ?stack into @self's hand. The addressee
; test is a physical envelope read (the abs `addressee` tag), not a belief read,
; so this stays action-pure; taking a letter out of the stack is env mutation,
; which only an ACTION may do.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")

(npc-action {@self scan_mail ?stack}
  (duration 5)
  (effects
    (for-each ?ltr (attr-values ?stack items [k letter])
      (if (attr-is ?ltr addressee @self)
          (then (take-from-stack ?ltr))))
    (set-outcome {@self scan_mail ?stack} succ)))
