# Google Maps API Integration Documentation

## Overview
This document details how Google Maps Places API is integrated into the HR Portal Flutter application for location autocomplete functionality in both the Profile and Job Posting forms.

---

## Package Used
**Package:** `google_places_flutter: ^2.0.9`

**Package Link:** https://pub.dev/packages/google_places_flutter

**Purpose:** Provides Google Places Autocomplete functionality with location search, predictions, and coordinate extraction.

---

## API Configuration

### API Key
**Key:** `AIzaSyAAxbBbwAa5E2Zr8PfLBVQeGNaJSYz6154`

**Location:** Hardcoded in multiple files (see Implementation Locations below)

**Restrictions:** 
- Country restricted to India (`countries: ["in"]`)
- Debounce time: 600ms to reduce API calls

### Required Permissions
**Android Manifest:** `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Implementation Locations

### 1. Custom Reusable Widget
**File:** `lib/Widgets/google_places_input.dart`

**Purpose:** A reusable widget that encapsulates Google Places Autocomplete functionality with consistent styling.

**Key Features:**
- Customizable label, hint, and icon
- Built-in validation support
- Enable/disable state
- Focus node management
- Clear button functionality
- Consistent UI styling with app theme

**Usage Example:**
```dart
GooglePlacesInput(
  controller: _locationController,
  label: "Location",
  hint: "Search for your location",
  icon: Icons.location_on_outlined,
  onPlaceSelected: (Prediction prediction) {
    // Handle place selection
  },
  validator: (value) => value?.isEmpty ?? true ? "Required" : null,
  enabled: true,
  focusNode: _locationFocusNode,
)
```

---

### 2. Profile Form Integration
**File:** `lib/View/Profiles/EditProfileScreen.dart`

**Location in Code:** Lines 562-643

**Field:** User Location

**Implementation Details:**
- **Controller:** `_locationController` (TextEditingController)
- **Focus Node:** `_locationFocusNode` (FocusNode)
- **Widget Key:** `_locationKey` (GlobalKey) - Used for widget identification
- **Coordinates Required:** `isLatLngRequired: false` - Only address needed
- **Callback:** `getPlaceDetailWithLatLng` - Sets location text when place is selected

**Data Flow:**
1. User types in location field
2. Google Places API returns suggestions (debounced by 600ms)
3. User selects a location from dropdown
4. `itemClick` callback sets the full address in the controller
5. `getPlaceDetailWithLatLng` callback logs the selection
6. Focus is removed to dismiss keyboard

**Code Snippet:**
```dart
GooglePlaceAutoCompleteTextField(
  textEditingController: _locationController,
  focusNode: _locationFocusNode,
  googleAPIKey: "AIzaSyAAxbBbwAa5E2Zr8PfLBVQeGNaJSYz6154",
  countries: const ["in"],
  isLatLngRequired: false,
  getPlaceDetailWithLatLng: (Prediction prediction) {
    _locationController.text = prediction.description ?? "";
    print("📍 Profile Location selected: ${prediction.description}");
  },
  itemClick: (Prediction prediction) {
    _locationController.text = prediction.description ?? "";
    _locationController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
    _locationFocusNode.unfocus();
  },
  // ... styling and UI configuration
)
```

---

### 3. Job Posting Form - Preferred Location
**File:** `lib/View/Home/CreateNewJob/JobBasicDetailsPage.dart`

**Location in Code:** Lines 635-720

**Field:** "Prefer applications from" (Preferred Location)

**Implementation Details:**
- **Controller:** `_preferredLocationController` (TextEditingController)
- **Focus Node:** `_preferredLocationFocusNode` (FocusNode)
- **Widget Key:** `_preferredLocationKey` (GlobalKey)
- **Coordinates Required:** `isLatLngRequired: true` - Coordinates are extracted and stored
- **Provider Integration:** Uses `JobFormProvider` to store location data

**Data Extraction:**
The implementation parses the selected address to extract:
1. **Full Address:** Complete location string
2. **City:** Extracted from address parts
3. **State:** Extracted from address parts
4. **Coordinates:** Latitude and longitude (if available)

**Parsing Logic:**
```dart
String fullAddress = prediction.description ?? "";
List<String> parts = fullAddress.split(',').map((e) => e.trim()).toList();

