#!/bin/bash

output_file="units.json"
tmp_file=$(mktemp)

# Flatten the HTML and put each <tr> on a new line
tr -d '\n' < "sorce code.html" | sed 's/<\/tr>/\n/g' > "$tmp_file"

echo "[" > "$output_file"

first=true
while IFS= read -r line; do
    if [[ $line != *'data-id'* ]]; then
        continue
    fi

    if [ "$first" = false ]; then
        echo "," >> "$output_file"
    fi
    first=false

    # Extract data from attributes
    id=$(echo "$line" | sed -n 's/.*data-id="\([^"]*\)".*/\1/p')
    nation=$(echo "$line" | sed -n 's/.*data-nation="\([^"]*\)".*/\1/p')
    year=$(echo "$line" | sed -n 's/.*data-year="\([^"]*\)".*/\1/p')

    # Extract data from <td> elements
    name=$(echo "$line" | sed -n 's/.*<a [^>]*>\([^<]*\)<\/a>.*/\1/p' | sed 's/"/\\"/g')

    # Split the line by <td> tags to get the content of each cell
    cells=$(echo "$line" | sed 's/<td/\n<td/g' | sed 's/<[^>]*>//g' | sed '/^\s*$/d' | sed 's/^\s*//;s/\s*$//' | sed ':a;N;$!ba;s/\n/|/g')

    IFS='|' read -r -a cells_array <<< "$cells"

    category_type=$(echo "${cells_array[3]}" | sed 's/"/\\"/g')
    cost=$(echo "${cells_array[5]}" | sed 's/"/\\"/g')
    def_spd=$(echo "${cells_array[6]}" | sed 's/"/\\"/g')
    ai_av=$(echo "${cells_array[7]}" | sed 's/"/\\"/g')
    abilities=$(echo "${cells_array[8]}" | sed 's/"/\\"/g')

    # Create JSON object
    printf '{\n' >> "$output_file"
    printf '  "id": "%s",\n' "$id" >> "$output_file"
    printf '  "nation": "%s",\n' "$nation" >> "$output_file"
    printf '  "year": "%s",\n' "$year" >> "$output_file"
    printf '  "name": "%s",\n' "$name" >> "$output_file"
    printf '  "category_type": "%s",\n' "$category_type" >> "$output_file"
    printf '  "cost": "%s",\n' "$cost" >> "$output_file"
    printf '  "def_spd": "%s",\n' "$def_spd" >> "$output_file"
    printf '  "ai_av": "%s",\n' "$ai_av" >> "$output_file"
    printf '  "abilities": "%s"\n' "$abilities" >> "$output_file"
    printf '}' >> "$output_file"

done < "$tmp_file"

echo "" >> "$output_file"
echo "]" >> "$output_file"

rm "$tmp_file"
