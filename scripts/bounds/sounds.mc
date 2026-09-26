; ----------------------------------------------------------------------------
; sounds.mc - the size of every sound the town makes. A sound has no asset to take a
; box from, so its kind declares one: its half-extents ARE how far it carries. The
; engine hears it within that box, never past the speaker's space.
; ----------------------------------------------------------------------------

(define-macro k-speech-earshot () 6.0)

(define-bounds speech (radius (k-speech-earshot)))