String city = "";
String state = "";

if (parts.length >= 3) {
  // Format: "City, State, Country"
  city = parts[0];
  state = parts[1];
} else if (parts.length == 2) {
  city = parts[0];
  state = parts[1];
} else if (parts.length == 1) {
  city = parts[0];
}
```

**Provider Methods Called:**
```dart
formProvider.setPreferredCity(city);
formProvider.setPreferredState(state);
formProvider.setPreferredLocation(fullAddress);
formProvider.setPreferredCoordinates(lat, lng);
```

**Code Snippet:**
```dart
GooglePlaceAutoCompleteTextField(
  textEditingController: _preferredLocationController,
  focusNode: _preferredLocationFocusNode,
  googleAPIKey: "AIzaSyAAxbBbwAa5E2Zr8PfLBVQeGNaJSYz6154",
  countries: const ["in"],
  isLatLngRequired: true,
  getPlaceDetailWithLatLng: (Prediction prediction) {
    // Parse address and extract city, state
    // Store in provider
    formProvider.setPreferredCity(city);
    formProvider.setPreferredState(state);
    formProvider.setPreferredLocation(fullAddress);
    
    // Store coordinates
    if (prediction.lat != null && prediction.lng != null) {
      double lat = double.tryParse(prediction.lat ?? "0") ?? 0.0;
      double lng = double.tryParse(prediction.lng ?? "0") ?? 0.0;
      formProvider.setPreferredCoordinates(lat, lng);
    }
  },
  // ... rest of configuration
)
```

---

### 4. Job Posting Form - Office Address
**File:** `lib/View/Home/CreateNewJob/JobLocationEmploymentPage.dart`

**Location in Code:** Lines 328-420

**Field:** "Office Address"

**Implementation Details:**
- **Controller:** `_officeAddressController` (TextEditingController)
- **Focus Node:** `_officeAddressFocusNode` (FocusNode)
- **Widget Key:** `_officeAddressKey` (GlobalKey)
- **Coordinates Required:** `isLatLngRequired: true` - Full address with coordinates
- **Provider Integration:** Uses `JobFormProvider.setOfficeAddress()`

**Data Flow:**
1. User types office address
2. Google Places API returns business/address suggestions
3. User selects from dropdown
4. Full address is stored in provider via `setOfficeAddress()`
5. Coordinates are available through the prediction object

**Code Snippet:**
```dart
GooglePlaceAutoCompleteTextField(
  textEditingController: _officeAddressController,
  focusNode: _officeAddressFocusNode,
  googleAPIKey: "AIzaSyAAxbBbwAa5E2Zr8PfLBVQeGNaJSYz6154",
  countries: const ["in"],
  isLatLngRequired: true,
  getPlaceDetailWithLatLng: (Prediction prediction) {
    String fullAddress = prediction.description ?? "";
    formProvider.setOfficeAddress(fullAddress);
    print("🏢 Office address selected: $fullAddress");
  },
  itemClick: (Prediction prediction) {
    _officeAddressController.text = prediction.description ?? "";
    _officeAddressController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description?.length ?? 0),
    );
    _officeAddressFocusNode.unfocus();
  },
  // ... styling configuration
)
```

---

## Provider Integration

### JobFormProvider
**File:** `lib/Provider/job_form_provider.dart`

**Relevant Properties:**
```dart
String preferredLocation = "";
String preferredCity = "";
String preferredState = "";
List<double> preferredCoordinates = [0.0, 0.0];
String officeAddress = "";
```

**Relevant Methods:**
```dart
void setPreferredLocation(String value) {
  preferredLocation = value;
  // Don't overwrite city and state if already set from Google Places
  notifyListeners();
}

void setPreferredCity(String value) {
  preferredCity = value;
  notifyListeners();
}

void setPreferredState(String value) {
  preferredState = value;
  notifyListeners();
}

void setPreferredCoordinates(double lat, double lng) {
  preferredCoordinates = [lat, lng];
  print("🌍 Coordinates stored in provider: [$lat, $lng]");
  notifyListeners();
}

