;; Academic Achievement & Certification Management System Smart Contract
;; A comprehensive blockchain-based platform for managing educational credentials,
;; course enrollments, academic achievements, and digital certificates with
;; automated verification and reputation tracking.

;; ERROR CONSTANTS & VALIDATION CODES

;; Authentication & Authorization Errors
(define-constant ERR-UNAUTHORIZED-ACCESS (err u1001))
(define-constant ERR-INSUFFICIENT-PERMISSIONS (err u1002))
(define-constant ERR-CONTRACT-PAUSED (err u1003))

;; Data Validation Errors  
(define-constant ERR-INVALID-INPUT-DATA (err u1101))
(define-constant ERR-RESOURCE-NOT-FOUND (err u1102))
(define-constant ERR-DUPLICATE-ENTRY (err u1103))
(define-constant ERR-INVALID-SCORE-RANGE (err u1104))
(define-constant ERR-INVALID-RATING-VALUE (err u1105))

;; Business Logic Errors
(define-constant ERR-COURSE-INACTIVE (err u1201))
(define-constant ERR-ENROLLMENT-LIMIT-REACHED (err u1202))
(define-constant ERR-PREREQUISITES-NOT-MET (err u1203))
(define-constant ERR-ACHIEVEMENT-DISABLED (err u1204))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1205))
(define-constant ERR-CERTIFICATION-REVOKED (err u1206))

;; SYSTEM CONFIGURATION CONSTANTS

(define-constant contract-deployer tx-sender)
(define-constant maximum-course-title-length u100)
(define-constant maximum-description-length u500)
(define-constant maximum-category-length u50)
(define-constant maximum-requirements-text-length u300)
(define-constant maximum-grade-designation-length u10)
(define-constant maximum-review-text-length u300)
(define-constant maximum-notes-length u200)

(define-constant minimum-passing-grade u60)
(define-constant maximum-possible-score u100)
(define-constant maximum-course-prerequisites u10)
(define-constant maximum-instructor-specializations u5)

(define-constant minimum-star-rating u1)
(define-constant maximum-star-rating u5)

;; Level progression thresholds
(define-constant expert-level-threshold u10000)
(define-constant advanced-level-threshold u5000)
(define-constant intermediate-level-threshold u2000)
(define-constant beginner-level-threshold u500)

;; SYSTEM STATE VARIABLES

(define-data-var next-available-course-id uint u1)
(define-data-var next-available-achievement-id uint u1)
(define-data-var next-available-certificate-id uint u1)

(define-data-var system-maintenance-mode bool false)
(define-data-var course-enrollment-fee uint u1000000) ;; 1 STX in microSTX
(define-data-var default-student-reputation uint u100)

;; DATA STORAGE STRUCTURES

;; Course catalog management
(define-map academic-course-registry
  { course-identifier: uint }
  {
    course-title: (string-ascii 100),
    detailed-description: (string-ascii 500),
    primary-instructor: principal,
    credit-hours: uint,
    difficulty-classification: (string-ascii 20),
    required-prerequisites: (list 10 uint),
    enrollment-capacity: uint,
    current-student-count: uint,
    course-active-status: bool,
    creation-timestamp: uint,
    last-modification-timestamp: uint
  }
)

;; Student enrollment tracking
(define-map student-course-enrollments
  { enrolled-student: principal, target-course: uint }
  {
    enrollment-timestamp: uint,
    completion-percentage: uint,
    enrollment-status: (string-ascii 20), ;; "active", "in-progress", "completed", "withdrawn"
    final-examination-score: (optional uint),
    course-completion-timestamp: (optional uint)
  }
)

;; Achievement system definitions
(define-map achievement-catalog
  { achievement-identifier: uint }
  {
    achievement-title: (string-ascii 100),
    achievement-description: (string-ascii 500),
    achievement-category: (string-ascii 50),
    point-value: uint,
    completion-requirements: (string-ascii 300),
    achievement-active-status: bool,
    created-by-user: principal,
    creation-timestamp: uint
  }
)

;; Student achievement records
(define-map student-earned-achievements
  { achievement-holder: principal, earned-achievement: uint }
  {
    achievement-earned-timestamp: uint,
    verified-by-authority: principal,
    achievement-score: uint,
    additional-notes: (optional (string-ascii 200))
  }
)

