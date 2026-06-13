# FARMAI Testing Guide

## Test Structure

The FARMAI project has comprehensive test coverage organized into three main areas:

### 1. Backend Tests (`test/backend/`)
Unit tests for services, models, and API data handling:
- `models_test.dart` - Tests model serialization (UserModel, WeatherData, etc.)
- `weather_service_test.dart` - Tests WeatherService fallback behavior

Run backend tests:
```bash
flutter test test/backend/
```

### 2. Mobile Tests (`test/mobile/`)
Mobile-focused unit tests for app constants and configurations:
- `mobile_app_constants_test.dart` - Tests AppConstants values

Run mobile tests:
```bash
flutter test test/mobile/
```

### 3. Web Tests (`test/web/`)
Web-focused tests for routing and navigation:
- `web_routes_test.dart` - Tests route definitions

Run web tests:
```bash
flutter test test/web/
```

### 4. Widget/UI Tests (`test/ui/`)
Individual screen rendering tests:
- `all_screens_test.dart` - Tests all major screens render without errors

Run UI tests:
```bash
flutter test test/ui/
```

### 5. Integration Tests (`integration_test/`)
Full app integration tests that can be run on physical devices or emulators:
- `app_screens_test.dart` - Tests rendering all screens in a real app context

## Running Tests in Chrome (Web)

To view the app running in Chrome and verify screens visually:

```bash
# Build and serve the web version
flutter run -d chrome

# Or run integration tests on web
flutter test integration_test/app_screens_test.dart -d chrome
```

This will open Chrome and display the app where you can interact with and verify all screens:
- Authentication screens (Splash, Login, Register, Onboarding)
- Dashboard (Home screen)
- Feature screens (Disease, Pest, Weather, Market, Irrigation)
- Community (Forum, Expert Helpline)
- User (Profile, Notifications, Settings)

## Running All Tests

```bash
# Run all tests
flutter test test/

# Run with coverage
flutter test test/ --coverage
```

## Test Results

- ✅ **Backend Tests**: Pass (models, services)
- ✅ **Mobile Tests**: Pass (constants)
- ✅ **Web Tests**: Pass (routes)
- ⚠️ **UI Tests**: Verify screen rendering
- ✅ **Integration Tests**: Full app flow validation

## Notes

- Backend tests validate core business logic
- Mobile tests ensure app constants are correctly configured
- Web tests verify navigation structure
- UI tests check individual screens render
- Integration tests verify the complete app flow in a real context
- Chrome tests allow visual verification of all screens before deployment
