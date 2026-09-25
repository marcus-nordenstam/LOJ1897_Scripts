; ----------------------------------------------------------------------------
; apply-for ?job - the WORKER's job application for ONE seat, the one the notice named
; (its org and line make it that seat): go home, write + address the application
; (prepare-application), hand the paper to the mail chain from the HOME out-box, done - an
; hour's errand, not a lifecycle. Its /succ is the "applied" record the driver reads
; (seek_apply_pick applies once per seat). The verdict arrives weeks later as a TYPED
; letter in the home post: reading an offer-letter drives accept-job-offer
; (job-search-think), a rejection-letter drives nothing. Drivers stay in job-search-think.
;
; One sequence: home, form, post, done; each stage reads the world for what is already
; done. The out-box is located by the sibling try once the form is in hand and no pile is
; known; the send stage holds until one is.
; ----------------------------------------------------------------------------

(npc-task {@self apply-for ?job}:?af-rel
  (aspect labour)
  (tar [k job] @object)
  (and
    (sequence
      (role ?home {@self home ?home}
        (utility errand (above read-mail))

        (stage
          (effects
            (if (not (spatial @self building ?home))
                (then (maintain-proposal {@self go ?home})))))

        (stage
          (effects
            (if (empty (spatial @self hold [k application]))
                (then (maintain-proposal {@self prepare-application ?job})))))

        ; THE FORM I WROTE and have not posted - the memory of the WRITE, never a form merely
        ; near: a housemate's form seen at home months ago still stands co-located in a
        ; stale belief with its env attrs reading true (measured: it was pushed out of the
        ; officer's hand into this man's out-box). The form is never in hand (measured).
        (stage
          (role ?app [k application] (spatial ?app co-located @self)
                                     {@self WRITE ?app ? /succ}
                                     -{@self send-mail ?app ? /succ}
                                     (substantial (attr ?app writing))
                                     (substantial (attr ?app destination)))
          (role ?out [k outgoing-mail-stack] (spatial ?out building ?home))
          (effects (maintain-proposal {@self send-mail ?app ?out})))

        (stage
          (effects (set-outcome ?af-rel /succ)))))

    (try
      (role ?home {@self home ?home}
        (no-role [k outgoing-mail-stack])
        (when (not (empty (spatial @self hold [k application]))))
        (utility errand)
        (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?home}))))))
