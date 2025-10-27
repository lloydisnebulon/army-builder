import json
import requests
import time
from bs4 import BeautifulSoup

UNITS_FILE = 'units.json'
FAQ_FILE = 'faq.json'

def main():
    with open(UNITS_FILE, 'r', encoding='utf-8') as f:
        units = json.load(f)

    faq_data = {}
    print(f"Starting FAQ extraction for {len(units)} units...")

    for i, unit in enumerate(units):
        unit_id = unit.get('id')
        href = unit.get('href')

        if not href:
            print(f"Skipping unit {unit_id} due to missing href.")
            continue

        print(f"Fetching FAQ for unit {i+1}/{len(units)}: {unit.get('name')}")

        try:
            response = requests.get(href, timeout=10)
            response.raise_for_status()  # Will raise an HTTPError for bad responses
            html = response.text

            soup = BeautifulSoup(html, 'html.parser')

            faq_header = soup.find(lambda tag: "Special Abilities Errata & FAQ" in tag.get_text())

            if faq_header:
                faq_content = ""
                for sibling in faq_header.find_next_siblings():
                    if sibling.name == 'a' and sibling.get('name') == 'specials':
                        continue
                    if (sibling.name == 'a' and sibling.get('name')) or (sibling.name == 'div' and sibling.get('id') == 'footer'):
                        break
                    faq_content += sibling.get_text(separator='\\n', strip=True) + '\\n'

                if faq_content.strip():
                    faq_data[unit_id] = faq_content.strip()
                    print("  -> Found FAQ.")
                else:
                    print("  -> FAQ section found, but it's empty.")
            else:
                print("  -> No FAQ section found.")

        except requests.exceptions.RequestException as e:
            print(f"  -> Failed to fetch URL: {e}")

        time.sleep(0.5)  # Be a good netizen

    with open(FAQ_FILE, 'w', encoding='utf-8') as f:
        json.dump(faq_data, f, indent=2)

    print(f"FAQ extraction complete. Data saved to {FAQ_FILE}")

if __name__ == '__main__':
    main()
