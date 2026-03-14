# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Lint / static analysis
flutter analyze

# Run tests
flutter test

# Run on device/emulator
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Architecture

### Data Flow

```
Page (UI)
  → reads from Provider (ChangeNotifier)
  → Provider calls Repository service class
  → Service class makes HTTP request (http or Dio)
  → Response parsed into Model
  → Provider calls notifyListeners()
  → Page rebuilds
```

### State Management — Providers (`lib/providers/`)

16 `ChangeNotifier` providers registered globally in `main.dart` via `MultiProvider`. Each manages one domain:

| Provider | Domain |
|----------|--------|
| `UserdataProvider` | Current user profile, likes, body stats |
| `WorkoutdataProvider` | Routine structure, exercises, sets, progressive overload |
| `HistorydataProvider` | Workout history (own, friends, all), likes, comments |
| `ExercisesdataProvider` | Exercise catalog and filtering |
| `FamousdataProvider` | Curated famous workout programs |
| `InterviewdataProvider` | Interview/blog content |
| `NotificationdataProvider` | Push notification management |
| `ThemeProvider` | Dark/light mode, font size — persisted to secure storage |
| `PrefsProvider` | User preferences |
| `BodyStater` | Bottom nav tab index |
| `LoginPageProvider` | Login/signup UI state |
| `PopProvider` | Dialog/popup state |
| `RoutineMenuStater` | Routine menu navigation |
| `RoutineTimeProvider` | Workout session timing |
| `ChartIndexProvider` | Stats chart filters |
| `StaticPageProvider` | Static page state |
| `TempImgStorage` | Temporary upload image staging |

**Provider pattern:**
```dart
class UserdataProvider extends ChangeNotifier {
  var _userdata;
  get userdata => _userdata;

  getdata(token) async {
    await UserService(token: token).loadUserdata().then((value) {
      _userdata = value;
      notifyListeners();
    });
  }
}
```

### HTTP Layer — Repository (`lib/repository/`)

Each domain has one repository file containing multiple small service classes — one class per API endpoint. Two HTTP clients are used:

- **`http` package** — Standard JSON REST calls. All authenticated calls include `Authorization: Bearer $token` header.
- **`Dio` package** — Multipart/form-data file uploads (images, videos).

**Token management:** JWT stored in `FlutterSecureStorage` under key `sdb_token`. Email stored under `sdb_email`.

**Backend URL:** Defined in `lib/src/utils/localhost_aws.dart`.

Example pattern:
```dart
class UserService {
  final String token;
  UserService({required this.token});

  Future<User> loadUserdata() async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/user/$email'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load user');
  }
}
```

### Data Models (`lib/src/model/`)

| File | Key Classes |
|------|-------------|
| `userdata.dart` | `User`, `BodyStat` |
| `workoutdata.dart` | `Routinedata`, `Routinedatas`, `Exercises`, `Sets` |
| `historydata.dart` | `SDBdataList`, `SDBdata`, `Exercises` |
| `exercisesdata.dart` | `Exercises`, `ExercisesdataList` |
| `interviewdata.dart` | Interview content model |
| `notification.dart` | Push notification payload |
| `exerciseList.dart` | Static exercise database (GIF URLs, muscles, categories) |
| `pre_exerciseList.dart` | Pre-workout/template exercises |

JSON parsing uses factory constructors. Defensive type-checking is common because some fields come as either `String` or `Object` depending on context:
```dart
var list = parsedJson['body_stats'].runtimeType == String
    ? json.decode(parsedJson['body_stats']) as List
    : parsedJson['body_stats'] as List;
```

### Navigation (`lib/navigators/`)

Per-tab nested navigators with independent route stacks. Each section (`exercise`, `profile`, `search`) has its own `Navigator` widget with route maps defined as static `String` constants.

### Pages (`lib/pages/`)

| Section | Key Files | Notes |
|---------|-----------|-------|
| `exercise/` | `exercise.dart`, `each_exercise.dart`, `each_workout.dart`, `each_plan.dart`, `exercise_done.dart`, `upload_program.dart` | Workout execution and routine management |
| `feed/` | `feed.dart`, `feed_friend.dart`, `friendHistory.dart`, `feedEdit.dart`, `photo_editer.dart` | Social history feed |
| `login/` | Login/signup screens | Multi-provider auth |
| `mystat/` | Personal stats and progress tracking | |
| `profile/` | User profile management | |
| `search/` | Exercise and user search | |
| `statistics/` | Charts and analytics | Uses Syncfusion charts |
| `app.dart` | Main shell with bottom navigation | 48KB — complex layout |

### Utilities (`lib/src/utils/`)

- `firebase_fcm.dart` — FCM token registration and message handling
- `firebaseAnalyticsService.dart` — Event tracking wrappers
- `notification.dart` — Local notification setup (`flutter_local_notifications`)
- `feedCard.dart` — Reusable feed item widget
- `imageFullViewer.dart` — Full-screen image gallery
- `hhmmss.dart` — Workout time formatting
- `alerts.dart` — Standard alert dialogs

### Authentication Flows

1. **Email/Password** → `POST /api/token` → token stored to secure storage
2. **Kakao OAuth** → `KakaoSdk` → `POST /api/tokenkakao/{email}`
3. **Google** → `google_sign_in` package
4. **Apple** → `sign_in_with_apple` package
5. **Firebase Auth** — Additional auth layer for Firebase-specific features

### Firebase Integration

- **Messaging (FCM):** Background handler registered in `main()`. On notification tap or receipt, `HistorydataProvider` reloads data.
- **Analytics:** `FirebaseAnalyticsObserver` attached to `MaterialApp` navigator.
- **Auth:** Used alongside JWT for certain auth flows.

### Theme

`ThemeProvider` stores mode (`sdb_theme`) and font scale in `FlutterSecureStorage`. Primary color: `#7a28cb` (purple). Dark background: `#101012`. Font: Noto Sans KR.

### Workout Data Structure

The most complex data shape is the workout routine, which nests 4 levels deep:

```
Workout
  └── Routinedata (the overall routine)
        └── Routinedatas[] (each routine/day)
              └── Exercises[] (each exercise)
                    └── Sets[] (weight, reps, rest, isChecked)
```

Progressive overload plans and program progression are tracked at the `Exercises` level.
