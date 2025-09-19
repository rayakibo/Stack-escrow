;; ------------------------------------------------
;; Contract: stack-escrow
;; Trustless Escrow Contract for STX
;; ------------------------------------------------

(define-constant ERR_NO_DEPOSIT (err u100))
(define-constant ERR_NOT_BUYER (err u101))
(define-constant ERR_NOT_SELLER (err u102))
(define-constant ERR_ALREADY_RELEASED (err u103))
(define-constant ERR_ALREADY_REFUNDED (err u104))

;; Escrow agreement storage
(define-map escrows
  { id: uint }
  { buyer: principal, seller: principal, arbiter: principal, amount: uint,
    deposited: bool, released: bool, refunded: bool })

;; ------------------------------
;; Public Functions
;; ------------------------------

;; Create an escrow agreement
(define-public (create-escrow (id uint) (seller principal) (arbiter principal) (amount uint))
  (if (is-some (map-get? escrows { id: id }))
      (err u200) ;; Escrow already exists
      (begin
        (map-set escrows { id: id }
          { buyer: tx-sender, seller: seller, arbiter: arbiter, amount: amount,
            deposited: false, released: false, refunded: false })
        (ok true))))

;; Deposit STX into escrow
(define-public (deposit (id uint))
  (match (map-get? escrows { id: id })
    escrow-data
      (if (is-eq (get buyer escrow-data) tx-sender)
        (begin
          (try! (stx-transfer? (get amount escrow-data) tx-sender (as-contract tx-sender)))
          (map-set escrows { id: id }
            { buyer: (get buyer escrow-data), seller: (get seller escrow-data), arbiter: (get arbiter escrow-data),
              amount: (get amount escrow-data), deposited: true, released: false, refunded: false })
          (ok true))
        ERR_NOT_BUYER)
    ERR_NO_DEPOSIT))

;; Release funds to seller (buyer approves)
(define-public (release (id uint))
  (match (map-get? escrows { id: id })
    escrow-data
      (if (is-eq (get buyer escrow-data) tx-sender)
        (if (get released escrow-data)
            ERR_ALREADY_RELEASED
            (begin
              (map-set escrows { id: id }
                { buyer: (get buyer escrow-data), seller: (get seller escrow-data), arbiter: (get arbiter escrow-data),
                  amount: (get amount escrow-data), deposited: true, released: true, refunded: false })
              (stx-transfer? (get amount escrow-data) (as-contract tx-sender) (get seller escrow-data))))
        ERR_NOT_BUYER)
    ERR_NO_DEPOSIT))

;; Refund funds to buyer (arbiter resolves dispute)
(define-public (refund (id uint))
  (match (map-get? escrows { id: id })
    escrow-data
      (if (is-eq (get arbiter escrow-data) tx-sender)
        (if (get refunded escrow-data)
            ERR_ALREADY_REFUNDED
            (begin
              (map-set escrows { id: id }
                { buyer: (get buyer escrow-data), seller: (get seller escrow-data), arbiter: (get arbiter escrow-data),
                  amount: (get amount escrow-data), deposited: true, released: false, refunded: true })
              (stx-transfer? (get amount escrow-data) (as-contract tx-sender) (get buyer escrow-data))))
        (err u201)) ;; Not arbiter
    ERR_NO_DEPOSIT))

;; ------------------------------
;; Read-Only Functions
;; ------------------------------

;; View escrow details
(define-read-only (get-escrow (id uint))
  (map-get? escrows { id: id }))
