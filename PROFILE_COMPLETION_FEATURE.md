# Profile Completion Snackbar Feature

## Overview
This feature adds a snackbar popup that appears when new users login to the app after signup, encouraging them to complete their profile. When users tap on the snackbar, it opens the edit profile page.

## Implementation Details

### 1. User Storage Updates
- Added `_profileCompletionSnackbarShownKey` to track if the snackbar has been shown
- Added `hasProfileCompletionSnackbarBeenShown()` method to check the flag
- Added `markProfileCompletionSnackbarAsShown()` method to set the flag

### 2. BottomNavBar Updates
- Added `showProfileCompletionSnackbar` parameter to control when to show the snackbar
- Added `_checkAndShowProfileCompletionSnackbar()` method to check if snackbar should be shown
- Added `_showProfileCompletionSnackbar()` method to display the snackbar
- Added `_navigateToEditProfile()` method to handle navigation to edit profile screen

### 3. CreateProfileScreen Updates
- Modified navigation to BottomNavBar to pass `showProfileCompletionSnackbar: true`

## User Flow

### New Users
1. User signs up → CreateProfileScreen
2. User completes basic profile → BottomNavBar with snackbar flag
3. Snackbar appears: "Complete Your Profile - Add more details to get better job matches"
4. User can tap "Complete" button to go to EditProfileScreen
5. Snackbar is marked as shown and won't appear again

### Existing Users
1. User logs in → BottomNavBar (no snackbar flag)
2. No snackbar appears (normal flow)

## Snackbar Design
- **Background**: Primary blue color (`AppColors.primary`)
- **Icon**: Person outline icon
- **Title**: "Complete Your Profile"
- **Subtitle**: "Add more details to get better job matches"
- **Action Button**: "Complete" with white text and semi-transparent background
- **Duration**: 6 seconds
- **Behavior**: Floating with rounded corners
- **Auto-dismiss**: Marks as shown after 6 seconds even if user doesn't interact

## Technical Features
- **One-time display**: Uses SharedPreferences to ensure snackbar only shows once per user
- **Error handling**: Graceful error handling for navigation and storage operations
- **Success feedback**: Shows success message when profile is updated
- **Consistent styling**: Follows app's design system and color scheme