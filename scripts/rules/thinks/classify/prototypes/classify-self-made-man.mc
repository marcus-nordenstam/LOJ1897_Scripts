; self-made-man: rising trajectory + arrived class + low breeding + reputable.
(think classify-self-made-man
  ; Toggle over the situation bands + repute (a Tier-2 sibling this reads);
  ; breeding is birth-seeded (inert). It drops when any input band toggles off.
  (rng-stream behaviour)
  (role @self {@self class-situation ?, breeding ?breeding}
    (effects
      (mint-band {@self prototype}
        (* (prob {@self social-trajectory [k rising]})
           (clamp (+ (prob {@self class-situation [k middle]})
                     (prob {@self class-situation [k upper]})) 0.0 1.0)
           (<= ?breeding 0.40)
           (clamp (+ (prob {@self repute [k exemplary]})
                     (prob {@self repute [k respectable]})) 0.0 1.0))
        [k self-made-man] 0.5))))
