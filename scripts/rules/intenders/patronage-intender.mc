; ----------------------------------------------------------------------------
; patronage - a man of standing, high prestige and an exemplary reputation, resolves to
; take a lower-class connection under his wing: the intent {@self intent {@self sponsor
; ?protege}}, caused by the repute that makes it his to give. The sponsor driver
; (drivers/sponsor-driver.mc) proposes it when they meet, and the sponsor task tells the
; protege he is backed - the `backed-by` belief business-founding gates on as a means-branch.
;
; Differs from `investment` in direction: investment is candidate-led (a worthy clerk seeks
; a backer), patronage is patron-led (an established man chooses to elevate someone). The
; per-patron (chance) is monthly, /12 of the old annual rate (0.06 -> 0.005).
;
; class-situation values are upper / middle / lower; the (or ...) below encodes the valid
; downward sponsorships - an upper patron elevates a middle or lower protege, a middle one a
; lower protege. Same-class is excluded: patronage is class-bridging by definition.
; ----------------------------------------------------------------------------


(intender patronage
  (cooldown 1 m try-once)
  (rng-stream business)

  (role @self {@self age ?age} {@self isa [k human], condition [k alive]}
              {@self age-band [k youth|young-adult|middle-aged|mature|elderly]}
              {@self repute [k exemplary]}:?repute
              {@self prestige ?prestige}
    ;; A protege one or more class steps below the patron, of sound character (not KNOWN
    ;; scandalous), a working-age adult, whom the patron does not know to be backed - all
    ;; judged from the patron's own beliefs.
    (role ?protege {?protege isa [k human], condition [k alive]}
                   {?protege age-band [k youth|young-adult|middle-aged]}
                   -{?protege repute [k scandalous]}
                   -{?protege backed-by ?}
                   (or (and {@self    class-situation [k upper]}
                            {?protege class-situation [k middle]})
                       (and {@self    class-situation [k upper]}
                            {?protege class-situation [k lower]})
                       (and {@self    class-situation [k middle]}
                            {?protege class-situation [k lower]}))

      (when (and (latch-eval (chance 0.005))
                 (>= ?age 35)
                 (>= ?prestige 0.65)))

      (declare-utility want)
      (effects
        (maintain-intent {@self intent {@self sponsor ?protege}} /caused_by ?repute)))))
