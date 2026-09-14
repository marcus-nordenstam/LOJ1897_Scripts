; ----------------------------------------------------------------------------
; invite-guest ?guest ?occ - carry ONE invitation to ONE friend: pen it, address it,
; post it from the home out-box. The same pen / envelope / post chain draft-verdict
; runs for a verdict letter, because it is the same physical job.
;
; The letter is a FORM, like an application or a job notice: a two-column table the
; reader looks up by field. READ's invitation branch reasons the occasion back out of
; those cells.
;
; The letter this task pens is the one it CREATED: the CREATE postlude stashes it
; under the running task's own `letter` key, so a restart re-reads that key rather
; than picking up whatever letter happens to be in hand, and never pens a second.
;
; Concluding MINTS the host's own {@self invite ?guest /aux ?occ} record - which is
; both what he reads back off his own guest list and what takes this friend off the
; parent round's queue.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

(npc-task {@self invite-guest ?guest ?occ}:?ig-rel
  (and
    (sequence
      (role ?my-home {@self home ?my-home})
      (role ?guest-home {?guest home ?guest-home})

      (stage
        (effects
          (if (bb-any ?ig-rel letter)
              (then (bind (bb-read ?ig-rel letter) ?ltr))
              (else (maintain-proposal {@self CREATE-ENTITY [k invitation-letter]}:?ce
                      [/postlude (bind (bb-read ?ce created) ?ltr)
                                 (bb-write ?ig-rel letter ?ltr)])))))

      ; The FORM. An occasion is a nameless abstract object and cannot ride a wire as
      ; itself, so the letter carries the facts that CONSTITUTE it - whose it is, when,
      ; where, between which hours - and the reader rebuilds his own occasion from them.
      ; Host by NAME and venue by ADDRESS: the two things a stranger can resolve.
      (stage
        (when {@self name ?my-name}
              {?occ held-on ?occ-date}
              {?occ venue ?occ-venue}
              {?occ-venue address ?venue-address}
              {?occ hours ?occ-from ?occ-to})
        (effects
          (kind ?occ): ?occ-kind
          (if (unsubstantial (attr ?ltr writing))
              (then (maintain-proposal
                      {@self WRITE ?ltr (table-msg [[occasion-kind ?occ-kind]
                                                    [host ?my-name]
                                                    [venue ?venue-address]
                                                    [held-on ?occ-date]
                                                    [from-hour ?occ-from]
                                                    [to-hour ?occ-to]])})))))

      (stage
        (when {?guest-home address ?guest-address})
        (effects
          (if (unsubstantial (attr ?ltr destination))
              (then (maintain-proposal {@self ADDRESS ?ltr ?guest-address})))))

      (stage
        (role ?out [k outgoing-mail-stack] (spatial ?out building ?my-home))
        (effects (maintain-proposal {@self send-mail ?ltr ?out})))

      (stage
        (effects
          (bb-clear ?ig-rel letter)
          (begin-belief {@self invite ?guest ?occ})
          (set-outcome ?ig-rel /succ))))

    ; The out-box is knowledge the posting stage needs and may not have: an addressed
    ; letter in hand with no pile known is what sends him looking for one.
    (try
      (role ?my-home {@self home ?my-home})
      (role ?held [k invitation-letter] (spatial ?held held-by @self)
                                        (substantial (attr ?held destination)))
      (no-role [k outgoing-mail-stack])
      (effects (maintain-proposal {@self locate [k outgoing-mail-stack] ?my-home})))))
