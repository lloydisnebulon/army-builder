from playwright.sync_api import sync_playwright
import os

def run_verification():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # Listen for console events and print them
        page.on("console", lambda msg: print(f"CONSOLE: {msg.text}"))

        # Get the absolute path to the HTML file
        html_file_path = os.path.abspath('army builder test 23.1 - offline-ready.html')

        # Go to the local HTML file
        page.goto(f'file://{html_file_path}')

        try:
            # Wait for the unit list to be populated, with a shorter timeout for faster failure
            page.wait_for_selector('.unit-card', timeout=10000)
        except Exception as e:
            print(f"Caught an exception: {e}")
            # Take a screenshot on failure to see what's wrong
            page.screenshot(path='jules-scratch/verification/verification-failure.png')
            raise

        # Take a screenshot on success
        page.screenshot(path='jules-scratch/verification/verification.png')

        browser.close()

if __name__ == '__main__':
    run_verification()
