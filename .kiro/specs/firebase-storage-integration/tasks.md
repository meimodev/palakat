# Implementation Plan

- [ ] 1. Set up Firebase Admin SDK and storage infrastructure
  - Install firebase-admin package in backend
  - Configure Firebase Admin SDK with service account credentials
  - Create storage configuration service for environment management
  - Set up Firebase Storage bucket references and security rules
  - _Requirements: 3.1, 3.2_

- [ ] 2. Create core Firebase Storage service
  - [ ] 2.1 Implement FirebaseStorageService with upload functionality
    - Write file upload method with structured path generation
    - Implement file deletion and cleanup methods
    - Add file metadata retrieval functionality
    - _Requirements: 1.2, 3.3, 4.1_

  - [ ]* 2.2 Write property test for storage path generation
    - **Property 2: Storage organization consistency**
    - **Validates: Requirements 1.2, 3.3, 4.1, 4.4**

  - [ ] 2.3 Implement signed URL generation
    - Create method for generating time-limited signed URLs
    - Add URL expiration and refresh logic
    - Implement security validation for URL access
    - _Requirements: 5.2, 5.4_

  - [ ]* 2.4 Write property test for signed URL generation
    - **Property 10: Signed URL generation**
    - **Validates: Requirements 5.2, 5.4**

- [ ] 3. Enhance database schema and models
  - [ ] 3.1 Update FileManager Prisma model
    - Add new fields: filename, storagePath, contentType, sizeInBytes, uploadedBy, churchId
    - Create database migration for schema changes
    - Update existing relationships and indexes
    - _Requirements: 1.3, 3.4_

  - [ ] 3.2 Create file upload DTOs and validation
    - Implement FileUploadDto with validation rules
    - Create FileUploadResponseDto for API responses
    - Add file type and size validation logic
    - _Requirements: 1.1, 1.5_

  - [ ]* 3.3 Write property test for file validation
    - **Property 1: File validation consistency**
    - **Validates: Requirements 1.1, 2.1**

- [ ] 4. Implement enhanced file service layer
  - [ ] 4.1 Create coordinated upload workflow
    - Implement file upload coordination between storage and database
    - Add transaction handling for data consistency
    - Create rollback mechanisms for failed uploads
    - _Requirements: 1.3, 3.4_

  - [ ]* 4.2 Write property test for database-storage consistency
    - **Property 3: Database-storage consistency**
    - **Validates: Requirements 1.3, 3.4, 6.1**

  - [ ] 4.3 Implement access control and authorization
    - Add user permission validation for file operations
    - Implement church membership-based access control
    - Create role-based authorization for file management
    - _Requirements: 3.2, 5.1, 5.3_

  - [ ]* 4.4 Write property test for authorization enforcement
    - **Property 8: Authorization enforcement**
    - **Validates: Requirements 3.2, 5.1, 5.3**

  - [ ] 4.5 Add file cleanup and orphan detection
    - Implement orphaned file detection logic
    - Create cleanup service for removing unused files
    - Add cleanup reporting and logging
    - _Requirements: 6.2, 6.3, 6.4_

  - [ ]* 4.6 Write property test for cleanup data integrity
    - **Property 11: Cleanup data integrity**
    - **Validates: Requirements 6.2, 6.3**

- [ ] 5. Create file upload API endpoints
  - [ ] 5.1 Implement file upload controller
    - Create multipart file upload endpoint
    - Add upload token generation and validation
    - Implement upload progress tracking
    - _Requirements: 3.1, 3.5_

  - [ ]* 5.2 Write property test for security token generation
    - **Property 7: Security token generation**
    - **Validates: Requirements 3.1**

  - [ ] 5.3 Add file access and download endpoints
    - Create secure file access endpoint with signed URLs
    - Implement file metadata retrieval API
    - Add file deletion endpoint with authorization
    - _Requirements: 5.1, 5.2_

  - [ ] 5.4 Implement error handling and validation
    - Add comprehensive error handling for all file operations
    - Create specific error messages for different failure scenarios
    - Implement retry logic for transient failures
    - _Requirements: 1.4, 7.1, 7.3, 7.4_

  - [ ]* 5.5 Write property test for error message specificity
    - **Property 13: Error message specificity**
    - **Validates: Requirements 7.1, 7.5**

- [ ] 6. Checkpoint - Ensure backend tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Create shared Flutter file models and services
  - [ ] 7.1 Create file upload models in shared package
    - Implement FileUploadRequest and FileUploadResult models using Freezed
    - Add JSON serialization for API communication
    - Create file category and metadata enums
    - _Requirements: 1.2, 2.1_

  - [ ] 7.2 Implement base file repository in shared package
    - Create FileRepository interface with core file operations
    - Implement API communication methods for file upload/download
    - Add signed URL caching and refresh logic
    - _Requirements: 5.2, 5.4_

  - [ ]* 7.3 Write unit tests for shared file models
    - Test JSON serialization and deserialization
    - Validate model creation and equality
    - Test enum conversions and edge cases
    - _Requirements: 1.2, 2.1_

