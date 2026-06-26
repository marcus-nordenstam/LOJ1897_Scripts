; ----------------------------------------------------------------------------
; cornerstone_businesses.hs - the private businesses the town opens WITH, as
; authored config (a (define-table ...), like public_orgs).
;
; These are the economic seed: the handful of trades that must exist from the
; cold start (1700) so the town has a bank, a solicitor, an apothecary, a pub and
; a grocer before the emergent business homeostat (business.hs) takes over and
; founds the rest on demand. Read by the (startup) found_cornerstone_business
; event via (for-each-table-record ...): the first eligible adult of the right
; class founds each still-missing one through found-org-seq, head-only - the
; labour market staffs it over subsequent ticks. Replaces the C++ bootstrap_orgs
; cornerstone loop (retired).
;
;   kind        - the business org kind ([k org <leaf>], a `business` sub-kind)
;   head_pos    - the founder's job, a scoped job kind ([k job <role>])
;   class_floor - the founder's minimum class ([k lower|middle|upper])
; ----------------------------------------------------------------------------

(define-table cornerstone_businesses
  (fields kind head_pos class_floor)
  (record [k org bank]           [k job banker]     [k middle])
  (record [k org solicitor_firm] [k job solicitor]  [k middle])
  (record [k org apothecary]     [k job apothecary] [k middle])
  (record [k org pub]            [k job bartender]  [k lower])
  (record [k org grocer]         [k job shop_clerk] [k lower]))
