; ----------------------------------------------------------------------------
; npc_traits.hs - the founder trait distributions, as authored config (define-table),
; migrated out of the old npc_traits/*.txt frequency files. make-human-founder draws
; each singular trait with (table-sample-weighted <dist> value weight) and each
; continuous trait with (sample-gaussian <mean> <sigma>) over continuous_traits.
;
;   value  - the trait value kind ([k gender male], [k appearance ugly], ...)
;   weight - the relative frequency (a bare integer)
; ----------------------------------------------------------------------------

(define-table gender_dist
  (fields value weight)
  (record [k male]   49)
  (record [k female] 51))

(define-table appearance_dist
  (fields value weight)
  (record [k appearance ugly]          1)
  (record [k appearance plain-looking] 4)
  (record [k appearance beautiful]     2))

(define-table girth_dist
  (fields value weight)
  (record [k girth thin]   1)
  (record [k girth medium] 4)
  (record [k girth fat]    2))

(define-table height_dist
  (fields value weight)
  (record [k height short]  1)
  (record [k height medium] 4)
  (record [k height tall]   1))

(define-table hair_color_dist
  (fields value weight)
  (record [k hair-color brown]  5)
  (record [k hair-color black]  3)
  (record [k hair-color blonde] 2)
  (record [k hair-color auburn] 1)
  (record [k hair-color red]    1))

(define-table eye_color_dist
  (fields value weight)
  (record [k eye-color brown] 4)
  (record [k eye-color blue]  4)
  (record [k eye-color green] 2)
  (record [k eye-color hazel] 2)
  (record [k eye-color grey]  1))

(define-table nationality_dist
  (fields value weight)
  (record [k st-revieran] 3)
  (record [k english]     2)
  (record [k irish]       1))

; The continuous genetic traits (Big-Five aspects + dark tetrad + attractiveness +
; physical). mean is sex-conditioned (strength / endurance dimorphic; the rest 0.5);
; every trait samples N(mean, sigma) clamped 0..1.
(define-table continuous_traits
  (fields trait mean-male mean-female sigma)
  (record openness         0.5  0.5  0.15)
  (record intellect        0.5  0.5  0.15)
  (record industriousness  0.5  0.5  0.15)
  (record orderliness      0.5  0.5  0.15)
  (record enthusiasm       0.5  0.5  0.15)
  (record assertiveness    0.5  0.5  0.15)
  (record compassion       0.5  0.5  0.15)
  (record politeness       0.5  0.5  0.15)
  (record volatility       0.5  0.5  0.15)
  (record withdrawal       0.5  0.5  0.15)
  (record narcissism       0.5  0.5  0.15)
  (record machiavellianism 0.5  0.5  0.15)
  (record psychopathy      0.5  0.5  0.15)
  (record sadism           0.5  0.5  0.15)
  (record attractiveness   0.5  0.5  0.15)
  (record strength         0.6  0.4  0.15)
  (record dexterity        0.5  0.5  0.15)
  (record agility          0.5  0.5  0.15)
  (record endurance        0.55 0.45 0.15))
