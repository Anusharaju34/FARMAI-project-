import time
from appium import webdriver
from appium.options.common import AppiumOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Appium Capabilities for Android Flutter testing
# AppPackage and AppActivity should match your compiled Flutter apk metadata.
# Typically, package = com.example.farmai (or similar) and activity = .MainActivity
CAPABILITIES = {
    "platformName": "Android",
    "automationName": "UiAutomator2",
    "appPackage": "com.example.farmai",
    "appActivity": "com.example.farmai.MainActivity",
    "noReset": True,
    "ensureWebviewsHavePages": True,
    "nativeWebScreenshot": True,
    "newCommandTimeout": 3600,
}

APPIUM_SERVER_URL = "http://localhost:4723"

def run_appium_test():
    print("Connecting to Appium Server...")
    options = AppiumOptions()
    options.load_capabilities(CAPABILITIES)
    
    driver = webdriver.Remote(APPIUM_SERVER_URL, options=options)
    wait = WebDriverWait(driver, 15)
    
    try:
        print("Waiting for app to launch and screen switcher to display...")
        time.sleep(5)
        
        # Click the "Login" button from the screen list tester
        print("Locating 'Login' button in screen switcher...")
        # Finding by text selector is highly reliable for Flutter accessibility labels
        login_btn = wait.until(
            EC.element_to_be_clickable(
                (By.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Login")')
            )
        )
        login_btn.click()
        print("Tapped 'Login'. Waiting for login page to load...")
        time.sleep(2)
        
        # In Flutter, text inputs map to android.widget.EditText
        print("Locating input fields...")
        text_fields = wait.until(
            EC.presence_of_all_elements_located((By.CLASS_NAME, "android.widget.EditText"))
        )
        print(f"Found {len(text_fields)} input fields.")
        assert len(text_fields) >= 2, f"Expected 2 inputs (email & password), found {len(text_fields)}"
        
        email_field = text_fields[0]
        password_field = text_fields[1]
        
        print("Entering credentials...")
        email_field.send_keys("farmer@example.com")
        password_field.send_keys("password123")
        time.sleep(1)
        
        # Tapping the Submit Sign In button
        print("Tapping the Sign In button...")
        submit_btn = driver.find_element(
            By.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Sign In")'
        )
        submit_btn.click()
        time.sleep(3)
        
        print("Appium Android E2E automation smoke test passed successfully!")
        
    except Exception as ex:
        print(f"Appium Test FAILED: {ex}")
        driver.save_screenshot("reports/appium_error.png")
        print("Saved error screenshot to reports/appium_error.png")
        raise ex
    finally:
        print("Quitting driver...")
        driver.quit()

if __name__ == "__main__":
    run_appium_test()
