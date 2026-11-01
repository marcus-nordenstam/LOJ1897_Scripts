; ----------------------------------------------------------------------------
; standing (reflex) - how @self comes to regard a man he knows by who he IS (funcs/standing.mc):
; everything known of him is felt when @self meets him, and each thing again when what @self
; knows of it is born or changes - his conduct, class, fortune, looks and company.
; ----------------------------------------------------------------------------

(reflex {@self acquaintance ?other}:?acquaintance
  (when (dirty-born))
  (effects (judge-standing-of ?other ?acquaintance)))

(reflex {?other honesty ?band}:?honesty
  (when (and (dirty-born) (neq ?other @self) {@self (closeness-labels acquaintance) ?other}))
  (effects (feel-conduct ?other honesty ?honesty)))

(reflex {?other piety ?band}:?piety
  (when (and (dirty-born) (neq ?other @self) {@self (closeness-labels acquaintance) ?other}))
  (effects (feel-conduct ?other piety ?piety)))

(reflex {?other sobriety ?band}:?sobriety
  (when (and (dirty-born) (neq ?other @self) {@self (closeness-labels acquaintance) ?other}))
  (effects (feel-conduct ?other sobriety ?sobriety)))

(reflex {?other class-situation ?class}:?class-situation
  (when (and (dirty-born) (neq ?other @self) {@self (closeness-labels acquaintance) ?other}))
  (effects (feel-class ?other ?class-situation)))

(reflex {?other wealth ?}:?wealth
  (when (and (dirty-born) (neq ?other @self) {@self (closeness-labels acquaintance) ?other}))
  (effects (feel-fortune ?other ?wealth)))

(reflex {?other prestige ?}:?prestige
  (when (and (dirty-born) (neq ?other @self) {@self (closeness-labels acquaintance) ?other}))
  (effects
    (feel-fortune ?other ?prestige)
    (feel-attraction ?other ?prestige)))

(reflex {?other attractiveness ?}:?attractiveness
  (when (and (dirty-born) (neq ?other @self) {@self (closeness-labels acquaintance) ?other}))
  (effects (feel-attraction ?other ?attractiveness)))

(reflex {?other friend ?companion}:?friend
  (when (and (dirty-born) (neq ?other @self) (neq ?companion @self)
             {@self (closeness-labels acquaintance) ?other}))
  (effects (feel-company ?other ?companion ?friend)))
