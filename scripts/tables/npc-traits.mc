; ----------------------------------------------------------------------------
; npc_traits.mc - the trait distributions more than one human-minting path draws
; from (founders, the player, immigrants, births), each sampled with
; (table-sample-weighted <dist> value weight). The distributions only one path reads
; live with it, in funcs/human-traits.mc.
;
;   value  - the trait value kind ([k gender male], [k appearance ugly], ...)
;   weight - the relative frequency (a bare integer)
; ----------------------------------------------------------------------------

(define-table gender_dist
  (fields value weight)
  (record [k male]   49)
  (record [k female] 51))

(define-table nationality_dist
  (fields value weight)
  (record [k st-revieran] 3)
  (record [k english]     2)
  (record [k irish]       1))

