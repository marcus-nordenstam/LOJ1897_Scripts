; ----------------------------------------------------------------------------
; The home-leisure drivers: a bored bookish man reads in his study (read-at), a crowded man
; withdraws there or rests, and a strained man rests at home (rest). The study gate reads his
; OWN spatial index of the home, (spatial ?home room [k study]).
; ----------------------------------------------------------------------------

(include "../../macros/home-macros.mc")
(include "../../macros/leisure-macros.mc")

(define-macro read-intellect-threshold () 0.5)

(driver household-read-driver
  (role @self {@self stimulation [k bored|restless]}
              {@self intellect ?intellect}
              {@self home ?home}
              (spatial ?home room [k study])
    (declare-utility want)
    (preemptive-or
      (try
        (role @self {@self interest [k academic-field|literature]}
          (effects (maintain-proposal {@self read-at ?home} /quit-trying-on-fail))))
      (try
        (when (>= ?intellect (read-intellect-threshold)))
        (effects (maintain-proposal {@self read-at ?home} /quit-trying-on-fail))))))

(driver household-retreat-driver
  (role @self {@self company [k crowded]}
              {@self home ?home}
    (declare-utility want)
    (preemptive-or
      (try
        (role @self (spatial ?home room [k study])
          (effects (maintain-proposal {@self read-at ?home} /quit-trying-on-fail))))
      (try
        (effects (maintain-proposal {@self rest ?home} /quit-trying-on-fail))))))

(driver household-rest-driver
  (role @self {@self ease [k strained|frayed]}
              {@self home ?home}
    (declare-utility want (flip {@self ease [k frayed]} (frayed-rest-value) (strained-rest-value)))
    (effects (maintain-proposal {@self rest ?home} /quit-trying-on-fail))))

; ----------------------------------------------------------------------------
; set-mealtimes-driver - the woman of the house, holding the duty, fixes the household's meal
; hours while her own mind lacks the home's supper hour: she proposes the set-mealtimes task
; (tasks/set-mealtimes-task.mc), which says the hours aloud to the household and then holds them
; herself. Any straggler self-heals through the ask-the-cook channel below.
; ----------------------------------------------------------------------------


(driver set-mealtimes-driver
  (cooldown 1 m try-until-succ)

  ; The COOK is the woman of the house - self-identified from @self's OWN gender
  ; belief (mental, no household-cook scan) - a CACHED self-gate filter. ?home is
  ; a CACHED role: home + no-supper-hour tested against the SAME candidate, and
  ; the role BINDS ?home for the effects. Whichever adult woman fires first sets
  ; the hours; the (not supper-hour) filter then empties for the whole household.
  (role @self {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self gender [k female]}
    (role ?household [k household] {@self duty-to ?household set-mealtimes}
      (role ?home {@self home ?home}
        (when -{?home supper-hour ?})
        (declare-utility want)
        (effects (maintain-proposal {@self set-mealtimes ?household}))))))

; (plan_provisioning / set_shop_schedule are GONE: provisioning is the
; pressure-driven cook errand in thinks/provisioning_think.mc - the kitchen
; larder count IS the schedule.)
