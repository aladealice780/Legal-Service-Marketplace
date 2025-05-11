;; Attorney Verification Contract
;; Validates and stores information about legal professionals

(define-data-var admin principal tx-sender)

;; Map to store verified attorneys
(define-map attorneys
  { attorney-id: principal }
  {
    name: (string-utf8 100),
    license-number: (string-utf8 50),
    jurisdiction: (string-utf8 50),
    specialization: (string-utf8 100),
    verified: bool
  }
)

;; Public function to register as an attorney
(define-public (register-attorney
                (name (string-utf8 100))
                (license-number (string-utf8 50))
                (jurisdiction (string-utf8 50))
                (specialization (string-utf8 100)))
  (let ((attorney-id tx-sender))
    ;; Check if attorney already exists
    (match (map-get? attorneys { attorney-id: attorney-id })
      existing-data (err u1) ;; Attorney already registered
      (ok (map-insert attorneys
                      { attorney-id: attorney-id }
                      {
                        name: name,
                        license-number: license-number,
                        jurisdiction: jurisdiction,
                        specialization: specialization,
                        verified: false
                      }))
    )
  )
)

;; Admin function to verify an attorney
(define-public (verify-attorney (attorney-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403)) ;; Only admin can verify
    (match (map-get? attorneys { attorney-id: attorney-id })
      attorney-data (ok (map-set attorneys
                                { attorney-id: attorney-id }
                                (merge attorney-data { verified: true })))
      (err u404) ;; Attorney not found
    )
  )
)

;; Public function to check if an attorney is verified
(define-read-only (is-verified-attorney (attorney-id principal))
  (match (map-get? attorneys { attorney-id: attorney-id })
    attorney-data (get verified attorney-data)
    false
  )
)

;; Public function to get attorney details
(define-read-only (get-attorney-details (attorney-id principal))
  (map-get? attorneys { attorney-id: attorney-id })
)

;; Admin function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
