;; Define NFT token
(define-non-fungible-token timesnap uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-expired (err u101))
(define-constant err-owner-only (err u102))
(define-constant err-token-not-found (err u103))

;; Token metadata map
(define-map token-metadata uint 
  {
    owner: principal,
    created-at: uint,
    expires-at: uint,
    metadata-uri: (string-utf8 256)
  }
)

;; Mint new NFT
(define-public (mint (token-id uint) (recipient principal) (duration uint) (metadata-uri (string-utf8 256)))
  (let ((expires-at (+ block-height duration)))
    (if (is-eq tx-sender contract-owner)
      (begin
        (try! (nft-mint? timesnap token-id recipient))
        (map-set token-metadata token-id
          {
            owner: recipient,
            created-at: block-height,
            expires-at: expires-at,
            metadata-uri: metadata-uri
          }
        )
        (ok true))
      err-owner-only)))

;; Transfer NFT if not expired
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (let ((token-data (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
    (if (< block-height (get expires-at token-data))
      (begin
        (try! (nft-transfer? timesnap token-id sender recipient))
        (map-set token-metadata token-id
          (merge token-data { owner: recipient })
        )
        (ok true))
      err-expired)))

;; Read-only functions
(define-read-only (get-token-info (token-id uint))
  (map-get? token-metadata token-id))

(define-read-only (is-expired (token-id uint))
  (let ((token-data (unwrap! (map-get? token-metadata token-id) err-token-not-found)))
    (ok (>= block-height (get expires-at token-data)))))

(define-read-only (get-owner (token-id uint))
  (nft-get-owner? timesnap token-id))
