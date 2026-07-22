import os
import pytest
from appium import webdriver
from appium.options.android import UiAutomator2Options

@pytest.fixture(scope="session")
def driver():
    os.makedirs("qa/reports", exist_ok=True)
    status_file = "qa/reports/appium_status.txt"
    
    # Target options for Android Emulator
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.device_name = "Android Emulator"
    options.app_package = "com.example.farmai"
    options.app_activity = ".MainActivity"
    options.automation_name = "UiAutomator2"
    options.no_reset = True
    
    app_path = "build/app/outputs/flutter-apk/app-release.apk"
    if os.path.exists(app_path):
        options.app = os.path.abspath(app_path)
    
    # Try connecting to Appium Server on localhost:4723
    try:
        appium_url = "http://localhost:4723"
        driver = webdriver.Remote(appium_url, options=options)
        with open(status_file, "w", encoding="utf-8") as f:
            f.write("APPIUM_SUCCESS")
    except Exception as e:
        print(f"Appium / Emulator connection failed: {e}")
        # Write failure status file so merging script knows to mark as Not Executed
        with open(status_file, "w", encoding="utf-8") as f:
            f.write("EMULATOR_FAILED")
        pytest.skip(f"Appium Server or Android Emulator is not available: {e}")
        
    yield driver
    driver.quit()

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    if rep.when == "call" and rep.failed:
        try:
            if "driver" in item.fixturenames:
                mobile_driver = item.funcargs["driver"]
                os.makedirs("qa/reports", exist_ok=True)
                screenshot_path = "qa/reports/appium_failure.png"
                mobile_driver.save_screenshot(screenshot_path)
                print(f"\nMobile screenshot saved to: {screenshot_path}")
        except Exception as e:
            print(f"Failed to capture mobile screenshot: {e}")
