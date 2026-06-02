# KostMap — Setup Guide

## 1. Get a Google Maps API Key

1. Go to https://console.cloud.google.com/
2. Create or select a project
3. Enable **Maps SDK for Android** and **Maps SDK for iOS**
4. Create an API key under **Credentials**

## 2. Insert the API Key

**Android** — open `android/app/src/main/AndroidManifest.xml` and replace:
```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY"
```

**iOS** — open `ios/Runner/AppDelegate.swift` and replace:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

## 3. Run the App

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
  main.dart                    # App entry point & MaterialApp
  theme/app_theme.dart         # AppColors + ThemeData (DM Sans, #724A24)
  models/kost_model.dart       # Kost data class
  data/kost_data.dart          # 5 hardcoded kosts around Sidoarjo
  screens/
    main_navigator.dart        # Bottom nav (Beranda / Peta / Favorit / Profil)
    home_screen.dart           # Search + filter chips + kost list
    detail_screen.dart         # Google Maps + kost details + Petunjuk Arah
    placeholder_screen.dart    # Placeholder for Map/Favorite/Profile tabs
  widgets/
    kost_card.dart             # Card with image placeholder, name, price, distance
    category_badge.dart        # Putra / Putri / Campur color badge
```

## Dependencies (pubspec.yaml)

| Package               | Purpose                         |
|-----------------------|---------------------------------|
| `google_fonts`        | DM Sans font                    |
| `google_maps_flutter` | Embedded map in detail screen   |
| `url_launcher`        | Open Google Maps for directions |