void setOfficeAddress(String value) {
  officeAddress = value;
  notifyListeners();
}
```

**Usage in Job Submission:**
The coordinates are used when submitting job data to the backend:
```dart
List<double> finalCoordinates = coordinates ?? preferredCoordinates;
// If still [0.0, 0.0], try to get from IndianStatesAndCities
```

---

## Common Configuration

### Shared Settings Across All Implementations

**1. Debounce Time:**
```dart
debounceTime: 600  // 600ms delay before API call
```
Reduces API calls by waiting for user to stop typing.

**2. Country Restriction:**
```dart
countries: const ["in"]  // Restrict to India only
```
Limits search results to Indian locations.

**3. UI Styling:**
- Border radius: 12px
- Border color: `AppColors.border`
- Background: White
- Icon color: `AppColors.primary`
- Consistent padding and spacing

**4. Dropdown Item Builder:**
```dart
itemBuilder: (context, index, Prediction prediction) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Icon(Icons.location_on, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            prediction.description ?? "",
            style: AppTextStyles.body2,
          ),
        ),
      ],
    ),
  );
}
```

**5. Clear Button:**
```dart
isCrossBtnShown: true  // Shows X button to clear input
```

---

## Key Features

### 1. Autocomplete Suggestions
- Real-time location suggestions as user types
- Debounced to reduce API calls
- Dropdown with location icon and formatted text

### 2. Address Parsing
- Extracts city and state from full address
- Handles different address formats (1, 2, or 3+ parts)
- Stores structured data in provider

### 3. Coordinate Extraction
- Latitude and longitude extracted when `isLatLngRequired: true`
- Stored as `List<double>` in provider
- Used for backend job submission

### 4. Focus Management
- FocusNode used for keyboard control
- Auto-unfocus after selection to dismiss keyboard
- Prevents input issues after selection

### 5. Text Selection
- Cursor positioned at end of text after selection
- Prevents accidental text editing
- Smooth user experience

---

## API Response Structure

### Prediction Object
```dart
class Prediction {
  String? description;  // Full address string
  String? placeId;      // Google Place ID
  String? lat;          // Latitude (string)
  String? lng;          // Longitude (string)
  // ... other properties
}
```

### Callbacks

**1. getPlaceDetailWithLatLng:**
- Called when place is selected
- Provides full prediction object with coordinates
- Used for data extraction and storage

**2. itemClick:**
- Called when user clicks a suggestion
- Used for UI updates (setting text, cursor position)
- Handles focus management

---

## Best Practices Implemented

1. **Debouncing:** 600ms delay reduces unnecessary API calls
2. **Country Restriction:** Limits results to relevant locations (India)
3. **Focus Management:** Proper keyboard dismissal after selection
4. **Error Handling:** Null-safe operations with `??` operator
5. **Logging:** Debug prints for tracking selections
6. **Reusable Widget:** `GooglePlacesInput` for consistent implementation
7. **Provider Pattern:** Centralized state management for form data
8. **Coordinate Storage:** Structured data for backend integration

---

## Potential Improvements

1. **API Key Security:** Move API key to environment variables or secure storage
2. **Error Handling:** Add try-catch blocks for API failures
3. **Loading States:** Show loading indicator during API calls
4. **Offline Support:** Cache recent searches
5. **Custom Styling:** Make widget more themeable
6. **Validation:** Add location format validation
7. **Multiple Countries:** Make country restriction configurable

---

## Testing Checklist

- [ ] Location autocomplete works in Profile form
- [ ] Preferred location works in Job Posting form
- [ ] Office address works in Job Posting form
- [ ] Coordinates are correctly extracted and stored
- [ ] City and state parsing works for different formats
- [ ] Keyboard dismisses after selection
- [ ] Clear button works correctly
- [ ] Debouncing reduces API calls
- [ ] Only Indian locations are shown
- [ ] Provider updates correctly

---

## Dependencies

### pubspec.yaml
```yaml
dependencies:
  google_places_flutter: ^2.0.9
```

### Android Permissions
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Summary

The Google Maps Places API is integrated in three key locations:
1. **Profile Form** - User location (address only)
2. **Job Posting Form** - Preferred location (with coordinates and parsing)
3. **Job Posting Form** - Office address (with coordinates)

All implementations use the `google_places_flutter` package with consistent configuration, styling, and user experience. The integration includes address parsing, coordinate extraction, and proper state management through the Provider pattern.
