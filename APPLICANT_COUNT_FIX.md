# Applicant Count Fix

## Problem
The applicant count was showing 0 even when there were actual applicants who applied to jobs. This happened because:

1. The backend API `getHrJobs` returns job data with `applicantsCount` field
2. However, this field was not being updated when new applicants applied
3. The actual applicant data is available through a separate API `getAppliedUsers`

## Solution
Updated the `JobProvider` to fetch actual applicant counts by:

1. **Added `_updateApplicantCounts()` method**: Fetches real applicant data for each job and updates the count
2. **Modified `fetchJobs()` method**: Now calls `_updateApplicantCounts()` after fetching jobs
3. **Added `updateJobApplicantCount()` method**: Updates count for a specific job
4. **Added `refreshApplicantCounts()` method**: Manually refresh all applicant counts

## Implementation Details

### JobProvider Changes
- `_updateApplicantCounts()`: Iterates through all jobs and fetches actual applicant data
- `updateJobApplicantCount(jobId)`: Updates count for a specific job
- `refreshApplicantCounts()`: Manual refresh for all jobs

### UI Integration
- **Job Details Screen**: Automatically updates applicant count when opened
- **Applicants Screen**: Updates job's applicant count when viewing applicants
- **Job List**: Uses RefreshIndicator to allow manual refresh

## How It Works

1. When jobs are fetched, the system now also fetches actual applicant data
2. The `applicantsCount` field is updated with real data from `getAppliedUsers` API
3. UI displays the correct applicant count
4. Users can pull-to-refresh to get latest counts

## Files Modified
- `lib/Provider/job_provider.dart` - Added applicant count update logic
- `lib/View/Jobs/job_details_screen.dart` - Auto-refresh on load
- `lib/View/Jobs/Applicants/applicants.dart` - Update count when viewing applicants

## Testing
1. Create a job
2. Have someone apply to the job
3. Check that the applicant count shows the correct number in:
   - Job list screen
   - Job details screen
   - Pull-to-refresh should update counts

## Notes
- The fix handles API errors gracefully (keeps existing count or sets to 0)
- Includes detailed logging for debugging
- Works with existing RefreshIndicator functionality