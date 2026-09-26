; ----------------------------------------------------------------------------
; founder-generation.mc - the part of world-gen that needs live minds: the founder
; generation arrives married, and the town's charters arrive headed. Both are beliefs a
; founder already holds on the first morning, minted into each mind by entering it -
; never decided by a rule, so nothing here competes, proposes or deliberates.
; Called by the startup func after (initialize-minds): a human cannot be the target of
; another mind's belief before the minds have perceived themselves.
; ----------------------------------------------------------------------------

; wed-founders - each founder marries the other founder of the other sex under his roof,
; the one he was minted beside. Each spouse holds his own half.
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
        (exit-mind)
        (break)))))

; seat-founding-heads - every founder old enough to head an institution takes up the first
; headless charter his class qualifies for, public orgs before businesses, one each.
(define-func seat-founding-heads ()
  (for-each ?h (env-entities [k human])
    (seat-founding-head ?h)))

(define-func seat-founding-head (?h)
  (enter-mind ?h)
  (if (>= (years-old @self) (founding_head_age_min))
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
    (if (and (substantial ?hcs-art) (class-at-least @self ?hcs-cf))
      (then
        (bind ?hcs-art ?found)
        (break))))
  ?found)

; charter-head-pos ?art - the head's job for the org kind ?art charters.
(define-func charter-head-pos (?art)
  (form-match (attr ?art writing) articles_form [/org-kind ?chp-kind])
  (if (table-match public_orgs kind ?chp-kind head-pos ?chp-hp)
      (then ?chp-hp)
      (else (if (table-match cornerstone_businesses kind ?chp-kind head-pos ?chp-cb)
                (then ?chp-cb)
                (else @nothing)))))

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
