; ----------------------------------------------------------------------------
; inherit - the named heir effects the estate (replaces C++ inherit_estate /
; inherit_or_dissolve_orgs). @self reads the public registers - no cross-mind
; touch - and re-points every record naming the deceased to @self:
;   - each title_deed the deceased owned: owner -> @self, and @self mints {own};
;   - each articles_of_incorporation the deceased founded: founder -> @self;
;   - then probate CONSUMES the will (destroys it), which withdraws the standing
;     settle_inheritance proposal (its (when) no longer finds a matching will).
;
; Coins are NOT claimed here: a coin pile carries no owner attr, so a heir cannot
; tell the deceased's pile from a co-resident's in a shared home - that awaits a
; pile-owner marker (the theft/ownership redesign). Business premises / rentals
; ride their deeds above; a heir-less estate is left for a later administrator.
; ----------------------------------------------------------------------------

(npc-action {@self INHERIT ?dead}
  (duration 240)
  (effects
    ; Buildings: every deed the deceased owned passes to @self.
    (for-each ?deed (documents [k title_deed])
      (do
        (read-doc-record [k title_deed] ?deed (owner ?o) (building ?b))
        (if (= ?o ?dead)
            (then
              (update-doc-record [k title_deed] ?deed (owner @self))
              (begin-belief {@self own ?b})))))
    ; Founded orgs: every articles the deceased founded passes to @self.
    (for-each ?art (documents [k articles_of_incorporation])
      (do
        (read-doc-record [k articles_of_incorporation] ?art (founder ?f))
        (if (= ?f ?dead)
            (then
              (update-doc-record [k articles_of_incorporation] ?art (founder @self))))))
    ; Probate: the will is spent - destroy it (guards settle_inheritance re-fire).
    (for-each ?w (documents [k will])
      (do
        (read-doc-record [k will] ?w (testator ?t))
        (if (= ?t ?dead)
            (then
              (destroy-entity ?w)
              (break)))))
    (set-outcome {@self INHERIT ?dead} succ)))
