; ----------------------------------------------------------------------------
; cornerstone_businesses.hs - the private businesses the town opens WITH, as
; authored config (a (define-table ...), like public_orgs).
;
; These are the economic seed: the handful of trades that must exist from the
; cold start (1700) so the town has a bank, a solicitor, an apothecary, a pub and
; a grocer before the emergent business homeostat (business.hs) takes over and
; founds the rest on demand. Read by the (startup) found_cornerstone_business
; rule via (for-each-table-record ...): the first eligible adult of the right
; class founds each still-missing one through found-org-seq, head-only - the
; labour market staffs it over subsequent ticks. Replaces the C++ bootstrap_orgs
; cornerstone loop (retired).
;
;   kind        - the business org kind ([k org <leaf>], a `business` sub-kind)
;   head-pos    - the founder's job, a scoped job kind ([k job <role>])
;   class-floor - the founder's minimum class ([k lower|middle|upper])
; ----------------------------------------------------------------------------

(define-table cornerstone_businesses
  (fields kind head-pos class-floor)
  (record [k org bank]           [k job banker]     [k middle])
  (record [k org solicitor-firm] [k job solicitor]  [k middle])
  (record [k org apothecary]     [k job apothecary] [k middle])
  ; The head seat is a HEAD kind (is-a head-of-non-household-org) - the one-org
  ; founding cap and the duty argmax both read head-ness off the job kind, so a
  ; staff kind here would make the founder invisible to both. Staff (bartender /
  ; shop-clerk) are hired by the labour market, never seated as the head.
  (record [k org pub]            [k job proprietor] [k lower])
  (record [k org grocer]         [k job proprietor] [k lower]))
