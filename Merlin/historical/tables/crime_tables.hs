; ----------------------------------------------------------------------------
; crime_tables.hs - authored config the C++ acquisition + skill-derive paths read
; via hse_table_lookup / hse_table_for_each_all (was the perpetration.hsc method-table
; parser; the method table itself is retired - methods are now real strike actions and
; the crime tasks). Keyed by KIND casts so the C++ side compares kind_ids.
;
; Item prices moved to the ontology: each item kind carries a (price N) clause in
; Objects.mon, read by t_ontology::price (and the (price ...) op).
; ----------------------------------------------------------------------------

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
