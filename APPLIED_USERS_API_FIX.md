# Applied Users API Integration Fix

## Overview
Updated the applied users API integration to properly fetch and display applicant details using the correct endpoint.

## API Endpoint

**Endpoint**: `GET https://api.thenaukrimitra.com/api/hr/applied-users?jobId={jobId}`

**Example**: `https://api.thenaukrimitra.com/api/hr/applied-users?jobId=6985f3562a5194af58b2d44d`

## Changes Made

### 1. API Service Updates (`lib/services/job_api_service.dart`)

#### Enhanced Response Parsing
The `getAppliedUsers` method now handles multiple response structures:

```dart
// Structure 1: Direct applicants array
{
  "applicants": [...]
}

// Structure 2: Nested in data object
{
  "data": {
    "applicants": [...]
  }
}

// Structure 3: Data is array
{
  "data": [...]
}

// Structure 4: Direct array
[...]
```

#### Improved Logging
- Logs the response data structure keys
- Logs the number of applicants found
- Helps debug response format issues

### 2. Existing Implementation

The following components were already correctly implemented:

#### API Route (`lib/services/api_routes.dart`)
```dart
static String getAppliedUsers(String jobId) =>
    "$baseUrl/applied-users?jobId=$jobId";
```
This correctly expands to: `https://api.thenaukrimitra.com/api/hr/applied-users?jobId=xxx`

#### Provider (`lib/Provider/applicant_provider.dart`)
- Fetches applicants using the job ID
- Handles loading states
- Manages contacted/non-contacted applicants
- Provides error handling

#### UI (`lib/View/Jobs/Applicants/applicants.dart`)
- Displays applicants in a card layout
- Shows applicant details (name, salary, education, experience, skills, location, email)
- Provides "Show Number" and "WhatsApp" buttons
- Separates applicants into "Applicants" and "Contacted" tabs
- Includes pull-to-refresh functionality

## Expected Response Format

The API returns applicant data with the following structure:

```json
{
  "success": true,
  "totalApplicants": 1,
  "applicants": [
    {
      "_id": "697da3cc23ea45b7e7527b40",
      "fullName": "Review For Play",
      "phone": "9999999999",
      "gender": "male",
      "email": "reviewforplay@gmail.com",
      "image": "image-1770624784683-528575912.jpg",
      "role": "user",
      "skills": ["jvubjb", "vibib"],
      "resume": "resume-1770624784683-942923591.pdf",
      "education": "Graduate",
      "jobCategory": "69721c7f73d74c5ea50a6601",
      "isExperienced": true,
      "totalExperience": 2,
      "currentSalary": 550000,
      "language": ["English", "Hindi"],
      "userLocation": "Panaji",
      "locationString": null,
      "locationGeo": {
        "type": "Point",
        "coordinates": [73.8293928, 15.5009538]
      },
      "isReferralRedeemed": false,
      "totalReferrals": 0,
      "successfulReferrals": 0,
      "createdAt": "2026-01-31T06:40:12.141Z",
      "updatedAt": "2026-02-09T08:13:04.941Z",
      "__v": 0,
      "referralHistory": []
    }
  ]
}
```

## Field Mapping

The applicant card displays the following fields with fallbacks:

| Display Field | API Fields (Priority Order) | Fallback |
|--------------|----------------------------|----------|
| Name | `fullName`, `name` | "Unknown" |
| Phone | `phone` | "N/A" |
| Email | `email` | "Not specified" |
| Salary | `currentSalary`, `expectedSalary`, `salary` | "Not specified" |
| Education | `education` | "Not specified" |
| Experience | `totalExperience`, `experience` | "0" |
| Skills | `skills` (array or string) | Not shown if empty |
| Location | `userLocation`, `city` | Not shown if empty |

## Features

### Applicant Card Features
1. **Profile Display**: Shows avatar, name, and key details
2. **Contact Actions**:
   - Show Number: Displays phone in dialog and marks as contacted
   - WhatsApp: Opens WhatsApp chat with the applicant
3. **Categorization**: Separates into "Applicants" and "Contacted" tabs
4. **Pull-to-Refresh**: Refresh applicant list by pulling down

### Error Handling
- Network timeout handling (30 seconds)
- Server error messages
- Schema registration errors
- Empty state when no applicants
- Retry functionality on error

### Loading States
- Skeleton loading animation while fetching
- Prevents multiple simultaneous requests
- Shows loading indicator during refresh

## Testing Checklist

- [ ] API endpoint is correct
- [ ] Job ID is passed correctly
- [ ] Response is parsed successfully
- [ ] Applicants are displayed in cards
- [ ] All fields are shown correctly
- [ ] Show Number button works
- [ ] WhatsApp button opens WhatsApp
- [ ] Contacted tab shows contacted applicants
- [ ] Pull-to-refresh works
- [ ] Error states are handled
- [ ] Empty state is shown when no applicants
- [ ] Console logs show correct data structure

## Debugging

### Check Console Logs
When testing, look for these console messages:

```
💼 Calling Get Applied Users API: https://api.thenaukrimitra.com/api/hr/applied-users?jobId=xxx
💼 Raw Response: {...}
💼 Status Code: 200
💼 Response data structure: [applicants, ...]
💼 Found X applicants
✅ Applied users fetched successfully
```

### Common Issues

1. **No applicants showing**:
   - Check console for response structure
   - Verify API returns data in expected format
   - Check if jobId is correct

2. **Fields showing "N/A"**:
   - Check if API returns the expected field names
   - Verify field mapping in the code

3. **Error messages**:
   - Check network connectivity
   - Verify authentication cookies
   - Check API server status

## Future Enhancements

- Add applicant filtering (by education, experience, salary)
- Add applicant sorting options
- Add applicant search functionality
- Add bulk actions (contact multiple applicants)
- Add applicant notes/comments
- Add interview scheduling
- Export applicant list to CSV/PDF
