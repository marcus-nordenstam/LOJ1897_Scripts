; ----------------------------------------------------------------------------
; stocktake_macros - the deliberate whereabouts-validation vocabulary.
;
; Disproving absence is DELIBERATE WORK, never an ambient gift: the engine's
; per-completion verify covers only goal-ATTENDED objects (the reach-for-it
; moment), and everything else stays believed until someone whose job it is
; goes and LOOKS. That act is the stocktake: stand at the premises, walk what
; you believe is here, and end the whereabouts of whatever is not where you
; left it. The whole algorithm is authored here from the general composable
; ops - (spatial ?room contents) lists the items my spatial index believes are in
; ?room, (spatial ?item space /env) reads where each actually is (a destroyed item reads
; as nothing, and an item squirreled into a hidden cache reads the CACHE sub-space,
; not this room - either way the miss IS the discovery), (retire-whereabouts ?item)
; evicts the miss from the index (releasing its reality-chain peg). The now-closed
; node remains as "it used to be here" testimony while another mind still pegs it.
;
; take-stock-of: validate @self's believed-in-?room items of ?kind against
; the room's actual contents. The CALLER gates the physical plausibility
; (@self must BE at the premises - walking the building's rooms during the
; stocktake act is the act's own granularity) and walks the rooms:
;   (for-each ?room (spatial <building> parts [k interior_space room] /env)
;     (take-stock-of ?room [k food]))
; ----------------------------------------------------------------------------

(define-macro take-stock-of (?room ?kind)
  (for-each ?item (spatial ?room contents)
    (if (and (is-a ?item [k ?kind])
             (!= (spatial ?item space /env) ?room))
        (then (retire-whereabouts ?item)))))