- [ ] 8. Enhance existing mobile file upload functionality
  - [ ] 8.1 Extend existing file upload service to use Firebase Storage
    - Enhance the existing FilePicker implementation in activity_publish_screen.dart
    - Integrate Firebase Storage upload with the existing onSelectedFile method
    - Add image compression for mobile uploads using existing file handling
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ]* 8.2 Write property test for upload progress reporting
    - **Property 4: Upload progress reporting**
    - **Validates: Requirements 2.2**

  - [ ] 8.3 Add network resilience to existing upload flow
    - Enhance existing file upload with automatic retry for failed uploads
    - Add exponential backoff for network errors to current implementation
    - Create offline upload queue that works with existing file selection
    - _Requirements: 2.4, 7.3_

  - [ ]* 8.4 Write property test for network resilience
    - **Property 6: Network resilience**
    - **Validates: Requirements 2.4, 7.3, 7.4**

  - [ ] 8.5 Enhance existing permission handling
    - Extend current file picker with storage permission management
    - Improve user guidance for permission setup in existing UI
    - Handle permission denial gracefully in current file upload flow
    - _Requirements: 2.5_

- [ ] 9. Implement admin panel file upload service
  - [ ] 9.1 Create web file upload service
    - Implement browser file selection and validation
    - Add drag-and-drop file upload interface
    - Create batch upload functionality for multiple files
    - _Requirements: 1.1, 1.2_

  - [ ] 9.2 Add upload state management
    - Implement upload progress tracking for web
    - Create upload queue management
    - Add upload cancellation and retry capabilities
    - _Requirements: 1.4, 2.2_

  - [ ]* 9.3 Write unit tests for web file upload
    - Test file selection and validation logic
    - Mock upload progress and state changes
    - Validate error handling and user feedback
    - _Requirements: 1.1, 1.4_

- [ ] 10. Enhance existing file management UI components
  - [ ] 10.1 Extend existing mobile file upload widgets
    - Enhance existing _buildFileUploadField widget with Firebase Storage integration
    - Add upload progress indicator to existing file picker button
    - Extend existing _buildSelectedFileCard with Firebase Storage metadata
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ]* 10.2 Write property test for UI state consistency
    - **Property 5: UI state consistency**
    - **Validates: Requirements 1.4, 2.3**

  - [ ] 10.3 Build admin panel file management interface
    - Create file upload component with drag-and-drop
    - Implement file list and management interface
    - Add file preview and download functionality
    - _Requirements: 1.1, 1.2, 1.4_

  - [ ] 10.4 Add file access and security UI
    - Implement secure file viewing with signed URLs
    - Create permission-based file access controls
    - Add file sharing and access management
    - _Requirements: 5.1, 5.2, 5.3_

- [ ] 11. Integrate with existing features
  - [ ] 11.1 Update document management system
    - Modify document creation to use Firebase Storage
    - Update document viewing to use signed URLs
    - Migrate existing document references
    - _Requirements: 1.2, 5.2_

  - [ ] 11.2 Update report generation system
    - Modify report storage to use Firebase Storage
    - Update report access to use signed URLs
    - Implement report file cleanup
    - _Requirements: 1.2, 6.1_

  - [ ] 11.3 Enhance existing activity file attachments
    - Upgrade existing activity file upload to use Firebase Storage
    - Implement activity-specific file organization in existing publish flow
    - Add file access control to existing activity file handling
    - _Requirements: 4.1, 5.1_

- [ ] 12. Implement security and path validation
  - [ ] 12.1 Add path traversal protection
    - Implement secure path generation and validation
    - Prevent unauthorized file access through path manipulation
    - Add security logging for suspicious access attempts
    - _Requirements: 4.3, 5.5_

  - [ ]* 12.2 Write property test for path security validation
    - **Property 9: Path security validation**
    - **Validates: Requirements 4.3**

  - [ ] 12.3 Implement comprehensive access logging
    - Log all file access attempts with user context
    - Create audit trail for file operations
    - Add alerting for unauthorized access attempts
    - _Requirements: 5.5, 7.5_

- [ ] 13. Add cleanup and maintenance features
  - [ ] 13.1 Create automated cleanup service
    - Implement scheduled cleanup of orphaned files
    - Add cleanup reporting and notifications
    - Create manual cleanup tools for administrators
    - _Requirements: 6.2, 6.3, 6.4_

  - [ ]* 13.2 Write property test for cleanup reporting consistency
    - **Property 12: Cleanup reporting consistency**
    - **Validates: Requirements 6.4**

  - [ ] 13.3 Add storage monitoring and alerts
    - Monitor storage usage and quota limits
    - Create alerts for storage threshold breaches
    - Implement storage analytics and reporting
    - _Requirements: 7.2_

- [ ] 14. Create migration utilities
  - [ ] 14.1 Build file migration service
    - Create utility to migrate existing files to Firebase Storage
    - Implement data integrity verification
    - Add rollback capabilities for failed migrations
    - _Requirements: 1.2, 1.3_

  - [ ] 14.2 Create migration monitoring and reporting
    - Track migration progress and success rates
    - Generate migration reports and statistics
    - Add error handling and recovery for migration failures
    - _Requirements: 6.4, 7.1_

- [ ]* 14.3 Write unit tests for migration utilities
  - Test file migration logic and data integrity
  - Validate rollback mechanisms
  - Test error handling and recovery scenarios
  - _Requirements: 1.2, 1.3_

- [ ] 15. Final checkpoint - Comprehensive testing
  - Ensure all tests pass, ask the user if questions arise.
  - Run integration tests with real Firebase Storage
  - Validate end-to-end file upload and access workflows
  - Verify security and access control enforcement