; ----------------------------------------------------------------------------
; inherit - the named heir effects the estate (replaces C++ inherit_estate /
; inherit_or_dissolve_orgs). @self reads the public registers - no cross-mind
; touch - and re-points every record naming the deceased to @self:
;   - each title_deed the deceased owned: owner -> @self, and @self mints {own};
;   - each articles_of_incorporation the deceased founded: founder -> @self;
;   - the coin pile the will bequeathed (?pile, resolved from the will's location
;     descriptor): its count is merged into @self's own pile and the empty pile
;     destroyed, so @self keeps a single pile the coin-balance pointer reads.
; ?pile rides in from the {@self inherit ?pile} belief the will-reading adopted.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/collection-macros.mc")

(npc-action {@self INHERIT ?dead ?pile}
  (duration 240)
  (effects
    ; Buildings: every deed the deceased owned passes to @self.
    (for-each ?deed (env-entities [k title_deed])
      (do
        (table-match (attr ?deed writing) owner ?o building ?b)
        (if (= ?o ?dead)
            (then
              (table-set ?deed owner @self)
              (begin-belief {@self own ?b})))))
    ; Founded orgs: every org @self KNOWS the deceased founded passes to @self - a
    ; belief re-point in @self's own mind (founder is @excl, so it supersedes). No
    ; doc scan: @self walks his OWN {? founder ?dead} beliefs.
    (for-each ?forel (every {? founder ?dead})
      (bind ?forel.subject ?iorg)
      (begin-belief {?iorg founder @self}))
    ; Coins: merge the bequeathed pile into @self's own, then destroy the empty.
    (if (substantial ?pile)
        (then
          (pile-add (any {@self coin_pile ?}).target (attr ?pile count))
          (destroy-entity ?pile)))
    (set-outcome {@self INHERIT ?dead ?pile} /succ)))
