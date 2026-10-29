; ----------------------------------------------------------------------------
; founder-generation.mc - the part of world-gen that needs live minds: the founder
; generation arrives married, and the town's charters arrive headed. Both are beliefs a
; founder already holds on the first morning, minted into each mind by entering it -
; never decided by a rule, so nothing here competes, proposes or deliberates.
; Called by the startup func after (initialize-minds): a human cannot be the target of
; another mind's belief before the minds have perceived themselves.
; ----------------------------------------------------------------------------

; wed-founders - each founder marries the other founder of the other sex under his roof,
; the one he was minted beside. Each spouse holds his own half, and knows the other's home is his.
(define-func wed-founders ()
  (for-each ?h (env-entities [k human])
    (wed-founder ?h)))

(define-func wed-founder (?h)
  (spatial ?h building /env): ?wf-home
  (for-each ?m (env-entities [k human])
    (if (and (spatial ?m building ?wf-home /env)
             (not (= (attr ?m gender) (attr ?h gender))))
      (then
        (enter-mind ?h)
        (observe ?m): ?wf-spouse
        (begin-belief {?wf-spouse name (attr ?m name)})
        (begin-belief {@self spouse ?wf-spouse})
        ; They were minted under one roof, so each knows the other lives where he does.
        (bind (any {@self home ?}) ?wf-own-home)
        (if (is-belief ?wf-own-home)
            (then (begin-belief {?wf-spouse home ?wf-own-home.target})))
        (exit-mind)
        (break)))))

; seat-founding-heads - every founder old enough to head an institution takes up the first
; headless charter his class qualifies for, public orgs before businesses, one each.
(define-func seat-founding-heads ()
  (for-each ?h (env-entities [k human])
    (seat-founding-head ?h)))

(define-func seat-founding-head (?h)
  (enter-mind ?h)
  (any {@self age ?age})
  (if (>= ?age (founding_head_age_min))
    (then
      (bind (headless-charter-for-self public_orgs) ?sfh-art)
      (if (not (substantial ?sfh-art))
        (then (bind (headless-charter-for-self cornerstone_businesses) ?sfh-art)))
      (if (substantial ?sfh-art)
        (then (take-up-charter ?sfh-art (charter-head-pos ?sfh-art))))))
  (exit-mind))

; headless-charter-for-self ?table - the first headless charter among ?table's kinds whose
; class floor @self meets, or @nothing.
(define-func headless-charter-for-self (?table)
  (bind @nothing ?found)
  (for-each-row ?table [/kind ?hcs-kind] [/class-floor ?hcs-cf]
    (headless-charter ?hcs-kind): ?hcs-art
    (if (and (substantial ?hcs-art) (>= (cond
                                          (case {@self class-situation [k upper]}  2)
                                          (case {@self class-situation [k middle]} 1)
                                          (case {@self class-situation [k lower]}  0)
                                          (else -1)) (switch (kind ?hcs-cf)
                                                       (on [k upper]  2)
                                                       (on [k middle] 1)
                                                       (else 0))))
      (then
        (bind ?hcs-art ?found)
        (break))))
  ?found)

; charter-head-pos ?art - the head's job for the org kind ?art charters.
(define-func charter-head-pos (?art)
  (form-match (attr ?art writing) articles_form [/org-kind ?chp-kind])
  (flip (table-match public_orgs kind ?chp-kind head-pos ?chp-hp)
        ?chp-hp
        (flip (table-match cornerstone_businesses kind ?chp-kind head-pos ?chp-cb) ?chp-cb @nothing)))

; take-up-charter - @self heads an org the town already chartered: the premises, articles and
; staff book exist and only the head seat is open, so heading it is his name entered as the
; articles' owner and his seat on the book. The deed is NOT claimed - taking a post is not buying the
; premises.
(define-func take-up-charter (?art ?head-role)
  (articles-premises ?art): ?tuc-wp
  (articles-register ?art): ?tuc-reg
  (check (substantial ?tuc-wp))
  (check (substantial ?tuc-reg))
  (take-premises ?tuc-wp)
  (name @self): ?tuc-name
  (add-table-entry ?art (table-entry articles_form owners
                          [[owner ?tuc-name] [is-org @false] [struck @false]]))
  (seat-org-head ?art ?tuc-wp ?tuc-reg ?head-role))

; found-households - every founder's household is an org he holds himself and his co-founders
; members of. Founders under one roof are seated in its first room (make-human), so at
; bootstrap the room they stand in is the home they share.
(define-func found-households ()
  (for-each ?h (env-entities [k human])
    (found-household ?h)))

(define-func found-household (?h)
  (spatial ?h space /env): ?fh-room
  (enter-mind ?h)
  (o [k household] {@self member-of @o}): ?fh-household
  (begin-belief {@self member-of ?fh-household})
  (for-each ?m (env-entities [k human])
    (if (and (not (= ?m ?h)) (= (spatial ?m space /env) ?fh-room))
        (then
          (observe ?m): ?fh-member
          (begin-belief {?fh-member member-of ?fh-household}))))
  (exit-mind))

; join-parishes - every founder belongs to the parish: he knows the church org by its articles,
; as its head does (seat-org-head), and is a member of it.
(define-func join-parishes ()
  (bind @nothing ?jp-art)
  (for-each ?art (env-entities [k articles-of-incorporation])
    (form-match (attr ?art writing) articles_form [/org-kind ?jp-kind])
    (if (is-a ?jp-kind [k church-org])
        (then
          (bind ?art ?jp-art)
          (break))))
  (if (substantial ?jp-art)
      (then
        (for-each ?h (env-entities [k human])
          (join-parish ?h ?jp-art)))))

(define-func join-parish (?h ?art)
  (enter-mind ?h)
  (observe ?art)
  (adopt-aoc ?art)
  (o {?art declares-org @o}): ?jp-church
  (begin-belief {@self member-of ?jp-church})
  (exit-mind))