;; Digital certificate registry
(define-map digital-certificate-registry
  { certificate-identifier: uint }
  {
    certificate-holder: principal,
    associated-course: uint,
    related-achievement: (optional uint),
    certificate-issuer: principal,
    issuance-timestamp: uint,
    letter-grade: (string-ascii 10),
    numerical-score: uint,
    blockchain-verification-hash: (string-ascii 64),
    revocation-status: bool
  }
)

;; Comprehensive student profiles
(define-map comprehensive-student-profiles
  { student-account: principal }
  {
    accumulated-credit-hours: uint,
    total-achievements-earned: uint,
    total-achievement-points: uint,
    current-academic-level: uint,
    platform-registration-date: uint,
    most-recent-activity: uint,
    reputation-score: uint
  }
)

;; Instructor professional profiles
(define-map instructor-professional-profiles
  { instructor-account: principal }
  {
    courses-taught-count: uint,
    total-students-instructed: uint,
    average-course-rating: uint,
    instructor-registration-date: uint,
    verification-status: bool,
    teaching-specializations: (list 5 (string-ascii 50))
  }
)

;; Course evaluation system
(define-map course-student-evaluations
  { evaluating-student: principal, evaluated-course: uint }
  {
    star-rating: uint,
    written-feedback: (optional (string-ascii 300)),
    evaluation-submission-timestamp: uint
  }
)

;; AUTHORIZATION & VALIDATION UTILITIES

(define-private (verify-contract-owner-privileges)
  (is-eq tx-sender contract-deployer)
)

(define-private (verify-course-instructor-privileges (target-course-id uint))
  (match (map-get? academic-course-registry { course-identifier: target-course-id })
    course-information (is-eq tx-sender (get primary-instructor course-information))
    false
  )
)

(define-private (verify-system-operational-status)
  (not (var-get system-maintenance-mode))
)

(define-private (validate-text-input-length (input-text (string-ascii 500)))
  (and (> (len input-text) u0) (<= (len input-text) u500))
)

(define-private (validate-short-text-input (input-text (string-ascii 100)))
  (and (> (len input-text) u0) (<= (len input-text) u100))
)

(define-private (validate-category-text (category-input (string-ascii 50)))
  (and (> (len category-input) u0) (<= (len category-input) u50))
)

(define-private (validate-difficulty-level (difficulty-input (string-ascii 20)))
  (and (> (len difficulty-input) u0) (<= (len difficulty-input) u20))
)

(define-private (validate-requirements-text (requirements-input (string-ascii 300)))
  (and (> (len requirements-input) u0) (<= (len requirements-input) u300))
)

(define-private (validate-grade-designation (grade-input (string-ascii 10)))
  (and (> (len grade-input) u0) (<= (len grade-input) u10))
)

(define-private (validate-course-identifier (course-id uint))
  (and (> course-id u0) (<= course-id (var-get next-available-course-id)))
)

(define-private (validate-achievement-identifier (achievement-id uint))
  (and (> achievement-id u0) (<= achievement-id (var-get next-available-achievement-id)))
)

(define-private (validate-certificate-identifier (certificate-id uint))
  (and (> certificate-id u0) (<= certificate-id (var-get next-available-certificate-id)))
)

(define-private (validate-star-rating-value (rating-value uint))
  (and (>= rating-value minimum-star-rating) (<= rating-value maximum-star-rating))
)

(define-private (validate-progress-percentage (progress-value uint))
  (<= progress-value u100)
)

(define-private (validate-fee-amount (fee-amount uint))
  (>= fee-amount u0)
)

