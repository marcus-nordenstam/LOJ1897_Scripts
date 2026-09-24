; ----------------------------------------------------------------------------
; attend drivers - the DESIRES that raise the occasion tasks. Learning of an
; occasion is ordinary mail: the invitation letter's two sentences ({<host> invite
; @self /aux <occ>} + {<occ> held-on <date>}) are adopted when @self reads his post,
; so no scan reconstructs them here. These drivers only fire the DOING when the day
; has come: the occasion is bound by a ROLE (change-driven, wakes on the invite /
; organize write) and only the held-on date test rides (when).
;
;   want_attend (guest / host) : raise the shared attend task (attend-task.mc).
;   want_wed                   : a wedding principal raises the vow duty (wed-task.mc).
;
; A host and a guest share one attend task; the tier and desirability of attending are
; these drivers' to set (the host is bound to his own occasion, over the working day; a
; guest's willingness scales with warmth toward the host). A wedding principal
; additionally runs the wed duty.
; maintain-proposal throughout: the desire self-withdraws once held-on leaves the
; current month; the task concludes itself once the occasion's hours are over.
;
; vow_realized / spouse_reciprocate reconcile the marriage beliefs the vow makes -
; they gate on fiancee / spouse, not on any attend token, so they stay here.
; ----------------------------------------------------------------------------

; A guest: I hold an invitation to an occasion whose day has come -> attend it.
(npc-think want_attend_guest
  ; alpha = occasions I know (?occ is the subject, so the cache can index it);
  ; the invite is the residual filter that keeps only the ones I was asked to.
  (role ?occ {?occ held-on ?}
              {? invite @self ?occ}
    (when (date-in-current-month (any {?occ held-on ?}).target))
    ; Desirability within the tier: 0 bedridden, a floor for a kill-driven crasher, else
    ; the warmth-scaled guest base.
    (utility errand (cond
                      (case {@self physical-mobility [k bedridden]} 0)
                      (case {@self goal {@self kill ?}} (max (attend-crasher-value)
                                                             (attend-guest-scaled ?occ)))
                      (else (attend-guest-scaled ?occ))))
    (effects (maintain-proposal {@self attend ?occ}))))

; A host: I am organizing an occasion whose day has come -> attend it too.
(npc-think want_attend_host
  (role ?occ {@self organize ?occ}
    (when (date-in-current-month (any {?occ held-on ?}).target))
    (utility obligation always-pick)
    (effects (maintain-proposal {@self attend ?occ}))))

; A wedding principal: organizing a wedding whose day has come, still betrothed and
; unmarried -> raise the vow duty. The [k wedding]:?occ kind-cast narrows the role to
; wedding occasions.
(npc-think want_wed
  (role ?occ {@self organize [k wedding]:?occ}
    (role @self {@self fiancee ?} (none {@self spouse @something})
      (when (date-in-current-month (any {?occ held-on ?}).target))
      (utility obligation always-pick)
      (effects (maintain-proposal {@self wed ?occ})))))

; The vow was SPOKEN. Saying it IS believing it - the say channel mints the spoken
; {@self spouse ?betrothed} in the speaker's own mind and every hearer's. What the vow
; does NOT say still closes: the betrothal ends, and the kin residue runs.
(npc-think vow_realized
  (role ?betrothed {@self fiancee ?betrothed}
                   {@self spouse ?betrothed}
    (effects
      (end-belief {@self fiancee ?betrothed})
      ; TELEPATHY - this married both parties by writing the bride's mind. The vow is
      ; spoken and HEARD; the reciprocal marriage below is her own rule on hearing it.
      ; Commented out pending that redesign.
      ; (formalize-marriage ?betrothed)
      )))

; Reciprocal marriage: learning {?p spouse @self} while betrothed to ?p marries @self
; back in their own mind - the bride hears the vow at the altar; an absent bride
; learns by gossip and marries then.
(npc-think spouse_reciprocate
  (role @self -{@self spouse ?}
    (role ?p {@self fiancee ?p}
             {?p spouse @self}
      (effects
        (end-belief {@self fiancee ?p})
        (begin-belief {@self spouse ?p})))))
