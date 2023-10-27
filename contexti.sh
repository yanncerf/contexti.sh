#!/bin/bash

# Check for the file extension
file_extension="${1##*.}"
if [ "$file_extension" == "pdf" ]; then
    # If it's a PDF, convert it to text using pdftotext
    text_file="${1}.txt"
    pdftotext "$1" "$text_file"
elif [ "$file_extension" == "odt" ]; then
    # If it's an ODT file, convert it to text using odt2txt
    text_file="${1}.txt"
    odt2txt "$1" > "$text_file"
elif [ "$file_extension" == "docx" ]; then
    # If it's a DOCX file, convert it to text using docx2txt
    text_file="${1}.txt"
    docx2txt "$1" "$text_file"
else
    # If it's not a supported format, exit
    echo "Unsupported file format. Please provide a PDF, ODT, or DOCX file."
    exit 1
fi

# First grep command to capture references in a specific format
references=$(grep -o -P '\b(?:[A-Z][A-Za-z'"'"'`-]+)(?:,? (?:and |& )?(?:[A-Z][A-Za-z'"'"'`-]+|(?:et al.?)))*(?:,? *(?:[0-9]{4}(?:, p\.? [0-9]+)?)(?:.*)?)' "$text_file")

# Second grep command to capture years (YYYY)
years=$(echo "$references" | grep -o -E '\b(1[4-9][0-9][0-9]|20[0-9][0-9])\b')

# Process the text file to count references by decade
reference_counts=$(echo "$years" | awk -F: '{print $1}' | awk -F. '{print $1}' | sort)

# Calculate total references
total_references=$(echo "$reference_counts" | wc -l)

# Calculate percentages for decades with 2 decimal places
percentages_decades=$(echo "$reference_counts" | awk '{count[int($1 / 10) * 10]++} END {for (decade in count) printf "%s: %d references (%.2f%%)\n", decade, count[decade], (count[decade]/'"$total_references"'*100) }' | sort)

# Calculate percentages for half-centuries with 2 decimal places
percentages_half_centuries=$(echo "$reference_counts" | awk '{count[int(($1 + 25) / 50) * 50]++} END {for (half_century in count) printf "%s: %d references (%.2f%%)\n", half_century, count[half_century], (count[half_century]/'"$total_references"'*100) }' | sort)

# Calculate percentages for centuries with 2 decimal places
percentages_centuries=$(echo "$reference_counts" | awk '{count[int(($1 + 50) / 100) * 100]++} END {for (century in count) printf "%s: %d references (%.2f%%)\n", century, count[century], (count[century]/'"$total_references"'*100) }' | sort)

# Print the results
echo "Total References: $total_references"
echo "Percentage Counts by Decade:"
echo "$percentages_decades"
echo "Percentage Counts by Half-Centuries:"
echo "$percentages_half_centuries"
echo "Percentage Counts by Centuries:"
echo "$percentages_centuries"

# Clean up the temporary text file
rm "$text_file"

