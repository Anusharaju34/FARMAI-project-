QA Automation Architecture for FARMAI

Phases:
1. Scoping & baseline tests (unit + widget)
2. Integration (web integration_test), Selenium for E2E web verification
3. Mobile E2E (Appium) for Android
4. Supabase validation and security tests
5. CI/CD automation and reporting

Folders created:
- test/: unit + widget tests
- integration_test/: Flutter integration tests
- selenium_tests/: Selenium examples
- appium_tests/: Appium examples
- security_tests/: Supabase/security scripts
- reports/: report templates and outputs
- .github/workflows/: CI pipelines
- tools/: reporting exporter scripts

Quick commands

- Run unit & widget tests:

```bash
flutter test
```

- Run integration tests (web):

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_screens_test.dart -d web-server
# or use the recommended integration_test runner per Flutter docs
```

- Run Selenium tests (local):

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r tools/requirements.txt selenium
python3 selenium_tests/selenium_login_test.py
```

- Export reports:

```bash
python tools/export_reports.py reports/test_report.json reports/output.xlsx
```

- Run upload validation test (writes base64 asset to temp and validates PNG header):

```bash
flutter test integration_test/upload_image_test.dart
```
