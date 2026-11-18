; The bring-up of the dialogue test world (dialogue_world.mc).

(define-func dialogue-room-in-a-home (?room-kind ?not-in)
  (bind @nothing ?found)
  (for-each ?b (env-entities [k residential-building])
    (if (neq ?b ?not-in)
        (then
          (for-each ?unit (spatial ?b parts [k unit] /env)
            (for-each ?room (spatial ?unit rooms /env)
              (if (eq (kind ?room) ?room-kind)
                  (then (bind ?room ?found) (break))))
            (if (substantial ?found) (then (break))))))
    (if (substantial ?found) (then (break))))
  (check (substantial ?found))
  ?found)

(define-func dialogue-nationality (?h ?nat)
  (enter-mind ?h)
  (end-belief (any {@self nationality ?}))
  (begin-belief {@self nationality ?nat})
  (exit-mind))

(define-func dialogue-startup ()
  (seed_property)
  (dialogue-room-in-a-home [k bedroom] @nothing): ?bedroom
  (spatial ?bedroom unit /env): ?his-home
  (make-human ?his-home [k lower] [k male]): ?man
  (set-attr ?man name [n Wilbur Parker])
  (set-attr ?man birth-date (create-date 1663 7 11))
  (dialogue-nationality ?man [k english])
  (cast interviewee ?man)
  (cast bedroom ?bedroom)
  (head (env-entities [k study])): ?study
  (check (substantial ?study))
  (cast study ?study)
  (dialogue-room-in-a-home [k bedroom] (spatial ?his-home building /env)): ?her-bedroom
  (make-human (spatial ?her-bedroom unit /env) [k lower] [k female]): ?woman
  (set-attr ?woman name [n Zelie Dupre])
  (cast seen-woman ?woman)
  (initialize-minds))
