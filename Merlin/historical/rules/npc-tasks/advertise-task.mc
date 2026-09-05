; ----------------------------------------------------------------------------
; advertise ?org - post the org's open staff role on the parish board. A COMPOSITION
; of general lego acts (no bespoke POST_ADVERT):
;   CREATE-ENTITY [k job-description] : pen the notice (born on the church board);
;   WRITE ?ad (written-msg {?org vacancy ?jk} {?org workplace ?wp})
;                                     : the whole notice in ONE act - the vacancy
;                                       (the ORG has an opening for role ?jk) and
;                                       where to apply. A seeker READs both and
;                                       adopts them; the workplace sentence is what
;                                       anchors the org for that reader, so it must
;                                       carry a BOUND ?wp - an unbound one writes a
;                                       hole and no seeker can act on the advert.
; The advert sits loose on the board (co-located reads find it); book-kept by
; {@self post ?ad ?org}. The role is derived from the org's OWN kind belief, the
; workplace from @self's {?org workplace} belief - no articles-doc read. One WRITE
; per advert is what lets the post rung read the outcome as a plain {.. WRITE ?ad ?}.
; ----------------------------------------------------------------------------

(npc-task {@self advertise ?org}:?adv-rel
  (tar org)
  (and
    ; The board is a church the officer KNOWS; knowing none, he searches the region for
    ; one (the find-building task), and gives up once that search has failed.
    (try
      (role ?board [k building church] (select (score (near @self ?board)) (policy roulette)))
      (when (not (spatial @self building ?board)))
      (effects (maintain-proposal {@self enter ?board})))
    (try
      (no-role [k building church])
      (when (and -{@self find-building [k building church] ? /fail}
                 (current-region @self): ?rg))
      (effects
               (maintain-proposal {@self find-building [k building church] ?rg})))
    (try
      (when (and (is-a (spatial @self building) [k building church])
                 -{@self CREATE-ENTITY [k job-description] /succ /caused_by ?adv-rel}))
      (effects
               (maintain-proposal {@self CREATE-ENTITY [k job-description]})))
    (try
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            (not (substantial (attr ?ad writing))))
      (when (and {?org isa ?ok}
                 {?org workplace ?wp}
                 (table-match org_staffing org-kind ?ok staff-role ?jk)
                 (is-kind ?jk)))
      (effects
               (maintain-proposal {@self WRITE ?ad (written-msg {?org vacancy ?jk}
                                                                {?org workplace ?wp})})))
    (try
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            -{@self post ?ad ?})
      (when {@self WRITE ?ad ? /succ})
      (effects (begin-belief {@self post ?ad ?org})))))
