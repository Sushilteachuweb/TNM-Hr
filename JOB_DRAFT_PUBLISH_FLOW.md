# Job Draft-to-Publish Flow Implementation

## Overview
Updated the job posting logic to implement a draft-to-publish workflow. Jobs are now saved as drafts first, and can be published later when the user has credits.

## Changes Made

### 1. API Routes (`lib/services/api_routes.dart`)
- Added new endpoint: `getDraftJobs` for fetching draft jobs
  - Endpoint: `https://api.thenaukrimitra.com/api/hr/drafts`
- Added new endpoint: `publishJob(String jobId)` for publishing draft jobs
  - Endpoint: `https://api.thenaukrimitra.com/api/jobs/{jobId}/publish`

### 2. Job API Service (`lib/services/job_api_service.dart`)
- Updated `createJob()` to return job ID in response for tracking draft jobs
- Added new method `getDraftJobs()` that:
  - Fetches all draft jobs for the HR
  - Returns list of jobs with status "draft"
- Added new method `publishJob(String jobId)` that:
  - Sends POST request to publish endpoint with job ID in URL path
  - Backend checks for active subscription
  - Backend checks for available credits
  - Backend deducts 1 credit if available
  - Backend publishes the job if successful
  - Returns error message if no credits: "Please buy a plan to get credits and publish the job."

### 3. Job Provider (`lib/Provider/job_provider.dart`)
- Updated `fetchJobs()` method to:
  - Fetch both regular jobs and draft jobs in parallel using `Future.wait()`
  - Merge draft jobs and regular jobs into a single list
  - Draft jobs appear first in the list
- Updated `createJob()` method to save jobs as drafts (removed payment check)
- Added new method `publishJob(String jobId)` to publish draft jobs
- Added helper methods:
  - `getDraftJobs()` - returns list of draft jobs
  - `getPublishedJobs()` - returns list of published jobs (active, pending, closed)

### 4. Job Creation Service (`lib/services/job_creation_service.dart`)
- Renamed `createJobWithCreditDeduction()` to `createJobAsDraft()`
- Removed credit deduction logic (now handled by publish API)
- Added new method `publishDraftJob(String jobId)` that:
  - Calls the publish API
  - Shows success/error messages
  - Returns true/false based on result

### 5. Subscription Screen (`lib/View/Home/CreateNewJobDetails/subscription/subscription.dart`)
- Completely simplified the screen
- Removed all payment/plan selection logic
- Now only creates job as draft and navigates to Jobs screen
- Shows success message: "Job saved as draft successfully! You can publish it from the Jobs screen."

### 6. Job Screen (`lib/View/Jobs/job_Screen.dart`)
- Added "Draft" tab as the first tab (default selected)
- Updated tab bar to show: Draft | Active | Pending | Closed
- Added "Publish Job" button for draft jobs (replaces "Applicants" button)
- Added `_showPublishDialog()` method that:
  - Explains what will happen when publishing
  - Calls `JobCreationService.publishDraftJob()`
  - Shows loading indicator during publish
  - Refreshes job list after successful publish
- Updated `_getStatusColor()` to handle "draft" status with warning color

## New Flow

### Creating a Job:
1. User fills out job form in `CreateNewJobDetails`
2. User clicks "Submit Job"
3. Job is saved as **draft** via `POST /api/jobs/hr/create` (status: "draft")
4. User is redirected to Jobs screen with success message
5. Draft job appears in "Draft" tab

### Fetching Jobs:
1. App fetches both draft and regular jobs in parallel:
   - Draft jobs: `GET /api/hr/drafts`
   - Regular jobs: `GET /api/hr/jobs`
2. Jobs are merged with draft jobs appearing first
3. Jobs are displayed in appropriate tabs based on status

### Publishing a Draft Job:
1. User navigates to Jobs screen → Draft tab
2. User sees draft jobs with "Publish Job" button
3. User clicks "Publish Job"
4. System shows elegant confirmation dialog with:
   - Job title
   - List of actions that will happen:
     - ✓ Check active subscription
     - ✓ Check available credits
     - ✓ Deduct 1 credit
     - ✓ Publish job live
5. User confirms by clicking "Publish Now"
6. System shows loading indicator with "Publishing job..." message
7. API call: `POST /api/jobs/:jobId/publish` with job ID in URL path
8. API checks subscription and credits:
   - **If credits available**: 
     - Job is published
     - 1 credit deducted
     - Success message shown
     - Job moves to "Active" tab
     - Jobs list refreshes automatically
   - **If no credits**: 
     - Loading indicator dismissed
     - Elegant dialog shown with:
       - Warning icon
       - Error message: "Please buy a plan to get credits and publish the job"
       - Helpful tip about purchasing a plan
       - "Later" button to dismiss
       - "Buy Plan" button to navigate to Plans screen
     - User can click "Buy Plan" to go directly to Plans tab
9. User can purchase a plan and retry publishing

## API Endpoints Used

### 1. Create Job (Draft)
- **Endpoint**: `POST https://api.thenaukrimitra.com/api/jobs/hr/create`
- **Purpose**: Creates a new job as draft
- **Response**: Returns job data with status "draft"

