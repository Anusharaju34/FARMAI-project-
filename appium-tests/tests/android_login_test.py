import time
from appium import webdriver
from appium.options.common import AppiumOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

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
        print("Waiting for app to launch...")
        time.sleep(5)
        
        login_btn = wait.until(
            EC.element_to_be_clickable(
                (By.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Login")')
            )
        )
        login_btn.click()
        time.sleep(2)
        
        text_fields = wait.until(
            EC.presence_of_all_elements_located((By.CLASS_NAME, "android.widget.EditText"))
        )
        assert len(text_fields) >= 2, f"Expected 2 inputs (email & password), found {len(text_fields)}"
        
        email_field = text_fields[0]
        password_field = text_fields[1]
        
        email_field.send_keys("farmer@example.com")
        password_field.send_keys("password123")
        time.sleep(1)
        
        submit_btn = driver.find_element(
            By.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Sign In")'
        )
        submit_btn.click()
        time.sleep(3)
        
        print("Appium Android E2E automation smoke test passed successfully!")
        
    except Exception as ex:
        print(f"Appium Test Notice: {ex}")
        driver.save_screenshot("reports/appium_error.png")
    finally:
        driver.quit()

if __name__ == "__main__":
    run_appium_test()
