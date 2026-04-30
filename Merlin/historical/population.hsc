; ----------------------------------------------------------------------------
; population.hsc - founder families for the St-Revier 1700 historical sim.
;
; Each (family ...) form expands into:
;   - one family object in Port Christie
;   - one npc per member, parented to the family
;   - kin beliefs: married_to(head, spouse), bio_parent_of(parent, child)
;   - residence beliefs: lives_in(member, residence)
;
; Form:
;   (family <Surname> <class> [<residence-id>]
;     (head   <given-name> <gender> <age>)
;     (spouse <given-name> <gender> <age>)
;     (child  <given-name> <gender> <age>)
;     ...)
;
; <class>          = lower | middle | upper
; <gender>         = male | female
; <age>            = years at sim start (back-computed to birth_ym)
; <residence-id>   = id of a building from geography.hsc
; ----------------------------------------------------------------------------

;; --- Upper class ---
(family Beauregard upper blackthorne_estate
  (head   Henri    male   42)
  (spouse Marie    female 38)
  (child  Jacques  male   14)
  (child  Elise    female 10))

(family Ashworth upper ashworth_house
  (head   Edmund    male   55)
  (spouse Catherine female 50)
  (child  Julian    male   22)
  (child  Lavinia   female 18))

;; --- Middle class ---
(family Duval middle duval_townhouse
  (head   Pierre  male   35)
  (spouse Claire  female 32)
  (child  Thomas  male   8))

(family Whitfield middle whitfield_townhouse
  (head   George   male   40)
  (spouse Anna     female 36)
  (child  Margaret female 12)
  (child  Edwin    male   6))

;; --- Lower class ---
(family Carrigan lower carrigan_cottage
  (head   William male   28)
  (spouse Rose    female 26)
  (child  Daniel  male   3))

(family O_Connell lower oconnell_cottage
  (head   Liam     male   33)
  (spouse Bridget  female 29)
  (child  Cathleen female 5))
