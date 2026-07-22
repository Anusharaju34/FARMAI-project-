import os
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

@pytest.fixture(scope="session")
def driver():
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--window-size=1920,1080")
    
    # Check if ChromeDriver is available on the system path
    try:
        driver = webdriver.Chrome(options=chrome_options)
    except Exception:
        # Fallback to webdriver_manager if not available on path
        try:
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=chrome_options)
        except Exception as e:
            pytest.skip(f"ChromeDriver initialization failed: {e}")
            
    yield driver
    driver.quit()

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    # Hook to capture screenshot on test failure
    outcome = yield
    rep = outcome.get_result()
    if rep.when == "call" and rep.failed:
        try:
            if "driver" in item.fixturenames:
                web_driver = item.funcargs["driver"]
                os.makedirs("qa/reports", exist_ok=True)
                screenshot_path = "qa/reports/selenium_failure.png"
                web_driver.save_screenshot(screenshot_path)
                print(f"\nScreenshot saved to: {screenshot_path}")
        except Exception as e:
            print(f"Failed to capture screenshot: {e}")
