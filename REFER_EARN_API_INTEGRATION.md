# Refer & Earn API Integration

## Overview
Integrated real API endpoints for the Refer & Earn feature with complete stats tracking and pull-to-refresh functionality.

## Changes Made

### 1. API Service Updates (`lib/services/refer_earn_api_service.dart`)

#### Generate Referral Code
- **Endpoint**: `POST https://api.thenaukrimitra.com/api/hr/referral/generate`
- **Authentication**: Uses cookie-based authentication via `CookieManager`
- **Response Handling**: Supports multiple response structures (referralCode, data.referralCode, code)
- **Error Handling**: Proper error messages and exception handling

#### Redeem Referral Code
- **Endpoint**: `POST https://api.thenaukrimitra.com/api/hr/referral/redeem`
- **Request Body**: `{ "referralCode": "REF022UQE" }`
- **Response**: Returns success status, message, and credits earned
- **Error Handling**: Returns user-friendly error messages

#### Get Referral Stats
- **Endpoint**: `GET https://api.thenaukrimitra.com/api/hr/referral/stats`
- **Response Structure**:
```json
{
  "success": true,
  "data": {
    "referralCode": "REF308HXG",
    "hasGeneratedCode": true,
    "totalReferrals": 1,
    "successfulReferrals": 1,
    "referralHistory": [
      {
        "referredHrId": "TNM057",
        "referredPhone": "7747768907",
        "redeemedAt": "2026-02-09T12:23:22.134Z",
        "creditsAwarded": 70,
        "redemptionType": "login",
        "_id": "6989d1bae2384aff94bae729"
      }
    ]
  }
}
```
- **Parsed Data**: 
  - Calculates total credits by summing `creditsAwarded` from referral history
  - Extracts referralCode, totalReferrals, successfulReferrals
  - Returns referral history array with credits awarded per referral
- **Fallback**: Returns default values (0) on error

### 2. UI Updates (`lib/View/ReferEarn/refer_earn_screen.dart`)

#### Enhanced Stats Display
- **Generate Tab**: Shows 4 stats cards
  - Total Referrals
  - Successful Referrals
  - Available Credits (calculated from referral history)
  - Total Credits (sum of all credits awarded)

- **Redeem Tab**: Shows referral credits earned card
  - Total Credits (from referrals)
  - Successful Referrals count

#### Pull-to-Refresh Feature
- Added `RefreshIndicator` to both Generate and Redeem tabs
- Pull down to refresh stats from the server
- Works seamlessly with loading states

#### Smart Code Generation
- Checks if user already has a generated code
- If code exists, displays it instead of generating a new one
- Shows existing code on screen load if available
- Prevents duplicate code generation

#### Auto-Load Existing Code
- On screen initialization, checks if user has generated code
- Automatically displays existing code in the UI
- No need to regenerate if code already exists

#### Stats Auto-Refresh
- Stats load on screen initialization
- Stats refresh after generating a referral code
- Stats refresh after successfully redeeming a code
- Stats refresh on pull-to-refresh gesture

#### Updated Success Messages
- Redeem success shows credits earned: "You received X database credits!"
- Generate code shows info message if code already exists
- Falls back to API message if credits not specified

### 3. Response Structure Support

The API service handles the complete stats response:

```dart
{
  'referralCode': 'REF086UBY',
  'hasGeneratedCode': true,
  'totalReferrals': 2,
  'successfulReferrals': 2,
  'availableCredits': 170,
  'totalCredits': 170,
  'subscriptionStatus': 'Active',
  'expiryDate': '2026-05-10T07:15:01.629Z',
  'referralHistory': [...]
}
```

## API Endpoints Summary

| Endpoint | Method | Purpose | Auth Required |
|----------|--------|---------|---------------|
| `/api/hr/referral/generate` | POST | Generate new referral code | Yes (Cookie) |
| `/api/hr/referral/redeem` | POST | Redeem a referral code | Yes (Cookie) |
| `/api/hr/referral/stats` | GET | Get user's referral statistics | Yes (Cookie) |

## Features

### Share Functionality
- Integrated `share_plus` package for native sharing
- Share button opens native share dialog
- Pre-formatted message with referral code
- Includes app promotion text and hashtags
- Works across all platforms (Android, iOS, Web)

### Pull-to-Refresh
- Available on both Generate and Redeem tabs
- Refreshes all stats from the server
- Shows loading indicator during refresh
- Updates all UI elements with fresh data

### Smart Code Management
- Prevents duplicate code generation
- Shows existing code automatically
- Persists code across app sessions
- Syncs with backend state

### Comprehensive Stats
- Total referrals count
- Successful referrals count
- Available credits balance
- Total credits earned
- Subscription status
- Credits expiry date
- Referral history (available in data)

### Loading States
- Shows loading indicator while fetching stats
- Maintains UI responsiveness
- Graceful error handling
- Default values on error

## Testing Recommendations

1. **Generate Code**: Test code generation and verify existing code display
2. **Redeem Code**: Test with valid/invalid codes to verify error handling
3. **Stats Loading**: Verify stats load on screen open and refresh after actions
4. **Pull-to-Refresh**: Test refresh gesture on both tabs
5. **Error Cases**: Test network failures and API errors
6. **Loading States**: Verify loading indicators appear during API calls
7. **Expiry Date**: Verify date formatting displays correctly

## Future Enhancements

- Display referral history list
- Add filtering/sorting for referral history
- Add analytics tracking for referral events
- Show credits earned per referral in history
- Add deep linking for referral codes
- Add QR code generation for referral codes
