;; TimeSnap NFT: Time-limited NFTs with expiration functionality
;; Implements SIP-009 NFT standard

;; Define NFT token
(define-non-fungible-token timesnap uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var total-supply uint u0)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-expired (err u101))           ;; Token has expired
(define-constant err-owner-only (err u102))        ;; Only contract owner can perform this action
(define-constant err-token-not-found (err u103))   ;; Token doesn't exist
(define-constant err-not-token-owner (err u104))   ;; Sender doesn't own the token
(define-constant err-token-exists (err u105))      ;; Token ID already exists
(define-constant err-invalid-duration (err u106))  ;; Invalid duration specified

;; SIP-009 Interface
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Token metadata map
(define-map token-metadata uint 
  {
    owner: principal,
    created-at: uint,
    expires-at: uint,
    metadata-uri: (string-utf8 256)
  }
)

;; Helper function to verify token ownership
(define-private (is-token-owner (token-id uint) (user principal))
  (let ((token-data (unwrap! (map-get? token-metadata token-id) false)))
    (is-eq (get owner token-data) user)))

;; Mint new NFT
(define-public (mint (token-id uint) (recipient principal) (duration uint) (metadata-uri (string-utf8 256)))
  (let ((expires-at (+ block-height duration)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> duration u0) err-invalid-duration)
    (asserts! (is-none (map-get? token-metadata token-id)) err-token-exists)
    (try! (nft-mint? timesnap token-id recipient))
    (var-set last-token-id token-id)
    (var-set total-supply (+ (var-get total-supply) u1))
    (map-set token-metadata token-id
      {
        owner: recipient,
        created-at: block-height,
        expires-at: expires-at,
        metadata-uri: metadata-uri
      }
    )
    (ok true)))

;; Transfer NFT if not expired
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (let ((token-data (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
    (asserts! (is-token-owner token-id sender) err-not-token-owner)
    (asserts! (< block-height (get expires-at token-data)) err-expired)
    (try! (nft-transfer? timesnap token-id sender recipient))
    (map-set token-metadata token-id
      (merge token-data { owner: recipient })
    )
    (ok true)))

;; Burn expired token
(define-public (burn (token-id uint))
  (let ((token-data (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
    (asserts! (>= block-height (get expires-at token-data)) err-expired)
    (asserts! (is-token-owner token-id tx-sender) err-not-token-owner)
    (try! (nft-burn? timesnap token-id tx-sender))
    (map-delete token-metadata token-id)
    (var-set total-supply (- (var-get total-supply) u1))
    (ok true)))

;; Read-only functions
(define-read-only (get-token-info (token-id uint))
  (map-get? token-metadata token-id))

(define-read-only (is-expired (token-id uint))
  (let ((token-data (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
    (ok (>= block-height (get expires-at token-data)))))

(define-read-only (get-owner (token-id uint))
  (nft-get-owner? timesnap token-id))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

;; SIP-009 required functions
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (token-id uint))
  (let ((token-data (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
    (ok (get metadata-uri token-data))))
