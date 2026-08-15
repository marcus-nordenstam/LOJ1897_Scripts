; ----------------------------------------------------------------------------
; home_macros.hs - the "am I at my own home" convenience.
;
; UNAMBIGUOUS by construction: a home is ALWAYS a building (the address-on-the-premise
; model), so this is a plain (in-building @self <my home>) - it never mixes a building
; with a room, unlike the purged place-macros. It binds ?home from @self's OWN home
; belief and tests the native per-mind whereabouts index; a 2-pattern composition shared
; across ~18 lanes, so it earns its macro (the macro-worth bar: several patterns AND
; shared). Callers that already bind ?home should read (in-building @self ?home) directly.
; ----------------------------------------------------------------------------

(define-macro at-home ()
  (and (any {@self home ?}).target: ?home
       (in-building @self ?home)))
