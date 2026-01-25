;; =========================================================
;; ROLES CONTRACT
;; Role-based Access Control System
;; =========================================================
;; Description: Manages installer roles and permissions for the
;;              UPS Solar service marketplace platform
;; Version: 1.0.0
;; =========================================================

;; -------------------------
;; Constants
;; -------------------------

(define-constant CONTRACT-OWNER tx-sender)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-NOT-FOUND (err u101))

;; -------------------------
;; Data Maps
;; -------------------------

(define-map installers principal bool)
(define-map installer-metadata 
  principal 
  {
    added-at: uint,
    added-by: principal,
    active: bool
  }
)

;; -------------------------
;; Data Variables
;; -------------------------

(define-data-var total-installers uint u0)

;; -------------------------
;; Administrative Functions
;; -------------------------

;; @desc Adds a new installer to the platform
;; @param installer: Principal address of the installer to add
;; @returns (response bool uint)
(define-public (add-installer (installer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-installer installer)) ERR-ALREADY-EXISTS)
    
    (map-set installers installer true)
    (map-set installer-metadata installer {
      added-at: stacks-block-height,
      added-by: tx-sender,
      active: true
    })
    (var-set total-installers (+ (var-get total-installers) u1))
    (ok true)
  )
)

;; @desc Removes an installer from the platform
;; @param installer: Principal address of the installer to remove
;; @returns (response bool uint)
(define-public (remove-installer (installer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-installer installer) ERR-NOT-FOUND)
    
    (map-delete installers installer)
    (match (map-get? installer-metadata installer)
      metadata (map-set installer-metadata installer (merge metadata { active: false }))
      true
    )
    (var-set total-installers (- (var-get total-installers) u1))
    (ok true)
  )
)

;; -------------------------
;; Read-Only Functions
;; -------------------------

;; @desc Checks if a user is an authorized installer
;; @param user: Principal address to check
;; @returns bool
(define-read-only (is-installer (user principal))
  (default-to false (map-get? installers user))
)

;; @desc Gets the contract owner
;; @returns principal
(define-read-only (get-contract-owner)
  CONTRACT-OWNER
)

;; @desc Gets installer metadata
;; @param installer: Principal address of the installer
;; @returns (optional metadata)
(define-read-only (get-installer-metadata (installer principal))
  (map-get? installer-metadata installer)
)

;; @desc Gets total number of active installers
;; @returns uint
(define-read-only (get-total-installers)
  (var-get total-installers)
)