(define-private (validate-principal-address (address-input principal))
  (not (is-eq address-input 'ST000000000000000000002AMW42H))
)

(define-private (validate-prerequisite-list (prerequisite-courses (list 10 uint)))
  (<= (len prerequisite-courses) maximum-course-prerequisites)
)

(define-private (validate-optional-review-text (review-text (optional (string-ascii 300))))
  (match review-text
    existing-review (and (> (len existing-review) u0) (<= (len existing-review) maximum-review-text-length))
    true
  )
)

(define-private (validate-optional-notes-text (notes-text (optional (string-ascii 200))))
  (match notes-text
    existing-notes (and (> (len existing-notes) u0) (<= (len existing-notes) maximum-notes-length))
    true
  )
)

;; SYSTEM UTILITY FUNCTIONS

(define-private (get-current-block-timestamp)
  block-height
)

(define-private (calculate-student-academic-level (total-achievement-points uint))
  (if (>= total-achievement-points expert-level-threshold)
    u5
    (if (>= total-achievement-points advanced-level-threshold)
      u4
      (if (>= total-achievement-points intermediate-level-threshold)
        u3
        (if (>= total-achievement-points beginner-level-threshold)
          u2
          u1
        )
      )
    )
  )
)

(define-private (generate-certificate-verification-hash (student-address principal) (course-id uint) (final-score uint))
  (int-to-ascii (+ (+ course-id final-score) (get-current-block-timestamp)))
)

(define-private (validate-academic-score (score-value uint))
  (and (>= score-value u0) (<= score-value maximum-possible-score))
)

(define-private (verify-student-prerequisites (student-address principal) (required-prerequisites (list 10 uint)))
  (fold verify-individual-prerequisite required-prerequisites true)
)

(define-private (verify-individual-prerequisite (prerequisite-course-id uint) (accumulator bool))
  (and accumulator
    (match (map-get? student-course-enrollments { enrolled-student: tx-sender, target-course: prerequisite-course-id })
      enrollment-record (is-eq (get enrollment-status enrollment-record) "completed")
      false
    )
  )
)

;; COURSE MANAGEMENT OPERATIONS

(define-public (create-new-academic-course 
  (course-title (string-ascii 100))
  (course-description (string-ascii 500))
  (credit-hours uint)
  (difficulty-level (string-ascii 20))
  (prerequisite-courses (list 10 uint))
  (maximum-enrollment uint)
)
  (let
    (
      (new-course-identifier (var-get next-available-course-id))
      (current-timestamp (get-current-block-timestamp))
    )
    (asserts! (verify-system-operational-status) ERR-CONTRACT-PAUSED)
    (asserts! (validate-short-text-input course-title) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-text-input-length course-description) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-difficulty-level difficulty-level) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-prerequisite-list prerequisite-courses) ERR-INVALID-INPUT-DATA)
    (asserts! (> credit-hours u0) ERR-INVALID-INPUT-DATA)
    (asserts! (> maximum-enrollment u0) ERR-INVALID-INPUT-DATA)

    ;; Register new course in system
    (map-set academic-course-registry
      { course-identifier: new-course-identifier }
      {
        course-title: course-title,
        detailed-description: course-description,
        primary-instructor: tx-sender,
        credit-hours: credit-hours,
        difficulty-classification: difficulty-level,
        required-prerequisites: prerequisite-courses,
        enrollment-capacity: maximum-enrollment,
        current-student-count: u0,
        course-active-status: true,
        creation-timestamp: current-timestamp,
        last-modification-timestamp: current-timestamp
      }
    )

    ;; Update instructor professional profile
    (map-set instructor-professional-profiles
      { instructor-account: tx-sender }
      (merge
        (default-to 
          {
            courses-taught-count: u0,
            total-students-instructed: u0,
            average-course-rating: u0,
            instructor-registration-date: current-timestamp,
            verification-status: false,
            teaching-specializations: (list)
          }
          (map-get? instructor-professional-profiles { instructor-account: tx-sender })
        )
        { 
          courses-taught-count: (+ (default-to u0 (get courses-taught-count (map-get? instructor-professional-profiles { instructor-account: tx-sender }))) u1)
        }
      )
    )

    ;; Increment course identifier counter
    (var-set next-available-course-id (+ new-course-identifier u1))
    (ok new-course-identifier)
  )
)

(define-public (modify-existing-course
  (target-course-id uint)
  (updated-title (string-ascii 100))
  (updated-description (string-ascii 500))
  (active-status bool)
)
  (let
    (
      (existing-course-data (unwrap! (map-get? academic-course-registry { course-identifier: target-course-id }) ERR-RESOURCE-NOT-FOUND))
    )
    (asserts! (validate-course-identifier target-course-id) ERR-INVALID-INPUT-DATA)
    (asserts! (verify-course-instructor-privileges target-course-id) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (validate-short-text-input updated-title) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-text-input-length updated-description) ERR-INVALID-INPUT-DATA)

    (map-set academic-course-registry
      { course-identifier: target-course-id }
      (merge existing-course-data {
        course-title: updated-title,
        detailed-description: updated-description,
        course-active-status: active-status,
        last-modification-timestamp: (get-current-block-timestamp)
      })
    )
    (ok true)
  )
)

;; STUDENT ENROLLMENT OPERATIONS

