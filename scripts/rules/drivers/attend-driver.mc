; ----------------------------------------------------------------------------
; attend drivers - the DESIRES that raise the occasion tasks. Learning of an
; occasion is ordinary mail: the invitation letter's two sentences ({<host> invite
; @self /aux <occ>} + {<occ> held-on <date>}) are adopted when @self reads his post. The
; invitation, or organizing the occasion himself, obliges him to attend
; (reflexes/obligation-attend.mc); these drivers read that obligation and fire the DOING when the
; day has come, only the held-on date test riding (when). A month gone by unattended lapses
; the obligation and strains him (attendance-lapsed).
;
;   want_attend (guest / host) : raise the shared attend task (attend-task.mc).
;
; A host and a guest share one attend task; the tier and desirability of attending are
; these drivers' to set (the host is bound to his own occasion, over the working day; a
; guest's willingness scales with warmth toward the host). The wedding itself is pursue-wed's
; (wed-think.mc).
; maintain-proposal throughout: the desire self-withdraws once held-on leaves the
; current month; the task concludes itself once the occasion's hours are over.
;
; ----------------------------------------------------------------------------

; A guest: I hold an invitation to an occasion whose day has come -> attend it.
(driver want-attend-guest-driver
  (role ?occ {?occ held-on ?held-on}
             {@self obligation {@self attend ?occ} ?}
             {? invite @self ?occ}
    (when (date-in-current-month ?held-on))
    ; Desirability within the tier: 0 bedridden, a floor for a kill-driven crasher, else
    ; the warmth-scaled guest base.
    (declare-utility errand (cond
                      (case {@self physical-mobility [k bedridden]} 0)
                      (case {@self intent {@self kill ?}} (max (attend-crasher-value)
                                                             (attend-guest-scaled ?occ)))
                      (else (attend-guest-scaled ?occ))))
    (effects (maintain-proposal {@self attend ?occ}))))

(driver want-attend-host-driver
  (role ?occ {@self organize ?occ}
             {@self obligation {@self attend ?occ} ?}
             {?occ held-on ?held-on}
    (when (date-in-current-month ?held-on))
    (declare-utility obligation always-pick)
    (effects (maintain-proposal {@self attend ?occ}))))
