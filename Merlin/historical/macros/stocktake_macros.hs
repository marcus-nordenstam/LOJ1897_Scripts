; ----------------------------------------------------------------------------
; stocktake_macros - the deliberate whereabouts-validation vocabulary.
;
; Disproving absence is DELIBERATE WORK, never an ambient gift: the engine's
; per-completion verify covers only goal-ATTENDED objects (the reach-for-it
; moment), and everything else stays believed until someone whose job it is
; goes and LOOKS. That act is the stocktake: stand at the premises, walk what
; you believe is here, and end the whereabouts of whatever is not where you
; left it. The whole algorithm is authored here from the general composable
; ops - (for-each-present-tense-belief {[k ?kind]:?item location ?room} ..) iterates my
; own believed-in-?room items of the kind (the subject slot IS the field
; binding, kind-cast inline; the macro's ?kind splices into the [k ...]
; payload), (attr ?item location) reads where each actually is (a destroyed
; item reads as nothing, and an item squirreled into a hidden cache reads
; the CACHE sub-space, not this room - either way the miss IS the
; discovery), (end-belief {..}) closes the miss. The now-past interval
; remains as "it used to be here" testimony.
;
; take-stock-of: validate @self's believed-in-?room items of ?kind against
; the room's actual contents. The CALLER gates the physical plausibility
; (@self must BE at the premises - walking the building's rooms during the
; stocktake act is the act's own granularity) and walks the rooms:
;   (for-each ?room (attr-values <building> parts [k interior_space room])
;     (take-stock-of ?room [k food]))
; ----------------------------------------------------------------------------

(define-macro take-stock-of (?room ?kind)
  (for-each ?ib (every {? location ?room})
    ?ib.subject: ?item
    (if (and (is-a ?item [k ?kind])
             (not (= (attr ?item location) ?room)))
        (then (end-belief ?ib)))))
