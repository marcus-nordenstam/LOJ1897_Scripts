; ----------------------------------------------------------------------------
; apply-for ?jk ?wp - the WORKER's job application, keyed on the job-kind + the WORKPLACE
; building the advert named: go home, write + address the application
; (prepare-application), hand the paper to the mail lane from the HOME out-box, done - an
; hour's errand, not a lifecycle. Its /succ is the "applied" record the driver reads
; (seek_apply_pick applies once per post). The verdict arrives weeks later as a TYPED
; letter in the home post: reading an offer-letter drives take-up-post (job-search-think),
; a rejection-letter drives nothing. Drivers stay in job-search-think.
;
; One sequence: home, form, post, done; each stage reads the world for what is already
; done. The out-box is located by the sibling try once the form is in hand and no pile is
; known; the send stage holds until one is.
; ----------------------------------------------------------------------------

(npc-task {@self apply-for ?jk ?wp}:?af-rel
  (tar job)
  (aux building)
  (and
    (sequence
      (role ?home {@self home ?home})
      (utility errand (above read-mail))

      (stage
        (effects
          (if (not (spatial @self building ?home))
              (then (maintain-proposal {@self enter ?home})))))

      (stage
        (effects
          (if (empty (spatial @self hold [k application]))
              (then (maintain-proposal {@self prepare-application ?wp ?jk})))))

      (stage
        (role ?app [k application] (spatial ?app co-located @self))
        (role ?out [k outgoing-mail-stack] (spatial ?out building ?home))
        (effects (maintain-proposal {@self send-mail ?app ?out})))

      (stage
        (effects (set-outcome ?af-rel /succ))))

    (try
      (role ?home {@self home ?home})
      (no-role [k outgoing-mail-stack])
      (when (not (empty (spatial @self hold [k application]))))
      (utility errand)
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?home})))))
