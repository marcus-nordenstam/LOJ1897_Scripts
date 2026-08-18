; ----------------------------------------------------------------------------
; crime_tables.hs - authored config the C++ acquisition + skill-derive paths read
; via hse_table_lookup / hse_table_for_each_all (was the perpetration.hsc method-table
; parser; the method table itself is retired - methods are now real strike actions and
; the crime tasks). Keyed by KIND casts so the C++ side compares kind_ids.
; ----------------------------------------------------------------------------

; Item prices (shillings) - the acquisition calculus's affordability gate. A purchase
; requires bank_balance >= price and debits it. Lookup is most-specific-first: an exact
; kind row wins, else the first row the candidate's kind is-a (a firearm row covers every
; gun leaf). Unlisted kinds use the engine default (cheap everyday goods anyone can buy).
; Scale: bank_balance ranges roughly 0..150 (wealth = balance/120).
(define-table item_prices
  (fields kind             price)
  (record [k firearm]      60)
  (record [k explosive]    40)
  (record [k toxin]         8)
  (record [k candlestick]  12)
  (record [k oil_lamp]      4)
  (record [k axe]           3)
  (record [k cleaver]       3)
  (record [k knife]         2)
  (record [k hammer]        2)
  (record [k rope]          1))

; Skill-affinity map: an actor skilled_in <domain> picks the mapped methods more readily
; (the hsim_derive band-raise pass reads this). Domains are `domain` sub-kinds; methods
; are strike-action / kill-method atoms. One (domain, method) pair per record.
(define-table skill_affinity
  (fields domain                    method)
  (record [k poisoning_knowledge]   poison)
  (record [k medicine]              poison)
  (record [k marksmanship]          shoot)
  (record [k knife_fighting]        stab)
  (record [k knife_fighting]        slash)
  (record [k pugilism]              beat_to_death)
  (record [k pugilism]              strangle)
  (record [k wrestling]             strangle)
  (record [k wrestling]             beat_to_death)
  (record [k garrotting]            garrotte)
  (record [k garrotting]            strangle)
  (record [k garrotting]            bludgeon))