(define-public (enroll-student-in-course (target-course-id uint))
  (let
    (
      (course-information (unwrap! (map-get? academic-course-registry { course-identifier: target-course-id }) ERR-RESOURCE-NOT-FOUND))
      (current-timestamp (get-current-block-timestamp))
      (student-wallet-balance (stx-get-balance tx-sender))
    )
    (asserts! (validate-course-identifier target-course-id) ERR-INVALID-INPUT-DATA)
    (asserts! (verify-system-operational-status) ERR-CONTRACT-PAUSED)
    (asserts! (get course-active-status course-information) ERR-COURSE-INACTIVE)
    (asserts! (< (get current-student-count course-information) (get enrollment-capacity course-information)) ERR-ENROLLMENT-LIMIT-REACHED)
    (asserts! (>= student-wallet-balance (var-get course-enrollment-fee)) ERR-INSUFFICIENT-BALANCE)
    (asserts! (is-none (map-get? student-course-enrollments { enrolled-student: tx-sender, target-course: target-course-id })) ERR-DUPLICATE-ENTRY)
    (asserts! (verify-student-prerequisites tx-sender (get required-prerequisites course-information)) ERR-PREREQUISITES-NOT-MET)

    ;; Process enrollment fee payment
    (try! (stx-transfer? (var-get course-enrollment-fee) tx-sender contract-deployer))

    ;; Create enrollment record
    (map-set student-course-enrollments
      { enrolled-student: tx-sender, target-course: target-course-id }
      {
        enrollment-timestamp: current-timestamp,
        completion-percentage: u0,
        enrollment-status: "active",
        final-examination-score: none,
        course-completion-timestamp: none
      }
    )

    ;; Update course enrollment statistics
    (map-set academic-course-registry
      { course-identifier: target-course-id }
      (merge course-information {
        current-student-count: (+ (get current-student-count course-information) u1)
      })
    )

    ;; Initialize or update student profile
    (map-set comprehensive-student-profiles
      { student-account: tx-sender }
      (merge
        (default-to 
          {
            accumulated-credit-hours: u0,
            total-achievements-earned: u0,
            total-achievement-points: u0,
            current-academic-level: u1,
            platform-registration-date: current-timestamp,
            most-recent-activity: current-timestamp,
            reputation-score: (var-get default-student-reputation)
          }
          (map-get? comprehensive-student-profiles { student-account: tx-sender })
        )
        { most-recent-activity: current-timestamp }
      )
    )

    (ok true)
  )
)

(define-public (update-student-course-progress (target-student principal) (target-course-id uint) (new-progress uint))
  (let
    (
      (enrollment-record (unwrap! (map-get? student-course-enrollments { enrolled-student: target-student, target-course: target-course-id }) ERR-RESOURCE-NOT-FOUND))
    )
    (asserts! (validate-principal-address target-student) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-course-identifier target-course-id) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-progress-percentage new-progress) ERR-INVALID-INPUT-DATA)
    (asserts! (verify-course-instructor-privileges target-course-id) ERR-UNAUTHORIZED-ACCESS)

    (map-set student-course-enrollments
      { enrolled-student: target-student, target-course: target-course-id }
      (merge enrollment-record {
        completion-percentage: new-progress,
        enrollment-status: (if (>= new-progress u100) "completed" "in-progress")
      })
    )
    (ok true)
  )
)

;; ACHIEVEMENT SYSTEM OPERATIONS

(define-public (create-new-achievement
  (achievement-title (string-ascii 100))
  (achievement-description (string-ascii 500))
  (achievement-category (string-ascii 50))
  (point-value uint)
  (completion-requirements (string-ascii 300))
)
  (let
    (
      (new-achievement-identifier (var-get next-available-achievement-id))
      (current-timestamp (get-current-block-timestamp))
    )
    (asserts! (verify-contract-owner-privileges) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (validate-short-text-input achievement-title) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-text-input-length achievement-description) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-category-text achievement-category) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-requirements-text completion-requirements) ERR-INVALID-INPUT-DATA)
    (asserts! (> point-value u0) ERR-INVALID-INPUT-DATA)

    (map-set achievement-catalog
      { achievement-identifier: new-achievement-identifier }
      {
        achievement-title: achievement-title,
        achievement-description: achievement-description,
        achievement-category: achievement-category,
        point-value: point-value,
        completion-requirements: completion-requirements,
        achievement-active-status: true,
        created-by-user: tx-sender,
        creation-timestamp: current-timestamp
      }
    )

    (var-set next-available-achievement-id (+ new-achievement-identifier u1))
    (ok new-achievement-identifier)
  )
)

