; ----------------------------------------------------------------------------
; acquisition_macros - shared vocabulary for the acquire / steal task chain: the
; concealment predicates a thief gates his grip on, plus the agent fee a hirer pays.
; Coin resolution / cost live in money_macros.hs; pile mutation in collection_macros.hs.
; ----------------------------------------------------------------------------

; (nobody-watching): env-truth - I am the only human in my space (no witness to a snatch).
(define-macro nobody-watching ()
  (= (count (spatial (spatial @self space) contents [k human] /env)) 1))

; (after-dark): the cover-of-darkness window (the now-hour clock is band-granular).
(define-macro after-dark ()
  (or (>= (now-hour) 22) (< (now-hour) 5)))

; (procure_fee): the coins a hired procurer takes on top of the item's price. Tunable.
(define-macro procure_fee () 20)
