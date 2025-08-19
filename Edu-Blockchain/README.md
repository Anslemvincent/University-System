# Academic Achievement & Certification Management System

A comprehensive blockchain-based platform for managing educational credentials, course enrollments, academic achievements, and digital certificates with automated verification and reputation tracking.

## Overview

This smart contract provides a decentralized solution for educational institutions to manage courses, track student progress, issue verifiable certificates, and maintain academic records on the blockchain. The system ensures transparency, immutability, and automated verification of educational credentials.

## Features

### Core Functionality
- **Course Management**: Create and manage academic courses with prerequisites and enrollment limits
- **Student Enrollment**: Automated enrollment system with fee processing and prerequisite verification
- **Achievement System**: Configurable achievements with point values and automated tracking
- **Digital Certificates**: Blockchain-verified certificates with tamper-proof verification hashes
- **Reputation System**: Student and instructor reputation tracking based on performance and ratings
- **Course Evaluations**: Student feedback system for course quality assessment

### Security Features
- Role-based access control for instructors and administrators
- Comprehensive input validation and sanitization
- Maintenance mode for system updates
- Anti-duplicate enrollment protection
- Prerequisites verification system

## System Architecture

### Data Storage Maps

#### Course Registry
- `academic-course-registry`: Stores course information including title, description, instructor, prerequisites, and enrollment data
- Tracks enrollment capacity, current student count, and course status

#### Student Management
- `student-course-enrollments`: Individual enrollment records with progress tracking
- `comprehensive-student-profiles`: Student academic profiles with accumulated credits and achievements
- `student-earned-achievements`: Records of achievements earned by students

#### Certification System
- `digital-certificate-registry`: Immutable certificate records with blockchain verification
- `achievement-catalog`: Configurable achievement definitions and requirements

#### Evaluation System
- `course-student-evaluations`: Student feedback and ratings for completed courses
- `instructor-professional-profiles`: Instructor statistics and verification status

## Constants and Limits

### Text Length Limits
- Course title: 100 characters maximum
- Course description: 500 characters maximum
- Achievement description: 500 characters maximum
- Review text: 300 characters maximum
- Notes: 200 characters maximum

### Academic Limits
- Maximum score: 100 points
- Minimum passing grade: 60 points
- Maximum course prerequisites: 10 courses
- Star rating range: 1-5 stars

### Level Progression Thresholds
- Beginner: 500+ achievement points
- Intermediate: 2,000+ achievement points
- Advanced: 5,000+ achievement points
- Expert: 10,000+ achievement points

## Key Functions

### Course Management

#### `create-new-academic-course`
Creates a new course with specified parameters including title, description, credit hours, difficulty level, prerequisites, and enrollment capacity.

**Parameters:**
- `course-title`: Course name (max 100 characters)
- `course-description`: Detailed course description (max 500 characters)
- `credit-hours`: Number of credit hours awarded
- `difficulty-level`: Course difficulty classification
- `prerequisite-courses`: List of required prerequisite course IDs
- `maximum-enrollment`: Maximum number of students allowed

#### `modify-existing-course`
Allows course instructors to update course information including title, description, and active status.

### Student Operations

#### `enroll-student-in-course`
Handles student enrollment with automatic fee processing, prerequisite verification, and enrollment limit checking.

**Requirements:**
- Course must be active
- Enrollment capacity not exceeded
- Prerequisites completed
- Enrollment fee paid (1 STX default)

#### `update-student-course-progress`
Allows instructors to update student progress and automatically marks courses as completed when progress reaches 100%.

### Achievement System

#### `create-new-achievement`
Contract owners can create new achievements with point values and completion requirements.

#### `award-achievement-to-student`
Awards achievements to students and automatically updates their academic level based on accumulated points.

### Certification

#### `issue-course-certificate`
Issues blockchain-verified certificates for completed courses with passing grades.

**Features:**
- Automatic verification hash generation
- Grade recording (letter and numerical)
- Tamper-proof certificate storage
- Credit hour allocation to student profile

#### `revoke-issued-certificate`
Allows certificate revocation by contract owner or original issuer.

### Evaluation System

#### `submit-course-evaluation`
Students can rate completed courses and provide written feedback.

## Read-Only Functions

### Data Retrieval
- `get-course-information`: Retrieve complete course details
- `get-student-enrollment-details`: Check enrollment status and progress
- `get-comprehensive-student-profile`: View student academic summary
- `get-instructor-professional-profile`: Access instructor statistics
- `verify-certificate-authenticity`: Validate certificate legitimacy

### System Information
- `get-system-configuration-info`: View system settings and statistics
- `get-course-enrollment-statistics`: Check course capacity and enrollment data
- `get-instructor-teaching-statistics`: Instructor performance metrics

## Administrative Functions

### System Control
- `enable-maintenance-mode` / `disable-maintenance-mode`: System maintenance control
- `update-enrollment-fee`: Modify course enrollment fees
- `verify-instructor-credentials`: Verify instructor qualifications

## Error Handling

The contract implements comprehensive error handling with specific error codes:

### Authentication Errors (1000s)
- `u1001`: Unauthorized access
- `u1002`: Insufficient permissions
- `u1003`: Contract paused

### Validation Errors (1100s)
- `u1101`: Invalid input data
- `u1102`: Resource not found
- `u1103`: Duplicate entry
- `u1104`: Invalid score range
- `u1105`: Invalid rating value

### Business Logic Errors (1200s)
- `u1201`: Course inactive
- `u1202`: Enrollment limit reached
- `u1203`: Prerequisites not met
- `u1204`: Achievement disabled
- `u1205`: Insufficient balance
- `u1206`: Certification revoked

## Security Considerations

### Access Control
- Only contract deployer can create achievements and manage system settings
- Course instructors can only modify their own courses
- Students can only enroll in active courses with met prerequisites

### Data Integrity
- All inputs are validated for length and format
- Duplicate enrollments are prevented
- Certificate verification hashes ensure authenticity
- Achievement awards are tracked and cannot be duplicated

### Financial Security
- Enrollment fees are automatically processed
- Balance verification before enrollment
- Secure STX transfer handling

## Usage Examples

### Creating a Course
```clarity
(contract-call? .academic-system create-new-academic-course
  "Introduction to Blockchain"
  "A comprehensive course covering blockchain fundamentals and smart contract development"
  u3
  "beginner"
  (list)
  u50
)
```

### Enrolling in a Course
```clarity
(contract-call? .academic-system enroll-student-in-course u1)
```

### Issuing a Certificate
```clarity
(contract-call? .academic-system issue-course-certificate
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
  u1
  u85
  "B+"
)
```

## Deployment Information

- **Network**: Stacks blockchain
- **Language**: Clarity
- **Default Enrollment Fee**: 1 STX (1,000,000 microSTX)
- **Contract Owner**: Deploying address