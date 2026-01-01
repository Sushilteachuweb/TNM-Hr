# Job Posting Flow - Restructured

## Overview
The job posting flow has been restructured from a single-page approach to a 2-page flow that matches the website's structure while keeping it mobile-friendly.

## New Flow Structure

### Page 1: Job Basic Details & Requirements (`JobBasicDetailsPage.dart`)
**Sections:**
1. **Basic Details**
   - Company Name *
   - Job Designation/Title *
   - Job Category/Role * (dropdown)
   - Job Type * (radio: Full Time, Part Time, Both)

2. **Salary Details**
   - Salary Type * (radio: Fixed Only, Fixed + Incentive, Incentive Only)
   - Salary Range * (min/max fields)

3. **Candidate Requirements**
   - Minimum Education * (dropdown)
   - English Level * (multi-select chips)
   - Total Experience * (radio: Any, Experienced Only, Fresher Only)
   - Experience Range (shown only if "Experienced Only" selected)
   - Job Description

4. **Preferred Requirements**
   - Age Range (min/max fields)
   - Preferred Location
   - Gender (dropdown: Male only, Female only, Both)

### Page 2: Job Location & Employment Details (`JobLocationEmploymentPage.dart`)
**Sections:**
1. **Interview Method and Communication Preferences**
   - Walk-in Interview (Yes/No radio)
   - Total Number of Openings
   - Communication Preferences (radio options)

2. **Job Location & Work Type**
   - Work Location Type * (dropdown: Office, Work from Home, Field Job)
   - Office Address *
   - Additional Perks (multi-select chips)

3. **Employment Info**
   - Documents Required (multi-select chips)
   - Working Days (dropdown)
   - Job Timing

## Data Structure

### JobFormProvider Updates
The provider has been completely restructured to match the website fields:

**Page 1 Fields:**
- `companyName`, `jobTitle`, `jobCategory`, `jobType`
- `salaryType`, `minSalary`, `maxSalary`
- `minimumEducation`, `englishLevel[]`, `totalExperience`
- `minExperience`, `maxExperience`, `jobDescription`
- `minAge`, `maxAge`, `preferredLocation`, `gender`

**Page 2 Fields:**
- `isWalkInInterview`, `totalOpenings`, `communicationPreference`
- `workLocationType`, `officeAddress`, `additionalPerks[]`
- `documentsRequired[]`, `workingDays`, `jobTiming`

## Key Features

### Website Alignment
- **Exact field matching**: All fields now match the website screenshots
- **Fixed values**: Gender options are "Male only", "Female only", "Both"
- **Arrays**: Skills, requirements, benefits use array structures
- **Proper validation**: Required fields marked with *

### Mobile UX
- **2-page flow**: Logical grouping of related fields
- **Progress indicators**: Clear step indication (Step 1 of 2, Step 2 of 2)
- **Validation**: Page-level validation before proceeding
- **Navigation**: Previous/Next buttons with proper state management

### Data Consistency
- **API compatibility**: Data structure matches existing API expectations
- **Type conversion**: Proper conversion between UI and API formats
- **Default values**: Sensible defaults for all fields

## Navigation Flow
```
HomeScreen 
  → JobBasicDetailsPage (Page 1)
    → JobLocationEmploymentPage (Page 2)
      → Subscription (Payment)
        → BottomNavBar (Success)
```

## Files Structure
```
lib/View/Home/CreateNewJob/
├── JobBasicDetailsPage.dart          # Page 1 - New
├── JobLocationEmploymentPage.dart    # Page 2 - New
├── README.md                         # This documentation
├── CreateNewJob.dart                 # Old file - can be removed
├── CustomTextField.dart              # Old component - can be removed
├── GenderSelector.dart               # Old component - can be removed
├── JobLocationType.dart              # Old component - can be removed
├── JobType.dart                      # Old component - can be removed
└── MinimumQualification.dart         # Old component - can be removed
```

## Provider Updates
- `lib/Provider/job_form_provider.dart` - Completely restructured
- All setter methods updated for new field structure
- Validation methods added for each page
- API data conversion methods updated

## Integration Points
- **HomeScreen**: Updated to navigate to `JobBasicDetailsPage`
- **Subscription**: Works with new data structure
- **JobProvider**: Compatible with new field structure
- **API Service**: No changes needed - data conversion handled in provider