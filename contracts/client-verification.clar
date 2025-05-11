;; Client Verification Contract
;; Validates and stores information about service seekers

(define-data-var admin principal tx-sender)

;; Map to store verified clients
(define-map clients
  { client-id: principal }
  {
    name: (string-utf8 100),
    contact: (string-utf8 100),
    verified: bool
  }
)

;; Public function to register as a client
(define-public (register-client
                (name (string-utf8 100))
                (contact (string-utf8 100)))
  (let ((client-id tx-sender))
    ;; Check if client already exists
    (match (map-get? clients { client-id: client-id })
      existing-data (err u1) ;; Client already registered
      (ok (map-insert clients
                      { client-id: client-id }
                      {
                        name: name,
                        contact: contact,
                        verified: false
                      }))
    )
  )
)

;; Admin function to verify a client
(define-public (verify-client (client-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403)) ;; Only admin can verify
    (match (map-get? clients { client-id: client-id })
      client-data (ok (map-set clients
                              { client-id: client-id }
                              (merge client-data { verified: true })))
      (err u404) ;; Client not found
    )
  )
)

;; Public function to check if a client is verified
(define-read-only (is-verified-client (client-id principal))
  (match (map-get? clients { client-id: client-id })
    client-data (get verified client-data)
    false
  )
)

;; Public function to get client details
(define-read-only (get-client-details (client-id principal))
  (map-get? clients { client-id: client-id })
)

;; Admin function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