(define-public (award-achievement-to-student (target-student principal) (achievement-id uint) (achievement-score uint) (additional-notes (optional (string-ascii 200))))
  (let
    (
      (achievement-information (unwrap! (map-get? achievement-catalog { achievement-identifier: achievement-id }) ERR-RESOURCE-NOT-FOUND))
      (current-timestamp (get-current-block-timestamp))
      (student-profile (default-to 
        {
          accumulated-credit-hours: u0,
          total-achievements-earned: u0,
          total-achievement-points: u0,
          current-academic-level: u1,
          platform-registration-date: current-timestamp,
          most-recent-activity: current-timestamp,
          reputation-score: (var-get default-student-reputation)
        }
        (map-get? comprehensive-student-profiles { student-account: target-student })
      ))
    )
    (asserts! (validate-principal-address target-student) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-achievement-identifier achievement-id) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-optional-notes-text additional-notes) ERR-INVALID-INPUT-DATA)
    (asserts! (or (verify-contract-owner-privileges) (is-eq tx-sender (get created-by-user achievement-information))) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (get achievement-active-status achievement-information) ERR-ACHIEVEMENT-DISABLED)
    (asserts! (validate-academic-score achievement-score) ERR-INVALID-SCORE-RANGE)
    (asserts! (is-none (map-get? student-earned-achievements { achievement-holder: target-student, earned-achievement: achievement-id })) ERR-DUPLICATE-ENTRY)

    ;; Record achievement award
    (map-set student-earned-achievements
      { achievement-holder: target-student, earned-achievement: achievement-id }
      {
        achievement-earned-timestamp: current-timestamp,
        verified-by-authority: tx-sender,
        achievement-score: achievement-score,
        additional-notes: additional-notes
      }
    )

    ;; Update student profile statistics
    (let
      (
        (updated-total-points (+ (get total-achievement-points student-profile) (get point-value achievement-information)))
        (updated-achievement-count (+ (get total-achievements-earned student-profile) u1))
      )
      (map-set comprehensive-student-profiles
        { student-account: target-student }
        (merge student-profile {
          total-achievements-earned: updated-achievement-count,
          total-achievement-points: updated-total-points,
          current-academic-level: (calculate-student-academic-level updated-total-points),
          most-recent-activity: current-timestamp
        })
      )
    )

    (ok true)
  )
)

;; DIGITAL CERTIFICATION OPERATIONS

(define-public (issue-course-certificate 
  (target-student principal) 
  (completed-course-id uint) 
  (final-score uint)
  (letter-grade (string-ascii 10))
)
  (let
    (
      (enrollment-record (unwrap! (map-get? student-course-enrollments { enrolled-student: target-student, target-course: completed-course-id }) ERR-RESOURCE-NOT-FOUND))
      (course-information (unwrap! (map-get? academic-course-registry { course-identifier: completed-course-id }) ERR-RESOURCE-NOT-FOUND))
      (new-certificate-identifier (var-get next-available-certificate-id))
      (current-timestamp (get-current-block-timestamp))
      (verification-hash (generate-certificate-verification-hash target-student completed-course-id final-score))
    )
    (asserts! (validate-principal-address target-student) ERR-INVALID-INPUT-DATA)
    (asserts! (validate-course-identifier completed-course-id) ERR-INVALID-INPUT-DATA)
    (asserts! (verify-course-instructor-privileges completed-course-id) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (validate-academic-score final-score) ERR-INVALID-SCORE-RANGE)
    (asserts! (>= final-score minimum-passing-grade) ERR-INVALID-SCORE-RANGE)
    (asserts! (validate-grade-designation letter-grade) ERR-INVALID-INPUT-DATA)

    ;; Issue digital certificate
    (map-set digital-certificate-registry
      { certificate-identifier: new-certificate-identifier }
      {
        certificate-holder: target-student,
        associated-course: completed-course-id,
        related-achievement: none,
        certificate-issuer: tx-sender,
        issuance-timestamp: current-timestamp,
        letter-grade: letter-grade,
        numerical-score: final-score,
        blockchain-verification-hash: verification-hash,
        revocation-status: false
      }
    )

    ;; Update enrollment record with completion details
    (map-set student-course-enrollments
      { enrolled-student: target-student, target-course: completed-course-id }
      (merge enrollment-record {
        enrollment-status: "completed",
        final-examination-score: (some final-score),
        course-completion-timestamp: (some current-timestamp)
      })
    )

    ;; Award credit hours to student profile
    (let
      (
        (student-profile (default-to 
          {
            accumulated-credit-hours: u0,
            total-achievements-earned: u0,
            total-achievement-points: u0,
            current-academic-level: u1,
            platform-registration-date: current-timestamp,
            most-recent-activity: current-timestamp,
            reputation-score: (var-get default-student-reputation)
          }
          (map-get? comprehensive-student-profiles { student-account: target-student })
        ))
      )
      (map-set comprehensive-student-profiles
        { student-account: target-student }
        (merge student-profile {
          accumulated-credit-hours: (+ (get accumulated-credit-hours student-profile) (get credit-hours course-information)),
          most-recent-activity: current-timestamp
        })
      )
    )

    (var-set next-available-certificate-id (+ new-certificate-identifier u1))
    (ok new-certificate-identifier)
  )
)

