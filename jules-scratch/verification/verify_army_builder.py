from playwright.sync_api import sync_playwright
import os

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    page = browser.new_page()
    # Construct the file path to be absolute
    file_path = "file://" + os.path.abspath("offline_army_builder.html")
    page.goto(file_path)
    # Check if the unit list is populated
    page.wait_for_selector("#unitAAMarmyList tr[data-id]")
    page.screenshot(path="jules-scratch/verification/verification.png")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)
