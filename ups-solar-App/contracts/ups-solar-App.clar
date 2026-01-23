;; title: ups-solar-App

;; Service Types
(define-constant SERVICE-UPS u1)
(define-constant SERVICE-SOLAR u2)
(define-constant SERVICE-ELECTRICAL u3)

;; Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-NOT-COMPLETED (err u104))