(define-public (revoke-issued-certificate (target-certificate-id uint))
  (let
    (
      (certificate-record (unwrap! (map-get? digital-certificate-registry { certificate-identifier: target-certificate-id }) ERR-RESOURCE-NOT-FOUND))
    )
    (asserts! (validate-certificate-identifier target-certificate-id) ERR-INVALID-INPUT-DATA)
    (asserts! (or (verify-contract-owner-privileges) (is-eq tx-sender (get certificate-issuer certificate-record))) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (not (get revocation-status certificate-record)) ERR-CERTIFICATION-REVOKED)

    (map-set digital-certificate-registry
      { certificate-identifier: target-certificate-id }
      (merge certificate-record { revocation-status: true })
    )
    (ok true)
  )
)

;; COURSE EVALUATION OPERATIONS

(define-public (submit-course-evaluation (evaluated-course-id uint) (star-rating uint) (written-feedback (optional (string-ascii 300))))
  (let
    (
      (enrollment-record (unwrap! (map-get? student-course-enrollments { enrolled-student: tx-sender, target-course: evaluated-course-id }) ERR-RESOURCE-NOT-FOUND))
      (current-timestamp (get-current-block-timestamp))
    )
    (asserts! (validate-course-identifier evaluated-course-id) ERR-INVALID-INPUT-DATA)
    (asserts! (verify-system-operational-status) ERR-CONTRACT-PAUSED)
    (asserts! (validate-star-rating-value star-rating) ERR-INVALID-RATING-VALUE)
    (asserts! (validate-optional-review-text written-feedback) ERR-INVALID-INPUT-DATA)
    (asserts! (is-eq (get enrollment-status enrollment-record) "completed") ERR-UNAUTHORIZED-ACCESS)

    (map-set course-student-evaluations
      { evaluating-student: tx-sender, evaluated-course: evaluated-course-id }
      {
        star-rating: star-rating,
        written-feedback: written-feedback,
        evaluation-submission-timestamp: current-timestamp
      }
    )
    (ok true)
  )
)

;; SYSTEM ADMINISTRATION OPERATIONS

(define-public (enable-maintenance-mode)
  (begin
    (asserts! (verify-contract-owner-privileges) ERR-UNAUTHORIZED-ACCESS)
    (var-set system-maintenance-mode true)
    (ok true)
  )
)

(define-public (disable-maintenance-mode)
  (begin
    (asserts! (verify-contract-owner-privileges) ERR-UNAUTHORIZED-ACCESS)
    (var-set system-maintenance-mode false)
    (ok true)
  )
)

(define-public (update-enrollment-fee (new-fee-amount uint))
  (begin
    (asserts! (verify-contract-owner-privileges) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (validate-fee-amount new-fee-amount) ERR-INVALID-INPUT-DATA)
    (var-set course-enrollment-fee new-fee-amount)
    (ok true)
  )
)

(define-public (verify-instructor-credentials (target-instructor principal))
  (let
    (
      (instructor-profile (unwrap! (map-get? instructor-professional-profiles { instructor-account: target-instructor }) ERR-RESOURCE-NOT-FOUND))
    )
    (asserts! (verify-contract-owner-privileges) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (validate-principal-address target-instructor) ERR-INVALID-INPUT-DATA)
    
    (map-set instructor-professional-profiles
      { instructor-account: target-instructor }
      (merge instructor-profile { verification-status: true })
    )
    (ok true)
  )
)

