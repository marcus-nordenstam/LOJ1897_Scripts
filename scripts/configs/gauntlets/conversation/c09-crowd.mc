; c09 crowd - four men and one woman under one roof, the house's supper hour unknown: every man
; hails her to ask it, in the same minute. Men may speak at once, but never two to her at once:
; whoever would speak to her while another is waits until that line is said. Seeds state only;
; the validate func reads.

(include "conversation.mc")

(define-list config
  seeds 4242 4243
  start 1700-01-01
  end 1700-01-31
  clock jump
  level "Theatres/demo_tech_level_v2.grs"
  startup c09-startup)

(define-list gauntlet validate c09-validate)

(define-func c09-startup ()
  (seed_property)
  (conversation-first-home): ?home
  (make-human ?home [k lower] [k male]): ?first
  (cast first ?first)
  (make-human ?home [k lower] [k male]): ?second
  (cast second ?second)
  (make-human ?home [k lower] [k male]): ?third
  (cast third ?third)
  (make-human ?home [k lower] [k male]): ?fourth
  (cast fourth ?fourth)
  (make-human ?home [k lower] [k female]): ?cook
  (cast cook ?cook)
  (initialize-minds)
  (wed-founders))

(define-func c09-validate ()
  (cast first): ?first
  (cast second): ?second
  (cast third): ?third
  (cast fourth): ?fourth
  (cast cook): ?cook
  (expect (> (+ (acts ?first hail started) (acts ?second hail started) (acts ?third hail started)
                (acts ?fourth hail started))
             2)
          "c09: fewer than three men hailed her")
  (expect (> (+ (flip (in-mind ?cook (took-in ?first)) 1 0) (flip (in-mind ?cook (took-in ?second)) 1 0)
                (flip (in-mind ?cook (took-in ?third)) 1 0) (flip (in-mind ?cook (took-in ?fourth)) 1 0))
             1)
          "c09: she took fewer than two men in")
  (expect (in-mind ?cook (= (spoken-over) 0)) "c09: two men spoke to her at once"))
