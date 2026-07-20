import os
import sys

REPORTS_DIR = "reports"
VALID_FILES = {
    "FARMAI_Selenium_Web_E2E_Report.xlsx",
    "FARMAI_Appium_Mobile_E2E_Report.xlsx",
    "FARMAI_Security_Vulnerability_Report.xlsx",
    "FARMAI_Load_Performance_SLA_Report.xlsx",
    "FARMAI_Core_Modules_QA_Report.xlsx",
    "FARMAI_Master_QA_Execution_Report.xlsx",
    "FARMAI_Master_QA_Execution_Report.html",
    "test_case_template.csv",
    "selenium_error.png"
}

def force_delete(file_path):
    # Try standard remove
    try:
        os.remove(file_path)
        print(f"Deleted: {file_path}")
        return True
    except Exception:
        pass
    
    # Try Windows command line force delete
    try:
        cmd = f'cmd /c del /f /q /a "{file_path}"'
        os.system(cmd)
        if not os.path.exists(file_path):
            print(f"Force deleted via cmd: {file_path}")
            return True
    except Exception:
        pass
    return False

def clean_reports():
    if not os.path.exists(REPORTS_DIR):
        print("Reports directory does not exist.")
        return

    print("Cleaning reports directory of all duplicate and obsolete files...")
    files = os.listdir(REPORTS_DIR)
    deleted_count = 0
    
    for filename in files:
        file_path = os.path.join(REPORTS_DIR, filename)
        if os.path.isfile(file_path):
            if filename not in VALID_FILES:
                if force_delete(file_path):
                    deleted_count += 1
                else:
                    print(f"Could not remove locked file: {filename}")
                    
    print(f"Cleanup finished. Total duplicate files removed: {deleted_count}")

if __name__ == "__main__":
    clean_reports()