### 2. Get Draft Jobs
- **Endpoint**: `GET https://api.thenaukrimitra.com/api/hr/drafts`
- **Purpose**: Fetches all draft jobs for the logged-in HR
- **Response**: Returns object with jobs array and pagination info
  ```json
  {
    "success": true,
    "message": "Jobs fetched successfully",
    "data": {
      "jobs": [...],
      "pagination": {
        "totalJobs": 4,
        "totalPages": 1,
        "currentPage": 1,
        "pageSize": 10
      },
      "totalApplications": 0
    }
  }
  ```

### 3. Get Regular Jobs
- **Endpoint**: `GET https://api.thenaukrimitra.com/api/hr/jobs`
- **Purpose**: Fetches all published jobs (active, pending, closed)
- **Response**: Returns object with jobs array and pagination info (same structure as draft jobs)
  ```json
  {
    "success": true,
    "message": "Jobs fetched successfully",
    "data": {
      "jobs": [...],
      "pagination": {
        "totalJobs": 3,
        "totalPages": 1,
        "currentPage": 1,
        "pageSize": 10
      },
      "totalApplications": 0
    }
  }
  ```

### 4. Publish Job
- **Endpoint**: `POST https://api.thenaukrimitra.com/api/jobs/:jobId/publish`
- **Purpose**: Publishes a draft job (checks credits and subscription)
- **Path Parameter**: `jobId` - The ID of the draft job to publish
- **Response**: Returns success/error based on credit availability

## API Response Examples

### Create Job (Draft) Response:
```json
{
  "success": true,
  "message": "Job created successfully",
  "data": {
    "title": "Sales Executive",
    "status": "draft",
    "isPublished": false,
    "_id": "6985baf5864acb36d23fad65",
    ...
  }
}
```

### Get Draft Jobs Response:
```json
{
  "success": true,
  "message": "Jobs fetched successfully",
  "data": {
    "jobs": [
      {
        "_id": "6985baf5864acb36d23fad65",
        "title": "Sales Executive",
        "companyName": "ABC Technologies Pvt Ltd",
        "status": "draft",
        "isPublished": false,
        ...
      }
    ],
    "pagination": {
      "totalJobs": 4,
      "totalPages": 1,
      "currentPage": 1,
      "pageSize": 10
    },
    "totalApplications": 0
  }
}
```

### Publish Job Response (Success):
```json
{
  "success": true,
  "message": "Job published successfully",
  "data": {
    "title": "Sales Executive",
    "status": "active",
    "isPublished": true,
    "creditsDeducted": 1,
    ...
  }
}
```

### Publish Job Response (No Credits):
```json
{
  "success": false,
  "message": "Please buy a plan to get credits and publish the job."
}
```

## Benefits

1. **Better User Experience**: Users can create jobs without worrying about credits immediately
2. **Clear Separation**: Draft and published jobs are clearly separated in different tabs
3. **Flexible Publishing**: Users can review drafts before publishing
4. **Credit Management**: Credits are only deducted when job is actually published
5. **Elegant Error Handling**: 
   - Beautiful dialogs instead of simple snackbars
   - Clear visual feedback with icons and colors
   - Helpful tips and guidance
   - Direct navigation to Plans screen when credits needed
6. **Parallel Loading**: Draft and regular jobs are fetched simultaneously for better performance
7. **Dedicated API**: Separate endpoint for draft jobs ensures better data organization
8. **Non-blocking UI**: Loading states don't block user interaction unnecessarily
9. **Smart Navigation**: Automatically redirects to Plans tab when user needs to buy credits

## Technical Implementation Details

### Job Model Updates
The `Job` model has been updated to handle all fields from both draft and published job APIs:

**New Fields Added:**
- `hrId` - HR identifier (String, optional)
- `planType` - Changed from String to List<String> to handle multiple plans
- `isPublished` - Boolean flag indicating if job is published
- `isFeatured` - Boolean flag for featured jobs
- `views` - Number of views (int)
- `applications` - Array of applications
- `location` - GeoJSON location object (optional)
- `isDraft` - Helper getter to check if job is draft
- `applicationsCount` - Helper getter for application count
- `planTypeSummary` - Helper getter for formatted plan names

**Enhanced Parsing:**
- `planType` - Handles both array and string formats
- `documents` - Handles both array and comma-separated string formats
- `coordinates` - Extracts from either direct field or GeoJSON location object
- `location` - Preserves GeoJSON structure for mapping features

### Job Fetching Strategy
- Uses `Future.wait()` to fetch draft and regular jobs in parallel
- Merges results with draft jobs appearing first in the list
- Handles different response structures from both APIs
- Updates applicant counts for all jobs after fetching

### Publish Flow
- Job ID is passed as URL path parameter (`:jobId`)
- Backend validates subscription and credit availability
- Credit deduction happens atomically with job publishing
- Job status changes from "draft" to "active" upon successful publish
- `isPublished` flag changes from false to true

### Error Handling
- Authentication errors redirect to login
- Network timeouts show retry option
- No credits error shows clear message to buy plan
- All errors are logged for debugging

## Testing Checklist

- [x] Create job saves as draft
- [x] Draft jobs appear in Draft tab
- [x] Publish button appears for draft jobs
- [x] Publish dialog shows correct information
- [x] Publish API is called with correct job ID
- [x] Success message shown when job published
- [x] Error message shown when no credits
- [x] Job moves from Draft to Active tab after publishing
- [x] Job list refreshes after publish
