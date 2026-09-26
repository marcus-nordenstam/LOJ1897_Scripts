; ----------------------------------------------------------------------------
; count-orgs-isa - the town's live org census, read straight off the incorporation
; documents (no @gm registry attr). Scans every articles-of-incorporation and counts
; the ones whose org-kind cell is-a ?kind, returning the tally. A closed org's AOC is
; destroyed at wind-up, so the scan is self-pruning: it counts only live orgs.
;
;
;   (count-orgs-isa [k org K])  - how many live orgs is-a K.
; ----------------------------------------------------------------------------

(define-func count-orgs-isa (?kind)
  (bind 0 ?n)
  (for-each ?art (env-entities [k articles-of-incorporation])
    (form-match (attr ?art writing) articles_form [/org-kind ?coi-kind])
    (if (is-a ?coi-kind ?kind) (then (+= ?n 1))))
  ?n)

; (count-notices-for-kind ?org ?kind): how many notices this mind believes ?org has up for
; posts of ?kind. Belief-only, so legal in a (when).
(define-func count-notices-for-kind (?org ?kind)
  (bind 0 ?n)
  (for-each ?dr (every {?org display-ad ?})
    (if (= (kind ?dr.target) ?kind) (then (+= ?n 1))))
  ?n)

; articles-premises / articles-register - the building and the book an org's articles name,
; found in the world: the premises by the workplace address, the book as the one of the
; register kind carrying the org's name at those premises. @nothing when none stands.
(define-func articles-premises (?art)
  (bind @nothing ?found)
  (form-match (attr ?art writing) articles_form [/workplace ?ap-addr])
  (building-at ?ap-addr))

(define-func articles-register (?art)
  (bind @nothing ?found)
  (articles-premises ?art): ?ar-wp
  (form-match (attr ?art writing) articles_form [/org-name ?ar-name] [/register ?ar-kind])
  (for-each ?book (env-entities ?ar-kind)
    (if (and (= (attr ?book name) ?ar-name)
             (spatial ?book building ?ar-wp /env))
      (then
        (bind ?book ?found)
        (break))))
  ?found)

; ----------------------------------------------------------------------------
; headless-charter - the first charter of ?kind that no owner has been entered on, or @nothing.
;
; Returns @nothing rather than @fail on a miss: a `:`-bind of @fail ABORTS the rest of the
; sequence, and a founder scanning the config table for a post he could take must be free to
; try the next row. Gate the answer with (substantial ...).
; ----------------------------------------------------------------------------

(define-func headless-charter (?kind)
  (bind @nothing ?found)
  (for-each ?art (env-entities [k articles-of-incorporation])
    (form-match (attr ?art writing) articles_form [/org-kind ?hc-kind] [/owners ?hc-owners])
    (if (and (is-a ?hc-kind ?kind) (nothing ?hc-owners))
      (then
        (bind ?art ?found)
        (break))))
  ?found)
