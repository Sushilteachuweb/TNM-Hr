# Profile Creation Flow Update - Document Submission Step

## Overview
Updated the profile creation flow to include a mandatory document submission step before completing the signup process.

## Changes Made

### 1. New Screen: DocumentSubmissionScreen
**File:** `lib/View/CreateProfileScreen/DocumentSubmissionScreen.dart`

A new screen that requires users to upload company verification documents:
- Displays document options (GST Certificate, PAN Card, FSSAI License, etc.)
- Supports file picker (PDF, JPG, PNG) and image picker from gallery
- Shows clear instructions for document upload
- Includes "Complete Profile" button to submit with document
- **Document upload is mandatory** - no skip option
- Clean UI matching the existing app theme

### 2. Updated CreateProfileScreen
**File:** `lib/View/CreateProfileScreen/CreateProfileScreen.dart`

Changes:
- Changed "Complete Profile" button to "Next" button with arrow icon
- Removed direct API call from this screen
- Now navigates to DocumentSubmissionScreen with form data
- Removed unused imports and loading state
- Passes all form data (fullName, email, companyName, totalEmp, profileImage) to next screen

### 3. Enhanced Auth API Service
**File:** `lib/services/auth_api_service.dart`

Added new method:
- `signupWithDocument()` - Handles multipart form data upload with verification document
- Uses `http.MultipartRequest` to send file along with form fields
- Properly handles session cookies and error responses
- Maintains existing `signup()` method for backward compatibility

### 4. Updated Dependencies
**File:** `pubspec.yaml`

Added:
- `file_picker: ^8.1.6` - For selecting PDF and image files

## Flow Diagram

```
Login/OTP Verification
        ↓
CreateProfileScreen (Basic Details)
    - Full Name
    - Email
    - Company Name
    - Employee Size
    - Profile Photo (optional)
        ↓
    [Next Button]
        ↓
DocumentSubmissionScreen (New - MANDATORY)
    - Upload Company Document (Required)
    - Document options displayed
    - File/Image picker
        ↓
    [Complete Profile] (Only enabled after document upload)
        ↓
Signup API Called (with document)
        ↓
Home Screen (BottomNavBar)
```

## API Integration

### Signup API Endpoint
**POST** `/signup`

**Request (with document):**
- Content-Type: `multipart/form-data`
- Fields:
  - `fullName`: String
  - `phone`: String
  - `email`: String
  - `companyName`: String
  - `totalEmp`: Number
  - `verificationDocument`: File (PDF/JPG/PNG) - **REQUIRED**

## Features

1. **Document Upload Options:**
   - File picker for PDF/JPG/PNG files
   - Image picker from gallery
   - Visual feedback when document is selected
   - Remove document option to select a different file

2. **User Experience:**
   - Clear instructions and document examples
   - Visual indicators (icons, colors)
   - **Mandatory upload** - users must upload a document to proceed
   - Loading states during API calls
   - Error handling with user-friendly messages
   - Validation to ensure document is uploaded before submission

3. **Accepted Documents:**
   - Company GST Certificate
   - Company PAN Card
   - FSSAI License
   - Company Incorporation Certificate
   - Shop & Establishment Certificate
   - MSME Registration Certificate

## Testing Notes

- No special Android permissions required (uses standard file/image pickers)
- File validation for supported formats (PDF, JPG, PNG)
- Proper error handling for file selection failures
- Session management maintained throughout the flow
- App data initialization happens after successful signup
- Document upload is mandatory - users cannot skip this step

## Key Changes from Previous Version

- Removed "Verify Later" button - document upload is now mandatory
- Removed verification badge promotional card
- Simplified header to focus on document requirement
- Users must upload a document to complete profile creation
