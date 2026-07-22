# FARMAI QA Automation Framework

A complete, professional QA automation framework designed for the FARMAI Flutter project. The framework runs automatically in GitHub Actions CI, executes exactly 300 test cases across 5 test suites, and generates a formatted master Excel report.

---

## Required Software

To run the automated tests locally, install the following tools:

1. **Flutter SDK (Stable channel)**: To run unit and widget tests.
2. **Python 3.11+**: To run Selenium, Appium, security checks, and report consolidated merging scripts.
3. **Node.js 20+ & npm**: Required to run the Appium server.
4. **Google Chrome & ChromeDriver**: Required for Selenium Web UI tests.
5. **Android SDK & Emulator**: Required for Appium Android testing.
6. **Grafana k6 (v0.49+)**: Required for load and performance SLA testing.
7. **OWASP ZAP (v2.14+)**: Required for security and baseline vulnerability scanning.

---

## Folder Structure

```
qa/
  selenium/                  # Selenium web UI page objects & pytest scripts
  appium/                    # Appium mobile UI pytest scripts
  load/                      # Grafana k6 performance SLA tests
  security/                  # Dependency checking, secret scanner & ZAP baseline config
  reports/                   # Local reports folder (XMLs, screenshots, and final Excel workbook)
  scripts/                   # Master data builder & consolidation merge scripts
  test_data/                 # Master JSON database (test_cases_data.json) for 300 test cases
  README.md                  # This documentation file
```

---

## How to Run Each Test Type Locally

First, install the Python dependency requirements:
```bash
pip install openpyxl pandas selenium webdriver-manager Appium-Python-Client pytest
```

### 1. Flutter Unit & Widget Tests (60 Test Cases)
Execute Flutter tests:
```bash
flutter test test/unit/qa_unit_tests.dart test/widget/qa_widget_tests.dart
```

### 2. Selenium Web UI Tests (100 Test Cases)
First, compile and serve the Flutter web application:
```bash
flutter build web --release
# Serve on port 8085
python -m http.server 8085 --directory build/web
```
Then, execute the Selenium pytests:
```bash
pytest qa/selenium/test_web_ui.py --junitxml=qa/reports/selenium_junit.xml
```

### 3. Appium Mobile Tests (80 Test Cases)
First, build the Android APK:
```bash
flutter build apk --release
```
Start your Android Emulator and ensure the Appium server is running:
```bash
appium --port 4723
```
Then, run the Appium pytests:
```bash
pytest qa/appium/test_mobile_ui.py --junitxml=qa/reports/appium_junit.xml
```

### 4. k6 Load Tests (30 Test Cases)
Execute the k6 script to test endpoint response thresholds (p95 < 350ms):
```bash
k6 run qa/load/k6_load_test.js
```

### 5. OWASP ZAP & Security Validation (30 Test Cases)
Execute the static secrets scan and dynamic header checklist:
```bash
python qa/security/security_audit.py
```

### 6. Excel Report Compilation & Consolidation
Run the consolidation script to parse raw logs/reports and generate `FARMAI_QA_300_Test_Cases.xlsx`:
```bash
python qa/scripts/merge_reports.py
```

---

## How to Run in GitHub Actions

The workflow triggers automatically on:
- A `push` to the `main` branch.
- A `pull_request` to the `main` branch.
- Manual trigger via **`workflow_dispatch`** in the GitHub Actions tab.

---

## How to Download the Excel Report

1. Navigate to the **Actions** tab of your repository.
2. Select the run execution of **QA Framework Automation**.
3. Scroll down to the **Artifacts** section at the bottom.
4. Click on **`FARMAI-QA-Excel-Report`** to download `FARMAI_QA_300_Test_Cases.xlsx`.

---

## Test Status Interpretation

- **Passed**: The test executed and met all assertions and performance SLA thresholds.
- **Failed**: The test encountered a functional assertion error, page element selector failure, or exceeded SLA thresholds. A screenshot of the failure is uploaded in the artifacts.
- **Skipped / Not Executed**: The test could not safely run in the target environment (e.g. Android Emulator starting without KVM virtualization in CI containers). It is marked cleanly with a remarks statement to ensure zero false passes.

---

## GitHub Secrets Required

Define these secrets under your repository's Settings > Secrets and variables > Actions:

- `SUPABASE_URL`: The production/staging Supabase URL.
- `SUPABASE_ANON_KEY`: The anonymous API key for authorization.

---

## Common Appium Emulator Troubleshooting

1. **KVM Acceleration Missing**: GitHub Actions default Linux VMs lack virtualization acceleration (KVM). Tests will gracefully write `EMULATOR_FAILED` and mark mobile cases `Not Executed` rather than failing the build step or reporting false passes.
2. **Appium Session Creation Timeout**: Ensure the emulator is fully booted before initiating Pytest by running:
   ```bash
   adb wait-for-device shell 'while [[ $(getprop sys.boot_completed) -ne 1 ]]; do sleep 1; done'
   ```
3. **Driver Path Missing**: If Appium fails to locate the Android SDK, specify:
   ```bash
   export ANDROID_HOME=$HOME/Android/Sdk
   export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
   ```
