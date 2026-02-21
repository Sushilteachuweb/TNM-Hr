# Report Feature Implementation

## Overview
Added a "Report an Issue" section to the Help & Support screen that allows users to submit issues or concerns with proper text input validation. **Now integrated with real API endpoint.**

## Implementation Details

### 1. UI Components Added
- **Report Section**: Added between Quick Actions and FAQs sections in the help screen
- **Text Input Field**: Multi-line text field with 500 character limit
- **Form Validation**: Ensures minimum 10 characters and non-empty input
- **Submit Button**: Styled button with loading state and success feedback

### 2. Files Modified/Created

#### Modified Files:
- `lib/View/Helps/help_screen.dart`
  - Added TextEditingController and Form validation
  - Added `_buildReportSection()` method
  - Added `_submitReport()` method with loading states
  - Fixed deprecation warnings (withOpacity → withValues)
  - Updated to handle real API responses

#### New Files:
- `lib/services/report_api_service.dart`
  - **Real API integration with https://api.thenaukrimitra.com/api/reports/submit**
  - Uses cookie-based authentication
  - Proper error handling and response parsing
  - Method for fetching user's previous reports

### 3. API Integration

#### Endpoint:
```
POST https://api.thenaukrimitra.com/api/reports/submit
```

#### Request Format:
```json
{
  "message": "User's issue description"
}
```

#### Response Format:
```json
{
  "success": true,
  "message": "Report submitted successfully. Our team will review it shortly.",
  "data": {
    "userId": "6981c905ffb97c7641a7f1b2",
    "role": "user",
    "phone": "8975474123",
    "message": "User's issue description",
    "status": "pending",
    "_id": "6985a20d2bcbe6afc42842b8",
    "createdAt": "2026-02-06T08:10:53.827Z",
    "updatedAt": "2026-02-06T08:10:53.827Z",
    "__v": 0
  }
}
```

#### Authentication:
- Uses cookie-based authentication via `CookieManager`
- Automatically includes session cookie in request headers
- User information (userId, role, phone) is extracted from session on backend

### 4. Features Implemented

#### User Experience:
- Clean, intuitive UI matching the app's design system
- Form validation with helpful error messages
- Loading indicator during submission
- Success/error feedback via SnackBar with API message
- Form clears automatically after successful submission

#### Technical Features:
- Real API integration with proper error handling
- Cookie-based authentication
- Network error handling with user-friendly messages
- Response parsing and validation
- Proper loading states and UI feedback

### 5. UI Layout
The report section is positioned strategically in the help screen:
1. Header section ("How can we help you?")
2. Quick Actions (Email/Call support)
3. **Report an Issue** ← Report section
4. Frequently Asked Questions
5. Contact Us

### 6. Form Validation Rules
- **Required**: Field cannot be empty
- **Minimum Length**: At least 10 characters required
- **Maximum Length**: 500 characters limit (with counter)
- **Real-time validation**: Shows errors on form submission

### 7. API Response Handling

The service properly handles:
- **Success responses** (200/201): Displays success message from API
- **Error responses**: Shows appropriate error message
- **Network errors**: Displays connection error message
- **Validation errors**: Backend validation errors are shown to user

### 8. Current Behavior (Production Ready)
- Form validates input properly
- Shows loading indicator during API call
- Sends authenticated request to backend
- Displays API response message
- Handles all error cases gracefully
- Clears form after successful submission

### 9. Design Considerations
- **Consistent Styling**: Uses app's color scheme and text styles
- **Error State**: Red icon and proper error messaging
- **Success State**: Green success message with check icon from API
- **Loading State**: Circular progress indicator during submission
- **Accessibility**: Proper form labels and validation messages
- **Authentication**: Automatic cookie-based authentication

## Usage
Users can now:
1. Navigate to Help & Support screen
2. Scroll to "Report an Issue" section
3. Enter their issue description (minimum 10 characters)
4. Submit the report (authenticated automatically)
5. Receive confirmation from backend with report ID and status

## Backend Integration Details

### Report Data Stored:
- **userId**: Extracted from authenticated session
- **role**: User's role (user/hr)
- **phone**: User's phone number
- **message**: Issue description
- **status**: Report status (pending/reviewed/resolved)
- **timestamps**: Created and updated timestamps
- **_id**: Unique report identifier

### Report Status Flow:
1. User submits report → Status: "pending"
2. Admin reviews → Status: "reviewed"
3. Issue resolved → Status: "resolved"

## Future Enhancements
1. Add report history screen to view submitted reports
2. Implement report status tracking
3. Add push notifications for report updates
4. Add file attachment capability
5. Implement report categories/types
6. Add priority levels for reports