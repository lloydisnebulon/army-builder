#!/bin/bash

# Create the new script block
cat <<EOF > new_script.js
<script>
const embeddedUnits =
EOF

cat units.json >> new_script.js

cat <<EOF >> new_script.js
;
const embeddedFaqs =
EOF

cat faq.json >> new_script.js

cat <<EOF >> new_script.js
;
</script>
EOF

# Create a temporary version of the template file with the first script block removed
# Correctly escaped the backslash in the sed command
sed '1,/<\\/script>/d' "army builder test 23.1 - offline-ready.html" > temp_template.html

# Assemble the final HTML file
cat new_script.js temp_template.html > offline_army_builder.html

# Clean up the temporary file
rm temp_template.html
