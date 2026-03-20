/// Centralised helper for turning raw API error messages (strings or arrays)
/// into short, user-friendly sentences shown in SnackBars.
class JobErrorHelper {
  /// Converts a raw API message (String or List) to a single readable string.
  static String parse(dynamic raw) {
    if (raw == null) return 'Something went wrong. Please try again.';

    // API sometimes returns a List of validation messages
    if (raw is List) {
      final messages = raw.map((e) => _friendly(e.toString())).toList();
      return messages.join('\n');
    }

    final str = raw.toString().trim();
    if (str.isEmpty) return 'Something went wrong. Please try again.';

    // Strip surrounding brackets from stringified arrays like ["msg1", "msg2"]
    if (str.startsWith('[') && str.endsWith(']')) {
      final inner = str.substring(1, str.length - 1);
      final parts = inner
          .split(',')
          .map((s) => _friendly(s.trim().replaceAll('"', '')))
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts.join('\n');
    }

    return _friendly(str);
  }

  /// Maps a single raw message to a human-readable sentence.
  static String _friendly(String raw) {
    final lower = raw.toLowerCase();

    // Field-specific messages
    if (lower.contains('title') && lower.contains('empty')) {
      return 'Job title is required.';
    }
    if (lower.contains('title')) return 'Job title is invalid.';

    if (lower.contains('companyname') || lower.contains('company name')) {
      return 'Company name is required.';
    }
    if (lower.contains('jobcategory') || lower.contains('job category')) {
      return 'Please select a job category.';
    }
    if (lower.contains('jobtype') || lower.contains('job type')) {
      return 'Please select a valid job type.';
    }
    if (lower.contains('salarytype') || lower.contains('salary type')) {
      return 'Please select a valid salary type.';
    }
    if (lower.contains('salaryrange') || lower.contains('salary range')) {
      return 'Please enter a valid salary range.';
    }
    if (lower.contains('minimumeducation') || lower.contains('minimum education')) {
      return 'Please select the minimum education level.';
    }
    if (lower.contains('englishlevel') || lower.contains('english level')) {
      return 'Please select the required English level.';
    }
    if (lower.contains('totalexperience') || lower.contains('experience')) {
      return 'Please select the experience requirement.';
    }
    if (lower.contains('jobdescription') || lower.contains('job description')) {
      return 'Job description is required.';
    }
    if (lower.contains('preferredlocation') || lower.contains('joblocation') ||
        lower.contains('location')) {
      return 'Please enter the job location.';
    }
    if (lower.contains('officeaddress') || lower.contains('office address')) {
      return 'Office address is required.';
    }
    if (lower.contains('worklocation') || lower.contains('work location')) {
      return 'Please select a work location type.';
    }
    if (lower.contains('documents must be an array') ||
        lower.contains('documents')) {
      return 'Please select at least one required document.';
    }
    if (lower.contains('communicationpreference') ||
        lower.contains('communication')) {
      return 'Please select a communication preference.';
    }
    if (lower.contains('workingdays') || lower.contains('working days')) {
      return 'Please select working days.';
    }
    if (lower.contains('openings')) {
      return 'Please enter the number of openings.';
    }
    if (lower.contains('gender')) return 'Please select a gender preference.';
    if (lower.contains('hrphone') || lower.contains('phone')) {
      return 'Phone number is missing. Please update your profile.';
    }
    if (lower.contains('plantype') || lower.contains('plan')) {
      return 'Invalid plan type. Please try again.';
    }

    // Auth / network errors
    if (lower.contains('unauthorized') || lower.contains('401')) {
      return 'Your session has expired. Please log in again.';
    }
    if (lower.contains('not found') || lower.contains('404')) {
      return 'Job not found. It may have been deleted.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'Server is taking too long. Please try again.';
    }
    if (lower.contains('network') || lower.contains('socket') ||
        lower.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }
    if (lower.contains('server') || lower.contains('500')) {
      return 'Server error. Please try again in a moment.';
    }

    // Fallback: capitalise first letter of the raw message
    if (raw.isEmpty) return 'Something went wrong. Please try again.';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  /// Returns a specific message for each missing field when page-1 validation fails.
  static String page1ValidationMessage({
    required String companyName,
    required String jobTitle,
    required String jobCategory,
    required String jobType,
    required String salaryType,
    required String minSalary,
    required String maxSalary,
    required String minimumEducation,
    required String preferredLocation,
    required String jobDescription,
  }) {
    if (companyName.isEmpty) return 'Company name is required.';
    if (jobTitle.isEmpty) return 'Job title is required.';
    if (jobCategory.isEmpty) return 'Please select a job category.';
    if (jobType.isEmpty) return 'Please select a job type.';
    if (salaryType != 'Incentive Only' &&
        (minSalary.isEmpty || maxSalary.isEmpty)) {
      return 'Please enter the salary range.';
    }
    if (minimumEducation.isEmpty) return 'Please select the minimum education.';
    if (preferredLocation.isEmpty) return 'Please enter the preferred job location.';
    if (jobDescription.isEmpty) return 'Job description is required.';
    return 'Please fill all required fields.';
  }

  /// Returns a specific message for each missing field when page-2 validation fails.
  static String page2ValidationMessage({
    required String workLocationType,
    required String officeAddress,
    required int totalOpenings,
  }) {
    final validWorkLocations = ['Work From Home', 'Work From Office', 'Field Job'];
    if (workLocationType.isEmpty || !validWorkLocations.contains(workLocationType)) {
      return 'Please select a work location type.';
    }
    if (officeAddress.isEmpty) return 'Office address is required.';
    if (totalOpenings <= 0) return 'Please enter the number of openings (minimum 1).';
    return 'Please fill all required fields.';
  }
}
