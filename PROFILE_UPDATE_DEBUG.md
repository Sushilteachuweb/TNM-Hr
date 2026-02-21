# Profile Update Issue - Debugging Guide

## Issue Description
After signing up as a new HR and completing the profile via Edit Profile screen, the success message appears but the updated fields are not reflecting when the profile is fetched again.

## API Endpoints
- **Update Profile**: `PUT https://api.thenaukrimitra.com/api/hr/update-hr`
- **Get Profile**: `GET https://api.thenaukrimitra.com/api/hr/get-users?hrId={hrId}`

## Current Flow

### 1. Edit Profile Screen (`EditProfileScreen.dart`)
When user saves profile:
```dart
// Line 129-139
final result = await HrProfileApiService.updateHrProfile(
  fullName: _nameController.text,
  companyName: _companyController.text,
  email: _emailController.text,
  designation: _designationController.text,
  experience: _experienceController.text,
  hrLocation: _locationController.text,
  bio: _bioController.text,
  skills: _skillsController.text,
  profilePhoto: validatedImage,
);
```

After successful update:
```dart
// Line 148-165
if (result['success'] == true) {
  // Updates local storage
  await UserStorage.updateUserProfile(...);
  
  // Updates provider
  final hrProfileProvider = Provider.of<HrProfileProvider>(context, listen: false);
  await hrProfileProvider.loadProfileFromLocal();
  
  // Returns true to trigger refresh
  Navigator.pop(context, true);
}
```

### 2. Profile Screen (`profile_screen.dart`)
When returning from edit:
```dart
// Line 382-391
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditProfileScreen(initialData: _userData),
  ),
);
if (result == true) {
  _loadUserData(); // Fetches from API and updates local storage
}
```

## Potential Issues to Check

### Issue 1: API Not Saving Data
**Check**: Is the update API actually saving the data to the database?

**How to verify**:
1. Add more detailed logging in `hr_profile_api_service.dart` line 30-110
2. Check the API response body after update
3. Verify the request fields being sent match what the API expects

**Expected API Response**:
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": { /* updated profile data */ }
}
```

### Issue 2: Get Profile API Not Returning Updated Data
**Check**: Is the get profile API returning stale/cached data?

**How to verify**:
1. Check the API response in `hr_profile_api_service.dart` line 140-160
2. Look for the updated fields in the response
3. Check if there's server-side caching

**Current Implementation** (Line 95-105):
```dart
print("👤 Request Fields: ${request.fields}");
print("👤 Request Files: ${request.files.map((f) => f.field).toList()}");

final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
final response = await http.Response.fromStream(streamedResponse);

print("👤 Raw Response: ${response.body}");
print("👤 Status Code: ${response.statusCode}");
```

### Issue 3: Field Name Mismatch
**Check**: Do the field names in the update request match what the API expects?

**Current field names being sent**:
- `fullName`
- `companyName`
- `email`
- `designation`
- `experience`
- `hrLocation`
- `bio`
- `skills[0]` (array format)
- `profilePhoto` (file)

**Field names in get response** (need to verify):
- Check if API returns `fullName` or `name`
- Check if API returns `hrLocation` or `location`
- Check if API returns `skills` as array or string

### Issue 4: Session/Cookie Issue
**Check**: Is the session cookie being sent correctly with both requests?

**How to verify**:
1. Check if `CookieManager.getHeadersWithCookie()` is returning valid cookie
2. Verify the cookie is not expired between update and get requests

### Issue 5: State Refresh Issue
**Check**: Is the UI state being updated after API fetch?

**Current implementation looks correct**:
```dart
// Line 156-159 in profile_screen.dart
final updatedData = await UserStorage.getLoginData();
setState(() {
  _userData = updatedData;
});
```

## Debugging Steps

### Step 1: Add Enhanced Logging
Add these print statements to track the full flow:

In `hr_profile_api_service.dart` after line 105:
```dart
print("👤 UPDATE REQUEST SENT");
print("👤 Fields: ${request.fields}");
print("👤 Files: ${request.files.length}");
```

After line 110:
```dart
print("👤 UPDATE RESPONSE RECEIVED");
print("👤 Status: ${response.statusCode}");
print("👤 Body: ${response.body}");
print("👤 Data returned: ${data['data']}");
```

In `hr_profile_api_service.dart` line 155:
```dart
print("👤 GET PROFILE RESPONSE");
print("👤 Raw data: ${response.body}");
print("👤 Parsed data: $profileData");
print("👤 Designation: ${profileData['designation']}");
print("👤 Experience: ${profileData['experience']}");
print("👤 hrLocation: ${profileData['hrLocation']}");
```

### Step 2: Test API Directly
Use Postman or similar tool to:
1. Call update API with test data
2. Immediately call get API with same hrId
3. Verify the updated data is returned

### Step 3: Check API Response Structure
The get profile API has complex response handling (line 165-210). Verify:
- Is the response wrapped in `data` or `user` key?
- Is it an array or object?
- Are field names consistent?

### Step 4: Check for Race Conditions
Ensure the get profile API is called AFTER the update completes:
```dart
// In EditProfileScreen.dart
if (result['success'] == true) {
  await UserStorage.updateUserProfile(...);
  await hrProfileProvider.loadProfileFromLocal();
  
  // Add small delay to ensure DB write completes
  await Future.delayed(Duration(milliseconds: 500));
  
  Navigator.pop(context, true);
}
```

## Recommended Fix

Based on the code analysis, the most likely issue is:

### Option 1: API Not Returning Updated Data Immediately
Add a delay or force refresh:

```dart
// In profile_screen.dart, line 391
if (result == true) {
  // Add delay to ensure DB write completes
  await Future.delayed(Duration(milliseconds: 500));
  await _loadUserData();
}
```

### Option 2: Field Name Mismatch
Verify the API expects these exact field names. Check backend logs or API documentation.

### Option 3: Response Not Including Updated Fields
Modify the update API to return the complete updated profile in the response, then use that directly:

```dart
// In EditProfileScreen.dart after line 148
if (result['success'] == true && result['data'] != null) {
  // Extract updated profile from response
  final updatedProfile = result['data']['data'] ?? result['data'];
  
  // Update local storage with response data
  await UserStorage.updateUserProfile(
    userName: updatedProfile['fullName'] ?? _nameController.text,
    userEmail: updatedProfile['email'] ?? _emailController.text,
    // ... use response data instead of form values
  );
}
```

## Next Steps
1. Run the app with enhanced logging
2. Perform a profile update
3. Check the console logs for:
   - Update request fields
   - Update response data
   - Get profile response data
4. Compare the data at each step to identify where the issue occurs
