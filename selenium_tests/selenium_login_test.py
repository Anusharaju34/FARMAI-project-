import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import os

# Configure the local port or deployment domain of the Flutter Web App
APP_URL = "http://localhost:8085/#/screen-list"

def run_selenium_test():
    options = Options()
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print("Initializing headless Chrome browser (CI/CD mode)...")
        options.add_argument("--headless=new")
    else:
        print("Initializing Chrome browser (visible mode)...")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1280,800")
    
    driver = webdriver.Chrome(options=options)
    wait = WebDriverWait(driver, 15)
    
    try:
        print(f"Navigating to {APP_URL}...")
        driver.get(APP_URL)
        time.sleep(5) # Wait for page load
        
        # Click the hidden accessibility button to force semantics DOM rendering
        try:
            print("Activating Flutter HTML Semantics via shadow DOM...")
            activated = driver.execute_script("""
                let pane = document.querySelector('flt-glass-pane');
                let btn = null;
                if (pane) {
                  if (pane.shadowRoot) {
                    btn = pane.shadowRoot.querySelector('button') || pane.shadowRoot.querySelector('[aria-label="Enable accessibility"]');
                  }
                  if (!btn) {
                    btn = pane.querySelector('button') || pane.querySelector('[aria-label="Enable accessibility"]');
                  }
                }
                if (btn) {
                  btn.click();
                  return true;
                }
                return false;
            """)
            print(f"Semantics activation trigger click result: {activated}")
            time.sleep(4)
        except Exception as se:
            print(f"Warning: Semantics script execution failed: {se}")
            
        # Verify the screen list tester renders successfully
        print("Locating screen list buttons...")
        # Since Flutter Web uses Semantics, locate using XPATH with fallback accessibility role search
        try:
            # Look for button that says "Login"
            login_nav_btn = wait.until(
                EC.element_to_be_clickable((By.XPATH, "//*[contains(text(), 'Login')] | //*[@aria-label='Login'] | //flt-semantics[@role='button' and @aria-label='Login']"))
            )
            print("Nav button 'Login' found. Clicking to navigate...")
            login_nav_btn.click()
            time.sleep(3)
        except Exception as e:
            print(f"Direct semantic lookup failed, trying fallback tag click. Error: {e}")
            # Fallback: find all accessible buttons and click the one that matches Login (index 2 in list)
            buttons = driver.find_elements(By.XPATH, "//flt-semantics[@role='button'] | //*[@role='button']")
            print(f"Found {len(buttons)} accessible button elements on page.")
            # Click Login (index 2 on visible_test_app list)
            buttons[2].click()
            time.sleep(3)
            
        print("Login screen loaded. Verifying input elements...")
        # Locate textfields or input fields
        inputs = wait.until(
            EC.presence_of_all_elements_located((By.TAG_NAME, "input"))
        )
        print(f"Found {len(inputs)} input fields on the screen.")
        assert len(inputs) >= 2, f"Expected at least 2 input fields, found {len(inputs)}"
        
        # Input credentials
        print("Entering credentials...")
        email_field = inputs[0]
        password_field = inputs[1]
        
        email_field.clear()
        email_field.send_keys("farmer@example.com")
        password_field.clear()
        password_field.send_keys("password123")
        time.sleep(1)
        
        print("Clicking Submit Sign-In button...")
        # Find submit button (usually tag button or semantic element)
        submit_btn = driver.find_element(By.XPATH, "//*[@aria-label='Sign In'] | //button[contains(., 'Sign In')]")
        submit_btn.click()
        time.sleep(2)
        
        print("Selenium Web E2E smoke test completed successfully!")
        
    except Exception as ex:
        print(f"Selenium Test FAILED: {ex}")
        # Take screenshot for debugging
        driver.save_screenshot("reports/selenium_error.png")
        print("Saved error screenshot to reports/selenium_error.png")
        raise ex
    finally:
        driver.quit()

if __name__ == "__main__":
    run_selenium_test()
