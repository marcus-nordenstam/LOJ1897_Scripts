; ----------------------------------------------------------------------------
; seduce ?paramour - take a new lover to replace a lost attachment. @self reaches the
; paramour and, discreetly (no spouse in the room) and only if opposite-sex and non-kin,
; proposes the SHARED consummation act HAVE_SEX_WITH (reused, never duplicated). The sex
; record then lets recognize_lover recognise the `lover` bond on both sides (no fiat mint),
; and THAT recognition is the seduce's conclusive outcome. A dead, same-sex, or kin
; paramour cannot be seduced -> abandon. Already a lover -> the deed is already done.
; ----------------------------------------------------------------------------

(npc-task {@self seduce ?paramour}:?seduce-rel
  (tar human)
  (construed_act intimacy_act)
  (facets blackmailable)
  (and
    (try
      (when (and (alive ?paramour)
                 (none {@self lover ?paramour})
                 (not (spatial ?paramour co-located @self))
                 (spatial ?paramour space): ?loc))
      (utility errand)
      (effects (maintain-proposal {@self go ?loc})))
    (try
      (when (and (alive ?paramour)
                 (none {@self lover ?paramour})
                 (not (spatial ?paramour co-located @self))
                 (unknown (spatial ?paramour space))))
      (effects (maintain-proposal {@self go (home-of ?paramour)})))
    (try
      (when (and (alive ?paramour)
                 (none {@self lover ?paramour})
                 (spatial ?paramour co-located @self)
                 (not (spatial (spouse-of @self) co-located @self))
                 (not {?paramour gender (any {@self gender}).target})
                 (not (blood-kin @self ?paramour))
                 (none {@self HAVE_SEX_WITH ?paramour /succ /caused_by ?seduce-rel})))
      (utility errand always-pick)
      (effects (maintain-proposal {@self HAVE_SEX_WITH ?paramour})))
    (try
      (when {@self lover ?paramour})
      (effects (set-outcome ?seduce-rel succ)))
    (try
      (when (or (not (alive ?paramour))
                {?paramour gender (any {@self gender}).target}
                (blood-kin @self ?paramour)))
      (effects (set-outcome ?seduce-rel fail)))))
