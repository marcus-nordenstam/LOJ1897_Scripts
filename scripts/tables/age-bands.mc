; ----------------------------------------------------------------------------
; age-bands.mc - the perceptible age ladder, as authored data.
;
; Age is never read as a number by a rule. Every mind holds a PERCEIVED band
; belief about the people it has seen - {?o age-band <band>} - and role filters
; test the band. This table is where the ladder lives; macros/age-macros.mc reads
; the same bands in its threshold predicates and MUST stay in lockstep with it.
;
;   band     - the band kind stamped on the age-band attr
;   min-age  - the age in whole years at which the band begins. ROWS ASCEND: the
;              walk keeps the LAST row whose min-age the age has reached, so the
;              order of the rows IS the ladder.
;   span-*   - the +/-1 proximity window written to the age-span attr, which is
;              what the age-peer checks read ("same or adjacent band") without
;              doing arithmetic. The end bands clamp against themselves.
;
; Narrow under 30, wide at 30+: an age-peer is a tight notion among the young and
; a loose one among adults, and that asymmetry is the whole point of the ladder.
; ----------------------------------------------------------------------------

(define-table age_bands
  (fields band min-age span-lo span-mid span-hi)
  (record [k infant]        0  [k infant]       [k infant]       [k juvenile])
  (record [k juvenile]      3  [k infant]       [k juvenile]     [k adolescent])
  (record [k adolescent]   10  [k juvenile]     [k adolescent]   [k youth])
  (record [k youth]        16  [k adolescent]   [k youth]        [k young-adult])
  (record [k young-adult]  18  [k youth]        [k young-adult]  [k middle-aged])
  (record [k middle-aged]  30  [k young-adult]  [k middle-aged]  [k mature])
  (record [k mature]       50  [k middle-aged]  [k mature]       [k elderly])
  (record [k elderly]      70  [k mature]       [k elderly]      [k elderly]))
