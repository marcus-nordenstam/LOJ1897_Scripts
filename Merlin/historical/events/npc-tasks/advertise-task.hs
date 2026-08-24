; ----------------------------------------------------------------------------
; advertise ?org - post the org's disclosed staff role on the parish board (a subtask of
; recruit_staff). Go to the board, post the advert (POST_ADVERT, whose target is the org's
; ARTICLES - an org can never ride an act - and whose aux is the staff role), then
; book-keep {@self post ?ad ?org}. The subtask has no explicit outcome: recruit_staff's
; advertise rung withdraws the maintain once {@self post ? ?org} exists.
; ----------------------------------------------------------------------------

(npc-task {@self advertise ?org}
  (tar org)
  (and
    (try
      (when (and (find-building [k building church]): ?board
                 (not (spatial @self building ?board))))
      (effects (maintain-proposal {@self enter ?board})))
    (try
      (when (and (any {?org record ?}).target: ?art
                 (find-building [k building church]): ?board
                 (spatial @self building ?board)
                 (read-doc-record [k articles_of_incorporation] ?art (kind ?ok))
                 (table-lookup org_staffing org_kind ?ok staff_role none): ?jk
                 (is-kind ?jk)))
      (effects (debug-print "RC_ADPOST") (maintain-proposal {@self POST_ADVERT ?art ?jk})))
    (try
      (role ?ad [k job_description]
                (not {@self post ?ad ?})
                (select (policy first-match)))
      (when (and (any {?org record ?}).target: ?art
                 (any {@self POST_ADVERT ?art /succ})
                 (read-doc-record [k job_description] ?ad (find org_record ?art))))
      (effects (begin-belief {@self post ?ad ?org})))))
