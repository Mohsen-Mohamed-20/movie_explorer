## Movie Explorer

### Description

Movie Explorer is a Flutter mobile app for discovering movies. It loads real movie
data from the TMDB REST API, lets you search for movies, view their details and
save your favorites on the phone. It has a dark theme and a light theme.

### Features

- Movie browsing (popular movies, genre filter)
- Movie search (with input validation)
- Movie details
- Favorites (saved locally)
- REST API (TMDB)
- Cubit state management
- SharedPreferences
- Dark Mode / Light Mode
- Loading / Error / Empty states

### Technologies

- Flutter
- Dart
- REST API (TMDB)
- flutter_bloc (Cubit)
- http
- shared_preferences

### Screens

Splash -> Promotional -> Home -> Search / Details / Favorites

Add screenshots from Figma / the running app here:

| Splash | Promotional | Home |
|--------|-------------|------|
|        |             |      |

| Search | Details | Favorites |
|--------|---------|-----------|
|        |         |           |

### Installation

1. Create a free account at https://www.themoviedb.org and request an API key
   (Settings -> API). Copy the **API Key (v3 auth)**.

2. Get the packages:

```
flutter pub get
```

3. Run the app and pass your key (it is NOT stored in the code, so it never
   goes to GitHub):

```
flutter run --dart-define=TMDB_API_KEY=YOUR_KEY_HERE
```

In VS Code you can put it in `.vscode/launch.json` (this folder is in
`.gitignore`):

```json
{
  "configurations": [
    {
      "name": "Movie Explorer",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=TMDB_API_KEY=YOUR_KEY_HERE"]
    }
  ]
}
```

In Android Studio: Run -> Edit Configurations -> "Additional run args".

**Android release builds:** add this line inside `<manifest>` in
`android/app/src/main/AndroidManifest.xml` (debug builds already have it):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Project Structure

```
lib/
├── main.dart
├── models/movie_model.dart
├── services/
│   ├── movie_api_service.dart
│   └── local_storage_service.dart
├── cubit/
│   ├── movie_cubit.dart
│   ├── movie_state.dart
│   └── theme_cubit.dart
├── screens/   (splash, promotional, home, search, movie details, favorites)
├── widgets/   (reusable UI components)
└── theme/app_theme.dart
```

### Team Members

- Mohsen Mohamed 
- Jana Ahmed
