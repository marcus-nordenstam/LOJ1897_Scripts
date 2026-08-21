; func-substrate unification SPIKE - a LOWERING-TEST fixture (throwaway).
; Its when-gate is lowered to a t_func + slot-refs and shadow-evaluated by the
; new slot loop, which CALLS the real isim funcs (arg-access redirected via the
; s_slot_hook seam), parity-checked vs the live t_expr eval:
;   (and ...)          -> isim t_and_func (3-arg)
;   (not ...)          -> native
;   (= ?x @self)       -> isim t_binary_compare_func<k_equal>  (raw-equality path)
;   (< (year) 1701)    -> isim t_binary_compare_func<k_less>   (match_symbols numeric
;                         path) over a native (year) value op
;   (none {@self spouse ?x}) -> NON-k_call {..} pattern lowered + grounded, then the
;                         isim `any` search (hsim desugars none/any to believes).
; ?x is a ROLE-var slot (cleared per fire); @self is slot 0.
(npc-think spike_lower_test
  (cooldown 1 m)
  (rng-stream behaviour)
  (role ?x (any_human ?x))
  (when (and (not (= ?x @self))
             (< (year) 1701)
             (none {@self spouse ?x})))
  (utility want)
  (effects
    (check (any_human ?x))))
