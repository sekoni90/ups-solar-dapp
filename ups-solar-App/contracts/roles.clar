;; =========================================================
;; roles.clar
;; Role-based access control
;; =========================================================

(define-constant CONTRACT-OWNER tx-sender)

(define-map installers principal bool)

;; -------------------------
;; Admin only
;; -------------------------

(define-public (add-installer (installer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set installers installer true)
    (ok true)
  )
)

(define-public (remove-installer (installer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-delete installers installer)
    (ok true)
  )
)

;; -------------------------
;; Read-only
;; -------------------------

(define-read-only (is-installer (user principal))
  (default-to false (map-get? installers user))
)
