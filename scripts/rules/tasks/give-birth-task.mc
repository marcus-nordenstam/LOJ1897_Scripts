; ----------------------------------------------------------------------------
; give-birth ?father - a woman at term bears ?father's child, names it, and makes it and each of
; her other living children known to each other: she delivers (GIVE-BIRTH), holds the child hers,
; christens it (CHRISTEN) and holds its name, and her pregnancy is over. The introductions are a
; decision made for her - one intent per other child (drivers/introductions-driver.mc), worth more
; than anything she has going. The child is kept under the task's own key, so a restart reads it
; back instead of delivering a second. Proposed by deliver-driver (drivers/births-driver.mc).
; ----------------------------------------------------------------------------

(task {@self give-birth ?father}:?give-birth
  (tar [k human] @object)
  (sequence
    (stage
      (effects
        (if (bb-any ?give-birth child)
            (then (bind (bb-read ?give-birth child) ?child))
            (else (maintain-proposal {@self GIVE-BIRTH ?father}:?GIVE-BIRTH
                    [/postlude (bind (bb-read ?GIVE-BIRTH created) ?child)
                               (bb-write ?give-birth child ?child)])))))

    (stage
      (effects
        (bind (kin-label child ?child) ?bond)
        (begin-belief {@self ?bond ?child})))

    (stage
      (effects
        (if (unsubstantial (name ?child))
            (then (maintain-proposal {@self CHRISTEN ?child ?father}:?CHRISTEN
                    [/postlude (begin-belief {?child name (bb-read ?CHRISTEN name)})])))))

    (stage
      (effects
        (for-each ?bore (every {@self child ?})
          (bind ?bore.target ?sibling)
          (if (and (neq ?sibling ?child) (unsubstantial (any {?sibling condition [k dead]})))
              (then (begin-intent {@self intent {@self introduce ?child ?sibling}}
                                  [/utility crisis 1000]))))
        (end-belief {@self pregnant ?father})
        (set-outcome ?give-birth /succ)))))
