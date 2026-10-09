; ----------------------------------------------------------------------------
; seduce ?paramour - take a new lover to replace a lost attachment. @self reaches the
; paramour and, discreetly (no spouse in the room) and only if opposite-sex and non-kin,
; proposes the SHARED consummation act HAVE-SEX-WITH (reused, never duplicated). The sex
; record then lets recognize-lover recognise the `lover` bond on both sides (no fiat mint),
; and THAT recognition is the seduce's conclusive outcome. A dead, same-sex, or kin
; paramour cannot be seduced -> abandon. Already a lover -> the deed is already done.
; ----------------------------------------------------------------------------

(task {@self seduce ?paramour}:?seduce
  (track-skill-level [k seduction])
  (tar [k human] @object)
  (construed-act intimacy-act)
  (facets blackmailable)
  (and
    (try
      (when (and (alive ?paramour)
                 -{@self lover ?paramour}
                 (not (spatial ?paramour co-located @self))
                 (spatial ?paramour space)))
      (declare-utility errand)
      (effects (maintain-proposal {@self go-to ?paramour})))
    (try
      (role ?phome {?paramour home ?phome}
        (when (and (alive ?paramour)
                   -{@self lover ?paramour}
                   (not (spatial ?paramour co-located @self))
                   (unknown (spatial ?paramour space))))
        (effects (maintain-proposal {@self go-to ?phome}))))
    (try
      (no-role [k human] {@self spouse ?norole} (spatial ?norole co-located @self))
      (role @self {@self gender ?gender}
        (when (and (alive ?paramour)
                   -{@self lover ?paramour}
                   (spatial ?paramour co-located @self)
                   -{?paramour gender ?gender}
                   (none {@self (kin-labels) ?paramour})
                   -{@self HAVE-SEX-WITH ?paramour /succ /caused_by ?seduce}))
        (declare-utility errand always-pick)
        (effects (maintain-proposal {@self HAVE-SEX-WITH ?paramour}))))
    (try
      (when {@self lover ?paramour})
      (effects (set-outcome ?seduce /succ)))
    (try
      (role @self {@self gender ?gender}
        (when (or (not (alive ?paramour))
                  {?paramour gender ?gender}
                  {@self (kin-labels) ?paramour}))
        (effects (set-outcome ?seduce /fail))))))
