; ----------------------------------------------------------------------------
; score_macros.hs - composable scoring/disposition macros for motive events.
;
; Layered by design: small named readings nest into bigger named scores, so an
; event's (when ...) / blame decision reads as intent, not arithmetic. Macros
; expand recursively at compile (a macro body may call other macros); every
; entity is passed BY ARGUMENT (?who / ?t), so the same reading works for
; @self, a role var, or a bound var at any call site.
;
; Belief reads run in the deliberating self's mind (the believes/target
; single-POV rule); (attr ...) reads env ground truth.
; ----------------------------------------------------------------------------

; --- Layer 0: numeric / belief primitives -----------------------------------

; Mean of two scores.
(define-macro mean2 (?a ?b)
  (* 0.5 (+ ?a ?b)))

; Mean of two env trait attrs of ?who.
(define-macro trait-mean (?who ?trait_a ?trait_b)
  (mean2 (attr ?who ?trait_a) (attr ?who ?trait_b)))

; ?who's ?label belief target, else ?default when the belief is absent
; (the "unknown reads as X" parity idiom).
(define-macro target-or (?who ?label ?default)
  (if (believes {?who ?label}) (target {?who ?label}) ?default))

; --- Layer 1: single-quantity readings ---------------------------------------

; How uninhibited @self is: the inverse of the inhibition moral brake.
(define-macro disinhibition ()
  (- 1 (inhibition)))

; How cold ?who is (inverse compassion).
(define-macro callousness (?who)
  (- 1 (target {?who compassion})))

; Does the deliberating self hold a grudge toward ?t (any negative warmth)?
; 1 / 0 - a score TERM, not a predicate.
(define-macro is-hostile-toward (?t)
  (if (< (stance-band ?t warmth) 0) 1 0))

; The MAGNITUDE of the self's hostility toward ?t (0 when warmth is positive).
(define-macro hostility-toward (?t)
  (if (< (stance-band ?t warmth) 0) (- 0 (stance-band ?t warmth)) 0))

; How attached the self is to ?t: kept warmth plus half the attraction.
(define-macro attachment-toward (?t)
  (+ (max 0 (stance-band ?t warmth)) (* 0.5 (stance-band ?t attraction))))

; Does the self DETEST ?t (warmth at or below the detest band)?
(define-macro detests (?t)
  (<= (stance-band ?t warmth) -2))

; ?holder's hostility MAGNITUDE toward ?t (the cross-holder sibling of
; hostility-toward; 0 when their warmth is positive).
(define-macro hostility-of (?holder ?t)
  (if (< (stance-band ?holder ?t warmth) 0)
      (- 0 (stance-band ?holder ?t warmth)) 0))

; The pair's joint carelessness: low decorum on BOTH sides makes an
; indiscretion likely; one careful partner keeps the affair tight. Read from
; the deliberating self's beliefs (an unknown side reads the 0.5 prior).
(define-macro carelessness-of (?a ?b)
  (* (- 1 (target-or ?a decorum 0.5))
     (- 1 (target-or ?b decorum 0.5))))

; The pull of ?toward measured against what still binds the self to ?away
; (attraction minus kept warmth - the affair-triangle drive).
(define-macro romantic-drive (?toward ?away)
  (- (stance-band ?toward attraction) (stance-band ?away warmth)))

; --- Layer 1: named trait tails (who is CAPABLE of what) --------------------

(define-macro lethal-disposition (?who)      (trait-mean ?who psychopathy sadism))
(define-macro rage-disposition (?who)        (trait-mean ?who volatility psychopathy))
(define-macro ambitious-disposition (?who)   (trait-mean ?who machiavellianism narcissism))
(define-macro acquisitive-disposition (?who) (trait-mean ?who machiavellianism psychopathy))

; --- Layer 2: the propensity product -----------------------------------------

; The standard motive-gate product: a disposition released by disinhibition.
; Use inside (chance (* (crime-scale) <base-rate> (dark-propensity (..)))).
(define-macro dark-propensity (?disposition)
  (* (disinhibition) ?disposition))

; --- Layer 3: betrayal blame (betrayal_kill.hs) ------------------------------

; Blame-the-partner terms, innermost out: the self's sense of propriety plus
; any standing grudge toward the partner ...
(define-macro propriety-affront (?t)
  (+ (target {@self decorum}) (is-hostile-toward ?t)))

; ... hardened by coldness ...
(define-macro cold-affront (?t)
  (+ (callousness @self) (propriety-affront ?t)))

; ... and inflated by self-regard: how much the betrayed self blames the
; unfaithful partner.
(define-macro blame-partner-score (?t)
  (+ (attr @self narcissism) (cold-affront ?t)))

; How much the betrayed self blames the interloper instead: attachment to the
; partner (worth keeping) + compassion (spare the partner) + hostility already
; held toward the interloper.
(define-macro blame-interloper-score (?partner ?interloper)
  (+ (attachment-toward ?partner)
     (+ (target {@self compassion})
        (hostility-toward ?interloper))))

; The dual-kill outrage: enough anger + propriety + scheming to kill BOTH.
(define-macro dual-outrage-score ()
  (+ (emotion-load @self [k anger])
     (+ (target {@self decorum}) (attr @self machiavellianism))))

; Value dissonance between ?a and ?b AS THE DELIBERATOR KNOWS IT: the share of
; declared moral values (chastity / piety / sobriety) the two hold differently,
; every side read from the deliberator's OWN beliefs ({X value <k>} - own values
; for @self, learned/mirrored values for another; an unknown value reads
; absent). Replaces the old C++ value-rift op - the value list is content and
; lives here now. believes folds to 0/1 in arithmetic, so a gap is |a - b|.
(define-macro value-gap (?a ?b ?vk)
  (max (- (believes {?a value ?vk}) (believes {?b value ?vk}))
       (- (believes {?b value ?vk}) (believes {?a value ?vk}))))

(define-macro value-rift (?a ?b)
  (/ (+ (value-gap ?a ?b [k chastity])
        (value-gap ?a ?b [k piety])
        (value-gap ?a ?b [k sobriety]))
     3))
