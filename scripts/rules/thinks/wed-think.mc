; Told she is betrothed to him, she holds the betrothal in her own mind.
(think fiancee-reciprocate
  (role @self -{@self spouse ?}
              -{@self fiancee ?}
    (role ?p {?p fiancee @self}
      (effects (begin-belief {@self fiancee ?p})))))
