#!/bin/bash

# Check if a filename is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <markdown_file>"
    exit 1
fi

input_file="$1"
log_file="script_log.txt"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File not found: $input_file"
    exit 1
fi

# Normalize line endings in the input file
dos2unix "$input_file" 2>/dev/null

# Function to sanitize the header text and create a new file
sanitize_and_create_file() {
    local header_line="$1"
    local header_text=$(echo "$header_line" | sed -E 's/^#+ \*\?(.*)\?\*$/\1/' | sed 's/^[ \t]*//')
    local output_file=$(echo "$header_line" | sed -E 's/^[0-9]+:#\ *//' | tr ' ' '_' | tr -d '*' | tr '[:upper:]' '[:lower:]').md
    touch "$output_file"
    echo "Creating file: $output_file" >> "$log_file"
    echo "Header line: $header_line" >> "$log_file"
    echo "Sanitized header text: $header_text" >> "$log_file"
    echo "$header_line" >> "$output_file"
    awk -v "header=$header_line" '
        NR>1 && /^# \*/ { exit }
        NR>1 && /^# / { exit }
        { print }
    ' "$input_file" >> "$output_file"
    local input_file_name=$(basename "$input_file" | sed 's/\.[^.]*$//')  # Remove extension from input file name
    echo "[[$input_file_name]]" >> "$output_file"  # Add the line with the input file name
    echo "File creation done: $output_file" >> "$log_file"
    echo "File created: $output_file"
}

# Main script logic
current_header=""
echo "Start parsing the file..." > "$log_file"

# Use grep to find headers in the input file and display the output for debugging
echo "---- Grep Output ----" >> "$log_file"
grep -nE '^#[[:space:]]+\*.*\*' "$input_file" >> "$log_file"
echo "---- End of Grep Output ----" >> "$log_file"

created_files=()
grep -nE '^#[[:space:]]+\*.*\*' "$input_file" | while IFS= read -r line; do
    if [[ "$line" =~ ^[0-9]+:#\ .* ]]; then
        if [ -n "$current_header" ]; then
            sanitize_and_create_file "$current_header"
            created_files+=("$current_header")
        fi
        current_header=$(echo "$line" | sed 's/^[0-9]\+://')
    else
        if [ -n "$current_header" ]; then
            current_header="$current_header"$'\n'"$line"
        fi
    fi
done

# Process the last header, if any
if [ -n "$current_header" ]; then
    sanitize_and_create_file "$current_header"
    created_files+=("$current_header")
fi

echo "Parsing complete. Check the log file for details: $log_file"

# Print the list of created files
echo "Files created:" >> "$log_file"
for ((i=0; i<${#created_files[@]}; i++)); do
    echo "${created_files[$i]}" | sed 's/^[0-9]\+://; s/^\s*#*\s*//; s/\*\?$/\.md/' | tr ' ' '_' | tr -d '*' | tr '[:upper:]' '[:lower:]' >> "$log_file"
done
