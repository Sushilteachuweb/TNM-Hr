# TNM Recruiter - HR Portal App

A comprehensive Flutter-based HR recruitment application designed for managing job postings, candidate applications, and recruitment workflows.

## 📱 About

TNM Recruiter is a mobile HR portal application that enables HR professionals to efficiently manage their recruitment processes. The app provides features for job posting, candidate management, payment processing, and profile management.

## ✨ Features

- **Authentication & Security**
  - Secure login with OTP verification
  - Session management with persistent storage
  - Cookie-based authentication

- **Job Management**
  - Create and manage job postings
  - Job categorization and filtering
  - Real-time job status updates

- **Candidate Management**
  - View and manage job applications
  - Applicant profile viewing
  - Application status tracking

- **Payment & Plans**
  - Integrated Razorpay payment gateway
  - Subscription plan management
  - Billing history and payment tracking
  - Credit management system

- **Profile Management**
  - HR profile creation and updates
  - Company information management
  - Profile completion tracking

- **Additional Features**
  - Offline connectivity handling
  - Image picker for profile photos
  - Animated UI components with Lottie
  - URL launcher for external links
  - Internationalization support

## 🏗️ Architecture

The app follows a clean architecture pattern with:

```
lib/
├── core/                 # App-wide constants and styles
├── models/              # Data models
├── Provider/            # State management (Provider pattern)
├── services/            # API services and business logic
├── View/                # UI screens and pages
├── Widgets/             # Reusable UI components
├── utils/               # Utility functions
└── SplashScreen/        # App initialization screens
```

## 🛠️ Tech Stack

- **Framework:** Flutter 3.8.1+
- **State Management:** Provider
- **HTTP Client:** http package
- **Local Storage:** SharedPreferences
- **Payment Gateway:** Razorpay Flutter
- **UI Components:** Material Design
- **Animations:** Lottie
- **Image Handling:** Image Picker

## 📦 Dependencies

### Core Dependencies
- `provider: ^6.0.5` - State management
- `http: ^1.5.0` - HTTP requests
- `shared_preferences: ^2.2.2` - Local storage

### UI & UX
- `lottie: ^3.1.0` - Animations
- `image_picker: ^1.1.2` - Image selection
- `pinput: ^6.0.1` - OTP input field

### Integrations
- `razorpay_flutter: ^1.3.3` - Payment processing
- `url_launcher: ^6.2.4` - External URL handling
- `connectivity_plus: ^7.0.0` - Network connectivity
- `intl: ^0.19.0` - Internationalization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd TNM-Hr
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration
Update the API endpoints in `lib/services/api_routes.dart` to match your backend configuration.

### Razorpay Setup
Configure your Razorpay credentials in the payment service files.

### App Icons
Replace the icon image at `assets/images/icon image.png` with your app icon and run:
```bash
flutter pub run flutter_launcher_icons:main
```

## 📱 Build & Deployment

### Development Build
```bash
flutter run --debug
```

### Release Build
```bash
# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# Android APK
flutter build apk --release --split-per-abi

# iOS
flutter build ios --release
```

### Google Play Store Deployment
The app is configured for Play Store deployment with:
- Signed release builds
- Proper permissions
- Optimized bundle size
- Security configurations

See `PLAY_STORE_DEPLOYMENT_GUIDE.md` for detailed deployment instructions.

## 📂 Project Structure

### Key Directories

- **`lib/View/`** - All UI screens organized by feature
- **`lib/Provider/`** - State management providers
- **`lib/services/`** - API services and business logic
- **`lib/models/`** - Data models and DTOs
- **`lib/Widgets/`** - Reusable UI components
- **`lib/core/`** - App constants, colors, and text styles

### Key Files

- **`lib/main.dart`** - App entry point
- **`lib/services/auth_service.dart`** - Authentication logic
- **`lib/services/job_api_service.dart`** - Job-related API calls
- **`lib/Provider/LoginProvider.dart`** - Login state management

## 🔐 Security Features

- Secure keystore for release builds
- Network security configuration
- Session management with secure storage
- API authentication with cookies
- Input validation and sanitization

## 📊 App Information

- **Package Name:** `com.techuweb.hrportal`
- **App Name:** TNM Recruiter
- **Version:** 1.0.0+2
- **Min SDK:** Android 21 (Android 5.0)
- **Target SDK:** Latest Android version

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software developed by Techuweb.

## 📞 Support

For support and queries, contact the development team at Techuweb.

---

**Built with ❤️ using Flutter**
