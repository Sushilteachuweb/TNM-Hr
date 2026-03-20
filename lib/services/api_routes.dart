class ApiConfig {
  // Base URL
  static const String baseUrl = "https://api.thenaukrimitra.com/api/hr";

  // Authentication endpoints
  static const String sendOtp = "$baseUrl/send-otp";
  static const String verifyOtp = "$baseUrl/verify-otp";
  static const String resendOtp = "$baseUrl/resend-otp";
  static const String signup = "$baseUrl/signup";
  static const String logout = "$baseUrl/logout";

  // HR Profile endpoints
  static const String updateHrProfile = "$baseUrl/update-hr";
  static String getHrProfile(String hrId) => "$baseUrl/get-users?hrId=$hrId";

  // Job Management endpoints
  static const String createJob = "https://api.thenaukrimitra.com/api/jobs/hr/create";
  static String getDraftJobs(String hrId) => "$baseUrl/drafts?hrId=$hrId";
  static String publishJob(String jobId) => "https://api.thenaukrimitra.com/api/jobs/$jobId/publish";
  static String getHrJobs(String hrId) => "$baseUrl/jobs?hrId=$hrId";
  static String updateJob(String jobId) => "$baseUrl/update-job?jobId=$jobId";
  static String deleteJob(String jobId) => "$baseUrl/delete-job?jobId=$jobId";
  
  // Job Category endpoints
  static const String getAllJobCategories = "https://api.thenaukrimitra.com/api/job-cate/all-cate";
  static String getAppliedUsers(String jobId) =>
      "$baseUrl/applied-users?jobId=$jobId";

  // User Management endpoints
  static const String getUsers = "$baseUrl/users";

  // Job Plans endpoints
  static const String fetchPlans = "https://api.thenaukrimitra.com/api/job-plan/fetch";
  static const String buyPlan = "https://api.thenaukrimitra.com/api/payment/create-order";
  
  // Payment Verification endpoints
  static const String verifyPayment = "https://api.thenaukrimitra.com/api/payment/verify";
  
  // Active Plan endpoints
  static String activePlan(String hrId) => "$baseUrl/active-plan/$hrId";
  
  // Payment History endpoints
  static String paymentHistory(String mobileNumber) => "https://api.thenaukrimitra.com/api/payment/history/$mobileNumber";
  
  // Payment Details endpoints
  static String paymentDetails(String orderId) => "https://api.thenaukrimitra.com/api/payment/details/$orderId";

  // Invoice Download endpoint
  static String downloadInvoice(String paymentId) => "https://api.thenaukrimitra.com/api/payment/download-invoice/$paymentId";

  // Checkout Summary endpoint
  static String checkoutSummary(String planId) => "https://api.thenaukrimitra.com/api/payment/checkout-summary/$planId";
}
