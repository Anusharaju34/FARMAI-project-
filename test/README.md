# Testing structure for FARMAI

This repository uses Flutter test files organized into separate domains:

- `test/mobile/` - mobile-focused test cases for app constants and mobile UI logic.
- `test/web/` - web-focused test coverage for route definitions and navigation constants.
- `test/backend/` - backend-related unit tests for services, models, and API data handling.

Run tests with:

```bash
flutter test
```

Or run a specific folder:

```bash
flutter test test/backend
```

---

## Chrome-visible integration tests

Integration tests are available in `integration_test/`.

Run the full browser-visible suite with:

```bash
flutter test integration_test/app_screens_test.dart -d chrome
```

If you want to watch the screens load in Chrome, use this command and keep the browser window open while the test runs.