;; READ-ONLY DATA RETRIEVAL FUNCTIONS

(define-read-only (get-course-information (course-id uint))
  (map-get? academic-course-registry { course-identifier: course-id })
)

(define-read-only (get-student-enrollment-details (student-address principal) (course-id uint))
  (map-get? student-course-enrollments { enrolled-student: student-address, target-course: course-id })
)

(define-read-only (get-achievement-details (achievement-id uint))
  (map-get? achievement-catalog { achievement-identifier: achievement-id })
)

(define-read-only (get-student-achievement-record (student-address principal) (achievement-id uint))
  (map-get? student-earned-achievements { achievement-holder: student-address, earned-achievement: achievement-id })
)

(define-read-only (get-certificate-details (certificate-id uint))
  (map-get? digital-certificate-registry { certificate-identifier: certificate-id })
)

(define-read-only (get-comprehensive-student-profile (student-address principal))
  (map-get? comprehensive-student-profiles { student-account: student-address })
)

(define-read-only (get-instructor-professional-profile (instructor-address principal))
  (map-get? instructor-professional-profiles { instructor-account: instructor-address })
)

(define-read-only (get-course-evaluation (student-address principal) (course-id uint))
  (map-get? course-student-evaluations { evaluating-student: student-address, evaluated-course: course-id })
)

(define-read-only (get-system-configuration-info)
  {
    contract-owner: contract-deployer,
    maintenance-mode-active: (var-get system-maintenance-mode),
    current-enrollment-fee: (var-get course-enrollment-fee),
    total-courses-registered: (- (var-get next-available-course-id) u1),
    total-achievements-created: (- (var-get next-available-achievement-id) u1),
    total-certificates-issued: (- (var-get next-available-certificate-id) u1),
    default-reputation-score: (var-get default-student-reputation)
  }
)

(define-read-only (verify-certificate-authenticity (certificate-id uint))
  (match (map-get? digital-certificate-registry { certificate-identifier: certificate-id })
    certificate-data 
      (ok {
        certificate-valid: (not (get revocation-status certificate-data)),
        certificate-holder: (get certificate-holder certificate-data),
        associated-course-id: (get associated-course certificate-data),
        final-numerical-score: (get numerical-score certificate-data),
        certificate-issued-date: (get issuance-timestamp certificate-data),
        blockchain-hash: (get blockchain-verification-hash certificate-data),
        issuing-authority: (get certificate-issuer certificate-data)
      })
    ERR-RESOURCE-NOT-FOUND
  )
)

(define-read-only (get-student-academic-summary (student-address principal))
  (match (map-get? comprehensive-student-profiles { student-account: student-address })
    profile-data
      (ok {
        total-credit-hours: (get accumulated-credit-hours profile-data),
        achievements-earned: (get total-achievements-earned profile-data),
        achievement-points: (get total-achievement-points profile-data),
        academic-level: (get current-academic-level profile-data),
        reputation: (get reputation-score profile-data),
        member-since: (get platform-registration-date profile-data),
        last-active: (get most-recent-activity profile-data)
      })
    ERR-RESOURCE-NOT-FOUND
  )
)

(define-read-only (get-course-enrollment-statistics (course-id uint))
  (match (map-get? academic-course-registry { course-identifier: course-id })
    course-data
      (ok {
        course-title: (get course-title course-data),
        current-enrollments: (get current-student-count course-data),
        maximum-capacity: (get enrollment-capacity course-data),
        enrollment-available: (- (get enrollment-capacity course-data) (get current-student-count course-data)),
        course-active: (get course-active-status course-data),
        instructor: (get primary-instructor course-data),
        credit-value: (get credit-hours course-data)
      })
    ERR-RESOURCE-NOT-FOUND
  )
)

(define-read-only (get-instructor-teaching-statistics (instructor-address principal))
  (match (map-get? instructor-professional-profiles { instructor-account: instructor-address })
    instructor-data
      (ok {
        courses-created: (get courses-taught-count instructor-data),
        students-taught: (get total-students-instructed instructor-data),
        average-rating: (get average-course-rating instructor-data),
        verified-status: (get verification-status instructor-data),
        teaching-since: (get instructor-registration-date instructor-data),
        specialization-areas: (get teaching-specializations instructor-data)
      })
    ERR-RESOURCE-NOT-FOUND
  )
)