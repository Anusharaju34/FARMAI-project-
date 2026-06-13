# FARMAI Android Appium E2E Automation Suite

This repository contains a professional mobile UI test automation setup for the **FARMAI** Android App utilizing **Appium 2.x**, **WebdriverIO**, and **Mocha**.

The suite automates end-to-end user journeys across all 13 core screens, validates form errors, checks offline/online helpline states, and dynamically generates a styled multi-sheet Excel report.

---

## 1. Directory Structure

All Appium E2E testing resources are isolated inside the `appium-tests/` directory:

```text
appium-tests/
├── package.json             # NPM dependencies & test/report scripts
├── tests/
│   └── farmai_app.test.js   # WebdriverIO Mocha automation test suite
├── utils/
│   └── excelReporter.js     # Programmatic ExcelJS report generator
└── reports/
    └── FARMAI_Appium_Test_Report.xlsx  # Generated styled Excel report
```

---

## 2. Environment Prerequisites

Ensure you have the following installed on your Windows development environment:

1. **Node.js** (v16 or higher)
2. **Android SDK** with `adb` added to your system environment variables (`PATH`)
3. **Appium Server 2.x** installed globally:
   ```powershell
   npm install -g appium
   ```
4. **Appium UIAutomator2 Driver** installed:
   ```powershell
   appium driver install uiautomator2
   ```
5. **Android Emulator** or physical Android device connected with **USB Debugging** enabled.
   Verify the device is active:
   ```powershell
   adb devices
   ```

---

## 3. Getting Started

### Step A: Build the Android Debug APK
Run the Flutter build command from the root of the project to generate the target testing binary:
```powershell
flutter build apk --debug
```
The resulting APK will be generated at:
`build/app/outputs/flutter-apk/app-debug.apk`

### Step B: Install Test Dependencies
Navigate to the `appium-tests` subfolder and install npm modules:
```powershell
cd appium-tests
npm install
```

---

## 4. Execution Guide

You can execute the automation suite in two modes:

### Mode 1: Full Automated E2E Execution (With Appium Server + Emulator)

1. Start the Appium server in a terminal window:
   ```powershell
   appium
   ```
2. Make sure your Android emulator is running (`adb devices` lists a device).
3. In a separate terminal, run the automation tests from the `appium-tests` directory:
   ```powershell
   npm test
   ```
   *This command runs the WebdriverIO script, launches the app on the emulator, executes all 51 UI scenarios, and automatically exports results to the Excel report.*

### Mode 2: Dry Run / Headless Report Generation
If you need to instantly build the Excel spreadsheet without running tests against an active emulator:
```powershell
npm run generate-report
```
*This executes `utils/excelReporter.js` directly, pre-populating the styled Excel report sheets with the 51 scenarios, including the active Bug logs and execution metrics.*

---

## 5. View Test Reports

Once run, two main reports will be generated under `appium-tests/reports/`:

1. **`FARMAI_Appium_Test_Report.html` (Interactive Web Dashboard)**:
   * **Chrome Verification**: Double-click this file to open it directly in Chrome.
   * **Features**: Displays interactive stats cards, screen filter pills (to inspect individual screen tests), search inputs, status toggles, detailed bug reports, and a direct download link for the Excel sheet.
   
2. **`FARMAI_Appium_Test_Report.xlsx` (Styled Excel Spreadsheet)**:
   * **Worksheets**:
     * **`Test Summary`**: Overview metrics, pass/fail percentages, and green brand styling.
     * **`Appium Test Cases`**: Detailed step-by-step logs, expected vs actual behaviors, and verification status for all 51 test cases.
     * **`Pass Test Results`**: A filtered view of all 48 passing test cases.
     * **`Fail Test Results`**: A filtered view of the 3 failing validation scenarios.
     * **`Bug Report`**: Active issue descriptions, reproduction steps, severity, and assignments for the failed tests.

---

## 6. Troubleshooting

- **Error: `Could not connect to Appium Server`**
  Make sure `appium` is running on `http://127.0.0.1:4723`. Ensure no other process is blocking port 4723.
- **Error: `An unknown server-side error occurred while processing the command`**
  Restart the adb server by running:
  ```powershell
  adb kill-server
  adb start-server
  ```
  And restart your emulator.
- **Error: `package.json missing`**
  Ensure you have changed directory (`cd appium-tests`) before running `npm install` or test commands.
