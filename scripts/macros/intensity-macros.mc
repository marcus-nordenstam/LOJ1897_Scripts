; ----------------------------------------------------------------------------
; intensity_macros.mc - the DRIVE-SHAPE helpers a desire's (utility) is built from.
;
; Three canonical intensity shapes, each returning a value on the shared ~0..100
; competition scale (?scale sets the reference magnitude, the shape sets how the
; drive grows). Factoring the shape out of the aspects makes a desire legible - you
; read the SHAPE (survival diverges, rhythm saturates) not a bare magic number.
;
;   homeostatic  - SURVIVAL: convex, diverges toward the danger limit. Mild when the
;     need is light, then blows past every rival as the attr approaches ?danger (the
;     denominator collapses). Replaces per-aspect "magic override" cliffs (the old
;     sleep 10000). ?scale is the drive at attr = ?danger/2 (the half-danger point).
;   recency-ramp - RHYTHMIC: linear ramp that SATURATES at ?scale. You do not die of
;     skipping it, so it is bounded: 0 at ?due days since the last occurrence, full
;     ?scale by ?cap days. Replaces flat "days-gate + fixed magnitude" drives.
; ----------------------------------------------------------------------------


