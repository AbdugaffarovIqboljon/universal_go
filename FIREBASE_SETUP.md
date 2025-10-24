# Firebase Setup Guide

## Issue
Your app is failing to initialize Firebase because the configuration files are missing.

## Solution

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Enable the services you need (Authentication, Firestore, Storage, etc.)

### 2. Add iOS Configuration
1. In Firebase Console, go to Project Settings
2. Select "iOS" and add your iOS app
3. Download `GoogleService-Info.plist`
4. Add the file to `ios/Runner/` directory in your Flutter project
5. Make sure it's added to the Xcode project (drag and drop into Xcode)

### 3. Add Android Configuration
1. In Firebase Console, go to Project Settings
2. Select "Android" and add your Android app
3. Download `google-services.json`
4. Add the file to `android/app/` directory in your Flutter project

### 4. Update iOS Podfile (if needed)
Add to `ios/Podfile`:
```ruby
# Add this line at the top
require_relative '../ios/Flutter/Flutter-Debug.xcconfig'

# Add this in the target section
target 'Runner' do
  # ... existing code ...
  
  # Add Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
end
```

### 5. Run Pod Install
```bash
cd ios && pod install && cd ..
```

### 6. Update Android Gradle Files
In `android/app/build.gradle.kts`, add:
```kotlin
apply plugin: 'com.google.gms.google-services'
```

In `android/build.gradle.kts`, add:
```kotlin
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

## Current Status
The app will now run without crashing, but Firebase features won't work until you add the configuration files.

## Next Steps
1. Set up Firebase project
2. Add configuration files
3. Remove the try-catch block from main.dart
4. Test Firebase features
