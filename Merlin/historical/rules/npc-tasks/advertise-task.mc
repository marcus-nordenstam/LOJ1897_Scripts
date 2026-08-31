; ----------------------------------------------------------------------------
; advertise ?org - post the org's open staff role on the parish board. A COMPOSITION
; of general lego acts (no bespoke POST_ADVERT):
;   CREATE_ENTITY [k job-description] : pen the notice (born on the church board);
;   WRITE ?ad {?org vacancy ?jk}      : the vacancy - the ORG has an opening for role
;                                       ?jk (a seeker READs + adopts this);
;   WRITE ?ad {?org workplace ?wp}    : where to apply (appended second sentence -
;                                       the workplace anchors the org for the reader).
; The advert sits loose on the board (co-located reads find it); book-kept by
; {@self post ?ad ?org}. The role is derived from the org's OWN kind belief, the
; workplace from @self's {?org workplace} belief - no articles-doc read.
; ----------------------------------------------------------------------------

(npc-task {@self advertise ?org}:?adv-rel
  (tar org)
  (and
    (try
      (when (and (find-building [k building church]): ?board
                 (not (spatial @self building ?board))))
      (effects (maintain-proposal {@self enter ?board})))
    (try
      (when (and (find-building [k building church]): ?board
                 (spatial @self building ?board)
                 -{@self CREATE_ENTITY [k job-description] /succ /caused_by ?adv-rel}))
      (effects (debug-print "ADV_PEN")
               (maintain-proposal {@self CREATE_ENTITY [k job-description]})))
    (try
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            (not (substantial (attr ?ad writing))))
      (when (and {?org isa ?ok}
                 (table-match org_staffing org-kind ?ok staff-role ?jk)
                 (is-kind ?jk)))
      (effects (debug-print "ADV_VACANCY")
               (maintain-proposal {@self WRITE ?ad {?org vacancy ?jk}})))
    (try
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            (substantial (attr ?ad writing)))
      (when (and {?org workplace ?wp}
                 -{@self WRITE ?ad {?org workplace ?wp} /succ}))
      (effects (debug-print "ADV_WHERE")
               (maintain-proposal {@self WRITE ?ad {?org workplace ?wp}})))
    (try
      (role ?ad [k job-description] (spatial ?ad co-located @self)
            -{@self post ?ad ?})
      (when {@self WRITE ?ad {?org workplace ?} /succ})
      (effects (debug-print "ADV_BOOK") (begin-belief {@self post ?ad ?org})))))
