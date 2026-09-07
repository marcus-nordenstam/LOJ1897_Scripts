; ----------------------------------------------------------------------------
; premises-identity - the identity classifiers for PREMISES: recognising that a building
; @self only imagined (read off a notice, was told of) IS a building he has now perceived.
;
; The engine keeps the two halves it can own: WHICH imagined objects are up for
; reconciliation (the participants of a running act - (is-reconcilable ?x), scoped by the
; action pipeline so a mind never scans its whole imagination), and the FUSION itself
; ((reconcile ?imagined ?real): the imagined object's beliefs rewired onto the real one, the
; imagined one discarded). What counts as "the same premises" is content, and lives here.
;
; A building's identity is its NAME if it has one, else its ADDRESS - so there are two
; criteria, in that order. Both are cached, wake-driven role filters: the perception write of
; the real building's name / address belief (walking past its sign) re-tests membership and
; arms the rule, and the pipeline re-tests the imagined object the instant an act starts on
; it. Nothing polls.
;
; Only whole-building identity is authored yet: a sub-let premise (a floor / apartment) is a
; space extending its building's address with a unit, and gets its own criterion when the
; world has such spaces.
; ----------------------------------------------------------------------------

(npc-think premises_identity_by_name
  (role ?imag [k building] (is-reconcilable ?imag) {?imag name ?n})
  (role ?real [k building] (observed ?real) {?real name ?n})
  (effects
    (reconcile ?imag ?real)))

(npc-think premises_identity_by_address
  (role ?imag [k building] (is-reconcilable ?imag) {?imag address ?a})
  (role ?real [k building] (observed ?real) {?real address ?a})
  (effects
    (reconcile ?imag ?real)))
