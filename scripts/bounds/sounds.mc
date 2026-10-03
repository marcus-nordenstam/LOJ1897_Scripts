; ----------------------------------------------------------------------------
; sounds.mc - the size of every sound the town makes. A sound has no asset to take a
; box from, so its kind declares one: its radius IS how far it carries, through walls or
; not. The engine hears it, and (in-earshot ..) judges who would, within that radius of
; where it was made.
; ----------------------------------------------------------------------------

(include "../macros/tunables.mc")

(define-bounds speech (radius (k-speech-earshot)))

; A voice raised to call out to someone further off: a hail, and the answers to one.
(define-bounds shout (radius (k-call-earshot)))
