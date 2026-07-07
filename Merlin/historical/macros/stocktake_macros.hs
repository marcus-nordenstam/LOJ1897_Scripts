; ----------------------------------------------------------------------------
; stocktake_macros - the deliberate whereabouts-validation vocabulary.
;
; Disproving absence is DELIBERATE WORK, never an ambient gift: the engine's
; per-completion verify covers only goal-ATTENDED objects (the reach-for-it
; moment), and everything else stays believed until someone whose job it is
; goes and LOOKS. That act is the stocktake: stand at the premises, walk what
; you believe is here, and end the whereabouts of whatever is not where you
; left it. The whole algorithm is authored here from the general composable
; ops - (for-each-belief {[k food]:?item location ?room} ..) iterates my own
; believed-in-?room food (the subject slot IS the loop binding, kind-cast
; inline), (attr ?item location) reads where each actually is (a destroyed
; item reads as nothing, and an item squirreled into a hidden cache reads
; the CACHE sub-space, not this room - either way the miss IS the
; discovery), (end-belief {..}) closes the miss. The now-past interval
; remains as "it used to be here" testimony.
;
; take-stock-of-provisions: validate @self's believed-in-?room food against
; the room's actual contents. Specialized to [k food] (the kind lives in the
; compound subject token, out of reach of node-level macro substitution -
; and WHAT gets stocktaken is content anyway; clone for other inventories).
; The CALLER gates the physical plausibility (@self must BE at the premises
; - walking the building's rooms during the stocktake act is the act's own
; granularity) and walks the rooms:
;   (for-each ?room (attr-values <building> parts [k interior_space room])
;     (take-stock-of-provisions ?room))
; ----------------------------------------------------------------------------

(define-macro take-stock-of-provisions (?room)
  (for-each-belief {[k food]:?item location ?room}
    (if (not (= (attr ?item location) ?room))
        (end-belief {?item location ?room}))))
